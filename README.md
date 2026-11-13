# Dockerized Nginx Web Server

A containerized static web server built around Nginx, with a custom site and server configuration. The project explores Docker image construction, container health checks, read-only content mounts, resource limits, log rotation, and basic lifecycle operations.

## Repository structure

```text
site/                  Static pages and assets
nginx/default.conf     Nginx server configuration
Dockerfile             Container image definition
docker-compose.yml     Local service and runtime settings
scripts/manage.sh      Lifecycle helper
```

## Run with Docker Compose

Requirements: Docker Engine and the Compose plugin.

```bash
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

## Useful diagnostics

| Goal | Command |
|---|---|
| Container status | `docker compose ps` |
| Health details | `docker inspect webserver-demo` |
| Recent logs | `docker logs --tail 50 webserver-demo` |
| Live resource usage | `docker stats webserver-demo` |
| Shell | `docker exec -it webserver-demo sh` |
| Stop service | `docker compose down` |

If the helper script is executable, `./scripts/manage.sh help` lists its supported operations. Review the script before running it in an unfamiliar environment.

## Design points

- Nginx serves static content rather than a development HTTP server.
- The container includes a health check against a dedicated health resource.
- Compose configuration sets resource and log bounds for the local service.
- Static content can be mounted read-only to reduce unnecessary write access.

## Security and operations

This is a local learning example, not a hardened production web tier. Before exposing it publicly, review Nginx headers and TLS termination, pin and scan the base image, run as a non-root user where supported, keep host ports restricted, and validate the health check and resource settings for the target environment.

## Validation

The repository includes Docker configuration and a helper script. Verify `docker compose config`, image build, health transition, and browser response on the machine where you run it. No external deployment or uptime is claimed.

## Next steps

- Add automated configuration linting and container scanning.
- Add an integration smoke test for the HTTP response and health route.
- Add a second service to exercise Compose networking.
