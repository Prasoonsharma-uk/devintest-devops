# CI/CD Pipeline: Azure DevOps + Terraform + AWS ECS

A complete CI/CD pipeline that automates infrastructure provisioning and deployment of a containerized Python application on Amazon ECS using Azure DevOps and Terraform.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Azure DevOps Pipeline                        │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  ┌───────────────┐ │
│  │  Source   │→ │  Build   │→ │Infrastructure │→ │   Deploy      │ │
│  │  Stage    │  │  Stage   │  │    Stage      │  │   Stage       │ │
│  └──────────┘  └──────────┘  └───────────────┘  └───────────────┘ │
│   Git Trigger   Python Test   Terraform Init     ECS Update       │
│                 Docker Build   Validate/Plan      Wait Stable     │
│                 ECR Push       Apply              Health Check    │
└─────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Cloud                                  │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                         VPC (10.0.0.0/16)                     │ │
│  │                                                                │ │
│  │  ┌─────────────────────┐    ┌──────────────────────┐         │ │
│  │  │   Public Subnets    │    │   Private Subnets     │         │ │
│  │  │                     │    │                       │         │ │
│  │  │  ┌──────────────┐  │    │  ┌─────────────────┐ │         │ │
│  │  │  │     ALB      │──│────│──│   ECS Fargate   │ │         │ │
│  │  │  │  (Internet)  │  │    │  │   Service        │ │         │ │
│  │  │  └──────────────┘  │    │  │                  │ │         │ │
│  │  │                     │    │  │  ┌────────────┐ │ │         │ │
│  │  │  ┌──────────────┐  │    │  │  │ Task (App) │ │ │         │ │
│  │  │  │ NAT Gateway  │  │    │  │  └────────────┘ │ │         │ │
│  │  │  └──────────────┘  │    │  └─────────────────┘ │         │ │
│  │  └─────────────────────┘    └──────────────────────┘         │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────┐  ┌──────────────┐  ┌────────────┐                  │
│  │   ECR    │  │  S3 (State)  │  │  DynamoDB  │                  │
│  │ Registry │  │   + KMS      │  │  (Locking) │                  │
│  └──────────┘  └──────────────┘  └────────────┘                  │
└─────────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
├── app/                              # Python application
│   ├── app.py                        # Flask Hello World application
│   ├── requirements.txt              # Python dependencies
│   └── tests/                        # Unit tests
│       └── test_app.py
├── terraform/                        # Infrastructure as Code
│   ├── main.tf                       # Root module orchestration
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── providers.tf                  # Provider configuration
│   ├── backend.tf                    # S3 remote backend config
│   ├── environments/                 # Environment-specific configs
│   │   ├── dev.tfvars
│   │   └── prod.tfvars
│   └── modules/                      # Reusable Terraform modules
│       ├── networking/               # VPC, subnets, ALB, security groups
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── ecr/                      # Container registry
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── ecs/                      # ECS cluster, task, service
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── scripts/                          # Utility scripts
│   └── bootstrap-terraform-backend.sh
├── Dockerfile                        # Multi-stage Docker build
├── .dockerignore                     # Docker build exclusions
├── .gitignore                        # Git exclusions
├── azure-pipelines.yml               # Azure DevOps pipeline
└── README.md                         # This file
```

## Prerequisites

1. **Azure DevOps Account** with a project created
2. **AWS Account** with appropriate IAM permissions
3. **AWS CLI** configured locally (for initial backend setup)

## Quick Start

### 1. Bootstrap Terraform Backend

Before running the pipeline, create the S3 bucket and DynamoDB table for Terraform state:

```bash
chmod +x scripts/bootstrap-terraform-backend.sh
./scripts/bootstrap-terraform-backend.sh hello-world-ecs us-east-1
```

### 2. Configure Azure DevOps

#### Create Variable Group

Create a variable group named `aws-credentials` in Azure DevOps with:

| Variable             | Description                    | Secret |
|----------------------|--------------------------------|--------|
| `AWS_ACCESS_KEY_ID`  | AWS IAM access key             | Yes    |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key          | Yes    |
| `AWS_ACCOUNT_ID`     | AWS account number (12 digits) | No     |

**Steps:**
1. Go to **Pipelines** → **Library** → **+ Variable group**
2. Name it `aws-credentials`
3. Add the three variables above
4. Mark `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as secrets
5. Save

#### Create Pipeline

1. Go to **Pipelines** → **New Pipeline**
2. Select your repository source
3. Choose **Existing Azure Pipelines YAML file**
4. Select `azure-pipelines.yml`
5. Run the pipeline

#### Create Environments (for approval gates)

1. Go to **Pipelines** → **Environments**
2. Create `dev` environment (no approvals needed)
3. Create `production` environment with approval checks:
   - Add **Approvals and checks** → **Approvals**
   - Add required approvers

### 3. IAM Permissions

The AWS IAM user/role needs these permissions:

- `AmazonECS_FullAccess`
- `AmazonEC2ContainerRegistryFullAccess`
- `AmazonVPCFullAccess`
- `ElasticLoadBalancingFullAccess`
- `IAMFullAccess` (for ECS task roles)
- `CloudWatchLogsFullAccess`
- `AmazonS3FullAccess` (for Terraform state)
- `AmazonDynamoDBFullAccess` (for Terraform locks)

> **Recommendation:** Create a dedicated IAM user for CI/CD with minimal required permissions using a custom policy.

## Pipeline Stages

### Stage 1: Build & Test
- Sets up Python environment
- Installs dependencies and lints code with `flake8`
- Runs unit tests with `pytest`
- Scans dependencies for vulnerabilities
- Builds multi-stage Docker image
- Pushes image to Amazon ECR
- Runs container image security scan with Trivy

### Stage 2: Infrastructure (Dev)
- Initializes Terraform with remote S3 backend
- Validates Terraform configuration
- Checks Terraform formatting
- Creates execution plan
- Applies infrastructure changes for dev environment

### Stage 3: Deploy (Dev)
- Forces new ECS service deployment
- Waits for service stability
- Verifies health check endpoint
- Reports deployment status and application URL

### Stage 4: Infrastructure (Prod)
- Only runs on `main` branch
- Creates Terraform plan for production
- **Manual approval gate** before applying

### Stage 5: Deploy (Prod)
- Deploys to production ECS cluster
- Verifies production health
- Reports production URL

## Terraform Modules

### Networking Module
- **VPC** with DNS support
- **Public subnets** (for ALB, NAT Gateways)
- **Private subnets** (for ECS tasks)
- **NAT Gateways** for private subnet internet access
- **Application Load Balancer** with health checks
- **Security groups** for ALB and ECS tasks

### ECR Module
- **ECR Repository** with encryption and image scanning
- **Lifecycle policy** to retain last N images

### ECS Module
- **ECS Cluster** with Fargate capacity providers
- **Task Definition** with CloudWatch logging
- **ECS Service** with deployment circuit breaker
- **Auto Scaling** policies (CPU and memory-based)
- **IAM Roles** for task execution and task

## Security Best Practices

- **Credentials**: AWS credentials stored as Azure DevOps secrets in variable groups
- **Container Security**: Non-root user in Docker image, vulnerability scanning
- **Network Security**: ECS tasks in private subnets, ALB in public subnets
- **State Security**: Terraform state encrypted in S3 with KMS, access via DynamoDB locking
- **Image Security**: ECR image scanning enabled, lifecycle policies for cleanup
- **Least Privilege**: Separate IAM roles for task execution and task runtime
- **Approval Gates**: Manual approval required for production deployments
- **Circuit Breaker**: ECS deployment circuit breaker with automatic rollback

## Environment Configuration

| Parameter             | Dev      | Prod     |
|-----------------------|----------|----------|
| Task CPU              | 256      | 512      |
| Task Memory           | 512 MiB  | 1024 MiB |
| Desired Count         | 1        | 2        |
| Min Capacity          | 1        | 2        |
| Max Capacity          | 2        | 6        |
| AZ Count              | 2        | 3        |
| Log Retention         | 7 days   | 90 days  |
| Container Insights    | Disabled | Enabled  |
| Image Tag Mutability  | Mutable  | Immutable|

## Local Development

```bash
# Run the application locally
cd app
pip install -r requirements.txt
python app.py

# Run tests
pip install pytest
python -m pytest tests/ -v

# Build Docker image locally
docker build -t hello-world-ecs .
docker run -p 5000:5000 hello-world-ecs

# Test endpoints
curl http://localhost:5000/
curl http://localhost:5000/health
```

## Verification

After deployment, verify the application:

```bash
# Get the ALB DNS name from Terraform outputs
cd terraform
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test the application
curl http://${ALB_DNS}/
# Expected: {"hostname":"...","message":"Hello World from ECS!","version":"..."}

curl http://${ALB_DNS}/health
# Expected: {"status":"healthy"}
```

## Cleanup

To destroy all infrastructure:

```bash
cd terraform

# Destroy dev environment
terraform init -backend-config="bucket=hello-world-ecs-terraform-state" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=hello-world-ecs-terraform-locks"
terraform destroy -var-file="environments/dev.tfvars"

# Destroy prod environment
terraform init -reconfigure \
  -backend-config="bucket=hello-world-ecs-terraform-state" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=hello-world-ecs-terraform-locks"
terraform destroy -var-file="environments/prod.tfvars"
```
