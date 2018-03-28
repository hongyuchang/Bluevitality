```txt
注意! 在ES的5.X >= Version下的elasticsearch-head：
    不能放在elasticsearch的plugins、modules目录下
    不能使用elasticsearch-plugin install

版本：5.5.0
其他依赖或插件：
    Jdk1.8
    Nodejs   作为head插件的依赖被安装
    Head     提供Node管理及可视化RestfulAPI接口
    Kibana
    x-pack   注意! 必须运行与Elasticsearch版本相匹配的X-Pack版本!
    ik       同上...
```
#### 软件列表
```txt
   32M  elasticsearch-5.5.0.tar.gz
  812K  elasticsearch-head-master.tar.gz
  3.2M  elasticsearch-analysis-ik-5.5.0.zip
  173M  jdk.tar.gz
   16M  node-v8.1.4-linux-x64.tar.gz
  153M  x-pack-5.5.0.zip
```
#### 部署 Elasticsearch 5.5.0、head、x-pack、ik
```bash
#ES5.X依赖JAVA Version >= 1.8，注! ES不能运行在CentOS 7以下的Linux上
#多机集群中的节点可以分为Master nodes和Data nodes
#在配置文件中使用Zen发现 (Zen discovery) 机制来管理不同节点，Zen发现是ES自带的默认发现机制，其用多播发现其它节点。
#只要启动一个新的ES节点并设置和集群相同的名称，次节点即被加入到集群内

#使用非root用户安装JDK
[wangyu@localhost ~]$ mkdir elasticsearch
[wangyu@localhost ~]$ tar -zxf jdk.tar.gz -C /home/wangyu/elasticsearch
[wangyu@localhost ~]$ ln -s /home/wangyu/elasticsearch/jdk1.8.0_101 /home/wangyu/elasticsearch/jdk
[wangyu@localhost ~]$ cd /home/wangyu/elasticsearch/jdk
[wangyu@localhost ~]$ export JAVA_HOME=$(pwd) && export PATH=$JAVA_HOME/bin:$PATH
[wangyu@localhost ~]$ echo "PATH=$PATH" >> ~/.bash_profile && . ~/.bash_profile

#ES5对系统ulimit有要求，此操作要Root权限，并且对对安装elasticsearch的用户修改ulimit信息，最终使用非root账户启动
[root@localhost ~]# yum -y install bzip2 git unzip maven
[root@localhost ~]# cat >> /etc/security/limits.conf <<eof
* soft nofile 655350
* hard nofile 655350
* soft nproc 655350
* hard nproc 655350
eof

#修改proc
[root@localhost ~]# cat >> /etc/sysctl.conf <<eof
fs.file-max = 1000000
vm.max_map_count=262144
vm.swappiness = 1
eof

[root@localhost ~]# vim /etc/security/limits.d/90-nproc.conf  #添加or修改如下参数
* soft nproc 102400

[root@localhost ~]# sysctl -p

#ES的三个配置文件说明
config/elasticsearch.yml   #主配置文件
config/jvm.options         #JVM参数配置文件
cofnig/log4j2.properties   #日志配置

#部署 MasterNode
[wangyu@localhost ~]$ cd ~ && tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim ~/elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
path.data: /home/wangyu/elasticsearch/elasticsearch-5.5.0/data
path.logs: /home/wangyu/elasticsearch/elasticsearch-5.5.0/logs
cluster.name: ES-Cluster            #加入的集群名称
node.name: "node1"                  #当前节点名称
network.host: 10.0.0.3              #本节点与其他节点交互时使用的地址，即可访问本节点的路由地址
transport.tcp.port: 19300           #参与集群事物的端口（使用9200端口接收用户请求）
http.port: 9200                     #使用9200接收用户请求（路由地址端口）
http.cors.enabled: true             #由head插件使用
http.cors.allow-origin: "*"         #由head插件使用
node.master: true
discovery.zen.ping.unicast.hosts: ["10.0.0.3:19300",...........]     #所有Master组成的列表

#部署 DataNode/ClientNode （在其他的节点）
[wangyu@localhost ~]$ tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
path.data: /home/wangyu/elasticsearch/elasticsearch-5.5.0/data
path.logs: /home/wangyu/elasticsearch/elasticsearch-5.5.0/logs
cluster.name: ES-Cluster
node.name: "1node1"
network.host: 10.0.0.4
transport.tcp.port: 19300
http.port: 9200
#http.cors.enabled: true
#http.cors.allow-origin: "*"
node.master: true                   #该节点是否有资格被选举为master，默认true
discovery.zen.ping.unicast.hosts: ["10.0.0.3:19300",..........]

#安装HEAD
[wangyu@localhost ~]$ tar -zxf elasticsearch-head-master.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ ln -s ~/elasticsearch/elasticsearch-head-master ~/elasticsearch/head

#安装Nodejs （Node是HEAD插件的依赖）
[wangyu@localhost ~]$ cd ~ && tar -zxf node-v8.1.4-linux-x64.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ cd /home/wangyu/elasticsearch/node-v8.1.4-linux-x64/
[wangyu@localhost node-v8.1.4-linux-x64]$ export NODE_HOME=$(pwd)
[wangyu@localhost node-v8.1.4-linux-x64]$ export PATH=$NODE_HOME/bin:$PATH && echo "PATH=$PATH" >> ~/.bash_profile
[wangyu@localhost node-v8.1.4-linux-x64]$ . ~/.bash_profile    #验证安装成功： node -v && npm -v

#由于head的代码还是2.6版本，有很多限制，如无法跨机器访问。因此要修改两个地方:
[wangyu@localhost ~]$ vim +92 /home/wangyu/elasticsearch/head/Gruntfile.js
connect: {
    server: {
        options: {              #约92行附近，增加hostname字段如下
            hostname: '*',      #
            port: 9100,
            base: '.',
            keepalive: true
        }
    }
}

#注意! 最小化安装的系统在执行如下命令前须开启root安装bzip2，npm下载文件时会使用其对文件进行解压
[wangyu@localhost ~]$ sed -i '4354s/localhost/10.0.0.4/' /home/wangyu/elasticsearch/head/_site/app.js 
[wangyu@localhost ~]$ npm install -g cnpm --registry=https://registry.npm.taobao.org  #若报错多执行几次
[wangyu@localhost ~]$ cd ~/elasticsearch/head/
[wangyu@localhost head]$ cnpm install

#安装X-pack，X-pack安装成功后需要修改elasticsearch配置才能配合head插件来使用（暂时不安装，有问题）
[wangyu@localhost ~]$ cd ~/elasticsearch/elasticsearch-5.5.0/bin/
[wangyu@localhost bin]$ ./elasticsearch-plugin install file:///home/wangyu/x-pack-5.5.0.zip  #根据提示输入yes
# ES内的x-pack插件配置段如下：
# http.cors.allow-headers: "Authorization"
# xpack.security.enabled: false
# xpack.monitoring.exporters.my_local:
#   type: local
#   index.name.time_format: YYYY.MM

#安装IK分词，其版本必须与ES严格一致，IK地址：https://github.com/medcl/elasticsearch-analysis-ik/tree/5.x
[wangyu@localhost bin]$ cd ~ && unzip elasticsearch-analysis-ik-5.5.0.zip -d ~/elasticsearch/
[wangyu@localhost bin]$ cd ~/elasticsearch/elasticsearch-analysis-ik-5.5.0 ; mvn package  #内存较小的话比较耗时
[wangyu@localhost elasticsearch-analysis-ik-5.5.0]$ mkdir -p ~/elasticsearch/elasticsearch-5.5.0/plugins/ik && \
unzip -d ~/elasticsearch/elasticsearch-5.5.0/plugins/ik ./target/releases/elasticsearch-analysis-ik-5.5.0.zip

#启动ES：
cd ~/elasticsearch/elasticsearch-5.5.0/bin/ ; ./elasticsearch -d

#启动HEAD
cd /home/wangyu/elasticsearch/head/node_modules/grunt/bin/ ; nohup ./grunt server &
```
#### 测试IK分词插件
```bash
[root@localhost ~]# curl -XGET 'http://10.0.0.3:9200/_analyze?pretty&analyzer=ik_max_word' -d '这是一个测试'
[root@localhost ~]# curl -XGET 'http://10.0.0.3:9200/_analyze?pretty&analyzer=ik_smart' -d '这是一个测试'
{
  "tokens" : [
    {
      "token" : "这是",
      "start_offset" : 0,
      "end_offset" : 2,
      "type" : "CN_WORD",
      "position" : 0
    },
    {
      "token" : "一个",
      "start_offset" : 2,
      "end_offset" : 4,
      "type" : "CN_WORD",
      "position" : 1
    },
    {
      "token" : "测试",
      "start_offset" : 4,
      "end_offset" : 6,
      "type" : "CN_WORD",
      "position" : 2
    }
  ]
}
```
