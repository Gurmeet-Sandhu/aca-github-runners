const { QueueServiceClient } = require("@azure/storage-queue");

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const azureStorageConnectionString = process.env['AzureWebJobsStorage']
    const queueName = 'outqueue';

    const githubEvent = req.body;

    try {
        const queueServiceClient = QueueServiceClient.fromConnectionString(azureStorageConnectionString);
        const queueClient = queueServiceClient.getQueueClient(queueName);
        await queueClient.createIfNotExists();

        if (githubEvent.action === 'queued') {
            // Enqueue a message with job ID
            const message = `Job ${githubEvent.workflow_job.id} is queued.`;
            await queueClient.sendMessage(Buffer.from(message).toString('base64'));
        } else if (githubEvent.action === 'completed') {
            // Retrieve all messages to find the one corresponding to the completed job
            let response = await queueClient.receiveMessages();
            if (response.receivedMessageItems.length > 0) {
                for (let message of response.receivedMessageItems) {
                    if (message.messageText.includes(`Job ${githubEvent.workflow_job.id}`)) {
                        // Delete the specific message corresponding to the completed job
                        await queueClient.deleteMessage(message.messageId, message.popReceipt);
                        break;
                    }
                }
            }
        }

        context.res = {
            body: "Function executed successfully!"
        };
    } catch (error) {
        context.res = {
            status: 500,
            body: "Error: " + error.message
        };
    }

    // const name = (req.query.name || (req.body && req.body.name));
    // const responseMessage = name
    //     ? "Hello, " + name + ". This HTTP triggered function executed successfully."
    //     : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";
}