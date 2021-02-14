#!/bin/bash
HOSTNAME=${1:-localhost:8080}
curl -vvvv -X POST http://$HOSTNAME/ner --data "George Washington was president of the United States." -H "Content-type: text/plain"
