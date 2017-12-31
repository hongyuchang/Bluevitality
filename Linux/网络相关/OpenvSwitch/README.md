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
#### Demo
```bash
[root@node1 ~]# ovs-vsctl add-br br0                        #新建网桥设备
[root@node1 ~]# ovs-vsctl set bridge br0 stp_enable=true    #启用生成树协议
[root@node1 ~]# ovs-vsctl add-port br0 eth0                 #添加接口到网桥（网桥中加入的物理接口不可以有IP地址）
[root@node1 ~]# ovs-vsctl add-port br0 eth1                 #
[root@node1 ~]# ovs-vsctl add-bond br0 bond0 eth2 eth3      #多网卡绑定
[root@node1 ~]# ifconfig br0 192.168.128.5 netmask 255.255.255.0     #为网桥设置IP
```
