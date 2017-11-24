FROM python:3.5-alpine

RUN pip install pyyaml

RUN mkdir /log
WORKDIR /log

COPY raw2json.py /bin/

ENTRYPOINT ["python", "/bin/raw2json.py"]
