#!/bin/sh
export JENKINS_HOME="/home/zyzx/jenkins/tomcat_jenkins2/jenkins"
export JAVA_OPTS="${JAVA_OPTS}"" -Xms512m -Xmx2048m -XX:PermSize=64m -XX:MaxPermSize=512m -Dfile.encoding=UTF-8 -Dhudson.util.ProcessTree.disable=true -Doracle.jdbc
.V8Compatible=true -Dappframe.server.name=release_tomcat_jenkins -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/zyzx/jenkins/tomcat_jenkins/logs/oom.hprof"
echo "JAVA_OPTS=${JAVA_OPTS}"
JAVA_HOME=/home/zyzx/jdk1.8.0_60
