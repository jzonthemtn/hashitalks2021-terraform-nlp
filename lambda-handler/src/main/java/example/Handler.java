package example;

import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.AmazonECSClientBuilder;
import com.amazonaws.services.ecs.model.DescribeTasksRequest;
import com.amazonaws.services.ecs.model.DescribeTasksResult;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.ScheduledEvent;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClientBuilder;
import com.amazonaws.services.sqs.model.Message;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import example.model.ModelTrainingRequest;

import java.util.List;

public class Handler implements RequestHandler<ScheduledEvent, String> {

  private static final String QUEUE_NAME = "ml-queue";
  private static final String ECS_CLUSTER_NAME = "nlp";
  private static final int MAX_TASKS = 2;

  private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

  @Override
  public String handleRequest(ScheduledEvent event, Context context) {

    final LambdaLogger logger = context.getLogger();
    logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
    logger.log("CONTEXT: " + gson.toJson(context));
    logger.log("EVENT: " + gson.toJson(event));
    logger.log("EVENT TYPE: " + event.getClass().toString());

    final AmazonECS ecs = AmazonECSClientBuilder.standard().build();

    final AmazonSQS sqs = AmazonSQSClientBuilder.defaultClient();
    final String queueUrl = sqs.getQueueUrl(QUEUE_NAME).getQueueUrl();
    final List<Message> messages = sqs.receiveMessage(queueUrl).getMessages();

    for(final Message message : messages) {

      final ModelTrainingRequest modelTrainingRequest = gson.fromJson(message.getBody(), ModelTrainingRequest.class);

      // How many models are currently being trained?
      final DescribeTasksRequest describeTasksRequest = new DescribeTasksRequest();
      describeTasksRequest.setCluster(ECS_CLUSTER_NAME);
      final DescribeTasksResult describeTasksResult = ecs.describeTasks(describeTasksRequest);

      if(describeTasksResult.getTasks().size() < MAX_TASKS) {

        // Start a new task.
        logger.log("Starting a new model training task.");

        // Delete the message from the queue.

      }

    }

    return "done";

  }

}