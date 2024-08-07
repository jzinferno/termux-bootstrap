#!/usr/bin/env bash

cd "$(cd "$(dirname "$0")" && pwd)"

if [ ! -d xmrig ]; then
  git clone --depth=1 https://github.com/jzinferno/xmrig
fi
cd xmrig
git pull

case $architecture in
  aarch64 )
    export ANDROID_ABI=arm64-v8a
    ;;
  arm )
    export ANDROID_ABI=armeabi-v7a
    ;;
  i686 )
    export ANDROID_ABI=x86
    ;;
  x86_64 )
    export ANDROID_ABI=x86_64
    ;;
  * )
    exit 1
    ;;
esac

mkdir -p build
cd build

cmake .. -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=$ANDROID_ABI \
  -DANDROID_PLATFORM=android-24 \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_OPENCL=OFF \
  -DWITH_CUDA=OFF \
  -DBUILD_STATIC=OFF \
  -DWITH_TLS=ON \
  -DWITH_HWLOC=OFF \
  -DUV_LIBRARY=$TERMUX_PREFIX/lib/libuv.a \
  -DUV_INCLUDE_DIR=$TERMUX_PREFIX/include \
  -DOPENSSL_SSL_LIBRARY=$TERMUX_PREFIX/lib/libssl.a \
  -DOPENSSL_CRYPTO_LIBRARY=$TERMUX_PREFIX/lib/libcrypto.a \
  -DOPENSSL_INCLUDE_DIR=$TERMUX_PREFIX/include

make -j$(nproc --all)
install -Dm775 xmrig -t $TERMUX_PREFIX/bin
rm -rf *
