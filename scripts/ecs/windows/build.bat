aws ecr get-login-password --region us-east-1 --profile [SEU_PROFILE] | docker login --username AWS --password-stdin [SEU_ECR]
docker build -t mtz .
docker tag mtz:latest [SEU_ECR]/mtz:latest
docker push [SEU_ECR]/mtz:latest