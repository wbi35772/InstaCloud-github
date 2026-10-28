FROM teddysun/xray:latest
USER root
RUN apk add --no-cache nginx zip
COPY nginx.conf /etc/nginx/nginx.conf
COPY config.json /etc/xray/config.json
COPY index.html /usr/share/nginx/html/index.html
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
