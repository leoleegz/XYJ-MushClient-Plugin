--Module: study_monitor.lua

--防止被卷入囚洞

--忽然一阵黄风呼啸而来，你身不由己被卷了进去！l
--你被嘭地一声摔在地上！
--囚洞 - 
--zuan
--你轻手轻脚地钻进一个小洞，不见了．．．
--你脚下一滑，重重地摔了下去！
--你的动作还没有完成，不能移动。
--out
--舍利塔 - 
--    这里唯一的出口是 westdown。
--云梯冈 - 
--    这里明显的出口是 southdown、north 和 enter。

require "addxml"
require "tprint"

study.monitor = {}

function study.monitor.OnFallInToJail()
	message.Note("掉到囚洞了")
	DoAfterSpecial(5, "study.monitor.StartEscape()", 12)
end

function study.monitor.StartEscape()
	addxml.trigger { name="monitor_escape", 
						match="^西游记已经运行了",
						group="Study",
						enabled=true,
						sequence=20,
						keep_evaluating="y",
						script="study.monitor.OnZuanEnd",
						regexp="y"}
	command.RunOnly ( "l;zuan;l;l;l;uptime")
end

function study.monitor.OnRoomEntered( room )
	local j = table.getn(room.exits)
	for i = 1, j do
		if ( room.exits[i] == "out" ) then
			print("找到出口了")
			map.EndTraverse()
			DoAfterSpecial(1, "study.monitor.AfterAction()", 12)
			return false
		end
	end
	return true
end

function study.monitor.OnZuanEnd(name, line, wildcards, styles)
	DoAfterSpecial(1, "study.monitor.FindWayOut ()", 12)
	EnableTrigger("monitor_escape", false)
end

--找到出路
function study.monitor.FindWayOut ()
	DeleteTrigger("monitor_escape")
	map.EnterRoomCallback = study.monitor.OnRoomEntered
	map.BeginTraverse()
end

function study.monitor.AfterAction()
	message.Note("找到出路了，回去")

	--local backpath = GetVariable("escape_path")
	local backpath = study.places.escape_path[study.place]
	walk.WalkEndCallback = study.monitor.OnBack
	walk.WalkPath ( backpath )
end

function study.monitor.OnBack()
	message.Note("回来了，继续学习")
	command.RunOnly("xx")
end