#!/usr/bin/env bash
# Rejoue les tests du TP et affiche les preuves (réponses HTTP, logs, contenu de DynamoDB).
set -uo pipefail

API_ID=$(awsemu apigatewayv2 get-apis --query 'Items[?Name==`tp1bis`].ApiId' --output text)
URL="http://localhost:4566/_aws/execute-api-v2/$API_ID/\$default/"

appel() {
  echo "> POST $1"
  curl -s -w '  (HTTP %{http_code})\n' -X POST "$URL" -H 'Content-Type: application/json' -d "$1"
}

echo "== Compte utilisé (doit être 000000000000, donc l'émulateur)"
awsemu sts get-caller-identity --query Account --output text

echo; echo "== Appel valide"
appel '{"nom":"Alice","message":"Bonjour"}'

echo; echo "== DynamoDB juste après la réponse (le traitement asynchrone n'est pas forcément fini)"
awsemu dynamodb scan --table-name messages --query Count

echo; echo "== Appels successifs"
appel '{"nom":"Bob","message":"Salut"}'
appel '{"nom":"Chloé","message":"Coucou"}'

echo; echo "== Appels invalides"
appel 'pas du json'
appel '{"nom":"Sans message"}'

echo; echo "== Attente du traitement par lambda-sqs"
sleep 15

echo; echo "== Contenu de DynamoDB"
awsemu dynamodb scan --table-name messages \
  --query 'Items[].[nom.S, message.S, id.S]' --output table

echo; echo "== Logs de lambda-sqs"
awsemu logs filter-log-events --log-group-name /aws/lambda/lambda-sqs \
  --query 'events[].message' --output text | tr '\t' '\n' | grep -E "Enregistré|Échec"
