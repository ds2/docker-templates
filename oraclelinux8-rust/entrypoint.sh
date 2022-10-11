#!/usr/bin/env zsh

source ~/.cargo/env

rustup update

exec "$@"
