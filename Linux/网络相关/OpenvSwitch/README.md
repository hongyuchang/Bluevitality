#### 部署
```bash 
[root@node1 ~]# yum -y install rpm-build selinux-policy-devel python-six
[root@node1 ~]# ll
总用量 6008
-rw-r--r--. 1 root root 6149523 12月 30 02:33 openvswitch-2.7.0.tar.gz   #下载源码并创建rpm包
[root@node1 ~]# setenforce 0
[root@node1 ~]# mkdir -p ~/rpmbuild/SOURCES
[root@node1 ~]# tar -zxf openvswitch-2.7.0.tar.gz 
[root@node1 ~]# cp openvswitch-2.7.0.tar.gz ~/rpmbuild/SOURCES/
[root@node1 ~]# sed 's/openvswitch-kmod, //g' openvswitch-2.7.0/rhel/openvswitch.spec > \
openvswitch-2.7.0/rhel/openvswitch_no_kmod.spec  
[root@node1 ~]# rpmbuild -bb --nocheck openvswitch-2.7.0/rhel/openvswitch_no_kmod.spec

#创建ovs配置目录并安装制作好的rpm包
[root@node1 ~]# mkdir /etc/openvswitch
[root@node1 ~]# yum -y localinstall rpmbuild/RPMS/x86_64/openvswitch-2.7.0-1.x86_64.rpm

#启动服务
[root@node1 ~]# systemctl start openvswitch
[root@node1 ~]# ovs-vsctl show            
286c02ff-a812-42ab-ac8a-cd342aeb6275
    ovs_version: "2.7.0"
```
#### 备忘
```txt
OpenvSwitch简称OVS，是虚拟交换软件，主要用于虚拟机VM环境
作为一个虚拟交换机，支持Xen/XenServer, KVM, and VirtualBox多种虚拟化技术。OpenvSwitch还支持多个物理机的分布式环境

在网络中换机和桥都是同一个概念，OVS实现了一个虚拟机的以太交换机，换句话说OVS也就是实现了一个以太桥。
那么在OVS中，给一个交换机或者说一个桥，用了一个专业的名词叫做：DataPath！

OpenvSwitch中有多个命令，分别有不同的作用：
    ovs-vsctl   用于控制ovs db
    ovs-ofctl   用于管理OpenFlow switch 的 flow
    ovs-dpctl   用于管理ovs的datapath
    ovs-appctl  用于查询和管理ovs daemon
```
#### Demo
```bash
[root@node1 ~]# ovs-vsctl add-br br0                        #新建网桥设备
[root@node1 ~]# ovs-vsctl set bridge br0 stp_enable=true    #启用生成树协议
[root@node1 ~]# ovs-vsctl add-port br0 eth0                 #添加接口到网桥（网桥中加入的物理接口不可以有IP地址）
[root@node1 ~]# ovs-vsctl add-port br0 eth1                 #
[root@node1 ~]# ovs-vsctl add-bond br0 bond0 eth2 eth3      #多网卡绑定 add-bond <bridge> <port> <iface...>
[root@node1 ~]# ifconfig br0 192.168.128.5 netmask 255.255.255.0     #为网桥设置IP (internal port 可配IP地址)
[root@node1 ~]# ovs-vsctl list-ports br0                    #列出br0上的端口（不包括internal port）
[root@node1 ~]# ovs-vsctl list interface eth8               #列出OVS中端口eth1的详细数据
[root@node1 ~]# ovs-vsctl list-br                           #列出网桥
[root@node1 ~]# ovs-vsctl port-to-br xxx                    #列出挂载某网络接口的所有网桥
[root@node1 ~]# ovs-vsctl show                              #查看全部信息

#VLAN
[root@node1 ~]# ovs-vsctl set port eth0 tag=10              #设置br0中的端口eth0为VLAN 10
[root@node1 ~]# ovs-svctl add-port br0 eth1 tag=10          #添加eth1到指定bridge br0并将其置成VLAN 10
[root@node1 ~]# ovs-vsctl add-port br0 eth1 trunk=9,10,11   #在br0上添加port eth1为VLAN 9,10,11的trunk

#GRE
[root@node1 ~]# ovs-vsctl add-port br0 br0-gre -- set interface br0-gre type=gre options:remote_ip=1.2.3.4

#STP
[root@node1 ~]# ovs-vsctl set bridge ovs-br stp_enable=[true|false]         #开启、关机STP生成树
[root@node1 ~]# ovs-vsctl get bridge ovs-br stp_enable                      #查询STP生成树配置信息
[root@node1 ~]# ovs−vsctl set bridge br0 other_config:stp-priority=0x7800   #设置Priority
[root@node1 ~]# ovs−vsctl set port eth0 other_config:stp-path-cost=10       #设置Cost
[root@node1 ~]# ovs−vsctl clear bridge ovs-br other_config                  #移除STP设置
```
