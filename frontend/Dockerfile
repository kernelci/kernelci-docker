FROM bitnami/minideb:jessie

### Install dependencies

RUN install_packages build-essential git python python-pip python-dev uwsgi-plugin-python

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
