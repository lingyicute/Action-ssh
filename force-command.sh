#!/bin/bash
#
# sshd 的 ForceCommand 入口。
#
# 为什么需要它：`ForceCommand tmux attach` 这种写法的副作用是
# 「客户端想做的事」被完全丢弃 —— sftp / scp / rsync / git over ssh
# 甚至是 `ssh host '命令'` 都会变成去 attach tmux，于是全部失败
# （实测：加了 Subsystem sftp 也没用，因为 ForceCommand 会覆盖子系统请求）。
#
# sshd 会把客户端原始请求放进 SSH_ORIGINAL_COMMAND，这里按内容分流：
#   空              交互式登录       -> 进入（或复用）tmux 会话
#   internal-sftp   sftp/scp         -> 交给 sftp-server
#   其它            ssh host <cmd>   -> 原样执行
set -u

cmd="${SSH_ORIGINAL_COMMAND:-}"

if [ -z "$cmd" ]; then
    # -A：会话在就 attach，不在就新建
    exec tmux new-session -A -s runner
fi

case "$cmd" in
    internal-sftp | */sftp-server)
        for server in /usr/lib/openssh/sftp-server /usr/libexec/sftp-server /usr/libexec/openssh/sftp-server; do
            [ -x "$server" ] && exec "$server"
        done
        echo "sftp-server 未找到，无法提供 sftp/scp" >&2
        exit 1
        ;;
    *)
        # 与 sshd 默认行为一致：交给 shell 执行原命令
        exec /bin/sh -c "$cmd"
        ;;
esac
