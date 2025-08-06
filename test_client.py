#!/usr/bin/env python3
"""
测试OpenAI API模拟器的客户端
"""

import requests
import json
import sys

def test_stream_api():
    url = "http://localhost:8080/v1/chat/completions"
    
    payload = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {"role": "user", "content": "Hello, how are you?"}
        ],
        "stream": True
    }
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer fake-token"
    }
    
    print("发送请求到模拟API...")
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    print("\n流式响应:")
    print("-" * 50)
    
    try:
        response = requests.post(url, json=payload, headers=headers, stream=True)
        response.raise_for_status()
        
        full_content = ""
        for line in response.iter_lines():
            if line:
                line_str = line.decode('utf-8')
                if line_str.startswith('data: '):
                    data_str = line_str[6:]  # 移除 'data: ' 前缀
                    if data_str == '[DONE]':
                        print("\n流结束")
                        break
                    
                    try:
                        data = json.loads(data_str)
                        if 'choices' in data and len(data['choices']) > 0:
                            delta = data['choices'][0].get('delta', {})
                            if 'content' in delta:
                                content = delta['content']
                                full_content += content
                                print(content, end='', flush=True)
                    except json.JSONDecodeError:
                        continue
        
        print(f"\n\n完整响应内容: '{full_content}'")
        
    except requests.exceptions.RequestException as e:
        print(f"请求失败: {e}")
        return False
    
    return True

if __name__ == "__main__":
    if test_stream_api():
        print("✅ 测试成功!")
    else:
        print("❌ 测试失败!")
        sys.exit(1)