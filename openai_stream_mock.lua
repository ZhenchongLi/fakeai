-- OpenAI API Stream Mock
-- 高性能模拟OpenAI API流式响应

local json = require "cjson"
local ngx = ngx

-- 设置响应头
ngx.header["Content-Type"] = "text/plain; charset=utf-8"
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Connection"] = "keep-alive"
ngx.header["Access-Control-Allow-Origin"] = "*"
ngx.header["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
ngx.header["Access-Control-Allow-Headers"] = "Content-Type, Authorization"

-- 处理OPTIONS预检请求
if ngx.var.request_method == "OPTIONS" then
    ngx.status = 200
    ngx.exit(200)
end

-- 只处理POST请求
if ngx.var.request_method ~= "POST" then
    ngx.status = 405
    ngx.say("Method Not Allowed")
    ngx.exit(405)
end

-- 模拟的响应内容
local response_text = "powered by openai"
local words = {}
for word in response_text:gmatch("%S+") do
    table.insert(words, word)
end

-- 生成唯一的请求ID
local function generate_id()
    return "chatcmpl-" .. ngx.time() .. math.random(100000, 999999)
end

local chat_id = generate_id()
local created_time = ngx.time()

-- 发送SSE格式的数据块
local function send_chunk(data)
    ngx.say("data: " .. json.encode(data))
    ngx.flush(true)
end

-- 开始流式响应
ngx.say("data: " .. json.encode({
    id = chat_id,
    object = "chat.completion.chunk",
    created = created_time,
    model = "gpt-3.5-turbo",
    choices = {{
        index = 0,
        delta = {
            role = "assistant"
        },
        finish_reason = json.null
    }}
}))
ngx.flush(true)

-- 逐词发送响应
for i, word in ipairs(words) do
    local content = word
    if i < #words then
        content = content .. " "
    end
    
    send_chunk({
        id = chat_id,
        object = "chat.completion.chunk",
        created = created_time,
        model = "gpt-3.5-turbo",
        choices = {{
            index = 0,
            delta = {
                content = content
            },
            finish_reason = json.null
        }}
    })
    
    -- 添加小延迟模拟真实的流式响应
    ngx.sleep(0.05)
end

-- 发送结束标记
send_chunk({
    id = chat_id,
    object = "chat.completion.chunk",
    created = created_time,
    model = "gpt-3.5-turbo",
    choices = {{
        index = 0,
        delta = {},
        finish_reason = "stop"
    }}
})

-- 发送流结束标记
ngx.say("data: [DONE]")
ngx.flush(true)