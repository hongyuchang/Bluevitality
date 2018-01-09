流程：
> **工作区** ---> **暂存区** ---> **版本库** ---> **远程仓库**  
> Git中文件的三种状态：已修改（还未add到Index）---> 已暂存（所有的修改还未提交）---> 已提交（存在版本库中）  
> HEAD：是当前分支版本最顶端的别名，即在当前分支的最后一次提交，相当变量  
> Index：暂存区是一系列将被提交到本地仓库文件集合。它也是将成为HEAD的那个commit对象 


#### 初始化Git环境设置
```
生成SSH密钥对：   
ssh-keygen -t rsa -C "youremail@example.com"

初始化当前目录以生成版本库".git"： 
    git init . 
    
创建Git服务端的无工作区的裸仓库：  
    git init --bare workspace.git
    
环境设置：    
    选项 
        --global：   用户全局
        --system：   系统全局
        --local：    仅针对当前项目
    
跳过命令设置的方式对特定作用范围的配置文件直接进行编辑：   
    git config -e [--global | --system | --local]

设置用户信息：（用户信息位于 ~/.gitconfig，若 --system 则位于 /etc/gitconfig，工作目录的 .git/conf 仅对当前项目生效）  
    git config --global user.name  "bluevitality"
    git config --global user.email "inmoonlight@163.com"
    
设置默认的编辑器：  
    git config --system core.editor vim
    
设置默认的差异分析工具：  
    git config --system merge.tool vimdiff
    
使用别名代替常用命令：  
    git config --global alias.st status
    
查看所有的Git配置信息：  
    git config --list
```
