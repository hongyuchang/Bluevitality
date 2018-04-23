#### 将80与443打上同一个标记
```bash
iptables -t mangle -A PREROUTING -d $DIP -p tcp --dport 80 -j MARK --set-mark 100
iptables -t mangle -A PREROUTING -d $DIP -p tcp --dport 443 -j MARK --set-mark 100
```

#### 基于标记保持会话
```bash
ipvsadm  -A -f 100 -s rr -p 300
ipvsadm -a -f 100 -r $REALSERVER1 -g
ipvsadm -a -f 100 -r $REALSERVER2 -g 
```
-f 表明这次的集群采用了防火墙标记的方式，后面的100就是上面iptables定义的MARK标记值  
-p 指定了超时时间，默认是600秒（与防火墙配合可以实现单FWM持久服务，解决会话和端口的问题）  
当启动后来自同一客户端的请求，不管是http还是https协议都会被负载均衡到同一服务器。
