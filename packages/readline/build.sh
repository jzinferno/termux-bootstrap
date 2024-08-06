#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f readline-8.2.tar.gz ]; then
  wget https://mirrors.kernel.org/gnu/readline/readline-8.2.tar.gz
fi
rm -rf readline-8.2; tar -xf readline-8.2.tar.gz; cd readline-8.2

for i in {001..013}; do
  wget https://mirrors.kernel.org/gnu/readline/readline-8.2-patches/readline82-$i 2>/dev/null
  if [ -f "readline82-$i" ]; then
    patch -p0 -i readline82-$i
    rm -f readline82-$i
  else
    break
  fi
done

patch -p1 < ../patches/readline.patch

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
export SHLIB_LIBS="-lncursesw"

./configure --prefix=$TERMUX_PREFIX \
  --host=$HOST \
  --with-curses --enable-multibyte bash_cv_wcwidth_broken=no

make -j$(nproc)
make install

#rm -f $TERMUX_PREFIX/lib/
