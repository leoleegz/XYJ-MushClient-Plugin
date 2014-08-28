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

study.study_list = {}		--ѧϰָ����
study.study_index = 0	--��ǰѧϰ������
study.target_max = 0	--Ŀ������/��������
study.target_level = 0	--Ŀ�꼼�ܼ���
study.place = ""		--ѧϰ�ص�


--����������xx��ʼѧϰ
function study.CallFromOuter()
	study.AvoidKilled()
	message.Note("��ʼ����ѧϰģʽ")
	--ֹͣ����ֹ������ʱ����������м��д����򷢴��˳�
	EnableTimer("fadai", false)	
	study.Begin()
end

--����ѧϰ����
function study.Abort()
	message.Note("����ѧϰ")
	study.study_flag.state = study_state_abort
end

--��ָ���ĵص�ѧϰ
function study.BeginAt ( study_place )
	if ( not study_place ) then
		--print("û��ָ��ѧϰ�ص㡣eg: wuzhuang, moon, gao, xajh")
		--return
		study.place = GetVariable("study_place")
	else
		SetVariable("study_place", study_place)
		study.place = study_place
	end
	study.Begin()
end

--���ݱ��������б�����Զ�ѧϰ
function study.Begin()
	local list = GetVariable("study_list")
	local index = GetVariable("study_index")
	--study.place = GetVariable("study_place")

	if ( list and index and list ~= "" and index ~="") then
		--��ȡѧϰ��Ϣ
		study.target_max = tonumber(GetVariable("target_max"))	
		study.target_level = tonumber(GetVariable("target_level"))	
		study.place = GetVariable("study_place")

		study.study_list = utils.split ( list, ";" )
		index = tonumber(index)
		if ( index > 0 and study.study_list[index] ) then
			study.study_index = index
			study.ExecOne ( study.study_list[index] )
		else
			print("ѧϰ��������" .. GetVariable("study_index"))
		end
	else
		print ("����study_list����")
	end
end

--ִ��һ��ѧϰ����
function study.ExecOne( commandstring )
	--�ֽ�ָ���������ѧϰ��
	local action_table = utils.split( commandstring, " " )

	if ( action_table[1] ) then
		study.study_flag.action = action_table[1]
		--print ("ִ��ѧϰָ��" .. commandstring)
		if ( action_table[1] == "dazuo" 
			or action_table[1] == "mingsi" 
			or action_table[1] == "chanting" 
			or action_table[1] == "xiudao" ) then
			--�����dazuo��mingsi����������׶�ѧϰ����
			study.twostage.Execute (action_table[1], commandstring)
		else
			for _,v in ipairs(study.special.support) do
				if ( action_table[1] == v ) then
					study.special.Execute(action_table[1], commandstring)
					return
				end
			end
			--������ʽ����һ�׶�ѧϰ����
			study.onestage.Execute (action_table[1], commandstring)
		end
	else
		message.Note ("ѧϰָ�����" .. commandstring )
		study.NextStudyAction()
	end
end

--����ѧϰָ�����
function study.OnCurrentEnd()
	print ("��ǰѧϰ״̬:" .. study.study_flag.state)
	if ( study.study_flag.state == study_state_abort ) then
		message.Note("����ѧϰ����")
		DoAfterSpecial(3, "study.OnQuitActionEnd()", 12)
	elseif ( study.study_flag.state == study_state_stop) then
		message.Note("ѧϰ����")
		return study.DoQuitAction()
	elseif ( study.study_flag.state == study_state_pause ) then
		-- �ȴ�1���Ӻ����ѧϰ
		return DoAfterSpecial(60, "study.Begin()", 12)
	elseif ( study.study_flag.state == study_state_continue) then
		--������ǰָ��
		return study.Begin()
	elseif ( study.study_flag.state == study_state_skillup) then
		local skill = me.skills.GetSkillByName(study.study_flag.current_skill)
		if ( skill.level >= study.target_level ) then
			--��ǰѧϰ�ļ��ܴﵽĿ�꼼�ܺ󣬼�����һ����ѧϰ
			message.Note ("����[" .. skill.name .. "]�ﵽĿ��ȼ�" .. study.target_level)
			return study.NextStudyAction()
		else
			--return study.Begin()
			--�ָ������ѧϰ
			return command.Run("hp", study.recover.RecoverAll)
		end
	elseif ( study.study_flag.state == study_state_hpup) then
		local level = 0
		local msg = ""
		if ( study.study_flag.action == "dazuo" ) then
			level = me.state.neilimax
			msg = "����"
		else
			level = me.state.falimax
			msg = "����"
		end

		if ( level >= study.target_max ) then
			message.Note (msg .. "���޴ﵽ" .. study.target_max)
			return study.NextStudyAction()
		else
			return study.Begin()
		end
	elseif ( study.study_flag.state == study_state_needrefresh) then
		print("��Ҫ�ָ�����")
		return command.Run("hp", study.recover.JingShen)
	elseif ( study.study_flag.state == study_state_needrecover) then
		print("��Ҫ�ָ���Ѫ")
		return command.Run("hp", study.recover.QiXue)
	elseif ( study.study_flag.state == study_state_needhuifu) then
		print("��Ҫȫ��ָ�")
		return command.Run("hp", study.recover.RecoverAll)
	elseif ( study.study_flag.state == study_state_needneili) then
		print("��Ҫ�ָ�һ������")
		return command.Run("hp", study.recover.NeiLi)
	elseif ( study.study_flag.state == study_state_needfali) then
		print("��Ҫ�ָ�һ�㷨��")
		return command.Run("hp", study.recover.FaLi)
	elseif ( study.study_flag.state ==study_state_needdrop ) then
		--��Ҫ������ǰѧϰ����
		message.Note("������ǰѧϰ����:" .. study.study_list[study.study_index])
		return study.NextStudyAction()
	elseif ( study.study_flag.state == study_state_needfeed ) then
		return study.recover.Feed()
	elseif ( study.study_flag.state == study_state_needpatch) then
		--ִ������ѧϰ����
		return study.patch.BeginInvoke()
	else
		message.Note ("δ�����ѧϰ״̬��������һ��ѧϰָ�" ..  study.study_flag.state)
		return study.NextStudyAction()
	end
end

--������һ�������ѧϰ
function study.NextStudyAction()
	local count = table.getn(study.study_list)
	local index = study.study_index
	if ( index < count ) then
		message.Note("ִ����һ��ѧϰָ��")
		index = index + 1
		SetVariable("study_index", index)
		--ѧϰ֮ǰ�Ƚ���һ�λָ����ָ����Զ���ʼѧϰ
		command.Run("hp", study.recover.RecoverAll)
	else
		message.Note("����ѧϰָ�����")
		study.study_flag.state = study_state_stop
		DoAfterSpecial ( 3, "study.DoQuitAction()", 12 )
	end
end

--ִ���˳�����
function study.DoQuitAction()
	local quit_action = study.places.quit_action[study.place]
	--command.Run(quit_action, study.OnQuitActionEnd)
	
	local i, j = string.find(quit_action, "fly")
	if ( i and i >= 1 ) then
		message.Note ("�ָ����˳�ѧϰģʽ")
		me.state.RecoverEndCallback = study.DoQuitActionAfterRecover
		me.state.Recover()
	else
		message.Note ("�˳�ѧϰģʽ")
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
		message.Note  ("��ִ�����˳�ѧϰģʽ")
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
		message.Note ("�˳�ģʽʧ�ܣ��ȴ�ϵͳ�Զ��˳�")
	end
end

--�򿪼��ӣ����ⱻɱ
function study.AvoidKilled ( )
	monitor.SomeWantKillMeCallback = study.OnByKilling
	EnableTrigger("monitor_mobs", true)
	EnableTrigger ( "warn_mobs", true )
	EnableTrigger ("wrong_place", true )
	EnableTrigger("monitor_qiudong", false)

	--���߾��˳�
	--EnableTimer("keep_conneted", false)
end

--���һ���й���Ҫɱ�ˣ�ֱ���˳�
function study.OnByKilling ( )
	message.Note ( "�����ϣ��˳���", "red" )
	EnableTrigger ( "warn_mobs", false )
	command.RunOnly("#20 (quit)")
end
