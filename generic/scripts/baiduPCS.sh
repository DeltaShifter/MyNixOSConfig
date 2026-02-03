#!/usr/bin/env bash

# === 配置 ===
PCS_CMD="BaiduPCS-Go"
DOWNLOAD_DIR="$HOME/Downloads"
# ===========

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

mkdir -p "$DOWNLOAD_DIR"
PCS_WORKING="${1:-/}"

# 依赖检查
for cmd in fzf awk sed grep; do
    if ! command -v $cmd &> /dev/null; then
        echo "错误: 缺少 $cmd，请先安装。"
        read -p "按键退出..."
        exit 1
    fi
done

while true; do
    # 清屏
    echo -e "${GREEN}=== 百度网盘 TUI ===${NC}"
    echo -e "路径: ${GREEN}$PSC_PWD${NC}"
    echo "获取列表中..."

    # 获取原生输出
    RAW_OUTPUT=$($PCS_CMD ls "$PCS_WORKING")
    EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo -e "${RED}Error: BaiduPCS-Go 命令执行失败!${NC}"
        echo "$RAW_OUTPUT"
        read -p "按任意键退出..." -n 1
        exit 1
    fi

    # === 数据清洗 ===
    # 1. sed: 去除 ANSI 颜色代码
    # 2. grep: 匹配 "行首(^) + 任意个空格([[:space:]]*) + 数字([0-9]+)" 的行
    # 3. awk: 提取第2列(大小)和第5列以后(文件名)
    CLEAN_LIST=$(echo "$RAW_OUTPUT" | \
        sed 's/\x1b\[[0-9;]*m//g' | \
        grep -E '^[[:space:]]*[0-9]+' | \
        awk '{
            # $1=序号, $2=大小, $3=日期, $4=时间, $5...=文件名
            
            # 拼接文件名 (从第5列直到最后)
            name=""; 
            for(i=5;i<=NF;i++) name=name $i " ";
            
            # 去掉末尾多余的空格
            sub(/ +$/, "", name);
            
            # 输出: 大小 [Tab] 文件名
            printf "%-10s\t%s\n", $2, name
        }')

    # 空列表检查
    if [[ -z "$CLEAN_LIST" ]]; then
        echo -e "${RED}列表为空 (解析后)${NC}"
        echo "--------------------------------"
        echo "原始输出前10行:"
        echo "$RAW_OUTPUT" | head -n 10
        echo "--------------------------------"
        
        read -p "按 'r' 返回根目录，按 'q' 退出: " -n 1 CHOICE
        echo
        if [[ "$CHOICE" == "r" ]]; then
            PCS_WORKING="/"
            continue
        elif [[ "$CHOICE" == "q" ]]; then
            exit 0
        else
            continue
        fi
    fi

    # 组合菜单
    MENU=".. (上级目录)"$'\n'"$CLEAN_LIST"

    # 调用 fzf
    SELECTED=$(echo "$MENU" | fzf \
        --ansi \
        --header "当前: $PCS_WORKING | 下载至: ~/Downloads" \
        --prompt="PCS> " \
        --height=95% \
        --layout=reverse \
        --border \
        --delimiter='\t' \
        --with-nth=2 \
        --preview='echo "Size: {1}"')

    if [ -z "$SELECTED" ]; then
        exit 0
    fi

    # 处理返回
    if [[ "$SELECTED" == ".. (上级目录)" ]]; then
        if [[ "$PCS_WORKING" != "/" ]]; then
            PCS_WORKING=$(dirname "$PCS_WORKING")
        fi
        continue
    fi

    # 提取文件名
    FILE_NAME=$(echo "$SELECTED" | awk -F'\t' '{print $2}')
    
    CLEAN_NAME=$(echo "$FILE_NAME" | sed 's/\/$//')
    
    if [[ "$PCS_WORKING" == "/" ]]; then
        NEXT_PATH="/$CLEAN_NAME"
    else
        NEXT_PATH="$PCS_WORKING/$CLEAN_NAME"
    fi

    if [[ "$FILE_NAME" == */ ]]; then
        # === 是目录 (名字以 / 结尾) ===
        PCS_WORKING="$NEXT_PATH"
    else
        # === 是文件 (尝试下载) ===
        echo -e "\n准备下载: ${GREEN}$FILE_NAME${NC}"
        read -p "确认? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $PCS_CMD d "$NEXT_PATH" --saveto "$DOWNLOAD_DIR"
            read -p "下载结束，按键继续..." -n 1
        fi
    fi
done
