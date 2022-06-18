#!/bin/bash

function git_clone() {
  rm -rf $(basename $1 .git)
  git clone --depth 1 $1 $(basename $1 .git) || true
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
}

function git_clone_b() {
  rm -rf $(basename $1 .git)
  git clone --depth 1 -b $2 $1 $(basename $1 .git) || true
  rm -rf $(basename $1 .git)/.svn* $(basename $1 .git)/.git*
}

function svn_co() {
  rm -rf $2
  svn co $1 $2 || true
  rm -rf $2/.svn* $2/.git*
}


# Argon 主题
git_clone_b https://github.com/jerrykuku/luci-theme-argon 18.06


# Argon 主题配置插件
git_clone https://github.com/jerrykuku/luci-app-argon-config
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile


# HelloWorld 依赖
git_clone https://github.com/fw876/helloworld
git_clone https://github.com/xiaorouji/openwrt-passwall


# HelloWorld
git_clone https://github.com/jerrykuku/lua-maxminddb.git
git_clone https://github.com/jerrykuku/luci-app-vssr.git


# OpenClash
git_clone https://github.com/vernesong/OpenClash.git
rm -rf luci-app-openclash && mv -f OpenClash/luci-app-openclash . && rm -rf OpenClash


# 应用商店
git_clone https://github.com/linkease/istore-ui
git_clone https://github.com/linkease/istore && mv -n istore/luci/* ./; rm -rf istore
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile


# 应用过滤
git_clone https://github.com/destan19/OpenAppFilter


# 实时监控
git_clone https://github.com/sirpdboy/luci-app-netdata


# 钉钉企微推送
git_clone https://github.com/zzsj0928/luci-app-pushbot


# end
rm -rf ./*/.svn*
rm -rf ./*/.git*

exit 0
