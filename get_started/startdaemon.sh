#!/bin/bash

sudo rm -f /tmp/firecracker.socket
../build/cargo_target/aarch64-unknown-linux-musl/debug/firecracker --api-sock /tmp/firecracker.socket
