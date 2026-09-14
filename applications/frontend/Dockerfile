# syntax=docker/dockerfile:1

# --- Build do bundle React com Vite ---
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install --no-audit --no-fund
COPY . .
RUN npm run build

# --- Runtime: nginx servindo os estáticos ---
FROM nginx:1.27-alpine AS runtime

# Config custom (SPA fallback, /metrics, /healthz, temp dirs graváveis).
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.d/99-config.sh

# Permite que o usuário não-root (nginx) escreva o config.js gerado em runtime.
RUN chmod +x /docker-entrypoint.d/99-config.sh \
    && chown -R nginx:nginx /usr/share/nginx/html \
    && touch /usr/share/nginx/html/config.js \
    && chown nginx:nginx /usr/share/nginx/html/config.js

USER nginx
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:80/healthz >/dev/null 2>&1 || exit 1
