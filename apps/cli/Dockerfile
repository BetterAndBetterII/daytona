# Daytona CLI - Production Dockerfile (Go multi-stage)
# Build:   docker build -f apps/cli/Dockerfile -t daytona-cli .
# Run:     docker run --rm daytona-cli --help

FROM docker.io/golang:1.23-alpine AS builder
WORKDIR /src
RUN apk add --no-cache git build-base nodejs npm

COPY go.work go.work.sum* ./
COPY apps/cli/go.mod apps/cli/go.sum ./apps/cli/
RUN --mount=type=cache,target=/go/pkg/mod true

COPY . .
RUN corepack enable && yarn install --immutable
RUN yarn nx run cli:build

FROM docker.io/alpine:3.20 AS runtime
WORKDIR /app
RUN apk add --no-cache ca-certificates \
    && addgroup -g 1001 -S app \
    && adduser -S app -u 1001 -G app

COPY --from=builder /src/dist/apps/cli/cli /usr/local/bin/daytona

USER app
ENTRYPOINT ["/usr/local/bin/daytona"]
CMD ["--help"]
