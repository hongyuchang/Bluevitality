#### 配置 DHCP 提供 PXE 引导文件地址...
```bash
# PXE：预引导执行环境（允许客户端启动后通过网络对DHCP指定的TFTP地址进行引导文件的加载）
# 注： DHCP服务器上的网卡地址需要手工修改网卡配置文件来指定（固定，不要用vmware的NET8，新建一个NET并取消DHCP）...

[root@localhost ~]# setenforce  0
[root@localhost ~]# cat /etc/sysconfig/selinux | grep SELINUX=
SELINUX=disabled
[root@localhost ~]# yum -y install dhcp
[root@localhost ~]# systemctl stop firewalld && systemctl disable firewalld
[root@localhost ~]# cat /etc/dhcp/dhcpd.conf
option domain-name              "danlab.local";
option domain-name-servers      127.0.0.1;
default-lease-time 86400;
max-lease-time 86400;

filename="pxelinux.0";              #引导文件（它由syslinux提供：yum install syslinux）
next-server 192.168.0.2;            #引导文件所在服务器地址

subnet 192.168.0.0 netmask 255.255.255.0 {
        range 192.168.0.3 192.168.0.254;
        option broadcast-address 192.168.0.255;
        option routers 192.168.0.1;
}
[root@localhost ~]# systemctl start dhcpd && systemctl enable dhcpd
[root@localhost ~]# netstat -atupnl | grep dhcp
udp        0      0 0.0.0.0:67              0.0.0.0:*                           1563/dhcpd          
udp        0      0 0.0.0.0:19992           0.0.0.0:*                           1563/dhcpd          
udp6       0      0 :::36907                :::*                                1563/dhcpd
```
#### Server端设置
```bash
[root@localhost ~]# yum -y install xinetd tftp-server syslinux system-config-kickstart httpd
[root@localhost ~]# cat /etc/xinetd.d/tftp
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot          #TFTP的默认根路径：/var/lib/tftpboot
        disable                 = no                            #改为no
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
[root@localhost ~]# chmod  777 /var/lib/tftpboot
[root@localhost ~]# systemctl start tftp.socket && systemctl enable tftp.socket
[root@localhost ~]# systemctl start tftp.service && systemctl enable tftp.service
[root@localhost ~]# systemctl start httpd && systemctl enable httpd
[root@localhost ~]# systemctl start xinetd && systemctl enable xinetd
[root@localhost ~]# mount -t auto /dev/cdrom /mnt/cdrom/                    #挂载IOS光盘
mount: /dev/sr0 写保护，将以只读方式挂载
[root@localhost ~]# cp /mnt/cdrom/isolinux/{vmlinuz,initrd.img} /var/lib/tftpboot/
[root@localhost ~]# cp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
[root@localhost ~]# cp /usr/share/syslinux/chain.c32 /var/lib/tftpboot/
[root@localhost ~]# cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot     #相当于bootloader
[root@localhost ~]# mkdir -p /var/lib/tftpboot/pxelinux.cfg
[root@localhost ~]# ll /var/lib/tftpboot/
总用量 42752
-rw-r--r--. 1 root root    20704 11月 20 21:13 chain.c32
-r--r--r--. 1 root root 38508192 11月 20 21:15 initrd.img
-rw-r--r--. 1 root root    55012 11月 20 21:16 menu.c32
-rw-r--r--. 1 root root    26764 11月 20 21:16 pxelinux.0
drwxr-xr-x. 2 root root        6 11月 20 21:16 pxelinux.cfg
-r-xr-xr-x. 1 root root  5156528 11月 20 21:15 vmlinuz
[root@localhost ~]# chmod 777 -R /var/lib/tftpboot/pxelinux.cfg
[root@localhost ~]# chmod 777 /var/lib/tftpboot/pxelinux.0
[root@localhost ~]# chmod 777 /var/www/html
[root@localhost ~]# mkdir -p /var/www/html/os
[root@localhost ~]# cp -r /mnt/cdrom/* /var/www/html/os #Linux_ISO文件(在ks文件中标记此位置进行下载运行)
[root@localhost ~]# vim /var/lib/tftpboot/pxelinux.cfg/default
default ks
prompt 0
timeout 30
MENU TITLE CentOS7 PXE Menu

LABEL ks
    KERNEL vmlinuz
    APPEND initrd=initrd.img ks=http://192.168.0.2:80/ks.cfg  [ksdevice=<interface>] [ip=dhcp] [quiet]
[root@localhost ~]# chmod 644 /var/lib/tftpboot/pxelinux.cfg/default

#验证ks文件正确性（此处没有ks.cfg的文档，请参考本URL下的：Kickstart.cfg，务必在/var/www/html/下放置ks.cfg..）
[root@localhost ~]# ksvalidator /var/www/html/ks.cfg

#注：
#http:/Host:Port/Path/ks.cfg 中要有 'url --url="http://192.168.0.2/os/"' 使其从网络进行安装
```
#### Client端
`开启网卡的PXE功能....`
