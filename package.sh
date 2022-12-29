#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi

BOX_NAME=$1
IMG=$2

DIR=$(dirname "$IMG")
FILE=$(basename "$IMG")

cd $DIR

cat >metadata.json <<EOF
{"provider": "libvirt", "format": "qcow2", "virtual_size": 50}
EOF

cat >Vagrantfile <<EOF
Vagrant.configure('2') do |config|
    config.vm.provider :libvirt do |libvirt|
        libvirt.driver = 'qemu'
        libvirt.username = 'root'
        libvirt.connect_via_ssh = false
        libvirt.storage_pool_name = 'default'
    end
end
EOF

tar -C $DIR -cvzf $BOX_NAME metadata.json Vagrantfile $FILE
