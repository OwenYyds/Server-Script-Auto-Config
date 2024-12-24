#!/bin/bash

# 添加错误处理
set -e  # 遇到错误时退出脚本
set -u  # 使用未声明变量时报错

############################################
# 函数定义
# 定义nginx安装函数
install_nginx() {
    echo "开始安装nginx..."
    apt-get install -y nginx certbot python3-certbot-nginx

    # 询问域名
    read -p "请输入您的域名 (例如: example.com): " domain_name
    
    # 询问后端服务
    read -p "请输入需要代理的端口 (例如: 3000): " port
    
    # 创建nginx配置文件
    cat > "/etc/nginx/sites-available/${domain_name}" <<EOF
server {
    listen 80;
    server_name ${domain_name};

    location / {
        proxy_pass http://localhost:${port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # 启用站点配置
    ln -sf "/etc/nginx/sites-available/${domain_name}" "/etc/nginx/sites-enabled/"
    
    # 验证nginx配置
    if nginx -t; then
        echo "Nginx配置测试成功"
    else
        echo "Nginx配置测试失败"
        exit 1
    fi

    # 重启nginx
    systemctl restart nginx

    # 询问是否配置SSL证书
    read -p "是否需要配置SSL证书？(y/n): " ssl_choice
    if [[ $ssl_choice == "y" || $ssl_choice == "Y" ]]; then
        # 申请Let's Encrypt证书
        certbot --nginx -d ${domain_name} --non-interactive --agree-tos --email admin@${domain_name}
        echo "SSL证书配置完成"
    fi

    echo "Nginx配置完成！"
    echo "域名: ${domain_name}"
    echo "代理端口: ${port}"
}
############################################

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
apt-get update && apt-get upgrade -y

# 安装常用工具（建议增加更多实用工具）
echo "安装常用工具..."
apt-get install -y curl wget vim

# 询问是否安装nginx
read -p "是否需要安装nginx?(y/n): " install_nginx_choice
if [[ $install_nginx_choice == "y" || $install_nginx_choice == "Y" ]]; then
    install_nginx
    echo "Nginx安装完成并已启动"
    echo "可以通过访问 http://服务器IP 来验证nginx是否正常运行"
fi

# 清理系统
echo "清理系统..."
apt-get autoremove -y
apt-get autoclean

echo "=============================="
echo "初始化配置完成！"
echo "=============================="