#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -f bash-5.2.tar.gz ]; then
  wget https://mirrors.kernel.org/gnu/bash/bash-5.2.tar.gz
fi
rm -rf bash-5.2; tar -xf bash-5.2.tar.gz; cd bash-5.2

for i in {001..032}; do
  wget https://mirrors.kernel.org/gnu/bash/bash-5.2-patches/bash52-$i 2>/dev/null
  if [ -f "bash52-$i" ]; then
    patch -p0 -i bash52-$i
    rm -f bash52-$i
  else
    break
  fi
done

patch -p1 < ../patches/bash.patch

case $architecture in
  aarch64 )
    export CC=aarch64-linux-android34-clang
    export CXX=aarch64-linux-android34-clang++
    export HOST=aarch64-linux-android
    ;;
  arm )
    export CC=armv7a-linux-androideabi34-clang
    export CXX=armv7a-linux-androideabi34-clang++
    export HOST=arm-linux-androideabi
    ;;
  i686 )
    export CC=i686-linux-android34-clang
    export CXX=i686-linux-android34-clang++
    export HOST=i686-linux-android
    ;;
  x86_64 )
    export CC=x86_64-linux-android34-clang
    export CXX=x86_64-linux-android34-clang++
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
  --enable-multibyte \
  --without-bash-malloc \
  --enable-static-link \
  --with-installed-readline \
  bash_cv_job_control_missing=present \
  bash_cv_sys_siglist=yes \
  bash_cv_func_sigsetjmp=present \
  bash_cv_unusable_rtsigs=no \
  ac_cv_func_mbsnrtowcs=no \
  bash_cv_dev_fd=whacky \
  bash_cv_getcwd_malloc=yes

make -j$(nproc)
make install
$STRIP $TERMUX_PREFIX/bin/bash
rm -f $TERMUX_PREFIX/bin/bashbug
