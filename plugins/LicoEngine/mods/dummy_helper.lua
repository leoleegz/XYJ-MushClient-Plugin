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

--������Ϣ���ݽ��е���
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
				match="^�Է������������棬����������$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnTargetFullQi",
				regexp="y"}
	elseif ( dummy.helper.lastmessage == "refresh") then
		commandstring = "exert refresh " .. id
		addxml.trigger { name="dummy_fullshen", 
				match="^�Է����ھ�����������������$",
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
				match="^�������������$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnOutofForce",
				regexp="y"}

	addxml.trigger { name="dummy_actionend", 
				match="^���μ��Ѿ�������",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.helper.OnActionEnd",
				regexp="y"}

	system.ResetTimers ()
	command.Run( "#15 (".. commandstring .. ");uptime")
end

--Ŀ�������Ѫ����: �Է������������棬����������
function dummy.helper.OnTargetFullQi (name, line, wildcards, styles)
	dummy.helper.state = helper_state_fullqi
	EnableTrigger("dummy_fullqi", false)
end

--Ŀ���������: �Է����ھ�����������������
function dummy.helper.OnTargetFullShen (name, line, wildcards, styles)
	dummy.helper.state = helper_state_fullshen
	EnableTrigger("dummy_fullshen", false)
end

--�Լ��������㣺 ����������
function dummy.helper.OnOutofForce (name, line, wildcards, styles)
	dummy.helper.state = helper_state_outofforce
	EnableTrigger("dummy_outofforce", false)
end

function dummy.helper.OnActionEnd (name, line, wildcards, styles)
	EnableTrigger("dummy_actionend", false)
	DoAfterSpecial ( 2, "dummy.helper.CheckStatus()", 12 )
end

--�ָ�����
function dummy.helper.HuifuEnd()
	dummy.helper.state = helper_state_none
	dummy.helper.Invoke ()
end

--���״̬
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
		--û�������ˣ���Ҫ�ָ�
		dummy.helper.state = helper_state_huifu
		command.Run("hp", dummy.helper.NeedRecover)
	end
end

function dummy.helper.NeedRecover()
	me.state.RecoverEndCallback = dummy.helper.HuifuEnd
	me.state.Recover()
end

--��������
function dummy.helper.EndInvoke()
	DeleteTrigger("dummy_fullqi")
	DeleteTrigger("dummy_fullshen")
	DeleteTrigger("dummy_outofforce")
	DeleteTrigger("dummy_actionend")
	dummy.helper.lastmessage = ""
	dummy.helper.HelpEndCallback()
	dummy.helper.HelpEndCallback = dummy.helper.HelpEnd_Inner
end