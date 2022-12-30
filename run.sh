#!/usr/bin/env bash
set -e

if [ $# -eq 0  ]; then
    SELF=`basename "$0"`
    echo "USAGE ./${SELF} <resolver> <arch> <INPUT_IMG> <OUTPUT_BOX>"
    echo "EX)   ./${SELF} cloud-init s390x 2204_s390x.qcow2 2204_s390x.box"
    exit 1
fi

# https://stackoverflow.com/a/246128
BASE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd )
CI=cloud-init
GF=guestfish

TMP=$(mktemp -d /tmp/qcow2box.XXXXXX)
TMP_BOX=${TMP}/box.img
TMP_CI=${TMP}/ciiso.iso

RESOLVER=$1
ARCH=$2
IMG=$3
BOX_NAME=$4
mv $BASE/$IMG $TMP_BOX
cd $TMP

case "${RESOLVER}" in
    cloud-init)
        $BASE/$CI/10_build_ciiso.sh $TMP_CI
        $BASE/$CI/20_resize_img.sh $TMP_BOX
        $BASE/$CI/30_provision.sh $ARCH $TMP_BOX $TMP_CI
        ;;
    guestfish)
        $BASE/$GF/30_provision.sh $TMP_BOX
        ;;
    *)
        echo "Unsupported Resolver"
        exit 1
        ;;
esac
$BASE/package.sh $BOX_NAME $TMP_BOX

mv $TMP/$BOX_NAME $BASE
ls -al $BASE/$BOX_NAME
echo $BASE/$BOX_NAME
