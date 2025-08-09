FROM docker:28.2.2-dind-alpine3.22 AS daytona

# Install nodejs
RUN apk --update add --no-cache nodejs=22.16.0-r2 npm bash
RUN npm install -g corepack && corepack enable

COPY --from=golang:1.23.5-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /daytona

COPY . .

# Docs build arguments
ENV PUBLIC_WEB_URL=https://daytona.io
ARG PUBLIC_ALGOLIA_APP_ID
ENV PUBLIC_ALGOLIA_APP_ID=${PUBLIC_ALGOLIA_APP_ID}
ARG PUBLIC_ALGOLIA_API_KEY
ENV PUBLIC_ALGOLIA_API_KEY=${PUBLIC_ALGOLIA_API_KEY}

ARG VERSION=0.0.1
ENV VERSION=${VERSION}

RUN yarn && \
  SKIP_COMPUTER_USE_BUILD=true yarn build:production-skip-computer-use --nxBail=true

RUN mkdir -p /etc/docker && echo '{"iptables": true, "ip-forward": true, "ip-masq": true, "userland-proxy": false, "insecure-registries": ["localhost:6000"]}' > /etc/docker/daemon.json

ENTRYPOINT ["sh", "-c", "dockerd-entrypoint.sh & node dist/apps/api/main.js"]

FROM alpine:3.18 AS proxy

WORKDIR /usr/local/bin

COPY --from=daytona /daytona/dist/apps/proxy daytona-proxy

RUN chmod +x daytona-proxy

ENTRYPOINT ["daytona-proxy"]

FROM docker:28.2.2-dind-alpine3.22 AS runner

WORKDIR /usr/local/bin

COPY --from=daytona /daytona/dist/apps/runner daytona-runner

RUN chmod +x daytona-runner

RUN mkdir -p /etc/docker && echo '{"iptables": true, "ip-forward": true, "ip-masq": true, "userland-proxy": false, "insecure-registries": ["localhost:6000"]}' > /etc/docker/daemon.json

ENTRYPOINT ["sh", "-c", "dockerd & daytona-runner"]

FROM node:22-alpine AS docs

WORKDIR /daytona

COPY --from=daytona /daytona/node_modules node_modules
COPY --from=daytona /daytona/dist/apps/docs dist/apps/docs
COPY --from=daytona /daytona/apps/docs/server dist/apps/docs/server

WORKDIR /daytona/dist/apps/docs

ENTRYPOINT ["sh", "-c", "node server/index.mjs"]