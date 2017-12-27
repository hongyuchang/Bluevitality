#### 下载Docker及说明 （ 环境：CentOS 7.3 ）
```bash
[root@localhost ~]# yum -y install docker
[root@localhost ~]# systemctl enable docker
[root@localhost ~]# systemctl start docker

[root@localhost ~]# systemctl cat docker.service      #Docker的service unit文件
# /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target
Wants=docker-storage-setup.service
Requires=docker-cleanup.timer

[Service]
Type=notify
NotifyAccess=all
EnvironmentFile=-/run/containers/registries.conf
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage                  #存储相关参数在此设置
EnvironmentFile=-/etc/sysconfig/docker-network                  #网络相关参数...
Environment=GOTRACEBACK=crash                                   #环境变量
Environment=DOCKER_HTTP_HOST_COMPAT=1                           #...
Environment=PATH=/usr/libexec/docker:/usr/bin:/usr/sbin         #...
ExecStart=/usr/bin/dockerd-current \                            #启动命令及默认的参数...
          --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current \
          --default-runtime=docker-runc \
          --exec-opt native.cgroupdriver=systemd \
          --userland-proxy-path=/usr/libexec/docker/docker-proxy-current \
          $OPTIONS \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY\
          $REGISTRIES
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
Restart=on-abnormal
MountFlags=slave
KillMode=process

[Install]
WantedBy=multi-user.target
```

#### 下载 docker 镜像 ...
```bash
[root@localhost ~]# docker search bash
INDEX       NAME                                  DESCRIPTION                        STARS  OFFICIAL  AUTOMATED
docker.io   docker.io/bash                        Bash is the GNU Project's Bour....  47     [OK]      
docker.io   docker.io/bashell/alpine-bash         Alpine Linux with /bin/bash as....  13               [OK]
docker.io   docker.io/frolvlad/alpine-bash        Docker image with Bash and com....  5                [OK]
docker.io   docker.io/andthensome/alpin......     Container with Hugo, Git & Bas....  2                [OK]
docker.io   docker.io/cosmintitei/bash-curl       bash image with curl                2                [OK]
docker.io   docker.io/andthensome/alpine....      Minimal container with Node & ....  1                [OK]
docker.io   docker.io/casimir/blinux-bash         Bash in blinux                      1                [OK]
docker.io   docker.io/contentanalyst/java-bash    Alpine with Java and Bash           1                [OK]
docker.io   docker.io/ellerbrock/bash-it          Bash Shell v.4.4 with bash-it,....  1                [OK]
docker.io   docker.io/tianon/bash                 Several versions of Bash, Dock....  1                
docker.io   docker.io/amd64/bash                  Bash is the GNU Project's Bour....  0                
docker.io   docker.io/blang/alpine-bash                                               0                [OK]
docker.io   docker.io/brenix/alpine-bash-git-ssh  Simple alpine image with bash,....  0                [OK]
......(略)         
[root@localhost ~]# docker pull  docker.io/bash                 #下载特定的docker镜像...
Using default tag: latest
Trying to pull repository docker.io/library/bash ... 
latest: Pulling from docker.io/library/bash

1160f4abea84: Pull complete 
35c12c862670: Pull complete 
50313e686d4e: Pull complete 
Digest: sha256:b146a2e9aadaf2ed4a540324094412f2cd3f609f8a2f55ed608285f85f12a0f1
[root@localhost ~]# docker images                               #查看本地的docker镜像
REPOSITORY          TAG                 IMAGE ID            CREATED                  SIZE
docker.io/bash      latest              a853bea42baa        Less than a second ago   12.22 MB

#注：docker官方建议配置信息以参数形式传递进入容器，并且一个容易最好只运行一个进程...
```

#### 
```bash

```
#### 
```bash

```

#### 
```bash

```

#### 
```bash

```

#### 
```bash

```
