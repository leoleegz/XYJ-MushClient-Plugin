--Module: nk.lua
require "tprint"
require "addxml"

nk={}

nk.target = ""

--方向列表
nk.dir_list = {"n", "e", "s", "w", "ne", "se", "sw", "nw", "u", "d", "nu", "nd", "eu", "ed", "su", "sd", "wu", "wd", "enter", "out", "backyard", "frontyard", "swim", "dive", "right", "left", "climb tree"}

function nk.Start()
	local walk_path = GetVariable("nk_path")
	local walk_step = 0
	SetVariable("nk_step", walk_step)
	if ( walk_path and walk_path ~= "") then
		message.Note("开始进入NK模式")
		--停止“防止发呆计时器”，如果中间有错误，则发呆退出
		EnableTimer("fadai", false)
		EnableTrigger("monitor_mobs", false)
		EnableTrigger ( "warn_mobs", false )

		--执行NK命令
		nk.DoNK()
	end
end

function nk.Stop()
	nk.RemoveTriggers()
	SetVariable("nk_step", "-1")
	message.Note("退出NK模式")
	EnableTimer("fadai", true)
end

--执行一次NK指令
function nk.DoNK()
	local nk_command = GetVariable("nk_command")
	nk.target = ""
	nk.RemoveTriggers()

	addxml.trigger { name="nk_gettarget", 
				match="^看起来(?P<nk_name>\\S+)想杀死你！$",
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnGetTarget",
				regexp="y"}
	addxml.trigger { name="nk_notarget", 
				match="^这里没有这个人。$",
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnNoTarget",
				regexp="y"}
	command.RunOnly(nk_command)
end

--找到目标
function nk.OnGetTarget (name, line, wildcards, styles)
	nk.target = wildcards["nk_name"]
	EnableTrigger("nk_gettarget", false)
	DoAfterSpecial (0.1, "nk.SetupEndTrigger()", 12)
end

--没有找到目标
function nk.OnNoTarget (name, line, wildcards, styles)
	EnableTrigger("nk_notarget", false)
	DoAfterSpecial (0.1, "nk.BrowseNextStep ()", 12)
end

--设置本次结束触发器
function nk.SetupEndTrigger ()
	nk.RemoveTriggers()

	local pattern = "^" .. nk.target .. "死了。$"

	addxml.trigger { name="nk_killedtarget", 
				match=pattern,
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnKilledTarget",
				regexp="y"}
end 

--杀死目标了
function nk.OnKilledTarget (name, line, wildcards, styles)
	EnableTrigger("nk_killedtarget", false)
	DoAfterSpecial (0.5, "nk.DoNK ()", 12)
end

function nk.RemoveTriggers()
	DeleteTrigger("nk_gettarget")
	DeleteTrigger("nk_notarget")
	DeleteTrigger("nk_killedtarget")
end

--往下一个地方走
function nk.BrowseNextStep ()
	nk.RemoveTriggers()

	local walk_path = GetVariable("nk_path")
	local walk_step = tonumber(GetVariable("nk_step"))
	local walk_list = utils.split ( walk_path, ";" )

	walk_step = walk_step + 1

	if ( walk_list[walk_step] ) then	--正常进行下一步行走
		local walk_dir = walk_list[walk_step]
		local do_nk = false
		SetVariable("nk_step", walk_step)
		command.RunOnly ( walk_dir )

		for _, v in pairs(nk.dir_list) do
			if ( walk_dir == v ) then
				do_nk = true
				break
			end
		end

		if ( do_nk ) then
			DoAfterSpecial (1, "nk.DoNK ()", 12)
		else
			DoAfterSpecial (0.5, "nk.BrowseNextStep ()", 12)
		end
	elseif ( walk_step >= table.getn(walk_list) ) then	-- 行走到路径末尾，从头开始
		--回到起始点了
		walk_step = 0
		SetVariable("nk_step", walk_step)
		--等待刷新后再进行NK
		print("去休息，等刷新")
		command.Run("hp", nk.DoRest)
		--DoAfterSpecial (2, "nk.DoRest ()", 12)
	else
		message.Note("路径错误")
	end
end

--休息一会等刷新
function nk.DoRest()
	--me.state.RecoverEndCallback = nk.GotoHotel
	--me.state.Recover()
	nk.GotoHotel()
end

--去客栈发呆
function nk.GotoHotel()
	local rest_path = GetVariable("nk_restpath")
	walk.WalkEndCallback = nk.OnRestEnd
	walk.WalkPath ( rest_path )
end

--休息结束
function nk.OnRestEnd(object_found, walk_end, state)
	print("重新开始NK")
	DoAfterSpecial (0.5, "nk.DoNK ()", 12)
end
