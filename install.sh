#!/bin/bash

set -o errexit

if [[ -z "$BUPT_USERNAME" || -z "$BUPT_PASSWORD" ]]; then
    echo "你必须设置两个环境变量用于网关认证: \$BUPT_USERNAME 为你的学号, \$BUPT_PASSWORD 为你的网关密码"
    exit 1
fi

# Install prefix
BIN=bupt-net-login
if [[ -z $PREFIX ]]; then
    PREFIX=/usr/local/bin
fi
echo "安装 $BIN 至 $PREFIX 。如果你希望更改安装位置, 请设置 PREFIX 环境变量。"
install -D bupt-net-login $PREFIX ||
    echo "默认安装位置 $PREFIX 需要 root 权限, 也许你需要以 root 权限运行。"

cron="0 * * * *"
# Use user-specified cron, if possible.
if [[ "$1" != "" ]]; then
    cron="$1"
fi
cronfull="$cron BUPT_USERNAME='$BUPT_USERNAME' BUPT_PASSWORD='$BUPT_PASSWORD' $PREFIX/bupt-net-login >>/tmp/bupt-net-login.log 2>&1"
echo "安装 cron job ($cron) 至当前用户 $USER 。如果你需要自定义 cron , 添加命令行参数即可, 例如 $0 \"$cron\"。"
if crontab -l | grep -q "$PREFIX/bupt-net-login"; then
    echo "先前 bupt-net-login 的 cron job 已安装, 替换之。"
fi

crontab -l 2>/dev/null | sed -e "\_$PREFIX/bupt-net-login_d" | echo -e "$(cat -)\n$cronfull\n" | crontab -
