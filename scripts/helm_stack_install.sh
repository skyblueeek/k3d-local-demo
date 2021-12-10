#!/bin/bash
set -o nounset
set -o errexit

echo !! Updating HELM REPOS !!
helm repo update

# ElasticSearch
echo INSTALLING ELASTICSEARCH
helm upgrade --install \
    elasticsearch \
    elastic/elasticsearch \
    --namespace core-v6 \
    --create-namespace \
    --debug

# Redis
echo INSTALLING REDIS
helm upgrade --install \
    redis-ha \
    bitnami/redis \
    --namespace core-v6 \
    --create-namespace \
    --values ../deploys/local-sentinel.yml \
    --debug

# Rabbit
echo INSTALLING RABBIT
helm upgrade --install \
    rabbitmq-cluster-operator \
    bitnami/rabbitmq-cluster-operator \
    --namespace core-v6 \
    --create-namespace \
    --debug

# MariaDB
echo INSTALLING MARIADB
helm upgrade --install \
    mysql-mariadb \
    bitnami/mariadb \
    --create-namespace \
    --namespace core-v6 \
    --debug

helm upgrade --install crossplane --create-namespace --namespace crossplane-system crossplane-stable/crossplane


helm upgrade --install \
    argocd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --set server.containerPort=8088
    --set server.ingress.hosts="kubernetes.docker.internal" \
    --set server.ingress.enabled=true \
    --set server.extraArgs="{--insecure}" \
    --set controller.args.appResyncPeriod=30 \
    --wait