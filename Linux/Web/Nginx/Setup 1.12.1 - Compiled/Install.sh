#!/bin/bash

#注意，此脚本与源码不要放在"/home/wangyu/nginx/"下!

NGINX_HOME="/home/wangyu/nginx/nginx-1.12.1"
NGINX_CONF="/home/wangyu/nginx/nginx-1.12.1/conf/nginx.conf"
PERE_HOME="/home/wangyu/nginx/pcre-8.41"
OPENSSL_HOME="/home/wangyu/nginx/openssl-1.0.21"
ZLIB_HOME="/home/wangyu/nginx/zlib-1.2.8"

set -e
set -x

#本地安装
[[ -e "nginx-1.12.1.tar.gz" && -e "openssl-1.0.2l.tar.gz" && -e "pcre-8.41.tar.gz" && -e "zlib-1.2.8.tar.gz" ]] || exit 1
rm -rf {nginx-1.12.1,openssl-1.0.2l,pcre-8.41,zlib-1.2.8,$NGINX_HOME,$NGINX_CONF,$PERE_HOME,$OPENSSL_HOME}

#Openssl
p=$(pwd)
tar zxf openssl-1.0.2l.tar.gz
cd openssl-1.0.2l/
./config --prefix=${OPENSSL_HOME}
make && make install

#PCRE
cd $p
tar zxf pcre-8.41.tar.gz
cd pcre-8.41
./configure --prefix=${PERE_HOME}
make && make install

#Zlib
cd $p
tar -xf zlib-1.2.8.tar.gz 
cd zlib-1.2.8
./configure --prefix=${ZLIB_HOME}
make && make install

cd $p
tar zxf nginx-1.12.1.tar.gz
mkdir -p ${NGINX_HOME}
cd nginx-1.12.1/
./configure  \
--prefix=${NGINX_HOME} \
--conf-path=${NGINX_CONF} \
--sbin-path=${NGINX_HOME}/sbin/nginx \
--pid-path=${NGINX_HOME}/nginx.pid \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-http_realip_module \
--with-pcre=../pcre-8.41 \
--with-zlib=../zlib-1.2.8 \
--with-openssl=../openssl-1.0.2l \
--with-http_ssl_module
NUM=$( awk '/processor/{NUM++};END{print NUM}' /proc/cpuinfo )
if [ $NUM -gt 1 ] ;then
    make -j $NUM
else
    make
fi
make install

#不启动（需要root权限启动1024以内的端口，建议sed替换一下）
chmod u+s ${NGINX_HOME}/sbin/nginx
export PATH=${NGINX_HOME}/sbin/:$PATH
#nginx

exit 0
