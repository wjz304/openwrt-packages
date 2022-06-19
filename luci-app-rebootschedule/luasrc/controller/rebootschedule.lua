module("luci.controller.rebootschedule", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/rebootschedule") then
		return
	end
	
	entry({"admin", "control", "rebootschedule"}, cbi("rebootschedule"), "Timing setting", 20).dependent = true
end



