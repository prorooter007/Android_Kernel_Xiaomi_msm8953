#!/bin/bash
echo "Cloning dependencies"
git clone --depth=1 -b rperf https://github.com/prorooter007/Android_Kernel_Xiaomi_msm8953 kernel
cd kernel
git clone --depth=1 -b master https://github.com/kdrag0n/proton-clang clang
git clone https://github.com/prorooter007/AnyKernel3 -b tissot --depth=1 AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
REPACK_DIR="${KERNEL_DIR}/AnyKernel"
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
export PATH="$(pwd)/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$($kernel/clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export ARCH=arm64
export KBUILD_BUILD_USER=prorooter007
export KBUILD_BUILD_HOST=circleci
# Compile plox
function compile() {
    make -j$(nproc) O=out ARCH=arm64 tissot_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \

    cd $REPACK_DIR

    if ! [ -a "$IMAGE" ]; then
        exit 1
        echo "There are some issues"
    fi
    cp $IMAGE $REPACK_DIR/
}
# Zipping
function zipping() {
    cd $REPACK_DIR || exit 1
    zip -r9 Lightning_Kernel-${TANGGAL}.zip *
    curl https://bashupload.com/Lightning_Kernel-${TANGGAL}.zip --data-binary @Lightning_Kernel-${TANGGAL}.zip
}
compile
zipping
