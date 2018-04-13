#!/usr/bin/env python
#coding=utf-8

import os,sys
import subprocess
import re

def monitor_log(LOG_PATH):

    #实时读取
    popen = subprocess.Popen('tail -f '+LOG_PATH,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)

    #循环匹配
    while True:
        MATCH = re.compile("123" )
        LINE=popen.stdout.readline().strip()
        new_line=MATCH.search(LINE.lower())

        #动作
        if new_line:
           #这里重启TOMCAT
           os.system('touch okokok')
           print("OK....")


if __name__ == '__main__':
    if len(sys.argv) == 2:
        monitor_log(sys.argv[1])
    else:
        msg='''
            input argv is wrong
            example: \033[31;1m python demo.py -f /xxx/xxx/xxx.log\033[0m
            '''
        print(msg)
