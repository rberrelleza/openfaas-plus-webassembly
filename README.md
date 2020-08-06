# WebAssembly + OpenFaaS The Universal Runtime for Serverless Functions

In this PoC, we show how you can use [OpenFaaS](https://openfaas.com) and [Krustlet](https://github.com/deislabs/krustlet) to run WebAssembly functions on any Kubernetes cluster.

Why does it matter? Well, I'll be talking about this as part of the [Serverless Practitioners Summit EU 2020](https://spseu20.sched.com/event/aYpr/webassembly-openfaas-the-universal-runtime-for-serverless-functions-ramiro-berrelleza-okteto). 

See you online!

> Demo code and setup instructions based on https://github.com/deislabs/krustlet

## Requirements

1. [arkade](https://github.com/alexellis/arkade)
```
curl -sLS https://dl.get-arkade.dev | sudo sh
```

2. [kind](https://github.com/kubernetes-sigs/kind)
```
arkade get kind
```

3. OpenFaaS CLI
```
arkade get faas-cli
```

4. kubectl
```
arkade get kubectl
```

5. [Krustlet](https://github.com/deislabs/krustlet) v0.3.0
```
Download the binary from https://github.com/deislabs/krustlet/releases/tag/v0.3.0
```

## Start and Configure your Cluster

```
kind create cluster
```

Since this is an experiment, I'm using kind as my cluster. This allows me to create and tear down my cluster almost instantly, in case somethign goes wrong. That being said, this works on any Kubernetes cluster. Take a look at Krustlet's [installation instructions](https://github.com/deislabs/krustlet/blob/master/docs/intro/install.md) for more info on this.

## Start your Krustlet Node

[Krustlet](https://github.com/deislabs/krustlet) is a tool to run WebAssembly workloads natively on Kubernetes. Krustlet acts like a node in your Kubernetes cluster. When a user schedules a Pod with certain node tolerations, the Kubernetes API will schedule that workload to a Krustlet node, which will then fetch the module and run it. We'll be using Krustlet to run our WebAssembly functions.

Open a second terminal window, and activate your kind's cluster Kubeconfig context.

```
kubectl cluster-info --context kind-kind
```

Clone the repository:
```
git clone https://github.com/rberrelleza/openfaas-plus-webassembly
```

Now, run the bootstrap script. This will create all the configurations and keys needed to be able to register the Krustlet node with your cluster.

```
./hacks/bootstrap-krustlet.sh
```

Set your context to the Krustlet's KUBECONFIG.
```
export KUBECONFIG=$HOME/.krustlet/config/kubeconfig
```

Get your local machine's IP (in my case, en0):
```
ifconfig en0
```

And finally, start the Krustlet.
```
krustlet-wascc --node-ip $IP --cert-file=$HOME/.krustlet/config/krustlet.crt --private-key-file=$HOME/.krustlet/config/krustlet.key --bootstrap-file=$HOME/.krustlet/config/bootstrap.conf --hostname krustlet
```

> We are using `krustlet-wascc` so we can leverage its networking capabilities. At the time of writing, `krustlet-wasi` was not able to open a network socket.

When the Krustlet starts, it won't long anything. It is waiting for a certificate to be approved on your cluster. To do it, go back to the terminal where you started the cluster, and run:

```
kubectl certificate approve krustlet-tls
```

Once the certificate is approved, you'll see the Krustlet start logging. 

## Install OpenFaaS

For this experiment, we are going to install [OpenFaaS](https://www.openfaas.com/) using [arkade](https://github.com/alexellis/arkade). We are going to set it without authentication to keep things simple. Don't do this in prod ;)

```
arkade install openfaas --clusterrole --basic-auth=false --operator --pull-policy Always --set serviceType=ClusterIP --wait 
kubectl port-forward -n openfaas svc/gateway 8000:8080
```

### Add the WasCC profile

With Krustlet, we now have a cluster that can handle both container as well as WebAssembly-based workloads. In order to tell OpenFaaS to schedule our WebAssembly functions in the Krustlet, we are going to use OpenFaaS' brand new [profiles feature](https://docs.openfaas.com/reference/profiles/). 

A profile is  way of injecting platform-specific information to OpenFaaS functions. In this, case are going to use it to set the tolerations and taints required to ensure that the function runs in the Krustlet, instead of on a regular node. 

```
kind: Profile
apiVersion: openfaas.com/v1
metadata:
  name: wascc
  namespace: openfaas
spec:
    tolerations:
    - key: "node.kubernetes.io/network-unavailable"
      operator: "Exists"
      effect: "NoSchedule"
    - key: "krustlet/arch"
      operator: "Equal"
      value: "wasm32-wascc"
      effect: "NoExecute"
```

Create the profile by running the command below:

```
kubectl apply -f hacks/profile-wascc.yaml
```

## Run the WebAssembly Function

To create the function, we are going to use the following OpenFaaS manifest:

```
provider:
  name: openfaas
  gateway: http://127.0.0.1:8000

functions:
  hello-world:
    image: webassembly.azurecr.io/greet-wascc:v0.5
    annotations:
      com.openfaas.profile: wascc
      com.openfaas.health.http.path: "/"
```

There's two big things to notice here:
- The `image` field points to a registry, just as if it was a container! WebAssemblies can be pushed and pulled from an OCI-compliant registry, allowing us to reuse a well-known distribution channel. For this case, we are using one of the pre-existing demos.
- The `com.openfaas.profile: wascc` annotation. This is what tells OpenFaaS to attach the profile we created earlier to our function, which in turn tells Kubernetes to place the workload in the Krustlet (composition ftw!)

We run the usual `deploy` command to deploy our function:
```
faas-cli deploy -f hello/hello.yaml
```

After a few seconds, the function will be up and running. You can check its state by running:

```
kubectl get pods -n=openfaas-fn
```

Finally, let's call the function, to see everything working end to end. 

```
curl http://localhost:8080
```

```
$ Hello, world!
```

> We are using `curl` instead of `faas-cli invoke` due to [current limitations](https://github.com/deislabs/krustlet/issues/293) in Kruslet's networking implementation. This should be fixed in the near future.

## Conclusion

This PoC shows how it is possible to use Krustlet, Kubernetes and OpenFaaS to to build and deploy WebAssembly-based functions. 

Writing functions using WebAssembly brings us several benefits, such as:
1. The resulting binary is smaller, which results in faster pulls, and faster cold starts.
1. We can write functions on any language, and compile them to a common target/platform, without the need of containers.
1. WebAssembly's sandbox promises better safety and isolation features.
1. The same binary will work on any platform, from clusters to smaller edge devices.
1. waSCC Actor SDK gives us some of the  abstractions that OpenFaaS' watchdog, specially around not having to deal with HTTP listener mechanics.

On the other side, OpenFaaS lets us build, publish, deploy and scale up/down our WebAssembly functions just as easily as container-based ones. And we can do it on any Kubernetes cluster. 

It is true that there are certain limitations, but it's only a matter of time before they get implemented/fixed. As the Krustlet project matures, a lot of the challenges I encountered will simple go away:

1. Functions have a fixed port, and are only available through the Node IP, since Krustlet hasn't implemented the full Kubernetes network stack
1. I have to use a public repository, since Krustlet doesn't support pull secrets
1. Building the wascc sample requires complex key management and signing binaries. And there's no way (today) for Krustlet to handle this dynamically.
1. Building wascc assemblies and getting them to run in Krustlet is still a bit of a dark art

Interested in collaborating on this experiment? [Let's talk!](https://twitter.com/rberrelleza).

