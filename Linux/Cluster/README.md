#### Notice
1. 所有的集群成员都需要 NTP 的时间同步
2. 修改各集群成员主机名  
 `~]# vim /etc/sysconfig/network`  
 `~]# vim /etc/hosts`  
 `~]# hostnamectl set-hostname <HOST_NAME>`
3. 修改各集群成员间的 /etc/hosts 将成员的主机名与地址做映射 eg: `~]# uname -n`
4. 必要时进行集群间 SSH 的公钥互信...
