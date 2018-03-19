![img](资料/RocketMQ.png)
#### 备忘
```txt
NameServer: 
    提供轻量级的服务发现和路由。 每个 NameServer 记录完整的路由信息，提供等效的读写服务，并支持快速存储扩展。
    
Broker: 
    通过提供轻量级的 Topic 和 Queue 机制来处理消息存储,同时支持推（push）和拉（pull）模式以及主从结构的容错机制。

Producer：
    生产者，产生消息的实例，拥有相同 Producer Group 的 Producer 组成一个集群。

Consumer：
    消费者，接收消息进行消费的实例，拥有相同 Consumer Group 的

Consumer 
    组成一个集群。
```

#### 部署
```bash

```
