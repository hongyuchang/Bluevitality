#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import re
import sqlite3
import time

#PATH = sys.argv[1]
#WORD = sys.argv[2]

#JVM内存溢出关键字
GC_ERROR = str('java.lang.OutOfMemoryError: Java heap space')

#数据库名，用于记录各TOM节点的日志及扫描位置
DB_NAME='Tomcat-log-Record.db'

#查找对应的TOM的PID并Kill
EXEC_COMMAND = u'''
kill -9 $(ps -ef | grep /home/zyzx/fupin/tomcat_fupin5 | grep bin/java | awk '{print $2}')
'''

#获取系统的JAVA_HOME环境变量值
JMAP = str(os.getenv('JAVA_HOME'))+'/bin/jmap'

#检查Jmap命令是否位于$JAVA_HOME/bin下
if not os.path.isfile(JMAP):
	print ("Jmap command not exist")
	sys.exit(1)

#创建数据库用于记录文件位置
def CREATE_DB(DB_NAME=DB_NAME):
	conn = sqlite3.connect(DB_NAME)
	c = conn.cursor()
	c.execute('''
		CREATE TABLE TOMLOG (
		FILENAME  TEXT,
		RECORD    INT);''')
	conn.commit()
	conn.close()
	print("Table created successfully!...")

#日志文件记录
def WDB(DB_NAME=DB_NAME):
	conn = sqlite3.connect(DB_NAME)
	c = conn.cursor()
	for F,R in LOGS.items():
		list=[str(F),str(R)]
		sql=u'''INSERT INTO TOMLOG VALUES(?,?)'''
		c.execute(sql,list)
	conn.commit()
	conn.close()

#搜索指定路径下包含关键字的文件
LOGS={}
def search_tomlog(PATH,WORD=GC_ERROR):
	DATE=time.strftime('%Y-%m-%d',time.localtime(time.time()))
	for FILENAME in os.listdir(PATH):
		fp = os.path.join(PATH, FILENAME)
		FILEPATH=str(fp)
		if os.path.isfile(fp):
			if not str(FILENAME).endswith(str(DATE)+".log"):	#跳过非本日期结尾的日志文件(仅扫描当天的日志)
				continue
			LINE_NUMBER = len(open(fp).readlines())			#获取文件行数
			with open(fp) as f:
				inumber=0
				for line in f:
					inumber+=1				#记录当前匹配的行数(这里需要再去读取历史进度并开始)
					if WORD in line:	
						LOGS[fp] = inumber 		#将搜索到的文件绝对路径加入字典: {文件路径:当前出错行}
						break
		elif os.path.isdir(fp):
			#递归调用
			search_tomlog(fp,WORD)

#输出被匹配到内容的日志路径
def report_search_file(LOGS=LOGS):
	pattern='logs/(.*?)$'
	#将字典的KV记录到数据库
	WDB()
	for FILENAME,LINE_NUMBER in LOGS.items():
		#print FILENAME,LINE_NUMBER		#输出文件路径和总行数	
		out=re.sub(pattern,'',FILENAME)		#输出去除logs/*的部分
		print FILENAME
		print out


def TOMCAT_STOP_AND_START():
	pass	

if __name__ == "__main__":
	if not os.path.exists('Tomcat-log-Record.db'):
		CREATE_DB()	
	search_tomlog(PATH=sys.argv[1],WORD=GC_ERROR)
	report_search_file()	
