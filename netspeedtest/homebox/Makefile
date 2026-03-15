# SPDX-License-Identifier: GPL-3.0-only
# Copyright (c) 2022-2026 sirpdboy herboy2008@gmail.com
#

include $(TOPDIR)/rules.mk

PKG_NAME:=homebox
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

ifeq ($(ARCH),aarch64)
  PKG_ARCH:=arm64
  PKG_HASH:=e645229b4cffef9ab1d4b3989f1b9523f487bf3f570c4391c4b62522de3e6b7f
else ifeq ($(ARCH),arm)
  PKG_ARCH:=armv7
  PKG_HASH:=879159fad956cf368b2c933bf871576a212379698245a91a2e5256d0dc17f8b3
else ifeq ($(ARCH),i386)
  PKG_ARCH:=386
  PKG_HASH:=ab3e875988506706b63420f4f3dcd959fdfb1777d836ada1d776a074a0aa561a
else ifeq ($(ARCH),x86_64)
  PKG_ARCH:=amd64
  PKG_HASH:=5640b5a93846f26a07cfbbb2d6ca9b27efd3ad2d210b327a7c3832beaf8a3e62
endif

PKG_LICENSE:=Proprietary
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sirpdboy <herboy2008@gmail.com>
PKG_SOURCE:=homebox-linux-$(PKG_ARCH)-musl-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/sirpdboy/homebox/releases/download/v$(PKG_VERSION)/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_ARCH)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Speed Test
	TITLE:=Home Local Network Speed Test Tool
	URL:=https://github.com/XGHeaven/homebox
	DEPENDS:=@(i386||x86_64||arm||aarch64)
endef

define Package/$(PKG_NAME)/description
  A Toolbox for Home Local Networks Speed Test
endef

define Build/Prepare
	( \
		pushd $(PKG_BUILD_DIR) ; \
			$(TAR) -zxf $(DL_DIR)/homebox-linux-$(PKG_ARCH)-musl-v$(PKG_VERSION).tar.gz -C . ; \
		popd ; \
	)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/homebox $(1)/usr/bin/homebox
endef

$(eval $(call BuildPackage,$(PKG_NAME)))