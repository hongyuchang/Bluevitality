#### 创建2个服务，服务名分别为demo1，demo2
```bash
[root@host-a ~]# docker service create --replicas 2 --network my-network  --name demo1  docker.io/bashell/alpine-bash  ping www.163.com
alrj33okhrqaes9n0l5a65s22
[root@host-a ~]# docker service create --replicas 2 --network my-network  --name demo2  docker.io/bashell/alpine-bash  ping www.qq.com  
55bzqljqmerg17bq4xn9qmgm3
[root@host-a ~]# docker service ls
ID            NAME   REPLICAS  IMAGE                          COMMAND
55bzqljqmerg  demo2  2/2       docker.io/bashell/alpine-bash  ping www.qq.com
alrj33okhrqa  demo1  2/2       docker.io/bashell/alpine-bash  ping www.163.com
```

#### 测试
```bash
[root@host-b ~]# docker ps
CONTAINER ID        IMAGE                                  COMMAND             CREATED             STATUS              PORTS               NAMES
454c481f4349        docker.io/bashell/alpine-bash:latest   "ping www.qq.com"   25 seconds ago      Up 23 seconds                           demo2.1.2yip71mh1aschw596wp6wrkxm
014067903d08        docker.io/bashell/alpine-bash:latest   "ping www.qq.com"   26 seconds ago      Up 24 seconds                           demo2.2.2uks2aqkl2ev2fj3gpzffbfq4
[root@host-b ~]# docker exec -it 014067903d08 bash  #进入demo2
bash-4.4# ping demo1.1.8gb683zx67i0o1wo2gpsjvz0g    #pingdemo1的DNS名称，发现可ping通，使用的是swarm内置的DNS
PING demo1.1.8gb683zx67i0o1wo2gpsjvz0g (10.0.9.3): 56 data bytes
64 bytes from 10.0.9.3: seq=0 ttl=64 time=0.531 ms
64 bytes from 10.0.9.3: seq=1 ttl=64 time=0.609 ms
```
#### 其他相关博文的转载
![img](资料/DNS.png)
