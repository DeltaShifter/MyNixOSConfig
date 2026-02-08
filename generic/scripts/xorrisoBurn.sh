#!/usr/bin/env bash

# === 1. 初始化与依赖检查 ===
DEPENDENCIES=("xorriso" "gum" "fzf" "eject" "file" "grep")
for dep in "${DEPENDENCIES[@]}"; do
    command -v "$dep" &> /dev/null || { echo "❌ 缺失核心命令: $dep"; exit 1; }
done

SELECTED_LOG=$(mktemp)
trap 'rm -f "$SELECTED_LOG"' EXIT

# 设置初始工作目录
START_DIR=$HOME
CURRENT_DIR="$START_DIR"

# ================================
# 全局大循环：允许报错后返回
# ================================
while true; do
    # 每次重新开始时，确保目录正确，并清空上次的已选清单
    cd "$CURRENT_DIR" || exit
    > "$SELECTED_LOG" 

    # === 2. 核心导航函数 ===
    while true; do
        cd "$CURRENT_DIR" || exit
        LIST=$(ls -p --group-directories-first --color=never)
        
        PREVIEW_STR='sh -c "
        if echo {} | grep -q \"上级目录\"; then 
            ls -p --color=always ..; 
        elif [ -d {} ]; then 
            ls -p --color=always {}; 
        else 
            echo -e \"\033[1;33m【文件信息】\033[0m\";
            echo -n \"📏 大小: \"; du -sh {} | cut -f1;
            echo -n \"类型: \"; file -b {} | fold -s -w 40;
            echo \"--------------------------------\";
            # 如果是文本文件，顺便预览前几行
            if file {} | grep -q \"text\"; then
                echo -e \"\n\033[1;34m【内容预览】\033[0m\";
                head -n 10 {};
            fi
        fi" 2>/dev/null'

        COUNT=$(wc -l < "$SELECTED_LOG" | tr -d ' ')
        display_path="${CURRENT_DIR/#$HOME/~}"
        term_width=$(tput cols)
        max_path_len=$((term_width - 5)) 
        if [ ${#display_path} -gt $max_path_len ]; then
            display_path="...${display_path: -$max_path_len}"
        fi

        HEADER_LINE1="📂 $display_path"
        HEADER_LINE2="📝 已选: ${COUNT} | [Tab]选择 [Enter]导航 [Esc]进入刻录"

        OUTPUT=$(echo -e ".. (上级目录)\n$LIST" | fzf \
            --multi \
            --ansi \
            --expect=esc \
            --reverse \
            --no-info \
            --header="$(echo -e "\033[1;34m$HEADER_LINE1\033[0m\n$HEADER_LINE2")" \
            --prompt="> " \
            --preview "$PREVIEW_STR")

        [ $? -ne 0 ] && exit 0 # 真正的 Ctrl+C 退出
        KEY_PRESSED=$(echo "$OUTPUT" | head -n1)
        SELECTED=$(echo "$OUTPUT" | tail -n +2)

        # 没选东西按 Esc -> 彻底退出程序
        if [ -z "$SELECTED" ] && [ "$KEY_PRESSED" == "esc" ] && [ ! -s "$SELECTED_LOG" ]; then
            exit 0
        fi

        SHOULD_BREAK=false
        if [ "$KEY_PRESSED" == "esc" ]; then
            SHOULD_BREAK=true
        fi

        while IFS= read -r item; do
            [ -z "$item" ] && continue
            clean_name="${item%/}"
            
            if [[ "$item" == ".. (上级目录)" ]]; then
                if [ "$SHOULD_BREAK" = false ]; then
                    CURRENT_DIR=$(dirname "$CURRENT_DIR")
                fi
            elif [ -d "$clean_name" ]; then
                if [ "$SHOULD_BREAK" = false ]; then
                    CURRENT_DIR=$(realpath "$clean_name")
                fi
            else
                if [ -f "$clean_name" ]; then
                    abs_path=$(realpath "$clean_name")
                    if ! grep -Fxq "$abs_path" "$SELECTED_LOG"; then
                        echo "$abs_path" >> "$SELECTED_LOG"
                    fi
                fi
            fi
        done <<< "$SELECTED"

        if [ "$SHOULD_BREAK" = true ] && [ -s "$SELECTED_LOG" ]; then
            break # 跳出导航，进入刻录逻辑
        fi
    done

    # === 3. 刻录逻辑 ===
    clear
    echo "📋 待刻录清单:"
    cat "$SELECTED_LOG" | sed "s|$HOME|~|g"
    echo "------------------------------------------------"
    
    if ! gum confirm "🚀 准备好刻录了吗？(写入 /dev/sr0)"; then
        echo "💡 已取消，返回重新选择..."
        sleep 1
        continue # 【关键】跳回最外层循环开头
    fi

    XORRISO_ARGS=("-fs" "128m")
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        XORRISO_ARGS+=("-map" "$path" "/$(basename "$path")")
    done < "$SELECTED_LOG"

    VOLID="DATA_$(date +%Y%m%d_%H%M)"
    echo "正在调用 xorriso 进行刻录..."

    # 执行刻录
    xorriso -x -dev /dev/sr0 \
        -joliet on \
        -compliance no_emul_toc \
        -rockridge on \
        -volid "$VOLID" \
        "${XORRISO_ARGS[@]}" \
        -commit -eject all

    if [ $? -eq 0 ]; then
        gum style --bold --foreground 82 "✅ 刻录成功！光盘已弹出。"
        read -p "按回车键返回主菜单..."
    else
        gum style --bold --foreground 196 "❌ 刻录失败！"
        echo "可能原因：未插入光盘、空间不足或驱动器繁忙。"
        read -p "按回车键尝试重新选择文件..."
    fi

    # 刻录结束或报错后，循环会自动回到开头
    # continue 也可以不写，因为已经到循环末尾了
done
