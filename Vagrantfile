# -*- mode: ruby -*-
# vi: set ft=ruby :

base_box="centos/7"

Vagrant.configure("2") do |config|
  config.vm.box = base_box

  config.vm.provider "virtualbox" do |config|
    config.memory = 8000
    config.cpus = 2
  end

  (1..3).each do |i|
    config.vm.define "#{i}.ceph.com" do |node|
      node.vm.box = base_box
      node.vm.hostname = "#{i}.ceph.com"
      node.vm.network "private_network", ip: "172.16.0.1#{i}"

      node.vm.provision "shell", inline: <<-SHELL
          apt-get update -y
          apt-get upgrade -y
        SHELL
    end
  end
end
