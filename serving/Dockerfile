FROM registry.access.redhat.com/ubi8/python-38:1-43

RUN python3 -m pip install wheel flair==0.7
RUN python3 -m pip install nltk textblob cherrypy awscli boto3
RUN python3 -c "import nltk; nltk.download('punkt')"

ADD serve.py /tmp/serve.py

EXPOSE 8080

CMD python3 /tmp/serve.py
