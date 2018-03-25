```txt
注意! 在5.1中，elasticsearch-head：
    不能放在elasticsearch的 plugins、modules 目录下
    不能使用 elasticsearch-plugin install

版本：5.5.0
其他依赖或插件：
    Jdk1.8
    Nodejs
    Head
    Kibana
    x-pack
    ik
```
#### 部署 Elasticsearch 5.5.0 
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
[wangyu@localhost ~]$ export "PATH=$PATH" >> ~/.bash_profile && . ~/.bash_profile

#ES5对系统ulimit有要求，此操作要Root权限，并且对对安装elasticsearch的用户修改ulimit信息，最终使用非root账户启动
cat >> /etc/security/limits.conf <<eof
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096
eof

#修改proc
cat >> /etc/sysctl.conf <<eof
fs.file-max = 1000000
vm.max_map_count=262144
vm.swappiness = 1
eof

sysctl -p

#ES的三个配置文件说明
config/elasticsearch.yml   #主配置文件
config/jvm.options         #JVM参数配置文件
cofnig/log4j2.properties   #日志配置

#部署elasticsearch MasterNode
[wangyu@localhost ~]$ cd ~ && tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim ~/elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
cluster.name: ES-Cluster            #加入的集群名称
node.name: "node1"                  #当前节点名称
network.host: 192.168.133.130       #本节点与其他节点交互时使用的地址，即可访问本节点的路由地址
transport.tcp.port: 19300           #参与集群事物的端口（使用9200端口接收用户请求）
http.port: 9200                     #使用9200接收用户请求（路由地址端口）
http.cors.enabled: true             #由head插件使用
http.cors.allow-origin: "*"         #由head插件使用
node.master: true
discovery.zen.ping.unicast.hosts: ["10.0.0.3:19300"]

#部署elasticsearch DataNode/ClientNode
[wangyu@localhost ~]$ tar -zxf elasticsearch-5.5.0.tar.gz -C ./elasticsearch/
[wangyu@localhost ~]$ vim elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
cluster.name: ES-Cluster
node.name: "1node1"
network.host: 10.0.0.3
transport.tcp.port: 19300
http.port: 9200
#http.cors.enabled: true
#http.cors.allow-origin: "*"
node.master: true                   #该节点是否有资格被选举为master，默认true
discovery.zen.ping.unicast.hosts: ["10.0.0.3:19300"]  #所有节点地址组成的一个列表


#安装HEAD
[wangyu@localhost ~]$ tar -zxf elasticsearch-head-master.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ mv ~/elasticsearch/elasticsearch-head-master ~/elasticsearch/head

#安装Nodejs （Node是HEAD插件的依赖）#版本好像太旧
[wangyu@localhost ~]$ cd ~ && tar -zxf node-v8.1.4-linux-x64.tar.gz -C /home/wangyu/elasticsearch/
[wangyu@localhost ~]$ cd /home/wangyu/elasticsearch/node-v8.1.4-linux-x64/
[wangyu@localhost node-v8.1.4-linux-x64]$ echo "export NODE_HOME=$(pwd)" >> ~/.bash_profile
[wangyu@localhost node-v8.1.4-linux-x64]$ echo "export PATH=$NODE_HOME/bin:$PATH" >> ~/.bash_profile
[wangyu@localhost node-v8.1.4-linux-x64]$ . ~/.bash_profile
[wangyu@localhost node-v8.1.4-linux-x64]$ cd ~
[wangyu@localhost ~]$ npm -v
5.0.3
[wangyu@localhost ~]$ node -v
v8.1.4

#由于head的代码还是2.6版本，有很多限制，如无法跨机器访问。因此要修改两个地方:
[wangyu@localhost ~]$ cat > /home/wangyu/elasticsearch/head/Gruntfile.js <<EOF
connect: {
    server: {
        options: {
            hostname: '*',
            port: 9100,
            base: '.',
            keepalive: true
        }
    }
}
EOF

#注意! 必须开启root安装bzip2!
[wangyu@localhost ~]# yum -y install bzip2
[wangyu@localhost head]$ sed -i '4354s/localhost/10.0.0.4/' /home/wangyu/elasticsearch/head/_site/app.js 
[wangyu@localhost head]$ npm install -g cnpm --registry=https://registry.npm.taobao.org
[wangyu@localhost head]$ cnpm install


#启动ES：
[wangyu@localhost ~]$ cd ~/elasticsearch/elasticsearch-5.5.0/bin/
[wangyu@localhost bin]$ ./elasticsearch -d

#启动HEAD
cd /home/wangyu/elasticsearch/head/node_modules/grunt/bin/ && ./grunt server 
#nohup ./grunt server &
```
