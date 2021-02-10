# The version of the base container must
# match the driver installed on the local system.
# Download the driver from: https://developer.nvidia.com/cuda-downloads

FROM nvidia/cuda:11.1-devel-ubi8

ARG FLAIR_VERSION

LABEL flair="${FLAIR_VERSION}"
LABEL python="3.8"

RUN yum upgrade -y \
	&& yum install -y python38 \
	&& yum install -y python38-devel

# Note: These RUN lines could be combined into a single RUN command to reduce layers
RUN python3.8 -m pip install --upgrade pip
RUN python3.8 -m pip install --upgrade setuptools wheel
RUN python3.8 -m pip install flair==${FLAIR_VERSION}
RUN python3.8 -m pip install awscli boto3
RUN python3.8 -m pip freeze
RUN python3.8 --version

ENV MODEL="ner-model"
ENV EPOCHS="20"
ENV EMBEDDINGS="distilbert-base-cased"
ENV S3_BUCKET="my-models"
ENV MODEL_ID=""
ENV REGION="us-east-1"
ENV TABLE_NAME=""

COPY train.py /tmp/train.py

CMD python3.8 /tmp/train.py --m ${MODEL} --e ${EPOCHS} --v ${EMBEDDINGS} --i ${MODEL_ID} --r ${REGION} --t ${TABLE_NAME} && aws s3 sync /tmp/$MODEL/ s3://${S3_BUCKET}/$MODEL/
