#!/usr/bin/env bash

scripts_dir="$(cd "$(dirname "$0")" && pwd)"

create_prefix() {
  rm -rf $TERMUX_PREFIX
  cp -r "$scripts_dir"/../root $TERMUX_PREFIX
}

build_packages() {
  for base_pkgs in ncurses readline bash nano; do
    "$scripts_dir/../packages/${base_pkgs}/build.sh"
  done
}

reduce_size() {
  cd $TERMUX_PREFIX
  for library in $(find ./lib -name "*.a" -o -name "*.so*"); do
    llvm-strip --strip-unneeded $library
  done
  for binary in $(find ./bin); do
    file $binary | grep "not stripped" >/dev/null
    if [ $? -eq 0 ]; then
      llvm-strip --strip-unneeded $binary
    fi
  done
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

generate_checksums() {
  cd "$scripts_dir/.."
  sha256sum bootstrap-* > CHECKSUMS-sha256.txt
}

main() {
  create_prefix
  build_packages
  reduce_size
  generate_bootstrap
  generate_checksums
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
  all )
    for architecture in aarch64 arm i686 x86_64; do
      export architecture=$architecture; main
    done
  * )
    echo "Usage:"
    echo "  build-bootstrap.sh aarch64|arm|i686|x86_64|all"
    ;;
esac
