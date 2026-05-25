#!/bin/bash


helm uninstall agent -n monitoring
helm  upgrade --install agent kube-prometheus-stack \
  -n monitoring --create-namespace -f values-dev.yaml



