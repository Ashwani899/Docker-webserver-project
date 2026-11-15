# Dockerized Nginx Web Server

A local containerized static web server built around Nginx, with a custom site and server configuration. The project demonstrates image construction, container health checks, read-only content mounts, resource limits, log rotation, and basic lifecycle operations.

> **Project status:** Local learning project. No public deployment or uptime claim is made.

## Repository structure

```text
site/                  Static pages and assets
nginx/default.conf     Nginx server configuration
scripts/manage.sh      Lifecycle helper
Dockerfile             Container image definition
docker-compose.yml     Local service and runtime settings
.github/workflows/ci.yml
```

## Run with Docker Compose

Requirements: Docker Engine and the Compose plugin.

```bash
docker compose config
docker compose up -d --build
docker compose ps
```

Open `http://localhost:8080`.

Stop and remove the service:

```bash
docker compose down
```

## Build and run without Compose

```bash
docker build -t docker-webserver-demo .
docker run --rm -p 8080:80 docker-webserver-demo
```

## Lifecycle helper

The helper supports `build`, `start`, `stop`, `restart`, `status`, `logs`, `health`, `clean`, and `help`:

```bash
./scripts/manage.sh help
./scripts/manage.sh health
```

Review scripts before running them in an unfamiliar environment.

## Design points

- Nginx serves static content rather than a development HTTP server.
- The image and Compose service define a health check against `/health.html`.
- Compose configuration sets CPU/memory and log-size bounds for the local service.
- Static content is mounted read-only into the running container.

## Automated validation

GitHub Actions runs on pushes and pull requests to `main`. The workflow:

1. validates the Compose configuration;
2. builds the Nginx image;
3. starts the service;
4. checks that `/health.html` returns `ok` and the homepage contains its expected heading; and
5. stops the service, including on failure.

This is a container smoke test, not a vulnerability scan or production deployment test. The workflow does not currently run Nginx configuration linting or image scanning.

## Security and operations

This is not a hardened production web tier. Before exposing it publicly:

- use a maintained, preferably digest-pinned base image and scan it regularly;
- review Nginx headers and TLS termination;
- evaluate running the container as a non-root user;
- keep host ports restricted; and
- validate resource, logging, and health-check settings for the target environment.

## Next steps

- Add Nginx configuration linting and container vulnerability scanning.
- Add a second service to exercise Compose networking.
- Document a deployment and rollback procedure only if one is actually implemented and tested.

## License

No license file is currently included. Do not assume reuse or redistribution rights until a license is explicitly added.
