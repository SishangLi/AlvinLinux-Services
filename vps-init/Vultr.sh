#!/usr/bin/bash
set -e

echo "Create user lisishang ..." \
    && useradd lisishang && echo 568884899 | passwd --stdin lisishang \
    && echo "OK!" 

echo "Add lisishang to sudo ..." \
    && chmod -v u+w /etc/sudoers \
    && echo "lisishang ALL=(ALL) ALL" >> /etc/sudoers \
    && echo "OK!" \
	&& echo root:LSS#$%^323 | chpasswd

echo "Install docker-compose ..." \
    && curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose \
	&& usermod -a -G docker lisishang \
    && echo "OK!"

echo "Add port 80/443 to firewall ..." \
    && firewall-cmd --add-port=80/tcp --permanent \
    && firewall-cmd --add-port=443/tcp --permanent \
    && firewall-cmd --reload \
    && echo "OK!"

echo "Seting scholar.google.com.hk IP ..." \
    && cat >>/etc/hosts <<EOF
2404:6800:4008:c06::be scholar.google.com
2404:6800:4008:c06::be scholar.google.com.hk
2404:6800:4008:c06::be scholar.google.com.tw
2404:6800:4005:805::200e scholar.google.cn #www.google.cn
EOF

echo "Installing common packages ..." \
    && yum install -y net-tools git

echo "Installing BBR ..." \
    && wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh \
    && chmod +x bbr.sh \
    && ./bbr.sh

echo "Seting vimrc ..." \
    && su -l lisishang <<EOF
touch /home/lisishang/.vimrc
echo "set ts=4" >>/home/lisishang/.vimrc
echo "set sts=4" >>/home/lisishang/.vimrc
echo "set expandtab" >>/home/lisishang/.vimrc
EOF

echo "rebooting ... " \
	&& reboot








