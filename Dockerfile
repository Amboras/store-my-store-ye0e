# syntax=docker/dockerfile:1

# ============================================
# Stage 1: Base - Install Dependencies
# ============================================
FROM node:20-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    bash \
    tini

WORKDIR /app

# Copy package files
COPY backend/package*.json ./backend/
COPY storefront/package*.json ./storefront/
COPY package*.json ./

# Install dependencies (this happens ONCE in CI, not per user!)
RUN cd backend && npm ci --omit=dev && npm cache clean --force
RUN cd storefront && npm ci --omit=dev && npm cache clean --force

# ============================================
# Stage 2: Builder - Build Applications
# ============================================
FROM base AS builder

# Install dev dependencies for building
COPY backend/package*.json ./backend/
COPY storefront/package*.json ./storefront/

RUN cd backend && npm ci && npm cache clean --force
RUN cd storefront && npm ci && npm cache clean --force

# Copy source code
COPY backend ./backend
COPY storefront ./storefront

# Build backend
RUN cd backend && npm run build

# Build storefront (pre-generate .next cache for instant first load)
RUN cd storefront && npm run build

# ============================================
# Stage 3: Production - Final Image
# ============================================
FROM node:20-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    git \
    curl \
    bash \
    tini

WORKDIR /app

# Copy installed node_modules from base stage
COPY --from=base /app/backend/node_modules ./backend/node_modules
COPY --from=base /app/storefront/node_modules ./storefront/node_modules

# Copy source code
COPY backend ./backend
COPY storefront ./storefront

# Copy built artifacts from builder stage
COPY --from=builder /app/backend/dist ./backend/dist
COPY --from=builder /app/storefront/.next ./storefront/.next

# Copy startup script
COPY docker/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Create workspace directory (mounted as volume)
RUN mkdir -p /workspace && chmod 777 /workspace

# Expose ports
EXPOSE 9000 3000

# Health check
HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:9000/health || curl -f http://localhost:9000 || exit 1

# Use tini as init system (proper signal handling)
ENTRYPOINT ["/sbin/tini", "--"]

# Run startup script
CMD ["/app/start.sh"]
