#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f libuv-v1.48.0.tar.gz ]; then
  wget https://dist.libuv.org/dist/v1.48.0/libuv-v1.48.0.tar.gz
fi
rm -rf libuv-v1.48.0; tar -xf libuv-v1.48.0.tar.gz; cd libuv-v1.48.0

patch -p1 < ../patches/libuv.patch

case $architecture in
  aarch64 )
    export CC=aarch64-linux-android24-clang
    export CXX=aarch64-linux-android24-clang++
    export HOST=aarch64-linux-android
    ;;
  arm )
    export CC=armv7a-linux-androideabi24-clang
    export CXX=armv7a-linux-androideabi24-clang++
    export HOST=arm-linux-androideabi
    ;;
  i686 )
    export CC=i686-linux-android24-clang
    export CXX=i686-linux-android24-clang++
    export HOST=i686-linux-android
    ;;
  x86_64 )
    export CC=x86_64-linux-android24-clang
    export CXX=x86_64-linux-android24-clang++
    export HOST=x86_64-linux-android
    ;;
  * )
    exit 1
    ;;
esac

export STRIP=llvm-strip
export AR=llvm-ar
export AS=$CC
export LD=ld.lld

export PLATFORM=android
sh autogen.sh

./configure --prefix=$TERMUX_PREFIX \
  --host=$HOST \
  --enable-static

make -j$(nproc)
make install-strip
