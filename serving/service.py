#!/usr/bin/python3

from flair.models import SequenceTagger
from flair.data import Sentence
import cherrypy
import json
from textblob import TextBlob


class Span:
    def __init__(self, text, tag, score, start, end):
        self.text = text
        self.tag = tag
        self.score = score
        self.start = start
        self.end = end


def obj_dict(obj):
    return obj.__dict__

# Download the model from S3.
model = SequenceTagger.load('final-model.pt')

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


if __name__ == '__main__':
    cherrypy.config.update({'server.socket_host': '0.0.0.0', 'server.socket_port': 18080})
    cherrypy.quickstart(NerModelService())
