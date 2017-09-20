FROM nginx:1.13

# Install deps
RUN apt-get update && apt-get install -y rsync nodejs git-core

# Remove default configuration
RUN rm /etc/nginx/conf.d/default.conf

# Main configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Frontend configuration
COPY frontend/server.conf /etc/nginx/conf.d/frontend.conf

# Backend configuration
COPY backend/server.conf      /etc/nginx/conf.d/backend.conf
COPY backend/proxy.conf       /etc/nginx/custom/backend-proxy.conf
COPY backend/maintenance.conf /etc/nginx/custom/backend-maintenance.conf

# Copy frontend's static assets
RUN mkdir -p /usr/share/nginx/html/kernelci/frontend \
    && chown nginx:nginx /usr/share/nginx/html/kernelci/frontend
RUN git clone https://github.com/kernelci/kernelci-frontend.git front
RUN nodejs /front/app/dashboard/static/js/lib/r.js -o /front/app/dashboard/static/js/build.js \
    && rsync -a -u /tmp/assets-build/ /usr/share/nginx/html/kernelci/frontend/static
