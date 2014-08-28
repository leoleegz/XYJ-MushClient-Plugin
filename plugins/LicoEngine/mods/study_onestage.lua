--Module: study_onestage.lua
--只需要一个命令阶段即可完成学习任务的模块，如xue/learn, du/read, lian/practice

require "tprint"

study.onestage = {}

--xue/learn
--你的「镇元神功」进步了！
--你听了韩湘子的指导，似乎有些心得。
--你今天太累了，结果什么也没有学到。
--你的潜能已经发挥到极限了，没有办法再成长了。
--你的法术修为还不够高深，无法学习太乙仙法。
--du/read
--你研读有关基本剑术的技巧，似乎有点心得。
--你现在过于疲倦，无法专心下来研读新知。
--你研读了一会儿，但是发现上面所说的对你而言都太浅了，没有学到任何东西。
--你的法术修为还不够高深，无法学习太乙仙法。
--千手经：你无法从这样东西学到任何东西。		最高50级
--千手经：你现在头晕脑胀，该休息休息了。
--千手经：你在【千手】方面已经很有造诣，这本书不会让你长进多少。
--lian/practice
--你的八卦阵法进步了！
--你现在脚下虚浮，先休息一阵吧。
--你现在内力不够，难以继续练下去了。
--你默默回忆了一会儿，然后练了一遍晓风残月剑。
--你的晓风残月剑进步了！
--你体质欠佳，强练晓风残月风剑有害无益。
--你内力不足，强练晓风残月风剑有走火入魔的危险。
--你的内力或气不够，没有办法练习风回雪舞剑法。
--你必须先找一柄长剑才能练习剑法。
--千手经：你现在手足酸软，休息一下再练吧。
--你的精神太差了，不能练冷月凝香舞。
--lianxi
--你神智不清，再练下去会有危险的！
--chat 448qn80for23
study.onestage.patterns = { xue={{failed="^你今天太累了，结果什么也没有学到。$", result=study_state_needrefresh},
							{failed="^你的潜能已经发挥到极限了，没有办法再成长了。$", result=study_state_needdrop},
							{failed="^你的法术修为还不够高深", result=study_state_needdrop},
							{failed="^你必须先找",  result=study_state_needdrop},
							{failed="^你要向谁求教？$", result=study_state_needdrop}},
						du={{failed="^你现在过于疲倦，无法专心下来研读新知。$", result=study_state_needrefresh},
						        {failed="^你研读了一会儿，但是发现上面所说的对你而言都太浅了，没有学到任何东西。$", result=study_state_needdrop},
							{failed="^你的法术修为还不够高深，无法学习", result=study_state_needdrop},
							--{failed="^你无法从这样东西学到任何东西。$", result=study_state_needrefresh},
							{failed="^你现在头晕脑胀，该休息休息了。$", result=study_state_needrefresh},
							{failed="^你在【千手】方面已经很有造诣，这本书不会让你长进多少。$", result=study_state_needdrop}},
						lian={{failed="^你现在脚下虚浮，先休息一阵吧。$", result=study_state_needrecover},
							{failed="^你现在内力不够，难以继续练下去了。$", result=study_state_needneili},
							{failed="^你体质欠佳，强练", result=study_state_needrecover},
							{failed="^你的内力或气不够", result=study_state_needrecover},
							{failed="^你内力不足，强练", result=study_state_needneili},
							{failed="^你必须先找", result=study_state_needdrop},
							{failed="^你的内力不够了。$", result=study_state_needneili},
							{failed="^你现在手足酸软，休息一下再练吧。$", result=study_state_needrecover},
							{failed="^你的气太低，再练下去太危险了！$", result=study_state_needrecover},
							{failed="^你的精神太差了", result=study_state_needrefresh}},
						lianxi={{failed="^你神智不清，再练下去会有危险的！$", result=study_state_needrefresh},
							{failed="^你昏昏地睡了过去。$", result=study_state_needpatch},
							{failed="^什么？$", result=study_state_needpatch},
							{failed="^你的法力不足，难以领会高深的妖法。$", result=study_state_needrecover}},
						dupoem={{failed="^你无法从这样东西学到任何东西。$", result=study_state_needrefresh}},
						duxueshu={{failed="^你研读了一会儿，但是发现上面所说的对你而言都太浅了，没有学到任何东西。$", result=study_state_needdrop},
						        {failed="^你现在过于疲倦，无法专心下来研读新知。$", result=study_state_needrefresh},
							{failed="^你要读什么？$", result=study_state_needpatch}}}

function study.onestage.EndCallback_Inner()
	if ( study.study_flag.state == study_state_skillup ) then
		--如果技能升级了，那么运行skills指令
		command.Run("skills", study.OnCurrentEnd)
	else
		DoAfterSpecial(0.1, "study.OnCurrentEnd()", 12)
	end
end
study.onestage.EndCallback = study.onestage.EndCallback_Inner

function study.onestage.Execute ( cmd_action, commandstring )
	local successpattern = "^你的「(?P<skill_name>\\S+)」进步了！$"
	local failedpatterns = {}

	if ( cmd_action and study.onestage.patterns[cmd_action] ) then
		study.study_flag.action = cmd_action

		--遍历学习列表，填充失败的触发器
		for _, v in ipairs( study.onestage.patterns[cmd_action] ) do
			--print ( "insert failed pattern:" .. v.failed )
			if ( v and v.failed ) then
				table.insert( failedpatterns, v.failed )
			end
		end
		
		study.study_flag.state = study_state_continue
		command.RunWithConfirm ( commandstring, study.onestage.OnEnd, 
				successpattern, study.onestage.OnSuccess, 
				failedpatterns, study.onestage.OnFailed )
	else
		message.Note ( "学习指令错误：" .. commandstring )
		study.study_flag.state = study_state_needdrop
		study.onestage.OnEnd ()
	end
end

function study.onestage.OnSuccess (line, wildcards)
	study.study_flag.state = study_state_skillup
	study.study_flag.current_skill = wildcards["skill_name"]
end

function study.onestage.OnFailed (line, wildcards)
	local cmd_action = 	study.study_flag.action
	--查找失败的匹配串，确定状态结果
	for _, v in ipairs( study.onestage.patterns[cmd_action] ) do
		local i, j = string.find ( line, v.failed )

		if ( i and i >= 1 and study.study_flag.state == study_state_continue) then
			study.study_flag.state  = v.result
			break
		end
	end
end

function study.onestage.OnEnd ()
	DoAfterSpecial(0.1, "study.onestage.OnRealEnd()", 12)
end

function study.onestage.OnRealEnd()
	study.onestage.EndCallback ()
	study.onestage.EndCallback = study.onestage.EndCallback_Inner
end
