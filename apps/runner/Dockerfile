# Daytona Runner - Production Dockerfile (Go multi-stage)
# Build:   docker build -f apps/runner/Dockerfile -t daytona-runner .
# Run:     docker run --add-host=host.docker.internal:host-gateway \
#            -v /var/run/docker.sock:/var/run/docker.sock \
#            -e API_TOKEN=secret_api_token -p 8080:8080 daytona-runner

FROM docker.io/golang:1.23-alpine AS builder
WORKDIR /src
ENV NX_DAEMON=false
RUN apk add --no-cache git bash build-base nodejs npm libx11-dev libxtst-dev pkgconf

# Enable go modules caching
COPY go.work go.work.sum* ./
COPY apps/runner/go.mod apps/runner/go.sum ./apps/runner/
COPY apps/daemon/go.mod apps/daemon/go.sum ./apps/daemon/
COPY libs/computer-use/go.mod libs/computer-use/go.sum ./libs/computer-use/
RUN --mount=type=cache,target=/go/pkg/mod \
    true

# Copy full workspace (needed for nx-go scripts and assets)
COPY . .

# Build daemon assets and binaries referenced by runner embed copy tasks
RUN npm i -g corepack && corepack enable && corepack prepare yarn@4.6.0 --activate && yarn install --immutable
RUN chmod +x hack/computer-use/build-computer-use-amd64.sh
RUN yarn nx run daemon:build-amd64
RUN yarn nx run computer-use:build-amd64

# Build runner
RUN yarn nx run runner:build-amd64

# ---------- Runtime ----------
FROM docker.io/alpine:3.20 AS runtime
WORKDIR /app
RUN apk add --no-cache ca-certificates bash git \
    && addgroup -g 1001 -S app \
    && adduser -S app -u 1001 -G app

# Copy runner binary
COPY --from=builder /src/dist/apps/runner-amd64 /app/runner

# Runner listens on API_PORT (default 8080)
ENV API_PORT=8080
EXPOSE 8080

# Healthcheck hitting runner root
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:${API_PORT}/ || exit 1

USER app
ENTRYPOINT ["/app/runner"]
