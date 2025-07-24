# LZ Custom Subdomain Application
# Dockerized Vue.js app for subdomains: lzcustom.lodexinc.com, lzcustom.giorgiy.org, lzcustom.bravoohio.org

# Multi-stage build for Vue.js
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the application with environment-specific configuration
ARG PARENT_DOMAIN
ARG SUBDOMAIN
ARG API_BASE_URL
ARG DOMAIN_BRAND

ENV VITE_PARENT_DOMAIN=$PARENT_DOMAIN
ENV VITE_SUBDOMAIN=$SUBDOMAIN
ENV VITE_API_BASE_URL=$API_BASE_URL
ENV VITE_DOMAIN_BRAND=$DOMAIN_BRAND

RUN npm run build

# Production stage with nginx
FROM nginx:alpine AS production

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# Set permissions
RUN chown -R nextjs:nodejs /usr/share/nginx/html && \
    chown -R nextjs:nodejs /var/cache/nginx && \
    chown -R nextjs:nodejs /var/log/nginx && \
    chown -R nextjs:nodejs /etc/nginx/conf.d

# Switch to non-root user
USER nextjs

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]