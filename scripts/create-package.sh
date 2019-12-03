#!/bin/bash

. build/envsetup.sh

out_dir=`get_build_var PRODUCT_OUT`

set -ex

system=$out_dir/system.img

if [ ! -f "$system" ]; then
    echo "Can't find $system file..."
    echo "Please check your build environment."
	exit 1
fi

workdir=`mktemp -d`
rootfs=$workdir/rootfs

mkdir -p $rootfs

mkdir $workdir/system
sudo mount -o loop,ro $system $workdir/system
sudo cp -ar $workdir/system/* $rootfs/
sudo umount $workdir/system


#apex process. binary and lib link to com.android.runtime, but real path has suffix with debug.
#It handled in apexd, so hard cording about it
for lib in libc libdl libm
do
    sudo rm $rootfs/system/lib/$lib.so
    sudo rm $rootfs/system/lib64/$lib.so
    sudo cp -ar $rootfs/system/apex/com.android.runtime.debug/lib/bionic/$lib.so $rootfs/system/lib/
    sudo cp -ar $rootfs/system/apex/com.android.runtime.debug/lib64/bionic/$lib.so $rootfs/system/lib64/
done

bins="dalvikvm dalvikvm32 dalvikvm64 dex2oat dexdiag dexdump dexlist dexoptanalyzer linker linker64 oatdump profman"
for bin in $bins
do
    sudo rm $rootfs/system/bin/$bin
    sudo cp -ar $rootfs/system/apex/com.android.runtime.debug/bin/$bin $rootfs/system/bin/
done

sudo rm $rootfs/system/bin/linker_asan
sudo rm $rootfs/system/bin/linker_asan64
sudo cp -ar $rootfs/system/apex/com.android.runtime.debug/bin/linker $rootfs/system/bin/linker_asan
sudo cp -ar $rootfs/system/apex/com.android.runtime.debug/bin/linker64 $rootfs/system/bin/liner_asan64

gcc -o $workdir/uidmapshift vendor/anbox/external/nsexec/uidmapshift.c
sudo $workdir/uidmapshift -b $rootfs 0 100000 65536

# FIXME
sudo chmod +x $rootfs/anbox-init.sh
sudo chmod +r $rootfs/system/bin

sudo mksquashfs $rootfs android.img -comp xz -no-xattrs
sudo chown $USER:$USER android.img

sudo rm -rf $workdir
