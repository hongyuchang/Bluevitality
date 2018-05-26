#说明：安装hive前提是要先安装hadoop集群，并且hive只需要再hadoop的namenode节点集群里安装即可(需要再所有namenode上安装)
#可以不在datanode节点的机器上安装。另外还需要说明的是，虽然修改配置文件并不需要你已经把hadoop跑起来，但是本文中用到了hadoop命令
#在执行这些命令前你必须确保hadoop是在正常跑着的，而且启动hive的前提也是需要hadoop在正常跑着
#所以建议你先将hadoop跑起来在按照本文操作。有关如何安装和启动hadoop集群，请参考： 

[hadoop@localhost ~]$ tar -zxf apache-hive-2.3.3-bin.tar.gz
[hadoop@localhost ~]$ ln -sv apache-hive-2.3.3-bin hive
[hadoop@localhost ~]$ cat > /etc/profile.d/hive.sh <<'eof'
HIVE_HOME=/home/hadoop/hive
HADOOP_HOME=/hadoop
HIVE_CONF_DIR=$HIVE_HOME/conf
#PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin
PATH=$PATH:$HADOOP_HOME/bin:$HIVE_HOME/bin
export JAVA_HOME JRE_HOME PATH CLASSPATH HADOOP_HOME  HIVE_HOME HIVE_CONF_DIR
eof
[hadoop@localhost ~]$ source /etc/profile
[hadoop@localhost ~]$ cd $HIVE_CONF_DIR
[hadoop@localhost conf]$ cp hive-default.xml.template  hive-site.xml
#因为在hive-site.xml中有这样的配置：
#
#  <name>hive.metastore.warehouse.dir</name>
#  <value>/user/hive/warehouse</value>
#   <name>hive.exec.scratchdir</name>
#  <value>/tmp/hive</value>
# 所以要在Hadoop集群新建/user/hive/warehouse目录，执行命令
[hadoop@localhost conf]$ cd $HADOOP_HOME
[hadoop@localhost hadoop]$ bin/hadoop fs -mkdir -p  /user/hive/warehouse #创建目录
[hadoop@localhost hadoop]$ bin/hadoop fs -chmod -R 777 /user/hive/warehouse #新建的目录赋予读写权限
[hadoop@localhost hadoop]$ bin/hadoop fs -mkdir -p /tmp/hive #新建/tmp/hive/目录
[hadoop@localhost hadoop]$ bin/hadoop fs -chmod -R 777 /tmp/hive #目录赋予读写权限
[hadoop@localhost hadoop]$ bin/hadoop fs -ls /user/hive     #验证
[hadoop@localhost hadoop]$ bin/hadoop fs -ls /tmp/hive      #验证

将hive-site.xml文件中的${system:java.io.tmpdir}替换为hive的临时目录，例如我替换为/usr/local/apache-hive-2.1.1/tmp/，该目录如果不存在则要自己手工创建，并且赋予读写权限。
[hadoop@localhost hadoop]$ cd $HIVE_CONF_DIR
[hadoop@localhost hadoop]$ vim hive-site.xml
# <value>${system:java.io.tmpdir}/${system:user.name}/operation_logs</value>    #HIVE的数据库在hdfs中表现为${hive.metastore.warehouse.dir}目录下一个文件夹
# 改为：
# <value>/home/hadoop/hive/tmp/hadoop/operation_logs</value>
# 说明: 以上给出的只是配置文件中截取了几处以作举例，在替换时候要认真仔细的将所有变量都全部替换掉。
#   sed -i 's@${system:java.io.tmpdir}@/home/hadoop/hive/tmp@g' hive-site.xml
#   sed -i 's@${system:user.name}@hadoop@g' hive-site.xml  
[hadoop@localhost conf]$ mkdir -p $HIVE_HOME/tmp && chmod 777 -R $HIVE_HOME/tmp 


#修改hive-site.xml数据库相关的配置
#javax.jdo.option.ConnectionDriverName，将该name对应的value修改为MySQL驱动类路径：
[hadoop@localhost hadoop]$ vim hive-site.xml
#  <property>
#    <name>javax.jdo.option.ConnectionDriverName</name>
#    <!-- <value>org.apache.derby.jdbc.EmbeddedDriver</value> -->
#    <value>com.mysql.jdbc.Driver</value>
#    <description>Driver class name for a JDBC metastore</description>
#  </property>

# javax.jdo.option.ConnectionURL，将该name对应的value修改为MySQL的地址：
 <name>javax.jdo.option.ConnectionURL</name>
 <value>jdbc:mysql://192.168.44.128:3306/hive?createDatabaseIfNotExist=true</value>
 
#javax.jdo.option.ConnectionUserName，将对应的value修改为MySQL数据库登录名：
<name>javax.jdo.option.ConnectionUserName</name>
<value>root</value>

#javax.jdo.option.ConnectionPassword，将对应的value修改为MySQL数据库的登录密码：
<name>javax.jdo.option.ConnectionPassword</name><value>*******</value>

#将MySQL驱动包上载到Hive的lib目录下
#需要下载mysql的jdbc<mysql-connector-java-5.1.28.jar>，然后将下载后的jdbc放到hive安装包的lib目录 #####################
#下载链接：http://dev.mysql.com/downloads/connector/j/ 
cp /home/dtadmin/spark_cluster/mysql-connector-java-5.1.36.jar $HIVE_HOME/lib/

#新建hive-env.sh文件并进行修改
cd $HIVE_CONF_DIR
cp hive-env.sh.template hive-env.sh #基于模板创建hive-env.sh
vim hive-env.sh #编辑配置文件并加入以下配置：
-------------------------------------------------
export HADOOP_HOME=/home/hadoop/hadoop-2.7.3
export HIVE_CONF_DIR=/usr/local/apache-hive-2.1.1/conf
export HIVE_AUX_JARS_PATH=/usr/local/apache-hive-2.1.1/lib
--------------------------------------------------

启动和测试
有关安装与配置MySQL数据库请参考文章:CentOS7.0安装配置MySQL5.7


对MySQL数据库初始化
#进入到hive的bin目录
cd $HIVE_HOME/bin
#对数据库进行初始化
[hadoop@localhost bin]$ schematool -initSchema -dbType mysql
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/home/hadoop/apache-hive-2.3.3-bin/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/hadoop-2.7.6/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
Metastore connection URL:        jdbc:mysql://192.168.44.128:3306/hive?createDatabaseIfNotExist=true
Metastore Connection Driver :    com.mysql.jdbc.Driver
Metastore connection User:       root
Starting metastore schema initialization to 2.3.0
Initialization script hive-schema-2.3.0.mysql.sql
Initialization script completed
schemaTool completed

执行成功后，在mysql的hive数据库里已生成metadata数据表

启动Hive
cd $HIVE_HOME/bin #进入Hive的bin目录
./hive #执行hive启动

简单测试
成功启动Hive后，会进入hive的命令行模式,下面进行一系列简单测试:
hive> show functions;
OK

执行一系列HIVE命令

在Hadoop的HDFS页面的数据浏览页面上查看




