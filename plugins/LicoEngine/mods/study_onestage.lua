--Module: study_onestage.lua
--ֻ��Ҫһ������׶μ������ѧϰ�����ģ�飬��xue/learn, du/read, lian/practice

require "tprint"

study.onestage = {}

--xue/learn
--��ġ���Ԫ�񹦡������ˣ�
--�����˺����ӵ�ָ�����ƺ���Щ�ĵá�
--�����̫���ˣ����ʲôҲû��ѧ����
--���Ǳ���Ѿ����ӵ������ˣ�û�а취�ٳɳ��ˡ�
--��ķ�����Ϊ����������޷�ѧϰ̫���ɷ���
--du/read
--���ж��йػ��������ļ��ɣ��ƺ��е��ĵá�
--�����ڹ���ƣ�룬�޷�ר�������ж���֪��
--���ж���һ��������Ƿ���������˵�Ķ�����Զ�̫ǳ�ˣ�û��ѧ���κζ�����
--��ķ�����Ϊ����������޷�ѧϰ̫���ɷ���
--ǧ�־������޷�����������ѧ���κζ�����		���50��
--ǧ�־���������ͷ�����ͣ�����Ϣ��Ϣ�ˡ�
--ǧ�־������ڡ�ǧ�֡������Ѿ��������裬�Ȿ�鲻�����㳤�����١�
--lian/practice
--��İ����󷨽����ˣ�
--�����ڽ����鸡������Ϣһ��ɡ�
--�������������������Լ�������ȥ�ˡ�
--��ĬĬ������һ�����Ȼ������һ��������½���
--���������½������ˣ�
--������Ƿ�ѣ�ǿ��������·罣�к����档
--���������㣬ǿ��������·罣���߻���ħ��Σ�ա�
--�����������������û�а취��ϰ���ѩ�轣����
--���������һ������������ϰ������
--ǧ�־�������������������Ϣһ�������ɡ�
--��ľ���̫���ˣ����������������衣
--lianxi
--�����ǲ��壬������ȥ����Σ�յģ�
--chat 448qn80for23
study.onestage.patterns = { xue={{failed="^�����̫���ˣ����ʲôҲû��ѧ����$", result=study_state_needrefresh},
							{failed="^���Ǳ���Ѿ����ӵ������ˣ�û�а취�ٳɳ��ˡ�$", result=study_state_needdrop},
							{failed="^��ķ�����Ϊ����������", result=study_state_needdrop},
							{failed="^���������",  result=study_state_needdrop},
							{failed="^��Ҫ��˭��̣�$", result=study_state_needdrop}},
						du={{failed="^�����ڹ���ƣ�룬�޷�ר�������ж���֪��$", result=study_state_needrefresh},
						        {failed="^���ж���һ��������Ƿ���������˵�Ķ�����Զ�̫ǳ�ˣ�û��ѧ���κζ�����$", result=study_state_needdrop},
							{failed="^��ķ�����Ϊ����������޷�ѧϰ", result=study_state_needdrop},
							--{failed="^���޷�����������ѧ���κζ�����$", result=study_state_needrefresh},
							{failed="^������ͷ�����ͣ�����Ϣ��Ϣ�ˡ�$", result=study_state_needrefresh},
							{failed="^���ڡ�ǧ�֡������Ѿ��������裬�Ȿ�鲻�����㳤�����١�$", result=study_state_needdrop}},
						lian={{failed="^�����ڽ����鸡������Ϣһ��ɡ�$", result=study_state_needrecover},
							{failed="^�������������������Լ�������ȥ�ˡ�$", result=study_state_needneili},
							{failed="^������Ƿ�ѣ�ǿ��", result=study_state_needrecover},
							{failed="^���������������", result=study_state_needrecover},
							{failed="^���������㣬ǿ��", result=study_state_needneili},
							{failed="^���������", result=study_state_needdrop},
							{failed="^������������ˡ�$", result=study_state_needneili},
							{failed="^����������������Ϣһ�������ɡ�$", result=study_state_needrecover},
							{failed="^�����̫�ͣ�������ȥ̫Σ���ˣ�$", result=study_state_needrecover},
							{failed="^��ľ���̫����", result=study_state_needrefresh}},
						lianxi={{failed="^�����ǲ��壬������ȥ����Σ�յģ�$", result=study_state_needrefresh},
							{failed="^�����˯�˹�ȥ��$", result=study_state_needpatch},
							{failed="^ʲô��$", result=study_state_needpatch},
							{failed="^��ķ������㣬�����������������$", result=study_state_needrecover}},
						dupoem={{failed="^���޷�����������ѧ���κζ�����$", result=study_state_needrefresh}},
						duxueshu={{failed="^���ж���һ��������Ƿ���������˵�Ķ�����Զ�̫ǳ�ˣ�û��ѧ���κζ�����$", result=study_state_needdrop},
						        {failed="^�����ڹ���ƣ�룬�޷�ר�������ж���֪��$", result=study_state_needrefresh},
							{failed="^��Ҫ��ʲô��$", result=study_state_needpatch}}}

function study.onestage.EndCallback_Inner()
	if ( study.study_flag.state == study_state_skillup ) then
		--������������ˣ���ô����skillsָ��
		command.Run("skills", study.OnCurrentEnd)
	else
		DoAfterSpecial(0.1, "study.OnCurrentEnd()", 12)
	end
end
study.onestage.EndCallback = study.onestage.EndCallback_Inner

function study.onestage.Execute ( cmd_action, commandstring )
	local successpattern = "^��ġ�(?P<skill_name>\\S+)�������ˣ�$"
	local failedpatterns = {}

	if ( cmd_action and study.onestage.patterns[cmd_action] ) then
		study.study_flag.action = cmd_action

		--����ѧϰ�б����ʧ�ܵĴ�����
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
		message.Note ( "ѧϰָ�����" .. commandstring )
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
	--����ʧ�ܵ�ƥ�䴮��ȷ��״̬���
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
