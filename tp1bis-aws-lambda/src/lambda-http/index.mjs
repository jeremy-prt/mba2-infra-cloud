import { randomUUID } from 'node:crypto'
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs'

// Sinon le SDK vise l'hôte de QUEUE_URL au lieu de l'émulateur (AWS_ENDPOINT_URL)
const sqs = new SQSClient({ useQueueUrlAsEndpoint: false })

const reponse = (statusCode, body) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body),
})

export const handler = async (event) => {
  let data
  try {
    data = JSON.parse(event.body ?? '')
  } catch {
    return reponse(400, { erreur: 'Corps JSON invalide' })
  }

  if (typeof data?.nom !== 'string' || typeof data?.message !== 'string') {
    return reponse(400, { erreur: 'Les champs nom et message sont obligatoires' })
  }

  const item = { id: randomUUID(), nom: data.nom, message: data.message, recuLe: new Date().toISOString() }

  await sqs.send(new SendMessageCommand({
    QueueUrl: process.env.QUEUE_URL,
    MessageBody: JSON.stringify(item),
  }))

  console.log('Message envoyé dans SQS', item.id)
  // 202 et non 201, le message n'est pas encore en base quand on répond
  return reponse(202, { statut: 'reçu', id: item.id })
}
