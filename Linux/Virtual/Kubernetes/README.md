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
#### 概念指南
```txt
Cluster :       是指由Kubernetes使用一系列的物理机/虚拟机和其他基础资源来运行你的应用程序
Node :          是一个运行着Kubernetes的物理机/虚拟机，并且pod可在其上被调度
Pod :           其对应由相关容器和卷组成的容器组，是管理，创建，计划的最小单元.其包含一或多个紧密相连的应用
                Pod通过提供一个高层次抽象而不是底层的接口简化了应用的部署及管理
                Pod的位置管理，拷贝复制，资源共享，依赖关系都是自动处理的，主要特点是支持同地协作
                同一Pod中的应用可共享磁盘，磁盘是Pod级的，应用可通过文件系统调用...
                PID 命名空间（同一个Pod中应用可以看到其它进程）
                NET 命名空间（同一个Pod的中的应用对相同的IP地址和端口有权限）
                IPC 命名空间（同一个Pod中的应用可以通过VPC或者POSIX进行通信）
                UTS 命名空间（同一个Pod中的应用共享一个主机名称）
Label :         一个label是一个被附加到资源上的键/值对，譬如附加到一个Pod上，为它传递一个用户自定的并且可识别的属性.
                Label还可以被应用来组织和选择子网中的资源，标签对内核系统是没有直接意义的
selector        是一个通过匹配labels来定义资源之间关系得表达式，例如为一个负载均衡的service指定所目标Pod.
Replication Controller :    replication controller 是为了保证一定数量被指定的Pod的复制品在任何时间都能正常工作.
                            它不仅允许复制的系统易于扩展，还会处理当pod在机器在重启或发生故障的时候再次创建一个
                            和直接创建的pod不同的是，Replication Controller会替换掉那些删除的或者被终止的pod
                            不管删除的原因是什么（维护，更新，RC都不关心）基于此，建议即使是只创建1个pod也要用RC...
                            Replication Controller像是进程管理器，监管不同node上的多个pod,而不仅是监控1个node的pod
                            "RC"只对那些RestartPolicy=Always的Pod的生效，RestartPolicy的默认值就是Always
Service :       一个service定义了访问pod的方式，就像单个固定的IP地址和与其相对应的DNS名之间的关系。
Volume:         一个volume是一个目录，可能会被容器作为未见系统的一部分来访问。（了解Volume详情）
Kubernetes volume           构建在Docker Volumes之上,并且支持添加和配置volume目录或者其他存储设备。
Secret :        Secret 存储了敏感数据，例如能允许容器接收请求的权限令牌。
Name :          用户为Kubernetes中资源定义的名字
Namespace :     Namespace 好比一个资源名字的前缀。它帮助不同的项目、团队或是客户可以共享cluster
                例如防止相互独立的团队间出现命名冲突
Annotation :    相对于label来说可以容纳更大的键值对，它对我们来说可能是不可读的数据，只是为了存储不可识别的辅助数据
                尤其是一些被工具或系统扩展用来操作的数据
```
