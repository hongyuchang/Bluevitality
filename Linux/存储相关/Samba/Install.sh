#!/bin/bash

SAMBA_DATA_HOME="/samba_data"
SAMBA_USERS=(admin1 admin2 test)
DEFAULT_PASS="123456"

set -e
set -x

setenforce 0 || :
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

yum -y install samba samba-client

#数据
mkdir -p ${SAMBA_DATA_HOME}/{Public,Develop}
chown nobody:nobody ${SAMBA_DATA_HOME}/Public
chmod -R o+w ${SAMBA_DATA_HOME}/Public

#配置
mv /etc/samba/smb.conf /etc/samba/smb.conf.origin
cat > /etc/samba/smb.conf <<EOF
[global]
        workgroup = WORKGROUP
        server string = Ted Samba Server %v
        netbios name = TedSamba
        security = user
        map to guest = Bad User
        passdb backend = tdbsam

[Public]
        comment = share some files
        path = ${SAMBA_DATA_HOME}/Public
        public = yes
        writeable = yes
        create mask = 0644
        directory mask = 0755

[Develop]
        comment = project development directory
        path = ${SAMBA_DATA_HOME}/Develop
        valid users = admin1,admin2
        write list = ted
        printable = no
        create mask = 0644
        directory mask = 0755
EOF


groupadd samba 2> /dev/null || :

for user in ${SAMBA_USERS[@]}
do
    if ! id $user &> /dev/null ;then
        useradd  $user -G samba -M -s /sbin/nologin
    fi
    echo -e "${DEFAULT_PASS}\n${DEFAULT_PASS}" | smbpasswd -s -a $user
    [[ "$?" == "0" ]] && echo "create samba user: $user ..."
done

[ -x /usr/bin/systemctl ] || exit 1 
[ -x /usr/bin/systemctl ] && {
    systemctl start smb
    systemctl enable smb
}

function firewall_set() {
    firewall-cmd --permanent --add-port=139/tcp
    firewall-cmd --permanent --add-port=445/tcp
    systemctl restart firewalld
}

firewall_set &> /dev/null

exit 0
