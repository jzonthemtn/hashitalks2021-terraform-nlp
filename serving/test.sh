#!/bin/bash
HOSTNAME=${1:-localhost}
curl -vvvv -X POST http://$HOSTNAME:8080/ner --data "George Washington was president of the United States." -H "Content-type: text/plain"
