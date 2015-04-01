#!/bin/bash

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

# sync with time server
HOST="$(/bin/hostname -f)"
if [[ $HOST == *"svl.ibm.com"* ]]
then
  ntpdate timeserver.svl.ibm.com;
else
  ntpdate pool.ntp.org;
fi
service ntpd start

# start ssh server
service sshd start

# start ambari
/usr/sbin/ambari-server start

#start ambari agent
/usr/sbin/ambari-agent start

echo "all boostrap commands executed"

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" ]]; then
  /bin/bash
fi
