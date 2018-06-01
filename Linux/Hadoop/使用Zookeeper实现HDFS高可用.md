```txt
部署HA之前请先将ZK服务先部署完毕~! 
需要zookeeper最少3台，需要journalnode最少三台，目前最多支持2台namenode，不过节点可以复用，但是不建议

Active NameNode、Standby NameNode：
    两台NameNode形成互备，一台处于Active状态，为主NameNode
    另外一台处于Standby状态，为备NameNode，只有主NameNode才能对外提供读写服务

主备切换控制器 ZKFailoverController：
    ZKFailoverController作为独立进程运行，对NameNode的主备切换进行总体控制
    ZKFailoverController能及时检测到NameNode健康状况
    在主NameNode故障时借助Zookeeper实现自动的主备选举和切换，当然NameNode也支持不依赖Zookeeper的手动主备切换

Zookeeper集群：
    为主备切换控制器提供主备选举支持
    
共享存储系统：
    共享存储系统是实现NN高可用最为关键的部分，共享存储系统保存了NameNode运行过程中所产生的HDFS元数据。
    Active NameNode和Standby NameNode通过共享存储系统实现元数据同步。
    在进行主备切换时新的主NameNode在确认元数据完全同步之后才能继续对外提供服务。
    DataNode同时向主NameNode和备NameNode上报数据块的位置信息
```

#### vim etc/hadoop/hdfs-site.xml
```xml
<!-- 名称服务的逻辑名称 -->
<property>
    <name>dfs.nameservices</name>
    <value>sxt</value>
</property>

<!-- 名称服务中每个NameNode的唯一标识，这将由DataNode用于确定群集中的所有NameNode，目前每个名称服务最多只能配2个NN -->
<property>
    <name>dfs.ha.namenodes.sxt</name>
    <value>nn1,nn2</value>
</property>

<!-- 每个NameNode监听的完全限定的RPC地址，对于之前配置的NameNode ID，需要设置NameNode进程的完整地址和IPC端口 -->
<property>
    <name>dfs.namenode.rpc-address.sxt.nn1</name>
    <value>node1:8020</value>
</property>
<property>
    <name>dfs.namenode.rpc-address.sxt.nn2</name>
    <value>node2:8020</value>
</property>

<!-- 每个NameNode监听的完全限定的HTTP地址 -->
<property>
    <name>dfs.namenode.http-address.sxt.nn1</name>
    <value>node1:50070</value>
</property>

<property>
    <name>dfs.namenode.http-address.sxt.nn2</name>
    <value>node2:50070</value>
</property>

<!--
这是NameNode读写JNs组的uri。通过此uri，NameNodes可以读写edit log内容
URI的格式"qjournal://host1:port1;host2:port2;host3:port3/journalId"。
这里的host1、host2、host3指的是Journal Node的地址，这里必须是奇数个，至少3个...
通过活动NameNode写入和备用NameNode读取此存储区，使2个NN数据尽可能一致（JournalNodes提供的共享编辑存储）
日志ID是此名称服务唯一标识符，它允许1组JournalNodes为多个联邦名称系统提供存储，虽非要求但重用日志标识符的名称服务ID是好主意
-->
<property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://node1:8485;node2:8485;node3:8485/sxt</value>
</property>

<!-- HDFS客户端用于联系Active NameNode的Java类 
配置将由DFS客户端使用的Java类的名称，以确定哪个NameNode是当前的Active，以及哪个NameNode当前正在为客户端请求提供服务
目前Hadoop附带的唯一的实现是ConfiguredFailoverProxyProvider，所以使用这个，除非你使用的是自定义的 -->
<property>
    <name>dfs.client.failover.proxy.provider.sxt</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>

<!-- SSH到活动NameNode并杀死进程，故障转移期间将用于遏制活动NameNode的脚本或Java类的列表 -->
<property>
    <name>dfs.ha.fencing.methods</name>
    <value>sshfence</value>
</property>

<!-- SSH必须能在不提供密码的情况下通过SSH连接到目标。因此还必须配置dfs.ha.fencing.ssh.private-key-files选项 -->
<property>
    <name>dfs.ha.fencing.ssh.private-key-files</name>
    <value>/root/.ssh/id_rsa</value>
</property>

<!-- 启用故障转移 -->
<property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
</property>
```
#### vim etc/hadoop/core-site.xml
```xml
<!-- 可将Hadoop客户端的默认路径配置为使用新的启用HA的逻辑URI。
如果之前使用“mycluster”作为名称服务标识，则这将是所有HDFS路径的权限部分的值。这可能是这样配置的 -->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://sxt</value>
</property>

<!-- JournalNode守护进程将存储其本地状态的路径 -->
<property>
    <name>dfs.journalnode.edits.dir</name>
    <value>/opt/data/journal</value>
</property>

<!-- 写入ZK信息 -->
<property>
    <name>ha.zookeeper.quorum</name>
    <value>node1:2181,node2:2181,node3:2181</value>
</property>
```
#### 启动顺序
```bash
#启动所有journalnode：
#在设置了所有必要的配置选项之后，必须先在集群中启动JournalNode守护进程，通过如下命令启动并等待守护进程在每台相关机器上启动。

    hadoop-daemon.sh start journalnode

#在其中一个namenode节点执行格式化：
#如果正在设置新的HDFS集群，则应首先在NameNode之一上运行format命令
#如果您已经格式化NameNode，或正在将未启用HA的群集转换为启用HA，则现在应该通过运行命令" hdfs namenode - "
#将您的NameNode元数据目录的内容复制到另一个未格式化的NameNode，bootstrapStandby放在未格式化的NameNode上。
#运行此命令还将确保JournalNodes（由dfs.namenode.shared.edits.dir配置）包含足够的编辑事务，以便能够启动两个NameNode。

    hdfs namenode -format

# 附：
#     #将给定NameNode的状态转换为Active或Standby
#     hdfs haadmin -transitionToActive <serviceId>
#     hdfs haadmin -transitionToStandby <serviceId>
#     #在两个NameNode之间启动故障转移
#     hdfs haadmin -failover [--forcefence] [--forceactive] <serviceId> <serviceId>
#     #确定给定的NameNode是Active还是Standby
#     hdfs haadmin -getServiceState <serviceId>

#在ZooKeeper中初始化所需的状态，可以通过从其中一个NameNode主机运行以下命令来完成此操作。
#这将在自动故障转移系统存储其数据的ZooKeeper中创建一个znode
    
    hdfs zkfc -formatZK


#由于配置中启用了自动故障转移功能，因此start-dfs.sh脚本将自动在任何运行NameNode的计算机上启动ZKFC守护程序。
#当ZKFC启动时，他们将自动选择一个NameNode变为活动状态。

    start-dfs.sh
```
