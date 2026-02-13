# End-to-End Deployment Workflow

Complete automation pipeline from AWS infrastructure to Kubernetes application deployment.

## 🎯 Two-Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     GIT Repository                              │
│  (Code, Dockerfile, Helm Charts, Terraform, Jenkinsfiles)      │
└────────────┬────────────────────────────────────────────────────┘
             │
             ├─────────────────────────────────────────────────────┐
             │                                                     │
             ▼                                                     ▼
    ┌──────────────────┐                              ┌──────────────────┐
    │  Jenkinsfile     │                              │ Jenkinsfile.deploy│
    │ (Infrastructure) │                              │ (Application)     │
    └──────┬───────────┘                              └────────┬─────────┘
           │                                                   │
    ┌──────▼──────────────────┐                       ┌────────▼──────────┐
    │   Terraform Apply       │                       │  Helm Upgrade     │
    │                         │                       │                   │
    │ Creates:                │                       │ Deploys:          │
    │ • EKS Cluster          │                       │ • Backend (Express)│
    │ • RDS Database         │                       │ • Frontend (Next) │
    │ • ECR Repositories     │                       │ • Services        │
    │ • VPC, NAT, IGW        │                       │ • Ingress         │
    │ • Security Groups      │                       │ • ConfigMaps      │
    └──────┬──────────────────┘                       └────────┬──────────┘
           │                                                   │
    ┌──────▼────────────────┐                        ┌─────────▼────────┐
    │ AWS Infrastructure    │                        │ Kubernetes Apps  │
    │ (EKS, RDS, S3, etc)   │                        │ (Running on EKS) │
    └──────────────────────┘                        └──────────────────┘
```

---

## 📋 Workflow: Infrastructure + Application

### Phase 1: Setup State Management (One-Time)

```bash
# Run this ONCE before any Terraform deployments
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
./setup-terraform-state.sh

# Creates:
# - S3 bucket: ecommerce-terraform-state-us-east-1
# - DynamoDB table: ecommerce-terraform-locks
# - IAM roles for state locking
```

**Output Files Generated:**
- `terraform/backend-template.hcl` - Backend configuration reference

---

### Phase 2: Deploy Infrastructure (Jenkinsfile)

**Jenkins Job Configuration:**
- Repository: Your Git repo
- Jenkinsfile: `Jenkinsfile` (not Jenkinsfile.deploy)
- Build Parameters:
  - `RDS_PASSWORD`: Min 8 chars (e.g., "MySecure123Pass")
  - `ENVIRONMENT`: dev/staging/prod

**Pipeline Execution:**

```
Checkout → Init → Format → Validate → Plan → Apply
```

**Build Parameters Example:**
```
RDS_PASSWORD: MySecure123Pass
ENVIRONMENT: dev
```

**Expected Duration:** 15-20 minutes

**Outputs Generated:**
- EKS Cluster Name: `ecommerce-eks-dev`
- RDS Endpoint: `ecommerce-db.c3b43k5z7y8h.us-east-1.rds.amazonaws.com`
- ECR Repository URLs:
  - `123456789012.dkr.ecr.us-east-1.amazonaws.com/ecommerce-backend`
  - `123456789012.dkr.ecr.us-east-1.amazonaws.com/ecommerce-frontend`

---

### Phase 3: Build & Push Docker Images

```bash
# Build backend image
cd server
docker build -t ecommerce-backend:latest .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO
docker tag ecommerce-backend:latest $ECR_REPO/ecommerce-backend:latest
docker push $ECR_REPO/ecommerce-backend:latest

# Build frontend image
cd app
docker build -f Dockerfile.dev -t ecommerce-frontend:latest .
docker tag ecommerce-frontend:latest $ECR_REPO/ecommerce-frontend:latest
docker push $ECR_REPO/ecommerce-frontend:latest

# Verify pushed images
aws ecr describe-images --repository-name ecommerce-backend
aws ecr describe-images --repository-name ecommerce-frontend
```

---

### Phase 4: Deploy Application (Jenkinsfile.deploy)

**Jenkins Job Configuration:**
- Repository: Your Git repo
- Jenkinsfile: `Jenkinsfile.deploy`
- Build Parameters (See below)

**Pipeline Execution:**

```
Checkout → Configure kubectl → Validate Helm → Create Namespace 
→ Create Secrets → Dry Run → Deploy → Verify → Show URLs
```

**Build Parameters Example:**

| Parameter | Value |
|-----------|-------|
| ACTION | deploy |
| ECR_REPOSITORY | 123456789012.dkr.ecr.us-east-1.amazonaws.com |
| DOCKER_TAG | latest |
| NAMESPACE | default |
| DOMAIN | yourdomain.com |
| RDS_PASSWORD | MySecure123Pass |

**Expected Duration:** 5-10 minutes

**Outputs Generated:**
```
✅ Helm deployment successful
========================================
Access Your Application
========================================
Frontend LoadBalancer: http://ecommerce-alb-1234567.us-east-1.elb.amazonaws.com
Ingress Endpoint: http://yourdomain.com

Next Steps:
1. Monitor logs:
   kubectl logs -f deployment/ecommerce-backend -n default
   kubectl logs -f deployment/ecommerce-frontend -n default

2. Check pod status:
   kubectl get pods -n default

3. View all resources:
   kubectl get all -n default
```

---

## 🔄 Common Operations

### Update Application (New Image Version)

```bash
# Build & push new images
docker build -t ecommerce-backend:v1.2.3 ...
docker push $ECR_REPO/ecommerce-backend:v1.2.3

# Deploy with new tag
# Jenkins → Jenkinsfile.deploy → Build with Parameters:
# - ACTION: deploy
# - DOCKER_TAG: v1.2.3
```

### Rollback to Previous Version

```bash
# Jenkins → Jenkinsfile.deploy → Build with Parameters:
# - ACTION: rollback
# - NAMESPACE: default
```

### Scale Application

```bash
# Update values.yaml
helm/ecommerce/values.yaml:
  backend:
    replicaCount: 5  # Increase from 2

# OR manually apply
kubectl set replicas deployment/ecommerce-backend=5 -n default
```

### Scale Infrastructure

```bash
# Update Terraform variables
terraform/terraform.tfvars:
  eks_node_count = 5  # Increase from 3

# Jenkins → Jenkinsfile → Build with Parameters:
# - ACTION: apply
```

### Destroy Everything

```bash
# Option 1: Just uninstall application
# Jenkins → Jenkinsfile.deploy → Build with Parameters:
# - ACTION: destroy

# Option 2: Destroy entire infrastructure
# Jenkins → Jenkinsfile → Build with Parameters:
# - ACTION: destroy
```

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Account                             │
│                                                                 │
│  ┌──────────────────────────┐        ┌──────────────────────┐  │
│  │      AWS EKS Cluster     │        │   RDS MySQL (prod)   │  │
│  │                          │        │                      │  │
│  │  ┌────────────────────┐  │        │  - 20GB storage      │  │
│  │  │   Node Group (3)   │  │        │  - Multi-AZ enabled  │  │
│  │  │  - t3.medium       │  │        │  - Automated backups │  │
│  │  │  - Auto-scaling    │  │        └──────────────────────┘  │
│  │  └────────────────────┘  │                                   │
│  │                          │        ┌──────────────────────┐  │
│  │  Kubernetes Pods:        │        │  ECR Registries      │  │
│  │  ├─ backend (2-5)        │        │  ├─ ecommerce-backend│  │
│  │  └─ frontend (2-5)       │        │  └─ ecommerce-front  │  │
│  │                          │        └──────────────────────┘  │
│  │  Services:               │                                   │
│  │  ├─ backend (ClusterIP)  │        ┌──────────────────────┐  │
│  │  └─ frontend (LoadBalancer)       │  VPC Network         │  │
│  │                          │        │  - Private subnets   │  │
│  │  Storage:                │        │  - Public subnets    │  │
│  │  ├─ ConfigMaps           │        │  - NAT Gateway       │  │
│  │  └─ Secrets (RDS creds)  │        │  - Route tables      │  │
│  │                          │        └──────────────────────┘  │
│  └──────────────────────────┘                                   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           S3 + DynamoDB (Terraform State)                │  │
│  │  - ecommerce-terraform-state-us-east-1 (S3 bucket)      │  │
│  │  - ecommerce-terraform-locks (DynamoDB table)           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Jenkins CI/CD                           │
│                                                                 │
│  Pipeline 1: Jenkinsfile (Infrastructure)                      │
│  ├─ Terraform init/validate/plan/apply                         │
│  ├─ EKS cluster creation                                       │
│  ├─ RDS provisioning                                           │
│  └─ ECR repositories (auto-created)                            │
│                                                                 │
│  Pipeline 2: Jenkinsfile.deploy (Application)                  │
│  ├─ Helm chart validation                                      │
│  ├─ Kubernetes deployment                                      │
│  ├─ Service exposure                                           │
│  └─ Health verification                                        │
│                                                                 │
│  Credentials Stored:                                           │
│  ├─ AWS_ACCESS_KEY_ID (Jenkins Secret)                         │
│  ├─ AWS_SECRET_ACCESS_KEY (Jenkins Secret)                     │
│  └─ AWS_REGION (Jenkins Secret)                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Components

### Infrastructure Level (Terraform)
- ✅ VPC with private/public subnets
- ✅ NAT Gateway for secure outbound traffic
- ✅ Security Groups restricting inbound access
- ✅ EKS cluster encryption at rest
- ✅ RDS encryption, backup, and backup retention
- ✅ IAM roles with least-privilege access

### Application Level (Kubernetes/Helm)
- ✅ Non-root containers
- ✅ Read-only root filesystems
- ✅ No privilege escalation
- ✅ Dropped Linux capabilities
- ✅ Service accounts with RBAC
- ✅ Secrets encrypted in Kubernetes

### CI/CD Level (Jenkins)
- ✅ Credentials stored securely in Jenkins
- ✅ No hardcoded passwords in code
- ✅ Automatic credential injection
- ✅ Atomic deployments with rollback capability
- ✅ State locking prevents concurrent runs

---

## 📈 Monitoring & Debugging

### Monitor Infrastructure

```bash
# Check EKS cluster status
aws eks describe-cluster --name ecommerce-eks-dev

# View nodes
kubectl get nodes -o wide

# View resource usage
kubectl top nodes
kubectl top pods

# Check cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Monitor Application

```bash
# Pod status
kubectl get pods -n default -w

# Pod logs
kubectl logs -f deployment/ecommerce-backend -n default
kubectl logs -f deployment/ecommerce-frontend -n default

# Describe deployment
kubectl describe deployment ecommerce-backend -n default

# HPA status
kubectl get hpa -n default
kubectl describe hpa ecommerce-backend-hpa -n default
```

### Monitor Database (RDS)

```bash
# Check RDS instance
aws rds describe-db-instances --db-instance-identifier vicky-mysql-db

# View performance metrics in CloudWatch
# AWS Console → CloudWatch → Metrics → RDS
```

---

## 🚨 Troubleshooting Checklist

### Infrastructure Won't Deploy

```bash
# Check Terraform state
terraform state list
terraform state show 'aws_eks_cluster.main'

# Check AWS credentials
aws sts get-caller-identity

# Check Terraform logs
export TF_LOG=DEBUG
terraform plan
```

### Application Won't Deploy

```bash
# Check Helm chart
helm lint helm/ecommerce/

# Verify ECR images exist
aws ecr describe-images --repository-name ecommerce-backend

# Check kubectl access
kubectl auth can-i create deployments --as=system:serviceaccount:default:ecommerce-backend

# View pod events
kubectl describe pod <pod-name> -n default
```

### Pods in CrashLoopBackOff

```bash
# Check pod logs
kubectl logs -p <pod-name> -n default  # Previous pod logs
kubectl logs <pod-name> -n default --all-containers=true

# View pod environment
kubectl exec -it <pod-name> -n default -- env

# Check RDS connectivity
kubectl exec -it <pod-name> -n default -- nc -zv <rds-endpoint> 3306
```

### LoadBalancer IP Pending

```bash
# Check service status
kubectl get svc frontend -n default

# Check AWS load balancer
aws elbv2 describe-load-balancers

# Usually takes 1-2 minutes, wait and retry
kubectl get svc frontend -n default -w
```

---

## 📚 Key Files Reference

| File | Purpose | Modified By |
|------|---------|-------------|
| `Jenkinsfile` | Infrastructure deployment pipeline | Jenkins (Infrastructure phase) |
| `Jenkinsfile.deploy` | Application deployment pipeline | Jenkins (Deployment phase) |
| `terraform/*.tf` | AWS infrastructure definition | Terraform |
| `helm/ecommerce/Chart.yaml` | Helm chart metadata | Manual editing |
| `helm/ecommerce/values.yaml` | Default Helm values | Manual editing |
| `helm/ecommerce/templates/*` | Kubernetes manifests | Helm templating |
| `docker-compose.yml` | Local development stack | Docker Compose |
| `setup-terraform-state.sh` | State backend setup | Manual run (one-time) |

---

## ✅ Pre-Deployment Checklist

- [ ] Git repository with all code committed
- [ ] Dockerfiles for backend and frontend ready
- [ ] AWS account with appropriate permissions
- [ ] Jenkins server installed and configured
- [ ] AWS credentials stored in Jenkins
- [ ] `setup-terraform-state.sh` executed successfully
- [ ] Terraform state backend configured
- [ ] ECR repositories created
- [ ] RDS subnet groups created (if using custom)
- [ ] VPC created with public/private subnets

---

## 🎉 Success Indicators

### After Infrastructure Deployment (Jenkinsfile)

```bash
✅ terraform apply completed
✅ EKS cluster created and running
✅ RDS instance endpoint available
✅ ECR repositories exist
✅ kubectl cluster-info shows connection
```

### After Application Deployment (Jenkinsfile.deploy)

```bash
✅ Helm deployment successful
✅ Backend pods running (kubectl get pods shows RUNNING)
✅ Frontend pods running
✅ Services configured (kubectl get svc shows EXTERNAL-IP)
✅ LoadBalancer endpoint assigned
✅ Application accessible via URL
```

---

## 📞 Support Resources

- **Terraform Issues**: [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest)
- **Kubernetes Issues**: [Kubernetes Official Docs](https://kubernetes.io/docs/)
- **Helm Issues**: [Helm Docs](https://helm.sh/docs/)
- **AWS EKS Issues**: [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- **Jenkins Issues**: [Jenkins Documentation](https://www.jenkins.io/doc/)

---

## Next Actions

1. ✅ Run `setup-terraform-state.sh` to create S3 + DynamoDB
2. ✅ Configure Jenkins credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)
3. ✅ Create Jenkins pipeline job for `Jenkinsfile` (Infrastructure)
4. ✅ Execute Jenkinsfile with RDS_PASSWORD and ENVIRONMENT params
5. ✅ Wait for EKS cluster to be ready (15-20 minutes)
6. ✅ Build and push Docker images to ECR
7. ✅ Create Jenkins pipeline job for `Jenkinsfile.deploy` (Application)
8. ✅ Execute Jenkinsfile.deploy with ECR_REPOSITORY and DOCKER_TAG
9. ✅ Access application via LoadBalancer/Ingress endpoint
10. ✅ Monitor and auto-scale as needed
