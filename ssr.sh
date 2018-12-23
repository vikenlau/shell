#!/bin/bash

base_path="/usr/local/"
#��װ�ͻ���
status_agent(){
   read -p "��ʼ��װServerstatus yes:no: " agent_select
   if [ "$agent_select" == "yes" ];then
     yum install git -y
     cd $base_path
     git clone https://github.com/vikenlau/ServerStatus.git
     yum -y install epel-release;yum -y install python-pip;
     pip install --upgrade pip
     yum clean all;yum -y install gcc; yum -y install python-devel;pip install psutil
     cd ServerStatus/clients
     c_file="client.py"
     read -p "����SERVER��ַ: " server_name
     sed -i "s#^SERVER.*#SERVER = \"$server_name\"#g" $c_file
     read -p "����USER: " user
     sed -i "s#^USER.*#USER = \"$user\"#g" $c_file
     read -p "����PASSWORD: " password
     sed -i "s#^PASSWORD.*#PASSWORD = \"$password\"#g" $c_file
     chmod +x /etc/rc.d/rc.local
     systemctl enable rc-local
     systemctl restart rc-local
     echo "nohup python $base_path/ServerStatus/clients/client.py >> /dev/null 2>&1 &" >>/etc/rc.local
     echo "��ʼ�����ͻ���"
     nohup python client.py &
     sleep 3
  fi

}

#��װ�����
shadow(){
   read -p "��ʼ��װshadow yes:no: " shadow_select
   if [ "$shadow_select" == "yes" ];then

     install python-setuptools && easy_install pip && pip install cymysql speedtest-cli && yum install git
     yum -y groupinstall "Development Tools" 
     wget -P $base_path https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/libsodium-1.0.13.tar.gz
     cd $base_path
     tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
     ./configure && make -j2 && make install&&echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf&&ldconfig
     rm -rf /base_path/libsodium-1.0.13.tar.gz && cd $base_path
     git clone -b manyuser https://github.com/vikenlau/shadowsocks.git
     yum -y install python-devel
     yum -y install libffi-devel
     yum -y install openssl-devel
     cd shadowsocks
     pip install -r requirements.txt
     cp apiconfig.py userapiconfig.py
     cp config.json user-config.json
     api_conf=userapiconfig.py
     read -p "������NODE_ID ���: " node_id
     sed -i "s#^NODE_ID.*#NODE_ID = $node_id#g" $api_conf

     read -p "���������ӷ�ʽ glzjinmod ���� modwebapi �س�Ĭ��Ϊmodwebapi: " api
     if [ -z "$api" ];then
      api=modwebapi
     fi
     sed -i "s#^API_INTERFACE.*#API_INTERFACE = \'$api\'#g" $api_conf
     echo $api
     if [ "$api" == "modwebapi" ];then
        echo "webapi ģʽ"
     #webapi 
        read -p "������webapi url��ַ Ĭ��Ϊhttps://zhaoj.in �س�����: " api_url
        [ -z "$api_url" ]&&api_url="https://zhaoj.in"
        sed -i "s#^WEBAPI_URL.*#WEBAPI_URL = \'$api_url\'#g" $api_conf
     #token
        read -p "������WEBAPI_TOKEN Ĭ��Ϊglzjin :" token
        [ -z "$token" ] && token="glzjin"
        sed -i "s#^WEBAPI_TOKEN.*#WEBAPI_TOKEN = \'$token\'#g" $api_conf
     elif [ "$api" == "glzjinmod" ];then
        echo "sqlģʽ ����Ҫ�������ݿ�"
#mysql_host
        read -p "������MYSQL_HOST Ĭ��Ϊ127.0.0.1 : " mysql_host
        [ -z $mysql_host ]&& mysql_host="127.0.0.1"
        sed -i "s#^MYSQL_HOST.*#MYSQL_HOST = \"$mysql_host\"#g" $api_conf

#mysql_port
        read -p "������MYSQL_PORT Ĭ��Ϊ3306: " mysql_port
        [ -z $mysql_port ]&& mysql_port="3306"
        echo $mysql_port
        sed -i "s#^MYSQL_PORT.*#MYSQL_PORT = $mysql_port#g" $api_conf
#mysql_user
        read -p "������MYSQL_USER Ĭ��Ϊxxx: " mysql_user
        [ -z $mysql_user ]&& mysql_user="default_user"
        sed -i "s#^MYSQL_USER.*#MYSQL_USER = \"$mysql_user\"#g" $api_conf
#mysql_pass
        read -p "������MYSQL_PASS Ĭ��Ϊxxx : " mysql_pass
        [ -z $mysql_pass ]&& mysql_pass="default_pass"
        sed -i "s#^MYSQL_PASS.*#MYSQL_PASS = \"$mysql_pass\"#g" $api_conf
#mysql_db
        read -p "������MYSQL_DB Ĭ��Ϊxxx: " mysql_db
        sed -i "s#^MYSQL_DB.*#MYSQL_DB = \"$mysql_db\"#g" $api_conf
        [ -z $mysql_pass ]&& mysql_db="default_db"
     fi
     echo "��ʼ��������˳���"
     echo "nohup bash $base_path/shadowsocks/run.sh >> /dev/null 2>&1 &" >>/etc/rc.local
     ./run.sh
     sleep 3
   fi
}


#��������
ddns(){
   read -p "��ʼ���ð�װddns yes:no: " ddns_select
   if [ "$ddns_select" == "yes" ];then
      #����ddns
      echo "����ddns"
      yum install wget -y
      curl https://raw.githubusercontent.com/vikenlau/cfddns/master/cf-ddns.sh > /usr/local/bin/cf-ddns.sh
      chmod +x /usr/local/bin/cf-ddns.sh
      ddns_path=/usr/local/bin/cf-ddns.sh
      read -p "����ddns��֤����: " email
      sed -i "s#^auth_email.*#auth_email=\"$(echo "$email")\"#g" $ddns_path
      read -p "����auth_key: " key
      sed -i "s#^auth_key.*#auth_key=\"$(echo $key)\"#g" $ddns_path
      read -p "����zone_name: " zone_name
      sed -i "s#^zone_name.*#zone_name=\"$(echo $zone_name)\"#g" $ddns_path
      read -p "����record_name: " record_name
      sed -i "s#^record_name.*#record_name=\"$(echo $record_name)\"#g" $ddns_path
      read -p "ddns�Ƿ���붨ʱ����:yes|no" cron_ddns
      if [ $cron_ddns == "yes" ];then
      #���ö�ʱ����
      echo "*/1 * * * *  /usr/local/bin/cf-ddns.sh >/dev/null 2>&1" >>crontab.txt
      /usr/bin/crontab crontab.txt
      fi
        
      
      #�޸�ϵͳʱ��Ϊ����
      rm -rf /etc/localtime
      ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
   fi
}

#��װbbr
bbr(){
read -p "��ʼ���ð�װbbr yes:no: " bbr_select
if [ "$bbr_select" == "yes" ];then
#����ELRepo��Կ
wget https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --import RPM-GPG-KEY-elrepo.org
#��װELRepo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
#���������ں�
yum --enablerepo=elrepo-kernel install kernel-ml -y
#�����ں�����˳��
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
cat >>/etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
#ʹ������Ч
sysctl -p
echo "�����Ч���������tcp_bbr 20480  a0����Ч"

echo "�����Ϊ:`lsmod | grep bbr`"

echo "���ֶ�����������"
fi
}

main(){
  #ִ�ж�Ӧ���ܵĺ���
  status_agent&&ddns&&shadow&&bbr
}

main