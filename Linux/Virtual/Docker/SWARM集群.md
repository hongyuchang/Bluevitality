#### 环境
```txt
	Host-A	--->	Master
	Host-B 	--->	Node-1
	Host-C 	--->	Node-2
```
#### 说明
```txt
Swarm支持设置一组Manager Node，通过支持多Manager Node实现HA
Docker 1.12中Swarm已内置了服务发现工具，不再需要像以前使用 Etcd 或 Consul 这些工具来配置服务发现
对于容器来说若没有外部通信但又是运行中的状态会被服务发现工具认为是 Preparing 状态，但若映射了端口则会是 Running 状态。
docker service [ls/ps/rm/scale/inspect/update]

Swarm使用Raft协议保证多Manager间状态的一致性。基于Raft协议，Manager Node具有一定容错功能（可容忍最多有(N-1)/2个节点失效）
每个Node的配置可能不同，比如有的适合CPU密集型应用，有的适合运行IO密集型应用
Swarm支持给每个Node添加标签元数据，这样可根据Node标签来选择性地调度某个服务部署到期望的一组Node上
```
#### 各节点加入swarm集群
```bash
#master节点创建集群并将其他节点加入swarm集群中
[root@host-a ~]# docker swarm init --advertise-addr 192.168.0.3     #IP地址为本节点在集群中对外的地址
Swarm initialized: current node (c4aa18akyid7wctl4e0hpbqmr) is now a manager.
To add a worker to this swarm, run the following command:           #下列输出说明如何将Worker Node加入到集群

    docker swarm join \
    --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
    192.168.0.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

[root@host-b ~]# docker swarm join \
> --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
> 192.168.0.3:2377
This node joined a swarm as a worker.

[root@host-c ~]# docker swarm join \
> --token SWMTKN-1-17d18kwcn6mef2usiz7p7d38txo6az4rrdxqzxtwdi9qvmrxwx-48hhk1wzm51sjcktwnbnm7qgl \
> 192.168.0.3:2377
This node joined a swarm as a worker.

[root@host-a ~]# docker node ls   #查看swarm集群节点信息
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
3fcyk6uf3l161uk6p3x1xwpsv    host-b    Ready   Active        
ags2l01cijtxux8kq0ft4mz8l    host-c    Ready   Active        
c4aa18akyid7wctl4e0hpbqmr *  host-a    Ready   Active        Leader
#Active：该Node可被指派Task
#Pause： 该Node不可被指派新Task，但其他已存在的Task保持运行（暂停一个Node后该其不再接收新的Task）
#Drain： 该Node不可被指派新Task，Swarm Scheduler停掉已存在的Task并将它们调度到可用Node上（进行停机维护时可修改\
         AVAILABILITY为Drain状态）

#查看Node状态
[root@host-a ~]# docker node inspect self
[
    {
        "ID": "c4aa18akyid7wctl4e0hpbqmr",
        "Version": {
            "Index": 10
        },
        "CreatedAt": "2017-12-29T16:04:28.575482252Z",
        "UpdatedAt": "2017-12-29T16:04:28.590768171Z",
        "Spec": {
            "Role": "manager",
            "Availability": "active"
        },
        "Description": {
            "Hostname": "host-a",
            "Platform": {
                "Architecture": "x86_64",
                "OS": "linux"
            },
            "Resources": {
                "NanoCPUs": 4000000000,
                "MemoryBytes": 2082357248
            },
            "Engine": {
                "EngineVersion": "1.12.6",
                "Plugins": [
                    {
                        "Type": "Network",
                        "Name": "bridge"
                    },
                    {
                        "Type": "Network",
                        "Name": "host"
                    },
                    {
                        "Type": "Network",
                        "Name": "null"
                    },
                    {
                        "Type": "Network",
                        "Name": "overlay"
                    },
                    {
                        "Type": "Volume",
                        "Name": "local"
                    }
                ]
            }
        },
        "Status": {
            "State": "ready"
        },
        "ManagerStatus": {
            "Leader": true,
            "Reachability": "reachable",
            "Addr": "192.168.0.3:2377"
        }
    }
]
```
