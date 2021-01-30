import json
import requests

from json_checker import Checker


def lambda_handler(event, context):
    current_data = {'first_key': 1, 'second_key': '2'}
    expected_schema = {'first_key': int, 'second_key': str}
    checker = Checker(expected_schema)

    s3_events = []
    for record in event['Records']:
        s3_events.append({
            "bucket": record['s3']['bucket']['name'],
            "file": record['s3']['object']['key']
        })

    data = {
        "result": checker.validate(current_data),
        "s3_events": s3_events
    }

    try:
        response = requests.post(
            'https://python-lambda.free.beeceptor.com/my/api/path',
            data=json.dumps(data)
        )

    except Exception as error:
        print('Error in request: ', str(error))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "result": checker.validate(current_data),
            "s3_events": s3_events
        }),
    }
