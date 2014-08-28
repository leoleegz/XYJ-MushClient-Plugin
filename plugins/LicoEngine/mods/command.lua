-- Module: command.lua
-- 指令系统
require "tprint"
require "addxml"

command = {}

local splitchar = ";"
--需要进行特殊处理的命令
--local special_cmds = {"#wa;#wait"}

function command.init_env ()
	--添加指令结束的触发器
	addxml.trigger { name="cmd_outputend", 
					match="^>",
					group="Cmds",
					enabled=false,
					sequence=20,
					script="command.OnOutputEnd",
					regexp="y"}

	--添加指令成功的触发器
	addxml.trigger { name="cmd_success", 
					match="temp_match",
					group="Cmds",
					enabled=false,
					sequence=20,
					script="command.OnCmdSuccess",
					regexp="y"}
	--由于addxml在match为空字符串时报错，因此需要先用一个临时的匹配模式
	SetTriggerOption ("cmd_success", "match", "")

	addxml.trigger { name="cmd_waittrigger", 
				match="temp_match",
				group="Cmds",
				enabled=false,
				sequence=20,
				script="command.OnTriggered",
				regexp="y"}
	SetTriggerOption ("cmd_waittrigger", "match", "")
end
command.init_env ()  -- 初始化指令环境

-- 指令输出结束时的回调函数
function command.OutputEndCallback_Inner( )
	print ("指令输出结束")
end --OutputEndCallback_Inner
command.OutputEndCallback = command.OutputEndCallback_Inner

--指令成功的回调函数
--line: 匹配的行
--wildcards: 匹配项
function command.CmdSuccessCallback_Inner(line, wildcards)
	print("指令成功")
end
command.CmdSuccessCallback = command.CmdSuccessCallback_Inner

--指令失败的回调函数
--line: 匹配的行
--wildcards: 匹配项
function command.CmdFailedCallback_Inner(line, wildcards)
	print("指令失败")
end
command.CmdFailedCallback = command.CmdFailedCallback_Inner

--指令输出结束时的触发器调用函数
function command.OnOutputEnd (name, line, wildcards, styles)
	local temp_func 
	temp_func = command.OutputEndCallback
	command.OutputEndCallback = command.OutputEndCallback_Inner

	--恢复原始环境
	EnableTrigger("cmd_outputend", false)
	EnableTrigger("cmd_success", false)
	EnableTriggerGroup("Cmds_Failed" ,false)
	
	command.CmdSuccessCallback = command.CmdSuccessCallback_Inner
	command.CmdFailedCallback = command.CmdFailedCallback_Inner

	--删除判断失败的触发器组
	SetTriggerOption ("cmd_success", "match", "")
	DeleteTriggerGroup ("Cmds_Failed")
	
	return temp_func()
end

--指令成功时的触发器调用函数
function command.OnCmdSuccess (name, line, wildcards, styles)
	command.CmdSuccessCallback(line, wildcards)
	--恢复原始状态
	command.CmdSuccessCallback = command.CmdSuccessCallback_Inner
end

--指令失败时的触发器调用函数
function command.OnCmdFailed (name, line, wildcards, styles)
	command.CmdFailedCallback (line, wildcards)
	command.CmdFailedCallback = command.CmdFailedCallback_Inner
end

function command.OnTriggered (name, line, wildcards, styles)
	EnableTrigger("cmd_waittrigger", false)
	SetTriggerOption ("cmd_waittrigger", "match", "")
	command.OnOutputEnd()
end

--注册外部的指令输出调用函数
function command.RegisterCmdEndCallback ( cmd_end_callback )
	--如果传入了输出结束回调函数
	if ( cmd_end_callback ) then
		command.OutputEndCallback = cmd_end_callback
	end
	EnableTrigger("cmd_outputend", true)
end

--仅仅是运行
function command.RunOnly ( commandstring )
	if ( not commandstring ) then
		print ("命令格式错误，没有指令")
		return
	end
	--记录运行的时间，用于检测 idle
	system.ResetTimers ()
	--todo:?

	world.Execute ( commandstring )
end

-- 运行一条指令
function command.Run ( commandstring, cmd_end_callback )
	system.ResetTimers ()
	--处理特殊指令
	if ( commandstring == "hp" ) then
		me.state.GetHpEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	elseif ( commandstring == "skills" ) then
		me.skills.GetSkillEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	elseif ( commandstring == "i" ) then
		me.items.GetItemsEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	end

	--如果传入了输出结束回调函数
	if ( cmd_end_callback ) then
		command.OutputEndCallback = cmd_end_callback
	end
	EnableTrigger("cmd_outputend", true)
	--记录运行的时间，用于检测 idle
	--todo:?

	--查找是否为等待指令，如果是则等待一段时间，否则直接执行指令
	local i, j, v

	i, j, v = string.find(commandstring, "^#wait (%d+)$")
	if ( i and i == 1 ) then
		--等待一段时间
		print("等待" .. tonumber(v) .. "秒后继续执行")
		return DoAfterSpecial (tonumber(v), 'command.OnOutputEnd()', 12)
	end

	i, j, v = string.find(commandstring, "^#tri (.*)$")
	if ( i and i == 1 ) then
		--设置触发条件
		print("等待触发:" .. v )
		SetTriggerOption ("cmd_waittrigger", "match", v)
		EnableTrigger("cmd_waittrigger", true)
		return
	end

	i, j, v = string.find(commandstring, "^#dummy (.*)$")
	if ( i and i == 1 ) then
		if ( dummy.mode >= 2 ) then
			--告诉大米行动
			print("通知大米行动:" .. v)
			local id = GetVariable("dummy_id")
			commandstring = "tell " .. id .. " " .. v
		else
			commandstring = "uptime"
		end
	end

	world.Execute ( commandstring )
end

-- 运行一条指令，需要进行成功与否的判定
function command.RunWithConfirm ( commandstring, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	system.ResetTimers ()

	-- 设置指令成功的触发器
	if ( successpattern ) then
		SetTriggerOption ("cmd_success", "match", successpattern)
		EnableTrigger("cmd_success", true)
		if ( cmd_success_callback ) then	-- 如果传入了回调函数，则设置回调函数
			command.CmdSuccessCallback = cmd_success_callback
		end
	end

	-- 设置指令失败的触发器，failedpatterns为数组
	if( failedpatterns ) then
		local v, i
		i = 0
		for _, v in pairs(failedpatterns) do
			-- 添加失败判断的触发器
			i = i + 1
			addxml.trigger { name="cmdfailed"..i,
				match=v,
				group="Cmds_Failed",
				enabled=true,
				sequence=50,
				script="command.OnCmdFailed",
				regexp="y"}
		end
		if ( cmd_failed_callback ) then
			command.CmdFailedCallback = cmd_failed_callback
		end
	end
	command.Run (commandstring, cmd_end_callback)
end

--运行多条指令，无需等待前一条指令成功
function command.RunMultipleCommands ( commands, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	local v
	local cmd_table = utils.split( commands, splitchar)
	system.ResetTimers ()
	for _, v in pairs(cmd_table) do
		command.RunWithConfirm ( v, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	end
end
