#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import re

#PATH = sys.argv[1]
#WORD = sys.argv[2]

#JVM内存溢出关键字
GC_ERROR = str('java.lang.OutOfMemoryError: Java heap space')

EXEC_COMMAND = u'''
kill -9 $(ps -ef | grep /home/zyzx/fupin/tomcat_fupin5 | grep bin/java | awk '{print $2}')
'''

#获取系统的JAVA_HOME环境变量值
JMAP = str(os.getenv('JAVA_HOME'))+'/bin/jmap'

#检查Jmap命令是否位于$JAVA_HOME/bin下
if not os.path.isfile(JMAP):
	print "Jmap command not exist"
	sys.exit(1)

print JMAP


#搜索指定路径下包含关键字的文件
LOGS={}
def search_tomlog(PATH,WORD=GC_ERROR):
	for FILENAME in os.listdir(PATH):
		fp = os.path.join(PATH, FILENAME)
		FILEPATH=str(fp)
		if os.path.isfile(fp):
			LINE_NUMBER = len(open(fp).readlines())
			with open(fp) as f:
				for line in f:
					if WORD in line:
						LOGS[fp] = LINE_NUMBER 	#将搜索到的文件绝对路径加入字典: {文件路径:总行数}
						break
		elif os.path.isdir(fp):
			search_tomlog(fp,WORD)

def report_search_file(LOGS=LOGS):
	pattern='logs/(.*?)$'
	for FILENAME,LINE_NUMBER in LOGS.items():
		#print FILENAME,LINE_NUMBER		#输出文件路径和总行数	
		out=re.sub(pattern,'',FILENAME)		#输出去除logs/*的部分
		print out


def TOMCAT_STOP_AND_START():
	pass	


if __name__ == "__main__":
	search_tomlog(PATH=sys.argv[1],WORD=GC_ERROR)
	report_search_file()	
