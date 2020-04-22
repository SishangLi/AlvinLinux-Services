## v2ray + ws + tls 科学上网

### nginx代理
- conf/ 为nginx配置文件。default.conf是为网站申请SSL证书时用到的配置文件，屏蔽了https段。获取SSL证书后，自动修改为default.conf.http。default.conf.https中有给v2ray路由的配置选项，涉及到给v2ray路由的主机名，一键脚本会根据传入参数进行修改，证书生成后自动修改为default.conf。（详情阅读creat-ssl.sh了解）
- html/ 网页源码
- ssl/ 证书文件
- weboot 为申请证书时使用的临时目录，域名申请时需要挂在

### v2ray
- config.json 为配置文件，可以设置v2ray端口、id、额外id、域名、伪装路径、监听主机

### script.conf
- 网上[一键脚本](https://www.hijk.pw/v2ray-one-click-script-with-mask/)得到的配置文件，供配置文件出错时参考

### init-nginx-v2ray.sh
- 为网站生成证书，使用方法 `creat-ssl.sh www.vultr.com xxx@gmail.com host(bridge) /pathtov2ray`
- 此文件完成了自动替换配置文件中的某些自动，提高了效率。
- 若此文件以及自clone起以及被执行过一次，则不能再次执行，需要重新clone，否则会因为某些字段找不到出错。经测试，除非ssl证书申请出错（可能是域名短时间内申请次数太多），否则不会出错。出bug请联系作者lisishang@gmail.com
- 

### recreate-ssl.sh
- 证书每过一段时间会失效，失效后使用此脚本重新生成证书。（由于证书目前还没有失效过，故此脚本是否有效有待验证。）

### docker-compose.yml.host
- host方式启动，可以正常运行，不能上谷歌学术

### docker-compose.yml.bridge
- bridge方式网络，可以启用IPV6，默认关闭
- 容器内部可以获取IPV6地址，`ping6 ipv6.baidu.com` 可以解析目标地址，但是ping不通，目前无解

### 为docker服务启动ipv6支持
```shell
{
    "ipv6": true,
    "fixed-cidr-v6": "2001:db8:1::/64"
}
```

