#!/usr/bin/env bash

scripts_dir="$(cd "$(dirname "$0")" && pwd)"

create_prefix() {
    rm -rf $TERMUX_PREFIX
    cp -r "$scripts_dir"/../root $TERMUX_PREFIX
}

build_packages() {
    "$scripts_dir/../packages/ncurses/build.sh"
    "$scripts_dir/../packages/readline/build.sh"
    "$scripts_dir/../packages/nano/build.sh"
    "$scripts_dir/../packages/bash/build.sh"
}

generate_bootstrap() {
    cd $TERMUX_PREFIX
    while read -r -d '' link; do
        echo "$(readlink "$link")←${link}" >> SYMLINKS.txt
        rm -f "$link"
    done < <(find . -type l -print0)

    zip -r9 "bootstrap-${architecture}.zip" ./*
    mv "bootstrap-${architecture}.zip" "$scripts_dir/.."
}

main() {
    create_prefix
    build_packages
    generate_bootstrap
}

export TERMUX_PREFIX=/data/data/com.jzinferno.termux/files/usr

case "$1" in
  aarch64 )
    export architecture=aarch64; main
    ;;
  arm )
    export architecture=arm; main
    ;;
  i686 )
    export architecture=i686; main
    ;;
  x86_64 )
    export architecture=x86_64; main
    ;;
  * )
    echo "Usage:"
    echo "  build-bootstrap.sh aarch64|arm|i686|x86_64"
    ;;
esac
