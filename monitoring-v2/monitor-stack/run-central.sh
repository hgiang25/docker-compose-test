#!/bin/bash

helm upgrade --install monitoring kube-prometheus-stack \
  -n prometheus \
  --create-namespace \
  -f values-central.yaml
  
 #kubectl apply -f prometheus-nodeport.yaml

# helm upgrade --install agent prometheus-community/kube-prometheus-stack -n monitoring -f values-dev.yaml