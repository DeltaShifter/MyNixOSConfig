#!/usr/bin/env bash

if ! command -v zenity &>/dev/null; then
    echo -n  "错误" "未安装 zenity"
    exit 1
fi

if ! command -v wl-copy &>/dev/null; then
    echo -n  "错误" "未安装 wl-clipboard (wl-copy)"
    exit 1
fi

TITLE="游戏输入助手 (Wayland)"

TEXT=$(zenity --entry --title="$TITLE" --text="请输入要发送到游戏的文字：") || exit 1
if [ -z "$TEXT" ]; then
    exit 0
fi

echo -n "$TEXT" | wl-copy
