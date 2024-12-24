#!/bin/bash

echo "=============================="
echo "服务器初始化脚本"
echo "=============================="
# Function declarations
declare -f install_nginx
declare -f configure_ssl

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

# 是否安装Nginx
echo "是否需要安装Nginx？(y/n)"
read nginx_choice

if [ "$nginx_choice" = "y" ]; then
    install_nginx
    configure_ssl
else
    echo "跳过Nginx安装"
fi

# 清理系统
echo "清理系统..."
apt autoremove -y
apt autoclean

echo "=============================="
echo "初始化配置完成！"
echo "=============================="


############################################
# 脚本函数
############################################
# Nginx安装函数
install_nginx() {
    echo "开始安装Nginx..."
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Nginx安装完成！"
}

# SSL证书配置函数
configure_ssl() {
    echo "是否需要配置SSL证书？(y/n)"
    read ssl_choice
    
    if [ "$ssl_choice" = "y" ]; then
        echo "请输入域名："
        read domain_name
        
        # 安装certbot
        apt install -y certbot python3-certbot-nginx
        
        # 申请证书
        certbot --nginx -d $domain_name
        
        echo "SSL证书配置完成！"
    else
        echo "跳过SSL证书配置"
    fi
}