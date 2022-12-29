#!/usr/bin/env bash
if [ $# -eq 0  ]; then
	echo "no arguments"
	exit 1
fi


ISO=${1:-ciiso.iso}
rm -rf $ISO meta-data user-data

cat >meta-data <<EOF
instance-id: vagrant
local-hostname: localhost
EOF

cat >user-data <<EOF
#cloud-config
users:
- name: vagrant
  groups: sudo
  sudo: ['ALL=(ALL) NOPASSWD:ALL']
  shell: /bin/bash
  lock_passwd: false
  plain_text_passwd: vagrant
  ssh-authorized-keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key

ssh_pwauth: True
chpasswd: { expire: False }

write_files:
  - path: /etc/cloud/cloud-init.disabled

runcmd:
  - grubby --update-kernel ALL --args selinux=0 || true
  - sed -i 's/enforcing/disabled/g' /etc/selinux/config || true
  - sed -i 's/enforcing/disabled/g' /etc/sysconfig/selinux || true
  - sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config || true

power_state:
    delay: now
    mode: poweroff
    message: Cloud Init-Done Powering off
    timeout: 0
EOF

genisoimage -output $ISO -volid cidata -joliet -rock user-data meta-data
