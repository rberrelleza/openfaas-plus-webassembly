build:
	cargo build --target wasm32-wasi

push:
	cargo build --target wasm32-wasi --release
	wasm-to-oci push target/wasm32-wasi/release/hello-world.wasm gcr.io/ramiro-282822/hello-webassembly:0.2

func:
	faas-cli deploy -f ../hello.yaml

rm:
	faas-cli remove -f ../hello.yaml
	kubectl delete pod -l=faas_function=hello -n=openfaas-fn