FROM debian:jessie
MAINTAINER "Milo Casagrande <milo.casagrande@linaro.org>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get clean && apt-get update -qq && apt-get install -qq -y \
    git \
    python \
    python-pip \
    python-dev \
    python-redis \
    python-tz \
    python-jinja2 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/linaro
COPY kernelci-backend.cfg /etc/linaro/kernelci-backend.cfg

WORKDIR /srv
RUN git clone https://github.com/kernelci/kernelci-backend.git
RUN pip install -r kernelci-backend/requirements.txt

EXPOSE 8888

WORKDIR /srv/kernelci-backend/app
CMD ["python", "-OO", "-R", "server.py"]
