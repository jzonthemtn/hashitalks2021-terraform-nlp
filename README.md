# ML Models from Training to Serving: A Terraform Journey

This repository contains the code for the 2021 HashiTalks presentation.

## Abstract

As machine learning becomes more pervasive across industries the need to automate the deployment of the required infrastructure becomes even more important. The ability to efficiently and automatically provision infrastructure for modeling training, evaluation, and serving becomes an important component of a successful ML pipeline

In this talk I will present a Terraform-managed architecture built in AWS to handle the full machine learning lifecycle. Using tools and services such as containers, Amazon EC2, S3, and Lambda, our architecture will facilitate training and evaluating NLP models.

Attendees of this talk will come away with a working knowledge of how a machine learning pipeline can be constructed and managed with Terraform. Knowledge of NLP is not required and all NLP concepts key to the talk will first be introduced. While the talk will use NLP as an example, the processes described will largely be generic and adaptable to other types of machine learning models. All code presented will be available on GitHub.

## Code

The code in this repository creates the infrastructure required to automate the training and serving of NLP models in AWS.
