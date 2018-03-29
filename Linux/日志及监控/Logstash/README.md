#### filebeat --> kafka --> logstash --> Elastic
#### filebeat
```yaml
filebeat:
  prospectors:
    - paths:
        - /home/wangyu/Test/access.log
      input_type: log
      document_type: oslog
      scan_frequency: 2s
output.kafka: 
  enabled: true 
  hosts: ["10.0.0.3:9092"] 
  topic: ES
  partition.round_robin:
    required_acks: 1
    max_message_bytes: 1000000
#output.console:
#    pretty: true
```
#### kafka
```txt
kafka-topics.sh --create --zookeeper 10.0.0.3:21811 --replication-factor 1 --partitions 1 --topic ES
```
#### Logstash
```logstash
input{
    kafka {
        bootstrap_servers => "10.0.0.3:9092"
        group_id => "logstash"
        topics => "ES"
        consumer_threads => 1
        decorate_events => true
        auto_commit_interval_ms => 1000
        auto_offset_reset => latest
        codec => "json"
    }
}

filter{
    grok {
        match => { 
            #"message" => "%{IPORHOST:clientip} - - \[%{HTTPDATE:timestamp}\]" 
            "message" => '%{IP:client} - - \[%{DATA:time}\] "%{DATA:verb} %{DATA:url_path} %{DATA:httpversion}" %{NUMBER:response} %{NUMBER:} "-" \"%{DATA:agent}\" "-" \"%{NUMBER:request_time}\" -' 
        }
    }
    mutate{ 
        #remove_field => "tags"
        #remove_field => "topic"
        remove_field => ["tags","topic","source","version","name"]
        add_field => [ "log_ip", "10.0.0.3" ]
        #remove_field => "information"
        #remove_field => "message"
    }
}

output{
    elasticsearch {
        hosts => ["10.0.0.3:9200"]
        index => "es"                   #索引名不要大写
    }
    stdout {
        codec => "rubydebug"
    }
}
```
