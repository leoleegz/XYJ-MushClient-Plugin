--Module: study_twostage.lua
--��Ҫ���׶β�����ɵ�ѧϰ������dazuo, mingsi


--Module: study_mingsi.lua
--ڤ˼ģ��

require "tprint"
require "addxml"

study.twostage = {}

study.twostage.patterns = {dazuo={stage1_success="^�������������ù���һ����Ϣ��ʼ������������$",
							stage1_failed={"^�����ڵ���̫���ˣ��޷�������Ϣ����ȫ������$"},
							stage1_failed_result=study_state_needrecover,
							stage2_up="^���������ǿ�ˣ�",
							stage2_max="^������������ӵ�˲�����Ȼ���û���һ���ƺ������������Ѿ�����ƿ����$",
							stage2_end="^���й���ϣ���һ����������վ��������$"},
					mingsi={stage1_success="^����ϥ����������ڤ˼��һ�����$",
							stage1_failed={"^���������ǲ���,����������Ƿ��ˡ�$"},
							stage1_failed_result=study_state_needrefresh,
							stage2_up="^��ķ�����ǿ�ˣ�",
							stage2_max="^����ķ������ӵ�˲�����Ȼ��������һƬ���ң��ƺ������������Ѿ�����ƿ����$",
							stage2_end="^���й���ϣ���ڤ˼�лع�������$"},
					chanting={stage1_success="^��ϯ�ض�����˫Ŀ΢�գ��������������˾��ġ�$",
							stage1_failed={"^������"},  --���������ǲ���
							stage1_failed_result=study_state_needhuifu,
							stage2_up="^����������",  --����Ҫ�ж�
							stage2_max="^���ж����",
							stage2_end="^�㻺�������۾�������һ����վ��������$"},
					xiudao={stage1_success="^������۾�����ϥ���£�����ĬĬ���֪��˵Щʲô��$",
						      stage1_failed={"^������"},	--���������ǲ���
						      stage1_failed_result=study_state_needhuifu,
						      stage2_up="^����������",	 --����Ҫ�ж�
						      stage2_max="^���ж����",
						      stage2_end="^�㻺�������۾�������һ����վ��������$"}}

function study.twostage.EndCallback_Inner ()
	if ( study.study_flag.state == study_state_hpup ) then
		return command.Run("hp", study.OnCurrentEnd)
	else
		return command.Run("hp", study.twostage.CheckFeed)
	end
end
study.twostage.EndCallback = study.twostage.EndCallback_Inner

--ִ��ѧϰָ��
function study.twostage.Execute ( cmd_action, commandstring )

	if ( cmd_action and study.twostage.patterns[cmd_action] ) then
		study.study_flag.action = cmd_action

		local v = study.twostage.patterns[cmd_action]

		study.study_flag.state = study_state_continue
		command.RunWithConfirm ( commandstring,  study.twostage.OnCommandEnd, 
				v.stage1_success, study.twostage.OnSuccess, 
				v.stage1_failed, study.twostage.OnFailed )
	else
		message.Note ( "ѧϰָ�����" .. commandstring )
		study.study_flag.state = study_state_needdrop
		return study.twostage.OnCommandEnd ()
	end
end

function study.twostage.OnSuccess ( line, wildcards )
	local v = study.twostage.patterns[study.study_flag.action]

	--��ӵڶ��׶εĴ�����
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

--��һ�׶��������
function study.twostage.OnCommandEnd ()
	if ( study.study_flag.state ~= study_state_pause ) then
		--ָ��û�гɹ�
		study.twostage.EndCallback ()
		study.twostage.EndCallback = study.twostage.EndCallback_Inner
	else
		--ָ��ɹ����ȴ��ڶ��׶ν���
		study.study_flag.state = study_state_continue
	end
end

--����/������ǿ��
function study.twostage.OnUp (name, line, wildcards, styles)
	study.study_flag.state = study_state_hpup
end

--����/�������Ｋ��
function study.twostage.OnMax (name, line, wildcards, styles)
	study.study_flag.state = study_state_needdrop
	DoAfterSpecial ( 0.5, "study.twostage.CleanAndEnd()", 12 )
end

--ڤ˼/�����ɹ�����
function study.twostage.OnEnd (name, line, wildcards, styles)
	DoAfterSpecial ( 0.5, "study.twostage.CleanAndEnd()", 12 )
end

--���������������
function study.twostage.CleanAndEnd()
	DeleteTrigger("dm_up")
	DeleteTrigger("dm_max")
	DeleteTrigger("dm_end")
	study.twostage.EndCallback ()
	study.twostage.EndCallback = study.twostage.EndCallback_Inner
end

--����Ƿ���Ҫ����ʳ��
function study.twostage.CheckFeed()
	if ( me.state.food < 50 or me.state.drink < 50 ) then
		 study.study_flag.state = study_state_needfeed
	end
	DoAfterSpecial(2, "study.OnCurrentEnd()", 12)
end
