#!/bin/bash

# OpenResty OpenAI API Mock 启动脚本

echo "启动OpenResty OpenAI API模拟器..."

# 检查OpenResty是否安装
if ! command -v openresty &> /dev/null; then
    echo "错误: OpenResty未安装"
    echo "请先安装OpenResty: https://openresty.org/en/installation.html"
    exit 1
fi

# 创建日志目录
mkdir -p logs

# 启动OpenResty
echo "使用配置文件: nginx.conf"
echo "监听端口: 8080"
echo "API端点: http://localhost:8080/v1/chat/completions"

openresty -p $(pwd) -c nginx.conf

echo "OpenResty已启动!"
echo ""
echo "测试命令:"
echo "  python3 test_client.py"
echo ""
echo "或使用curl测试:"
echo '  curl -X POST http://localhost:8080/v1/chat/completions \'
echo '    -H "Content-Type: application/json" \'
echo '    -d '"'"'{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"test"}],"stream":true}'"'"
echo ""
echo "停止服务:"
echo "  openresty -p $(pwd) -s stop"