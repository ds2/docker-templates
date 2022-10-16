#!/usr/bin/env zsh

echo "My path is actually: ${PATH}"

export CARGO_HOME=${CARGO_HOME:-/home/rusty/.cargo}
export SRC_DIR=${SRC_DIR:-/work}
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-'x86_64-unknown-linux-gnu'}
export CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-/tmp/rust-stuff}

if [ "${CARGO_HOME}" != "/home/rusty/.cargo" ]; then
    echo "Copying existing cargo bins from ~/.cargo/bin/ to new CARGO_HOME at $CARGO_HOME/bin/"
    mkdir -p $CARGO_HOME/bin
    cp ~/.cargo/bin/* $CARGO_HOME/bin/
else
    echo "Reusing default cargo home :)"
fi

echo "Resetting PATHs.."
export PATH=$CARGO_HOME/bin:$PATH

echo "Doing rust update.."
rustup update || true
echo "Alright. Good luck now :D"
exec "$@"
