# Web Server in Docker

A custom Nginx-based web server, containerized from scratch — built to actually get hands-on with Docker fundamentals instead of just reading about them: image layering, health checks, container lifecycle, resource limits, and the troubleshooting commands you end up using constantly once something goes wrong.

## Why Nginx over just running a Python `http.server`

I wanted the project to reflect how web servers actually get containerized in practice — a real web server binary with its own config file, not a toy dev server. Nginx also makes the "best practices" part of this task concrete: gzip, custom error pages, log format, blocking access to hidden files — all things you configure explicitly, not defaults you inherit.

## Structure

```
.
├── site/                   # static site served by the container
│   ├── index.html
│   ├── 404.html
│   ├── health.html         # dedicated endpoint for the container health check
│   └── assets/style.css
├── nginx/
│   └── default.conf        # custom Nginx config (replaces the image default)
├── Dockerfile
├── docker-compose.yml
└── scripts/
    └── manage.sh           # lifecycle commands wrapped into one script
```

## Running it

```bash
# build + start in the background
docker compose up -d --build

# visit
http://localhost:8080
```

Or using the helper script:

```bash
chmod +x scripts/manage.sh
./scripts/manage.sh build
./scripts/manage.sh start
./scripts/manage.sh status
```

## What's actually going on under the hood

**Image build:** Based on `nginx:1.27-alpine` rather than the full Debian-based image — the Alpine variant is a fraction of the size, which matters once you're rebuilding repeatedly during development. `curl` gets installed on top since Alpine doesn't ship it by default and the `HEALTHCHECK` instruction needs it.

**Health checks:** The container has a native Docker `HEALTHCHECK` hitting a dedicated `/health.html` endpoint rather than the homepage — kept separate on purpose so a health check doesn't depend on the full page (CSS, templating, etc.) rendering correctly. Health state shows up directly in `docker ps` as `healthy` / `unhealthy` / `starting`, and `docker-compose.yml` duplicates this check so `depends_on: condition: service_healthy` would work correctly if I add a second service later.

**Resource limits:** Capped at 0.5 CPU / 128MB memory in the compose file. Ran into this need firsthand — during earlier testing with no limits set, a container in a different project pinned an entire CPU core and I didn't notice until my machine started lagging. Limits force you to actually think about what a container needs instead of letting it default to "whatever's available."

**Logging:** `json-file` driver capped at 10MB × 3 files. Without a cap, container logs grow unbounded on the host disk — fine for a demo, but the kind of thing that quietly fills a server's disk over weeks in production.

**Read-only volume mount:** The site content is mounted `:ro` (read-only) into the container. Even if the Nginx process were compromised, it can't write back into the source files on the host.

## Container lifecycle — commands I actually used

| Action | Command |
|---|---|
| Build the image | `docker build -t docker-webserver-demo .` |
| Start (detached) | `docker compose up -d` |
| Check running containers | `docker ps` |
| Check health status | `docker inspect --format='{{json .State.Health}}' webserver-demo` |
| View logs | `docker logs -f --tail 50 webserver-demo` |
| Live resource usage | `docker stats webserver-demo` |
| Shell into the container | `docker exec -it webserver-demo sh` |
| Restart | `docker compose restart` |
| Stop (keep container) | `docker compose stop` |
| Stop + remove | `docker compose down` |
| Full cleanup | `docker compose down --rmi local -v && docker system prune -f` |

All of these are wrapped in `scripts/manage.sh` so I'm not retyping the same 15 commands every time — e.g. `./manage.sh health` or `./manage.sh logs`.

## Troubleshooting notes (real issues, not hypothetical ones)

- **Container showed `unhealthy` right after starting.** Turned out the `start_period` in the `HEALTHCHECK` was too short relative to how long Nginx actually took to bind and serve on a cold container start — bumped `start_period` to 5s so the first few checks don't count against it while the container is still coming up.
- **`docker exec -it ... sh` failed with "container not running."** Obvious in hindsight, but worth noting: you can't shell into a stopped container. `docker ps -a` first to confirm the container's actually up before trying to exec into it.
- **Changes to `site/` weren't showing up.** Because the image `COPY`s the site into itself at build time, editing files on the host does nothing to an already-running container unless you're using the volume mount (which `docker-compose.yml` does) — otherwise you have to rebuild the image for changes to take effect. Good reminder of the difference between "baked into the image" and "mounted from the host."
- **`docker stats` showing near-zero CPU/memory even under load** was a good sanity check that the static Nginx setup is genuinely lightweight — useful baseline before adding anything heavier to this later.

## What I'd add next

- A second service (small API) added to `docker-compose.yml` to actually exercise multi-container networking and `depends_on`
- A named volume for Nginx logs so they survive container recreation instead of living inside the ephemeral container filesystem
- Wiring this into the Azure Pipelines CI/CD project so this image gets built and pushed automatically on every commit
