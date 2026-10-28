#!/bin/sh
sed -i "s/listen 8080;/listen ${PORT:-8080};/g" /etc/nginx/nginx.conf
xray -config /etc/xray/config.json &
nginx
