#!/bin/bash
set -o nounset
set -o errexit

echo $'\n!! I NUKE ARGO APPS FOR YOU !! \n'
kubectl delete -f ../apps.yaml --wait

echo $'\n!! I NUKE ARGO PROJECT FOR YOU !! \n'
kubectl delete -f ../project.yaml --wait

echo $'\n!! I NUKE ARGO NAMESPACE FOR YOU !! \n'
kubectl delete namespaces argocd --wait

echo $'#####################___COMPLETED___#########################\n'
echo $'\n!! ALL TRACES OF ARGOCD SUCCESSFULLY NUKED !! \n'