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
  branch=""
  [ ! -z "$2" ] && branch="-b $2"
  git clone --depth 1 ${branch} $1 $(basename $1 .git) || true
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
git_clone https://github.com/jerrykuku/luci-theme-argon 18.06


# Argon 主题配置插件
git_clone https://github.com/jerrykuku/luci-app-argon-config
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile
#sed -i 's/\"Argon 主题设置\"/\"主题设置\"/g' luci-app-argon-config/po/zh-cn/argon-config.po


# 在线用户
git_clone https://github.com/selfcan/luci-app-onliner
chmod 755 luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 关机
git_clone https://github.com/esirplayground/luci-app-poweroff


# bypass
git_clone https://github.com/kiddin9/openwrt-bypass
sed -i 's/luci-lib-ipkg/luci-base/g' openwrt-bypass/luci-app-bypass/Makefile

# openwrt-passwall 依赖
git_clone https://github.com/xiaorouji/openwrt-passwall

# Passwall  # 依赖 openwrt-passwall
svn_co https://github.com/xiaorouji/openwrt-passwall/branches/luci/luci-app-passwall

# Passwall2  # 依赖 openwrt-passwall
svn_co https://github.com/xiaorouji/openwrt-passwall2/trunk/luci-app-passwall2


# HelloWorld 依赖
git_clone https://github.com/fw876/helloworld


# HelloWorld  # 依赖 helloworld 和 openwrt-passwall
git_clone https://github.com/jerrykuku/lua-maxminddb
git_clone https://github.com/jerrykuku/luci-app-vssr


# OpenClash
git_clone https://github.com/vernesong/OpenClash
rm -rf luci-app-openclash && mv -f OpenClash/luci-app-openclash . && rm -rf OpenClash


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
git_clone https://github.com/linkease/istore && mv -n istore/luci/* ./; rm -rf istore
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile


# 网络向导
svn_co https://github.com/linkease/nas-packages/trunk/network/services/quickstart
svn_co https://github.com/linkease/nas-packages-luci/trunk/luci/luci-app-quickstart
sed -i 's/ +luci-app-store//g' luci-app-quickstart/Makefile


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
sed -i 's/DEPENDS:=\$(GO_ARCH_DEPENDS)$/DEPENDS:=\$(GO_ARCH_DEPENDS) +upx/g' netspeedtest/speedtest-web/Makefile

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
svn_co https://github.com/immortalwrt/luci/trunk/applications/luci-app-eqos
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-eqos/Makefile
cp -rf luci-app-eqos/po/zh_Hans luci-app-eqos/po/zh-cn
sed -i 's/zh_Hans/zh_CN/g' luci-app-eqos/po/zh-cn/eqos.po
chmod 755 luci-app-eqos/root/etc/init.d/eqos


# 文件浏览器
git_clone https://github.com/xiaozhuai/luci-app-filebrowser
sed -i 's/"services"/"nas"/g; s/"Services"/"NAS"/g' luci-app-filebrowser/luasrc/controller/filebrowser.lua
cp -rf luci-app-filebrowser/po/zh_Hans luci-app-filebrowser/po/zh-cn


# gowebdav
svn_co https://github.com/immortalwrt/packages/trunk/net/gowebdav
sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' gowebdav/Makefile
svn_co https://github.com/immortalwrt/luci/trunk/applications/luci-app-gowebdav
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' luci-app-gowebdav/Makefile
#sed -i '/"NAS"/d; /page/d' luci-app-gowebdav/luasrc/controller/gowebdav.lua
#sed -i 's/\"nas\"/\"services\"/g' luci-app-gowebdav/luasrc/controller/gowebdav.lua
cp -rf luci-app-gowebdav/po/zh_Hans luci-app-gowebdav/po/zh-cn


# vm-tools
# git_clone https://github.com/fangli/openwrt-vm-tools




# clean
rm -rf ./*/.svn*
rm -rf ./*/.git*


#end
exit 0
