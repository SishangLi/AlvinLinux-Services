## AlvinLinux-services

综述：Docker微服务一键部署

### 代理

- HTTP代理

位于squid，使用Dockerfile构建，详情参阅该服务下的README文件。该服务主要用于内网http协议代理访问。

### 预处理脚本（还没有实现）
对刚刚都买的实例进行预处理包括但不限于以下内容：
- yum更新
- 修改hostname
- 安装docker和docker-compose
