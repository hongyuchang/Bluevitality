#### Logstash Template
```txt
Logstash自带的模版其实也挺好，不过有一个参数 "refresh_interval":"5s" 用于控制索引的刷新频率。
索引的刷新频率越快，搜索到的数据就实时，这里是5秒。
一般在日志的场景不需要这么高的实时性。可适当降低该参数，提高ES索引库的写入速度
```
```json
curl-XPUThttp://10.10.1.244:9200/_template/logstash2-d'
{
	"order": 1,     #把优先级order定义的比logstash模版高，而模版匹配规则又一样，所以这个自定义模版的配置会覆盖原模版
	"template": "logstash-*",
	"settings": {
		"index": {
			"refresh_interval": "120s"
		}
	},
	"mappings": {
		"_default_": {
			"_all": {
				"enabled": false
			}
		}
	}
}
```
