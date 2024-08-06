#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)/.."
sha256sum bootstrap-* > CHECKSUMS-sha256.txt
