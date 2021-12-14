#!/bin/bash
set -o nounset
set -o errexit

echo $'\n!! Installing ArgoCD from HELM !! \n'
helm upgrade --install \
    argocd argo/argo-cd \
    --namespace argocd \
    --create-namespace \
    --set server.ingress.hosts="{kubernetes.docker.internal}" \
    --set server.ingress.enabled=true \
    --set server.extraArgs="{--insecure}" \
    --set controller.args.appResyncPeriod=30 \
    --wait


echo $'\n##################################################################\n'

echo $'\n!! Enabling local ingress for ArgoCD !! \n'
kubectl apply -f ../argocd/ingress.yaml --wait

echo $'\n##################################################################\n'

echo $'\n!! Adding 5k-core project to ArgoCD !! \n'
kubectl apply -f ../project.yaml --wait

echo $'\n##################################################################\n'

echo $'\n!! Adding all included apps to ArgoCD !! \n'
kubectl apply -f ../apps.yaml --wait

echo $'\n##################################################################\n'

echo $'\n!! Your username is: admin !!'
echo $'!! And here\'s your password !! \n'
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo $'\n'

echo $'#####################___COMPLETED___#########################\n'
echo $'\n!! ...now go ship some cool sh*t, you rockstar !!'
