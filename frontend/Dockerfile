FROM bitnami/minideb:jessie

### Install dependencies

RUN apt-get update && \
    apt-get install -y build-essential python python-pip python2.7-dev uwsgi-plugin-python git-core

### Setup application

WORKDIR /srv
RUN git clone https://github.com/kernelci/kernelci-frontend.git
RUN pip install -r kernelci-frontend/requirements.txt
WORKDIR /srv/kernelci-frontend/app
RUN touch /etc/flask_settings
COPY flask_settings /etc/linaro/kernelci-frontend.cfg

### uWSGI configuration

EXPOSE 5000
COPY uwsgi.ini /srv/uwsgi.ini
CMD ["uwsgi", "--ini", "/srv/uwsgi.ini"]
