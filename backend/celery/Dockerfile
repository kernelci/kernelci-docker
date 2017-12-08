FROM python:2.7.14

RUN mkdir -p /etc/linaro
COPY celery-config.cfg /etc/linaro/kernelci-celery.cfg

RUN groupadd user && useradd --create-home --home-dir /home/user -g user user
RUN mkdir -p /var/www/images/kernel-ci && chown -R user:user /var/www

WORKDIR /home/user
RUN git clone https://github.com/kernelci/kernelci-backend.git

# QUICK FIX: changing configuration of celery so it targets redis instead of localhost
COPY celeryconfig.py /home/user/kernelci-backend/app/taskqueue/celeryconfig.py

RUN pip install -r kernelci-backend/requirements.txt

USER user
WORKDIR /home/user/kernelci-backend/app
CMD ["celery", "worker", "-Ofair", "--autoscale=3,1", "--app=taskqueue", "--broker=redis://redis:6379/0", "-E"]
