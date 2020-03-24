## v2ray + ws + tls 科学上网

### nginx代理
- conf/ 为nginx配置文件。default.conf.http是为网站申请SSL证书时用到的配置文件，屏蔽了https段。获取SSL证书后，更换为default.conf配置文件。default.conf中有给v2ray路由的配置选项，涉及到给v2ray路由的主机名。
- html/ 网页源码
- ssl/ 证书文件
- weboot 为申请证书时使用的临时目录，域名申请时需要挂在

### v2ray
- config.json 为配置文件，可以设置v2ray端口、id、额外id、域名、伪装路径、监听主机

### script.conf
- 一键脚本得到的配置文件

### creat-ssl
- 为网站生成证书，使用时需要修改nginx配置文件，屏蔽https段

### docker-compose.yml.back
- host方式启动，可以正常运行，不能上谷歌学术

### docker-compose.yml
- bridge方式网络，启用IPV6
- 容器内部可以获取IPV6地址，`ping6 ipv6.baidu.com` 可以解析目标地址，但是ping不通，目前无解

### 为docker服务启动ipv6支持
```shell
{
    "ipv6": true,
    "fixed-cidr-v6": "2001:db8:1::/64"
}
```

