#!/usr/bin/env bash

# 依赖检查
DEPENDENCIES=("xorriso" "gum" "eject")
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "❌ 缺失依赖: $dep (你装好这些包了吗？)"
        exit 1
    done
done

# 内容选择并传入SELECTED PATHS
echo "📂 [空格] 勾选内容，[回车] 启动刻录任务"
SELECTED_PATHS=$(gum file --no-limit --header "选择要存入光盘的文件/目录" --height 15)

if [ -z "$SELECTED_PATHS" ]; then
    gum style --foreground 214 "⚠️ 未选择任何内容，操作取消。"
    exit 0
fi

# 开始构造目录序列
XORRISO_ARGS=()
# 设置缓存以防断流（有必要吗）
XORRISO_ARGS+=("-fs" "128m") 

while IFS= read -r path; do
    # 将选中的内容映射到光盘根目录，保持原始文件名
    # IFS把空格当成分隔符，避免带空格文件名传入出问题
    # 用数组的方式传入变量比较容易不出错
    XORRISO_ARGS+=("-map" "$path" "/$(basename "$path")")
done <<< "$SELECTED_PATHS"

DRIVE="/dev/sr0"

gum confirm "准备写入选中的内容至 $DRIVE ，确定吗？" || exit 0

echo "🚀 开始刻录..."

# gum spin --spinner dots --title "正在执行一次性物理刻录..." -- \
# 
# xorriso -osirrox on \ 启用增强模式，识别多区段光盘
#    -dev "$DRIVE" \ 加载光驱
#    -compliance no_emul_toc \  
#    "${XORRISO_ARGS[@]}" \ 传入构建的序列
#    -commit \ 写入
#    -next \ 保持光盘多区段开启
#    -rollback_end 失败时记得回滚
xorriso -osirrox on \
    -dev "$DRIVE" \
    -compliance no_emul_toc \  
    "${XORRISO_ARGS[@]}" \
    -commit \
    -next \
    -rollback_end

if [ $? -eq 0 ]; then
    gum style --bold --foreground 82 "👏 刻录成功！所有文件已整合。"
    gum confirm "是否弹出光盘？" && eject "$DRIVE"
else
    gum style --bold --foreground 196 "❌ 刻录失败！请检查权限或者剩余空间？。"
fi
