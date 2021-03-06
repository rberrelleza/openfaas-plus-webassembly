## Development Guide

Follow this if you want to build the sample yourself

### Requirements

You can start a [remote development environment](https://github.com/okteto/okteto) with everything installed by running:

```
okteto up --deploy
```

If you want to do it the hard way:

1. Rust, rustup and cargo
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. [NKeys](https://wascc.dev/tutorials/first-actor/sign_module/)
```
cargo install nkeys --features "cli"
```

3. [wasm-to-oci](https://github.com/engineerd/wasm-to-oci)
```
Download the binary from https://github.com/engineerd/wasm-to-oci/releases/tag/v0.1.1
```

4. [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)
```
cargo install wasm-pack
```

5. [wascapp](https://github.com/wascc/wascap)
```
cargo install wascap --features "cli"
```

6. [A GKE container registry with anonymous pull access](https://cloud.google.com/container-registry)
> You can also use your own registry here. 
