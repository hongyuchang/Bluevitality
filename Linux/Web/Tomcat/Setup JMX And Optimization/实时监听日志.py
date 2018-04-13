#!/usr/bin/env python
#coding=utf-8

import os,sys
import subprocess
from multiprocessing import Process,Lock,Queue
import re
import sqlite3
import time

#JVM内存溢出关键字
GC_ERROR = str('java.lang.OutOfMemoryError: Java heap space')

#获取系统的JAVA_HOME环境变量值
JMAP = str(os.getenv('JAVA_HOME'))+'/bin/jmap'

def scan_log(PATH):
	for FILENAME in os.listdir(PATH):
		FILEPATH = os.path.join(PATH, FILENAME)
		if os.path.isfile(FILEPATH):
			if not str(FILENAME).endswith(str(DATE)+".log"):
				continue
			else:
				Q.put(str(FILEPATH))
				print "加入队列的文件名",FILEPATH 
				print "队列大小",Q.qsize()
				#把文件名加入队列中
		elif os.path.isdir(FILEPATH):
			scan_log(FILEPATH)


def monitor_log():
	if not Q.empty():
		L.acquire()
		F = Q.get()
		L.release()
	else:
		return
	print "队列中读取的文件名",F
	print "读取后队列大小",Q.qsize()
	#实时读取
	popen = subprocess.Popen('tail -1f '+F,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
	print "当前进程监听：%s" %(F)
		
	#循环匹配
	while True:
		MATCH = re.compile("123" )
		LINE=popen.stdout.readline().strip()
		new_line=MATCH.search(LINE.lower())

		#动作
		if new_line:
			time.sleep(1)
			#这里重启TOMCAT            
			pattern='logs/(.*?)$'
			out = re.sub(pattern,'',F)
			PID = os.popen("ps -ef | grep %s | grep bin/java | awk '{print $2}'" %(out)).read() #需要KILL
			DUMP_HEAP = u"%s -dump:format=b,file=%slogs/%s_hprof  %s" %(JMAP,out,DATE,PID)
			STOP_COMMAND = u"kill -9 %s" %(PID)
			START_COMMAND = u"%sbin/startup.sh" %(out)
			print str("heap_info: %slogs/%s_hprof" %(out,DATE))		#记录到日志
			print "DUMP_HEAP: ",DUMP_HEAP
			print "STOP: ",STOP_COMMAND
			print "start: ",START_COMMAND



if __name__ == '__main__':
	#检查Jmap命令是否位于$JAVA_HOME/bin下
	if not os.path.isfile(JMAP):
		print ("Jmap command not exist")
		sys.exit(1)
	
	Q = Queue()
	L = Lock()
	
	#当前时间 yyyy-mm-dd
	DATE = time.strftime('%Y-%m-%d',time.localtime(time.time()))
	
	scan_log("/root")
	print "队列总大小：",Q.qsize()	

	process_list = []
	for i in xrange(int(Q.qsize())):
		p = Process(target=monitor_log,args=())
		p.start()
		process_list.append(p)
	for i in process_list:
		i.join()


