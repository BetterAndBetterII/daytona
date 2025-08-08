# Daytona Daemon - Production Dockerfile (Go multi-stage)
# Build:   docker build -f apps/daemon/Dockerfile -t daytona-daemon .
# Run:     docker run -p 22222:22222 daytona-daemon

FROM docker.io/golang:1.23-alpine AS builder
WORKDIR /src
RUN apk add --no-cache git build-base nodejs npm

COPY go.work go.work.sum* ./
COPY apps/daemon/go.mod apps/daemon/go.sum ./apps/daemon/
RUN --mount=type=cache,target=/go/pkg/mod true

COPY . .
RUN npm i -g corepack && corepack enable && corepack prepare yarn@4.6.0 --activate && yarn install --immutable
RUN yarn nx run daemon:prepare
RUN yarn nx run daemon:build-amd64

FROM docker.io/alpine:3.20 AS runtime
WORKDIR /app
RUN apk add --no-cache ca-certificates git openssh-client \
    && addgroup -g 1001 -S app \
    && adduser -S app -u 1001 -G app

COPY --from=builder /src/dist/apps/daemon-amd64/daemon /app/daemon

EXPOSE 22222
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:22222/ >/dev/null 2>&1 || exit 1

USER app
ENTRYPOINT ["/app/daemon"]
