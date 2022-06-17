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


git_clone_b https://github.com/jerrykuku/luci-theme-argon 18.06

git_clone https://github.com/jerrykuku/luci-app-argon-config
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile


git_clone https://github.com/fw876/helloworld
git_clone https://github.com/xiaorouji/openwrt-passwall

git_clone https://github.com/jerrykuku/lua-maxminddb.git
git_clone https://github.com/jerrykuku/luci-app-vssr.git


git_clone https://github.com/linkease/istore-ui
git_clone https://github.com/linkease/istore && mv -n istore/luci/* ./; rm -rf istore
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile



rm -rf ./*/.svn*
rm -rf ./*/.git*

exit 0
