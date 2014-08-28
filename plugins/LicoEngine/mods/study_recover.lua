--Module: study_recover.lua

require "tprint"
require "addxml"

study.recover = {}

--exert recover
--你深深吸了几口气，脸色看起来好多了。
--你现在气力充沛，不需吸气。
--你的内力不够。
--( 你上一个动作还没有完成，不能施用内功。)
--exert refresh
--你略一凝神，吸了口气，精神看起来清醒多了。
--你现在精神饱满，不需吸气。
--cast transfer
--你嘴里嘀咕了几句，觉得真气充盈多了。
--你的法力不够了。
--
--sleep
--你刚睡过一觉, 先活动活动吧。 
--这里不是睡觉的地方。
--荡悠悠三更梦 - 
--你揉揉眼睛，醒了过来。
--你一觉醒来，只觉精力充沛。该活动一下了。

function study.recover.CheckIfXunHuan()
	local xunhuan = GetVariable("xunhuan")
	return tonumber(xunhuan) == 1
end

function study.recover.QiXue()
	local xunhuan = study.recover.CheckIfXunHuan()
	if ( not xunhuan ) then
		if ( dummy.mode == 2 ) then	
			--如果有大米，呼叫大米恢复
			dummy.requirer.HelpEndCallback = study.Begin
			dummy.requirer.CallRecover()
		else
			--如果没有达到循环的级别，则等待指定的时间再继续学习
			local wait_time = GetVariable("wait_time")
			print ("等待" .. wait_time .. "秒让气血恢复")
			DoAfterSpecial ( tonumber(wait_time), "study.Begin()", 12 )
		end
	else
		--否则用exert recover和dazuo来恢复
		--me.state.RecoverEndCallback = study.Begin
		--me.state.Recover()

		--试试
		if ( me.state.neili >= 200 ) then
			DoAfterSpecial(1, "study.recover.ExertRecover()", 12)
		else
			me.state.RecoverEndCallback = study.Begin
			me.state.Recover()
		end
	end
end

--使用内力恢复
function study.recover.ExertRecover()
	command.Run("exert recover", function()
					return study.Begin()
				end)
end

function study.recover.JingShen()
	local xunhuan = study.recover.CheckIfXunHuan()

	if ( me.state.neili >= 200 ) then
		DoAfterSpecial(1, "study.recover.ExertRefresh()", 12)
	elseif ( xunhuan ) then
		--否则用exert refresh, exert recover, dazuo来恢复
		me.state.RecoverEndCallback = study.Begin
		DoAfterSpecial(1, "me.state.Recover()", 12)
	elseif ( dummy.mode == 2 ) then
		--如果有大米
		dummy.requirer.HelpEndCallback = study.Begin
		dummy.requirer.CallRefresh()
	else
		--用睡觉来恢复
		DoAfterSpecial(1, "study.recover.GotoSleep()", 12)
	end
end

--使用内力恢复
function study.recover.ExertRefresh()
	command.Run("exert refresh", function()
					return study.Begin()
				end)
end

function study.recover.NeiLi()
	local xunhuan = study.recover.CheckIfXunHuan()
	
	--if ( not xunhuan ) then
		--没达到正循环，则直接dazuo
		--print("to do...")
		
	--else
		me.state.RecoverEndCallback = study.Begin
		me.state.Recover()
	--end
end

function study.recover.FaLi()
	local xunhuan = study.recover.CheckIfXunHuan()
	--if ( not xunhuan ) then
	--else
	--end
end

function study.recover.Feed()
	print("执行补充动作")
	if ( not study.place or study.place == "" ) then
		study.place = GetVariable("study_place")
	end
	local pathes = study.places.feed_action[study.place]
	walk.WalkEndCallback = study.recover.StudyAgain
	walk.WalkPath ( pathes )
end

function study.recover.RecoverAll()
	me.state.RecoverEndCallback = study.Begin
	me.state.Recover()
end

function study.recover.GotoSleep()
	if ( not study.place or study.place == "" ) then
		study.place = GetVariable("study_place")
	end
	print ("去"..study.place.."睡觉")
	local pathes = study.places.execroom_to_restroom[study.place]
	walk.WalkEndCallback = study.recover.ReachRestroom
	walk.WalkPath ( pathes )
end

--到达卧室/睡房
function study.recover.ReachRestroom (object_found, walk_end, state)
	if ( not walk_end ) then
		print ("错误路径")
		return
	end

	--到达卧室
	--添加触发器
	addxml.trigger { name="wake_up", 
				match="^你一觉醒来，只觉精力充沛。该活动一下了。$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WakeUp",
				regexp="y"}
	addxml.trigger { name="wake_up2", 
				match="^你揉揉眼睛，醒了过来。$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WakeUp",
				regexp="y"}
	addxml.trigger { name="need_wait", 
				match="^你刚睡过一觉, 先活动活动吧。\\s?$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.NeedWait",
				regexp="y"}
	addxml.trigger { name="need_wait2", 
				match="^你现在精神太差，一睡倒恐怕就再也醒不过来了。$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.NeedWait",
				regexp="y"}
	addxml.trigger { name="wrong_to_honglou", 
				match="^荡悠悠三更梦\\s\\-\\s$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WrongToHongLou",
				regexp="y"}
	
	command.RunOnly("sleep")
end

--需要等等再去学技能
function study.recover.NeedWait (name, line, wildcards, styles)
	print ("等待30秒后再睡")
	DoAfterSpecial (30, "study.recover.ClearAndGotoExecroom()", 12)
end

--醒来了，继续学习
function study.recover.WakeUp (name, line, wildcards, styles)
	DoAfterSpecial (1, "study.recover.ClearAndGotoExecroom()", 12)
end

--睡觉的时候，进入红楼一梦了
function study.recover.WrongToHongLou (name, line, wildcards, styles)
	message.Note("进入到红楼了")
	walk.WalkPath ( pathes["honglou_skip"] )
end

--清除触发器，然后去练功室继续学习
function study.recover.ClearAndGotoExecroom()
	DeleteTrigger ( "wake_up" )
	DeleteTrigger ( "wake_up2" )
	DeleteTrigger ( "need_wait" )
	DeleteTrigger ( "need_wait2" )
	DeleteTrigger ( "wrong_to_honglou" )

	if ( not study.place or study.place == "" ) then
		study.place = GetVariable("study_place")
	end
	local pathes = study.places.restroom_to_execroom[study.place]
	walk.WalkEndCallback = study.recover.StudyAgain
	walk.WalkPath ( pathes )
end

function study.recover.StudyAgain (object_found, walk_end, state)
	study.Begin()
end
