# 使用镜像工具

主要的镜像工具`qemu-img`。

## 创建镜像文件

镜像文件的格式，主要有`qcow2`和`raw`，如下用`qemu-img`命令创建镜像文件：

```
qemu-img create -f TYPE FILENAME SIZE
		TYPE :  qcow2, raw
		FILENAME : 文件名
		SIZE : 文件大小，例如`1G`（稀疏格式）
```

用`dd`命令也可以创建`raw`格式的镜像文件，用如下命令：

```
dd if=/dev/zero of=FILENAME bs=1024k count=4096  # 4G Image
```

用如下命令转换镜像文件格式：

```
qemu-img convert -O TYPE SRC_IMG_NAME DEST_IMG_NAME
```

## 加载镜像文件

#### 加载raw格式的镜像文件

+ 加载不分区的镜像文件

```
qemu-img create -f raw test.img 3G 	# 创建镜像
fdisk -lu test.img			# 查看分区情况
mkfs.ext4 test.img  			# 格式化
mount -o loop test.img /PATH
```

+ 加载分区的镜像文件
```
qemu-img create -f raw test.img 3G
fdisk -lu test.img
fdisk test.img  			# 对镜像分区
kpartx -avs test.img  			# 会在/dev/mapper目录下，生成与分区对应的loopXpY文件
mkfs.ext4 /dev/mapper/loop0p1
mount /dev/mapper/loop0p1 /PATH

umount /PATH
kpartx -d test.img
```

#### 加载qcow2格式的镜像文件

加载qcow2格式的镜像文件，需要内核支持NBD(Network Block Device)模块。按如下命令加载：
```
modprobe nbd				# 加载NBD模块

qemu-img create -f qcow2 test.qcow2 2G  # 创建镜像

qemu-nbd -c /dev/nbd0 test.qcow2
kpartx -avs /dev/nbd0
mount /dev/mapper/nbd0p1 /PATH

umount /PATH
kpartx -d /dev/nbd0
qemu-nbd -d /dev/nbd0
```


