# Daytona Dashboard - Production Dockerfile (multi-stage: build with Vite, serve via Nginx)
# Build:   docker build -f apps/dashboard/Dockerfile -t daytona-dashboard \
#            --build-arg VITE_API_URL=http://localhost:3001 .
# Run:     docker run -e NGINX_PORT=8080 -p 8080:8080 daytona-dashboard

# ---------- Builder ----------
FROM docker.io/node:lts-alpine AS builder
WORKDIR /workspace
RUN apk add --no-cache git libc6-compat
COPY . .
RUN corepack enable && yarn install --immutable

# Inject API base URL for Vite at build time
ARG VITE_API_URL=http://localhost:3001
ENV VITE_API_URL=${VITE_API_URL}

# Build only dashboard
RUN yarn nx run dashboard:build

# ---------- Runtime ----------
FROM docker.io/nginx:alpine AS runtime

ENV NGINX_PORT=8080

# Simple nginx config with SPA fallback
RUN printf '\
server {\n\
  listen       ${NGINX_PORT};\n\
  listen       [::]:${NGINX_PORT};\n\
  server_name  _;\n\
  root   /usr/share/nginx/html;\n\
  index  index.html;\n\
  location / {\n\
    try_files $uri /index.html;\n\
  }\n\
  # Pass through API calls if dashboard and api colocated behind same container
  # location /api {\n\
  #   proxy_pass http://api:3000;\n\
  # }\n\
}\n' > /etc/nginx/conf.d/default.conf

COPY --from=builder /workspace/dist/apps/dashboard /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD wget -qO- http://localhost:${NGINX_PORT}/ >/dev/null 2>&1 || exit 1

CMD ["/docker-entrypoint.sh", "nginx", "-g", "daemon off;"]

