#!/bin/bash
#本次安装的前提是Hadoop环境已经部署完成...

#准备安装包：
#    scala-2.10.4.tgz
#    spark-2.3.0-bin-hadoop2.7.tgz

#安装scala（注：在Spark的所有节点都要安装Scala环境）
tar -zxf scala-2.10.4.tgz && ln -sv scala-2.10.4.tgz scala

cat > /etc/profile.d/scala.sh <<'eof'
export SCALA_HOME=/home/hadoop/scala
export PATH=$SCALA_HOME/bin:$PATH
eof

source /etc/profile

#验证： scala -version

#安装spark
tar -zxf spark-1.3.0-bin-hadoop2.4.tgz && ln -sv spark-1.3.0-bin-hadoop2.4.tgz spark

cd ~/spark/conf && cp spark-env.sh.template spark-env.sh
cat > spark-env.sh <<'eof'
export JAVA_HOME=/home/hadoop/jdk1.8    #部署Spark应使用大于等于1.8以上的版本，否则会报错!
export SCALA_HOME=/home/hadoop/scala
export HADOOP_HOME=/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_LOG_DIR=/home/hadoop/spark/logs
export SPARK_MASTER_IP=node1            #集群的Master节点的ip地址
export SPARK_LOCAL_DIRS=/home/hadoop/spark
export SPARK_WORKER_CORES=16            #每个worker节点所占有的CPU核数目
export SPARK_DRIVER_MEMORY=64G          #每个Worker节点能够最大分配给exectors的内存大小
export SPARK_WORKER_INSTANCES=1         #每台机器上开启的worker节点的数目
eof

vim slave
#在Slaves文件下填上Spark的Slave主机名

#将配置文件拷贝给所有Spark节点（需要注意的是其他的Slave节点同样也需要安装Scala!）
scp spark-env.sh hadoop@:$(pwd)
scp slave hadoop@:$(pwd)

#启动Spark
sbin/start-all.sh

#各节点验证 Spark 是否安装成功
$ jps | grep -iE "Master|Worker"
7805 Master

#URL：    http://master:8080
#CLI：    cd ~/spark/bin && ./spark-shell
---------------------------------------------------------------

#运行示例

#本地模式两线程运行
./bin/run-example SparkPi 10 --master local[2]

#Spark Standalone 集群模式运行
./bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master spark://master:7077 \
    lib/spark-examples-1.3.0-hadoop2.4.0.jar \
    100
  
#Spark on YARN 集群上 yarn-cluster 模式运行
./bin/spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master yarn-cluster \  # can also be `yarn-client`
    lib/spark-examples*.jar \
    10
