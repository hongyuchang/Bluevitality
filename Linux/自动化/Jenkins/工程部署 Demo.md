#### 工程
```bash
smrz@LY1F-R020508-VM14:[/home/smrz/edcebs]ll /home/smrz/shell/
total 8
lrwxrwxrwx 1 smrz smrz  18 2018-04-20 16:03 bootctl -> /home/smrz/bootctl
-rwxr-x--x 1 smrz smrz 274 2018-04-20 16:34 edcebs-control_start.sh
-rwxr-x--x 1 smrz smrz  77 2018-04-20 16:02 edcebs-control_stop.sh

smrz@LY1F-R020508-VM14:[/home/smrz/edcebs]ll
total 83140
drwxr-x--- 2 smrz smrz       89 2018-04-20 16:51 bak
lrwxrwxrwx 1 smrz smrz       18 2018-04-20 15:33 bootctl -> /home/smrz/bootctl
-rw-rw-r-- 1 smrz smrz        7 2018-04-20 16:51 edcebs-control-1.pid
-rw-rw-r-- 1 smrz smrz 85129157 2018-04-20 16:51 edcebs-control.jar
drwxr-x--- 2 smrz smrz       50 2018-04-20 16:55 logs
drwxrwxr-x 3 smrz smrz       17 2018-04-20 16:51 tmp
```
#### Post Steps -->  @Jenkins
```txt
#拷贝
cp $WORKSPACE/edcebs-service-impl/target/edcebs-core.jar /home/smrz/ansible/dist/
#推到目标
cd /home/smrz/ansible && ansible 192.168.21.176 -m copy -a 'src=/home/smrz/ansible/dist/edcebs-core.jar \
dest=/home/smrz/edcebs/bak/'
#关闭服务
cd /home/smrz/ansible && ansible 192.168.21.176 -m shell -a 'nohup sh /home/smrz/shell/edcebs-core_stop.sh &'
#备份旧jar
cd /home/smrz/ansible && ansible 192.168.21.176 -m shell -a 'cd /home/smrz/edcebs && \
mv edcebs-core.jar bak/edcebs-core.jar-`date +"%Y-%m-%d-%H-%M-%S"`'
#导入新jar
cd /home/smrz/ansible && ansible 192.168.21.176 -m shell -a 'cd /home/smrz/edcebs && mv bak/edcebs-core.jar ./'
#启动新jar
cd /home/smrz/ansible && ansible 192.168.21.176 -m shell -a 'nohup sh /home/smrz/shell/edcebs-core_start.sh &'
```
#### Sonar
```txt
sonar.projectKey=smrzedc-edcebs-control:sonar
sonar.projectName=smrzedc-edcebs-control
sonar.projectVersion=1.0
sonar.sources=edcebs-service-impl/src
sonar.cobertura.reportPath=edcebs-service-impl/target/site/cobertura/coverage.xml
sonar.sourceEncoding=UTF-8
sonar.language=java
```
