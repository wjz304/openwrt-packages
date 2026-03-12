# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2026  sirpdboy  <herboy2008@gmail.com> 
# https://github.com/sirpdboy/luci-app-netspeedtest
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-netspeedtest

PKG_VERSION:=5.1.3
PKG_RELEASE:=20260306

LUCI_TITLE:=LuCI Support for netspeedtest
LUCI_DEPENDS:=+ookla-speedtest +homebox +python3-light +python3-pkg-resources +python3-xml +python3-email \
	  +python3-urllib +python3-codecs +python3-openssl +jq $(if $(find_package iperf3-ssl),+iperf3-ssl,+iperf3)
LUCI_PKGARCH:=all
PKG_MAINTAINER:=sirpdboy  <herboy2008@gmail.com>

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
