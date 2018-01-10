#### 附注：
```
集群角色
在ZooKeeper中，有三种角色：
    Leader
    Follower
    Observer
    一个ZooKeeper集群同一时刻只会有一个Leader，其他都是Follower或Observer。

ZooKeeper配置很简单，每个节点的配置文件(zoo.cfg)都是一样的，只有myid文件不一样。myid的值必须是zoo.cfg中server.{数值}的{数值}部分。
```
