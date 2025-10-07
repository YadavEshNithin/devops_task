# DevOps Internship Assessment: Next.js Application Deployment

## 📋 Project Overview

This project demonstrates a complete DevOps workflow for containerizing and deploying a Next.js application using Docker, GitHub Actions, and Kubernetes (Minikube) as per the internship assessment requirements.

**Assessment Title**: Containerize and Deploy a Next.js Application using Docker, GitHub Actions, and Minikube

---

## 🎯 Objective Successfully Demonstrated

✅ **Containerize a Next.js application using Docker**  
✅ **Automate build and image push using GitHub Actions and GitHub Container Registry (GHCR)**  
✅ **Deploy the containerized app to Kubernetes (Minikube) using manifests**

---

## 📁 Project Structure

```
travel_ui_ux/
├── .github/
│   └── workflows/
│       └── dockerbuild.yaml          # GitHub Actions CI/CD workflow
├── k8s/
│   ├── deployment.yaml               # Kubernetes deployment with replicas & health checks
│   ├── service.yaml                  # Kubernetes service to expose application
│   └── namespace.yaml                # Kubernetes namespace (optional)
├── Dockerfile                        # Docker containerization with best practices
├── next.config.js
├── package.json
├── public/
├── src/
└── README.md
```

---

## 🐳 Requirement 1: Next.js Application

A simple Next.js starter template application has been created and is fully functional.

### Application Details
- **Framework**: Next.js
- **Port**: 3000
- **Status**: ✅ Completed

---

## 🐳 Requirement 2: Docker Containerization with Best Practices

### Dockerfile
```
# syntax=docker/dockerfile:1

# Stage 1: Builder
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY *.js ./

# Install dependencies
RUN npm ci

# Copy app and build
COPY . .
RUN npm run build

# Stage 2: Production  
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001

# Copy only production essentials
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
COPY --from=builder --chown=appuser:appgroup /app/.next ./.next
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules

# Copy necessary config files
COPY --from=builder --chown=appuser:appgroup /app/next.config.js ./

USER appuser

EXPOSE 3000

CMD ["npm", "start"]

```

### Best Practices Implemented
✅ Multi-stage build to reduce image size  
✅ Non-root user for security  
✅ Minimal base image (Alpine Linux)  
✅ Proper layer caching  
✅ Explicit port exposure  
 

### Local Docker Commands
```bash
# Build Docker image
docker build -t nextjs-app .

# Run container locally
docker run -p 3000:3000 nextjs-app

# Test application
curl http://localhost:3000
```

---

## ⚙️ Requirement 3: GitHub Actions & GHCR Automation

### GitHub Actions Workflow (.github/workflows/dockerbuild.yaml)
```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  docker:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            ghcr.io/yadaveshnithin/devops-task:latest
            ghcr.io/yadaveshnithin/devops-task:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### GitHub Actions Features
✅ **Trigger**: On push to main branch  
✅ **Image Registry**: GitHub Container Registry (GHCR)  
✅ **Image Tagging**: `latest` and Git SHA tags  
✅ **Multi-architecture**: linux/amd64, linux/arm64  
✅ **Build Caching**: GitHub Actions cache for performance  

### GHCR Image URL
```
ghcr.io/yadaveshnithin/devops-task:latest
```

---

## ☸️ Requirement 4: Kubernetes Manifests

### k8s/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextjs-app
  labels:
    app: nextjs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nextjs-app
  template:
    metadata:
      labels:
        app: nextjs-app
    spec:
      containers:
      - name: nextjs-app
        image: ghcr.io/yadaveshnithin/devops-task:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 1
```

### k8s/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nextjs-service
spec:
  selector:
    app: nextjs-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

### Kubernetes Features Implemented
✅ **Replicas**: 3 instances for high availability  
✅ **Health Checks**: Liveness and readiness probes  
✅ **Resource Management**: CPU and memory limits/requests  
✅ **Service Exposure**: LoadBalancer service type  
✅ **Proper Networking**: Port 80 → 3000 mapping  

---

## 🚀 Requirement 5: Setup & Deployment Documentation

### Prerequisites
- **Node.js** 18+
- **Docker** & Docker Desktop
- **Minikube**
- **kubectl**

### Local Development

#### Run with Node.js
```bash
npm install
npm run dev
# Access: http://localhost:3000
```

#### Run with Docker
```bash
docker build -t nextjs-app .
docker run -p 3000:3000 nextjs-app
# Access: http://localhost:3000
```

### Minikube Deployment Steps

#### 1. Start Minikube Cluster
```bash
minikube start --driver=docker
```

#### 2. Verify Cluster Status
```bash
minikube status
kubectl get nodes
```

#### 3. Deploy Application
```bash
kubectl apply -f k8s/
```

#### 4. Verify Deployment
```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

Expected Output:
```
NAME                          READY   STATUS    RESTARTS   AGE
nextjs-app-59449876f8-9n8t2   1/1     Running   0          64s
nextjs-app-59449876f8-n8hnr   1/1     Running   0          64s
nextjs-app-59449876f8-q9t4x   1/1     Running   0          64s
```

### Access the Deployed Application

#### Method 1: Get Service URL
```bash
minikube service nextjs-service --url
# Returns: http://192.168.49.2:30000
```

#### Method 2: Open Directly in Browser
```bash
minikube service nextjs-service
```

#### Method 3: Port Forwarding
```bash
kubectl port-forward service/nextjs-service 8080:80
# Access: http://localhost:8080
```

### Management Commands

#### Monitoring
```bash
# View all resources
kubectl get all

# Check pod logs
kubectl logs -f deployment/nextjs-app

# View detailed information
kubectl describe deployment nextjs-app
```

#### Scaling
```bash
# Scale up
kubectl scale deployment nextjs-app --replicas=5

# Scale down
kubectl scale deployment nextjs-app --replicas=2
```

#### Cleanup
```bash
# Delete deployment
kubectl delete -f k8s/

# Stop Minikube
minikube stop

# Delete cluster
minikube delete
```

---

## 📧 Submission Details

### Repository Information
- **Repository URL**: `https://github.com/yadaveshnithin/devops-assessment`
- **Public Repository**: ✅ Yes

### GHCR Image Information
- **GHCR Image URL**: `ghcr.io/yadaveshnithin/devops-task:latest`


## 🔗 Important Links

- **GitHub Repository**: `https://github.com/YadavEshNithin/devops_task`
- **GHCR Image URL**: `ghcr.io/yadaveshnithin/devops-task:latest`
- **GHCR Package**: `https://github.com/yadaveshnithin?tab=packages`


---

**🎉 Assessment Successfully Completed!** All requirements have been implemented and verified. The Nextjs application is containerized, automated with Github-Actions CI/CD, and successfully deployed to Kubernetes via Minikube.
