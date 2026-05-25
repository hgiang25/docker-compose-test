#!/bin/bash
kubectl -n kube-system create token prometheus-sa > token
