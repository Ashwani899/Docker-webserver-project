#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
Usage: ./scripts/manage.sh <command>

Commands:
  build    Build the Docker image and Compose service
  start    Start the web server in the background
  stop     Stop the Compose service
  restart  Restart the Compose service
  status   Show Compose service status
  logs     Follow recent web server logs
  health   Check the local health endpoint
  clean    Stop and remove the Compose service
  help     Show this help
EOF
}

command=${1:-help}
case "$command" in
  build)   docker compose build ;;
  start)   docker compose up -d ;;
  stop)    docker compose stop ;;
  restart) docker compose restart ;;
  status)  docker compose ps ;;
  logs)    docker compose logs -f --tail 50 web ;;
  health)  curl --fail --silent --show-error http://127.0.0.1:8080/health.html ;;
  clean)   docker compose down ;;
  help|-h|--help) usage ;;
  *) echo "Unknown command: $command" >&2; usage >&2; exit 2 ;;
esac
