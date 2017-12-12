FROM bitnami/minideb:jessie

### Install dependencies

RUN install_packages build-essential git python python-pip python-dev uwsgi-plugin-python curl redis-tools

### Setup application

WORKDIR /srv
COPY kernelci-frontend /srv/kernelci-frontend
RUN pip install -r kernelci-frontend/requirements.txt
WORKDIR /srv/kernelci-frontend/app
RUN touch /etc/flask_settings
COPY flask_settings /etc/linaro/kernelci-frontend.cfg

### uWSGI configuration

EXPOSE 5000
COPY uwsgi.ini /srv/uwsgi.ini
COPY entrypoint.sh /srv/entrypoint.sh
CMD ["/srv/entrypoint.sh"]
