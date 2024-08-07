#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f openssl-3.3.1.tar.gz ]; then
  wget https://www.openssl.org/source/openssl-3.3.1.tar.gz
fi
rm -rf openssl-3.3.1; tar -xf openssl-3.3.1.tar.gz; cd openssl-3.3.1

patch -p1 < ../patches/openssl.patch

case $architecture in
  aarch64 )
    export PLATFORM=android-arm64
    ;;
  arm )
    export PLATFORM=android-arm
    ;;
  i686 )
    export PLATFORM=android-x86
    ;;
  x86_64 )
    export PLATFORM=android-x86_64
    ;;
  * )
    exit 1
    ;;
esac

./Configure $PLATFORM -D_ANDROID_API=24 \
  --prefix=$TERMUX_PREFIX \
  --openssldir=$TERMUX_PREFIX/etc/tls \
  -no-shared \
  -no-asm \
  -no-zlib \
  -no-comp \
  -no-dgram \
  -no-filenames \
  -no-cms

make -j$(nproc)
make install_sw
