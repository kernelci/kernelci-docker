FROM bitnami/minideb:jessie

RUN install_packages git python python-pip python-dev build-essential 

RUN mkdir -p /etc/linaro
COPY celery-config.cfg /etc/linaro/kernelci-celery.cfg

RUN groupadd user && useradd --create-home --home-dir /home/user -g user user

WORKDIR /home/user
RUN git clone https://github.com/kernelci/kernelci-backend.git

RUN pip install -r kernelci-backend/requirements.txt

USER user
WORKDIR /home/user/kernelci-backend/app
CMD ["celery", "worker", "-Ofair", "--autoscale=3,1", "--app=taskqueue", "--broker=redis://redis:6379/0", "-E"]
