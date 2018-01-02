#### 备忘
```txt
Consul Template 提供一个方便的方式从Consul获取数据通过consul-template的后台程序保存到文件系统.
Consul Template 会通过Http请求从Consul中读取集群中的数据，数据发生变更时会触发更新指定配置文件的操作。
其提供了便捷的方式从consul中获取存储的值，consul-template守护进程会查询consul实例来更新系统上指定的任何模板...
当模板更新完成后还可以选择运行任意的命令....
Template 内制静止平衡功能，可以智能的发现consul实例中的更改信息。这个功能可以防止频繁的更新模板而引起系统的波动。

dry mode：
    当不确定当前架构的状态或担心模板的变化会破坏子系统时，可使用consul template的-dry模式
    在dry模式下Consul Template会将结果呈现在STDOUT，所以操作员可以检查输出是否正常，以决定更换模板是否安全...
```
#### 参数
```txt
-auth=<user[:pass]>      设置基本的认证用户名和密码
-consul=<address>        Consul实例的地址
-max-stale=<duration>    查询过期的最大频率，默认1s
-dedup                   启用重复数据删除，当许多consul template实例渲染一个模板的时候可降低consul的负载
-ssl                     使用https连接Consul
-ssl-verify              通过SSL连接的时候检查证书
-ssl-cert                SSL客户端证书发送给服务器
-ssl-key                 客户端认证时使用的SSL/TLS私钥
-ssl-ca-cert             验证服务器的CA证书列表
-token=<token>           设置Consul API的token
-syslog                  把标准输出和标准错误重定向到syslog，syslog的默认级别是local0。
-syslog-facility=<f>     设置syslog级别，默认是local0，必须和-syslog配合使用
-template=<template>     增加一个需要监控的模板，格式：'templatePath:outputPath(:command)'，多个模板则可以设置多次
-wait=<duration>         当呈现一个新的模板到系统和触发一个命令时等待的最大最小时间。若最大值被忽略，默认是最小值4倍
-retry=<duration>        当在和consul api交互的返回值是error的时候，等待的时间，默认5s
-config=<path>           配置文件或者配置目录的路径
-pid-file=<path>         PID文件路径
-log-level=<level>       设置日志级别："debug","info", "warn" (default), and "err"
-dry                     Dump生成的模板到标准输出，不会生成到磁盘
-once                    运行consul-template一次后退出，不以守护进程运行
-reap                    子进程自动收割
```
