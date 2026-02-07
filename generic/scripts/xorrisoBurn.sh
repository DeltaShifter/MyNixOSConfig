#!/usr/bin/env bash

# === 1. 初始化与依赖检查 ===
DEPENDENCIES=("xorriso" "gum" "fzf" "eject" "file" "grep")
for dep in "${DEPENDENCIES[@]}"; do
    command -v "$dep" &> /dev/null || { echo "❌ 缺失核心命令: $dep"; exit 1; }
done

SELECTED_LOG=$(mktemp)
trap 'rm -f "$SELECTED_LOG"' EXIT

cd "$HOME" || exit
CURRENT_DIR=$(pwd)

# === 2. 核心导航函数 ===
while true; do
    cd "$CURRENT_DIR" || exit
    
    # ls -p 仅给目录加斜杠，方便解析
    LIST=$(ls -p --group-directories-first --color=never)
    
    # --- 预览逻辑 ---
    # 优先显示目录，其次尝试 file 命令，失败则降级为 ls -lh
    PREVIEW_STR='sh -c "
        if echo {} | grep -q \"上级目录\"; then 
            ls -p --color=always ..; 
        elif [ -d {} ]; then 
            ls -p --color=always {}; 
        else 
            file -b {} 2>/dev/null || ls -lh --color=always {}; 
        fi"'

    # --- 界面统计与路径优化 ---
    COUNT=$(wc -l < "$SELECTED_LOG" | tr -d ' ')

    # 路径过长自动截断显示逻辑
    display_path="${CURRENT_DIR/#$HOME/~}"
    term_width=$(tput cols)
    max_path_len=$((term_width - 5)) 
    if [ ${#display_path} -gt $max_path_len ]; then
        display_path="...${display_path: -$max_path_len}"
    fi

    HEADER_LINE1="📂 $display_path"
    HEADER_LINE2="📝 已选: ${COUNT} | [Tab]选择 [Enter]导航 [Esc]刻录"

    # --- FZF 执行 ---
    OUTPUT=$(echo -e ".. (上级目录)\n$LIST" | fzf \
        --multi \
        --ansi \
        --expect=esc \
        --reverse \
        --no-info \
        --header="$(echo -e "\033[1;34m$HEADER_LINE1\033[0m\n$HEADER_LINE2")" \
        --prompt="> " \
        --preview "$PREVIEW_STR")

    # --- 退出与状态判断 ---
    [ $? -ne 0 ] && exit 0
    KEY_PRESSED=$(echo "$OUTPUT" | head -n1)
    SELECTED=$(echo "$OUTPUT" | tail -n +2)

    # 没选任何东西且按 Esc -> 退出
    if [ -z "$SELECTED" ] && [ "$KEY_PRESSED" == "esc" ] && [ ! -s "$SELECTED_LOG" ]; then
        exit 0
    fi

    # 标记是否需要跳出循环
    if [ "$KEY_PRESSED" == "esc" ]; then
        SHOULD_BREAK=true
    else
        SHOULD_BREAK=false
    fi

    # --- 处理选择项 ---
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        clean_name="${item%/}"
        
        if [[ "$item" == ".. (上级目录)" ]]; then
            # 如果是 Esc 触发的，不跳转目录
            if [ "$SHOULD_BREAK" = false ]; then
                CURRENT_DIR=$(dirname "$CURRENT_DIR")
            fi
        elif [ -d "$clean_name" ]; then
            # 进入目录
            if [ "$SHOULD_BREAK" = false ]; then
                CURRENT_DIR=$(realpath "$clean_name")
            fi
        else
            # 添加文件到清单
            if [ -f "$clean_name" ]; then
                abs_path=$(realpath "$clean_name")
                if ! grep -Fxq "$abs_path" "$SELECTED_LOG"; then
                    echo "$abs_path" >> "$SELECTED_LOG"
                fi
            fi
        fi
    done <<< "$SELECTED"

    if [ "$SHOULD_BREAK" = true ]; then
        break
    fi
done

# === 3. 刻录逻辑 ===
clear
[ ! -s "$SELECTED_LOG" ] && { echo "❌ 未选择文件"; exit 0; }

echo "📋 待刻录清单:"
cat "$SELECTED_LOG" | sed "s|$HOME|~|g"
echo "------------------------------------------------"
gum confirm "🚀 准备好刻录了吗？(写入 /dev/sr0)" || exit 0

XORRISO_ARGS=("-fs" "128m")
while IFS= read -r path; do
    [ -z "$path" ] && continue
    # 映射文件： -map "源路径" "/文件名"
    XORRISO_ARGS+=("-map" "$path" "/$(basename "$path")")
done < "$SELECTED_LOG"

echo "正在调用 xorriso 进行刻录..."

# 【修复后的核心刻录命令】
# -joliet on: 增加 Windows 兼容性
# -commit: 执行写入
# -eject all: 写入完成后弹出
xorriso -dev /dev/sr0 -joliet on -compliance no_emul_toc "${XORRISO_ARGS[@]}" -commit -eject all

if [ $? -eq 0 ]; then
    gum style --bold --foreground 82 "✅ 刻录成功！光盘已弹出。"
else
    gum style --bold --foreground 196 "❌ 刻录失败！请检查日志。"
fi
