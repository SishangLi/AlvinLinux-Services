# frps-docker
[frp](https://github.com/fatedier/frp)服务器端容器镜像

# 使用方法

首先创建配置`frps.ini`文件，然后将其挂载到容器的`/etc/frp`文件夹中。

## docker

```
$ mkdir ./config
$ tee ./config/frps.ini <<-'EOF'
[common]
bind_port = 7000
log_file = /var/log/frps.log
EOF
$ docker run -d \
       --network host \
       --name frps \
       -v `pwd`/config:/etc/frp \
       -v `pwd`/log:/var/log \
       traceflight/frps
```

## docker-compose

```
$ git clone https://github.com/traceflight/frps-docker.git
$ cd frps-docker
$ docker-compose up -d
```

# 配置

参考[官方说明](https://github.com/fatedier/frp/blob/master/README_zh.md)
