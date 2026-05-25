#!/bin/bash
#kubectl create secret generic additional-scrape-configs \
 # --from-file=dev-scrape.yaml \
  #-n prometheus
  
kubectl delete secret additional-scrape-configs -n prometheus

kubectl create secret generic additional-scrape-configs \
  --from-file=dev-scrape.yaml \
  -n prometheus
  
#kubectl apply -f expose-endpont-metric.yaml
