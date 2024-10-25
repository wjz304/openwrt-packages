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

BRANCH=${1:-openwrt}

function _lang() {
  if [ "${BRANCH}" == "openwrt" ]; then
    for I in $(find $1 -name "zh-cn"); do
      [ ! -d "${I}" ] && continue
      [ -d "${I/zh-cn/zh_Hans}" ] && continue
      cp -rf "${I}" "${I/zh-cn/zh_Hans}"
    done
    for I in $(find $1 -name "zh-tw"); do
      [ ! -d "${I}" ] && continue
      [ -d "${I/zh-tw/zh_Hant}" ] && continue
      cp -rf "${I}" "${I/zh-tw/zh_Hant}"
    done
  else
    for I in $(find $1 -name "zh_Hans"); do
      [ ! -d "${I}" ] && continue
      [ -d "${I/zh_Hans/zh-cn}" ] && continue
      cp -rf "${I}" "${I/zh_Hans/zh-cn}"
    done
    for I in $(find $1 -name "zh_Hant"); do
      [ ! -d "${I}" ] && continue
      [ -d "${I/zh_Hant/zh-tw}" ] && continue
      cp -rf "${I}" "${I/zh_Hant/zh-tw}"
    done
  fi
}

function git_clone() {
  rm -rf $(basename $1 .git)
  branch=""
  [ ! -z "$2" ] && branch="-b $2"
  git clone --depth 1 ${branch} $1 $(basename $1 .git) || true
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
  _lang $(basename $1 .git)
}

function git_co() {
  rm -rf ${1//*\/}
  rm -rf /tmp/git_co
  branch=""
  [ ! -z "$3" ] && branch="-b $3"
  git clone --depth 1 ${branch} $2 /tmp/git_co || true
  mkdir -p ${1//*\/}
  cp -rf /tmp/git_co/$1/* ${1//*\/}
  rm -rf /tmp/git_co
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf ${1//*\/}/.svn* ${1//*\/}/.git*
  _lang ${1//*\/}
}

function svn_co() {
  rm -rf $(basename $1 .git)
  svn co $1 $(basename $1 .git) || true
  # sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' $(basename $1 .git)/Makefile
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
  _lang $(basename $1 .git)
}

# default-settings
[ "${BRANCH}" == "openwrt" ] && git_co package/lean/default-settings https://github.com/coolsnowwolf/lede

# Pink 主题
git_clone https://github.com/virualv/luci-theme-pink

# Argon 主题
git_clone https://github.com/jerrykuku/luci-theme-argon

# Argon 主题配置插件
git_clone https://github.com/jerrykuku/luci-app-argon-config
#sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile

# 在线用户
git_clone https://github.com/selfcan/luci-app-onliner
chmod 755 luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 关机
git_clone https://github.com/esirplayground/luci-app-poweroff

# 自动格式化分区、扩容、自动挂载
git_clone https://github.com/sirpdboy/luci-app-partexp

# bypass
#git_clone https://github.com/kiddin9/openwrt-bypass
git_co luci-app-bypass https://github.com/kiddin9/openwrt-packages
#sed -i 's/luci-lib-ipkg/luci-base/g' openwrt-bypass/luci-app-bypass/Makefile

# openwrt-passwall 依赖
git_clone https://github.com/xiaorouji/openwrt-passwall-packages

# Passwall  # 依赖 openwrt-passwall
git_co luci-app-passwall https://github.com/xiaorouji/openwrt-passwall

# Passwall2  # 依赖 openwrt-passwall
git_co luci-app-passwall2 https://github.com/xiaorouji/openwrt-passwall2

# HelloWorld 依赖
git_clone https://github.com/fw876/helloworld

# HelloWorld  # 依赖 helloworld 和 openwrt-passwall
git_clone https://github.com/jerrykuku/lua-maxminddb
git_clone https://github.com/jerrykuku/luci-app-vssr

# OpenClash
git_co luci-app-openclash https://github.com/vernesong/OpenClash

# Clash
git_clone https://github.com/frainzy1477/luci-app-clash

# iKoolProxy 滤广告
git_clone https://github.com/yaof2/luci-app-ikoolproxy

# AdGuard Home
git_clone https://github.com/rufengsuixing/luci-app-adguardhome

# SmartDNS # 与 bypass 冲突
#git_clone https://github.com/pymumu/openwrt-smartdns
#git_clone https://github.com/pymumu/luci-app-smartdns lede
#sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-smartdns/Makefile

# 应用商店
git_clone https://github.com/linkease/istore-ui
git_clone https://github.com/linkease/istore
rm -rf $(ls istore/luci/) && cp -rf istore/luci/* . && rm -rf istore
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile

# 网络向导
git_co network/services/quickstart https://github.com/linkease/nas-packages
git_co luci/luci-app-quickstart https://github.com/linkease/nas-packages-luci
sed -i 's/ +luci-app-store//g' luci-app-quickstart/Makefile

# lucky
# git_clone https://github.com/sirpdboy/luci-app-lucky
# 和DDNS-GO只能选择其中的一个就可以了，已经涵盖ddns-go了
#
# 拉取gdy666/lucky主线
git_clone https://github.com/gdy666/luci-app-lucky
sed -i 's/#LUCI_DEPENDS:=+lucky/LUCI_DEPENDS:=+lucky/g' luci-app-lucky/luci-app-lucky/Makefile

# DDNS-GO
git_clone https://github.com/sirpdboy/luci-app-ddns-go

# 实时监控
git_clone https://github.com/sirpdboy/luci-app-netdata

# 高级设置
git_clone https://github.com/sirpdboy/luci-app-advanced

# 定时任务
git_clone https://github.com/DevOpenWRT-Router/luci-app-rebootschedule
sed -i '/firstchild/d' luci-app-rebootschedule/luasrc/controller/rebootschedule.lua
sed -i 's/"control"/"system"/g; s/"Timing setting"/"定时任务"/g' luci-app-rebootschedule/luasrc/controller/rebootschedule.lua
chmod 755 luci-app-rebootschedule/root/etc/init.d/rebootschedule

# 应用过滤
git_clone https://github.com/destan19/OpenAppFilter

# 网速测试
git_clone https://github.com/sirpdboy/netspeedtest
# sed -i 's/DEPENDS:=\$(GO_ARCH_DEPENDS)$/DEPENDS:=\$(GO_ARCH_DEPENDS) +upx/g' netspeedtest/speedtest-web/Makefile

# 流量统计
git_co wrtbwmon https://github.com/brvphoenix/wrtbwmon
git_co luci-app-wrtbwmon https://github.com/brvphoenix/luci-app-wrtbwmon

# 全能推送
git_clone https://github.com/zzsj0928/luci-app-pushbot

# ZeroTier
git_clone https://github.com/rufengsuixing/luci-app-zerotier
sed -i 's/"vpn"/"services"/g; s/"VPN"/"Services"/g' luci-app-zerotier/luasrc/controller/zerotier.lua

# Tailscale
git_clone https://github.com/MoZhonghua/openwrt-tailscale

# IPv6 端口转发
git_clone https://github.com/big-tooth/luci-app-socatg
#sed -i 's/socat\r/socatg\r/g' luci-app-socatg/Makefile && sed -i 's/socat$/socatg/g' luci-app-socatg/Makefile

# beardropper
git_clone https://github.com/NateLol/luci-app-beardropper

# IP限速
git_co applications/luci-app-eqos https://github.com/immortalwrt/luci
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-eqos/Makefile
chmod 755 luci-app-eqos/root/etc/init.d/eqos

# 文件浏览器
git_clone https://github.com/xiaozhuai/luci-app-filebrowser
sed -i 's/"services"/"nas"/g; s/"Services"/"NAS"/g' luci-app-filebrowser/luasrc/controller/filebrowser.lua

# gowebdav
git_co net/gowebdav https://github.com/immortalwrt/packages
sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' gowebdav/Makefile
git_co applications/luci-app-gowebdav https://github.com/immortalwrt/luci
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-gowebdav/Makefile
#sed -i '/"NAS"/d; /page/d' luci-app-gowebdav/luasrc/controller/gowebdav.lua
#sed -i 's/\"nas\"/\"services\"/g' luci-app-gowebdav/luasrc/controller/gowebdav.lua

# vm-tools
# git_clone https://github.com/fangli/openwrt-vm-tools

# clean
rm -rf ./*/.svn*
rm -rf ./*/.git*

#end
exit 0
