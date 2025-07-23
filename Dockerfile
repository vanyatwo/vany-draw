# ---------- Build ----------
FROM oven/bun:1.1.42 AS build
WORKDIR /app

# Копируем только package.json (без старого bun.lock)
COPY package.json ./
RUN bun install

COPY . .

# Генерим маршруты и билдим
RUN bunx tanstack-router generate && TANSTACK_DISABLE_GENERATION=1 bun run build

# ---------- Run ----------
FROM oven/bun:1.1.42 AS run
WORKDIR /app

COPY package.json ./
# Прод зависимости без frozen (или вообще не ставим, если server.ts почти ничего не тянет)
RUN bun install --production --no-save

COPY --from=build /app/dist ./dist
COPY server.ts ./

EXPOSE 3729
CMD ["bun", "run", "server.ts"]
