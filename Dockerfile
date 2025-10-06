# Stage 1: Builder
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY *.js ./

# Install dependencies
RUN npm ci

# Copy app and build
COPY . .
RUN npm run build

# Stage 2: Production  
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001

# Copy only production essentials
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
COPY --from=builder --chown=appuser:appgroup /app/.next ./.next
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules

# Copy necessary config files
COPY --from=builder --chown=appuser:appgroup /app/next.config.js ./

USER appuser

EXPOSE 3000

CMD ["npm", "start"]