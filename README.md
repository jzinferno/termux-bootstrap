# termux-bootstrap

```bash
export ANDROID_NDK_ROOT=~/android-ndk-r27
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
export TERMUX_PREFIX=/data/data/com.jzinferno.termux/files/usr

./scripts/generate-bootstraps.sh
```
