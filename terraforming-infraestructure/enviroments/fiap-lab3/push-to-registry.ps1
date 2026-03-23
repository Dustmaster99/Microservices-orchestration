$ErrorActionPreference = "Stop"

$AWS_REGION = "us-east-1"
$AWS_ACCOUNT_ID = "654654184825"
$PROJECT_NAME = "fiap-microservices"

$IMAGES = @(
    @{ Local = "microservices-orchestration-auth-service";       Ecr = "auth-service";       Tag = "latest" },
    @{ Local = "microservices-orchestration-analytics-service";  Ecr = "analytics-service";  Tag = "latest" },
    @{ Local = "microservices-orchestration-evaluation-service"; Ecr = "evaluation-service"; Tag = "latest" },
    @{ Local = "microservices-orchestration-flag-service";       Ecr = "flag-service";       Tag = "latest" },
    @{ Local = "microservices-orchestration-targeting-service";  Ecr = "targeting-service";  Tag = "latest" },
    @{ Local = "redis";                                          Ecr = "redis";              Tag = "7" }
)

$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

Write-Host "Login no ECR..."
cmd.exe /c "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY"
if ($LASTEXITCODE -ne 0) { throw "Falha no login do ECR" }

foreach ($IMAGE in $IMAGES) {
    $LOCAL_IMAGE = "$($IMAGE.Local):$($IMAGE.Tag)"
    $REMOTE_IMAGE = "${ECR_REGISTRY}/${PROJECT_NAME}/$($IMAGE.Ecr):$($IMAGE.Tag)"

    Write-Host "Tagueando $LOCAL_IMAGE -> $REMOTE_IMAGE"
    docker tag $LOCAL_IMAGE $REMOTE_IMAGE
    if ($LASTEXITCODE -ne 0) { throw "Falha no docker tag: $LOCAL_IMAGE" }

    Write-Host "Enviando $REMOTE_IMAGE"
    docker push $REMOTE_IMAGE
    if ($LASTEXITCODE -ne 0) { throw "Falha no docker push: $REMOTE_IMAGE" }
}

Write-Host "Push concluido com sucesso."