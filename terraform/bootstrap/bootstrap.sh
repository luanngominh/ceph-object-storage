#!/usr/bin/env bash

number_of_instance=$1
ceph_domain=$2
current=$3

ntp_subnet=$4
ntp_net_mask=$5
ntp_server=$6

hostnamectl set-hostname ${current}.${ceph_domain}

# NTP
if [[ $current == 1 ]]; then
    cp /tmp/1.ntp.conf /etc/ntp.conf
    sed -i 's|{{ SUBNET_IP }}|'${ntp_subnet}'|g' /etc/ntp.conf
    sed -i 's|{{ NET_MASK }}|'${ntp_net_mask}'|g' /etc/ntp.conf
else
    cp /tmp/2.ntp.conf /etc/ntp.conf
    sed -i 's|{{ INTERNAL_NTP_SERVER }}|'${ntp_server}'|g' /etc/ntp.conf
fi

rm -f /tmp/1.ntp.conf
rm -f /tmp/2.ntp.conf

echo -e "\n#ceph domain" >> /etc/hosts
for ((c = 1; c < $number_of_instance+1; c++)); do
    echo ${c}.${ceph_domain} >> /etc/hosts
done

# tunning kernel for ceph
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

yum update -y
yum upgrade -y

systemctl stop chronyd && systemctl disable chronyd
yum install ntp -y && systemctl enable ntp && systemctl start ntp
