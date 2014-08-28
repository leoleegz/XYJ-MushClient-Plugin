-- dummy_helper.lua
require "addxml"
require "tprint"

dummy.helper = {}

dummy.helper.lastmessage = ""

helper_state_none = 0
helper_state_fullqi = 1
helper_state_fullshen = 2
helper_state_outofforce = 3
helper_state_huifu = 4

dummy.helper.state = helper_state_none

function dummy.helper.HelpEnd_Inner()
	dummy.Send(dummy.endflag)
end
dummy.helper.HelpEndCallback = dummy.helper.HelpEnd_Inner

function dummy.helper.Receive (message)
	dummy.helper.lastmessage = message
	dummy.helper.Invoke ()
end

--根据消息内容进行调用
function dummy.helper.Invoke ()
	if ( dummy.helper.state == helper_state_huifu ) then
		me.state.RecoverEndCallback = dummy.helper.HuifuEnd
		return
	end
	dummy.helper.state = helper_state_none
	
	local commandstring = ""
	local id = GetVariable("dummy_id")
	if ( dummy.helper.lastmessage == "huifu" or dummy.helper.lastmessage == "recover" ) then
		commandstring = "exert recover " .. id
		addxml.trigger { name="dummy_fullqi", 
				match="^对方现在气力充沛，不需吸气。$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnTargetFullQi",
				regexp="y"}
	elseif ( dummy.helper.lastmessage == "refresh") then
		commandstring = "exert refresh " .. id
		addxml.trigger { name="dummy_fullshen", 
				match="^对方现在精神饱满，不需吸气。$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnTargetFullShen",
				regexp="y"}
	else
		world.Execute ( dummy.helper.lastmessage )
		dummy.helper.EndInvoke()
		return
	end

	addxml.trigger { name="dummy_outofforce", 
				match="^你的内力不够。$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnOutofForce",
				regexp="y"}

	addxml.trigger { name="dummy_actionend", 
				match="^西游记已经运行了",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnActionEnd",
				regexp="y"}

	system.ResetTimers ()
	command.Run( "#15 (".. commandstring .. ");uptime")
end

--目标对象气血充足: 对方现在气力充沛，不需吸气。
function dummy.helper.OnTargetFullQi (name, line, wildcards, styles)
	dummy.helper.state = helper_state_fullqi
	EnableTrigger("dummy_fullqi", false)
end

--目标对象精神饱满: 对方现在精神饱满，不需吸气。
function dummy.helper.OnTargetFullShen (name, line, wildcards, styles)
	dummy.helper.state = helper_state_fullshen
	EnableTrigger("dummy_fullshen", false)
end

--自己内力不足： 你内力不足
function dummy.helper.OnOutofForce (name, line, wildcards, styles)
	dummy.helper.state = helper_state_outofforce
	EnableTrigger("dummy_outofforce", false)
end

function dummy.helper.OnActionEnd (name, line, wildcards, styles)
	EnableTrigger("dummy_actionend", false)
	DoAfterSpecial ( 2, "dummy.helper.CheckStatus()", 12 )
end

--恢复结束
function dummy.helper.HuifuEnd()
	dummy.helper.state = helper_state_none
	dummy.helper.Invoke ()
end

--检查状态
function dummy.helper.CheckStatus()
	if ( dummy.helper.state == helper_state_none ) then
		dummy.helper.Invoke ()
	elseif ( dummy.helper.state == helper_state_fullqi ) then
		if ( dummy.helper.lastmessage == "huifu") then
			dummy.helper.lastmessage = "refresh"
			dummy.helper.Invoke ()
			return
		end
		dummy.helper.EndInvoke()
	elseif ( dummy.helper.state == helper_state_fullshen ) then
		dummy.helper.EndInvoke()
	elseif ( dummy.helper.state == helper_state_outofforce ) then
		--没有内力了，需要恢复
		dummy.helper.state = helper_state_huifu
		command.Run("hp", dummy.helper.NeedRecover)
	end
end

function dummy.helper.NeedRecover()
	me.state.RecoverEndCallback = dummy.helper.HuifuEnd
	me.state.Recover()
end

--帮助结束
function dummy.helper.EndInvoke()
	DeleteTrigger("dummy_fullqi")
	DeleteTrigger("dummy_fullshen")
	DeleteTrigger("dummy_outofforce")
	DeleteTrigger("dummy_actionend")
	dummy.helper.lastmessage = ""
	dummy.helper.HelpEndCallback()
	dummy.helper.HelpEndCallback = dummy.helper.HelpEnd_Inner
end