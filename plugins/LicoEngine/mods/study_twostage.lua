--Module: study_twostage.lua
--需要两阶段才能完成的学习任务，如dazuo, mingsi


--Module: study_mingsi.lua
--冥思模块

require "tprint"
require "addxml"

study.twostage = {}

study.twostage.patterns = {dazuo={stage1_success="^你坐下来运气用功，一股内息开始在体内流动。$",
							stage1_failed={"^你现在的气太少了，无法产生内息运行全身经脉。$"},
							stage1_failed_result=study_state_needrecover,
							stage2_up="^你的内力增强了！",
							stage2_max="^当你的内力增加的瞬间你忽然觉得浑身一震，似乎内力的提升已经到了瓶颈。$",
							stage2_end="^你行功完毕，吸一口气，缓缓站了起来。$"},
					mingsi={stage1_success="^你盘膝而坐，静坐冥思了一会儿。$",
							stage1_failed={"^你现在神智不清,不能再想入非非了。$"},
							stage1_failed_result=study_state_needrefresh,
							stage2_up="^你的法力增强了！",
							stage2_max="^当你的法力增加的瞬间你忽然觉得脑中一片混乱，似乎法力的提升已经到了瓶颈。$",
							stage2_end="^你行功完毕，从冥思中回过神来。$"},
					chanting={stage1_success="^你席地而坐，双目微闭，口中轻声诵起了经文。$",
							stage1_failed={"^你现在"},  --你现在神智不清
							stage1_failed_result=study_state_needhuifu,
							stage2_up="^道行增加了",  --不需要判断
							stage2_max="^不判断这个",
							stage2_end="^你缓缓睁开眼睛，长舒一口气站了起来。$"},
					xiudao={stage1_success="^你闭上眼睛，盘膝坐下，嘴里默默念念不知在说些什么。$",
						      stage1_failed={"^你现在"},	--你现在神智不清
						      stage1_failed_result=study_state_needhuifu,
						      stage2_up="^道行增加了",	 --不需要判断
						      stage2_max="^不判断这个",
						      stage2_end="^你缓缓睁开眼睛，长舒一口气站了起来。$"}}

function study.twostage.EndCallback_Inner ()
	if ( study.study_flag.state == study_state_hpup ) then
		return command.Run("hp", study.OnCurrentEnd)
	else
		return command.Run("hp", study.twostage.CheckFeed)
	end
end
study.twostage.EndCallback = study.twostage.EndCallback_Inner

--执行学习指令
function study.twostage.Execute ( cmd_action, commandstring )

	if ( cmd_action and study.twostage.patterns[cmd_action] ) then
		study.study_flag.action = cmd_action

		local v = study.twostage.patterns[cmd_action]

		study.study_flag.state = study_state_continue
		command.RunWithConfirm ( commandstring,  study.twostage.OnCommandEnd, 
				v.stage1_success, study.twostage.OnSuccess, 
				v.stage1_failed, study.twostage.OnFailed )
	else
		message.Note ( "学习指令错误：" .. commandstring )
		study.study_flag.state = study_state_needdrop
		return study.twostage.OnCommandEnd ()
	end
end

function study.twostage.OnSuccess ( line, wildcards )
	local v = study.twostage.patterns[study.study_flag.action]

	--添加第二阶段的触发器
	addxml.trigger { name="dm_up", 
					match=v.stage2_up,
					group="Study",
					enabled=true,
					sequence=20,
					script="study.twostage.OnUp",
					regexp="y"}
	addxml.trigger { name="dm_max", 
					match=v.stage2_max,
					group="Study",
					enabled=true,
					sequence=20,
					script="study.twostage.OnMax",
					regexp="y"}
	addxml.trigger { name="dm_end", 
					match=v.stage2_end,
					group="Study",
					enabled=true,
					sequence=20,
					script="study.twostage.OnEnd",
					regexp="y"}
	study.study_flag.state = study_state_pause
end

function study.twostage.OnFailed ( line, wildcards )
	local v = study.twostage.patterns[study.study_flag.action]
	study.study_flag.state = v.stage1_failed_result
end

--第一阶段命令结束
function study.twostage.OnCommandEnd ()
	if ( study.study_flag.state ~= study_state_pause ) then
		--指令没有成功
		study.twostage.EndCallback ()
		study.twostage.EndCallback = study.twostage.EndCallback_Inner
	else
		--指令成功，等待第二阶段结束
		study.study_flag.state = study_state_continue
	end
end

--法力/内力增强了
function study.twostage.OnUp (name, line, wildcards, styles)
	study.study_flag.state = study_state_hpup
end

--法力/内力到达极限
function study.twostage.OnMax (name, line, wildcards, styles)
	study.study_flag.state = study_state_needdrop
	DoAfterSpecial ( 0.5, "study.twostage.CleanAndEnd()", 12 )
end

--冥思/打坐成功结束
function study.twostage.OnEnd (name, line, wildcards, styles)
	DoAfterSpecial ( 0.5, "study.twostage.CleanAndEnd()", 12 )
end

--清除触发器，结束
function study.twostage.CleanAndEnd()
	DeleteTrigger("dm_up")
	DeleteTrigger("dm_max")
	DeleteTrigger("dm_end")
	study.twostage.EndCallback ()
	study.twostage.EndCallback = study.twostage.EndCallback_Inner
end

--检查是否需要补充食物
function study.twostage.CheckFeed()
	if ( me.state.food < 50 or me.state.drink < 50 ) then
		 study.study_flag.state = study_state_needfeed
	end
	DoAfterSpecial(2, "study.OnCurrentEnd()", 12)
end
