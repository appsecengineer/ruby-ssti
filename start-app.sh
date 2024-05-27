#!/bin/bash


# Build the Docker image
docker build -t erb-injection-app .

# Run the Docker container on port 8880
docker run -p 8880:8880 erb-injection-app

