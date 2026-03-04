#!/usr/bin/env bash
set -euo pipefail

URL="${LIBRENMS_URL:?set LIBRENMS_URL}"
TOKEN="${LIBRENMS_TOKEN:?set LIBRENMS_TOKEN}"
START="${START_US:-6}"
END="${END_US:-41}"

api() {
  local method="$1"; shift
  local path="$1"; shift
  curl -fsS -X "$method" \
    -H "X-Auth-Token: $TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "$URL$path" "$@"
}

# один раз получаем список групп
GROUPS_JSON="$(api GET /api/v0/devicegroups)"

group_exists() {
  local name="$1"
  echo "$GROUPS_JSON" | grep -q "\"name\"[[:space:]]*:[[:space:]]*\"$name\""
}

for i in $(seq "$START" "$END"); do
  NAME="US$i"
  REGEX="^us${i}_[^0-9]"

  # rules как JSON-строка (обрати внимание на экранирование кавычек)
  RULES_STR=$(printf '{"condition":"AND","rules":[{"id":"devices.sysName","field":"devices.sysName","type":"string","input":"text","operator":"regex","value":"%s"}],"valid":true}' "$REGEX")

  PAYLOAD=$(cat <<JSON
{
  "name": "$NAME",
  "desc": null,
  "type": "dynamic",
  "rules": $(python3 - <<PY
import json
print(json.dumps("""$RULES_STR"""))
PY
)
}
JSON
)

  if group_exists "$NAME"; then
    echo "SKIP (exists) $NAME"
  else
    echo "CREATE $NAME -> $REGEX"
    api POST /api/v0/devicegroups --data-raw "$PAYLOAD" >/dev/null
  fi
done

echo "DONE."