# Your Spotify on Railway

A Railway template for [Your Spotify](https://github.com/Yooooomi/your_spotify), a self-hosted dashboard that records your Spotify listening history and turns it into statistics.

## What it deploys

| Service | Source | Purpose |
|---|---|---|
| `your-spotify` | this repo (`Dockerfile`) | Official `yooooomi/your_spotify_server` and `yooooomi/your_spotify_client` **1.20.0** images, pinned by digest, served by a small Caddy proxy on one public domain: the web app at `/`, the API at `/api` |
| `MongoDB` | `mongo:8.0.38` (pinned by digest) | Database, data on a Railway volume at `/data/db`, private network only |

Serving the web app and the API on one domain keeps Your Spotify's `SameSite=Strict` login cookie first-party, and you only register one URL with Spotify.

## Variables

| Variable | Service | Value |
|---|---|---|
| `SPOTIFY_PUBLIC` | your-spotify | **You provide it.** Client ID of your Spotify app |
| `SPOTIFY_SECRET` | your-spotify | **You provide it.** Client secret of your Spotify app |
| `MONGO_ENDPOINT` | your-spotify | Reference to the MongoDB service (`${{MongoDB.MONGO_URL}}/your_spotify?authSource=admin`) |
| `CLIENT_ENDPOINT` | your-spotify | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| `API_ENDPOINT` | your-spotify | `https://${{RAILWAY_PUBLIC_DOMAIN}}/api` |
| `TIMEZONE` | your-spotify | `Etc/UTC` (timezone used for statistics; each user can override it in Settings) |
| `MONGO_INITDB_ROOT_PASSWORD` | MongoDB | Generated at deploy (`${{secret(32)}}`) |

Optional upstream settings (`LOG_LEVEL`, `COOKIE_VALIDITY_MS`, `PROMETHEUS_USERNAME`/`PROMETHEUS_PASSWORD`, `MAX_IMPORT_CACHE_SIZE`, `FRAME_ANCESTORS`) can be added to the `your-spotify` service later; see the [upstream README](https://github.com/Yooooomi/your_spotify#environment).

## Setting up Spotify

1. Create an app at <https://developer.spotify.com/dashboard> and tick **Web API**.
2. Add the redirect URI `https://YOUR-DOMAIN/api/oauth/spotify/callback`, where `YOUR-DOMAIN` is the Railway domain of the `your-spotify` service (the deploy logs print the exact URI).
3. Copy the app's Client ID and Client secret into `SPOTIFY_PUBLIC` and `SPOTIFY_SECRET`.
4. Open the Railway domain and log in with Spotify. The first account becomes the admin. Turn off new registrations in **Settings** if the instance is just for you, and add other listeners under **User Management** in the Spotify dashboard.

## Updates

The template builds from this repository. When a new Your Spotify release is out, the pinned image digests in the `Dockerfile` are bumped here and noted in [`CHANGELOG.md`](CHANGELOG.md). Railway then shows an "update available" notice on your project, and you choose when to apply it. Database migrations run automatically at start.

## Local test

`docker compose -f compose.test.yml up --build`, then open <http://localhost:8080>. The test compose file is not used by Railway.

## License

Your Spotify is licensed under GPL-3.0 by Yooooomi and contributors. This repo only adds the Railway wrapper (Dockerfile, Caddyfile, start script).
