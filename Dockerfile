FROM teddysun/xray:latest
USER root

# 安装必要组件
RUN apk add --no-cache nginx

# 生成 Xray 配置文件
RUN echo '{"inbounds":[{"port":8081,"listen":"127.0.0.1","protocol":"vless","settings":{"clients":[{"id":"66666666-6666-6666-6666-666666666666"}],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/proxy"}}}],"outbounds":[{"protocol":"freedom"}]}' > /etc/xray/config.json

# 生成 Nginx 配置文件
RUN echo 'worker_processes 1; daemon off; events { worker_connections 1024; } http { server { listen 8080; location / { root /usr/share/nginx/html; index index.html; } location /proxy { proxy_redirect off; proxy_pass http://127.0.0.1:8081; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $http_host; } } }' > /etc/nginx/nginx.conf

# 生成可视化的 Web 节点提取页面
RUN mkdir -p /usr/share/nginx/html && echo '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>InstaCloud 节点中心</title></head><body style="font-family:sans-serif;background:#f0f2f5;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;"><div style="background:white;padding:30px;border-radius:12px;box-shadow:0 4px 12px rgba(0,0,0,0.1);width:90%;max-width:500px;text-align:center;"><h2 style="margin-top:0;color:#333;">🎉 节点部署成功</h2><p style="color:#666;font-size:14px;">节点链接已根据当前外网域名自动生成</p><textarea id="node" readonly style="width:95%;height:100px;padding:10px;margin-top:15px;border:1px solid #ddd;border-radius:6px;resize:none;background:#fafafa;word-break:break-all;"></textarea><br><button onclick="copyBtn()" id="btn" style="margin-top:20px;background:#1677ff;color:white;border:none;padding:12px 24px;border-radius:6px;font-size:16px;cursor:pointer;transition:0.3s;">一键复制节点</button></div><script>const host = window.location.host;const uuid = "66666666-6666-6666-6666-666666666666";document.getElementById("node").value = `vless://${uuid}@${host}:443?encryption=none&security=tls&type=ws&host=${host}&path=%2Fproxy#InstaCloud-Auto`;function copyBtn() { document.getElementById("node").select(); document.execCommand("copy"); const btn = document.getElementById("btn"); btn.innerText = "复制成功！"; btn.style.background = "#52c41a"; setTimeout(() => { btn.innerText = "一键复制节点"; btn.style.background = "#1677ff"; }, 2000); }</script></body></html>' > /usr/share/nginx/html/index.html

# 生成无错启动脚本 (使用 printf 强制 Linux 换行)
RUN printf '#!/bin/sh\nsed -i "s/listen 8080;/listen ${PORT:-8080};/g" /etc/nginx/nginx.conf\nxray -config /etc/xray/config.json &\nnginx\n' > /start.sh && chmod +x /start.sh

# 执行启动
CMD ["/start.sh"]
