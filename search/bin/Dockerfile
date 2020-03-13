FROM python:3.5-alpine

RUN pip install pyyaml

COPY raw2json.py /bin/

# TODO: create a user with access to /in and /out folder

ENTRYPOINT ["python", "/bin/raw2json.py"]
CMD ["--input", "/in", "--output", "/out"]
