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
      node.vm.network "private_network", ip: "172.16.0.2#{i}"

      node.vm.provision "shell", inline: <<-SHELL
          apt-get update -y
          apt-get upgrade -y

          echo '
          # maximum number of open files/file descriptors
          fs.file-max = 4194303
          # use as little swap space as possible
          vm.swappiness = 1
          # prioritize application RAM against disk/swap cache
          vm.vfs_cache_pressure = 10
          # minimum free memory
          vm.min_free_kbytes = 1000000
          # maximum receive socket buffer (bytes)
          net.core.rmem_max = 268435456
          # maximum send buffer socket buffer (bytes)
          net.core.wmem_max = 268435456
          # default receive buffer socket size (bytes)
          net.core.rmem_default = 67108864
          # default send buffer socket size (bytes)
          net.core.wmem_default = 67108864
          # maximum number of packets in one poll cycle
          net.core.netdev_budget = 1200
          # maximum ancillary buffer size per socket
          net.core.optmem_max = 134217728
          # maximum number of incoming connections
          net.core.somaxconn = 65535
          # maximum number of packets queued
          net.core.netdev_max_backlog = 250000
          # maximum read buffer space
          net.ipv4.tcp_rmem = 67108864 134217728 268435456
          # maximum write buffer space
          net.ipv4.tcp_wmem = 67108864 134217728 268435456
          # enable low latency mode
          net.ipv4.tcp_low_latency = 1
          # socket buffer portion used for TCP window
          net.ipv4.tcp_adv_win_scale = 1
          # queue length of completely established sockets waiting for accept
          net.ipv4.tcp_max_syn_backlog = 30000
          # maximum number of sockets in TIME_WAIT state
          net.ipv4.tcp_max_tw_buckets = 2000000
          # reuse sockets in TIME_WAIT state when safe
          net.ipv4.tcp_tw_reuse = 1
          # time to wait (seconds) for FIN packet
          net.ipv4.tcp_fin_timeout = 5
          # disable icmp send redirects
          net.ipv4.conf.all.send_redirects = 0
          # disable icmp accept redirect
          net.ipv4.conf.all.accept_redirects = 0
          # drop packets with LSR or SSR
          net.ipv4.conf.all.accept_source_route = 0
          # MTU discovery, only enable when ICMP blackhole detected
          net.ipv4.tcp_mtu_probing = 1
          ' >> /etc/sysctl.conf

          sysctl -p
        SHELL
    end
  end
end
