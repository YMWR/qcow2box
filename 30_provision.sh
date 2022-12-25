#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi

ARCH=$1
IMG=$2
ISO=${3:-ciiso.iso}

case "${ARCH}" in
x86_64)
	QEMU_BINARY=qemu-system-x86_64
	QEMU_FLAGS=(-smp 2)
	;;
arm64)
	# https://wiki.ubuntu.com/ARM64/QEMU
	cp /usr/share/AAVMF/AAVMF_CODE.fd flash1.img
	QEMU_BINARY=qemu-system-aarch64
	QEMU_FLAGS=(-smp 2 -cpu cortex-a57 -M virt -pflash /usr/share/AAVMF/AAVMF_CODE.fd -pflash flash1.img)
    ;;
armhf)
	# https://wiki.ubuntu.com/ARM64/QEMU
	cp /usr/share/AAVMF/AAVMF_CODE.fd flash1.img
	QEMU_BINARY=qemu-system-arm
	QEMU_FLAGS=(-smp 2 -cpu cortex-a15 -M virt -pflash /usr/share/AAVMF/AAVMF_CODE.fd -pflash flash1.img)
	;;
s390x)
	QEMU_BINARY=qemu-system-s390x
    QEMU_FLAGS=(-smp 2)
	;;
ppc64el)
	QEMU_BINARY=qemu-system-ppc64le
    QEMU_FLAGS=(-smp 2)
	;;
riscv64)
	# https://discourse.ubuntu.com/t/ubuntu-installation-on-a-risc-v-virtual-machine-using-a-server-install-image-and-qemu/27636
	QEMU_BINARY=qemu-system-riscv64
	QEMU_FLAGS=(-smp 2 -M virt -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.bin -kernel /usr/lib/u-boot/qemu-riscv64_smode/u-boot.bin)
	;;
*)
	echo "Unsupported architecture"
	exit 1
	;;
esac

$QEMU_BINARY "${QEMU_FLAGS[@]}" -m 2G -hda $IMG -cdrom $ISO -nic none -nographic
