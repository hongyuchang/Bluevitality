#### 说明
```txt
Heartbeat从2010年之后就不再继续维护，而Corosync则仍然处于活跃期...

AIS: 全称："Application Interface Standard" 开源的是 OpenAIS
    其类似于POSIX的API但AIS是用于定义中间件的，这些规范的主要目的就是为了提高中间组件可移植性和应用程序高可用性
    OpenAIS提供一种集群模式，包括集群框架，集群成员管理，通信方式，集群监测等，能够为集群软件或工具提供满足 AIS标准的集群接口
    OpenAIS组件包括AMF,CLM,CKPT,EVT,LCK,MSG，TMR,CPG,EVS等。注意：它没有集群资源管理功能，不能独立形成一个集群
    OpenAIS主要包含三个分支：Picacho，Whitetank，Wilson。其中Wilson是最新的

Corosync： http://corosync.github.io/corosync/
    是OpenAIS发展到Wilson版本后衍生出来的开放性集群引擎工程。可以说Corosync是OpenAIS工程的一部分（集群引擎项目）
    Corosync是一种集群管理引擎，类似于heartbeat的思想
    
    核心特性：
        1. 能够将多个主机构建成一个主机组，并且在主机组之间同步状态数据
        2. 提供了较为简洁的可用性管理器以实现在各种应用程序发生故障时的重启
        3. 配置接口和统计数据是在内存数据库中维护的因此其性能高效，速度快，便捷
        4. ........

corosync + pacemaker 的管理工具：
    1.crmsh   由suse提供
    2.pcs     由centos提供（centos6.6以后的默认）

各项目间的编译依赖：

        > 这部分的组件非必须（其目的是为了实现集群文件系统的功能）
        >            [CLVM2]   [GFS2]   [OCFS2]                   
        >                |        |        |                      
        >            [Distributed Lock Manager]  <---  分布式锁管理器
                                  |                               
                             [Pacemaker]
                             /    ↑    \
                            /     |    [Corosync]
                [Resource Agents] |
                            \     ↓
                           [Cluster Glue]
```
#### Corosync 部署流程
```bash
# 注：
# Corosync v1.x 没有投票系统，需要安装使用cman作为插件运行
# Corosync v2.x 支持投票系统，支持冲裁，可完全独立运行

[root@localhost ~]# vim /etc/hosts                  #修改主机名并集群节点间主机名映射
[root@localhost ~]# ntpdate 192.168.10.1            #集群节点间保持时间同步
[root@localhost ~]# yum info corosync
可安装的软件包
名称    ：corosync
架构    ：x86_64
版本    ：2.4.0        #2.X版本
发布    ：9.el7_4.2
大小    ：218 k
源      ：updates/7/x86_64
简介    ： The Corosync Cluster Engine and Application Programming Interfaces
网址    ：http://corosync.github.io/corosync/
协议    ： BSD
描述    ： This package contains the Corosync Cluster Engine Executive, several default
        : APIs and libraries, default configuration files, and an init script.
[root@localhost ~]# yum -y install corosync pacemaker
```
