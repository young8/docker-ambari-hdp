#!/bin/bash

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

# sync with time server
#ntpdate pool.ntp.org
ntpdate timeserver.svl.ibm.com
service ntpd start

# start ssh server
service sshd start

# start ambari
/usr/sbin/ambari-server start

#start ambari agent
HOST_SERVER="$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')"
SERVER="$(/bin/hostname -i)"

sed -i.bak "s@hostname=localhost@hostname=$SERVER@g" /etc/ambari-agent/conf/ambari-agent.ini && \
cat /etc/ambari-agent/conf/ambari-agent.ini
/usr/sbin/ambari-agent start

echo "all boostrap commands executed"

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" ]]; then
  /bin/bash
fi
