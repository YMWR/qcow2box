#!/bin/bash -
set -e
set -x

# SOURCE=$1
# cp --reflink=auto ${SOURCE} ${IMAGE}
IMAGE=${1:-box.img}

guestfish[0]="guestfish"
guestfish[1]="--listen"
guestfish[2]="-a"
guestfish[3]="$IMAGE"

GUESTFISH_PID=
eval $("${guestfish[@]}")
if [ -z "$GUESTFISH_PID" ]; then
	echo "error: guestfish didn't start up, see error messages above"
	exit 1
fi

cleanup_guestfish ()
{
	guestfish --remote -- exit >/dev/null 2>&1 ||:
}
trap cleanup_guestfish EXIT ERR

# DESTINATION=$2
gf() {
    guestfish --remote -- "$@"
}

# https://stackoverflow.com/a/246128
BASE=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd )

gf run
is_fedora=false
BTRFS=$(gf list-filesystems | grep btrfs || true)
if [[ -n "$BTRFS" ]]; then
    is_fedora=true
fi

gf list-filesystems
if $is_fedora; then
    gf mount btrfsvol:/dev/sda5/root /
else
    gf mount /dev/sda1 /
fi

gf_relabel() {
    if $is_fedora; then
        gf llz "$@"
        gf selinux-relabel /etc/selinux/targeted/contexts/files/file_contexts "$@"
        gf llz "$@"
    fi
}

INJECT_BIN=provision.sh
INJECT_PRE=provision.preset
INJECT_SVC=provision.service

SYSTEMD_SVC_DIR=/etc/systemd/system
SYSTEMD_PRE_DIR=/etc/systemd/system-preset
SYSTEMD_LINK_DIR=$SYSTEMD_SVC_DIR/multi-user.target.wants

TARGET_SVC=$SYSTEMD_SVC_DIR/$INJECT_SVC
LINK_SVC=$SYSTEMD_LINK_DIR/$INJECT_SVC
DUMMY_SVC=/usr/lib/systemd/system/systemd-random-seed.service

TARGET_BIN=/usr/libexec/$INJECT_BIN

gf cp-a $DUMMY_SVC $TARGET_SVC
gf upload $BASE/$INJECT_SVC $TARGET_SVC
gf ln-s $TARGET_SVC $LINK_SVC
gf_relabel $LINK_SVC

gf mkdir $SYSTEMD_PRE_DIR
gf_relabel $SYSTEMD_PRE_DIR
gf upload $BASE/$INJECT_PRE $SYSTEMD_PRE_DIR/$INJECT_PRE
gf_relabel $SYSTEMD_PRE_DIR/$INJECT_PRE

gf cp-a /usr/bin/bash $TARGET_BIN
gf upload $BASE/$INJECT_BIN $TARGET_BIN

if [[ $(gf exists "/etc/cloud") == "true" ]]; then
    gf write "/etc/cloud/cloud-init.disabled" ""
    gf_relabel "/etc/cloud/cloud-init.disabled"
fi
gf glob rm-rf "$SYSTEMD_LINK_DIR/cloud-init*"
gf glob rm-rf "$SYSTEMD_LINK_DIR/cloud-final.service"
gf glob rm-rf "$SYSTEMD_LINK_DIR/cloud-config*"

gf umount-all
guestfish --remote -- exit
