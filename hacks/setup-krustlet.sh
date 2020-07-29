#!/usr/bin/env bash
rm -rf $HOME/.krustlet
/usr/local/bin/kubectl delete certificatesigningrequests.certificates.k8s.io krustletwascc krustletwascc-tls

set -e
BASEDIR=$(dirname "$0")

kubectl cluster-info --context kind-kind
bash $BASEDIR/bootstrap-krustlet.sh
export KUBECONFIG=$HOME/.krustlet/config/kubeconfig
echo -e Run  "\033[0;31mkubectl certificate approve krustletwascc-tls\033[0m" in a different terminal
#/Users/ramiro/code/krustlet/target/debug/krustlet-wascc --node-ip 10.0.0.115 --cert-file=$HOME/.krustlet/config/krustlet.crt --private-key-file=$HOME/.krustlet/config/krustlet.key --bootstrap-file=/Users/ramiro/.krustlet/config/bootstrap.conf --hostname krustletwascc
krustlet-wascc --node-ip 10.0.0.115 --cert-file=$HOME/.krustlet/config/krustlet.crt --private-key-file=$HOME/.krustlet/config/krustlet.key --bootstrap-file=/Users/ramiro/.krustlet/config/bootstrap.conf --hostname krustletwascc

