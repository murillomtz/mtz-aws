#!/bin/bash
# deploy-versioned.sh - Deploy simples com versionamento

set -e

REGION="us-east-1"
ECR_REPO="mtz"
CLUSTER="cluster-mtz"
SERVICE="service-mtz"
TASK_FAMILY="task-def-mtz"
ACCOUNT_ID="791074026410"

# Obter commit hash
COMMIT_HASH=$(git rev-parse --short=7 HEAD)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"

echo "=== Deploy Versionado MTZ ==="
echo "Versão: $COMMIT_HASH"
echo "ECR: $ECR_URI:$COMMIT_HASH"
echo ""

# 1. Login ECR
echo "[1/5] Login no ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# 2. Build
echo "[2/5] Build da imagem..."
docker build -t $ECR_URI:$COMMIT_HASH -t $ECR_URI:latest .

# 3. Push
echo "[3/5] Push para ECR..."
docker push $ECR_URI:$COMMIT_HASH
docker push $ECR_URI:latest

# 4. Criar Task Definition
echo "[4/5] Criando task definition..."
TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION --query 'taskDefinition')
echo "$TASK_DEF" | jq -c --arg img "$ECR_URI:$COMMIT_HASH" '.containerDefinitions[0].image = $img | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .placementConstraints, .compatibilities, .registeredAt, .registeredBy)' > /tmp/task-def.json
NEW_REVISION=$(aws ecs register-task-definition --region $REGION --cli-input-json file:///tmp/task-def.json --query 'taskDefinition.revision' --output text)

# 5. Update Service
echo "[5/5] Atualizando serviço..."
aws ecs update-service --region $REGION --cluster $CLUSTER --service $SERVICE --task-definition $TASK_FAMILY:$NEW_REVISION > /dev/null

echo ""
echo "✅ Deploy concluído!"
echo "   Versão: $COMMIT_HASH"
echo "   Task Definition: $TASK_FAMILY:$NEW_REVISION"
echo ""
echo "Para rollback: aws ecs update-service --cluster $CLUSTER --service $SERVICE --task-definition $TASK_FAMILY:<revision>"
