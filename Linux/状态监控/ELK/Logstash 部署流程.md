#### 安装
```bash
#分别在Logstash的各Node节点执行如下：
any_node ~]# yum -y install java-1.8.0-openjdk
any_node ~]# yum -y install java-1.8.0-openjdk-devel.x86_64
any_node ~]# echo "export JAVA_HOME=/usr" > /etc/profile.d/java.sh      #要保证环境变量JAVA_HOME正确设置
any_node ~]# . /etc/profile
any_node ~]# yum -y install logstash-1.5.4-1.noarch.rpm                 #本地安装

any_node ~]# echo "export PATH=/opt/logstash/bin:$PATH" > /etc/profile.d/logstash.sh 
any_node ~]# . /etc/profile                                             #其二进制文件放在了opt/logstash目录下

any_node ~]# rpm -ql logstash | grep -v opt         
/etc/init.d/logstash
/etc/logrotate.d/logstash
/etc/logstash/conf.d
/etc/sysconfig/logstash
/var/lib/logstash
/var/log/logstash
```
#### 配置举例 （ 使用 stdin 与 stdout 插件 ）
```bash
any_node ~]# cd /etc/logstash/conf.d     #此目录下所有的conf后缀都是配置文件                 
any_node conf.d]# vim simple.conf        #一般用于定义使用的插件及参数，如：从哪里得到数据，从哪里输出数据...
input {                                  #定义输入
        stdin {}                         #使用stdin插件实现从标准输入获取数据
}                                        #
    
output {                                 #定义输出
        stdout {                         #使用stdout插件实现输出到标准输出
                codec => rubydebug       #定义编码插件，使用的编码是rubydebug（其中的 XXX "=>" XXX 即键与值）
        }                                #
}                                        #

any_node conf.d]# logstash -f /etc/logstash/conf.d/simple.conf --configtest  #测试配置是否正确
Configuration OK

any_node conf.d]# logstash -f /etc/logstash/conf.d/simple.conf               #运行
Logstash startup completed

 kjfsdjfsdjfhskdhfskjd                                   #当前屏幕输入一堆数据
{                                                        #
       "message" => " kjfsdjfsdjfhskdhfskjd",            #输入的数据（可使用过滤器对其进行过滤）
      "@version" => "1",                                 #版本号，若没修改则通常为1
    "@timestamp" => "2018-01-05T12:23:18.403Z",          #数据生成时间戳
          "host" => "node1"                              #在哪个节点生成
}                                                        #

# Logstash的配置文件内的配置框架 ---------------------------------------------------------------------------
input {
    ...
}

filter {
    ...
}

output {
    ...
}

# 支持的数据类型：
#    Array: [item1,item2,item3,...]
#    Boolean: True/false
#    Bytes:简单字符
#    Codec:编码器，指明数据类型
#    HASH:key: value
#    Number: 数值，一般是正数或浮点数
#    Password: 密码串，不会被记录到日志中，或显示为星号的字串
#    Path：路径，表示FS路径
#    String：字符串

# 字段引用：使用中括号括起来 []
# 条件判断：
#    逻辑：==，!=，<，<=，>，>=，...
#    匹配：=~, !~
#    in，not in
#    and，or
#    复合语句：()
```
####  一个监听 /var/log/messages 的例子
```bash
any_node conf.d]# cat from_message.conf 
input {
    file {
        path => ["/var/log/messages"]       #键的值支持使用数组的方式
        type => "system"                    #
        start_position => "beginning"       #键值对，指明读取的起使位置
    }
}
        #上面的type字段说明：指明其获取的数据类型，默认是string，（也可以随便取）
        #type可供logstash的server端收集时根据类型做额外的处理（这些都是file的相关参数，需要参考官方的文档）...

output {
    stdout {
        codec => rubydebug
    }
}

any_node conf.d]# logstash -f /etc/logstash/conf.d/from_message.conf --configtest    #验证配置
Configuration OK
any_node conf.d]# logstash -f /etc/logstash/conf.d/from_message.conf                 #启动
{
       "message" => "Jan  5 02:21:18 node1 elasticsearch: at org.elasticsearch.http.netty.HttpRequestHandler.exceptionCaught(HttpRequestHandler.java:67)",
      "@version" => "1",
    "@timestamp" => "2018-01-05T14:35:05.831Z",
          "host" => "node1",
          "path" => "/var/log/messages",
          "type" => "system"
}
{
       "message" => "Jan  5 02:21:18 node1 elasticsearch: at org.jboss.netty.channel.SimpleChannelUpstreamHandler.handleUpstream(SimpleChannelUpstreamHandler.java:112)",
      "@version" => "1",
    "@timestamp" => "2018-01-05T14:35:05.841Z",
          "host" => "node1",
          "path" => "/var/log/messages",
          "type" => "system"
}
{
       "message" => "Jan  5 02:21:18 node1 elasticsearch: at org.jboss.netty.channel.DefaultChannelPipeline.sendUpstream(DefaultChannelPipeline.java:564)",
      "@version" => "1",
    "@timestamp" => "2018-01-05T14:35:05.848Z",
          "host" => "node1",
          "path" => "/var/log/messages",
          "type" => "system"
}
```

