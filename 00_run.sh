#!/usr/bin/env bash
set -e

if [ $# -eq 0  ]; then
    SELF=`basename "$0"`
    echo "USAGE ./${SELF} <arch> <INPUT_IMG> <OUTPUT_BOX>"
    echo "EX)   ./${SELF} s390x 2204_s390x.qcow2 2204_s390x.box"
	exit 1
fi

# https://stackoverflow.com/a/246128
BASE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd )

TMP=$(mktemp -d /tmp/qcow2box.XXXXXX)
TMP_BOX=${TMP}/box.img
TMP_CI=${TMP}/ciiso.iso

ARCH=$1
IMG=$2
BOX_NAME=$3
mv $BASE/$IMG $TMP_BOX
cd $TMP

$BASE/10_build_ciiso.sh $TMP_CI
$BASE/20_resize_img.sh $TMP_BOX
$BASE/30_provision.sh $ARCH $TMP_BOX $TMP_CI
$BASE/90_package.sh $BOX_NAME $TMP_BOX

ls -al $TMP/$BOX_NAME
echo $TMP/$BOX_NAME
