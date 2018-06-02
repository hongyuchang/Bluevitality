spark部署：

#准备安装包：
#    scala-2.10.4.tgz
#    spark-2.3.0-bin-hadoop2.7.tgz

#安装scala
tar -zxvf scala-2.10.4.tgz
ln -sv scala-2.10.4.tgz scala

cat > /etc/profile.d/scala.sh <<'eof'
export SCALA_HOME=/home/hadoop/scala
export PATH=$SCALA_HOME/bin:$PATH
eof

source /etc/profile

#验证：
scala -version


#安装spark
tar -zxvf spark-1.3.0-bin-hadoop2.4.tgz
ln -sv spark-1.3.0-bin-hadoop2.4.tgz spark

cd ~/spark/conf
cp spark-env.sh.template spark-env.sh
cat > spark-env.sh <<'eof'
export SCALA_HOME=/home/hadoop/scala
#部署Spark应使用大于等于1.8以上的版本，否则会报错!
export JAVA_HOME=/home/hadoop/jdk1.8
export HADOOP_HOME=/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
SPARK_MASTER_IP=node1
SPARK_LOCAL_DIRS=/home/hadoop/spark
SPARK_DRIVER_MEMORY=1G
eof

vim slave
#在Slaves文件下填上Spark的Slave主机名

#将配置文件拷贝给所有Spark节点
scp spark-env.sh hadoop@:$(pwd)
scp slave hadoop@:$(pwd)

#启动Spark
sbin/start-all.sh


#验证 Spark 是否安装成功
$ jps | grep -iE "Master|Worker"
7805 Master

#访问：
http://master:8080

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
