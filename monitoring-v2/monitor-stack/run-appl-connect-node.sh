#!/bin/bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
  -n prometheus \
  -f ./values-central.yaml
