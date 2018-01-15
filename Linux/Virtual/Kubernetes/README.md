#### 备忘
```txt
可以把kubernetes理解为容器级别的自动化运维工具
之前的针对操作系统的自动化运维工具如 puppet, saltstack, chef...
它们所做的工作是确保代码状态的正确, 配置文件状态的正确, 进程状态的正确, 本质是状态本身的维护
而kubernetes实际上也是状态的维护, 只不过是容器级别的状态维护
且kubernetes在容器级别要做到不仅仅状态的维护, 还需要docker跨机器之间通信的问题...
其设计理念和功能其实就是一个类似Linux的分层架构
```
####  kubernetes 组件
```txt
etcd        保存了整个集群的状态
apiserver   提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制
Container runtime   负责镜像管理以及Pod和容器的真正运行（CRI）
controller manager  负责维护集群的状态，比如故障检测、自动扩展、滚动更新等
kube-proxy  负责为Service提供cluster内部的服务发现和负载均衡
scheduler   负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上
kubelet     负责维护容器的生命周期，同时也负责Volume（CVI）和网络（CNI）的管理

除核心组件外还有一些推荐的Add-ons：
    kube-dns    负责为整个集群提供DNS服务
    Heapster    提供资源监控
    Dashboard   提供GUI
    Federation  提供跨可用区的集群
    Ingress Controller      为服务提供外网入口
    Fluentd-elasticsearch   提供集群日志采集、存储与查询
```
