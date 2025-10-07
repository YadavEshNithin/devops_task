# Next.js Application with Docker, GitHub Actions, and Kubernetes

## Local Development

### Prerequisites
- Node.js 18+
- Docker
- Minikube
- kubectl

### Run Locally with Docker
```bash
docker build -t nextjs-app .
docker run -p 3000:3000 nextjs-app
