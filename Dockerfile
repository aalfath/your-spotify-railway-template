# Your Spotify for Railway: the official server and web client images, served together
# behind a small Caddy proxy on one domain (web app at /, API at /api).
# Upstream: https://github.com/Yooooomi/your_spotify (GPL-3.0)
FROM yooooomi/your_spotify_client:1.20.0@sha256:e4da90a0634c7862f9f4e893026ee8cd91380234fa2125b88b26c6fb9da3d47e AS client
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0 AS caddy

FROM yooooomi/your_spotify_server:1.20.0@sha256:624ea009f2ef9d877989bee9c7913ac66840449f566517871696c31a8ea13ddf

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=client /app/apps/client/build/ /app/apps/client/build/
COPY --from=client /app/apps/client/scripts/ /app/apps/client/scripts/
COPY rootfs/ /

ENV XDG_DATA_HOME=/tmp/caddy-data XDG_CONFIG_HOME=/tmp/caddy-config

EXPOSE 8080
ENTRYPOINT ["sh", "/usr/local/bin/railway-start.sh"]
