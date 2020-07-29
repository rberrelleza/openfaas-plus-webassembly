kubectl cluster-info --context kind-kind
arkade install openfaas --clusterrole --basic-auth=false --operator --pull-policy Always --set serviceType=ClusterIP --wait 
BASEDIR=$(dirname "$0")
kubectl apply -f $BASEDIR/profile-wascc.yaml
echo "port-forwarding the gateway over http://localhost:8000"
kubectl port-forward -n openfaas svc/gateway 8000:8080