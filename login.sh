#!/bin/bash

REDIRECTION_TEST_URL="http://captive.apple.com/"

info() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $*"
}

warn() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [WARN] $*"
}

error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ERRO] $*"
}

if [[ -z "$BUPT_USERNAME" || -z "$BUPT_PASSWORD" ]]; then
    error "你必须设置两个环境变量用于网关认证: \$BUPT_USERNAME 为你的学号, \$BUPT_PASSWORD 为你的网关密码"
    exit 1
fi

debug_args=""
if [[ -n "$DEBUG" ]]; then
    debug_args+="-v"
fi

cookie_file=$(mktemp)

cleanup() {
    rm -f "$cookie_file"
}

trap cleanup EXIT

login() {
    redirected_auth_url=$1
    if [[ -z "$redirected_auth_url" ]]; then
        error "未指定认证地址"
        return 1
    fi

    info "准备使用账号 $BUPT_USERNAME 进行认证, 认证地址 $redirected_auth_url"

    if ! curl "$debug_args" \
        -s -c "$cookie_file" \
        -o /dev/null \
        "$redirected_auth_url"; then
        error "获取 cookie 失败"
        return 1
    fi

    if ! curl "$debug_args" \
        -s -b "$cookie_file" \
        -X POST --data "user=$BUPT_USERNAME&pass=$BUPT_PASSWORD" \
        -o /dev/null \
        "${redirected_auth_url/index/login}"; then
        error "发送登录请求失败, 请检查网络连接"
        return 1
    fi

    test_login
}

test_login() {
    curl "$debug_args" -4s "${REDIRECTION_TEST_URL}" | grep -q "Success"
}

main() {
    redirect_resp="$(curl "$debug_args" -4s -w '%{redirect_url}' "${REDIRECTION_TEST_URL}")"

    if [[ $redirect_resp == *Success* ]]; then
        info "您已经登录, 无需进一步操作"
        exit 0
    elif [[ $redirect_resp == *10.3.8* ]]; then
        info "您未登录, 准备认证..."
        if login "$redirect_resp"; then
            info "账号 $BUPT_USERNAME 认证成功"
            exit 0
        else
            error "账号 $BUPT_USERNAME 认证失败"
            exit 1
        fi
    else
        error "未知响应 $REDIRECTION_TEST_URL: \"$redirect_resp\""
        exit 1
    fi
}

main
