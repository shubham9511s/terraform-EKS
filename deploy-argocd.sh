#!/bin/bash

set -e

# Export the AWS region
#export AWS_REGION="eu-north-1"
#export CLUSTER_NAME="my-cluster"

# Get the EKS cluster details
aws eks update-kubeconfig --name mycluster --region eu-north-1

# Create the Argo CD namespace
kubectl create namespace argocd || true

# Apply the Argo CD manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD server to be ready
kubectl rollout status deployment argocd-server -n argocd

# Print the Argo CD server URL
kubectl get svc argocd-server -n argocd
