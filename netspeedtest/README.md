![hello](https://views.whatilearened.today/views/github/sirpdboy/deplives.svg) [![](https://img.shields.io/badge/TG群-点击加入-FFFFFF.svg)](https://t.me/joinchat/AAAAAEpRF88NfOK5vBXGBQ)

- 因 luci-app-netspeedtest 仓库近期更新时，在 JS 版本测速插件中误用了部分文件，导致被指侵权，目前原仓库暂时无法访问。
- 应好伙伴们的要求，现已开放最新的临时测速源码地址：👉 https://github.com/sirpdboy/netspeedtest
- 本插件最早由我于 2019 年开发并发布，是【OPENWRT 平台上最早】系统性研究和整合网络测速功能的人，并一直持续更新维护至今。
- 这次事件也波及到了多个其他仓库，对此我深表遗憾。
- 我个人的 GitHub 仓库中，有十几个开源的插件，每一个都是经过无数个日夜、一点点熬出来的，熬出了一身病，也熬出了一份执着。
- 开发过程中，代码间相互参考、借鉴他人经验，本是开源社区的常态，也是开源精神的体现：互相学习，共同进步。
- 关于 luci-app-netspeedtest 仓库，我们在说明中已标明部分代码的参考来源。
- 唯一的问题是，之前在维护过程中，有一个 License 文件确实因操作失误填错了，我当时是在网页端直接操作，处理上可能不够严谨，恳请大家理解。
- 即便是被指“抄袭”的 speedtest.js 文件，前段时间我们也已补充了参考来源，该文件也绝不是简单复制粘贴而来的。
- 希望大家能尊重事实，理性看待问题，文明交流，少一点戾气，多一份理解。
- 我们都是开源社区的搬运工，做点东西不容易，没必要动辄上纲上线。
- 
- 附：恩山【网络测速】开源贴：https://www.right.com.cn/forum/thread-5970397-1-1.html
- 
- 【最近感觉】：风雨飘摇，且用且珍惜吧。


<h1 align="center">
  <br>Net Speed Test<br>
</h1>

  <p align="center">

  <a target="_blank" href="https://github.com/sirpdboy/luci-app-netspeedtest/releases">
    <img src="https://img.shields.io/github/release/sirpdboy/luci-app-netspeedtest.svg?style=flat-square&label=NetSpeedTest&colorB=green">
  </a>
</p>

[中文](README_CN.md) | English

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/说明1.jpg)

Luci app netspeedtest network speed diagnostic test (including: intranet web version speed test, intranet iperf3 throughput speed test, intranet speedtest.net network speed test, specific server port latency speed test)

Please read this page carefully, which includes precautions and instructions on how to use it.

##Write it in front

- I have been looking for a plugin to test speed on OPENWRT, but I couldn't find it, so I came up with it! This plugin can perform internal and external network speed testing.
- TG group members said that the plugin hasn't been updated for 2 years, and it took a few days to upgrade the network testing function to version 2.0 based on current needs.


## Function Description
- Internal network web version speed measurement plugin: Based on the HomeBox web version, enable it and then click start to perform speed measurement. After the web version is launched, the program will reside in memory. It is not recommended to enable the service due to slow speed.
- Internal iperf3 throughput test, if the server router is not installed, please install this iperf3 plugin first.
- The external network speed measurement uses the speedtest.net speed measurement kernel, based on speedtest cli, and cancels the old Python 3.
- The port delay speed measurement of a specific server is to test the delay situation of the specified server's port.

## Precautions for iperf3 throughput testing
- The terminal for speed measurement must be on the same local area network as the speed measurement server!
- Client usage steps: Start the speed measurement server -->Download the test client -->Run the speed measurement client -->Enter the server IP address -->View the results.
- The client is running, and there is a "iperf3 speed measurement client" available for download on the domestic end. Simply enter the server IP to run it.
The original version from abroad requires manually entering CMD command mode and then entering the command: iperf3.exe - c server IP
- Download link for iperf3 client for network speed measurement: https://sipdboy.lanzoui.com/b01c3esih Password: cpd6
 -Need to rely on: speedtest cli



### downloading source:

 ```Brach
    # downloading
    git clone https://github.com/sirpdboy/luci-app-netspeedtest package/netspeedtest
    make menuconfig
	
 ``` 
### Configuration Menu

 ```Brach
    make menuconfig
	# find LuCI -> Applications, select luci-app-netspeedtest, save and exit
 ``` 
### compile
 ```Brach 
    # compile
    make package/netspeedtest/luci-app-netspeedtest/compile V=s
 ```


## describe
- luci-app-netspeedtest：https://github.com/sirpdboy/luci-app-netspeedtest
- homebox：https://github.com/hay-kot/homebox
- speedtest-cli: https://github.com/sbwml/openwrt_pkgs
- speedtest.py: https://github.com/sivel/speedtest-cli
- speedtest.js: https://github.com/muink/luci-app-netspeedtest

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/说明2.jpg)


## interface

![screenshots](./演示.gif)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netspeedtest1.png)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netspeedtest2.png)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netspeedtest3.png)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netspeedtest4.png)

# My other project

- Watch Dog ： https://github.com/sirpdboy/luci-app-watchdog
- Net Speedtest ： https://github.com/sirpdboy/netspeedtest
- Task Plan : https://github.com/sirpdboy/luci-app-taskplan
- Power Off Device : https://github.com/sirpdboy/luci-app-poweroffdevice
- OpentoPD Theme : https://github.com/sirpdboy/luci-theme-opentopd
- Ku Cat Theme : https://github.com/sirpdboy/luci-theme-kucat
- Ku Cat Theme Config : https://github.com/sirpdboy/luci-app-kucat-config
- NFT Time Control : https://github.com/sirpdboy/luci-app-timecontrol
- Parent Control: https://github.com/sirpdboy/luci-theme-parentcontrol
- Eqos Plus: https://github.com/sirpdboy/luci-app-eqosplus
- Advanced : https://github.com/sirpdboy/luci-app-advanced
- ddns-go : https://github.com/sirpdboy/luci-app-ddns-go
- Advanced Plus）: https://github.com/sirpdboy/luci-app-advancedplus
- Net Wizard: https://github.com/sirpdboy/luci-app-netwizard
- Part Exp: https://github.com/sirpdboy/luci-app-partexp
- Lukcy: https://github.com/sirpdboy/luci-app-lukcy

## HELP

|     <img src="https://img.shields.io/badge/-Alipay-F5F5F5.svg" href="#赞助支持本项目-" height="25" alt="图飞了"/>  |  <img src="https://img.shields.io/badge/-WeChat-F5F5F5.svg" height="25" alt="图飞了" href="#赞助支持本项目-"/>  | 
| :-----------------: | :-------------: |
|![xm1](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/支付宝.png) | ![xm1](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/微信.png) |

<a href="#readme">
    <img src="https://img.shields.io/badge/-TOP-orange.svg" alt="no" title="Return TOP" align="right"/>
</a>

![hello](https://visitor-badge-deno.deno.dev/sirpdboy.sirpdboy.svg) [![](https://img.shields.io/badge/TGGroup-ClickJoin-FFFFFF.svg)](https://t.me/joinchat/AAAAAEpRF88NfOK5vBXGBQ)
