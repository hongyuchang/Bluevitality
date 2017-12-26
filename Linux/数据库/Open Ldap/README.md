#### 备忘 ( 轻量量目录访问协议：LDAP )
```txt
目录是一个为查询、浏览和搜索而优化的专业分布式数据库，它呈树状结构组织数据，就象Linux/Unix中的文件目录一样。
目录数据库和关系数据库不同，它有优异的读性能但写性能差且没有事务处理、回滚等复杂功能，不适于存储修改频繁的数据。
LDAP 是从 X.500 目录访问协议的基础上发展过来的，目前的版本是 v3.0

目录服务是由目录数据库和一套访问协议组成的系统。类似以下的信息适合储存在目录中：
    1.企业员工信息，如姓名、电话、邮箱等
    2.公用证书和安全密钥
    3.公司的物理设备信息，如服务器，它的IP地址、存放位置、厂商、购买时间等
    4.密码，口令

LDAP的特点：
    1.结构用树表示而不是用表格。因此不能用SQL语句
    2.可很快地得到查询结果，不过在写方面慢得多
    3.提供了静态数据的快速查询方式
    4.C/S模式，Server 用于存储数据，Client提供操作目录信息树的工具
    5.这些工具可将数据库的内容以文本格式（LDAP 数据交换格式，LDIF）呈现在面前
    6.LDAP是一种开放Internet标准，LDAP协议是跨平台的Interent协议

LDAP的概念：
    条目：Entry
        也叫记录项，是LDAP中最基本的颗粒，就像字典中的词条或数据库的记录。通常对LDAP的增删改查都是以条目为基本对象的
        每个条目（Entry）都有唯一的标识名：distinguished Name ---> 简称："DN"
        
        Example：dn："cn=baby,ou=marketing,ou=people,dc=mydomain,dc=org"
        通过DN的层次型语法结构，可以方便地表示出条目在LDAP树中的位置，通常用于检索。
        rdn：        一般指dn逗号最左边部分，如cn=baby。它与RootDN不同，RootDN通常与RootPW同时出现，特指管理LDAP中信息的最高权限用户
        Base DN：    LDAP目录树的最顶部就是根，也就是所谓的“Base DN"，如"dc=mydomain,dc=org"。

    属性：Attribute
        属性不是随便定义的，需要符合一定的规则，而这个规则可以通过schema制定（objectClass的类型）
        每个条目都可有很多属性，如常见的人都有姓名、地址、电话等属性。每个属性都有名称及对应值，属性值可有单个或多个
        LDAP为人员组织机构中常见的对象都设计了属性 (比如commonName，surname)。

    LDIF 数据交换格式: "LDAP Data Interchange Format" 是LDAP数据库信息的一种文本格式，用于数据导入/出，每行都是"属性:值"对
    可以说LDIF文件是OpenLDAP操作数据或修改配置的一切来源
    LDIF格式：
        #####注释#####
        dn: 条目1
        属性描述:值
        属性描述:值
        属性描述:值

        #####注释#####
        dn: 条目2
        属性描述:值
        属性描述:值
        属性描述:值
```
#### 数据交换格式：LDIF
```txt
dn: ou=Marketing, dc=example,dc=com     #
changetype: add                         #
objectclass: top                        #通过schema定义条目的属性（即objectClass的作用）
objectclass: organizationalUnit         #每个条目至少要有一个objectclass
ou: Marketing                           #K:V

dn: cn=Pete Minsky,ou=Marketing,dc=example,dc=com
changetype: add                          #
objectclass: person                      #通过schema定义条目的属性（即objectClass的作用）
objectclass: organizationalPerson        #...
objectclass: inetOrgPerson               #...
cn: Pete Minsky                          #K:V
sn: Pete                                 #...
ou: Marketing                            #...
description: sb, sx                      #...
description: sx                          #...
uid: pminsky                             #...
```
#### 常用的 objectClass
```txt
dcobject                                #表示一个公司
ipHost                                  #
alias
organizationalUnit                      #表示一个公司/部门
posixAccount                            #常用于账户认证
```
