const { app, output } = require('@azure/functions')

const queueOutput = output.storageQueue({
  queueName: 'messages',
  connection: 'AzureWebJobsStorage',
})

app.http('httpTrigger', {
  methods: ['POST'],
  authLevel: 'anonymous',
  extraOutputs: [queueOutput],
  handler: async (request, context) => {
    const data = await request.json().catch(() => null)
    if (!data) return { status: 400, body: 'Corps JSON attendu' }

    context.extraOutputs.set(queueOutput, data)
    context.log('Message envoyé dans la queue', data)
    return { status: 202, jsonBody: { envoye: data } }
  },
})
