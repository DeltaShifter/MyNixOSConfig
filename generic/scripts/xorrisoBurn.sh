#!/usr/bin/env bash

# === 1. 初始化与依赖检查 ===
DEPENDENCIES=("xorriso" "gum" "fzf" "eject")
for dep in "${DEPENDENCIES[@]}"; do
    command -v "$dep" &> /dev/null || { echo "❌ 缺失: $dep"; exit 1; }
done

cd "$HOME" || exit
CURRENT_DIR="$HOME"
SELECTED_LOG=$(mktemp)
trap 'rm -f "$SELECTED_LOG"' EXIT

# === 2. 核心导航函数 ===
while true; do
    cd "$CURRENT_DIR" || exit
    LIST=$(ls -F --group-directories-first)
    
    # 【关键修复】：将预览命令包裹在 sh -c 中，确保不触发 fish 报错
    # 逻辑：如果是上级目录提示词，ls ..；否则 test 是否为目录；否则 file
    PREVIEW_STR='sh -c "echo {} | grep -q \"上级目录\" && ls -CF .. || (test -d {} && ls -CF {} || echo \"文件预览不可用\")"'

    SELECTED=$(echo -e ".. (上级目录)\n$LIST" | fzf \
        --multi --ansi \
        --header "当前: $CURRENT_DIR | 已选: $(wc -l < "$SELECTED_LOG") 个" \
        --prompt="Burner> " \
        --footer "Tab: 勾选 | Enter: 确认/进入 | Esc: 开始刻录" \
        --preview "$PREVIEW_STR")

    # 处理 Esc 或未选择
    if [ $? -ne 0 ] || [ -z "$SELECTED" ]; then
        if [ -s "$SELECTED_LOG" ]; then break; else exit 0; fi
    fi

    # 处理跳转逻辑
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        if [[ "$item" == ".. (上级目录)" ]]; then
            CURRENT_DIR=$(realpath ".." 2>/dev/null)
        elif [[ "$item" == */ ]]; then
            # 目录跳转，去掉末尾的 /
            CURRENT_DIR=$(realpath "${item%/}" 2>/dev/null)
        else
            # 记录文件绝对路径
            abs_path=$(realpath "$item" 2>/dev/null)
            if [ -f "$abs_path" ]; then
                grep -Fxq "$abs_path" "$SELECTED_LOG" || echo "$abs_path" >> "$SELECTED_LOG"
            fi
        fi
    done <<< "$SELECTED"
done

# === 3. 刻录逻辑 ===
clear
[ ! -s "$SELECTED_LOG" ] && { echo "未选择文件"; exit 0; }

echo "📋 待刻录清单:"
cat "$SELECTED_LOG"
echo "------------------------------------------------"
gum confirm "🚀 开始物理刻录？" || exit 0

XORRISO_ARGS=("-fs" "128m")
while IFS= read -r path; do
    [ -z "$path" ] && continue
    XORRISO_ARGS+=("-map" "$path" "/$(basename "$path")")
done < "$SELECTED_LOG"

xorriso -osirrox on -dev /dev/sr0 -compliance no_emul_toc "${XORRISO_ARGS[@]}" -commit -next -rollback_end

[ $? -eq 0 ] && gum style --bold --foreground 82 "✅ 刻录成功！" || gum style --bold --foreground 196 "❌ 刻录失败！"
