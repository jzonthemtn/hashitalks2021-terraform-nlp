FROM nvidia/cuda:11.1-devel-ubi8

RUN yum upgrade -y \
	&& yum install -y python38 \
	&& yum install -y python38-devel

RUN python3.8 -m pip install wheel flair==0.7 awscli
RUN python3.8 -m pip install nltk textblob cherrypy awscli boto3
RUN python3.8 -c "import nltk; nltk.download('punkt')"
RUN python3.8 -m pip freeze
RUN python3.8 --version

ADD serve.py /tmp/serve.py

ENV MODEL_BUCKET=""
ENV MODEL_KEY=""

EXPOSE 8080

CMD python3.8 /tmp/serve.py
