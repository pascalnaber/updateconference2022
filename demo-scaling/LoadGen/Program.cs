using System.Net;
using Azure.Storage.Queues;

ServicePointManager.DefaultConnectionLimit = 100;

var connectionString = args[0];
var queueName = args[1];
var messageCount = int.Parse(args[2]);

// Get a reference to a queue and then create it
QueueClient queue = new QueueClient(connectionString, queueName);
await queue.CreateAsync();

ParallelOptions parallelOptions = new()
{
    MaxDegreeOfParallelism = 100
};

Console.WriteLine($"Sending {messageCount} message(s)...");

await Parallel.ForEachAsync(
    Enumerable.Range(0, messageCount),
    parallelOptions,
    async (_, _) =>
    {
        await queue.SendMessageAsync("Hello, Azure!");
    });

Console.WriteLine("Done");