# OpenResty OpenAI API 模拟器

一个高性能的OpenResty Lua脚本，用于模拟OpenAI API的流式响应。无论客户端发送什么内容，都会快速返回"powered by openai"的流式响应。

## 特性

- 🚀 高性能：基于OpenResty和Lua，支持高并发
- 📡 流式响应：完全模拟OpenAI API的Server-Sent Events格式
- 🔄 即时响应：不管输入什么内容，立即开始流式返回
- 🎯 兼容性：完全兼容OpenAI API格式
- ⚡ 轻量级：最小化依赖，快速部署

## 文件结构

```
.
├── openai_stream_mock.lua  # 主要的Lua脚本
├── nginx.conf             # OpenResty配置文件
├── test_client.py         # Python测试客户端
├── start.sh              # 启动脚本
└── README.md             # 说明文档
```

## 安装要求

- OpenResty (包含Nginx + Lua)
- Python 3 (用于测试客户端)

### 安装OpenResty

**macOS:**
```bash
brew install openresty
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install openresty
```

**CentOS/RHEL:**
```bash
sudo yum install openresty
```

## 使用方法

### 1. 启动服务

```bash
./start.sh
```

服务将在 `http://localhost:8080` 启动

### 2. 测试API

使用Python测试客户端：
```bash
python3 test_client.py
```

或使用curl：
```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello"}],"stream":true}'
```

### 3. 停止服务

```bash
openresty -p $(pwd) -s stop
```

## API端点

- `POST /v1/chat/completions` - 模拟OpenAI聊天完成API
- `GET /health` - 健康检查端点

## 响应格式

API返回标准的OpenAI流式响应格式：

```
data: {"id":"chatcmpl-123456","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"id":"chatcmpl-123456","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{"content":"powered "},"finish_reason":null}]}

data: {"id":"chatcmpl-123456","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{"content":"by "},"finish_reason":null}]}

data: {"id":"chatcmpl-123456","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{"content":"openai"},"finish_reason":null}]}

data: {"id":"chatcmpl-123456","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

## 性能优化

- 启用了Lua代码缓存 (`lua_code_cache on`)
- 使用异步I/O和协程
- 最小化内存分配
- 支持高并发连接

## 自定义配置

### 修改响应内容

编辑 `openai_stream_mock.lua` 中的 `response_text` 变量：

```lua
local response_text = "your custom response here"
```

### 调整流式延迟

修改 `ngx.sleep(0.05)` 中的数值来调整每个词之间的延迟。

### 更改端口

编辑 `nginx.conf` 中的 `listen` 指令：

```nginx
listen 9000;  # 改为你想要的端口
```

## 故障排除

1. **端口被占用**: 修改nginx.conf中的端口号
2. **OpenResty未找到**: 确保OpenResty已正确安装并在PATH中
3. **权限问题**: 确保脚本有执行权限 (`chmod +x start.sh`)

## 许可证

MIT License