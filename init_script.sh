#!/bin/bash

echo "=============================="
echo "服务器初始化脚本"
echo "=============================="

# 检查是否以 root 身份运行
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 身份运行此脚本。"
   exit 1
fi

# 系统更新
echo "更新系统包..."
apt update && apt upgrade -y

# 安装常用工具
echo "安装常用工具..."
apt install -y curl wget vim

# 设置时区
#echo "设置时区为 Asia/Shanghai..."
#timedatectl set-timezone Asia/Shanghai

# 配置防火墙
#echo "配置防火墙..."
#ufw allow ssh
#ufw allow http
#ufw allow https
#ufw --force enable

# Nginx 安装与配置
read -p "是否需要安装和配置 Nginx？[y/n]: " install_nginx
if [[ "$install_nginx" == "y" ]]; then
    # 安装 Nginx
    echo "安装 Nginx..."
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "Nginx 安装完成！"

    # 配置虚拟主机
    read -p "是否需要配置虚拟主机？[y/n]: " configure_vhost
    if [[ "$configure_vhost" == "y" ]]; then
        read -p "请输入域名（例如 example.com）: " domain
        read -p "请输入站点根目录路径（默认 /var/www/$domain）: " root_dir
        root_dir=${root_dir:-/var/www/$domain}

        # 创建站点目录
        mkdir -p $root_dir
        chown -R www-data:www-data $root_dir
        chmod -R 755 $root_dir

        # 创建 Nginx 配置文件
        echo "创建 Nginx 配置文件..."
        cat > /etc/nginx/sites-available/$domain <<EOL
server {
    listen 80;
    server_name $domain www.$domain;

    root $root_dir;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

        # 启用配置并测试 Nginx 配置
        ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        echo "虚拟主机 $domain 配置完成，站点根目录为 $root_dir"
    fi

    # 配置 HTTPS
    read -p "是否需要配置 HTTPS（自动获取证书并配置）？[y/n]: " configure_https
    if [[ "$configure_https" == "y" ]]; then
        # 检查是否安装 Certbot
        if ! command -v certbot &> /dev/null; then
            echo "安装 Certbot..."
            apt install -y certbot python3-certbot-nginx
        fi

        # 配置 HTTPS 证书
        echo "为域名 $domain 获取并配置 HTTPS 证书..."
        certbot --nginx -d $domain -d www.$domain
        echo "HTTPS 配置完成！"
    fi
else
    echo "已跳过 Nginx 安装和配置。"
fi

# 清理系统
echo "清理系统..."
apt autoremove -y
apt autoclean

echo "=============================="
echo "初始化配置完成！"
echo "=============================="
