#!/usr/bin/env bash

scripts_dir="$(cd "$(dirname "$0")" && pwd)"

for architecture in aarch64 arm i686 x86_64; do
    "$scripts_dir/build-bootstrap.sh" $architecture
done

"$scripts_dir/generate-checksums.sh"
