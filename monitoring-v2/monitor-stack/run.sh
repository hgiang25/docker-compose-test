#!/bin/bash
set -e

NAMESPACE=prometheus

# Create namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install / Upgrade
helm upgrade --install monitoring kube-prometheus-stack \
  -n $NAMESPACE \

