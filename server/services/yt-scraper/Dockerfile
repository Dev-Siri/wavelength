FROM oven/bun:1 AS base

WORKDIR /usr/src/app

FROM base AS install

RUN mkdir -p /temp/dev

COPY services/yt-scraper/package.json services/yt-scraper/bun.lock /temp/dev/

RUN cd /temp/dev && bun install --frozen-lockfile --no-progress

RUN mkdir -p /temp/prod

COPY services/yt-scraper/package.json services/yt-scraper/bun.lock /temp/prod/

RUN cd /temp/prod && bun install --frozen-lockfile --production --no-progress

RUN rm -rf /temp/prod/node_modules/**/test /temp/prod/node_modules/**/tests /temp/prod/node_modules/**/*.md /temp/prod/node_modules/**/*.map

FROM base AS prerelease

COPY --from=install /temp/dev/node_modules node_modules

COPY . .

ENV NODE_ENV=production

WORKDIR /usr/src/app/services/yt-scraper

RUN bun run build

FROM gcr.io/distroless/nodejs20-debian12

WORKDIR /usr/src/app

COPY --from=install /temp/prod/node_modules node_modules

COPY --from=prerelease /usr/src/app/services/yt-scraper/dist dist
COPY --from=prerelease /usr/src/app/services/yt-scraper/package.json .

EXPOSE 8080

ENV NODE_ENV=production

CMD ["dist/main.js"]
