import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb'

const db = DynamoDBDocumentClient.from(new DynamoDBClient({}))

export const handler = async (event) => {
  const batchItemFailures = []

  for (const record of event.Records) {
    try {
      const item = JSON.parse(record.body)
      // L'id vient de la Lambda HTTP, un message traité deux fois écrase la même ligne
      await db.send(new PutCommand({ TableName: process.env.TABLE_NAME, Item: item }))
      console.log('Enregistré dans DynamoDB', item.id)
    } catch (err) {
      console.error('Échec du message', record.messageId, err)
      batchItemFailures.push({ itemIdentifier: record.messageId })
    }
  }

  return { batchItemFailures }
}
