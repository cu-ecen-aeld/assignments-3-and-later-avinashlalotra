#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u
OUTDIR=/home/vboxuser/Desktop/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    #git apply ${FINDER_APP_DIR}/required.patch
    # TODO: Add your kernel build steps here
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

fi

echo "Adding the Image in outdir"
cd ${OUTDIR}
cp linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image
 

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi


# TODO: Create necessary base directories
mkdir ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir \
    bin \
    dev \
    etc \
    home \
    lib \
    lib64 \
    proc \
    sbin \
    sys \
    tmp \
    usr \
    usr/bin \
    usr/lib \
    usr/sbin \
    var \
    var\log 
cd ${OUTDIR}
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd ${OUTDIR}/rootfs
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs 
echo
echo "Intalling busybox dependencies in /lib/ and /lib64/"
_GCC_SYSROOT=/usr/local/arch64_cross_compile/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu

# Alternatively:
#   _INTERPRETER="/lib/ld-linux-aarch64.so.1"
echo "  Interpeter:"
cp ${_GCC_SYSROOT}/aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/ld-linux-aarch64.so.1

# Alternatively:
#   _SHARED_LIBS=\
#   "libm.so.6
#   libresolv.so.2
#   libc.so.6"
echo "  Shared libraries:"
cp ${_GCC_SYSROOT}/aarch64-none-linux-gnu/libc/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/libm.so.6 
cp ${_GCC_SYSROOT}/aarch64-none-linux-gnu/libc/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/libresolv.so.2 
cp ${_GCC_SYSROOT}/aarch64-none-linux-gnu/libc/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/libc.so.6 
# TODO: Make device nodes
echo "Populating /dev/"
cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "Populating /home"
cp -r -t "${OUTDIR}/rootfs/home/" \
    conf/ \
    autorun-qemu.sh \
    finder.sh \
    finder-test.sh \
    writer
# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
echo "Compressing initramfs.cpio"
cd ${OUTDIR}
gzip -f initramfs.cpio

echo "Done"