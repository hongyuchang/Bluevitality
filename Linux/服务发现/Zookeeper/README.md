#### 备忘：
```
集群角色
    在ZooKeeper中，有三种角色：
        Leader
        Follower
        Observer
        一个ZooKeeper集群同一时刻只会有一个Leader，其他都是Follower或Observer。

ZooKeeper配置很简单，每个节点的配置文件 zoo.cfg 都是一样的，只有myid文件不一样

Zookeeper类似集群工作的协调者 又可以作为最为集群中存放"全局"变量的角色（不适应存放大量）
所有分布式的协商和一致都可以利用zk实现。可理解为一个分布式的带有订阅功能的小型元数据库。
它是分布式，开源的分布式应用程序协调服务，它是集群的管理者，监视着集群中各节点状态根据节点提交的反馈进行下一步合理操作
```
#### 部署
```bash
#解压
[root@localhost ~]# ll zookeeper-3.4.10.tar.gz 
-rw-r--r--. 1 root root 35042811 3月  19 2018 zookeeper-3.4.10.tar.gz
[root@localhost ~]# tar -zxf zookeeper-3.4.10.tar.gz -C /usr/local/
[root@localhost ~]# cd /usr/local/zookeeper-3.4.10/
[root@localhost zookeeper-3.4.10]# ls
bin         docs             NOTICE.txt            zookeeper-3.4.10.jar
build.xml   ivysettings.xml  README_packaging.txt  zookeeper-3.4.10.jar.asc
conf        ivy.xml          README.txt            zookeeper-3.4.10.jar.md5
contrib     lib              recipes               zookeeper-3.4.10.jar.sha1
dist-maven  LICENSE.txt      src

#创建Zookeeper下的Data及日志目录，ID
[root@localhost zookeeper-3.4.10]# mkdir -p {data,logs} ; touch data/myid
[root@localhost zookeeper-3.4.10]# echo '<本节点ID号>' > data/myid

#设置环境变量
[root@localhost zookeeper-3.4.10]# pwd -P
/usr/local/zookeeper-3.4.10
[root@localhost zookeeper-3.4.10]# export ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10/
[root@localhost zookeeper-3.4.10]# export PATH=$ZOOKEEPER_HOME/bin:$PATH
[root@localhost zookeeper-3.4.10]# export PATH
[root@localhost zookeeper-3.4.10]# vim /etc/profile.d/zookeeper.sh
export ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10/
export PATH=$ZOOKEEPER_HOME/bin:$PATH
export PATH
[root@localhost zookeeper-3.4.10]# source /etc/profile

#配置文件，注意！遇到了编码问题，生产环境中不要使用中文
[root@localhost zookeeper-3.4.10]# cd conf
[root@localhost conf]# vim zoo.cfg
#心跳基本时间单位，C/S间交互的基本时间单元"ms"
tickTime=2000
#集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数，相当于最大等待时间
initLimit=10
#Leader与Follower之间发送消息，请求和应答的时间长度
syncLimit=5
#保存Zookeeper数据的路径，即内存数据库快照存放地址
dataDir=/home/smrz/wangyu/zookeeper-3.4.10/data
#保存Zookeeper日志的路径，当此配置不存在时默认路径与dataDir一致
dataLogDir=/home/smrz/wangyu/zookeeper-3.4.10/logs
#客户端访问Zookeeper时使用的端口号
clientPort=13331
#默认1000，当Server没有空闲来处理更多的客户端请求时，还是允许C端将请求提交到S以提高吞吐性能
#为防止Server内存溢出，这个请求堆积数还是要限制一下  
globalOutstandingLimit=1000

#集群成员相关配置，单节点不需要
server.1=192.168.220.128:2888:3888  #需要在此节点的Zookeeper/data目录下执行 echo '1' > /data/myid 来标明其ID号 
server.2=192.168.220.128:4888:5888  #同上...
server.3=192.168.220.128:6888:7888  #同上...
# 格式说明：server.A=B:C:D
# A是一个数字，标识其是第几号服务器
# B是服务器的IP地址
# C指明此节点与集群中的Leader服务器交换信息的端口
# D标识的是万一集群中的Leader服务器挂了，需要一个端口来重新选出一个新的Leader，此即用来执行选举时服务器间的通信端口

#启动Zookeeper，在分布式环境中，下面的启动命令要尽量在同一时间内启动
[root@localhost conf]# cd ..
[root@localhost zookeeper-3.4.10]# cd bin/
[root@localhost bin]# ./zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED


#查看进程
[root@localhost bin]# ps -ef | grep zookeeper
root      24032      1  1 19:39 pts/0    00:00:00 java -Dzookeeper.log.dir=. -Dzookeeper.root.logger=INFO,CONSOLE -cp /usr/local/zookeeper-3.4.10/bin/../build/classes:/usr/local/zookeeper-3.4.10/bin/../build/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/netty-3.10.5.Final.jar:/usr/local/zookeeper-3.4.10/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper-3.4.10/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper-3.4.10/bin/../zookeeper-3.4.10.jar:/usr/local/zookeeper-3.4.10/bin/../src/java/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../conf: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false org.apache.zookeeper.server.quorum.QuorumPeerMain /usr/local/zookeeper-3.4.10/bin/../conf/zoo.cfg

#查看状态
[root@localhost bin]# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: standalone

#连接服务端
[root@localhost bin]# ./zkCli.sh –server 127.0.0.1:13331
Connecting to localhost:2181
2017-06-28 20:20:29,331 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
2017-06-28 20:20:29,334 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=localhost
2017-06-28 20:20:29,334 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.7.0_45
2017-06-28 20:20:29,335 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2017-06-28 20:20:29,335 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/jre
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/usr/local/zookeeper-3.4.10/bin/../build/classes:/usr/local/zookeeper-3.4.10/bin/../build/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper-3.4.10/bin/../lib/netty-3.10.5.Final.jar:/usr/local/zookeeper-3.4.10/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper-3.4.10/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper-3.4.10/bin/../zookeeper-3.4.10.jar:/usr/local/zookeeper-3.4.10/bin/../src/java/lib/*.jar:/usr/local/zookeeper-3.4.10/bin/../conf:
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=2.6.32-431.el6.x86_64
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2017-06-28 20:20:29,336 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2017-06-28 20:20:29,337 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/usr/local/zookeeper-3.4.10/bin
2017-06-28 20:20:29,338 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@5e411af2
ZooKeeper -server host:port cmd args
        connect host:port
        get path [watch]
        ls path [watch]
        set path data [version]
        rmr path
        delquota [-n|-b] path
        quit 
        printwatches on|off
        create [-s] [-e] path data acl
        stat path [watch]
        close 
        ls2 path [watch]
        history 
        listquota path
        setAcl path acl
        getAcl path
        sync path
        redo cmdno
        addauth scheme auth
        delete path [version]
        setquota -n|-b val path
```

