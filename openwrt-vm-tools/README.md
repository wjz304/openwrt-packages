# openwrt-vm-tools
vmware tools open-vm-tools for OpenWRT

This is an OpenWRT port of VMWare official open-vm-tools. This port uses latest devel branch(01/23/2019) of original, fixed bunches of bugs by https://github.com/srchack/custom-packages .

I have it tested with the follow platform:
OpenWRT 18.06.1 x86_64 on ESXi 6.x

Power on/Shutdown/Report IPs etc. are functional normally with this build. It should works with both lede 17.x and OpenWRT 18.x. Feel free to report bugs here.

With this build, I don't see any crashes or segfault anymore. and that's why I made this build.

## Compile

```
# Step 1
# git clone OpenWRT and checkout the same branch as your router.
# Since open-vm-tools has many dependencies of basic libraries in OpenWRT, I don't think you can compile this tools with only SDK.
# So just make sure you cloned the full openwrt repo.

# Step 2
git clone https://github.com/fangli/openwrt-vm-tools package/open-vm-tools

# Step 3
make menuconfig
# And Set `Utilities` - `open-vm-tools` to `M` (modularizes features)

# Step 4
make package/open-vm-tools/compile

# Finish
# Then ./bin/packages/x86_64/base/open-vm-tools_devel-1a39495-1_x86_64.ipk is what you need.

```

## For convenience, I published the ipk binary for OpenWRT 18.06.1, if you are running the same version of openwrt, feel free to just download and install it:

```
cd /tmp
wget https://xxxxx/open-vm-tools_devel-1a39495-1_x86_64.ipk (Get the URL on releases page of this repo)
opkg update
opkg install open-vm-tools_devel-1a39495-1_x86_64.ipk
reboot
```
