# ── Tetris – OpenShift / arbitrary-UID compatible ───────────────────────────
FROM nginx:1.31.5-alpine

LABEL maintainer="tetris-js"
LABEL description="Tetris game – nginx, runs as any UID (OpenShift SCC safe)"

RUN set -eux; \
    rm -rf /usr/share/nginx/html/*; \
    \
    # ── nginx.conf tweaks ──────────────────────────────────────────────────
    # 1. Remove 'user nginx;' – meaningless / warns when not running as root
    sed -i '/^user /d' /etc/nginx/nginx.conf; \
    # 2. Move PID to /tmp – writable by any UID without special permissions
    sed -i 's|pid\s*/run/nginx.pid;|pid /tmp/nginx.pid;|' /etc/nginx/nginx.conf; \
    \
    # ── Temp dirs in /tmp ─────────────────────────────────────────────────
    # OpenShift mounts /tmp as world-writable; /var/cache/nginx may not be
    mkdir -p \
      /tmp/nginx/client_temp \
      /tmp/nginx/proxy_temp \
      /tmp/nginx/fastcgi_temp \
      /tmp/nginx/uwsgi_temp \
      /tmp/nginx/scgi_temp; \
    \
    # ── GID-0 ownership + group-write ─────────────────────────────────────
    # OpenShift always assigns GID 0 (root group) to the arbitrary runtime UID.
    # Granting g+rwX to GID 0 makes every file accessible regardless of UID.
    chown -R 0:0 \
      /var/cache/nginx \
      /var/log/nginx \
      /usr/share/nginx/html \
      /etc/nginx; \
    chmod -R g+rwX \
      /var/cache/nginx \
      /var/log/nginx \
      /usr/share/nginx/html \
      /etc/nginx

COPY --chown=0:0 index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# Declare a non-root UID; OpenShift overrides this with its own arbitrary UID,
# but this makes the intent explicit and satisfies most image scanners.
USER 1001

CMD ["nginx", "-g", "daemon off;"]
