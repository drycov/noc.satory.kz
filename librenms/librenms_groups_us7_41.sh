#!/usr/bin/env bash
set -euo pipefail

URL="${LIBRENMS_URL:?set LIBRENMS_URL like https://librenms.local}"
TOKEN="${LIBRENMS_TOKEN:?set LIBRENMS_TOKEN}"
START="${START_US:-1}"
END="${END_US:-41}"

# 1) Вариант regex:
#REGEX_TPL='^us%s_[^0-9]'       # строго как ты написал
REGEX_TPL='^us%s_[^0-9].*'      # более практично (если надо — включи этот)

api() {
  local method="$1"; shift
  local path="$1"; shift
  curl -fsS -X "$method" \
    -H "X-Auth-Token: $TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$URL$path" "$@"
}

# Получить список групп (один раз)
GROUPS_JSON="$(api GET /api/v0/devicegroups)"

group_exists() {
  local name="$1"
  # LibreNMS обычно возвращает {"status":"ok","groups":[...]} или [{"groups":[...]}] в зависимости от версии/обвязки
  echo "$GROUPS_JSON" | grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$name\""
}

for i in $(seq "$START" "$END"); do
  NAME="US$i"
  RULE=$(printf 'devices.sysName REGEXP "%s"' "$(printf "$REGEX_TPL" "$i")")

  # payload: в LibreNMS встречается поле "pattern" (в UI оно Pattern),
  # а в некоторых версиях API оно может называться "rules".
  # Поэтому шлём оба (лишнее игнорируется, нужное применится).
  PAYLOAD=$(cat <<JSON
{
  "name": "$NAME",
  "type": "dynamic",
  "desc": "Auto: sysName us$i",
  "pattern": "$RULE",
  "rules": "$RULE"
}
JSON
)

  if group_exists "$NAME"; then
    echo "UPDATE $NAME -> $RULE"
    # Обновление: в LibreNMS обычно работает PUT на /devicegroups/{name}
    api PUT "/api/v0/devicegroups/$NAME" -d "$PAYLOAD" >/dev/null || {
      echo "WARN: PUT failed for $NAME. Try POST recreate or check API path/version."
    }
  else
    echo "CREATE $NAME -> $RULE"
    api POST /api/v0/devicegroups -d "$PAYLOAD" >/dev/null
  fi
done

echo "DONE."