FROM bitnami/minideb:jessie

### Install dependencies
RUN install_packages git python python-pip python-dev build-essential
RUN pip install python-dateutil

### Configuration
RUN mkdir -p /etc/linaro
COPY kernelci-backend.cfg /etc/linaro/kernelci-backend.cfg

### Get source code
WORKDIR /srv
RUN git clone https://github.com/kernelci/kernelci-backend.git
RUN pip install -r kernelci-backend/requirements.txt

EXPOSE 8888

WORKDIR /srv/kernelci-backend/app
CMD ["python", "-OO", "-R", "server.py"]
