#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f ncurses-6.5.tar.gz ]; then
  wget https://mirrors.kernel.org/gnu/ncurses/ncurses-6.5.tar.gz
fi
rm -rf ncurses-6.5; tar -xf ncurses-6.5.tar.gz; cd ncurses-6.5

patch -p1 < ../patches/ncurses.patch

case $architecture in
  aarch64 )
    export CC=aarch64-linux-android24-clang
    export CXX=aarch64-linux-android24-clang++
    export HOST=arm64-linux-android
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

./configure --prefix=$TERMUX_PREFIX \
  --host=$HOST \
  ac_cv_header_locale_h=no \
  am_cv_langinfo_codeset=no \
  --enable-stripping \
  --with-strip-program=$STRIP \
  --enable-const \
  --enable-ext-colors \
  --enable-ext-mouse \
  --enable-overwrite \
  --enable-pc-files \
  --enable-termcap \
  --enable-widec \
  --without-ada \
  --without-cxx-binding \
  --without-debug \
  --without-tests \
  --with-normal \
  --with-static \
  --with-termpath=$TERMUX_PREFIX/etc/termcap:$TERMUX_PREFIX/share/misc/termcap \
  --with-pkg-config-libdir=$TERMUX_PREFIX/lib/pkgconfig \
  --mandir=$TERMUX_PREFIX/share/man

make -j$(nproc)
make install.data install.libs install.progs
