#!/usr/bin/env bash
# Crée toutes les ressources dans LocalEmu. À relancer après chaque redémarrage de l'émulateur.
set -euo pipefail
cd "$(dirname "$0")"

ROLE=arn:aws:iam::000000000000:role/lambda-role
mkdir -p build

awsemu sqs create-queue --queue-name messages >/dev/null
QUEUE_URL=$(awsemu sqs get-queue-url --queue-name messages --query QueueUrl --output text)
QUEUE_ARN=$(awsemu sqs get-queue-attributes --queue-url "$QUEUE_URL" --attribute-names QueueArn --query Attributes.QueueArn --output text)

awsemu dynamodb create-table --table-name messages \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST >/dev/null

for fn in lambda-http lambda-sqs; do
  (cd src/$fn && zip -qr ../../build/$fn.zip .)
done

awsemu lambda create-function --function-name lambda-http \
  --runtime nodejs22.x --handler index.handler --role $ROLE \
  --zip-file fileb://build/lambda-http.zip \
  --environment "Variables={QUEUE_URL=$QUEUE_URL}" >/dev/null

awsemu lambda create-function --function-name lambda-sqs \
  --runtime nodejs22.x --handler index.handler --role $ROLE \
  --zip-file fileb://build/lambda-sqs.zip \
  --environment "Variables={TABLE_NAME=messages}" >/dev/null

awsemu lambda create-event-source-mapping --function-name lambda-sqs \
  --event-source-arn "$QUEUE_ARN" --batch-size 10 \
  --function-response-types ReportBatchItemFailures >/dev/null

API_ID=$(awsemu apigatewayv2 create-api --name tp1bis --protocol-type HTTP \
  --target "arn:aws:lambda:us-east-1:000000000000:function:lambda-http" \
  --query ApiId --output text)

echo "Ressources créées. URL de l'API :"
echo "http://localhost:4566/_aws/execute-api-v2/$API_ID/\$default/"
