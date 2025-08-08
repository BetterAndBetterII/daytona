# Daytona API - Production Dockerfile (multi-stage)
# Build:   docker build -f apps/api/Dockerfile -t daytona-api .
# Run:     docker run --env-file .env -p 3000:3000 daytona-api

# ---------- Builder: install deps and build dist ----------
FROM docker.io/node:lts-alpine AS builder
WORKDIR /workspace

# System deps (for node-gyp if needed during build)
RUN apk add --no-cache git python3 make g++ libc6-compat go

# Copy repo (prefer full copy to keep Nx context; can be optimized later)
COPY . .

# Enable corepack and install workspace dependencies
RUN corepack enable \
 && yarn install --immutable

# Build only the API in production mode
RUN yarn nx run api:build:production

# ---------- Deps: install runtime deps for dist package.json ----------
FROM docker.io/node:lts-alpine AS deps
WORKDIR /app
RUN apk add --no-cache python3 make g++ libc6-compat

# Use the generated package.json from the built output to install only runtime deps
COPY --from=builder /workspace/dist/apps/api/package.json ./package.json
RUN npm install --omit=dev --no-audit --no-fund

# ---------- Runtime: minimal image ----------
FROM docker.io/node:lts-alpine AS runtime
ENV NODE_ENV=production \
    PORT=3000

WORKDIR /app

# Add minimal tools for proper PID 1 handling and healthcheck
# node:lts-alpine 基镜像已自带非 root 的 `node` 用户，无需重复创建
RUN apk add --no-cache tini curl libc6-compat

# Copy node_modules and build output
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /workspace/dist/apps/api ./

# Ensure the expected static folder exists (dashboard assets may be mounted/copied later)
RUN mkdir -p ./dashboard \
 && chown -R node:node /app

USER node
EXPOSE 3000

# Basic healthcheck: Swagger UI is mounted at /api
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:${PORT}/api || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "main.js"]