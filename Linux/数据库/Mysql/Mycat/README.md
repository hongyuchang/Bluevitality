#### Mycat 部署流程
```bash
[root@localhost ~]# mysql_install_db            #数据库初始化
[root@localhost ~]# systemctl start mariadb     #启动数据库服务
[root@localhost ~]# cat /etc/my.cnf             #修改配置文件，加入参数：lower_case_table_names = 1  
[mysqld]
.......(略)                                     #注意：远程 mysql 必须允许 mycat主机进行远程连接
lower_case_table_names = 1                      #表名存储在磁盘是小写的，但比较时不区分大小写

[root@localhost ~]# mysql -u <username> -p<password>                        #创建测试数据库
MariaDB [(none)]> CREATE database db1;
MariaDB [(none)]> CREATE database db2;
MariaDB [(none)]> CREATE database db3;

[root@localhost ~]# tar -zxvf jdk-8u91-linux-x64.tar.gz -C /usr/local       #安装JDK
[root@localhost ~]# cat /etc/profile.d/java.sh                              #设置环境变量
export JAVA_HOME=/usr/java/jdk1.8.0_91   
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar  
export PATH=$PATH:$JAVA_HOME/bin
[root@localhost ~]# source /etc/profile
[root@localhost ~]# java -version                                           #测试安装是否正确
openjdk version "1.8.0_151"
OpenJDK Runtime Environment (build 1.8.0_151-b12)
OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)

[root@localhost ~]# tar -zxf Mycat-server-1.6-RELEASE-20161012170031-linux.tar.gz -C /usr/local/
[root@localhost ~]# groupadd mycat                                          #创建运行用户
[root@localhost ~]# adduser -r -g mycat mycat                               #
[root@localhost ~]# chown -R mycat.mycat /usr/local/mycat                   #
[root@localhost ~]# cd /usr/local/mycat/
[root@localhost ~]# vim /usr/local/mycat/conf/schema.xml                    #修改Myscat配置文件
......                                                                      #配置mycat的用户名密码
<user name="root">
   <property name="password">MYCAT_PASSOWRD</property>
   <property name="schemas">TESTDB</property>
</user>
......                                                                      #设置读写分离
<writeHost host="hostM1" url="<address>:<port>" user="<user>" password="<password>">
    <readHost host="hostS1" url="<address>:<port>" user="<user>" password="<password>" />
</writeHost>
.....
[root@localhost ~]# /usr/local/mycat/bin/mycat start                                #启动mycat
[root@localhost ~]# mysql -uroot -pMYCAT_PASSOWRD -h127.0.0.1 -P8066 -DTESTDB       #链接mycat
MariaDB [(none)]> use TESTDB;                                                       #创建测试数据
MariaDB [(none)]> create table company(id int not null primary key,name varchar(50),addr varchar(255));
MariaDB [(none)]> insert into company values(1,"facebook","usa");
[root@localhost ~]# #验证其他数据库是否存在相同数据...
```
