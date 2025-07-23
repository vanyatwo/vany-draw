# ---------- Build ----------
FROM oven/bun:1.1.42 AS build

WORKDIR /app

# Лучше копировать lock-файл, если есть
COPY package.json bun.lock* ./

RUN bun install --frozen-lockfile

COPY . .

# 1) Генерим роуты один раз
RUN bunx tanstack-router generate

# 2) Отключаем автогенерацию на время билда
ENV TANSTACK_DISABLE_GENERATION=1
RUN bun run build

# ---------- Run ----------
FROM oven/bun:1.1.42 AS run

WORKDIR /app

# Копируем только то, что нужно на прод
COPY package.json bun.lock* ./
RUN bun install --production --frozen-lockfile

COPY --from=build /app/dist ./dist
COPY server.ts ./

EXPOSE 3729
CMD ["bun", "run", "server.ts"]
