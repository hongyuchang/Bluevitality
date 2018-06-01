```txt
清空回收站     hadoop fs -expunge
复制文件到本地文件系统     hadoop fs -get /user/hadoop/file localfile
将源目录中所有的文件连接成本地目标文件   hadoop fs -getmerge <src> <localdst>
创建一个名为 /foodir 的目录		bin/hadoop dfs -mkdir /foodir
创建一个名为 /foodir 的目录		bin/hadoop dfs -mkdir /foodir
查看名为 /foodir/myfile.txt 的文件内容		bin/hadoop dfs -cat /foodir/myfile.txt
将集群置于安全模式				bin/hadoop dfsadmin -safemode enter
显示Datanode列表				bin/hadoop dfsadmin -report
使Datanode节点 datanodename退役				bin/hadoop dfsadmin -decommission datanodename

将文件从源路径移动到目标路径。这个命令允许有多个源路径，此时目标路径必须是一个目录
  hadoop fs -mv /user/hadoop/file1 /user/hadoop/file2

从本地文件系统中复制单个或多个源路径到目标文件系统。也支持从标准输入中读取输入写入目标文件系统
  hadoop fs -put <localsrc> ... <dst>
  hadoop fs -put localfile1 localfile2 /user/hadoop/hadoopdir
  hadoop fs -put - hdfs://host:port/hadoop/hadoopfile （从标准输入中读取输入）

删除指定的文件。只删除非空目录和文件
  hadoop fs -rm URI [URI …]
  hadoop fs -rm hdfs://host:port/file /user/hadoop/emptydir

delete的递归版本
  hadoop fs -rmr /user/hadoop/dir
  hadoop fs -rmr hdfs://host:port/user/hadoop/dir

改变一个文件的副本系数。-R选项用于递归改变目录下所有文件的副本系数
  hadoop fs -setrep -w 3 -R /user/hadoop/dir1

将文件尾部1K字节的内容输出到stdout。支持-f选项，行为和Unix中一致
  hadoop fs -tail [-f] URI
  hadoop fs -tail pathname
  
hadoop fs -ls /user/hadoop/file1
  如果是文件，则按照如下格式返回文件信息：
  文件名 <副本数> 文件大小 修改日期 修改时间 权限 用户ID 组ID 
  如果是目录，则返回它直接子文件的一个列表，就像在Unix中一样。目录返回列表的信息如下：
  目录名 <dir> 修改日期 修改时间 权限 用户ID 组ID 
```
