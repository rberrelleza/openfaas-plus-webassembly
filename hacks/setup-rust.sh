brew install rustup
rustup-init

rustup toolchain add nightly
rustup override set nightly
rustup target add wasm32-wasi

curl https://wasmtime.dev/install.sh -sSf | bash
cargo install cargo-wasi
source $HOME/.cargo/env

