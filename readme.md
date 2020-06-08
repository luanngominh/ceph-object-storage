# Object storage with Ceph
# Provision infrastructure
We use terraform to provision ceph server on aws EC2.
* Put your public key at `terraform/bootstrap/public_key.pem`
* Add aws credentials and path to your private `terraform/credentials.tfvars` which contain has pattern. Private key is used for provision server.
```
aws_access_key_id = "xxxxxx"
aws_secret_access_key = "yyyyyyyyyy"
ssh_key_private = "~/.ssh/id_rsa"

```
* Provision server by typing `make init` and then `make apply`

# Install Guide
1.
useradd cephadm && echo "ji20jka" | passwd --stdin cephadm
echo "cephadm ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephadm
chmod 0440 /etc/sudoers.d/cephadm
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
reboot

2.
sudo su cephadm

ssh-copy-id cephadm@ceph-01.meowing.site
ssh-copy-id cephadm@ceph-02.meowing.site
ssh-copy-id cephadm@ceph-03.meowing.site

vi ~/.ssh/config
Host ceph-01
   Hostname ceph-01.meowing.site
   User cephadm
Host ceph-02
   Hostname ceph-02.meowing.site
   User cephadm
Host ceph-03
   Hostname ceph-03.meowing.site
   User cephadm

chmod 644 ~/.ssh/config

3. Install ceph deploy
   
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://download.ceph.com/rpm-nautilus/el7/noarch/ceph-release-1-1.el7.noarch.rpm
yum install python-setuptools
yum update -y && yum install ceph-deploy

4. Init ceph deploy
su cephadm
mkdir ceph_cluster
cd ceph_cluster

ceph-deploy new ceph-01 ceph-02 ceph-03
ceph-deploy install ceph-01 ceph-02 ceph-03 --release nautilus

5. create mon

ceph-deploy mon create ceph-01 ceph-02 ceph-03
ceph-deploy gatherkeys ceph-01
ceph-deploy admin ceph-01 ceph-02 ceph-03

Install mgr
ceph-deploy mgr create ceph-01 ceph-02

Enable dashboard and prometheus moudle: 
ceph mgr module enable prometheus
ceph mgr module enable dashboard

If enable dashboard is failed, let's try install below package.
yum install -y https://download.ceph.com/rpm-nautilus/el7/noarch/ceph-mgr-dashboard-14.2.9-0.el7.noarch.rpm


6. osd
ceph-deploy disk list
# xoa data
ceph-deploy disk zap ceph-01 /dev/xvdb
ceph-deploy disk zap ceph-01 /dev/xvdc
ceph-deploy disk zap ceph-01 /dev/xvdd
ceph-deploy disk zap ceph-01 /dev/xvde
ceph-deploy disk zap ceph-01 /dev/xvdf

# tao osd
ceph-deploy osd create --data /dev/xvdb ceph-01
ceph-deploy osd create --data /dev/xvdc ceph-01
ceph-deploy osd create --data /dev/xvdd ceph-01
ceph-deploy osd create --data /dev/xvde ceph-01
ceph-deploy osd create --data /dev/xvdf ceph-01

# xoa data
ceph-deploy disk zap ceph-02 /dev/xvdb
ceph-deploy disk zap ceph-02 /dev/xvdc
ceph-deploy disk zap ceph-02 /dev/xvdd
ceph-deploy disk zap ceph-02 /dev/xvde
ceph-deploy disk zap ceph-02 /dev/xvdf

# tao osd
ceph-deploy osd create --data /dev/xvdb ceph-02
ceph-deploy osd create --data /dev/xvdc ceph-02
ceph-deploy osd create --data /dev/xvdd ceph-02
ceph-deploy osd create --data /dev/xvde ceph-02
ceph-deploy osd create --data /dev/xvdf ceph-02

# xoa data
ceph-deploy disk zap ceph-03 /dev/xvdb
ceph-deploy disk zap ceph-03 /dev/xvdc
ceph-deploy disk zap ceph-03 /dev/xvdd
ceph-deploy disk zap ceph-03 /dev/xvde
ceph-deploy disk zap ceph-03 /dev/xvdf

# tao osd
ceph-deploy osd create --data /dev/xvdb ceph-03
ceph-deploy osd create --data /dev/xvdc ceph-03
ceph-deploy osd create --data /dev/xvdd ceph-03
ceph-deploy osd create --data /dev/xvde ceph-03
ceph-deploy osd create --data /dev/xvdf ceph-03

S3
ceph-deploy install --rgw ceph-01 ceph-02 ceph-03
ceph-deploy rgw create ceph-01 ceph-02 ceph-03

add vi /etc/ceph/ceph.conf
[client.rgw.ceph-01]
rgw frontends = civetweb port=80

[client.rgw.ceph-02]
rgw frontends = civetweb port=80

[client.rgw.ceph-03]
rgw frontends = civetweb port=80

push config
ceph-deploy --overwrite-conf config push ceph-01 ceph-02 ceph-03

restart radosgw on ceph-01 ceph-02 ceph-03
systemctl status ceph-radosgw.target
systemctl restart ceph-radosgw.target
systemctl status ceph-radosgw.target

tao user
radosgw-admin user create --uid=admin --display-name=admin --system
radosgw-admin user create --uid=luanngominh --display-name=luanngominh --email=ngominhluanbox@gmail.com

ceph dashboard set-rgw-api-ssl-verify False
ceph dashboard set rgw-api-scheme http
ceph dashboard set rgw-api-port 80
ceph dashboard set-rgw-api-access-key <admin_access_key>
ceph dashboard set-rgw-api-secret-key <admin_secret_key>


config s3cmd
yum install s3cmd -y
cat << EOF> ~/.s3cfg
[default]
access_key = <access>
secret_key = <secret>
host_base = s3.meowing.site
host_bucket = s3.meowing.site/%(bucket)
multipart_chunk_size_mb = 15
multipart_max_chunks = 10000
socket_timeout = 300
use_https = True
check_ssl_certificate = False
EOF

Create pool
ceph osd pool create volume-01 64

Xoa pool
ceph config set mon mon_allow_pool_delete true
ceph osd pool delete volume-01 volume-01 --yes-i-really-really-mean-it


RBD
ceph osd pool create replicated 64
ceph osd pool application enable replicated rbd
rbd pool init replicated
rbd create --size 20000 --pool replicated meocon-data

# option
# rbd feature disable replicated/meocon-data object-map fast-diff deep-flatten

rbd map meocon-data --pool replicated

ceph-deploy install workspace --release nautilus
ceph-deploy admin workspaces

on client
rbd map meocon-data --pool replicated
mount -t ext4 /dev/rbd0 /data


RBD
ceph osd pool create workspace-vol-01 64
rbd pool init workspace-vol-01

ceph auth get-or-create client.workspace mon 'profile rbd' osd 'profile rbd pool=workspace-vol-01'
rbd create --size 10000 workspace-vol-01/data-01
rbd ls smod | grepworkspace-vol-01
rbd info workspace-vol-01/data-01
rbd resize --size 20000 workspace-vol-01/data-01

Add osd node


* References
  - https://min.io/resources/docs/MinIO-Throughput-Benchmarks-on-NVMe-SSD-8-Node.pdf
