kind create cluster
arkade install openfaas --clusterrole --basic-auth=false --operator --pull-policy Always

kubectl apply -f crd.yaml
kubectl apply -f rbac.yaml

kubectl port-forward -n openfaas svc/gateway 8080:8080 > /dev/null 2>&1