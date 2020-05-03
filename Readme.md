## AlvinLinux-services

综述：Docker微服务一键部署

### 代理

- [HTTP代理](https://github.com/SishangLi/AlvinLinux-Services/tree/master/squid-proxy)
位于squid，使用Dockerfile构建，详情参阅该服务下的README文件。该服务主要用于内网http协议代理访问。

- [v2ray+ws+tls 科学上网](https://github.com/SishangLi/AlvinLinux-Services/tree/master/nginx%2Bv2ray)

### [预处理脚本](https://github.com/SishangLi/AlvinLinux-Services/tree/master/vps-init)
- 此脚本用于初始化新建的VPS实例，包括root密码修改、新建用户以及安装常用软件包。

### [OpenVPN+Frpc虚拟个人网络搭建]()
- 基于[kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)，增加了账户认证和限速功能。
- 预计完善一键脚本，敬请期待...

