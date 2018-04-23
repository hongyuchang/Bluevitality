#!/bin/bash

VIP_INTERFACE="eth0"
VIP=192.168.0.30
PORT=80

REALSERVER_IP1=192.168.0.21
REALSERVER_IP2=192.168.0.22


case "$1" in
    start)           
        /sbin/ifconfig ${VIP_INTERFACE}:3 $VIP broadcast $VIP netmask 255.255.255.255 up
        /sbin/route add -host $VIP dev ${VIP_INTERFACE}:3
    
        echo 1 > /proc/sys/net/ipv4/ip_forward
    
        /sbin/iptables -F
        /sbin/iptables -Z
        /sbin/ipvsadm -C
    
        /sbin/ipvsadm -A -t ${VIP}:${PORT} -s wlc
        /sbin/ipvsadm -a -t ${VIP}:${PORT} -r $REALSERVER_IP1 -g -w 1
        /sbin/ipvsadm -a -t ${VIP}:${PORT} -r $REALSERVER_IP2 -g -w 1
        /bin/touch /var/lock/ipvsadm &> /dev/null
    ;; 

    stop)
        echo 0 > /proc/sys/net/ipv4/ip_forward
        /sbin/ipvsadm -C
        /sbin/ifconfig ${VIP_INTERFACE}:3 down
        /sbin/route del $VIP    
        /bin/rm -f /var/lock/ipvsadm &&  echo "ipvs is stopped..."
    ;;
    
    status)
        if [ ! -e /var/lock/subsys/ipvsadm ]; then
            echo "ipvsadm is stopped ..."
        else
            echo "ipvs is running ..."
            ipvsadm -nL
        fi
    ;;
    
    *)
        echo "Usage: $0 {start|stop|status}"
    ;;
    
esac
