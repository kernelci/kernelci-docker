FROM bitnami/minideb:buster

# Install dependencies
RUN install_packages git python python-pip python-setuptools python-dev build-essential wget gnupg2 python-wheel
RUN pip install python-dateutil

# Install Node.js / nodemon
RUN wget --no-check-certificate -nc -P /tmp/bitnami/pkg/cache/ https://downloads.bitnami.com/files/stacksmith/node-8.9.3-0-linux-x64-debian-8.tar.gz && \
    tar -zxf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz -P --transform 's|^.*/files|/opt/bitnami|' --wildcards '*/files' && \
    rm -rf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz
ENV PATH="/opt/bitnami/node/bin:$PATH"
RUN npm install -g nodemon

# Install mongo shell
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - \
    && echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list \
    && apt-get update -y \
    && apt-get install -y mongodb-org-shell

# Configuration
RUN mkdir -p /etc/kernelci
COPY app/kernelci-backend.cfg /etc/kernelci/kernelci-backend.cfg

# Get source code
COPY kernelci-backend /srv/kernelci-backend

# Install python dependencies
RUN install_packages libyaml-dev  # needed for yaml.CLoader
RUN pip install -r /srv/kernelci-backend/requirements.txt

EXPOSE 8888

COPY app/entrypoint.sh /srv/entrypoint.sh
CMD ["/srv/entrypoint.sh"]
