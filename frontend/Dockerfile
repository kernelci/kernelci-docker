FROM bitnami/minideb:buster

# Install dependencies

RUN install_packages build-essential git python python-pip python-setuptools python-dev uwsgi-plugin-python curl redis-tools wget

# Install Node.js / nodemon
RUN wget --no-check-certificate -nc -P /tmp/bitnami/pkg/cache/ https://downloads.bitnami.com/files/stacksmith/node-8.9.3-0-linux-x64-debian-8.tar.gz && \
    tar -zxf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz -P --transform 's|^.*/files|/opt/bitnami|' --wildcards '*/files' && \
    rm -rf /tmp/bitnami/pkg/cache/node-8.9.3-0-linux-x64-debian-8.tar.gz
ENV PATH="/opt/bitnami/node/bin:$PATH"
RUN npm install -g nodemon

# Setup application

WORKDIR /srv
COPY kernelci-frontend /srv/kernelci-frontend
RUN pip install -r kernelci-frontend/requirements.txt
WORKDIR /srv/kernelci-frontend/app
RUN touch /etc/flask_settings
COPY flask_settings /etc/kernelci/kernelci-frontend.cfg

# uWSGI configuration

EXPOSE 5000
COPY uwsgi.ini /srv/uwsgi.ini
COPY entrypoint.sh /srv/entrypoint.sh
CMD ["/srv/entrypoint.sh"]
