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
#### 关于 Mapping 中的"index"字段的说明
```txt
{
    "tag": {
        "type":     "string",
        "index":    "not_analyzed"
    }
}
---------------------------
值	       解释
analyzed	首先分析这个字符串，然后索引。换言之，以全文形式索引此字段。
not_analyzed	索引这个字段，使之可以被搜索，但是索引内容和指定值一样。不分析此字段。
no		不索引这个字段。这个字段不能为搜索到。
```
#### 修改已经存在的Mapping
```txt
1.如果要推到现有的映射,你得重新建立一个索引.然后重新定义映射
2.然后把之前索引里的数据导入到新的索引里
-------具体方法------
1.给现有的索引定义一个别名,并且把现有的索引指向这个别名,运行步骤2
2.运行: PUT /现有索引/_alias/别名A
3.新创建一个索引,定义好最新的映射
4.将别名指向新的索引.并且取消之前索引的执行,运行步骤5
5.运行: POST /_aliases
        {
            "actions":[
                {"remove"    :    {    "index":    "现有索引名".    "alias":"别名A"    }}.
                {"add"        :    {    "index":    "新建索引名",    "alias":"别名A"    }}
            ]
        }
注意:通过这几个步骤就实现了索引的平滑过渡,并且是零停机
```
#### 常用指令
```txt
获取index为library,type为books的映射
GET /libraryyry/_mapping/books

获取集群内所有的映射信息
GET /_all/_mapping/

获取这个集群内某两个或多个type映射信息(books和bank_account映射信息)
GET /_all/_mapping/books,bank_account

DELETE /libraryry/books

删除books的映射
DELETE /libraryry/books/_mapping

删除多个映射
DELETE /libraryry/_mapping/books,bank_acount
```
