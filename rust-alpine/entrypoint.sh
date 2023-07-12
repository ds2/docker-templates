#!/usr/bin/env zsh

set -euo pipefail #e=exitonfail u=unboundvarsdisallow o=pipefail x=debug

whoami

echo "My path is actually: ${PATH}"

export CARGO_HOME=${CARGO_HOME:-/home/rusty/.cargo}
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-'x86_64-unknown-linux-gnu'}
export CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-target}
export PERFORM_RUSTUP_UPDATE=${PERFORM_RUSTUP_UPDATE:-0}

if [ "${CARGO_HOME}" != "/home/rusty/.cargo" ]; then
    echo "Alternate cargo home detected: $CARGO_HOME"
    echo "Copying existing cargo bins from ~/.cargo/bin/ to new CARGO_HOME at $CARGO_HOME/bin/.."
    sudo install -d -o rusty $CARGO_HOME
    sudo install -d -o rusty $CARGO_HOME/bin
    cp ~/.cargo/bin/* $CARGO_HOME/bin/
else
    echo "Reusing default cargo home :)"
fi

echo "Resetting PATHs.."
export PATH=$CARGO_HOME/bin:$PATH
export PATH=$PATH:$HOME/.local/bin

if [ $PERFORM_RUSTUP_UPDATE -eq 1 ]; then
    echo "Performing rustup update.."
    rm $CARGO_HOME/bin/rustfmt
    rm $CARGO_HOME/bin/cargo-fmt
    rustup update stable
fi

cargo --version

echo "Alright. Good luck now :D"
exec "$@"
