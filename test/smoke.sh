#!/bin/sh
# Smoke test image: nacte Lua zavislosti nginx-proxy (crowdsec bouncer,
# healthcheck upstreamu) a overi proxy + healthcheck. Pouziti: test/smoke.sh <image>
set -eu
image=$1
dir=$(cd "$(dirname "$0")" && pwd)
name=nginx-proxy-smoke-$$

docker run --rm "$image" nginx -t
docker run -d --name "$name" -v "$dir/smoke.conf:/etc/nginx/conf.d/default.conf:ro" "$image" >/dev/null
trap 'rc=$?; [ $rc -eq 0 ] || docker logs "$name" 2>&1 | tail -20; docker rm -f "$name" >/dev/null; exit $rc' EXIT

sleep 3
docker exec "$name" curl -fsS http://127.0.0.1/ | grep -q '^lua ok '
docker exec "$name" curl -fsS http://127.0.0.1/status | grep -q '127.0.0.1:8081 UP'
if docker logs "$name" 2>&1 | grep -E '\[(emerg|alert|crit|error)\]'; then
	exit 1
fi
docker exec "$name" nginx -v
echo "smoke test OK"
