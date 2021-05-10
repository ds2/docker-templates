#!/usr/bin/env bash

CNT=$(ps -e | grep "Runner.Listener" | wc -l)

[[ $CNT -gt 0 ]] || exit 1
