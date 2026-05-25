#!/bin/bash

kubectl apply -f service-account.yml
kubectl apply -f role-base-service-account.yml

Lai CA
#kubectl config view --raw
#

#Lai Token
#./generate-token-base-service-account.sh
