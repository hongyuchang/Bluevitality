#!/bin/bash

#注意！脚本执行之前需要确定本机的内核参数已经调整为ES需要的值

#当前脚本需要与打包的项目在相同的路径下

set -e
set -x

head_address="本机IP地址"
es_cluster_name="ES-CLUSTER"
es_node_name="node1"
es_network_host="本机IP地址"
es_transport_tcp_port="port"
es_discovery_zen_ping_unicast_hosts="[1.1.1.1:19300]"


origin_path=$(pwd)

#设置JAVA_HOME变量
rm -rf elasticsearch/jdk
echo "#ES_CLUSTER_VARIABLES" >> ~/.bash_profile
cd elasticsearch/jdk1.8.0_101/bin
export PATH=$(pwd):$PATH   #不能存在相同的JAVA_HOME变量，此处仅将JAVA_HOME/bin加入PATH中
echo "PATH=$PATH" >> ~/.bash_profile


#修改配置文件：
cd $origin_path
sed -i '1,2d' elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml       #注意!!!!配置文件中还要修改地址相关
sed -i "s/cluster.name.*/cluster.name: ${es_cluster_name}/" elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
sed -i "s/node.name.*/node.name: ${es_node_name}/g" elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
sed -i "s/network.host.*/network.host: ${es_network_host}/g" elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
sed -i "s/transport.tcp.port.*/transport.tcp.port: ${es_transport_tcp_port}/g" elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml
sed -i "s/discovery.zen.ping.unicast.hosts.*/discovery.zen.ping.unicast.hosts: ${es_discovery_zen_ping_unicast_hosts}/g" \
elasticsearch/elasticsearch-5.5.0/config/elasticsearch.yml

#重新创建软连接，避免旧的软连接失效
rm -rf elasticsearch/head
cd elasticsearch && ln -s elasticsearch-head-master head
cd ..

cd elasticsearch/node-v8.1.4-linux-x64/bin
echo "#ES_CLUSTER_VARIABLES" >> ~/.bash_profile
export PATH=$(pwd):$PATH
echo "PATH=$PATH" >> ~/.bash_profile

cd $origin_path

sed -i '4354s/10.0.0.4/这里用变量改成要用的值/' elasticsearch/head/_site/app.js 

#启动ES：
cd $origin_path && . ~/.bash_profile
. ~/.bash_profile
cd elasticsearch/elasticsearch-5.5.0/bin/ ; ./elasticsearch -d

#启动HEAD
cd $origin_path
cd elasticsearch/head/node_modules/grunt/bin/
nohup ./grunt server 1> /dev/null &

exit 0
