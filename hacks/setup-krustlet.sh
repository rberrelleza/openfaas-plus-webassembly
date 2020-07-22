set -e

kubectl cluster-info --context kind-kind
bash bootstrap-krustlet.sh
export KUBECONFIG=$HOME/.krustlet/config/kubeconfig
hostname="krustletwascc"
echo Run  "kubectl certificate approve $hostname" in a different terminal
krustlet-wascc --node-ip 10.0.0.115 --cert-file=$HOME/.krustlet/config/krustlet.crt --private-key-file=$HOME/.krustlet/config/krustlet.key --bootstrap-file=/Users/ramiro/.krustlet/config/bootstrap.conf --hostname $hostname