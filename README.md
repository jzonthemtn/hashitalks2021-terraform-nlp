# ML Models from Training to Serving: A Terraform Journey

This repository contains the code for the [HashiTalks 2021](https://events.hashicorp.com/hashitalks2021) presentation. This project facilitates the automated training and serving of NLP NER models on AWS.

## Presentation Abstract

As machine learning becomes more pervasive across industries the need to automate the deployment of the required infrastructure becomes even more important. The ability to efficiently and automatically provision infrastructure for modeling training, evaluation, and serving becomes an important component of a successful ML pipeline

In this talk I will present a Terraform-managed architecture built in AWS to handle the full machine learning lifecycle. Using tools and services such as containers, Amazon EC2, S3, and Lambda, our architecture will facilitate training and evaluating NLP models.

Attendees of this talk will come away with a working knowledge of how a machine learning pipeline can be constructed and managed with Terraform. Knowledge of NLP is not required and all NLP concepts key to the talk will first be introduced. While the talk will use NLP as an example, the processes described will largely be generic and adaptable to other types of machine learning models. All code presented will be available on GitHub.

## Usage

To get started first clone this repository.

### Building the Containers

This project uses Docker containers for model training and serving. One container is used for training an NLP NER model and another container is used to serve a model via a simple REST API. Refer to each container's Dockerfile for details on the training and serving. The NLP is handled by [Flair](https://github.com/flairNLP/flair).

* You will want to modify the `build-image.sh` scripts to use your DockerHub username instead of mine.
* You also need to update the DockerHub username in the Terraform scripts regarding the image definitions.

Build and push the NLP NER training container:

```
cd training
./build-image.sh
docker push username/ner-training:latest
```

Now build and push the serving container:

```
cd serving
./build-image.sh
docker push username/ner-serve:latest
```

### Building the Lambda Function

The Lambda function is implemented in Java. The Lambda function controls the creation of ECS tasks.

To build the Lambda function:

```
mvn clean package -f ./lambda-handler/pom.xml
```

### Creating the infrastructure using Terraform

With the Docker images built and pushed we can now create the infrastructure using Terraform.

```
terraform init
terraform apply
```

This step creates:

* An SQS queue that holds the model training definitions (the models we want to train).
* An ECS cluster on which the model training and model serving containers will be run.
* An S3 bucket that will contain the trained models and their associated files.
* A Lambda function that consumes from the SQS queue and initiates model training.

To delete the resources and clean up:

```
terraform destroy
```

#### Lambda Function

The Lambda function is deployed via the Terraform scripts. It is a Java 11 function that is triggered when a message is published to the SQS queue.

### Training a Model

To train a model, publish a message to the SQS queue. Using the `queue-training.sh` scripts. Look at the contents of this script to change things such as the number of epochs and embeddings. The only required argument is the name of the model to train, shown below as `my-model`.

`./scripts/queue-training.sh my-model`

This publishes a message to the SQS queue which describes a desired model training. The Lambda function will be triggered by a Cloud Watch EventBridge (Events) rule. The function will consume the message(s) from the queue and launch a model training container on the ECS cluster if the cluster's number of running tasks is below a set threshold. When model training is complete, the model and its associated files will be uploaded to the S3 bucket by the container prior to exiting.

### Serving a Model

To serve a model, run the `serve.sh` script giving it the name of the model to serve.

`./scripts/serve.sh my-model`

This command will launch a model serving container on the ECS cluster for the given model. The model can then be used as:

```
curl -X POST http://$HOSTNAME:8080/ner --data "George Washington was president of the United States." -H "Content-type: text/plain"
```

The response will be a JSON-encoded list of entities (`George Washington` and `United States`) from the text.
