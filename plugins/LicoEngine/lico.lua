-- Lico 引擎主程序
-- 根据hellua改写

luapath=string.match(GetInfo(35),"^.*\\")
--print("luapath:"..luapath)
mclpath=GetInfo(67)
--print("mclpath:"..mclpath)

include=function(str)
	dofile(luapath..str)
end

loadmod=function(str)
	include("mods\\"..str)
end

loadmclfile=function(str)
		local f=(loadfile(mclpath..str))
		if f~=nil then f() end
end

print("载入中...")

loadmod("general.lua")
loadmod("system.lua")
loadmod("message.lua")
loadmod("number.lua")
loadmod("command.lua")
--loadmod("command_serial.lua")
loadmod("map.lua")
loadmod("map_room.lua")
loadmod("me_state.lua")
loadmod("me_items.lua")
loadmod("me_skills.lua")
loadmod("location.lua")
loadmod("walk.lua")
loadmod("task.lua")
loadmod("task_yuan.lua")
loadmod("task_lijing.lua")
loadmod("study.lua")
loadmod("study_onestage.lua")
loadmod("study_twostage.lua")
loadmod("study_special.lua")
loadmod("study_places.lua")
loadmod("study_recover.lua")
loadmod("study_patch.lua")
loadmod("study_patch_xueshu.lua")
loadmod("study_patch_tianmotai.lua")
loadmod("study_monitor.lua")
loadmod("dummy.lua")
loadmod("dummy_requirer.lua")
loadmod("dummy_helper.lua")
loadmod("study_dummy.lua")
loadmod("nk.lua")
loadmod("monitor.lua")

--[[
if configcmd~=nil then
	configcmd()
end
loadmod("update.mod")
--]]
print("载入完毕")

