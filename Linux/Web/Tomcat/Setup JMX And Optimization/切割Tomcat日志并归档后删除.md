```bash
#!/bin/bash
#
#压缩备份Tomcat产生超过3天的日志文件并删除，备份文件默认保存2天

#检查pid
if [ -f "${0}.pid" ]; then
    grep -q [[:digit:]] ${0}.pid && exit
fi

#写入Pid
echo $$ > ./${0}.pid

#将zyzx下"Tomcat_*/logs/"内最后修改时间超过3天的日志文件删除并做tar包归档
find /home/zyzx/*/tomcat_*/logs/ -mtime +3 -exec tar -P -zcvf {}.tar.gz --remove {} \;

#将zyzx下"Tomcat_*/logs/"内最后修改时间超过2天的归档文件删除
find /home/zyzx/*/tomcat_*/logs/ -name "*.tar.gz" -mtime +2 -exec rm -rf {} \;

rm -f ./${0}.pid

exit 0
```
