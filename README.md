# docker-nginx-proxy

## appsdevteam/nginx-proxy

nginx pro nginx-proxy (edge proxy s docker-gen a acme-companion, sluzba `nginx-proxy`
v server-management-scripts), platformy `linux/amd64` a `linux/arm64`.

Zaklad je Alpine a nginx z jeho balicku (`nginx`, `nginx-mod-http-lua`,
`nginx-mod-http-lua-upstream`), ne kompilace ze zdrojaku - CVE sken (trivy) pak nginx vidi
jako apk balicek a hlasi jeho zranitelnosti podle Alpine secdb. Alpine bali stabilni vetev
nginx (sude minor cislo).

Obsahuje navic:

- Lua: `lua-resty-http`, `lua-resty-openssl`, `cjson` (CrowdSec lua bouncer - knihovnu
  samotnou mountuje sluzba z volume `crowdsec-lua`)
- `resty.upstream.healthcheck` (openresty lua-resty-upstream-healthcheck v0.08) a
  `resty.string` (lua-resty-string v0.15) v `lua/` - Alpine je nebali
- `curl` (healthcheck kontejneru)

`/etc/nginx/nginx.conf` vklada `conf.d/*.conf` (generuje docker-gen), logy jdou na
stdout/stderr.

## Tagy

Kazdy build ma neprepisovatelny tag s datem buildu (UTC): `<verze nginx>-<revize>-<YYYYMMDD>`,
napr. `1.30.7-1-20261122`. Ten je doporuceny - jen u nej je z nazvu jasne, co v image je.
`<verze nginx>-<revize>` a `latest` se pri kazdem buildu prepisi.

Bezpecnostni opravy Alpine prinasi tydenni rebuild (pondeli). Server na datovem tagu je
dostane vedomym bumpem data - signalem je CVE sken, ktery zacne hlasit opravitelnou
zranitelnost.

Revize (`REVISION` ve workflow) se zvysuje pri zmene image, ktera muze rozbit proxy
(odebrany modul, jine chovani).

## Lokalni build a test

```bash
docker build -t nginx-proxy:test .
test/smoke.sh nginx-proxy:test
```

Smoke test nacte vsechny Lua zavislosti, ktere nginx-proxy pouziva, a overi proxy
a healthcheck upstreamu. Stejny test bezi v CI pred pushem, spolu s trivy (opravitelna
CRITICAL CVE push zastavi).
