FROM debian:jessie
MAINTAINER "Milo Casagrande <milo.casagrande@linaro.org>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get clean && apt-get update -qq && apt-get install -qq -y \
    git \
    python \
    python-pip \
    python-dev \
    build-essential

RUN mkdir -p /etc/linaro

RUN groupadd user && useradd --create-home --home-dir /home/user -g user user

WORKDIR /home/user
RUN git clone https://github.com/kernelci/kernelci-backend.git

RUN pip install -r kernelci-backend/requirements.txt

RUN apt-get purge -y python-dev build-essential && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

USER user
WORKDIR /home/user/kernelci-backend/app
CMD ["celery", "worker", "-Ofair", "--autoscale=3,1", "--app=taskqueue", "-E"]
