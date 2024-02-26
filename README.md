# openwrt-packages
[openwrt-packages](https://github.com/wjz304/openwrt-packages)

## 使用
Openwrt:
```
sed -i '$a src-git ing https://github.com/wjz304/openwrt-packages;openwrt' feeds.conf.default
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```
Lede:
```
sed -i '$a src-git ing https://github.com/wjz304/openwrt-packages;lede' feeds.conf.default
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

# 在此 鸣谢各位插件作者

## 本仓库集成的各插件原库  


### default-settings
https://github.com/coolsnowwolf/lede/tree/master/package/lean/default-settings  


### r8125
this repo  


### Argon 主题
https://github.com/jerrykuku/luci-theme-argon/tree/18.06  


### Pink 主题
https://github.com/virualv/luci-theme-pink  


### Argon 主题配置插件
https://github.com/jerrykuku/luci-app-argon-config  


### 在线用户
https://github.com/selfcan/luci-app-onliner  


### 关机
https://github.com/esirplayground/luci-app-poweroff  


### 自动格式化分区、扩容、自动挂载
https://github.com/sirpdboy/luci-app-partexp  


### bypass
https://github.com/kiddin9/openwrt-packages/tree/master/luci-app-bypass  


### openwrt-passwall 依赖
https://github.com/xiaorouji/openwrt-passwall-packages  


### Passwall
https://github.com/xiaorouji/openwrt-passwall/tree/luci/luci-app-passwall  


### Passwall2
https://github.com/xiaorouji/openwrt-passwall2/tree/main/luci-app-passwall2  


### HelloWorld 依赖
https://github.com/fw876/helloworld  


### HelloWorld
https://github.com/jerrykuku/lua-maxminddb  
https://github.com/jerrykuku/luci-app-vssr  


### OpenClash
https://github.com/vernesong/OpenClash/tree/master/luci-app-openclash  


### Clash
https://github.com/frainzy1477/luci-app-clash  


### iKoolProxy 滤广告
https://github.com/yaof2/luci-app-ikoolproxy  


### AdGuard Home
https://github.com/rufengsuixing/luci-app-adguardhome  


###  ~~SmartDNS~~
~~https://github.com/pymumu/openwrt-smartdns~~  
~~https://github.com/pymumu/luci-app-smartdns/tree/lede~~  


### 应用商店
https://github.com/linkease/istore-ui  
https://github.com/linkease/istore/tree/main/luci/luci-app-store  


### 网络向导
https://github.com/linkease/nas-packages/tree/master/network/services/quickstart  
https://github.com/linkease/nas-packages-luci/tree/main/luci/luci-app-quickstart  


### lucky
https://github.com/gdy666/luci-app-lucky  


### DDNS-GO
https://github.com/sirpdboy/luci-app-ddns-go  

### 实时监控
https://github.com/sirpdboy/luci-app-netdata  


### 高级设置
https://github.com/sirpdboy/luci-app-advanced  


### 定时任务
https://github.com/DevOpenWRT-Router/luci-app-rebootschedule  


### 应用过滤
https://github.com/destan19/OpenAppFilter  


### 网速测试
https://github.com/sirpdboy/netspeedtest  


### 全能推送
https://github.com/zzsj0928/luci-app-pushbot  


### ZeroTier
https://github.com/rufengsuixing/luci-app-zerotier  


### Tailscale
https://github.com/MoZhonghua/openwrt-tailscale  


### IPv6 端口转发
https://github.com/big-tooth/luci-app-socatg  


### beardropper
https://github.com/NateLol/luci-app-beardropper  


### IP限速
https://github.com/immortalwrt/luci/tree/master/applications/luci-app-eqos  


### 文件浏览器
https://github.com/xiaozhuai/luci-app-filebrowser  


### gowebdav
https://github.com/immortalwrt/packages/tree/master/net/gowebdav  
https://github.com/immortalwrt/luci/tree/master/applications/luci-app-gowebdav  


### ~~vm-tools~~
~~https://github.com/fangli/openwrt-vm-tools~~  



## 鸣谢
- [sirpdboy's openwrt](https://github.com/sirpdboy)
- [immortalwrt's openwrt](https://github.com/immortalwrt/packages)
- [有種's openwrt-package](https://github.com/kenzok8/openwrt-packages)
- [笨蛋ovo's openwrt-package](https://github.com/liuran001/openwrt-packages)
- [kiddin9's openwrt-package](https://github.com/kiddin9/openwrt-packages)
- [Stalker's openwrt-package](https://github.com/xiangfeidexiaohuo/openwrt-packages)
- [jerrykuku's openwrt-package](https://github.com/jerrykuku/openwrt-package)
