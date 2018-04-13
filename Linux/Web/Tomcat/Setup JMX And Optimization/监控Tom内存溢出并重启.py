#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#注意：本脚本在遍历完日志后将默认从第一行重新进行扫描....(BUG)

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

#获取系统的JAVA_HOME环境变量值
JMAP = str(os.getenv('JAVA_HOME'))+'/bin/jmap'

#创建数据库用于记录文件位置
def CREATE_DB(DB_NAME=DB_NAME):
	conn = sqlite3.connect(DB_NAME)
	c = conn.cursor()
	c.execute('''CREATE TABLE TOMLOG (FILENAME TEXT,RECORD INT);''')
	conn.commit()
	conn.close()
	print("Table created successfully!...")

#记录日志文件的扫描行历史位置
def WDB(DB_NAME=DB_NAME,DELETE_RECORD="NO"):
	conn = sqlite3.connect(DB_NAME)
	c = conn.cursor()
	if DELETE_RECORD != "NO":
		list=[str(DELETE_RECORD)]
		sql = u'''DELETE FROM TOMLOG WHERE FILENAME=?'''
		c.execute(sql,list)
	else:		
		for F,R in LOGS.items():
			list=[str(F),str(R)]
			sql = u'''INSERT INTO TOMLOG VALUES(?,?)'''
			c.execute(sql,list)
	conn.commit()
	conn.close()

#读取日志文件扫描行的历史位置
def RDB(DB_NAME=DB_NAME):
	conn = sqlite3.connect(DB_NAME)
	c = conn.cursor()
	cursor = c.execute("SELECT FILENAME,RECORD FROM TOMLOG")
	HISTORY_TOM_LOG={}
	for row in cursor:
		HISTORY_TOM_LOG[row[0]]=row[1]
	for k,v in HISTORY_TOM_LOG.items():
		print "从数据库中读取的文件记录:",k,v
	conn.close()
	return HISTORY_TOM_LOG

#搜索指定路径下包含关键字的文件，输出到LOGS字典：{'文件名',关键字所在行'} 若存在数据库则从其记录位置开始扫描
LOGS={}
def search_tomlog(PATH,WORD=GC_ERROR):
	DATE=time.strftime('%Y-%m-%d',time.localtime(time.time()))
	if os.path.isfile(DB_NAME):
		OLDFILE_AND_RECORD=RDB()		#改逻辑，若存在则从此位置进行读取，文件名：OLDFILE_AND_RECORD[文件名]
	for FILENAME in os.listdir(PATH):
		fp = os.path.join(PATH, FILENAME)
		FILEPATH=str(fp)
		if os.path.isfile(fp):
			if not str(FILENAME).endswith(str(DATE)+".log"):	#跳过非本日期结尾的日志文件，格式: "YYYY-MM-DD.log" (仅扫描当天的日志)
				continue
			if str(FILEPATH) in OLDFILE_AND_RECORD.keys():
				print str(type(FILENAME))
				print "shanchu.................."
				LINE_NUMBER = int(OLDFILE_AND_RECORD[str(FILEPATH)]) + 1
				print FILEPATH
				WDB(DELETE_RECORD = str(FILEPATH))		
			else:
				LINE_NUMBER = 0
			COUNT_NUMBER = len(open(fp).readlines())			#获取文件行数
			if LINE_NUMBER == 0:
				with open(fp) as f:
					i=0
					for line in f:
						try:
							if WORD in line:
								LOGS[fp] = i 			#将搜索到的文件绝对路径加入字典: {文件路径:当前出错行}
								break
							i+=1
						except IndexError:
							print "已扫描到文件尾部，当前行:" + str(LINE_NUMBER+1) + " 将从文件起使行开始"
			else:
				with open(fp) as f:
					contents = f.readlines()
					for i in xrange(1,COUNT_NUMBER):
						try:
							if WORD in contents[ LINE_NUMBER + i ]:
								LOGS[fp] = LINE_NUMBER + i
								break
						except IndexError:
							print "已扫描到文件尾部，当前行:" + str(LINE_NUMBER+1) + " 将从文件起使行开始"
		elif os.path.isdir(fp):
			#递归调用
			search_tomlog(fp,WORD)

#输出被匹配到内容的日志路径，并写入到数据库
def report_search_file(LOGS=LOGS):
	pattern='logs/(.*?)$'
	#将字典的KV记录到数据库
	WDB()
	for FILENAME,LINE_NUMBER in LOGS.items():
		#print FILENAME,LINE_NUMBER		#输出文件路径和扫描行数	
		out=re.sub(pattern,'',FILENAME)		#输出去除logs/*的部分
		print "被抓取并写入数据库的文件:",FILENAME
		print "去除被匹配的日志路径的logs部分:",out

def TOMCAT_STOP_AND_START(PATH):
	#DUMP_HEAP = u"%s -dump:format=b,file=. " %(JMAP,)	#导出堆信息，未完成
	KILL_COMMAND = u"kill -9 $(ps -ef | grep %s | grep bin/java | awk '{print $2}')" %(PATH)
	START_COMMAND = u"%s/bin/startup.sh" %(PATH)
	print KILL_COMMAND
	print START_COMMAND
	#result_kill_code=os.system(KILL_COMMAND)	
	#time.sleep(0.5)
	#if result_kill_code == 0:
	#	print 'KILL执行成功'	
	
	

if __name__ == "__main__":
	#检查Jmap命令是否位于$JAVA_HOME/bin下
	if not os.path.isfile(JMAP):
		print ("Jmap command not exist")
		sys.exit(1)
	if not os.path.exists('Tomcat-log-Record.db'):
		CREATE_DB()	
	search_tomlog(PATH=sys.argv[1],WORD=GC_ERROR)
	report_search_file()	
	x=RDB()
	for F in LOGS.keys():
		TOMCAT_STOP_AND_START(F)
