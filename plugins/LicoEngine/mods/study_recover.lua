--Module: study_recover.lua

require "tprint"
require "addxml"

study.recover = {}

--exert recover
--���������˼���������ɫ�������ö��ˡ�
--�������������棬����������
--�������������
--( ����һ��������û����ɣ�����ʩ���ڹ���)
--exert refresh
--����һ�������˿����������������Ѷ��ˡ�
--�����ھ�����������������
--cast transfer
--�������ֹ��˼��䣬����������ӯ���ˡ�
--��ķ��������ˡ�
--
--sleep
--���˯��һ��, �Ȼ��ɡ� 
--���ﲻ��˯���ĵط���
--������������ - 
--�������۾������˹�����
--��һ��������ֻ���������档�ûһ���ˡ�

function study.recover.CheckIfXunHuan()
	local xunhuan = GetVariable("xunhuan")
	return tonumber(xunhuan) == 1
end

function study.recover.QiXue()
	local xunhuan = study.recover.CheckIfXunHuan()
	if ( not xunhuan ) then
		if ( dummy.mode == 2 ) then	
			--����д��ף����д��׻ָ�
			dummy.requirer.HelpEndCallback = study.Begin
			dummy.requirer.CallRecover()
		else
			--���û�дﵽѭ���ļ�����ȴ�ָ����ʱ���ټ���ѧϰ
			local wait_time = GetVariable("wait_time")
			print ("�ȴ�" .. wait_time .. "������Ѫ�ָ�")
			DoAfterSpecial ( tonumber(wait_time), "study.Begin()", 12 )
		end
	else
		--������exert recover��dazuo���ָ�
		--me.state.RecoverEndCallback = study.Begin
		--me.state.Recover()

		--����
		if ( me.state.neili >= 200 ) then
			DoAfterSpecial(1, "study.recover.ExertRecover()", 12)
		else
			me.state.RecoverEndCallback = study.Begin
			me.state.Recover()
		end
	end
end

--ʹ�������ָ�
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
		--������exert refresh, exert recover, dazuo���ָ�
		me.state.RecoverEndCallback = study.Begin
		DoAfterSpecial(1, "me.state.Recover()", 12)
	elseif ( dummy.mode == 2 ) then
		--����д���
		dummy.requirer.HelpEndCallback = study.Begin
		dummy.requirer.CallRefresh()
	else
		--��˯�����ָ�
		DoAfterSpecial(1, "study.recover.GotoSleep()", 12)
	end
end

--ʹ�������ָ�
function study.recover.ExertRefresh()
	command.Run("exert refresh", function()
					return study.Begin()
				end)
end

function study.recover.NeiLi()
	local xunhuan = study.recover.CheckIfXunHuan()
	
	--if ( not xunhuan ) then
		--û�ﵽ��ѭ������ֱ��dazuo
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
	print("ִ�в��䶯��")
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
	print ("ȥ"..study.place.."˯��")
	local pathes = study.places.execroom_to_restroom[study.place]
	walk.WalkEndCallback = study.recover.ReachRestroom
	walk.WalkPath ( pathes )
end

--��������/˯��
function study.recover.ReachRestroom (object_found, walk_end, state)
	if ( not walk_end ) then
		print ("����·��")
		return
	end

	--��������
	--��Ӵ�����
	addxml.trigger { name="wake_up", 
				match="^��һ��������ֻ���������档�ûһ���ˡ�$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WakeUp",
				regexp="y"}
	addxml.trigger { name="wake_up2", 
				match="^�������۾������˹�����$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WakeUp",
				regexp="y"}
	addxml.trigger { name="need_wait", 
				match="^���˯��һ��, �Ȼ��ɡ�\\s?$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.NeedWait",
				regexp="y"}
	addxml.trigger { name="need_wait2", 
				match="^�����ھ���̫�һ˯�����¾���Ҳ�Ѳ������ˡ�$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.NeedWait",
				regexp="y"}
	addxml.trigger { name="wrong_to_honglou", 
				match="^������������\\s\\-\\s$",
				group="Study",
				enabled=true,
				sequence=50,
				script="study.recover.WrongToHongLou",
				regexp="y"}
	
	command.RunOnly("sleep")
end

--��Ҫ�ȵ���ȥѧ����
function study.recover.NeedWait (name, line, wildcards, styles)
	print ("�ȴ�30�����˯")
	DoAfterSpecial (30, "study.recover.ClearAndGotoExecroom()", 12)
end

--�����ˣ�����ѧϰ
function study.recover.WakeUp (name, line, wildcards, styles)
	DoAfterSpecial (1, "study.recover.ClearAndGotoExecroom()", 12)
end

--˯����ʱ�򣬽����¥һ����
function study.recover.WrongToHongLou (name, line, wildcards, styles)
	message.Note("���뵽��¥��")
	walk.WalkPath ( pathes["honglou_skip"] )
end

--�����������Ȼ��ȥ�����Ҽ���ѧϰ
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
