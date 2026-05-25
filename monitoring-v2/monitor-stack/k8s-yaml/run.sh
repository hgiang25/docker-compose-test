#!/bin/bash

kubectl apply -f ServiceAccount.yaml
kubectl apply -f ClusterRole.yaml
kubectl apply -f ClusterRoleBinding.yaml
