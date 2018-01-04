#### 运维相关
```bash
#查看集群统计数据
[root@node2 ~]# curl -X GET http://localhost:9200/_cluster/state?pretty 
{
  "cluster_name" : "elasticsearch",
  "version" : 4,
  "state_uuid" : "5Mcqk1GEQMq8UOO3AoiDsA",
  "master_node" : "-eE6xk1kReaiHJkXdMnrzQ",
  "blocks" : { },
  "nodes" : {
    "-eE6xk1kReaiHJkXdMnrzQ" : {
      "name" : "node2",
      "transport_address" : "192.168.0.6:9300",
      "attributes" : { }
    },
    "FphwOd7zQ2GGsMQRfvY1sA" : {
      "name" : "node1",
      "transport_address" : "192.168.0.5:9300",
      "attributes" : { }
    },
    "VhkF497sQKSAoWY7_ow-og" : {
      "name" : "node3",
      "transport_address" : "192.168.0.7:9300",
      "attributes" : { }
    }
  },
  "metadata" : {
    "cluster_uuid" : "dkZecPmFQN6PVFh9hu_InA",
    "templates" : { },
    "indices" : { }
  },
  "routing_table" : {
    "indices" : { }
  },
  "routing_nodes" : {
    "unassigned" : [ ],
    "nodes" : {
      "VhkF497sQKSAoWY7_ow-og" : [ ],
      "FphwOd7zQ2GGsMQRfvY1sA" : [ ],
      "-eE6xk1kReaiHJkXdMnrzQ" : [ ]
    }
  }
} 

#查询master_node
[root@node2 ~]# curl -X GET http://localhost:9200/_cluster/state/master_node?pretty 
{
  "cluster_name" : "elasticsearch",
  "master_node" : "-eE6xk1kReaiHJkXdMnrzQ"
}

#查看集群状态的版本
[root@node2 ~]# curl -X GET http://localhost:9200/_cluster/state/version?pretty 
{
  "cluster_name" : "elasticsearch",
  "version" : 4,
  "state_uuid" : "5Mcqk1GEQMq8UOO3AoiDsA"
}

#更新集群设定(常用)
[root@node2 ~]# curl -X PUT http://192.168.0.6:9200/_cluster/settings -d \' {
>     "persistent": {
>           "discovery.zen.minimun_master_nodes": 1
>     }
> }\'
{"acknowledged":true,"persistent":{},"transient":{}}


#节点相关信息
[root@node2 ~]# curl -X GET http://localhost:9200/_nodes/node1,node2?pretty
```
#### CURD 相关的 ES API
```bash

```
