#
#!/bin/bash
# © 2022 GitHub, Inc.
#====================================================================
# Copyright (c) 2022 Ing
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/wjz304/openwrt-packages
# File name: upgrade.sh
# Description: OpenWrt packages update script
#====================================================================


function git_clone() {
  rm -rf $(basename $1 .git)
  git clone --depth 1 $1 $(basename $1 .git) || true
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
}

function git_clone_b() {
  rm -rf $(basename $1 .git)
  git clone --depth 1 -b $2 $1 $(basename $1 .git) || true
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
}

function svn_co() {
  rm -rf $(basename $1 .git)
  svn co $1 $(basename $1 .git) || true
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
}


# Argon 主题
git_clone_b https://github.com/jerrykuku/luci-theme-argon 18.06


# Argon 主题配置插件
git_clone https://github.com/jerrykuku/luci-app-argon-config
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile


# HelloWorld 依赖
git_clone https://github.com/fw876/helloworld

# Passwall
git_clone https://github.com/xiaorouji/openwrt-passwall


# HelloWorld  # 依赖 helloworld 和 openwrt-passwall
git_clone https://github.com/jerrykuku/lua-maxminddb
git_clone https://github.com/jerrykuku/luci-app-vssr


# OpenClash
git_clone https://github.com/vernesong/OpenClash
rm -rf luci-app-openclash && mv -f OpenClash/luci-app-openclash . && rm -rf OpenClash


# bypass
git_clone https://github.com/kiddin9/openwrt-bypass


# 应用商店
git_clone https://github.com/linkease/istore-ui
git_clone https://github.com/linkease/istore && mv -n istore/luci/* ./; rm -rf istore
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile


# 应用过滤
git_clone https://github.com/destan19/OpenAppFilter


# 实时监控
git_clone https://github.com/sirpdboy/luci-app-netdata


# 网速测试
git_clone https://github.com/sirpdboy/netspeedtest


# 高级设置
git_clone https://github.com/sirpdboy/luci-app-advanced


# 全能推送
git_clone https://github.com/zzsj0928/luci-app-pushbot


# 文件管理
git_clone https://github.com/xiaozhuai/luci-app-filebrowser


# 定时任务
git_clone https://github.com/DevOpenWRT-Router/luci-app-rebootschedule


# SmartDNS
git_clone https://github.com/pymumu/openwrt-smartdns 
git_clone https://github.com/pymumu/luci-app-smartdns lede
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-smartdns/Makefile


# ZeroTier
git_clone https://github.com/rufengsuixing/luci-app-zerotier

# Tailscale
git_clone https://github.com/MoZhonghua/openwrt-tailscale


# 网络向导
svn_co https://github.com/linkease/nas-packages/trunk/network/services/quickstart
svn_co https://github.com/linkease/nas-packages-luci/trunk/luci/luci-app-quickstart
sed -i 's/ +luci-app-store//g' luci-app-quickstart/Makefile


# gowebdav
svn_co https://github.com/openwrt/packages/trunk/lang/golang
svn_co https://github.com/immortalwrt/packages/trunk/net/gowebdav
sed -i 's/..\/..\/lang\/golang\/golang-package.mk/..\/golang\/golang-package.mk/g' gowebdav/Makefile
svn_co https://github.com/immortalwrt/luci/trunk/applications/luci-app-gowebdav
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-gowebdav/Makefile

# IP限速
svn_co https://github.com/immortalwrt/luci/trunk/applications/luci-app-eqos
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-eqos/Makefile






# end
rm -rf ./*/.svn*
rm -rf ./*/.git*

exit 0
