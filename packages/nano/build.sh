#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f nano-8.1.tar.gz ]; then
  wget https://nano-editor.org/dist/latest/nano-8.1.tar.gz
fi
rm -rf nano-8.1; tar -xf nano-8.1.tar.gz; cd nano-8.1

patch -p1 < ../patches/nano.patch

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

export CFLAGS="-g -O2 -I $TERMUX_PREFIX/include -L $TERMUX_PREFIX/lib"

./configure --prefix=$TERMUX_PREFIX \
  --host=$HOST \
  ac_cv_header_glob_h=no \
  ac_cv_header_pwd_h=no \
  --disable-libmagic \
  --enable-utf8 \
  --with-wordbounds

make -j$(nproc)
make install-strip
