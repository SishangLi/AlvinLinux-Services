## v2ray + ws + tls 科学上网

### nginx代理
- conf/ 为nginx配置文件。default.conf是为网站申请SSL证书时用到的配置文件，屏蔽了https段。获取SSL证书后，自动修改为default.conf.http。default.conf.https中有给v2ray路由的配置选项，涉及到给v2ray路由的主机名，一键脚本会根据传入参数进行修改，证书生成后自动修改为default.conf。（详情阅读creat-ssl.sh了解）
- html/ 网页源码
- ssl/ 证书文件
- weboot 为申请证书时使用的临时目录，域名申请时需要挂在

### v2ray
- config.json 为配置文件，可以设置v2ray端口、id、额外id、域名、伪装路径、监听主机

### script.conf
- [一键安裝Vray+ws+tls脚本](https://www.hijk.pw/v2ray-one-click-script-with-mask/)得到的配置文件，供配置文件出错时参考

### init-nginx-v2ray.sh
- 为网站生成证书，使用方法 `creat-ssl.sh www.domain.com xxx@gmail.com host(bridge) /pathtov2ray`
- 此脚本完成了一键自动为nginx的https代理生成证书并修改相应配置文件，最后启动nginx和v2ray服务。
- 若此文件以及自clone起以及被执行过一次，则不能再次执行，需要重新clone，否则会因为某些字段找不到出错。经测试，除非ssl证书申请出错（可能是域名短时间内申请次数太多），否则不会出错。出bug请联系作者lisishang@gmail.com

### recreate-ssl.sh
- 证书每过一段时间会失效，失效后使用此脚本重新生成证书。（由于证书目前还没有失效过，故此脚本是否有效有待验证。）

### docker-compose.yml.host
- host方式启动，可以正常运行。

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

-------

注：两种网络方式是因为，若VPS的iIPV4地址被墙，则谷歌学术需要通过修改/etc/hosts来使用IPV6地址访问。按理说host模式就可以实现，实测不可以（2020年上半年）。故寻找在容器中分配IPV6地址来解决此问题，但是因为只是匮乏，容器中分配IPV6地址的方式一致没有成果，在容器中也只能使用IPV4访问。

### 参考链接

- [letsencrypt](https://letsencrypt.org/zh-cn/docs/integration-guide/)
- [一键脚本极配置文件](https://tlanyan.me/v2ray-tutorial/)
- [V2Ray 配置指南](https://toutyrater.github.io/)
- [使用Docker容器签发和自动续期Let's Encrypt证书](https://blog.newnius.com/automated-letsencrypt-certbot-with-docker.html)