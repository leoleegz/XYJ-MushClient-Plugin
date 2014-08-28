-- Module: monitor.lua
-- 监控模块，防止意外

monitor = {}

-- 添加监视触发器
addxml.trigger { name="monitor_mobs", 
				match="^(?P<killer_name>\\S+)盯着你，馋得直流口水：嘿嘿．．．$",
				group="Monitor",
				enabled=false,
				sequence=50,
				script="monitor.FocusedByMobs",
				regexp="y"}

addxml.trigger { name="warn_mobs", 
				match="^看起来想杀死你！$",
				group="Monitor",
				enabled=false,
				sequence=50,
				script="monitor.SomeWantKillMe",
				regexp="y"}

function monitor.SomeWantKillMeCallback_Inner ( )
	message.Note("口水怪要杀人", "red")
	command.RunOnly("quit")
end
monitor.SomeWantKillMeCallback = monitor.SomeWantKillMeCallback_Inner


--被口水怪盯上
function monitor.FocusedByMobs (name, line, wildcards, styles)
	local mob_name = wildcards["killer_name"]
	message.Note("被口水怪"..wildcards["killer_name"].."盯上", "red")
	SetTriggerOption("warn_mobs", "match", "^看起来"..mob_name.."想杀死你！$")
	EnableTrigger("warn_mobs", true)
end

--口水怪要杀人
function monitor.SomeWantKillMe (name, line, wildcards, styles)
	monitor.SomeWantKillMeCallback ( )
	monitor.SomeWantKillMeCallback = monitor.SomeWantKillMeCallback_Inner
end

function monitor.KeepConnected (name, line, wildcards, styles)
	if ( not world.IsConnected() ) then
		message.Note("断线，重新连接")
		world.Connect ( )
	end
end
