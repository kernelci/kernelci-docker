FROM bitnami/minideb:jessie

### Install dependencies
RUN install_packages git python python-pip python-dev build-essential
RUN pip install python-dateutil

### Install mongo shell
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    && apt-get update -y \
    && apt-get install -y mongodb-org-shell

### Configuration
RUN mkdir -p /etc/linaro
COPY kernelci-backend.cfg /etc/linaro/kernelci-backend.cfg

### Get source code
WORKDIR /srv
RUN git clone https://github.com/kernelci/kernelci-backend.git
RUN pip install -r kernelci-backend/requirements.txt

EXPOSE 8888

WORKDIR /srv/kernelci-backend/app
COPY entrypoint.sh /srv/kernelci-backend/app/entrypoint.sh
CMD ["/srv/kernelci-backend/app/entrypoint.sh"]
