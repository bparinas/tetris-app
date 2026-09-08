# ── Tetris – nginx:alpine, non-root safe ────────────────────────────────────
FROM nginx:alpine

LABEL maintainer="tetris-js"
LABEL description="Tetris game – pure HTML/JS served by nginx"

RUN set -eux; \
    # Remove default content
    rm -rf /usr/share/nginx/html/*; \
    # Drop the global 'user nginx;' directive – irrelevant when already running
    # as the nginx user and it triggers a warning when the master isn't root
    sed -i '/^user /d' /etc/nginx/nginx.conf; \
    # Pre-create all temp/cache dirs nginx needs at runtime
    mkdir -p \
      /var/cache/nginx/client_temp \
      /var/cache/nginx/proxy_temp \
      /var/cache/nginx/fastcgi_temp \
      /var/cache/nginx/uwsgi_temp \
      /var/cache/nginx/scgi_temp; \
    # Hand ownership of everything nginx touches to the nginx user
    chown -R nginx:nginx \
      /var/cache/nginx \
      /var/log/nginx \
      /usr/share/nginx/html; \
    # PID file must be writable by nginx user
    touch /var/run/nginx.pid; \
    chown nginx:nginx /var/run/nginx.pid

# Copy game + config
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Run as non-root
USER nginx

CMD ["nginx", "-g", "daemon off;"]
