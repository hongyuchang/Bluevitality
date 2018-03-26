#### 备忘
```txt
filebeat由2个主要组件构成：prospector、harvesters：
    1.harvesters：主要负责进行单个文件内容收集，每个Harvester会对一个文件逐行进行读取并把读到的内容发到配置的output中
    2.prospector：管理Harvsters并找到所有需进行读取的数据源
      若input type是log，Prospector将会去配置的路径下查找所有能匹配到的文件然后为每个文件创建一个Harvster
      每个Prospector都运行在自己的Go routime里
      
1、当开启filebeat时会启动一或若干探测器进程"prospectors"去检测指定的日志目录或文件
2、对探测器找出的每个文件，filebeat都会启动收割进程"harvester"，各收割进程读取其文件新内容并将其发到处理程序"spooler"
3、处理程序会集合这些事件，最后filebeat会发送集合的数据到你指定的地点
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
    -
       paths:
         - /www/wwwLog/www.lanmps.com_old/*.log
         - /www/wwwLog/www.lanmps.com/*.log
       input_type: log 
       document_type: nginx-access-www.lanmps.com
    -
       paths:
         - /www/wwwRUNTIME/www.lanmps.com/order/*.log
       input_type: log 
       document_type: order-www.lanmps.com
output:
    -
       logstash:
         hosts: ["10.1.5.65:5044"]
```
#### 测试-1 输出到文件
```yaml
filebeat:
  prospectors:
    - 
      paths:
        - /var/log/messages
      input_type: log
      document_type: nginx
output.file:
      path: '/tmp/'
      filename: filebeat.txt
      #rotate_every_kb: 10000
      #number_of_files: 7
```
#### 测试-2 输出到终端
```yaml
output：
  console:
    pretty: true
```
#### 启动
```bash
nohup ./filebeat -e -c filebeat.yml >/dev/null 2>&1 &
```
#### logstash端input使用beats插件接收日志数据
```txt
input {
  beats {
    port => 5044
  }
}
```
