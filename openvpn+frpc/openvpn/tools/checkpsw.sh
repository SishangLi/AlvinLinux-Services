#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman <mathias@openvpn.se>
#
# This script will authenticate OpenVPN users against
# a plain text file. The passfile should simply contain
# one row per user with the username first followed by
# one or more space(s) or tab(s) and then the password.

LOG_FILE="/etc/openvpn/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
IP="xxx.xxx.xxx.xxx"

########### Create temp passwd file #######################
_tmppwd="$(cd `dirname $0`; pwd)/pwd.sh"

echo "#!/bin/bash">$_tmppwd
echo "echo \"${password}\"">>$_tmppwd

################ Verify passwd ###########################

echo 'exit;'|setsid env SSH_ASKPASS=${_tmppwd} DISPLAY='none:0' ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no ${username}@${IP} -p22 > /dev/null 2>&1

if [ $? -eq 0 ];then			#如果ssh访问成功并且exit命令执行成功，那么返回值为0
	echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE} 
	echo "" > $_tmppwd
	exit 0
else
	echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
	echo "" > $_tmppwd
	exit 1
fi

