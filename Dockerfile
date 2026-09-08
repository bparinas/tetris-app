# ── Stage 1: No build needed (pure HTML/JS) ─────────────────────────────────
# Using nginx:alpine for a minimal, production-ready image (~25 MB)
FROM nginx:alpine

LABEL maintainer="tetris-js"
LABEL description="Tetris game – pure HTML/JS served by nginx"

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy game files
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# nginx starts in foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
