#### 备忘
```txt
Filebeat由2个主要组件构成：prospector、harvesters：
    1.harvesters：负责进行单个文件内容收集，每个Harvester会对1个文件逐行进行读取并把读到的内容发到配置的output中
    2.prospector：管理Harvsters并找到所有需读取的数据源
      若input type是log则Prospector将去配置的路径下查找所有能匹配到的文件然后为每个文件创建一个Harvster
      每个Prospector都运行在自己的Go Routime里
      
1、启动Filebeat时会启动一或若干探测器进程"prospectors"去检测指定的日志目录或文件...
2、对探测器找出的每个文件，Filebeat都会启动收割进程"harvester"，各收割进程读取其文件新内容并将其发到处理程序"spooler"
3、处理程序会集合这些事件，最后Filebeat会发送集合的数据到指定的地点

Filebeat如何保持文件状态：
其保持每个文件的状态并频繁刷新状态到磁盘上的注册文件，用于记忆"harvesters"读取的最后的偏移量并确保所有日志行被发送
若ES或Logstash的输出不可达时Filebeat将持续追踪发送的最后一样并继续读取文件，尽快变为可用的输出
```
#### 部署 fliebeat
```bash
[wangyu@localhost filebeat-6.2.3-linux-x86_64]$ tar -zxf filebeat-6.2.3-linux-x86_64.tar.gz -C .
[wangyu@localhost filebeat-6.2.3-linux-x86_64]$ cd filebeat-6.2.3-linux-x86_64

[wangyu@localhost filebeat-6.2.3-linux-x86_64]$ ./filebeat --help
Usage:
  filebeat [flags]
  filebeat [command]

Available Commands:
  export      Export current config or index template
  help        Help about any command
  keystore    Manage secrets keystore
  modules     Manage configured modules
  run         Run filebeat
  setup       Setup index template, dashboards and ML jobs
  test        Test config
  version     Show current version info

Flags:
  -E, --E setting=value      Configuration overwrite
  -M, --M setting=value      Module configuration overwrite
  -N, --N                    Disable actual publishing for testing
  -c, --c string             Configuration file, relative to path.config (default "filebeat.yml")
      --cpuprofile string    Write cpu profile to file
  -d, --d string             Enable certain debug selectors
  -e, --e                    Log to stderr and disable syslog/file output
  -h, --help                 help for filebeat
      --httpprof string      Start pprof http server
      --memprofile string    Write memory profile to this file
      --modules string       List of enabled modules (comma separated)
      --once                 Run filebeat only once until all harvesters reach EOF
      --path.config string   Configuration path
      --path.data string     Data path
      --path.home string     Home path
      --path.logs string     Logs path
      --plugin pluginList    Load additional plugins
      --setup                Load the sample Kibana dashboards
      --strict.perms         Strict permission checking on config files (default true)
  -v, --v                    Log at INFO level

Use "filebeat [command] --help" for more information about a command.
```
#### filebeat的配置文件：filebeat.yml
```yaml
filebeat:
  prospectors:
    - paths:
        - /www/wwwLog/www.lanmps.com_old/*.log
        - /www/wwwLog/www.lanmps.com/*.log
      input_type: log 
      document_type: nginx-access-www.lanmps.com
    - paths:
        - /www/wwwRUNTIME/www.lanmps.com/order/*.log
      input_type: log 
      document_type: order-www.lanmps.com
output.logstash:
      hosts: ["10.1.5.65:5044"]         #Worker代表连到每个Logstash的线程数量
      worker: 2
      loadbalance: true
      index: filebeat
```
#### 测试-1 输出到文件/终端
```yaml
filebeat:
  prospectors:
    - paths:
        - /var/log/*.log
        - /var/log/sshd/*.log
      input_type: log                   #向log中添加标签，提供给logstash用于区分不同客户端不同业务的log
      document_type: system_log         #跟tags差不多，用于区别不同的日志来源
　  - drop_event:
     　　when:
       　　 regexp:
          　　 message: "^DBG:"
output.file:
      path: '/tmp/'
      filename: filebeat.txt
      #rotate_every_kb: 10000
      #number_of_files: 7
#output.console:
#    pretty: true
```
#### 测试-2 输出到终端
```yaml
output：
  console:
    pretty: true
```
#### 输出到 kafka
```yaml
filebeat:
  prospectors:
    - paths:
        - /home/wangyu/Test/access.log
      enabled: true                         #每个prospectors的开关，默认true
      input_type: log                       #输入类型
      fields: "TEST"                        #添加字段，可用values，arrays，dictionaries或任何嵌套数据
      document_type: oslog
      scan_frequency: 2s                    #扫描频率，默认10秒
      encoding：plain                       #编码，默认无，plain不验证或改变输入、latin1、utf-8、utf-16be-bom...
      include_lines: ['^ERR','^WARN']       #匹配行，后接正则的列表，默认无，若启用则仅输出匹配行
      exclude_lines: ["^DBG"]               #排除行，意义同上...
      exclude_files: [".gz$"]               #排除文件，后接正则列表，默认无
      ignore_older: 0                       #排除更改时间超过定义的文件，时间可用2h表示2小时，5m表示5分钟，默认0
      max_bytes: 10485760                   
      #单文件最大收集字节数，超过此值后的字节将被丢弃，默认10MB，需增大
      #保持与日志输出配置的单文件最大值一致即可...
      close_removed: true
      #若文件不存在则关闭处理。若后面又出现了则会在scan_frequency之后继续从最后一个已知position处开始收集，默认true
output.kafka: 
  enabled: true 
  hosts: ["10.0.0.3:9092"] 
  topic: ES
  max_retries: 3
  timeout: 90
  compression_level:0                       #gzip压缩级别，默认0不压缩（耗CPU）
  partition.round_robin:
    required_acks: 1                        #需要Kafka端回应ack
    max_message_bytes: 1000000
```
#### 启动
```bash
nohup ./filebeat -e -c filebeat.yml >/dev/null 2>&1 &
```
#### logstash端input使用beats插件接收filebeat发来的日志数据
```txt
input {
  beats {
    port => 5044
  }
}
```
