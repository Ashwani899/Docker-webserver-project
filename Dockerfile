# Alpine variant - much smaller image, matters once you're pulling this
# repeatedly during dev/test cycles
FROM nginx:1.27-alpine

# Swap out the default config for mine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Ship the static site
COPY site/ /usr/share/nginx/html/

# curl is needed for the HEALTHCHECK below - not in the base alpine image by default
RUN apk add --no-cache curl

# Docker-native health check - this is what shows up as "healthy"/"unhealthy"
# in `docker ps` and is what docker-compose's `depends_on: condition: service_healthy` reads
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health.html || exit 1

EXPOSE 80

# nginx image already has a proper CMD/ENTRYPOINT (nginx -g "daemon off;")
# left as-is intentionally instead of overriding it
