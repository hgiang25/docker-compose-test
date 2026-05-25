#!/bin/bash

# 1. Thêm Repo
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

# 2. Kiểm tra và Tạo Namespace
NAMESPACE="prometheus"
if kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
    echo "Namespace $NAMESPACE already exists. Upgrading..."
    # Nâng cấp nếu đã tồn tại
    helm upgrade stable prometheus-community/kube-prometheus-stack -n $NAMESPACE
else
    echo "Creating namespace $NAMESPACE and installing..."
    kubectl create namespace $NAMESPACE
    # Cài đặt mới
    helm install stable prometheus-community/kube-prometheus-stack -n $NAMESPACE
fi

# 3. Chuyển Service sang LoadBalancer (Để truy cập từ trình duyệt)
echo "Patching services to LoadBalancer..."
kubectl patch svc stable-kube-prometheus-sta-prometheus -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch svc stable-grafana -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'

echo "Done! Hãy đợi vài phút để các Pod khởi tạo xong."
