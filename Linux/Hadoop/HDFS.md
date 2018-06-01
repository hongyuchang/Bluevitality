```txt
创建一个名为 /foodir 的目录		bin/hadoop dfs -mkdir /foodir
创建一个名为 /foodir 的目录		bin/hadoop dfs -mkdir /foodir
查看名为 /foodir/myfile.txt 的文件内容		bin/hadoop dfs -cat /foodir/myfile.txt
将集群置于安全模式				bin/hadoop dfsadmin -safemode enter
显示Datanode列表				bin/hadoop dfsadmin -report
使Datanode节点 datanodename退役				bin/hadoop dfsadmin -decommission datanodename

```
