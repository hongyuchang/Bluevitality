#### Logstash Template
```txt
Logstash自带的模版其实也挺好，不过有一个参数 "refresh_interval":"5s" 用于控制索引的刷新频率。
索引的刷新频率越快，搜索到的数据就实时，这里是5秒。
一般在日志的场景不需要这么高的实时性。可适当降低该参数，提高ES索引库的写入速度

将模板中优先级字段"order"定义的比Logstash自带的模版高，而模版匹配规则又一样，所以这个自定义模版的配置会覆盖原模版 (合并)
```
```json
curl-XPUThttp://10.10.1.244:9200/_template/logstash2-d'
{
	"order": 1,
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
```txt
其中的"_default_"字段特指针对此索引下所有类型的的JSON定义其映射，也可以修改为单独针对某一特定类型下的JSON映射...
```
#### Example
```json
GET library/_mapping
{
   "library": {
      "mappings": {
         "books": {
            "properties": {
               "name": {
                  "type": "string",
                  "index": "not_analyzed"
               },
               "number": {
                  "type": "object",
                  "dynamic": "true"
               },
               "price": {
                  "type": "double"
               },
               "publish_date": {
                  "type": "date",
                  "format": "dateOptionalTime"
               },
               "title": {
                  "type": "string"
               }
            }
         }
      }
   }
}
```
