# bupt-net-login

这是一个用于认证北京邮电大校园网网关的脚本。

还在因为服务器没有 GUI 难以登录校园网而烦恼吗？还在因为偶尔网络掉线而忧虑吗？快用 bupt-net-login 吧！

## 为什么选择这个脚本

众所周知，现在北邮无线网 (portal) 认证 `10.3.8.216` 需要加参数了（有线网 `10.3.8.211` 暂时还不需要），传统直接一个 POST 怼到 `10.3.8.216/login` 不行了，而目前绝大多数的脚本都是这么做的，所以跑不了了。

这个脚本能同时处理有线网和无线网的认证，并掉线自动登录，确保长期在线。

如果后续北邮认证又做了什么更改，我又没更新，可以提 issue （x 。

## 准备工作

首先，建议在类 Unix 系统下运行该脚本（例如 Linux, macOS, FreeBSD 之类），因为：

- 本脚本的全部依赖通常在这些操作系统下一般都是满足的（不像 Windows 需要装点东西），所以能不用管啥直接跑；
- Linux, FreeBSD 之类操作系统一般不安装 GUI ，登录网关认证没那么简单，符合本脚本解决的问题；

那 Windows 用户呢？最简单的就是直接用浏览器登录得了，接下来的所有内容都 **不** 针对 Windows 。不过如果你就是想要自动化登录怎么办呢？既然你都有这个想法了，说明你一定有能力解决遇到的问题的罢！(关键词: MinGW, WSL **1** , Cygwin) 后续会提供 Windows 的运行教程，目前还没有打算 <del>绝对不是懒</del> 。

然后您需要确保你的计算机上有 `bash` 和 `curl` 。一般来说这两个都已经满足（ Windows 除外）。可以直接在命令行运行 `bash --version` 和 `curl --version` ，如果没有，安装即可。

接下来你需要下载这个项目的代码，使用 `git clone https://github.com/charlie0129/bupt-net-login.git`。注意：不要使用 GitHub 的下载 zip 功能，因为有可能会丢失权限。下载完成后进入目录 `cd bupt-net-login`。

## 手动登录

立即登录网关，只登录一次，一般用于测试。

```bash
BUPT_USERNAME='你的学号' BUPT_PASSWORD='你的网关密码' ./bupt-net-login
```

<details>
<summary>样例输出</summary>

如果你已经登录：
```console
2023-05-06 09:24:16 [INFO] 您已经登录, 无需进一步操作
```
如果你没有登录：
```console
2023-05-06 09:24:16 [INFO] 您未登录, 准备认证...
2023-05-06 09:24:16 [INFO] 准备使用账号 xxx 进行认证, 认证地址 xxx
2023-05-06 09:24:16 [INFO] 获取 cookie ...
2023-05-06 09:24:16 [INFO] 正在认证...
2023-05-06 09:24:17 [INFO] 账号 xxx 认证成功
```
</details>

## 自动登录

这是建议的用法，可以保证你的网关一直都是登录的。默认情况下会 _每小时_ 检查网关是否登录，如果没有将自动登录。

有两种运行方法: Docker 和 本机。

### 使用 Docker

如果你的系统是 Linux 并有 Docker ，那么这是建议的方法。如果你不知道什么是 Docker ，那么你可以使用下一种方法。

如果你使用这种方法，你可以跳过上面下载项目代码的步骤。

- 如果你直接使用 `docker run`：
    ```bash
    docker run \
        --detach \
        --name bupt-net-login \
        --restart unless-stopped \
        --network host \
        -e BUPT_USERNAME="你的学号" \
        -e BUPT_PASSWORD="你的网关密码" \
        charlie0129/bupt-net-login
    ```
    接下来它会在后台运行并自动检查登录态，后续你可以使用 `docker logs bupt-net-login` 查看日志。

- 如果你希望使用 `docker compose`：你可以查阅本项目下的 `docker-compose.yml` ，其中包含了足够的例子。然后使用 `docker compose up -d` 来启动。

### 本机运行

如果你本机没有 Docker ，或者你觉得运行 Docker 对你来说太重或太困难（例如 macOS 和 FreeBSD ），或者你不知道什么是 Docker 。那么本机运行都是建议的方法。

```bash
BUPT_USERNAME='你的学号' \
    BUPT_PASSWORD='你的网关密码' \
    sudo ./install.sh
```
接下来它会在后台运行并自动检查登录态，后续你可以使用 `cat /tmp/bupt-net-login.log` 查看日志。

这会做什么：

- 安装 bupt-net-login 至 /usr/local/bin 。这也是需要 sudo 的原因。如果你希望更改安装位置, 请设置 PREFIX 环境变量。例如：
    ```bash
    BUPT_USERNAME='你的学号' \
        BUPT_PASSWORD='你的网关密码' \
        PREFIX=$HOME/bin \
        ./install.sh
    ```
- 安装 cron job （用于定时检查登录态）至当前用户（如果你用了 sudo 那就是 root ，如果没有那就是当前用户）。

## 高级

### 自定义 cron

默认每小时检查一次登录态，你可以通过附加命令行参数来自定义它，参数为标准 cron 格式 `x x x x x`。

例如你想每分钟运行一次：
- 在 `docker run` 的时候附加参数：`docker run <省略> charlie0129/bupt-net-login "* * * * *"` 
- 本机运行 `install.sh` 的时候附加参数：`<环境变量省略> ./install.sh "* * * * *"`。

