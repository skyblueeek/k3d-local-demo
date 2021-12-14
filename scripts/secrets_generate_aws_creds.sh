#!/bin/bash
set -o nounset
set -o errexit

kubectl --namespace argocd \
    create secret generic aws-creds \
    --from-file creds=./aws-creds.conf \
    --output json \
    --dry-run=client \
    | kubeseal \
    --controller-namespace argocd \
    --controller-name sealed-secrets \
    --format yaml \
    | tee crossplane/configs/config-aws-creds.yaml

echo $'\n##################################################################\n'
echo $'#####################___COMPLETED___#########################\n'
echo $'\n!! Generated new sealed-secrets. Please check them in to git for them to work !! \n'