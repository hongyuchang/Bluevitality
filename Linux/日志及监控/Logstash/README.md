###### filebeat   -->   kafka   -->   logstash   -->   Elasticsearch   -->   Kibana
#### filebeat
```bash
filebeat:
  prospectors:
    - paths:
        - /home/wangyu/Test/access.log
      input_type: log
      document_type: oslog
      scan_frequency: 2s              #Every 2s scan ..
output.kafka: 
  enabled: true 
  hosts: ["10.0.0.3:9092"]
  topic: ES                           #MQ Topic
  partition.round_robin:
    required_acks: 1                  #Need kafka Ack
    max_message_bytes: 1000000
#output.console:
#    pretty: true
```
#### kafka
```bash
#在Kafka的Broker端创建"Logstash"消费的主题
kafka-topics.sh --create --zookeeper 10.0.0.3:21811 --replication-factor 1 --partitions 1 --topic ES
```
#### Logstash
```bash
input{
    kafka {
        bootstrap_servers => "10.0.0.3:9092"    #Kafka Address
        group_id => "logstash"                  #消费组，同组中的消费者间同时仅能消费相同主题的1个消息
        topics => "ES"                          #消费主题
        consumer_threads => 1
        decorate_events => true
        auto_commit_interval_ms => 1000         #消费间隔，毫秒
        auto_offset_reset => latest             #
        codec => "json"
    }
}

filter{
    grok {
        match => { 
            #Grok从message语义中按Patterns获取并分割成Key，其表达式很像C语言中的宏定义
            "message" => '%{IP:client} - - \[%{DATA:time}\] "%{DATA:verb} %{DATA:url_path} %{DATA:httpversion}" %{NUMBER:response} %{NUMBER:} "-" \"%{DATA:agent}\" "-" \"%{NUMBER:request_time}\" -' 
        }
    }
    mutate{ 
        remove_field => ["tags","topic","source","version","name"]  #屏蔽Logstash中的部分KEY（语义）
        add_field => [ "log_ip", "10.0.0.3" ]                       #添加指定KEY
    }
}

output{
    elasticsearch {
        hosts => ["10.0.0.3:9200"]      #Elasticsearch根据请求体中提供的数据自动创建映射
        index => "es"                   #索引名不要大写!
    }
#    stdout {
#        codec => "rubydebug"
#    }
}
```
