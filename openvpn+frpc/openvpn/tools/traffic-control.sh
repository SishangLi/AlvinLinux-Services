#!/bin/bash
# 
# Traffic shaping for data rate limiting of individual client 
# with tc (traffic control) command
#
[ "$script_type" ] || exit 0
[ "$dev" ] || exit 0

build_classid() {
  local classid=0
  if [ "$ifconfig_pool_remote_ip" ]; then
    # local ip_byte1=`echo "$ifconfig_pool_remote_ip" | cut -d. -f1`
    # local ip_byte2=`echo "$ifconfig_pool_remote_ip" | cut -d. -f2`
    # local ip_byte3=`echo "$ifconfig_pool_remote_ip" | cut -d. -f3`
    local ip_byte4=`echo "$ifconfig_pool_remote_ip" | cut -d. -f4`
    # Class ID is hex, and can go up to FFFF, which is 65535.
    # classid=$((256*256*256*ip_byte1+256*256*ip_byte2+256*ip_byte3+ip_byte4))
    classid=$((ip_byte4))
  fi
  echo $classid
}

speed_contract() {
  # set up/down or in/out rate based on ip, username or common name
  # in format: eg. 1mbit-2mbit
  # which allows 1mbit traffic rate from client to server and 2mbit 
  # traffic rate from server to client
  echo '512kbit-512kbit'
}

# cidr_network() {
#  local i1 i2 i3 i4 m1 m2 m3 m4
#  IFS=. read -r i1 i2 i3 i4 <<< "$ifconfig_broadcast"
#  IFS=. read -r m1 m2 m3 m4 <<< "$ifconfig_netmask"
#  printf "%d.%d.%d.%d/%s" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))" "$ifconfig_netmask"
# }

cut_ip_local() {
  if [ -n "${ifconfig_local}" ]; then
    ip_local_byte1=`echo "$ifconfig_local" | cut -d. -f1`
    ip_local_byte2=`echo "$ifconfig_local" | cut -d. -f2`
	ip_local_byte3=`echo "$ifconfig_local" | cut -d. -f3`
  fi
}

start_tc() {
  [ "$script_type" = "up" ] || exit 0
  # echo "openvpn startup" && printenv
  
  cut_ip_local	

  tc qdisc add dev "$dev" root handle 1: htb
  # Round robin type, provide each session the chance to send 
  # data in turn. It changes its hashing algorithm within an 
  # interval. No single session will able to dominate outgoing bandwidth.
  #tc qdisc add dev "$dev" root sfq perturb 10
  #
  # Hashing filters for very fast massive filtering, see more:
  # http://tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.adv-filter.hashing.html
  #
  # we make a filter root, then we create a table with 256 entries.
  #
  # For traffic from vpn server to client
  tc filter add dev "$dev" parent 1:0 prio 1 protocol ip u32
  tc filter add dev "$dev" parent 1:0 prio 1 handle 2: protocol ip u32 divisor 256
  tc filter add dev "$dev" parent 1:0 prio 1 protocol ip u32 ht 800:: \
      match ip dst "${ip_local_byte1}"."${ip_local_byte2}"."${ip_local_byte3}".0/24 \
      hashkey mask 0x000000ff at 16 link 2:
  
  tc qdisc add dev "$dev" handle ffff: ingress
  # For traffic from vpn client to server
  tc filter add dev "$dev" parent ffff:0 prio 1 protocol ip u32
  tc filter add dev "$dev" parent ffff:0 prio 1 handle 3: protocol ip u32 divisor 256
  tc filter add dev "$dev" parent ffff:0 prio 1 protocol ip u32 ht 800:: \
      match ip src "${ip_local_byte1}"."${ip_local_byte2}"."${ip_local_byte3}".0/24 \
      hashkey mask 0x000000ff at 12 link 3:
  
}

stop_tc() {
  [ "$script_type" = "down" ] || exit 0
  #echo "openvpn shutdown" && printenv
  tc qdisc del dev "$dev" root
  tc qdisc del dev "$dev" handle ffff: ingress
}

bwlimit_on() {
  [ "$script_type" = "client-connect" ] || exit 0
  # echo "openvpn client connected" && printenv
  [ "$common_name" ] || exit 0
  # [ "$username" ] || exit 0
  local rates=`speed_contract`
  local uprate=`echo "$rates" | cut -d- -f1`
  local downrate=`echo "$rates" | cut -d- -f2`
  # use the 4th part as hash key
  local hashkey=`echo "$ifconfig_pool_remote_ip" | cut -d. -f4 | xargs printf "%x"`
  local classid=`build_classid`
  [ $classid -gt 0 ] && [ $classid -lt 65536 ] || exit 0 # skip invalid classid
  classid=`printf "%x" $classid`
  echo $classid
  # limit traffic from vpn server to client
  tc class add dev "$dev" parent 1: classid 1:"$classid" htb rate "$downrate"
  tc filter add dev "$dev" parent 1:0 protocol ip prio 1 \
      handle 2:"$hashkey":"$classid" \
      u32 ht 2:"$hashkey": match ip dst "$ifconfig_pool_remote_ip"/32 flowid 1:"$classid"

  # limit traffic from vpn client to server
  tc filter add dev "$dev" parent ffff:0 protocol ip prio 1 \
      handle 3:"$hashkey":"$classid" \
      u32 ht 3:"$hashkey": match ip src "$ifconfig_pool_remote_ip"/32 \
      police rate "$uprate" burst 10k drop flowid :"$classid"
}

bwlimit_off() {
  [ "$script_type" = "client-disconnect" ] || exit 0
  #echo "openvpn client disconnected" && printenv
  [ "$common_name" ] || exit 0
  #[ "$username" ] || exit 0

  # use the 4th part as hash key
  local hashkey=`echo "$ifconfig_pool_remote_ip" | cut -d. -f4 | xargs printf "%x"`
  local classid=`build_classid`
  [ $classid -gt 0 ] && [ $classid -lt 65536 ] || exit 0 # skip invalid classid
  classid=`printf "%x" $classid`
  tc filter del dev "$dev" parent 1:0 protocol ip prio 1 \
      handle 2:"$hashkey":"$classid" u32 ht 2:"$hashkey":
  tc class del dev "$dev" classid 1:"$classid"
  
  tc filter del dev "$dev" parent ffff:0 protocol ip prio 1 \
      handle 3:"$hashkey":"$classid" u32 ht 3:"$hashkey":
}


# 
case "$script_type" in
  up)
    start_tc
    ;;
  down)
    stop_tc
    ;;
  client-connect)
    bwlimit_on
    ;;
  client-disconnect)
    bwlimit_off
    ;;
  *)
    : # do nothing
    ;;
esac
exit 0
