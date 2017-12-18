FROM bitnami/minideb:jessie

# Install dependencies
RUN install_packages git python python-pip python-dev build-essential wget
RUN pip install python-dateutil

# Install Node.js / nodemon
RUN wget --no-check-certificate -nc -P /tmp/bitnami/pkg/cache/ https://downloads.bitnami.com/files/stacksmith/node-8.9.3-0-linux-x64-debian-8.tar.gz && \
    tar -zxf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz -P --transform 's|^.*/files|/opt/bitnami|' --wildcards '*/files' && \
    rm -rf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz
ENV PATH="/opt/bitnami/node/bin:$PATH"
RUN npm install -g nodemon

# Install mongo shell
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    && apt-get update -y \
    && apt-get install -y mongodb-org-shell

# Configuration
RUN mkdir -p /etc/linaro
COPY app/kernelci-backend.cfg /etc/linaro/kernelci-backend.cfg

# Get source code
COPY kernelci-backend /srv/kernelci-backend

# Install python dependencies
RUN pip install -r /srv/kernelci-backend/requirements.txt

EXPOSE 8888

COPY app/entrypoint.sh /srv/entrypoint.sh
CMD ["/srv/entrypoint.sh"]
