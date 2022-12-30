#!/usr/bin/bash
set -euo pipefail
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

# Add user and set password
useradd vagrant
echo -n 'vagrant' | passwd -f --stdin vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant-nopasswd
sed -i 's,Defaults\\s*requiretty,Defaults !requiretty,' /etc/sudoers
echo -n 'vagrant' | passwd -f --stdin root
passwd -u root

# Add vagrant insecure key
SSH_BASE=/home/vagrant/.ssh
mkdir -m 0700 -p $SSH_BASE
echo $VAGRANT_INSECURE_KEY > $SSH_BASE/authorized_keys
chmod 600 $SSH_BASE/authorized_keys
chown -R vagrant:vagrant $SSH_BASE

# sshd config
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

touch /var/lib/provision.flag
