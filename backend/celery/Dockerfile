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
COPY celery-config.cfg /etc/linaro/kernelci-celery.cfg

RUN groupadd user && useradd --create-home --home-dir /home/user -g user user

WORKDIR /home/user
RUN git clone https://github.com/kernelci/kernelci-backend.git

RUN pip install -r kernelci-backend/requirements.txt

USER user
WORKDIR /home/user/kernelci-backend/app
CMD ["celery", "worker", "-Ofair", "--autoscale=3,1", "--app=taskqueue", "-E"]
