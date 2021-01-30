#!/bin/bash

# Amazon Linux 2
aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended

# Amazon Linux 2 (GPU)
aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended
