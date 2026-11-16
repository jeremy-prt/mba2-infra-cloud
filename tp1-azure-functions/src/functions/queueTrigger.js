const { app, output } = require('@azure/functions')
const { randomUUID } = require('node:crypto')

const tableOutput = output.table({
  tableName: 'messages',
  connection: 'AzureWebJobsStorage',
})

app.storageQueue('queueTrigger', {
  queueName: 'messages',
  connection: 'AzureWebJobsStorage',
  extraOutputs: [tableOutput],
  handler: (message, context) => {
    context.log('Message reçu depuis la queue', message)
    context.extraOutputs.set(tableOutput, {
      PartitionKey: 'messages',
      RowKey: randomUUID(),
      ...message,
    })
  },
})
