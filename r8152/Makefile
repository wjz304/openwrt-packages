# Attribution: https://gist.github.com/lenew/9b41ba901c3393047ede0766760f9d55

#Put this source to 'package/lean/r8152' folder of OpenWRT/LEDE SDK
#Build(make menuconfig, make defconfig, make)

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=r8152
PKG_VERSION:=2.18.1-1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/awesometic/realtek-r8152-dkms/tar.gz/$(PKG_VERSION)?
PKG_HASH:=7f2868568cd389127e3853603d8457cc02e67694e3c475191d02d8476b5caa57
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/realtek-$(PKG_NAME)-dkms-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define KernelPackage/r8152
  TITLE:=Driver for Realtek r8152 chipsets
  SUBMENU:=Network Devices
  VERSION:=$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE)
  FILES:= $(PKG_BUILD_DIR)/src/r8152.ko
  AUTOLOAD:=$(call AutoProbe,r8152)
endef

define Package/r8152/description
  This package contains a driver for Realtek r8152 chipsets.
endef

define Build/Compile
	+$(KERNEL_MAKE) M=$(PKG_BUILD_DIR)/src modules
endef

$(eval $(call KernelPackage,r8152))
