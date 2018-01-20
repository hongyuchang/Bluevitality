#### 安装Kvm模块与Libvirtd
```bash
#检测硬件是否支持虚拟化，若含有vmx或svm字样则表示支持CPU虚拟化，Intel是：vmx，AMD是：svm （KVM依赖硬件虚拟化技术的支持）
#同时也需要检测是否有kvm_xxx模块，若装载不成功可能是未开启硬件虚拟化，需从bios中开启 "VT-d" 与 "Virtual Technology"
[root@wy ~]# egrep '(vmx|svm)' --color=always /proc/cpuinfo      
[root@wy ~]# modprobe kvm     
[root@wy ~]# modprobe kvm_intel || modprobe kvm_amd

#安装rpm包并启动"libvirtd"服务，注：KVM依赖于Qemu的某些功能，如I/O设备的模拟/管理等...
[root@wy ~]# yum -y install epel-release
[root@wy ~]# yum -y install kvm qemu-kvm-tools qemu-img libvirt libvirt-client libvirt-python libguestfs-tools \
virt-v2v virt-manager virt-viewer virt-top bridge-utils
[root@wy ~]# ln -sv /usr/libexec/qemu-kvm /usr/sbin/
"/usr/sbin/qemu-kvm" -> "/usr/libexec/qemu-kvm"

[root@wy ~]# systemctl start libvirtd

#检查是否有kvm模块，若有则继续
[root@wy ~]# lsmod | grep kvm
kvm_intel       52570  30      
kvm             314739 1 kvm_intel

#建议使用此方式进行验证。字符设备："/dev/kvm" 是linux的Kvm模块调用接口，若需创建虚拟机等操作，仅需向其发起调用即可!...
[root@wy ~]# ll /dev/kvm 
crw-------. 1 root root 10, 232 1月  20 11:19 /dev/kvm
```

#### 配置桥接网络 br0 ，使虚拟机使用宿主机的物理网卡
```bash
# 即创建网桥设备并将物理网卡的地址转移到桥设备上，然后再将物理网卡加入到桥设备中

[root@wy ~]# cd /etc/sysconfig/network-scripts/ && cp ifcfg-eth0 ifcfg-br0
[root@wy ~]# vim ifcfg-eth0:     
DEVICE=eth0     
TYPE=Ethernet     
ONBOOT=yes     
NM_CONTROLLED=no                # NetworkManager服务不支持桥接，所以原则上建议设为"no"
BRIDGE="br0"                    # 将本设备桥接到哪个设备 --> br0 (此配置下eth0与br0逻辑上称为1个网卡且MAC相同)
#BOOTPROTO=static               # 或者把br0当交换机，将eth0当接入设备

[root@wy ~]# vim ifcfg-br0:
DEVICE=br0                      # 网桥名字
TYPE=Bridge                     # 网桥名字
ONBOOT=yes     
NM_CONTROLLED=yes     
BOOTPROTO=static     
IPADDR="192.168.2.149"     
NETMASK="255.255.255.0"     
GATEWAY="192.168.2.2"     

[root@wy ~]# systemctl restart network
[root@wy ~]# ip link set dev br0 promisc on     #开启网卡的混杂模式
```
## 部署安装虚拟机
#### 建立磁盘文件
```bash
#如果使用的是raw格式就不需要了，kvm虚拟机默认使用raw格式的镜像格式，其性能最好，速度最快
#它的缺点就是不支持一些新的功能如快照镜像，zlib磁盘压缩，AES加密等。这里使用qcow2格式...
[root@wy ~]# mkdir /opt/vms
[root@wy ~]# qemu-img create -f qcow2 /opt/vms/centos63-webtest.img 40G
```
#### 建立虚拟机
下面展示多种方式建立虚拟机
```bash
# KVM对I/O设备同时支持全虚拟化和半虚拟化!，其半虚拟化组件叫做"virtio"，它是一种通用的半虚拟化驱动，是Linux内核中的模块
# I/O设备的虚拟模式有三种：1.模拟,2.半虚拟化,3.透传
# virtio-blk      块设备的半虚拟化，使用磁盘的版虚拟化时其性能接近物理机的85%
# virtio-net      网络设备的半虚拟化
# virtio-pci      PCI设备的半虚拟化（注！显卡设备不支持版虚拟化）
# virtio-console  控制台的半虚拟化
# virtio-ballon   内存的动态扩展/缩容

########### 使用iso安装 ###########     
[root@wy ~]# virt-install \     
--name=centos5 \     
--os-variant=RHEL5 \     
--ram=512 \     
--vcpus=1 \     
--disk path=/opt/vms/centos63-webtest.img,format=qcow2,size=7,bus=virtio \  #virtio是其接口类型，即半虚拟化技术
--accelerate \     
--cdrom /data/iso/CentOS5.iso \     
--vnc --vncport=5910 \     
--vnclisten=0.0.0.0 \     
--network bridge=br0,model=virtio \     #此处的网卡即使用了之前在宿主机创建的br0
--noautoconsole

########### 使用nat模式网络###########     
[root@wy ~]# virt-install \     
--name=centos5 \     
--os-variant=RHEL5 \     
--ram=512 \     
--vcpus=1 \     
--disk path=/opt/vms/centos63-webtest.img,format=qcow2,size=7,bus=virtio \     
--accelerate \     
--cdrom /data/iso/CentOS5.iso \     
--vnclisten=0.0.0.0 --vnc --vncport=5910 \     
--network network=default,model=virtio \     
--noautoconsole

########## 从http安装，使用ks, 双网卡, 启用console ########     
[root@wy ~]# virt-install \     
--name=centos63-webtest \     
--os-variant=RHEL6 \     
--ram=4096 \     
--vcpus=4 \     
--virt-type kvm  \     
--disk path=/opt/vms/centos63-webtest.img,format=qcow2,size=7,bus=virtio \     
--accelerate  \     
--location http://111.205.130.4/centos63 \     
--extra-args "linux ip=59.151.73.22 netmask=255.255.255.224 gateway=59.151.73.1 \ 
ks=http://111.205.130.4/ks/xen63.ks console=ttyS0  serial" \
--vnclisten=0.0.0.0 --vnc --vncport=5910 \     
--network bridge=br0,model=virtio \     
--network bridge=br1,model=virtio \     
--force \     
--noautoconsole

########## 安装windows ######## (不能用virtio，因为默认windows没有virtio的硬盘和网卡驱动，即windows不支持半虚拟化)
[root@wy ~]# virt-install \     
--name=win7-test \     
--os-variant=win7 \     
--ram=4096 \     
--vcpus=4 \      
--disk path=/opt/vms/centos63-webtest.img,size=100 \     
--accelerate  \     
--cdrom=/opt/iso/win7.iso       
--vnclisten=0.0.0.0 --vnc --vncport=5910 \     
--network bridge=br0 \       
--force \
--noautoconsole

# 参数说明：     
# --name 指定虚拟机名称     
# --ram 分配内存大小
# --vcpus 分配CPU核心数，最大与实体机CPU核心数相同
# --vcpus 2,cpuset=1,2  将虚拟机的CPU绑定在物理机的哪个核心上，避免多核CPU的核心之间资源漂移的开销
# --disk 指定虚拟机镜像，其size子参数指定分配大小单位为G 
# --network 网络类型，此处用的是默认，一般用的应该是bridge桥接。可以指定两次也就是两块网卡
# --metadata 用户自定义的元数据文本信息
# --accelerate 加速 
# --cdrom 指定安装镜像iso
# --pxe 从网卡启动
# --boot 指定启动顺序，如：--boot hd,cdrom
# --import 从已经存在的磁盘镜像中创建
# --location 从ftp,http,nfs启动 
# --vnc 启用VNC远程管理     
# --vncport 指定VNC监控端口，默认端口5900，端口不能重复
# --vnclisten 指定VNC绑定IP，默认绑定127.0.0.1
# --os-type=linux,windows
# --extra-args 指定额外的安装参数
# --os-variant= [win7 vista winxp win2k8 rhel6 rhel5]
# --force 如果有yes或者no的交互式，自动yes
```
#### 关于KVM的四种简单网络模型
```txt
1. 隔离模式：    虚机之间组建网络，该模式无法与宿主机通信，无法与其他网络通信，相当于虚机都连接到了独立的交换机上
2. 路由模式：    相当于虚机连接到一台路由器上，由路由器(物理网卡)，统一转发，但是不会改变源地址，因此无法实现NAT
3. NAT模式：     在路由模式中会出现虚拟机可以访问其他主机但其他主机的报文无法到达虚拟机
                而NAT模式则将源地址转换为路由器(物理网卡)地址，这样其他主机也知道报文来自哪个主机，docker中常被使用
4. 桥接模式：    在宿主机中创建一张虚拟网卡作为宿主机的网卡，而物理网卡则作为交换机
```
#### 安装系统
安装系统有三种方式，通过：VNC，virt-manager，console配合ks
```bash
#通过VNC来安装
#下载TightVNC连接上vnc安装，只需TightVNC Client即可。如果使用RealVNC就设置ColourLevel=rgb222才能连接
#端口号是安装时指定的，以后的安装流程和普通的是一样的

#通过virt-manager,
#如果你使用xshell那么可以不用安装x window就可以使用virt-manager, 需要安装 x11相关软件
[root@wy ~]# yum -y install libX11 xorg-x11-server-utils xorg-x11-proto-devel dbus-x11 \
xorg-x11-xauth xorg-x11-drv-ati-firmware  xorg-x11-xinit 
[root@wy ~]# virt-manager

#通过virt console
#如果安装时启用了 console可以使用 console来安装。Ctrl+] 可以退出console

#通过virt-viewer
[root@wy ~]# yum -y install virt-viewer xorg-x11-font* virt-viewer centos63-webtest 
```

## 管理KVM虚拟机
#### virsh 常见命令
```bash
1.virsh进入交互模式，在该交互模式下有命令补全。
   virsh # help list   #详细帮助     
2. virsh list --all #查看虚拟机状态     
3. virsh start instanceName #虚拟机开机     
4. virsh shutdown instanceName #虚拟机关机（需要Linux母体机电源管理 service acpid start）  
5. virsh destroy instanceName  #强制关机     
6. virsh create /etc/libvirt/qemu/wintest01.xml #通过以前的配置文件创建虚拟机     
7. virsh autostart instanceName #配置自启动     
8. virsh dumpxml wintest01 > /etc/libvirt/qemu/wintest02.xml #导出配置文件     
9. virsh undefine wintest01 #删除虚拟机配置文件，不会真的删除虚拟机     
10. mv /etc/libvirt/qemu/wintest02.xml /etc/libvirt/qemu/wintest01.xml ; \ 
    virsh define /etc/libvirt/qemu/wintest01.xml      #重新定义虚拟机
11. virsh edit wintest01  #编辑虚拟机配置文件     
12. virsh suspend wintest01  #挂起虚拟机     
13. virsh resume wintest01 #恢复挂起虚拟机     
```

#### 克隆
```bash
#一.使用virt-manager克隆，这个太简单就不演示了，需注意的是如果启用了VNC记得记得更改VNC的端口
#否则启动会失败的，见命令方式修改VNC修改

#二.使用命令克隆虚拟机
    Example：
    [root@wy ~]# virt-clone -o centos63_webtest -n centos63_webtest2 -f /opt/vms/centos_webtest2.img
    #参数说明:     
         -o –-original  #原来实例name     
         -n –-name      #新实例名称     
         -f –-file      #新实例磁盘存放位置
    #注：若启用了vnc则需修改配置文件的vnc端口否则启动失败，文件为：/etc/libvirt/qemu实例名.xml
        #或执行命令直接修改：
            [root@wy ~]# virsh edit <实例名>  ---->  <graphics type='vnc' port='5915'   ............
#三.启动克隆机
#有的Linux版本可能生成的网卡有问题，请修改 /etc/udev/rules.d/70-persistent-cd.rules 重启虚拟机)
[root@wy ~]# virsh start <实例名>
```
#### 快照
```bash
#kvm虚拟机默认使用raw格式的镜像格式，性能最好，速度最快
#它的缺点是不支持一些新功能，如支持镜像，zlib磁盘压缩，AES加密等。要使用镜像功能则磁盘格式必须为qcow2
#快照相关的主要命令：snapshot-create , snapshot-revert , snapshot-delete

#查看磁盘格式
[root@wy ~]# qemu-img info /opt/vms/centos63-119.22.img      
image: /opt/vms/centos63-119.22.img     
file format: qcow2     
virtual size: 40G (42949672960 bytes)     
disk size: 136K     
cluster_size: 65536 

#若不是qcow2格式则需要关机后转换磁盘格式，若是则跳过
[root@wy ~]# cp centos63-119.22.img centos63-119.22.raw     
[root@wy ~]# qemu-img convert -f raw -O qcow2 centos63-119.22.raw  centos63-119.22.img

#启动vm, 建立快照，以后可以恢复 (快照配置文件在/var/lib/libvirt/qemu/snapshot/实例名/..)
[root@wy ~]# virsh start centos63-119.22     
[root@wy ~]# virsh snapshot-create centos63-119.22 

#恢复快照，可以建立一些测试文件，准备恢复
[root@wy ~]# ls /var/lib/libvirt/qemu/snapshot/centos63-119.22
1410341560.xml    
[root@wy ~]# virsh snapshot-revert centos63-119.22 1410341560

删除快照
[root@wy ~]# qemu-img info   centos63-119.22     
1         1410341560             228M 2014-04-08 10:26:40   00:21:38.053 
[root@wy ~]# virsh snapshot-delete centos63-119.2 1410341560
```

#### 添加网卡
```bash
#线上服务器是双网卡，一个走内网一个走外网。但初始虚拟机时没有指定两个网卡，这样需要添加网卡了
#比如已经将br1桥接到em2了，如果不会见刚开始br0桥接em1

#方式一.通过virt-manager添加
#简单描述：选中虚拟机 -- Open -- Details – AddHardware 选择网卡模式，mac不要重复，确定即可

#方式二.通过命令来添加
#1.使用命令"virsh attach-interface"为虚拟机添加网卡
[root@wy ~]# virsh attach-interface centos63-119.23 --type bridge --source br1 --model virtio
#2.导出运行配置并覆盖原来的配置文件，因为attach-interface添加后次网卡只是在运行中的虚拟机内部生效了，但配置文件并未改变
[root@wy ~]# cd /etc/libvirt/qemu
[root@wy ~]# virsh dumpxml centos63-119.23 > centos63-119.23.xml
#3.修改GuestOS中的网卡配置文件，为另一个网卡配置IP
[root@wy ~]# cd /etc/sysconfig/network-scripts  
略...
```
#### 硬盘扩容
```bash
#原来的/opt目录随着使用，空间渐渐满了，这时候我们就需要给/opt的挂载分区扩容了
#有两种情况 1. 该分区是lvm格式 2. 不是lvm格式，且不是扩展分区

#一. 分区是lvm格式 这种很简单，添加一块磁盘，lvm扩容
    #virt-manager添加方式和添加网卡一样，不再赘述，下面是使用命令来添加
    #1. 建立磁盘，并附加到虚拟机中
    [root@wy ~]# qemu-img create -f raw 10G.img 10G     
    [root@wy ~]# virsh attach-disk centos-1.2 /opt/kvm/5G.img vdb  
    #2. 添加qcow2磁盘
    [root@wy ~]# qemu-img create -f qcow2 10G.img 10G     
    [root@wy ~]# virsh attach-disk centos-1.2 /opt/kvm/5G.img vdb --cache=none --subdriver=qcow2 
    #说明:       
    #centos-1.2         虚拟机名称     
    #/opt/kvm/5G.img    附加的磁盘     
    #vdb                添加为哪个磁盘, 也就是在guestos中的名字
    #3. 导出并覆盖原来的配置文件，和网卡一样，attach后只是在虚拟机中生效
    [root@wy ~]# virsh dumpxml centos-1.2 > centos63-119.23.xml
    #4. 使用lvm在线扩容，详见 http://www.cnblogs.com/cmsd/p/3964118.html
    
#二. 分区不是lvm格式，该分区不是扩展分区, 需要关机离线扩展
    1.  新建一个磁盘，大于原来的容量，比如原来是40G，你想对某个分区扩容20G那么
    [root@wy ~]# qemu-img create -f qcow2 60G.img 60G
    2. 备份原来的磁盘以防三长两短
    [root@wy ~]# cp centos63-119.27.img centos63-119.27.img.bak
    3. 查看原来的磁盘决定扩容哪一个分区
    [root@wy ~]# virt-filesystems --partitions --long -a centos63-119.27.img     
    [root@wy ~]# virt-df centos63-119.27.img 
    4. 扩容GuestOS的sda2
    [root@wy ~]# virt-resize --expand /dev/sda2 centos63-119.27.img 60G.img      
    #说明：  
    #/dev/sda2              扩容guestos的/dev/sda2     
    #centos63-119.27.img    原来的磁盘文件
    #60G                    第一步建立的更大的磁盘文件    
    5. 使用新磁盘启动
   [root@wy ~]# mv 60G.img centos63-119.27.img      
   [root@wy ~]# virsh start centos63-119.27
   #virt-resize其实就是将原来磁盘中的文件复制到新的文件中，将想要扩大的分区扩大了
```
#### 动态（实时）迁移
```bash
# 进行实时迁移时，KVM的GuestOS物理镜像必须在共享存储之上，且cpu型号和时钟相同，等等....
# 参考：
# https://www.chenyudong.com/archives/virsh-kvm-live-migration-with-libvirt.html
```
