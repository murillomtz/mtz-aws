ECR_REGISTRY="SEU_REGISTRY"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
docker build -t mtz .
docker tag mtz:latest $ECR_REGISTRY/mtz:latest
docker push $ECR_REGISTRY/mtz:latest
