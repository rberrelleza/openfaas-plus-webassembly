kubectl cluster-info --context kind-kind
bash <(curl https://raw.githubusercontent.com/deislabs/krustlet/master/docs/howto/assets/bootstrap.sh) 
export KUBECONFIG=$HOME/.krustlet/config/kubeconfig
echo Run  "kubectl certificate approve krustlet-tls" in a different terminal
krustlet-wasi --node-ip 10.0.0.115 --cert-file=$HOME/.krustlet/config/krustlet.crt --private-key-file=$HOME/.krustlet/config/krustlet.key --bootstrap-file=/Users/ramiro/.krustlet/config/bootstrap.conf --hostname krustlet