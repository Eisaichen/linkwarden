FROM node:18.18-bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/node/.cargo/bin:${PATH}"
COPY . /data

RUN apt update && \
    apt install -y build-essential curl libssl-dev pkg-config && \
    chown 1000:1000 /data -R && \
    npx playwright install-deps && \
    apt clean

WORKDIR /data
USER node

# Increase timeout to pass github actions arm64 build
RUN --mount=type=cache,sharing=locked,target=/usr/local/share/.cache/yarn curl https://sh.rustup.rs -sSf | bash -s -- -y && \
    cargo install monolith && \
    yarn install --network-timeout 10000000 && \
    yarn playwright install && \
    yarn cache clean

RUN yarn prisma generate && \
    yarn build

CMD yarn prisma migrate deploy && yarn start
