#!/usr/bin/env sh

# 跨平台路径处理（同时支持Linux路径和Windows的Git Bash路径）
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    PROJECT_DIR="/c/Users/zuyj/draws"  # Windows Git Bash路径示例
else
    PROJECT_DIR="$HOME/draws"  # Linux/macOS路径
fi

# 统一的分支管理（默认使用main分支）
DEFAULT_BRANCH="main"

# 兼容性处理函数
windows_path_convert() {
    if [ "$OSTYPE" = "msys" ]; then
        echo "$1" | sed -e 's|^/||' -e 's|^\([a-zA-Z]\)/|\U\1:\\|' -e 's|/|\\|g'
    else
        echo "$1"
    fi
}

# 进入项目目录
cd "$(windows_path_convert "$PROJECT_DIR")" || exit 1

# 执行同步操作
echo "正在同步代码库..."
git add . > /dev/null 2>&1

# 处理行尾差异（Windows需要特别处理）
if [ "$OSTYPE" = "msys" ]; then
    git commit -m "从Windows同步draws: $(date +"%Y-%m-%d %H:%M:%S")" > /dev/null 2>&1
    git config --local core.autocrlf false > /dev/null 2>&1
else
    git commit -m "从Ubuntu同步draws: $(date +"%Y-%m-%d %H:%M:%S")" > /dev/null 2>&1
fi

# 网络重试机制（适用于不稳定的网络环境）
retry_count=0
max_retries=3

while [ $retry_count -lt $max_retries ]; do
    git pull origin $DEFAULT_BRANCH && git push origin $DEFAULT_BRANCH
    if [ $? -eq 0 ]; then
        echo "github同步成功!"
        break
    fi
    retry_count=$((retry_count+1))
    echo "github同步失败，5秒后重试（第$retry_count次）..."
    sleep 5
done

if [ $retry_count -ge $max_retries ]; then
    echo "github同步失败，请检查网络连接后重试"
    exit 1
fi


#exit 1
