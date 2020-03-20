syslogd
squid -v 
squid -k parse

if [[ -x "/var/cache/squid" ]];then
   echo "Change cache dir owner ..."
   chown squid:squid /var/cache/squid
fi

 if [[ -x "/var/log/squid" ]];then
   echo "Change log dir owner ..."
   chown squid:squid /var/log/squid
fi

if [[ ! -d /var/cache/squid/00 ]]; then 
   echo "Initializing cache..."
   squid -N -f /etc/squid/squid.conf -z
fi

squid --foreground -f /etc/squid/squid.conf
#squid -N -f /etc/squid/squid.conf
