```txt
NAME	        SERVICE
Keystone	Identity	        认证*
Glance	        Image	                镜像*
Nova	        Compute	                计算*
Neutron	        Networking	        网络*
Cinder	        Block Storage	        块存储
Swift	        Object Storage	        对象存储
Horizon	        Dashboard	        面板*
Heat	        Orchestration	        编排
Ceilometer	Telemetry	        监控
Sahara	        Elastic Map Reduce	大数据部署
----------------------------------------------------------------
Service	Code Name	        Description
Identity Service	        Keystone	User Management
Compute Service	                Nova	        Virtual Machine Management
Image Service	                Glance	        Manages Virtual image like kernel image or disk image
Dashboard	                Horizon	        Provides GUI console via Web browser
Object Storage	                Swift	        Provides Cloud Storage
Block Storage	                Cinder	        Storage Management for Virtual Machine
Network Service	                Neutron	        Virtual Networking Management
Orchestration Service	        Heat	        Provides Orchestration function for Virtual Machine
Metering Service	        Ceilometer	Provides the function of Usage measurement for accounting
Database Service	        Trove	        Database resource Management
Data Processing Service	        Sahara	        Provides Data Processing function
Bare Metal Provisioning	        Ironic	        Provides Bare Metal Provisioning function
Messaging Service	        Zaqar	        Provides Messaging Service function
Shared File System	        Manila	        Provides File Sharing Service
DNS Service	                Designate	Provides DNS Server Service
Key Manager Service	        Barbican	Provides Key Management Service
```
![img](资料/Openstack.PNG)
