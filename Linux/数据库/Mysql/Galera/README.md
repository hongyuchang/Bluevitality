#### 备忘
```txt
1.同步复制
2.真正的multi-master，即所有节点可以同时读写数据库
3.自动的节点成员控制，失效节点自动被清除（当失效节点重新加入集群时需修改wsrep_cluster_address为集群内互活跃成员地址!）
4.新节点加入数据自动复制
5.真正的并行复制，行级，同时具有读和写的扩展能力
6.用户可以直接连接集群，使用感受上与MySQL完全一致
7.节点间数据是同步的,而Master/Slave模式是异步的,不同slave上的binlog可能是不同的
8.不存在丢失交易的情况，当节点发生崩溃时无数据丢失
9.数据复制保持连续性

注：安装MariaDB集群至少需要3台服务器（如果只有两台的话需要特殊配置，请参照官方文档）
```
#### Galera 部署流程 （环境：CentOS 7）
```bash
[root@localhost ~]# vim /etc/hosts                              #在每个节点上配置集群内各节点的主机名与IP映射
[root@localhost ~]# systemctl stop firewalld
[root@localhost ~]# systemctl disable firewalld

[root@localhost ~]# yum install -y mariadb mariadb-galera-server mariadb-galera-common galera rsync
[root@localhost ~]# systemctl start mariadb
[root@localhost ~]# mysql_secure_installation                   #进行安全初始化
[root@localhost ~]# systemctl stop mariadb
[root@localhost ~]# cat /etc/my.cnf.d/galera.cnf                #
[galera]
wsrep_on=ON
wsrep_provider=/usr/lib64/galera/libgalera_smm.so
wsrep_cluster_address="gcomm://192.168.1.112,192.168.1.113 "    #可用/etc/hosts映射（集群内任1成员IP即可，可多个）
binlog_format=row                                               #二进制日志格式
default_storage_engine=InnoDB                                   #默认存储引擎（目前Galera仅支持Innodb）
innodb_autoinc_lock_mode=2                                      
bind-address=0.0.0.0                                            #
wsrep_cluster_name="MyCluster"
wsrep_node_address="192.168.1.112"                              #本节点的IP地址
wsrep_node_name="node1"                                         #本节点的hostname值（必须）
wsrep_sst_method=rsync
wsrep_sst_auth=root:command
#wsrep_provider_options="socket.ssl_key=/etc/pki/galera/galera.key; socket.ssl_cert=/etc/pki/galera/galera.crt;"

[root@localhost ~]# /usr/libexec/mysqld --wsrep-new-cluster --user=root &   #因systemd默认不支持加入参数，手动启动
#警告⚠：--wsrep-new-cluster 参数只能在初始化集群使用，且只能在一个节点使用!（初始节点）....

[root@localhost ~]# tail -f /var/log/mariadb/mariadb.log                    #观察日志
150701 19:54:17 [Note] WSREP: wsrep_load(): loading provider library 'none'
150701 19:54:17 [Note] /usr/libexec/mysqld: ready for connections.          #出现ready for connections 证明启动成功
Version: '5.5.40-MariaDB-wsrep'  socket: '/var/lib/mysql/mysql.sock' port: 3306  MariaDB Server, ......

[root@localhost2 ~]# systemctl start mariadb            #陆续启用其他节点
[root@localhost3 ~]# systemctl start mariadb
[root@localhost4 ~]# systemctl start mariadb            #查看 /var/log/mariadb/mariadb.log 可看到节点均加入了集群


[root@localhost4 ~]#mysql -uroot -p123456  -e 'show status like "wsrep_%";'
wsrep_connected = on        #链接已开启
wsrep_local_index = 1       #在集群中的索引值
wsrep_cluster_size =3       #集群中节点的数量
wsrep_incoming_addresses = 10.128.20.17:3306,10.128.20.16:3306,10.128.20.18:3306    #集群中节点的访问地址
```
#### 为集群加入冲裁者： Galera arbitrator
```txt
对于只有2个节点的 Galera Cluster 和其他集群一样需要面对极端情况下的"脑裂"状态。为避免这种问题，Galera引入了"arbitrator"
"仲裁人"节点上没有数据，它在集群中的作用就是在集群发生分裂时进行仲裁，集群中可以有多个"仲裁人"节点。
"仲裁人"节点加入集群的方法很简单，运行如下命令即可:
[root@arbitrator ~]# garbd -a gcomm://192.168.0.171:4567 -g my_wsrep_cluster -d
 
参数说明:
    -d  以daemon模式运行
    -a  集群地址
    -g  集群名称
```
#### 注意
```txt
配置参数"wsrep_cluster_address"中的"gcomm://" 是特殊的地址,仅仅是Galera cluster初始化启动时候使用。
如果集群启动以后，我们关闭了第一个节点，那么再次启动的时候必须先修改"gcomm://"为其他节点的集群地址

为了能够引入配置，需要在/etc/my.cnf中加入：!includedir /etc/my.cnf.d/
```
