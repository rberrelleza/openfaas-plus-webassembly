kind create cluster
arkade install openfaas --clusterrole --basic-auth=false --operator --pull-policy Always --wait
kubectl apply -f profile-wasi.yaml
kubectl apply -f profile-wascc.yaml
echo "port-forwarding the gateway over http://localhost:8080"
kubectl port-forward -n openfaas svc/gateway 8080:8080