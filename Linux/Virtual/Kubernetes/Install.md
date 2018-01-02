#### 实验环境
```txt
         etcd    master                  node
             \   /                      /
             [Node1]  <----------->  [Node2]
               |                       |
            192.168.0.3              192.168.0.4
```
#### k8s安装流程
```bash
[root@node1 ~]# yum -y install kubernetes* ntp flannel etcd docker  #在所有节点执行安装...
[root@node* ~]# yum -y install kubernetes* ntp flannel etcd docker  #
[root@node1 ~]# setenforce 0 && systemctl stop firewalld
[root@node2 ~]# setenforce 0 && systemctl stop firewalld
[root@node1 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.3 node1
192.168.0.4 node2
[root@node2 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.3 node1
192.168.0.4 node2
[root@node1 ~]# ntpdate ntp1.aliyun.com
[root@node2 ~]# ntpdate ntp1.aliyun.com
```
#### 部署 etcd 
```bash
[root@node1 ~]# cat /etc/etcd/etcd.conf             #配置etcd服务器(k8s的数据库系统)
#[Member]
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"          #数据存储目录
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"       #写入监听地址（client通信端口）
ETCD_NAME="default"
.......
#
#[Clustering]
#ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380"                       #peer初始化广播端口
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379,http://192.168.0.3:2379"      #写入通告地址（集群成员）
#ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
.......
#ETCD_ENABLE_V2="true"
[root@node1 ~]# systemctl enable etcd && systemctl start etcd

[root@node1 ~]# etcdctl member list                 #检查etcd集群成员列表，这里只有一台
8e9e05c52164694d: name=default peerURLs=http://localhost:2380 clientURLs=http://192.168.0.3:2379,\
http://localhost:2379 isLeader=true
[root@node1 ~]# etcdctl set /k8s/network/config '{"Network": "192.168.0.0/16"}' #配置etcd（曾用/24出故障)
{"Network": "192.168.0.0/16"}
[root@node1 ~]# etcdctl get /k8s/network/config
{"Network": "192.168.0.0/16"}
```
#### 部署 Master 
```bash
[root@node1 ~]# cat /etc/kubernetes/config      #配置master服务器
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"    #APISERVER在什么地方运行

[root@node1 ~]# cat /etc/kubernetes/apiserver    
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"              #KUBE_API的绑定地址
KUBE_API_PORT="--port=8080"
KUBELET_PORT="--kubelet_port=10250"                             # Port minions listen on
KUBE_ETCD_SERVERS="--etcd-servers=http://192.168.0.3:2379"      #指明etcd地址
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=192.168.0.0/24"      #外网网段，k8s通过其把服务暴露出去
KUBE_ADMISSION_CONTROL="--admission-control=AlwaysAdmit,NamespaceLifecycle,NamespaceExists,\
LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
KUBE_API_ARGS=""

[root@node1 ~]# cat /etc/kubernetes/controller-manager          #配置kube-controller-manager配置文件
KUBE_CONTROLLER_MANAGER_ARGS=""

[root@node1 ~]# cat /etc/kubernetes/scheduler                   #配置kube-scheduler配置文件
KUBE_SCHEDULER_ARGS="--address=0.0.0.0"

[root@node1 ~]# systemctl enable kube-apiserver kube-scheduler kube-controller-manager
[root@node1 ~]# systemctl start  kube-apiserver kube-scheduler kube-controller-manager
```
#### Node 1
```bash
[root@node1 ~]# vim /etc/sysconfig/docker                       #配置Docker配置文件，使其允许从registry中拉取镜像
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
OPTIONS='--insecure-registry registry:5000'

#配置node1网络，本实例采用flannel方式来配置，如需其他方式，请参考Kubernetes官网
[root@node1 ~]# cat /etc/sysconfig/flanneld    
FLANNEL_ETCD_ENDPOINTS="http://192.168.0.3:2379"
FLANNEL_ETCD_PREFIX="/k8s/network"
FLANNEL_OPTIONS="--iface=eno16777736"

[root@node1 ~]# cat /etc/kubernetes/config                      #配置node1 kube-proxy
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"

[root@node1 ~]# grep -v '^#' /etc/kubernetes/proxy                  
KUBE_PROXY_ARGS="--bind=address=0.0.0.0"


[root@node1 ~]# cat /etc/kubernetes/kubelet                     #配置node1 kubelet
KUBELET_ADDRESS="--address=0.0.0.0"                             #绑定的地址
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname-override=node1"                    #汇报的本机名称
KUBELET_API_SERVER="--api-servers=http://192.168.0.3:8080"      #要访问的APISERVER(Master地址)
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
#kubenet服务的启动要依赖pause这个镜像, 默认kubenet从google镜像服务下载, 而由于GFW原因会不成功，这里我们指定为docker的镜像
#手动方式镜像下载: docker pull docker.io/kubernetes/pause
KUBELET_ARGS=""

[root@node1 ~]# systemctl start flanneld
[root@node1 ~]# systemctl start kube-proxy
[root@node1 ~]# systemctl start kubelet
[root@node1 ~]# systemctl start docker
```
#### Node 2
```bash
[root@node1 ~]# vim /etc/sysconfig/docker                       #配置Docker配置文件，使其允许从registry中拉取镜像
OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false'
if [ -z "${DOCKER_CERT_PATH}" ]; then
    DOCKER_CERT_PATH=/etc/docker
fi
OPTIONS='--insecure-registry registry:5000'

#配置node2网络，本实例采用flannel方式来配置，如需其他方式，请参考Kubernetes官网
[root@node2 ~]# cat /etc/sysconfig/flanneld    
FLANNEL_ETCD_ENDPOINTS="http://192.168.0.3:2379"
FLANNEL_ETCD_PREFIX="/k8s/network"                              #即获取之前在etcd中设置的网络...
FLANNEL_OPTIONS="--iface=eno16777736"

[root@node2 ~]# cat /etc/kubernetes/config                      #配置node2 kube-proxy
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://192.168.0.3:8080"

[root@node2 ~]# grep -v '^#' /etc/kubernetes/proxy                  
KUBE_PROXY_ARGS="--bind=address=0.0.0.0"


[root@node2 ~]# cat /etc/kubernetes/kubelet                     #配置node2 kubelet
KUBELET_ADDRESS="--address=0.0.0.0"                             #绑定的地址
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname-override=node2"                    #汇报的本机名称
KUBELET_API_SERVER="--api-servers=http://192.168.0.3:8080"      #要访问的APISERVER
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
KUBELET_ARGS=""

[root@node2 ~]# systemctl start flanneld
[root@node2 ~]# systemctl start kube-proxy
[root@node2 ~]# systemctl start kubelet
[root@node2 ~]# systemctl start docker
```
```bash
[root@node1 ~]# kubectl get nodes                               #至此，整个Kubernetes集群搭建完毕    
NAME      STATUS     AGE
node1     Ready      9m
node2     NotReady   8s
```
