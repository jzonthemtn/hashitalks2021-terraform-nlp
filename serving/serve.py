#!/usr/bin/python3

import argparse
from flair.models import SequenceTagger
from flair.data import Sentence
import cherrypy
import json
import boto3
from textblob import TextBlob
import os


class Span:
    def __init__(self, text, tag, score, start, end):
        self.text = text
        self.tag = tag
        self.score = score
        self.start = start
        self.end = end


def obj_dict(obj):
    return obj.__dict__


parser = argparse.ArgumentParser(description='Model Serving')
parser.add_argument('--b', action="store", dest='bucket', default="")
parser.add_argument('--k', action="store", dest='key', default=20)
args = parser.parse_args()

# Download the model.
#s3 = boto3.resource('s3')
#s3.Bucket(args.bucket).download_file(args.key, '/tmp/final-model.pt')

print("Downloading model s3://" + args.bucket + "/" + args.key)
s3 = boto3.client('s3')
s3.download_file(args.bucket, args.key + '/final-model.pt', '/tmp/final-model.pt')
print("Model downloaded.")

model = SequenceTagger.load('/tmp/final-model.pt')

class NerModelService(object):

    @cherrypy.expose
    def ner(self):

        input = cherrypy.request.body.read().decode('utf-8')

        sentences = []

        blob = TextBlob(input)
        for s in blob.sentences:
            sentences.append(Sentence(s.raw))

        model.predict(sentences)

        spans = []
        index = 0

        for i in sentences:

            start_pos = blob.sentences[index].start_index

            for entity in i.get_spans('ner'):
                p1 = Span(entity.text, entity.tag, entity.score, (entity.start_pos + start_pos),
                          (entity.end_pos + start_pos))
                spans.append(p1)

            index = index + 1

        s = json.dumps(spans, default=obj_dict)

        return s

    @cherrypy.expose
    def health(self):
        return "healthy"


if __name__ == '__main__':
    cherrypy.config.update({'server.socket_host': '0.0.0.0', 'server.socket_port': 8080})
    cherrypy.quickstart(NerModelService())
