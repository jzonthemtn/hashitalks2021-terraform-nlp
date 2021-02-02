package example;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.ecs.AmazonECS;
import com.amazonaws.services.ecs.AmazonECSClientBuilder;
import com.amazonaws.services.ecs.model.*;
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

import java.util.Arrays;
import java.util.List;

public class Handler implements RequestHandler<ScheduledEvent, String> {

  private static final String QUEUE_NAME = "ml-queue";
  private static final String ECS_CLUSTER_NAME = "nlp";
  private static final int MAX_TASKS = 2;
  private static final String NLP_SERVING_SERVICE = "serving";
  private static final String NLP_TRAINING_SERVICE = "training";

  private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

  @Override
  public String handleRequest(ScheduledEvent event, Context context) {

    final LambdaLogger logger = context.getLogger();

    final AmazonECS ecs = AmazonECSClientBuilder.standard().withRegion(Regions.US_EAST_1).build();
    final AmazonSQS sqs = AmazonSQSClientBuilder.standard().withRegion(Regions.US_EAST_1).build();

    final String queueUrl = sqs.getQueueUrl(QUEUE_NAME).getQueueUrl();
    final List<Message> messages = sqs.receiveMessage(queueUrl).getMessages();

    for(final Message message : messages) {

      final ModelTrainingRequest modelTrainingRequest = gson.fromJson(message.getBody(), ModelTrainingRequest.class);

      logger.log("Received training request for model " + modelTrainingRequest.getName());

      // How many models are currently being trained?

      final ListTasksRequest listTasksRequest = new ListTasksRequest();
      listTasksRequest.setCluster(ECS_CLUSTER_NAME);
      listTasksRequest.setServiceName(NLP_SERVING_SERVICE);

      final ListTasksResult listTasksResult = ecs.listTasks(listTasksRequest);
      final int tasks = listTasksResult.getTaskArns().size();

      logger.log("Current ECS tasks is " + tasks);

      if(tasks < MAX_TASKS) {

        // Start a new task.
        logger.log("Starting a new model training task.");

        final CreateTaskSetRequest createTaskSetRequest = new CreateTaskSetRequest();
        createTaskSetRequest.setCluster(ECS_CLUSTER_NAME);
        createTaskSetRequest.setService(NLP_SERVING_SERVICE);
        ecs.createTaskSet(createTaskSetRequest);

        // Delete the message from the queue.
        sqs.deleteMessage(queueUrl, message.getReceiptHandle());

      }

    }

    //logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
    //logger.log("CONTEXT: " + gson.toJson(context));
    //logger.log("EVENT: " + gson.toJson(event));
    //logger.log("EVENT TYPE: " + event.getClass().toString());

    return "done";

  }

}