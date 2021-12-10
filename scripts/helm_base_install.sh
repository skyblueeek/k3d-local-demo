#!/bin/bash
set -o nounset
set -o errexit

# Set up HELM repos
echo !! ADDING HELM REPOS !!
helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add elastic https://helm.elastic.co
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo add fluxcd https://charts.fluxcd.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add kubevela https://charts.kubevela.net/core

echo !! Updating HELM REPOS !!
helm repo update

echo !! INSTALLING DAY-ZERO SERVICES !!

# Cert manager
echo INSTALLING CERT MANAGER
helm upgrade --install \
    cert-manager \
    jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true

# Sealed Secrets
echo INSTALLING SEALED SECRETS
helm upgrade --install \
    --namespace kube-system \
    --create-namespace \
    sealed-secrets-controller \
    sealed-secrets/sealed-secrets

echo INSTALLING ARGOCD
helm upgrade --install \
    argocd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --set server.ingress.hosts="{kubernetes.docker.internal, argo-cd.76.234.234.104.nip.io}" \
    --set server.ingress.enabled=true \
    --set server.extraArgs="{--insecure}" \
    --set controller.args.appResyncPeriod=30 \
    --wait