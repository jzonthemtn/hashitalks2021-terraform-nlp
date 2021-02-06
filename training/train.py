import argparse
import os
import sys
import boto3
from typing import List
from pathlib import Path

from flair.data import Corpus
from flair.datasets import WIKINER_ENGLISH
from flair.embeddings import BertEmbeddings, TokenEmbeddings, StackedEmbeddings, TransformerWordEmbeddings
from flair.models import SequenceTagger
from flair.trainers import ModelTrainer

parser = argparse.ArgumentParser(description='Model Training')
parser.add_argument('--m', action="store", dest='model', default="")
parser.add_argument('--e', action="store", dest='epochs', default=20)
parser.add_argument('--v', action="store", dest='embeddings', default="distilbert-base-cased")
parser.add_argument('--i', action="store", dest='model_id', default="")
parser.add_argument('--r', action="store", dest='region', default="us-east-1")
parser.add_argument('--t', action="store", dest='table', default="")

args = parser.parse_args()

corpus: Corpus = WIKINER_ENGLISH().downsample(0.1)

tag_type = 'ner'
tag_dictionary = corpus.make_tag_dictionary(tag_type=tag_type)
embeddings = TransformerWordEmbeddings(model=args.embeddings)

tagger: SequenceTagger = SequenceTagger(hidden_size=256,
                                        embeddings=embeddings,
                                        tag_dictionary=tag_dictionary,
                                        tag_type=tag_type,
                                        use_crf=True)

trainer: ModelTrainer = ModelTrainer(tagger, corpus, use_tensorboard=True)

trainer.train('./' + args.model,
              learning_rate=0.1,
              mini_batch_size=32,
              max_epochs=int(args.epochs),
              num_workers=12,
              checkpoint=True,
              save_final_model=True,
              shuffle=True,
              embeddings_storage_mode='cpu')

dynamodb = boto3.resource('dynamodb', region_name=args.region)
table = dynamodb.Table(args.table)
table.update_item(
    Key={
        'ModelID': args.model_id
    },
    UpdateExpression="set Progress=:s",
    ExpressionAttributeValues={
        ':s': 'Complete'
    },
    ReturnValues="UPDATED_NEW"
)
