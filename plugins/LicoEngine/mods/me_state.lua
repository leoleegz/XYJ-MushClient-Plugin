-- Module "char_info"
-- 用于记录角色的状态、金钱、技能等信息
-- 作者： Li Ying
-- 日期： 2010/12/21

require "serialize"
require "tprint"
require "addxml"

--hp:气血  mp:精神  neili:内力  fali:法力  food:食物  drink:饮水  
--wuxue:武学 daoxing:道行  qn:潜能  shaqi:杀气
--dxjj:道行境界 wxjj:武学境界  flxw:法力修为  nlxw:内力修为
me.state = {hp=0,hpmax=0,hprate=0,mp=0,mpmax=0,mprate=0,
	neili=0,neilimax=0,fali=0,falimax=0,
	food=0,foodmax=0,drink=0,drinkmax=0,
	wuxue=0,daoxing=0,qn=0,shaqi=0,
	dxjj="",wxjj="",flxw="",nlxw=""}

--获取状态结束回调函数，其他模块可以更改此值来进行回调操作
function me.state.GetHpEndCallback_Inner()
	--print("hp输出结束")
end
me.state.GetHpEndCallback = me.state.GetHpEndCallback_Inner

--获取Score结束回调函数，其他模块可以更改此值来进行回调操作
function me.state.GetScoreEndCallback_Inner()
	--print("score输出结束")
end
me.state.GetScoreEndCallback = me.state.GetScoreEndCallback_Inner

--状态恢复回调函数
function me.state.RecoverEndCallback_Inner()
	print("恢复完毕")
end
me.state.RecoverEndCallback = me.state.RecoverEndCallback_Inner

local status_win_plugin_id = "02a068ee44c6e2a9ba0df18c"

--HP指令输出的第一行
function me.state.HPLine1 (name, line, wildcards, styles)
	--record data
	me.state.hp = tonumber(wildcards["hp"])
	me.state.hpmax = tonumber(wildcards["hpmax"])
	me.state.hprate = tonumber(wildcards["hprate"])
	me.state.neili = tonumber(wildcards["neili"])
	me.state.neilimax = tonumber(wildcards["neilimax"])
	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusClear")
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HP指令输出的第二行
function me.state.HPLine2 (name, line, wildcards, styles)
	--record data
	me.state.mp = tonumber(wildcards["mp"])
	me.state.mpmax = tonumber(wildcards["mpmax"])
	me.state.mprate = tonumber(wildcards["mprate"])
	me.state.fali = tonumber(wildcards["fali"])
	me.state.falimax = tonumber(wildcards["falimax"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HP指令输出的第三行
function me.state.HPLine3 (name, line, wildcards, styles)
	--record data
	me.state.food = tonumber(wildcards["food"])
	me.state.foodmax = tonumber(wildcards["foodmax"])
	me.state.wuxue = tonumber(wildcards["wuxue"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HP指令输出的第四行
function me.state.HPLine4 (name, line, wildcards, styles)
	--record data
	me.state.drink = tonumber(wildcards["drink"])
	me.state.drinkmax = tonumber(wildcards["drinkmax"])
	me.state.daoxing = wildcards["daoxing"]

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HP指令输出的第五行
function me.state.HPLine5 (name, line, wildcards, styles)
	--record data
	me.state.qn = tonumber(wildcards["qn"])
	me.state.shaqi = tonumber(wildcards["shaqi"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
	CallPlugin (status_win_plugin_id, "StatusRefresh")

	--设置输出结束回调
	--SetTriggerOption("output_end", "script", "me.state.HpOutputEnd")
	--EnableTrigger("output_end", true)
	command.RegisterCmdEndCallback( me.state.OnHpOutputEnd )
end -- HPLine1

function me.state.OnHpOutputEnd ()
	me.state.GetHpEndCallback()
	me.state.GetHpEndCallback = me.state.GetHpEndCallback_Inner
end --OnHpOutputEnd

--Score指令输出的内容1
function me.state.ScoreLine1 (name, line, wildcards, styles)
	me.state.dxjj = wildcards["dxjj"]
	me.state.wxjj = wildcards["wxjj"]

	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end --ScoreLine1

--Score指令输出的内容2
function me.state.ScoreLine2 (name, line, wildcards, styles)
	--record data
	me.state.flxw = wildcards["flxw"]
	me.state.nlxw = wildcards["nlxw"]

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
	CallPlugin (status_win_plugin_id, "StatusRefresh")

	--设置输出结束回调
	--SetTriggerOption("output_end", "script", "me.state.ScoreOutputEnd")
	--EnableTrigger("output_end", true)
	command.RegisterCmdEndCallback( me.state.OnScoreOutputEnd )
end -- ScoreLine2

function me.state.OnScoreOutputEnd (name, line, wildcards, styles)
	me.state.GetScoreEndCallback()
	me.state.GetScoreEndCallback = me.state.GetScoreEndCallback_Inner
end --OnScoreOutputEnd

--你得到了XX道行。
function me.state.GetDx (name, line, wildcards, styles)
	message.Note("获得" .. wildcards["dx"] .. "道行")
end

me.state.recover_stage = ""

--通过dazuo,mingsi 恢复气血、内力、精神、法力，需要在hp指令后执行
function me.state.Recover()
	me.state.recover_stage = ""
	if ( me.state.hp < me.state.hpmax - 5 ) then
		--气血不够
		if ( me.state.neili >= 50 or dummy.mode == 2) then
			--如果还有内力或有大米，那么先回复气血
			return me.state.ExertRecover()
		elseif ( me.state.hp < 50 ) then
			--如果气血也不足，那么需要等待一段时间再恢复
			local wait_time = GetVariable("wait_time")
			print("气血、内力都较低，等待" .. wait_time .. "秒再恢复")
			return DoAfterSpecial ( tonumber(wait_time), "me.state.Recover()", 12 )
		else
			return me.state.Dazuo()
		end
	elseif ( me.state.neili < me.state.neilimax - 10 ) then
		--内力不够满，打坐来恢复内力
		return me.state.Dazuo()
	elseif ( me.state.hprate < 98 ) then
		--受伤了，需要补足上限
		return command.Run("exert heal", me.state.OnExertHealEnd)
	elseif ( me.state.mp < me.state.mpmax - 5 ) then
		--精神不够，通过exert refresh来恢复精神
		return me.state.ExertRefresh()
	elseif ( me.state.fali < me.state.falimax - 10 ) then
		--法力不够，通过mingsi来恢复法力
		return me.state.MingSi()
	else
		--状态全满
		return me.state.OnRecoverEnd()
	end
end

function me.state.Dazuo()
	--计算需要打坐多少
	local ratio = tonumber( GetVariable("neili_ratio") ) or 1

	addxml.trigger { name="dazuo_end", 
				match="^你行功完毕，吸一口气，缓缓站了起来。$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnDazuoEnd",
				regexp="y"}
	
	addxml.trigger { name="dazuo_neiliup", 
				match="^你的内力增强了！$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnNeiliUp",
				regexp="y"}

	addxml.trigger { name="dazuo_max", 
				match="^当你的内力增加的瞬间你忽然觉得浑身一震，似乎内力的提升已经到了瓶颈。$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnDazuoEnd",
				regexp="y"}
	
	local pt = (me.state.neilimax * 2 - 50 - me.state.neili) / ratio
	if ( pt < 20 ) then
		-- 打坐最少为20点
		pt = 20
	end
	if ( pt > me.state.hp - 1 ) then
		pt = me.state.hp - 1
	else
		pt = math.floor( pt )
	end

	me.state.recover_stage = "dazuo"
	command.RunOnly ("dazuo " .. pt)
end

--内力居然增加了，说明系数需要调整
function me.state.OnNeiliUp (name, line, wildcards, styles)
	local ratio = tonumber( GetVariable("neili_ratio") ) or 1
	ratio = ratio + 0.1
	SetVariable("neili_ratio", tostring(ratio))
end

--打坐结束
function me.state.OnDazuoEnd (name, line, wildcards, styles)
	--3秒之后再恢复气血
	DoAfterSpecial ( 3, "me.state.ExertRecover()", 12 )
end

--用内力恢复气血
function me.state.ExertRecover()
	DeleteTrigger("dazuo_end")
	DeleteTrigger("dazuo_neiliup")
	DeleteTrigger("dazuo_max")

	if ( dummy.mode == 2 ) then		--如果是求助于大米，那么通过大米恢复气血
		dummy.requirer.HelpEndCallback = me.state.OnExertRecoverEnd
		dummy.requirer.CallRecover()
	else
		command.Run("exert recover", me.state.OnExertRecoverEnd)
	end
end

function me.state.OnExertRecoverEnd()
	command.Run("hp", me.state.Recover)
end

function me.state.OnExertHealEnd()
	command.Run("hp", me.state.Recover)
end

--通过exert refresh恢复精神
function me.state.ExertRefresh()
	DeleteTrigger("mingsi_end")
	DeleteTrigger("mingsi_faliup")
	DeleteTrigger("mingsi_max")

	if ( dummy.mode == 2 ) then		--如果是求助于大米，那么通过大米恢复精神
		dummy.requirer.HelpEndCallback = me.state.OnExertRefreshEnd
		dummy.requirer.CallRefresh()
	else
		command.Run("exert refresh", me.state.OnExertRefreshEnd)
	end
end

function me.state.OnExertRefreshEnd()
	command.Run("hp", me.state.Recover)
end

function me.state.MingSi()
	--计算需要冥思多少
	local ratio = tonumber( GetVariable("fali_ratio") ) or 1

	addxml.trigger { name="mingsi_end", 
				match="^你行功完毕，从冥思中回过神来。$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnMingSiEnd",
				regexp="y"}

	addxml.trigger { name="mingsi_faliup", 
				match="^你的法力增强了！$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnFaliUp",
				regexp="y"}

	addxml.trigger { name="mingsi_max", 
				match="^当你的法力增加的瞬间你忽然觉得脑中一片混乱，似乎法力的提升已经到了瓶颈。$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnMingSiEnd",
				regexp="y"}
	
	--local pt = (me.state.falimax * 2 -50 - me.state.fali) / ratio
	local pt = (me.state.falimax + 100 - me.state.fali) / ratio
	if ( pt < 20 ) then
		-- 冥思最少为20点
		pt = 20
	end
	if ( pt > me.state.mp - 1 ) then
		pt = me.state.mp - 1
	else
		pt = math.floor( pt )
	end

	me.state.recover_stage = "mingsi"
	command.RunOnly ("mingsi " .. pt)
end

--法力居然增加了，说明系数需要调整
function me.state.OnFaliUp (name, line, wildcards, styles)
	local ratio = tonumber( GetVariable("fali_ratio") ) or 1
	--if ( ratio < 1 ) then
	--	ratio = 1
	--end
	ratio = ratio + 0.1
	SetVariable("fali_ratio", tostring(ratio))
end

--冥思结束
function me.state.OnMingSiEnd (name, line, wildcards, styles)
	--3秒之后再恢复气血
	DoAfterSpecial ( 3, "me.state.ExertRefresh()", 12 )
end

--恢复结束，设置enforce等
--Ok.
function me.state.OnRecoverEnd()
	addxml.trigger { name="jiali_end", 
				match="^Ok.$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnEnforceEnd",
				regexp="y"}

	local jiali = tonumber(GetVariable("jiali"))
	return command.RunOnly("jiali " .. jiali)
end

function me.state.OnEnforceEnd (name, line, wildcards, styles)
	EnableTrigger("jiali_end", false)
	addxml.trigger { name="enchant_end", 
				match="^Ok.$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnEnchantEnd",
				regexp="y"}

	local enchant = tonumber(GetVariable("enchant"))
	return command.RunOnly("enchant " .. enchant)
end

function me.state.OnEnchantEnd (name, line, wildcards, styles)
	EnableTrigger("enchant_end", false)
	DoAfterSpecial(0.5, "me.state.AllEnd()", 12)
end

function me.state.AllEnd()
	DeleteTrigger("jiali_end")
	DeleteTrigger("enchant_end")
	me.state.RecoverEndCallback()
	me.state.RecoverEndCallback = me.state.RecoverEndCallback_Inner
end


--停止恢复
function me.state.StopRecover()
	if ( me.state.recover_stage == "dazuo" ) then
		DeleteTrigger("dazuo_end")
		DeleteTrigger("dazuo_neiliup")
		DeleteTrigger("dazuo_max")
		command.RunOnly ("dazuo 0")
	end
	if ( me.state.recover_stage == "mingsi" ) then
		DeleteTrigger("mingsi_end")
		DeleteTrigger("mingsi_faliup")
		DeleteTrigger("mingsi_max")
		command.RunOnly ("mingsi 0")
	end
end