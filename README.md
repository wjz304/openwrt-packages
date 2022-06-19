# openwrt-packages


## 使用
```
sed -i '$a src-git ing https://github.com/wjz304/openwrt-packages' feeds.conf.default
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

## 本仓库所有插件
### Argon 主题
https://github.com/jerrykuku/luci-theme-argon/tree/18.06  


### Argon 主题配置插件
https://github.com/jerrykuku/luci-app-argon-config  


### HelloWorld 依赖
https://github.com/fw876/helloworld  
https://github.com/xiaorouji/openwrt-passwall  


### HelloWorld
https://github.com/jerrykuku/lua-maxminddb  
https://github.com/jerrykuku/luci-app-vssr  


### OpenClash
https://github.com/vernesong/OpenClash/tree/master/luci-app-openclash  


### bypass
git_clone https://github.com/kiddin9/openwrt-bypass  


### 应用商店
https://github.com/linkease/istore-ui  
https://github.com/linkease/istore/tree/main/luci/luci-app-store  


### 应用过滤
https://github.com/destan19/OpenAppFilter  


### 实时监控
https://github.com/sirpdboy/luci-app-netdata  


### 网速测试
https://github.com/sirpdboy/netspeedtest  


### 高级设置
https://github.com/sirpdboy/luci-app-advanced  


## 全能推送
https://github.com/zzsj0928/luci-app-pushbot  


### 文件管理
https://github.com/xiaozhuai/luci-app-filebrowser  


### 定时任务
https://github.com/DevOpenWRT-Router/luci-app-rebootschedule  


### gowebdav
https://github.com/immortalwrt/luci/tree/master/applications/luci-app-gowebdav  
https://github.com/immortalwrt/packages/tree/master/net/gowebdav  


### IP限速
https://github.com/immortalwrt/luci/tree/master/applications/luci-app-eqos


## 鸣谢
- [sirpdboy's openwrt](https://github.com/sirpdboy)
- [immortalwrt's openwrt](https://github.com/immortalwrt/packages)
- [有種's openwrt-package](https://github.com/kenzok8/openwrt-packages)
- [笨蛋ovo's openwrt-package](https://github.com/liuran001/openwrt-packages)
- [kiddin9's openwrt-package](https://github.com/kiddin9/openwrt-packages)
- [Stalker's openwrt-package](https://github.com/xiangfeidexiaohuo/openwrt-packages)
- [jerrykuku's openwrt-package](https://github.com/jerrykuku/openwrt-package)