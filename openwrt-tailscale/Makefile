#
# Copyright (C) 2019-2020 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tailscale
PKG_VERSION:=1.26.1
PKG_RELEASE:=1

PKG_SOURCE_NAME=tailscale
PKG_SOURCE:=v$(PKG_VERSION).tar.gz

PKG_SOURCE_URL:=https://github.com/tailscale/tailscale/archive/refs/tags/
PKG_HASH:=69fb95840bd0fc9d2f39300c984db0d504f6af180f839d31b2f26034092077cc
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_NAME)-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Zhonghua Mo <mozhonghu@yeah.net>

PKG_BUILD_DEPENDS:=golang/host PACKAGE_tailscale_compress_upx:upx/host

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=tailscale.com/cmd/tailscale
GO_PKG_LDFLAGS:=-s -w -buildid=

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/tailscale
  TITLE:=Tailscale
  URL:=https://github.com/tailscale/tailscale
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(GO_ARCH_DEPENDS)
  PROVIDES:=tailscale
endef

define Package/tailscale/description
	tailscale
endef

define Package/tailscale/config
menu "Tailscale Configuration"

config PACKAGE_tailscale_compress_upx
	bool "Compress executable files with UPX"
	default n

endmenu
endef


define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=tailscale.com/cmd/tailscale)
	$(call GoPackage/Build/Compile)

	$(eval GO_PKG_BUILD_PKG:=tailscale.com/cmd/tailscaled)
	$(call GoPackage/Build/Compile)

ifeq ($(CONFIG_PACKAGE_tailscale_compress_upx),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/tailscale || true
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/tailscaled || true
endif

endef

define Package/tailscale/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tailscale $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tailscaled $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tailscaled.init $(1)/etc/init.d/tailscaled
endef

$(eval $(call BuildPackage,tailscale))
