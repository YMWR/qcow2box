#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi

ARCH=$1
IMG=$2
ISO=${3:-ciiso.iso}
qemu-system-${ARCH} -m 2G -smp 2 -hda $IMG -cdrom $ISO -nographic
