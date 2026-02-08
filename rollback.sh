#!/bin/bash
set -e

REGION="us-east-1"
CLUSTER="cluster-mtz"
SERVICE="service-mtz"
REPO="mtz-app"

if [ -z "$1" ]; then
    echo "Uso: ./rollback.sh <COMMIT_HASH>"
    echo ""
    echo "Versões disponíveis no ECR:"
    aws ecr describe-images --repository-name $REPO --region $REGION \
        --query 'sort_by(imageDetails,& imagePushedAt)[*].[imageTags[0],imagePushedAt]' \
        --output table
    exit 1
fi

HASH=$1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:$HASH"

echo "🔄 Fazendo rollback para: $HASH"

# Verificar se imagem existe
if ! aws ecr describe-images --repository-name $REPO --region $REGION --image-ids imageTag=$HASH &>/dev/null; then
    echo "❌ Imagem $HASH não encontrada no ECR"
    exit 1
fi

# Atualizar service
aws ecs update-service \
    --cluster $CLUSTER \
    --service $SERVICE \
    --force-new-deployment \
    --region $REGION \
    --task-definition $(aws ecs describe-services --cluster $CLUSTER --services $SERVICE --region $REGION \
        --query 'services[0].taskDefinition' --output text | sed "s/:.*/:$HASH/") \
    --query 'service.serviceName' \
    --output text

echo "✅ Rollback iniciado para versão $HASH"
echo "📊 Acompanhe: aws ecs describe-services --cluster $CLUSTER --services $SERVICE --region $REGION"
