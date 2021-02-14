# The version of the base container must
# match the driver installed on the local system.
# Download the driver from: https://developer.nvidia.com/cuda-downloads

FROM nvidia/cuda:11.1-devel-ubi8

RUN yum upgrade -y \
	&& yum install -y python38 \
	&& yum install -y python38-devel

# Note: These RUN lines could be combined into a single RUN command to reduce layers
RUN python3.8 -m pip install wheel flair==0.7 awscli
RUN python3.8 -m pip install nltk textblob cherrypy awscli boto3
RUN python3.8 -c "import nltk; nltk.download('punkt')"
RUN python3.8 -m pip freeze
RUN python3.8 --version

COPY serve.py /tmp/serve.py

ENV MODEL_BUCKET=""
ENV MODEL_KEY=""

EXPOSE 8080

CMD python3.8 /tmp/serve.py --b ${MODEL_BUCKET} --k ${MODEL_KEY}
