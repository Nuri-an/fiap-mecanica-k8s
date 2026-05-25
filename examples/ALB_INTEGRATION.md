# ALB Integration with EKS

This directory contains examples for integrating the internal Application Load Balancer (ALB) with your EKS cluster.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     API Gateway (HTTP)                       │
│              (module apigateway)                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ VPC Link
                         │
┌────────────────────────▼────────────────────────────────────┐
│              Internal ALB Listener                           │
│          (created in networking module)                      │
│          - Listens on port 80 in private subnets             │
│          - ARN exported as backend_listener_arn              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ Routing Rules
                         │
┌────────────────────────▼────────────────────────────────────┐
│           EKS Cluster (Kubernetes)                           │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  AWS Load Balancer Controller                           │  │
│  │  - Installed via Helm                                   │  │
│  │  - Uses IRSA (IAM Role for Service Accounts)            │  │
│  │  - Watches for Ingress resources                        │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                          │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │  Ingress Resource (Kubernetes)                        │  │
│  │  - Routes traffic to Services                         │  │
│  │  - Automatically registers pods as ALB targets        │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                          │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │  Service (NodePort)                                  │  │
│  │  - Exposes pod ports on node ports                   │  │
│  └──────────────┬───────────────────────────────────────┘  │
│                 │                                          │
│  ┌──────────────▼───────────────────────────────────────┐  │
│  │  Pods / Deployment                                   │  │
│  │  - Your application containers                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Components

### 1. Internal ALB (created by Terraform in `networking` module)

- **Name**: `{project_name}-{environment}-internal-alb`
- **Location**: Private subnets of the VPC
- **Listener**: Port 80 HTTP
- **Target Group**: Routes to EKS nodes on their NodePort

### 2. AWS Load Balancer Controller (installed by Terraform in `eks` module)

The controller is automatically deployed via Helm chart and provides:

- **Automatic Ingress Management**: Watches for Kubernetes `Ingress` resources
- **Target Registration**: Automatically registers/deregisters pods as ALB targets
- **Security Group Management**: Creates and manages security groups as needed
- **IAM Integration**: Uses IRSA (IAM Roles for Service Accounts) for AWS API access

### 3. Kubernetes Ingress Resources

Define routing rules and map traffic to your Services.

## Files

- `alb-ingress-example.yaml`: Example Ingress resource and Service configuration

## How to Deploy Your Application

### Step 1: Deploy your application to EKS

```bash
kubectl apply -f your-deployment.yaml
```

### Step 2: Create a Service to expose your deployment

```bash
kubectl apply -f your-service.yaml
```

Example Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
    - port: 3000
      targetPort: 3000
```

### Step 3: Create an Ingress resource

```bash
kubectl apply -f your-ingress.yaml
```

Example Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/load-balancer-name: 'fiap-mecanica-dev-internal-alb'
    alb.ingress.kubernetes.io/target-type: instance
spec:
  rules:
    - host: backend.internal
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 3000
```

## Verification

### Check AWS Load Balancer Controller deployment

```bash
# Check if the controller is running
kubectl get deployment -n kube-system aws-load-balancer-controller

# Check logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### Check Ingress status

```bash
# Get all ingress resources
kubectl get ingress

# Get detailed ingress information
kubectl describe ingress my-app-ingress
```

### Check ALB in AWS Console

1. Go to EC2 → Load Balancers
2. Find `{project_name}-{environment}-internal-alb`
3. Check:
   - Listener rules
   - Target group
   - Registered targets (should show your pod IPs)
   - Health status

## Troubleshooting

### Ingress not getting load balancer

Check controller logs:

```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### Targets showing as unhealthy

- Verify health check path in Ingress annotations
- Check security groups allow traffic from ALB to nodes
- Verify application is responding to health checks

### Connection refused from API Gateway

- Verify VPC Link is active
- Check ALB listener ARN in API Gateway integration
- Verify security group rules allow traffic

## Important Notes

- The internal ALB is created in **private subnets** only
- It's only accessible within the VPC
- Pods must be registered as targets for traffic to flow
- The AWS Load Balancer Controller handles all ALB management automatically
- Changes to Ingress resources are reflected in the ALB within seconds
