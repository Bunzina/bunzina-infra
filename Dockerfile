FROM oven/bun:1.2 AS base

WORKDIR /app
ENV NODE_ENV=production

FROM base AS deps

COPY bun.lock package.json bunfig.toml tsconfig.json ./
RUN bun install --frozen-lockfile --production

FROM base AS runner

RUN addgroup --system bunzina \
	&& adduser --system --ingroup bunzina bunzina

COPY --from=deps /app/node_modules ./node_modules
COPY --chown=bunzina:bunzina package.json bunfig.toml tsconfig.json ./
COPY --chown=bunzina:bunzina src ./src
COPY --chown=bunzina:bunzina migrations ./migrations

USER bunzina

EXPOSE 3000

ENV PORT=3000

CMD ["bun", "run", "start"]
