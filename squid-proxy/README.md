### Squid-Proxy代理服务
#### 综述
- 基于http协议的代理
- 使用squid提供台历服务，docker容器方式运行，
- 若需修改端口请到docker-compose.ymal和squid.conf文件中修改
- 默认端口 3128
### Dockerfile
- 使用alpine微型容器镜像
- 注意：alpine的版本会影响squid的版本，旧版squid阻塞模式不支持多进程
### entrypoint.sh
- 注意初始化squidcache
- 若docker-compose.ymal中挂在本地物理路径需要添加修改权限的语句，因为在容器中squid是以用户squid的身份运行，而不是root
- **--foreground** 方式为阻塞运行，支持多线程
### docker-compse.ymal
- 若挂在本地物理卷需要再容器中修改身份
- 若挂载非指定物理卷，需要再底部声明，docker会自动创建（位于/var/lib/docker/squid/xxx），这种方式身份问题不存在，但是不方便管理。
### squid.conf
- squid 配置文件
- 需要了解ACL匹配规则
### passwd
- 可以使用 `htpasswd -c /to/file/path/passwd username` 来创建验证文件


