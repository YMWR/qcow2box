#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi

DIST=$1
DIST=${DIST,,}  # Lowercase
ARCH=$2         # options: [arm64, s390x, ppc64el]

URL=https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-$ARCH.img

if [[ "$DIST" == *"fedora"* ]];then
    PARSE_IMAGE() {
        local URL=$1
        curl -Ls $URL | grep -E '\.qcow2|\.img' |  grep -oP 'href="\K[^"]+'
    }
    case "${ARCH}" in
    arm64)
        ARCH=aarch64
        BASE_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/$ARCH/images
        URL=${BASE_URL}/$(PARSE_IMAGE $BASE_URL)
        ;;
    s390x)
        ARCH=s390x
        BASE_URL=https://download.fedoraproject.org/pub/fedora-secondary/releases/37/Cloud/$ARCH/images
        URL=${BASE_URL}/$(PARSE_IMAGE $BASE_URL)
        ;;
    ppc64el)
        ARCH=ppc64le
        BASE_URL=https://download.fedoraproject.org/pub/fedora-secondary/releases/37/Cloud/$ARCH/images
        URL=${BASE_URL}/$(PARSE_IMAGE $BASE_URL)
        ;;
    *)
        echo "Unsupported architecture"
        exit 1
        ;;
    esac
fi

wget -O base.img $URL
