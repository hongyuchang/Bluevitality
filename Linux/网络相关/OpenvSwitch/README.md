#### 部署
```bash 
[root@node1 ~]# yum -y install rpm-build
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
