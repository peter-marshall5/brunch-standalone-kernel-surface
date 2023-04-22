#!/bin/bash

kernel=6.2.12

apply_patches()
{
for patch_type in "base" "others" "chromeos" "all_devices" "surface"; do
	if [ -d "./kernel-patches/$1/$patch_type" ]; then
		for patch in ./kernel-patches/"$1/$patch_type"/*.patch; do
			echo "Applying patch: $patch"
			patch -d"./kernels/$1" -p1 --no-backup-if-mismatch -N < "$patch" || { echo "Kernel $1 patch failed"; exit 1; }
		done
	fi
done
}

make_config()
{
mkdir kernels/$1/out
cp config-$1 kernels/$1/out/.config
#make -C "./kernels/$1" O=out nconfig
}

download_and_patch_kernels()
{
mkdir -p kernels/$kernel
echo "Downloading Mainline kernel source for kernel $kernel"
curl -L "https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-$kernel.tar.gz" -o "./kernels/mainline-$kernel.tar.gz" || { echo "Kernel source download failed"; exit 1; }
tar -C "./kernels/$kernel" -zxf "./kernels/mainline-$kernel.tar.gz" --strip 1 || { echo "Kernel $kernel source extraction failed"; exit 1; }
rm -f "./kernels/mainline-$kernel.tar.gz"
apply_patches "$kernel"
make_config "$kernel"
}

rm -rf ./kernels
mkdir ./kernels

download_and_patch_kernels
