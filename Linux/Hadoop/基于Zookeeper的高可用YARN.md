#### vim yarn-site.xml
```xml
<!-- 启用RM高可用 -->
<property>
    <name>yarn.resourcemanager.ha.enabled</name>
    <value>true</value>
</property>
<!-- 自定义RM的id -->
<property>
    <name>yarn.resourcemanager.cluster-id</name>
    <value>yrc</value>
</property>
<property>
    <name>yarn.resourcemanager.ha.rm-ids</name>
    <value>rm1,rm2</value>
</property>
<!-- 指定分配RM服务的地址 -->
<property>
    <name>yarn.resourcemanager.hostname.rm1</name>
    <value>master1</value>
</property>
<property>
    <name>yarn.resourcemanager.hostname.rm2</name>
    <value>master2</value>
</property>
<property>
    <name>yarn.resourcemanager.webapp.address.rm1</name>
    <value>master1:8088</value>
</property>
<property>
    <name>yarn.resourcemanager.webapp.address.rm2</name>
    <value>master2:8088</value>
</property>
<!-- 指定zk集群地址 -->  
<property>
    <name>yarn.resourcemanager.zk-address</name>
    <value>master1:2181,master2:2181,worker1:2181</value>
</property>
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<!--开启故障自动切换-->    
<property>  
    <name>yarn.resourcemanager.ha.automatic-failover.enabled</name>  
    <value>true</value>  
</property>

<property>  
    <name>yarn.resourcemanager.ha.automatic-failover.zk-base-path</name>  
    <value>/yarn-leader-election</value>  
</property> 

<!--开启自动恢复功能-->    
<property>   
    <name>yarn.resourcemanager.recovery.enabled</name>    
    <value>true</value>    
</property>   
<property>  
    <name>yarn.resourcemanager.store.class</name>  
    <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>  
</property>  
```
#### 启动YARN、查看Yarn节点状态
```bash
# Step1 正常启动hadoop集群
$ start-yarn.sh

# Step2 在另外配置的ResourceManger上启动服务（单独启用备用resourcemanager）
$ yarn-daemon.sh start resourcemanager

#查看状态
$ yarn rmadmin -getServiceState rm1
 active
$ yarn rmadmin -getServiceState rm2
 standby
```
```txt
Configuration Property	Description
yarn.resourcemanager.zk-address	zk-quorum的地址。同时用于状态存储和leader选举。
yarn.resourcemanager.ha.enabled	Enable RM HA
yarn.resourcemanager.ha.rm-ids	RM的逻辑id，比如"rm1,rm2"
yarn.resourcemanager.hostname.rm-id	对于每个rm-id，声明一个对应的主机名，也可以声明rm的服务地址来替换。
yarn.resourcemanager.ha.id	在全体中识别RM。可选参数；如果设置了，admin需要确保所有的RM都有属于自己的id。
yarn.resourcemanager.ha.automatic-failover.enabled	启动自动failover；只有在HA启动的情况下默认启动。
yarn.resourcemanager.ha.automatic-failover.embedded	当启用自动failover后，使用内置的leader选举来选主RM。只有当HA启用时默认是开启的。
yarn.resourcemanager.cluster-id	标识集群。被elector用来确保RM不会接管另一个集群，即不会成为其他集群的主RM。
yarn.client.failover-proxy-provider	Clients, AMs NMs连接主RM，实现failover的类
yarn.client.failover-max-attempts	FailoverProxyProvider尝试failover的最大次数。
yarn.client.failover-sleep-base-ms	failover之间计算延迟的睡眠时间（单位是毫秒）
yarn.client.failover-sleep-max-ms	failover之间的睡眠最大时间（单位毫秒）
yarn.client.failover-retries	每次连接RM的重试次数。
yarn.client.failover-retries-on-socket-timeouts	每次连接RMsocket超时的重试次数。
```
