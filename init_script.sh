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

# 清理系统
echo "清理系统..."
apt-get autoremove -y
apt-get autoclean

echo "=============================="
echo "初始化配置完成！"
echo "=============================="