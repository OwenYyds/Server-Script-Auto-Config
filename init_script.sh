#!/bin/bash

# 添加错误处理
set -e  # 遇到错误时退出脚本
set -u  # 使用未声明变量时报错

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
apt-get install -y curl wget neovim

###############################################
# 安装 Docker
# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
###############################################

###############################################
# 安装 Nginx
echo "安装 Nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Nginx 安装完成！"
###############################################

###############################################
# 安装 小雅Alist
#echo "安装 小雅Alist..."
#bash -c "$(curl http://docker.xiaoya.pro/update_new.sh)" -s host
###############################################

###############################################
# 安装 3XUI
echo "安装 3XUI..."
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
###############################################



# 清理系统
echo "清理系统..."
apt-get autoremove -y
apt-get autoclean

echo "=============================="
echo "初始化配置完成！"
echo "=============================="