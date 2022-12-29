#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi

IMG=$1
SIZE=${2:-50G}
qemu-img resize $IMG $SIZE
