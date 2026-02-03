#!/usr/bin/env bash

# 百度网盘TUI 0.2
# 
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
    clear
    echo -e "${GREEN}=== 百度网盘 TUI ===${NC}"
    echo -e "路径: ${GREEN}$PCS_WORKING${NC}"
    echo -ne "正在获取列表... \r"

    # 获取原生输出
    RAW_OUTPUT=$($PCS_CMD ls "$PCS_WORKING")
    EXIT_CODE=$?
    echo -ne "\033[K"
    while true;do
        if [[ $EXIT_CODE -eq 0 ]]; then
        break
        fi
    
        echo -e "${RED}Error: BaiduPCS-Go 命令执行失败!${NC}"
        echo "$RAW_OUTPUT"
        read -s -p "按任意键重试，或Ctrl+C退出..." -n 1
    done

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
        echo -e "${RED}提示: 该文件夹为空，或者解析失败。${NC}"
        echo "--------------------------------"
        
        # 自动尝试获取父目录路径
        PARENT_PATH=$(dirname "$PCS_WORKING")
        
        # 提示用户
        if [[ "$PCS_WORKING" == "/" ]]; then
            read -p "当前已在根目录,按任意键刷新。" -n 1
        else
            read -p "按任意键返回上层目录..." -n 1
            # 逻辑：如果当前不是根目录，就退到父目录；如果是根目录，就保持现状
            if [[ "$PCS_WORKING" != "/" ]]; then
                PCS_WORKING="$PARENT_PATH"
            else
                PCS_WORKING="/"
            fi
        fi
        
        echo -e "\n正在跳转..."
        continue
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
