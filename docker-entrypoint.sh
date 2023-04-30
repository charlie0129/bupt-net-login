#!/bin/bash

if [[ -z "$BUPT_USERNAME" || -z "$BUPT_PASSWORD" ]]; then
    echo "你必须设置两个环境变量用于网关认证: \$BUPT_USERNAME 为你的学号, \$BUPT_PASSWORD 为你的网关密码"
    exit 1
fi

cron="0 * * * *"

# Use user-specified cron, if possible.
if [[ "$1" != "" ]]; then
    cron="$1"
fi

echo "$cron /login.sh > /proc/1/fd/1 2>/proc/1/fd/2" | tee /var/spool/cron/crontabs/root

crond -l 2 -f
