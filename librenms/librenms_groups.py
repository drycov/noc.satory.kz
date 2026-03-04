#!/usr/bin/env python3
import os
import sys
import requests

URL = os.environ["LIBRENMS_URL"].rstrip("/")
TOKEN = os.environ["LIBRENMS_TOKEN"]
START = int(os.environ.get("START_US", "1"))
END = int(os.environ.get("END_US", "41"))

# как у тебя:
# REGEX_TPL = r'^us{n}_[^0-9]'
# практичнее:
REGEX_TPL = r'^us{n}_[^0-9].*'

sess = requests.Session()
sess.headers.update({
    "X-Auth-Token": TOKEN,
    "Accept": "application/json",
    "Content-Type": "application/json",
})

def req(method: str, path: str, json=None):
    r = sess.request(method, f"{URL}{path}", json=json, timeout=20, verify=True)
    try:
        data = r.json()
    except Exception:
        data = r.text
    if r.status_code >= 400:
        raise RuntimeError(f"{method} {path} -> {r.status_code}: {data}")
    return data

def list_groups():
    data = req("GET", "/api/v0/devicegroups")
    # нормализуем разные форматы ответа
    if isinstance(data, dict) and "groups" in data:
        return data["groups"]
    if isinstance(data, list) and data and isinstance(data[0], dict) and "groups" in data[0]:
        return data[0]["groups"]
    return []

groups = {g.get("name"): g for g in list_groups()}

for n in range(START, END + 1):
    name = f"US{n}"
    rule = f'devices.sysName REGEXP "{REGEX_TPL.format(n=n)}"'

    payload = {
        "name": name,
        "type": "dynamic",
        "desc": f"Auto: sysName us{n}",
        # на разных версиях API встречается pattern или rules
        "pattern": rule,
        "rules": rule,
    }

    if name in groups:
        print(f"UPDATE {name} -> {rule}")
        try:
            req("PUT", f"/api/v0/devicegroups/{name}", json=payload)
        except Exception as e:
            print(f"WARN: PUT failed for {name}: {e}", file=sys.stderr)
    else:
        print(f"CREATE {name} -> {rule}")
        req("POST", "/api/v0/devicegroups", json=payload)

print("DONE")