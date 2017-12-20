#### 说明
```txt
Heartbeat从2010年之后就不再继续维护，而Corosync则仍然处于活跃期...

AIS: 全称："Application Interface Standard" 开源的是 OpenAIS
    其类似于POSIX的API但AIS是用于定义中间件的，这些规范的主要目的就是为了提高中间组件可移植性和应用程序高可用性
    OpenAIS提供一种集群模式，包括集群框架，集群成员管理，通信方式，集群监测等，能够为集群软件或工具提供满足AIS标准的接口
    OpenAIS组件包括AMF,CLM,CKPT,EVT,LCK,MSG，TMR,CPG,EVS等。注意：它没有集群资源管理功能，不能独立形成一个集群
    OpenAIS主要包含三个分支：Picacho，Whitetank，Wilson。其中Wilson是最新的

Corosync： http://corosync.github.io/corosync/
    是OpenAIS发展到Wilson版本后衍生出来的开放性集群引擎工程。可以说Corosync是OpenAIS工程的一部分（集群引擎项目）
    Corosync可提供完整的HA功能，但要实现更多，更复杂的功能就需要使用OpenAIS了
    Corosync是一种集群管理引擎，类似于heartbeat的思想，它是未来的发展方向。在以后的新项目里一般采用Corosync
    
    核心特性：
        1. 能够将多个主机构建成一个主机组，并且在主机组之间同步状态数据
        2. 提供了较为简洁的可用性管理器以实现在各种应用程序发生故障时的重启
        3. 配置接口和统计数据是在内存数据库中维护的因此其性能高效，速度快，便捷
        4. ........

Pacemaker：
	是开源的高可用资源管理器(CRM)，其位于HA集群架构中资源管理、资源代理(RA)这个层次
	pacemaker本身只是资源管理器，我们需要接口才能对pacemker上的资源进行定义与管理，而crmsh即是pacemaker的配置接口!
	能够实现：
		监测并恢复节点和服务级别的故障
		存储无关，并不需要共享存储
		资源无关，任何能用脚本控制的资源都可以作为服务来管理
		支持使用STONITH来保证数据一致性。
		支持大型或者小型的集群
		支持quorate(法定人数) 或 resource(资源) 驱动的集群
		支持几乎所有的冗余配置，包括Active/Active, Active/Passive, N+1, N+M, N-to-1 and N-to-N
		自动同步各个节点的配置文件
		可以设定集群范围内的ordering, colocation , anti-colocation约束
		支持更多高级服务类型:支持需要在多个节点运行的服务,支持需要多种模式的服务。(比如 主/从,主/备)
		统一的，脚本化的，cluster shell

corosync + pacemaker 相关的2种管理工具：
    1. crmsh   由suse提供
    2. pcs     由redhat提供（centos6.6以后的默认）

Pacemaker启动的2种方式：
    1. 以插件方式随corosync启动，类似于heartbeat的CRM（默认的方式，corosync在2.X版以后不再支持这种方式）
    2. 作为独立的服务启动（会是将来更新的更强大的功能的方式）

各项目间的编译依赖：

        -> 这部分的组件非必须（其目的是为了实现集群文件系统的功能）
        ->           [CLVM2]   [GFS2]   [OCFS2]                   
        ->               |        |        |                      
        ->           [Distributed Lock Manager]     <---  分布式锁管理器
                                  |                               
                             [Pacemaker]    <---  其有多个版本在同时维护并且使用方式不同
                             /    ↑    \
                            /     |    [Corosync]
                [Resource Agents] |
                            \     ↓
                            [Cluster Glue]
```
#### Corosync + pacemaker 部署流程（仅参考，crmsh部分在centos7上有问题，需要改为使用红帽的pcs）
```bash
# 注：
# Corosync v1.x 没有投票系统，需要安装使用cman作为插件运行
# Corosync v2.x 支持投票系统，支持冲裁，可完全独立运行

[root@localhost ~]# systemctl stop
[root@localhost ~]# setenforce 0
[root@localhost ~]# hostnamectl set-hostname <NODE_NAME>	#设置节点名称
[root@localhost ~]# cat /etc/sysconfig/network			#
HOSTNAME=node1
[root@localhost ~]# vim /etc/hosts                  		#修改主机名并集群节点间主机名映射
[root@localhost ~]# scp /etc/hosts root@node{1..N}:/etc/hosts	#将主机名映射同步至所有集群节点...
[root@localhost ~]# ntpdate 192.168.10.1            		#集群节点间保持时间同步
[root@localhost ~]# hwclock -w
[root@localhost ~]# yum info corosync  | grep '版本'
版本    ：2.4.0
[root@localhost ~]# yum info pacemaker | grep '版本'# 2.X版本之后其不在支持以corosync的插件方式运行
版本    ：1.1.16                                    
[root@localhost ~]# yum -y install corosync pacemaker
[root@localhost ~]# rpm -ql corosync
/etc/corosync                                       #配置文件目录
/etc/corosync/corosync.conf.example                 #
/etc/corosync/corosync.conf.example.udpu            #
/etc/corosync/corosync.xml.example                  #
/etc/corosync/uidgid.d
/etc/dbus-1/system.d/corosync-signals.conf
/etc/logrotate.d/corosync
/etc/sysconfig/corosync
/etc/sysconfig/corosync-notifyd
/usr/bin/corosync-blackbox
/usr/bin/corosync-xmlproc
/usr/lib/systemd/system/corosync-notifyd.service
/usr/lib/systemd/system/corosync.service
/usr/sbin/corosync                                  #主程序
/usr/sbin/corosync-cfgtool                          #辅助性工具
/usr/sbin/corosync-cmapctl                          #
/usr/sbin/corosync-cpgtool                          #
/usr/sbin/corosync-keygen                           #
/usr/sbin/corosync-notifyd                          #
/usr/sbin/corosync-quorumtool                       #实现集群节点防止脑裂时的法定票数计算的工具
/usr/share/corosync
/usr/share/corosync/corosync
/usr/share/corosync/corosync-notifyd
/usr/share/corosync/xml2conf.xsl
...........(略)
/var/lib/corosync
/var/log/cluster
[root@localhost ~]# cp /etc/corosync/corosync.conf.example /etc/corosync/corosync.conf
[root@localhost ~]# cd /etc/corosync/
[root@localhost corosync]# cat corosync.conf
#totem 定义底层信息层如何通信（心跳）
totem {                     
	version: 2              #totem使用的版本
   	secauth: off            #启用心跳认证功能（若启用则需要执行：corosync-keygen生成密钥文件）
   	threads: 2              #工作线程数（若设为0则其不基于线程模式工作而使用进程模式）
	crypto_cipher: none     #
	crypto_hash: none       #
	interface {
		ringnumber: 0                   #环数量，保持为0即可
		bindnetaddr: 192.168.1.0        #使多播地址工作在本机的哪个网段之上（不是本机的IP地址!）
		mcastaddr: 239.255.1.1          #多播地址（需要开启网卡的组播 "MULTICAST"，默认开启）
		mcastport: 5405                 #多播端口
		ttl: 1                          #
	}
}

logging {
	fileline: off
	to_stderr: no                           #是否将日志发往标准错误输出
	to_logfile: yes                         #启用日志文件
	logfile: /var/log/cluster/corosync.log  #日志路径
	to_syslog: yes                          #发往syslog
	debug: off
	timestamp: on                           #是否在日志中打开时间戳功能
	logger_subsys {
		subsys: QUORUM                      #记录其特定类型的子系统信息到日志
		debug: off
	}
}

quorum {

}

aisexec {  
    user: root              #以什么身份运行插件 "service"（aisexec段可省略）
    group: root             #
}

service {  
    ver: 0                  #版本
    name: pacemaker         #名称
} 

[root@localhost corosync]# ip link show | grep MULTICAST        #检查网卡是否开启组播（默认开启）
2: eno16777736: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc ........

# 若在配置文件中启用 secauth/crypto_* 则需要使用 corosync-keygen 生成密钥文件
# corosync生成key文件会默认调用/dev/random随机数设备，一旦系统中断的IRQS的随机数不够用将会产生大量等待时间
# 解决办法：在另一个终端下载大文件来产生磁盘IO进行随机数产生或：find . > /dev/null

[root@localhost ~]# corosync-keygen				#生成密钥文件（需确其保权限为400）
Corosync Cluster Engine Authentication key generator.
Gathering 1024 bits for key from /dev/random.
Press keys on your keyboard to generate entropy (bits = 200).
Press keys on your keyboard to generate entropy (bits = 968).
Press keys on your keyboard to generate entropy (bits = 1016).
Writing corosync key to /etc/corosync/authkey.
[root@localhost ~]# scp -p /etc/corosync/{authkey,corosync.conf} node{1..n}:/etc/corosync   #拷贝到集群各节点
[root@localhost ~]# systemctl start  corosync                   #需要在集群的各个节点执行此操作
[root@localhost ~]# systemctl status corosync
● corosync.service - Corosync Cluster Engine
   Loaded: loaded (/usr/lib/systemd/system/corosync.service; disabled; vendor preset: disabled)
   Active: active (running) since 二 2017-11-21 12:26:07 CST; 4s ago
     Docs: man:corosync
           man:corosync.conf
           man:corosync_overview
  Process: 25355 ExecStart=/usr/share/corosync/corosync start (code=exited, status=0/SUCCESS)
 Main PID: 25362 (corosync)
   CGroup: /system.slice/corosync.service
           └─25362 corosync

11月 21 12:26:06 localhost.localdomain corosync[25362]:   [QB    ] server name: cfg
11月 21 12:26:06 localhost.localdomain corosync[25362]:   [SERV  ] Service engine lo........(略)
11月 21 12:26:06 localhost.localdomain corosync[25362]:   [TOTEM ] A new membership (192.168.0.3:4) w.....
11月 21 12:26:06 localhost.localdomain corosync[25362]:   [MAIN  ] Completed service synchronization......
11月 21 12:26:07 localhost.localdomain corosync[25355]: Starting Corosync Cluster Engine (corosy.....
11月 21 12:26:07 localhost.localdomain systemd[1]: Started Corosync Cluster Engine.
[root@node1 ~]# systemctl start corosync
[root@node2 ~]# systemctl start corosync
[root@node3 ~]# systemctl start corosync

#查看corosync引擎是否正常启动
[root@node1 ~]# grep -e "Corosync Cluster Engine" -e "configuration file" /var/log/cluster/corosync.log    
Aug 13 14:20:15 corosync [MAIN  ] Corosync Cluster Engine ('1.4.1'): started and ready to provide service.    
Aug 13 14:20:15 corosync [MAIN  ] Successfully read main configuration file '/etc/corosync/corosync.conf'.    
Aug 13 17:08:51 corosync [MAIN  ] Corosync Cluster Engine ('1.4.1'): started and ready to provide service.    
Aug 13 17:08:51 corosync [MAIN  ] Successfully read main configuration file '/etc/corosync/corosync.conf'.    
Aug 13 17:08:51 corosync [MAIN  ] Corosync Cluster Engine exiting with status 18 at main.c:1794.

#查看初始化成员节点通知是否正常发出
[root@node1 ~]# grep  TOTEM /var/log/cluster/corosync.log    
Aug 13 14:20:15 corosync [TOTEM ] Initializing transport (UDP/IP Multicast).    
Aug 13 14:20:15 corosync [TOTEM ] Initializing transmit/receive security: libtomcrypt SOBER128/SHA1HMAC ...
Aug 13 14:20:15 corosync [TOTEM ] The network interface [192.168.18.201] is now up.    
Aug 13 14:20:15 corosync [TOTEM ] A processor joined or left the membership and a new membership was formed.    
Aug 13 14:20:40 corosync [TOTEM ] A processor joined or left the membership and a new membership was forme

#检查启动过程中是否有错误产生
[root@node1 ~]# grep ERROR: /var/log/cluster/corosync.log    
Aug 13 14:20:15 corosync [pcmk  ] ERROR: process_ais_conf: You have configured a cluster using the Pacemaker plugin for Corosync. The plugin is not supported in this environment and will be removed very soon.    
Aug 13 14:20:15 corosync [pcmk  ] ERROR: process_ais_conf:  Please see Chapter 8 of 'Clusters from Scratch' (http://www.clusterlabs.org/doc) for details on using Pacemaker with CMAN

#查看pacemaker是否正常启动
[root@node1 ~]# grep pcmk_startup /var/log/cluster/corosync.log    
Aug 13 14:20:15 corosync [pcmk  ] info: pcmk_startup: CRM: Initialized    
Aug 13 14:20:15 corosync [pcmk  ] Logging: Initialized pcmk_startup    
Aug 13 14:20:15 corosync [pcmk  ] info: pcmk_startup: Maximum core file size is: 18446744073709551615    
Aug 13 14:20:15 corosync [pcmk  ] info: pcmk_startup: Service: 9    
Aug 13 14:20:15 corosync [pcmk  ] info: pcmk_startup: Local hostname: node1.test.com

#查看集群状态
[root@node1 ~]# crm_mon
Last updated: Tue Aug 13 17:41:31 2013  
Last change: Tue Aug 13 14:20:40 2013 via crmd on node1.test.com    
Stack: classic openais (with plugin)    
Current DC: node2.test.com - partition with quorum    
Version: 1.1.8-7.el6-394e906    
2 Nodes configured, 2 expected votes    
0 Resources configured. 
Online: [ node1.test.com node2.test.com ]

```
#### 安装 crmsh ( pacemaker 的配置接口 )
```bash
#[root@localhost corosync]# cd /etc/yum.repos.d/   
#[root@localhost corosync]# wget http://download.opensuse.org/repositories\
#/network:/ha-clustering:/Stable/CentOS_CentOS-7/network:ha-clustering:Stable.repo   
#[root@localhost corosync]# yum -y install deltarpm
#[root@localhost corosync]# yum -y install crmsh pssh    	#yum方式安装Crmsh（可能会有问题）

[root@localhost ~]# yum -y install python-dateutil python-lxml
[root@localhost ~]# rpm -ivh python-parallax-1.0.0a1-7.1.noarch.rpm
[root@localhost ~]# rpm -ivh crmsh-*				#安装本README所在的当前URL下的rpm包....
[root@localhost ~]# #crm                                	#直接输入crm将进入子命令模式
[root@localhost ~]# crm status                          	#查看下localhost上的集群状态信息
Last updated: Sun Apr 20 16:56:11 2014
Last change: Sun Apr 20 16:50:32 2014 via crmd on node2.shuishui.com
Stack: classic openais (with plugin)
Current DC: node2.shuishui.com - partition WITHOUT quorum       #当前 DC
Version: 1.1.8-7.el6-394e906
2 Nodes configured, 2 expected votes                            #节点数量，期望有几票 
0 Resources configured.                                         #当前有几个资源被配置
Online: [ node2.shuishui.com ]                                  #在线节点
OFFLINE: [ node1.shuishui.com ]                                 #node1已经离线
 webip  (ocf::heartbeat:IPaddr):  Started node2.shuishui.com  	#webip转移到了node2上
```
