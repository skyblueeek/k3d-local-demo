# K3D-Local Space

```

# install the things you need
brew install k3d helm argocd k9s kail

# install helm charts for stuff you need
helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add elastic https://helm.elastic.co
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo add fluxcd https://charts.fluxcd.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add kubevela https://charts.kubevela.net/core

# update helm repos you added
helm repo update

# create local k3s cluster via k3d
k3d cluster create --config k3d_local.yml --verbose

# check cluster and status
k9s

# install "base" for cluster

# install cert-manager
helm upgrade --install \
    cert-manager \
    jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true\
    --wait

# install, configure, and prepare ArgoCD (yes, it's a terrible BASH script...)
./scripts/argo_provision.sh

# go grab your AWS credentials - Key ID and Secret Key

cp aws-creds.conf.example aws-creds.conf

# Add your API keys to the new conf file
# THEN --> 
# generate a "sealed secret" for your aws credentials

./scripts/secrets_generate_aws_creds.sh

# This generates/regenerates a sealed-secret in /crossplane/configs/config-aws-creds.yaml

# Add safely-sealed secrets and push to git
git add crossplane/configs/config-aws-creds.yaml
git commit -m "secrets(aws): Generate AWS sealed secrets
git push

# access Argo UI in browser
# WE ASSUME that YOU are on a Mac, and you have the following in /etc/hosts (of your macbook) --> 127.0.0.1 kubernetes.docker.internal

https://kubernetes.docker.internal


```

Workflow:

project.yaml defines your "project"

apps.yaml is your "app of apps"

apps/5k-core is where your apps are defined

core-clusters.yaml creates the ArgoCD "app" for all deployed clusters

deployments/core-clusters/* is where you drop off your "claim" for a cluster

Therefore, to create a new cluster, just copy ops-arostamian1.yaml to a new file

example: ops-jefferson-airplane.yaml

THEN, in that NEW file, edit:
`metadata --> name --> <yourclustername>`
`spec --> id --> <yourclustername>`

git add .

git commit

git push

Go back to Argo, click into the "core-clusters" app, and look for your new cluster to spin up in AWS...it will take a LONG while (due to AWS EKS being very slow, not ArgoCD)