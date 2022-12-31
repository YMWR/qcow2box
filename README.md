# qcow2box
convert cloud image to vagrant box

### Example Vagrantfile

```vagrant
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "YMWR/ubuntu2204-s390x"
  config.vm.provider "libvirt" do |v|
    v.cpus = 4
    v.memory = 4096

    # arch specific setting
    v.machine_arch = "s390x"
    v.machine_type = "s390-ccw-virtio"
    v.cpu_mode = "custom"
    v.cpu_model = "qemu"
    v.graphics_type = "none"
    v.input :type => "mouse", :bus => "virtio"

    # virtiofs specific setting
    v.memorybacking :source, :type => "memfd"
    v.memorybacking :access, :mode => "shared"
  end

  config.vm.synced_folder "./linux", "/home/vagrant/linux", type: "virtiofs" 
end

```
