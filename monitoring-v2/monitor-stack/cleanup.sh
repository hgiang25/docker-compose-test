#!/bin/bash

# Thiết lập màu sắc để dễ theo dõi
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Cleanup K8s Resources...${NC}"

# 1. Xóa App và Service (Cẩn thận với service kubernetes mặc định)
echo "Step 1: Deleting App resources..."
# Lưu ý: Thường không nên xóa service 'kubernetes' vì nó là service hệ thống của K8s
kubectl delete deploy pandacloud-app --ignore-not-found
kubectl delete svc pandacloud-app --ignore-not-found

# 2. Xóa ArgoCD
echo "Step 2: Deleting ArgoCD installation..."
kubectl delete -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --ignore-not-found || true
kubectl delete namespace argocd --ignore-not-found

# 3. Gỡ cài đặt Helm Prometheus
echo "Step 3: Uninstalling Helm releases..."
if helm list -n prometheus | grep -q "stable"; then
    helm uninstall stable -n prometheus
else
    echo "No helm release found in namespace prometheus."
fi

# 4. Xóa Namespace Prometheus
echo "Step 4: Deleting namespace prometheus..."
kubectl delete namespace prometheus --ignore-not-found

# 5. Xóa Helm Repos
echo "Step 5: Removing Helm repositories..."
helm repo remove stable 2>/dev/null || true
helm repo remove prometheus-community 2>/dev/null || true

echo -e "${GREEN}Cleanup Completed!${NC}"
