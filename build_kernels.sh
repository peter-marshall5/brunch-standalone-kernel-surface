#!/bin/bash

if [ ! -d /home/runner/work ]; then NTHREADS=$(nproc); else NTHREADS=$(($(nproc)*4)); fi

if [ -z "$1" ]; then
kernels=$(ls -d ./kernels/* | sed 's#./kernels/##g')
else
kernels="$1"
fi

kernels=6.2.12

mkdir -p rootc/packages

touch rootc/linux-test
exit

for kernel in $kernels; do
	echo "Building kernel $kernel"
	KCONFIG_NOTIMESTAMP=1 KBUILD_BUILD_TIMESTAMP='' KBUILD_BUILD_USER=chronos KBUILD_BUILD_HOST=localhost make -C "./kernels/$kernel" -j"$NTHREADS" O=out || { echo "Kernel build failed"; exit 1; }
	rm -f "./kernels/$kernel/out/source"
	#if [ -f /persist/keys/brunch.priv ] && [ -f /persist/keys/brunch.pem ]; then
	#	echo "Signing kernel $kernel"
	#	mv "./kernels/$kernel/out/arch/x86/boot/bzImage" "./kernels/$kernel/out/arch/x86/boot/bzImage.unsigned" || { echo "Kernel signing failed"; exit 1; }
	#	sbsign --key /persist/keys/brunch.priv --cert /persist/keys/brunch.pem "./kernels/$kernel/out/arch/x86/boot/bzImage.unsigned" --output "./kernels/$kernel/out/arch/x86/boot/bzImage" || { echo "Kernel signing failed"; exit 1; }
	#fi
	cp "./kernels/$kernel/out/arch/x86/boot/bzImage" "./rootc/kernel-$kernel"
	make -C "./kernels/$kernel" -j"$NTHREADS" O=out INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH="./kmods" modules_install
	tar zcf rootc/packages/kernel-"$kernel".tar.gz -C "./kernels/$kernel/out/kmods/" . --owner=0 --group=0
done
