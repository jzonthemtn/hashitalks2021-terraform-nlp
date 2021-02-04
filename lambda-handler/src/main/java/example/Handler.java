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
import org.apache.commons.lang3.StringUtils;

import java.util.*;

public class Handler implements RequestHandler<ScheduledEvent, String> {

  private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

  @Override
  public String handleRequest(ScheduledEvent event, Context context) {

    final LambdaLogger logger = context.getLogger();

    final String ecsClusterName = System.getenv("ecs_cluster_name");
    logger.log("Using ECS cluster " + ecsClusterName);

    final String queueUrl = System.getenv("queue_url");
    logger.log("Using SQS queue " + queueUrl);

    final String region = System.getenv("region");
    logger.log("Using region " + region);

    final String debug = System.getenv("debug");
    logger.log("Using debug " + debug);

    final AmazonECS ecs = AmazonECSClientBuilder.standard().withRegion(region).build();
    final AmazonSQS sqs = AmazonSQSClientBuilder.standard().withRegion(region).build();

    final List<Message> messages = sqs.receiveMessage(queueUrl).getMessages();

    if(messages.isEmpty()) {

      logger.log("No messages were consumed.");

    } else {

      final int maxTasks = Integer.valueOf(System.getenv("max_tasks"));

      for (final Message message : messages) {

        final ModelTrainingRequest modelTrainingRequest = gson.fromJson(message.getBody(), ModelTrainingRequest.class);
        final String modelId = modelTrainingRequest.getName() + "-" + UUID.randomUUID().toString();

        logger.log("Received training request for model " + modelTrainingRequest.getName() + " (" + modelId + ")");

        // TODO: Check to see if we are under the maximum.

        final ContainerDefinition containerDefinition = new ContainerDefinition();
        containerDefinition.setName(modelTrainingRequest.getName());
        containerDefinition.setMemoryReservation(100);
        containerDefinition.setMemory(4096);
        containerDefinition.setImage(modelTrainingRequest.getImage());

        final LogConfiguration logConfiguration = new LogConfiguration();
        logConfiguration.setLogDriver("awslogs");

        // See https://aws.amazon.com/blogs/compute/centralized-container-logs-with-amazon-ecs-and-amazon-cloudwatch-logs/
        final Map<String, String> options = new LinkedHashMap<>();
        options.put("awslogs-group", System.getenv("aws_logs_group"));
        options.put("awslogs-region", Regions.US_EAST_1.getName());
        options.put("awslogs-stream-prefix", modelId);
        logConfiguration.setOptions(options);
        containerDefinition.setLogConfiguration(logConfiguration);

        final String s3Bucket = System.getenv("s3_bucket");
        logger.log("Using s3 bucket " + s3Bucket);

        final Collection<KeyValuePair> environmentVariables = new LinkedList<>();
        environmentVariables.add(new KeyValuePair().withName("MODEL").withValue(modelTrainingRequest.getName()));
        environmentVariables.add(new KeyValuePair().withName("EPOCHS").withValue(String.valueOf(modelTrainingRequest.getEpochs())));
        environmentVariables.add(new KeyValuePair().withName("EMBEDDINGS").withValue(modelTrainingRequest.getEmbeddings()));
        environmentVariables.add(new KeyValuePair().withName("S3_BUCKET").withValue(s3Bucket));
        containerDefinition.setEnvironment(environmentVariables);

        final RegisterTaskDefinitionRequest registerTaskDefinitionRequest = new RegisterTaskDefinitionRequest();
        registerTaskDefinitionRequest.setNetworkMode(NetworkMode.Host);
        registerTaskDefinitionRequest.setContainerDefinitions(Arrays.asList(containerDefinition));
        registerTaskDefinitionRequest.setFamily(modelTrainingRequest.getName());

        ecs.registerTaskDefinition(registerTaskDefinitionRequest);

        final DeploymentController deploymentController = new DeploymentController();
        deploymentController.setType("ECS");

        final CreateServiceRequest createServiceRequest = new CreateServiceRequest();
        createServiceRequest.setServiceName(modelId);
        createServiceRequest.setCluster(ecsClusterName);
        createServiceRequest.setDesiredCount(1);
        createServiceRequest.setTaskDefinition(modelTrainingRequest.getName());
        createServiceRequest.setDeploymentController(deploymentController);

        final CreateServiceResult createServiceResult = ecs.createService(createServiceRequest);

        if(StringUtils.isNotEmpty(createServiceResult.getService().getServiceArn())) {
          sqs.deleteMessage(queueUrl, message.getReceiptHandle());
        }

      }

      if(StringUtils.equalsIgnoreCase(debug, "true")) {
        logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
        logger.log("CONTEXT: " + gson.toJson(context));
        logger.log("EVENT: " + gson.toJson(event));
        logger.log("EVENT TYPE: " + event.getClass().toString());
      }

    }

    return "done";

  }

}