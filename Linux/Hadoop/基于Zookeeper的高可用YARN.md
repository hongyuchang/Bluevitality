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
