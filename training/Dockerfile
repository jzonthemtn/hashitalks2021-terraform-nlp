# The version of the base container must
# match the driver installed on the local system.
# Download the driver from: https://developer.nvidia.com/cuda-downloads

FROM nvidia/cuda:11.1-devel-ubi8

ARG FLAIR_VERSION

LABEL maintainer="jeff.zemerick@mtnfog.com"
LABEL flair="${FLAIR_VERSION}"
LABEL python="3.8"

ENV MODEL="ner-model"
ENV EPOCHS="20"
ENV EMBEDDINGS="distilbert-base-cased"
ENV S3_BUCKET="my-models"

RUN yum upgrade -y \
	&& yum install -y python38 \
	&& yum install -y python38-devel

RUN python3.8 -m pip install --upgrade pip
RUN python3.8 -m pip install --upgrade setuptools wheel
RUN python3.8 -m pip install flair==${FLAIR_VERSION}
RUN python3.8 -m pip install awscli
RUN python3.8 -m pip freeze
RUN python3.8 --version

ADD train.py /tmp/train.py

CMD python3.8 /tmp/train.py --m ${MODEL} --e ${EPOCHS} --v ${EMBEDDINGS} && aws s3 sync /tmp/$MODEL s3://${S3_BUCKET}/$MODEL/
