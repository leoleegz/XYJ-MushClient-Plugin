--Module: study.lua

study = {}

study_state_stop = 0
study_state_continue = 1
study_state_skillup=2
study_state_hpup= 3
study_state_pause = 4
study_state_needrefresh = 5
study_state_needrecover = 6
study_state_needhuifu = 7
study_state_needneili=8
study_state_needfali=9
study_state_needdrop = 10
study_state_needfeed=11
study_state_needpatch=12
study_state_abort = 13

study.study_flag = {action="", state=study_state_stop,
			current_skill=""}

study.study_list = {}		--学习指令表格
study.study_index = 0	--当前学习的索引
study.target_max = 0	--目标内力/法力上限
study.target_level = 0	--目标技能级别
study.place = ""		--学习地点


--从命令输入xx开始学习
function study.CallFromOuter()
	study.AvoidKilled()
	message.Note("开始进入学习模式")
	--停止“防止发呆计时器”，如果中间有错误，则发呆退出
	EnableTimer("fadai", false)	
	study.Begin()
end

--放弃学习任务
function study.Abort()
	message.Note("放弃学习")
	study.study_flag.state = study_state_abort
end

--在指定的地点学习
function study.BeginAt ( study_place )
	if ( not study_place ) then
		--print("没有指定学习地点。eg: wuzhuang, moon, gao, xajh")
		--return
		study.place = GetVariable("study_place")
	else
		SetVariable("study_place", study_place)
		study.place = study_place
	end
	study.Begin()
end

--根据变量配置列表进行自动学习
function study.Begin()
	local list = GetVariable("study_list")
	local index = GetVariable("study_index")
	--study.place = GetVariable("study_place")

	if ( list and index and list ~= "" and index ~="") then
		--获取学习信息
		study.target_max = tonumber(GetVariable("target_max"))	
		study.target_level = tonumber(GetVariable("target_level"))	
		study.place = GetVariable("study_place")

		study.study_list = utils.split ( list, ";" )
		index = tonumber(index)
		if ( index > 0 and study.study_list[index] ) then
			study.study_index = index
			study.ExecOne ( study.study_list[index] )
		else
			print("学习索引错误：" .. GetVariable("study_index"))
		end
	else
		print ("变量study_list错误")
	end
end

--执行一项学习任务
function study.ExecOne( commandstring )
	--分解指令，获得是如何学习的
	local action_table = utils.split( commandstring, " " )

	if ( action_table[1] ) then
		study.study_flag.action = action_table[1]
		--print ("执行学习指令" .. commandstring)
		if ( action_table[1] == "dazuo" 
			or action_table[1] == "mingsi" 
			or action_table[1] == "chanting" 
			or action_table[1] == "xiudao" ) then
			--如果是dazuo或mingsi，则调用两阶段学习处理
			study.twostage.Execute (action_table[1], commandstring)
		else
			for _,v in ipairs(study.special.support) do
				if ( action_table[1] == v ) then
					study.special.Execute(action_table[1], commandstring)
					return
				end
			end
			--其他方式调用一阶段学习处理
			study.onestage.Execute (action_table[1], commandstring)
		end
	else
		message.Note ("学习指令错误：" .. commandstring )
		study.NextStudyAction()
	end
end

--单条学习指令结束
function study.OnCurrentEnd()
	print ("当前学习状态:" .. study.study_flag.state)
	if ( study.study_flag.state == study_state_abort ) then
		message.Note("放弃学习任务")
		DoAfterSpecial(3, "study.OnQuitActionEnd()", 12)
	elseif ( study.study_flag.state == study_state_stop) then
		message.Note("学习结束")
		return study.DoQuitAction()
	elseif ( study.study_flag.state == study_state_pause ) then
		-- 等待1分钟后继续学习
		return DoAfterSpecial(60, "study.Begin()", 12)
	elseif ( study.study_flag.state == study_state_continue) then
		--继续当前指令
		return study.Begin()
	elseif ( study.study_flag.state == study_state_skillup) then
		local skill = me.skills.GetSkillByName(study.study_flag.current_skill)
		if ( skill.level >= study.target_level ) then
			--当前学习的技能达到目标技能后，继续下一条的学习
			message.Note ("技能[" .. skill.name .. "]达到目标等级" .. study.target_level)
			return study.NextStudyAction()
		else
			--return study.Begin()
			--恢复后继续学习
			return command.Run("hp", study.recover.RecoverAll)
		end
	elseif ( study.study_flag.state == study_state_hpup) then
		local level = 0
		local msg = ""
		if ( study.study_flag.action == "dazuo" ) then
			level = me.state.neilimax
			msg = "内力"
		else
			level = me.state.falimax
			msg = "法力"
		end

		if ( level >= study.target_max ) then
			message.Note (msg .. "上限达到" .. study.target_max)
			return study.NextStudyAction()
		else
			return study.Begin()
		end
	elseif ( study.study_flag.state == study_state_needrefresh) then
		print("需要恢复精神")
		return command.Run("hp", study.recover.JingShen)
	elseif ( study.study_flag.state == study_state_needrecover) then
		print("需要恢复气血")
		return command.Run("hp", study.recover.QiXue)
	elseif ( study.study_flag.state == study_state_needhuifu) then
		print("需要全面恢复")
		return command.Run("hp", study.recover.RecoverAll)
	elseif ( study.study_flag.state == study_state_needneili) then
		print("需要恢复一点内力")
		return command.Run("hp", study.recover.NeiLi)
	elseif ( study.study_flag.state == study_state_needfali) then
		print("需要恢复一点法力")
		return command.Run("hp", study.recover.FaLi)
	elseif ( study.study_flag.state ==study_state_needdrop ) then
		--需要跳过当前学习任务
		message.Note("跳过当前学习任务:" .. study.study_list[study.study_index])
		return study.NextStudyAction()
	elseif ( study.study_flag.state == study_state_needfeed ) then
		return study.recover.Feed()
	elseif ( study.study_flag.state == study_state_needpatch) then
		--执行特殊学习补丁
		return study.patch.BeginInvoke()
	else
		message.Note ("未处理的学习状态，继续下一条学习指令：" ..  study.study_flag.state)
		return study.NextStudyAction()
	end
end

--进行下一个主题的学习
function study.NextStudyAction()
	local count = table.getn(study.study_list)
	local index = study.study_index
	if ( index < count ) then
		message.Note("执行下一条学习指令")
		index = index + 1
		SetVariable("study_index", index)
		--学习之前先进行一次恢复，恢复完自动开始学习
		command.Run("hp", study.recover.RecoverAll)
	else
		message.Note("所有学习指令结束")
		study.study_flag.state = study_state_stop
		DoAfterSpecial ( 3, "study.DoQuitAction()", 12 )
	end
end

--执行退出命令
function study.DoQuitAction()
	local quit_action = study.places.quit_action[study.place]
	--command.Run(quit_action, study.OnQuitActionEnd)
	
	local i, j = string.find(quit_action, "fly")
	if ( i and i >= 1 ) then
		message.Note ("恢复后退出学习模式")
		me.state.RecoverEndCallback = study.DoQuitActionAfterRecover
		me.state.Recover()
	else
		message.Note ("退出学习模式")
		walk.WalkEndCallback = study.OnQuitActionEnd
		walk.WalkPath ( quit_action ) 
	end
end

function study.DoQuitActionAfterRecover()
	local quit_action = study.places.quit_action[study.place]
	--command.Run(quit_action, study.OnQuitActionEnd)
	walk.WalkEndCallback = study.OnQuitActionEnd
	walk.WalkPath ( quit_action ) 
end

function study.OnQuitActionEnd(object_found, walk_end, state)
	if ( walk_end ) then
		message.Note  ("已执行完退出学习模式")
		EnableTimer ("fadai", true)
		--EnableTimer("keep_conneted", true)

		EnableTrigger("monitor_mobs", false)
		EnableTrigger ( "warn_mobs", false )
		EnableTrigger ("wrong_place", false )
		EnableTrigger("monitor_qiudong", false)
	else
		EnableTimer ("fadai", false)
		EnableTrigger("monitor_mobs", true)
		EnableTrigger ( "warn_mobs", true )
		EnableTrigger ("wrong_place", false )
		EnableTrigger("monitor_qiudong", true)
		message.Note ("退出模式失败，等待系统自动退出")
	end
end

--打开监视，避免被杀
function study.AvoidKilled ( )
	monitor.SomeWantKillMeCallback = study.OnByKilling
	EnableTrigger("monitor_mobs", true)
	EnableTrigger ( "warn_mobs", true )
	EnableTrigger ("wrong_place", true )
	EnableTrigger("monitor_qiudong", false)

	--断线就退出
	--EnableTimer("keep_conneted", false)
end

--如果一旦有怪物要杀人，直接退出
function study.OnByKilling ( )
	message.Note ( "被盯上，退出吧", "red" )
	EnableTrigger ( "warn_mobs", false )
	command.RunOnly("#20 (quit)")
end
