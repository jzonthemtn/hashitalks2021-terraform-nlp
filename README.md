# From Training to Serving: Machine Learning Models with Terraform

This repository contains the code for the [HashiTalks 2021](https://events.hashicorp.com/hashitalks2021) presentation.

* Jeff Zemerick
* David Smithbauer

## Summary

This project facilitates the automated training and serving of NLP named-entity recognition models on AWS.

### Presentation Abstract

As machine learning becomes more pervasive across industries the need to automate the deployment of the required infrastructure becomes even more important. The ability to efficiently and automatically provision infrastructure for modeling training, evaluation, and serving becomes an important component of a successful ML pipeline

In this talk I will present a Terraform-managed architecture built in AWS to handle the full machine learning lifecycle. Using tools and services such as containers, Amazon EC2, S3, and Lambda, our architecture will facilitate training and evaluating NLP models.

Attendees of this talk will come away with a working knowledge of how a machine learning pipeline can be constructed and managed with Terraform. Knowledge of NLP is not required and all NLP concepts key to the talk will first be introduced. While the talk will use NLP as an example, the processes described will largely be generic and adaptable to other types of machine learning models. All code presented will be available on GitHub.

## Usage

To get started first clone this repository.

> **Note: this project will create resources outside the AWS free tier. You are responsible for all associated costs/charges.**

### Building the Containers

This project uses Docker containers for model training and serving. One container is used for training an NLP NER model and another container is used to serve a model via a simple REST API. Refer to each container's Dockerfile for details on the training and serving. The NLP is handled by [Flair](https://github.com/flairNLP/flair).

**Important First Steps**

* You will need a DockerHub <hub.docker.com> account.
* You will need to log the Docker CLI into your account `docker login`
* Export your DockerHub username to the shell you'll be using `export DOCKERHUB_USERNAME=<your-user-name>`

Now you can build and push the NLP NER training container:

```
cd training
./build-image.sh
docker push $DOCKERHUB_USERNAME/ner-training:latest
```

Now build and push the serving container:

```
cd serving
./build-image.sh
docker push $DOCKERHUB_USERNAME/ner-serving:latest
```

### Building the Lambda Function

The Lambda function is implemented in Java. The Lambda function controls the creation of ECS tasks.

To build the Lambda function, run `build.sh` or the command:

```
mvn clean package -f ./lambda-handler/pom.xml -DskipTests=true
```

### Creating the infrastructure using Terraform

With the Docker images built and pushed we can now create the infrastructure using Terraform. In `variables.tf` there is a `name_prefix` variable that you can set in order to instantiate multiple copies of the infrastructure.

```
terraform init
terraform apply
```

This step creates:

* An SQS queue that holds the model training definitions (the models we want to train).
* An ECS cluster on which the model training and model serving containers will be run.
* An EventsBridge rule to trigger the Lambda function.
* A Lambda function that consumes from the SQS queue and initiates model training by creating the ECS service and task.
* An S3 bucket that will contain the trained models and their associated files.
* A DynamoDB table that will contain metadata about the models.

To delete the resources and clean up run `terraform destroy`.

> Note: if you have any model trainings in progress when trying to delete the delete will hang. This is because the ECS services and tasks for the model training were not created by Terraform. Just manually delete those services and tasks first and the destroy will succeed.

#### Lambda Function

The Lambda function is deployed via Terraform. It is a Java 11 function that is triggered by an Amazon EventBridge (CloudWatch Events) Rule. The function consumes messages from the SQS queue. The function is parameterized through environment variables set by the terraform script.

### Training a Model

To train a model, publish a message to the SQS queue. Using the `queue-training.sh` scripts. Look at the contents of this script to change things such as the number of epochs and embeddings. The only required argument is the name of the model to train, shown below as `my-model`.

`./queue-training.sh my-model`

This publishes a message to the SQS queue which describes a desired model training. The Lambda function will be triggered by a Cloud Watch EventBridge (Events) rule. The function will consume the message(s) from the queue and launch a model training container on the ECS cluster if the cluster's number of running tasks is below a set threshold. The function will also insert a row into the DynamoDB table indicating the model's training is in progress. A `modelId` will be generated by the function that is the concatenation of the given model's name and a random UUID.

When model training is complete, the model and its associated files will be uploaded to the S3 bucket by the container prior to exiting. The model's metadata in the DynamoDB table will be updated to reflect that training is complete.

### Serving a Model

To serve a model, change to the `serve` directory. Edit `variables.tf` to set the name of the model to serve and then run `terraform init` and `terraform apply`.

This will launch a service and task on the ECS cluster to serve the given given model. The model can then be used by referencing the output DNS name of the load balancer:

```
curl -X POST http://$ALB:8080/ner --data "George Washington was president of the United States." -H "Content-type: text/plain"
```

The response will be a JSON-encoded list of JSON entities (`George Washington` and `United States`) from the text. (The actual output will vary based on the model's training and input text.)

> Note: if you receive a `503 Service Temporarily Unavailable` response, be patient and try again in a few moments.

## GPU

For training and serving on a GPU:

1. Use a GPU-capable EC2 instance type for the ECS cluster.
1. Install the appropriate CUDA runtime on the EC2 instance(s).

## License

This project is licensed under the Apache License, version 2.0.
