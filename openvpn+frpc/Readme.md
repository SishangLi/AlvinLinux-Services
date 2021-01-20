# OpenVPN+Frpc

## 声明
- 本项目是利用docker微服务方式构建的虚拟个人网络。适用于校外访问校内资源及在公司外部访问公司内部网络。**请在法律及机构规章制度内妥善使用，由此项目带来的任何安全问题和利益纠纷，请使用者自己承担！**
- 本项目只提供实现上述功能的一种方案，速度和稳定性不能保证。欢迎点赞、fork。
- 需要的资源：
  - 一台公网服务器
  - 一台内网服务器

## 方案描述
- 本项目使用docker微服务的方式使用内网穿透frp和OpeVPN构成，实现了用户名密码认证和客户端的限速功能。
- OpenVPN镜像在[kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)基础上构建，增加了"openssh-client"包用来实现客户端账户认证。
- 账户认证：账户认证采用向目标服务器内用户名密码来认证，可以通过在[checkpsw.sh](https://github.com/SishangLi/AlvinLinux-Services/blob/master/openvpn%2Bfrpc/openvpn/tools/checkpsw.sh)脚本中修改目标服务器IP快速方便地更换目标服务器。在客户端输入用户名和密码后通过接受到的用户名密码使用ssh来登录目标服务器，若登录成功则认证成功，否则认证失败。详情请阅读[认证脚本](https://github.com/SishangLi/AlvinLinux-Services/blob/master/openvpn%2Bfrpc/openvpn/tools/checkpsw.sh)。（账户认证还可以采用自建**用户名密码对**的文本来实现，这种方式使用文本存储用户名和明文密码对，位于服务端。由于密码以明文方式存储，不是安全的方式，故不推荐，若有需要，可以参考[教程1](https://xu3352.github.io/linux/2017/06/08/openvpn-use-username-and-password-authentication)[教程2](https://www.wangfeng.live/2019/09/osxzhmmdl/)）
- 客户端限速：若OpenVPN用户人数增多，对客户端进行限速是很有必要的。
  - 方案1：采用插件的形式，可以参阅[教程](http://www.sskywatcher.com/blog/archives/48)。不过，经过测试，次方案在本项目中测试未通过。可能是因为openvpn部署在容器中的原因，若openvpn部署在物理机上可以尝试。若基于[kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)使用插件，需要启动容器后，在容器内部编译，而且需要在容器内安装`make` `gcc` `libc-dev` 方可使插件编译通过，生成bwlimitplugin.so文件。
  - 方案2：此方案和方案1原理相同，均是使用TC环境在网卡上对IP报文进行过滤实现针对IP的限速。不过此方案是使用脚本方式执行，在openvpn服务端启动、停止以及客户端连接、断开时动态生成和删除TC队列和包过滤器，详情参见[限速脚本](https://github.com/SishangLi/AlvinLinux-Services/blob/master/openvpn%2Bfrpc/openvpn/tools/traffic-control.sh)。关于TC可以[点此](https://blog.csdn.net/pansaky/article/details/88801249)了解。关于限速脚本来源可以参考[教程](https://serverfault.com/questions/777875/how-to-do-traffic-shaping-rate-limiting-with-tc-per-openvpn-client)。
  - 客户端限速脚本：
    - 此脚本是在openvpn的服务端子网为192.168.255.0/24，即本项目的默认配置下测试通过的。实测，若子网选择不同，如选择10.8.0.0/16或其他，可能需要修改该脚本的 `build_classid() cut_ip_local() start_tc() bwlimit_on()`中相关联的地方，请根据规律自行修改。是否需要修改请自行查看openvpn服务端运行后的日志，若出现"match illegal" 或者 "illegal ID"的错误并且客户端速度并没有被限制，则需要检查并修改该脚本内容。
    - 修改该脚本的28行可以修改限速值，单位kbit/s。若需要增加多级限速，请参考[这里](https://serverfault.com/questions/777875/how-to-do-traffic-shaping-rate-limiting-with-tc-per-openvpn-client)修改脚本。

## 快速使用指南
### 以下步骤为快速部署提供命令指南，默认采用docker-compose构建、开启账户认证并使用方案二限速(请确保已安装docker-ce和docker-compose)。
#### OpenVPN配置
- 克隆本项目 `https://github.com/SishangLi/AlvinLinux-Services.git` 本项目包含了作者的其他工具和脚本文件，本教程只需要openvpn+frpc下的文件，其他文件若不需要可自行删除。

- 生成镜像 `cd AlvinLinux-Services/openvpn+frpc/openvpn/create-image && docker build -t kylemanna/openvpn .` （若不成功可以尝试直接拉取`docker pull kylemanna/openvpn`）

- 生成配置文件 `cd .. && docker-compose run --rm openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM` (将`VPN.SERVERNAME.COM`换成所在服务器的IP。

- 生成证书 `docker-compose run --rm openvpn ovpn_initpki` ，依次需要输入：
  - 根证书 CA KEY 密码
  - 确认 CA KEY 密码
  - Common Name 名字
  - 根证书 CA KEY 密码
  - 根证书 CA KEY 密码
  
- 修改配置文件权限 `sudo chown -R $(whoami): ./openvpn-data` 可忽略。若未执行此步骤需要使用sudo修改以下文件内容

- 修改openvpn配置文件 `vim openvpn-data/conf/openvpn.conf`
  - 在openvpn配置文件中修改**user**和**group**的身份，这里默认开启限速和认证功能，直接修改为``root`（注：本着docker微服务拥有的权限越少越好的原则，若不启用限速功能，可以不必使用`root`。如果只启用账户认证将原来的`nobody`修改为`openvpn`即可，若认证功能也不启用，则不需要修改，维持nobody即可。）：
    
    ```
    user root 
    group root
    ```

  - 在openvpn配置文件中添加以下内容，开启账户认证：
    ```shell
    ### use username and password login
    auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env
    client-cert-not-required
    username-as-common-name
    script-security 3
    ```

  - 在openvpn配置文件中添加以下内容，开启限速功能：
    ```shell
    ### band width limit
    down-pre
    up /etc/openvpn/traffic-control.sh
    down /etc/openvpn/traffic-control.sh
    client-connect /etc/openvpn/traffic-control.sh
    client-disconnect /etc/openvpn/traffic-control.sh
    ```
  
  - 在openvpn配置文件中注释以下内容：
    ```shell
    # 以下三行内容不注释不影响使用，但是客户端会有警告
    # push "block-outside-dns"
    # push "dhcp-option DNS 8.8.8.8"
    # push "dhcp-option DNS 8.8.4.4"
    # 注释以下路由规则，默认不路由任何网络
    # route 192.168.254.0 255.255.255.0
    ```
  
- 复制账户认证和限速功能需要的脚本到openvpn挂载目录 `cp tools/* openvpn-data/conf/`

- 修改文件权限
  - `chmod +x openvpn-data/conf/checkpsw.sh openvpn-data/conf/traffic-control.sh`
  - `chmod 666 openvpn-data/conf/openvpn-password.log`
  - `chmod 777 openvpn-data/conf/pwd.sh`
  
- 修改checkpsw.sh文件，将要认证的目标服务器IP填入替换`xxx.xxx.xxx.xxx`，端口默认22，需要修改端口请自行在该脚本里修改。`vim openvpn-data/conf/checkpsw.sh`

- 修改客户端配置文件client.ovpn
  
  - 获得ca.crt `cat openvpn-data/conf/pki/ca.crt`,替换掉client.ovpn中的`# ------ ca.crt`
  - 获得ta.key `cat openvpn-data/conf/pki/ta.key`,替换掉client.ovpn中的`# ------ ta.key`
  - 此外，为方便自定义需要路由的网络，客户端默认不添加任何路由，服务端也不添加任何路由，客户手动修改`route xxx.xxx.0.0 255.255.0.0`来修改需要接入VPN隧道的网络，如何确定哪些网络需要路由不在本项目的指导范围内，请自行了解。
  - 客户端文件中的`redirect-gateway def1`参数默认是注释的，该参数将客户端全部流量均转入服务端代理，在客户端网络复杂，尤其是不需要代理所有网站时候，此参数是十分糟糕的选项，若需要代理全部流量，取消注释即可。
  - 若服务端IP可以被客户端直接连接到，那么`remote xxx.xxx.xxx.xxx 1194 udp` 参数中的IP直接写服务端所在服务器的IP。事实上，需要OpenVPN的场景下，通常是无法直接连接到服务端的，这就需要frp来做内网穿透，这里需要填写frp服务端公网服务器的IP，端口填写frp为OpenVPN设置的远程端口。详情参见下面frp的设置。
  
- 一切准备就绪，启动服务端 `docker-compose up -d`

#### Frp配置
- [Frp](https://github.com/fatedier/frp)用来做内网穿透，可以将OpenVPN的1194端口映射在公网上，从而可以在任意位置连接到内网的openvpn服务上。
- 请在公网服务器下载好frp，并将frp的服务端frps运行在公网服务器上，最简frps.ini配置可参见官网：
```
# frps.ini
[common]
bind_port = 7000
```
- 修改客户端配置文件`openvpn+frpc/frpc-docker/config/frpc.ini`,如下

```
[common]
server_addr = xxx.xxx.xxx 
# 修改为公网服务器的IP
server_port = 7000
log_file = /var/log/frpc.log

[openvpn]
type = udp
local_ip = 127.0.0.1
local_port = 1194
remote_port = 31194
# 默认远程OpenVPN端口设置为31194
```
- 在frpc-docker文件夹内执行 `docker-compose up -d` 启动 frpc
- 将公网服务器的IP 和 OpenVPN的远程端口填入OpenVPN的客户端配置文件中即可。
- 一切准备就绪，客户端连接即可。


#### 参考链接

- [登录测试，用于密码验证脚本参考代码](https://blog.csdn.net/dieaixia5129/article/details/86438820)
- [网卡限速脚本](https://serverfault.com/questions/777875/how-to-do-traffic-shaping-rate-limiting-with-tc-per-openvpn-client)
- [Linux 下 TC 命令原理及详解](https://blog.csdn.net/pansaky/article/details/88801249)