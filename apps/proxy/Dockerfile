# Daytona Proxy - Production Dockerfile (Go multi-stage)
# Build:   docker build -f apps/proxy/Dockerfile -t daytona-proxy .
# Run:     docker run -e PROXY_PORT=4000 -p 4000:4000 daytona-proxy

FROM docker.io/golang:1.23-alpine AS builder
WORKDIR /src
RUN apk add --no-cache git build-base

COPY go.work go.work.sum* ./
COPY apps/proxy/go.mod apps/proxy/go.sum ./apps/proxy/
RUN --mount=type=cache,target=/go/pkg/mod true

COPY . .
RUN corepack enable && yarn install --immutable
RUN yarn nx run proxy:build

FROM docker.io/alpine:3.20 AS runtime
WORKDIR /app
RUN apk add --no-cache ca-certificates \
    && addgroup -g 1001 -S app \
    && adduser -S app -u 1001 -G app

COPY --from=builder /src/dist/apps/proxy/proxy /app/proxy

ENV PROXY_PORT=4000
EXPOSE 4000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:${PROXY_PORT}/ || exit 1

USER app
ENTRYPOINT ["/app/proxy"]
