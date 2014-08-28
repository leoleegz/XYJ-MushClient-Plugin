-- Module: system.lua
-- ִ��ϵͳ

system = {}

current_action_type = { dotask=false, walk=false, study=false, idle=false }

local last_send_time

--���õ�ǰ��������
function system.SetActionType( action_type )
	
end  --system.SetActionType

function system.ResetTimers ()
	--��ֹ������ʱ������
	ResetTimer("fadai")
end

--����ʱ��Ҫ����Ķ���
function system.Idle(command)
end --system.Idle

local retry_time = 10

--����ʱ�Զ���������
function system.OnWorldDisconnect ()
	if ( not world.IsConnected() ) then
		message.Note("���ߣ�" .. retry_time .. "�����������")
		DoAfterSpecial(retry_time, "system.CheckConnState()", 12)

		--�������ӵļ��ʱ�䣬ÿ������
		retry_time = 2 * retry_time
		if ( retry_time > 300 ) then
			retry_time = 300	--�Ϊ5����
		end
	else
		retry_time = 10
	end
end

function system.CheckConnState()
	world.Connect ()
	DoAfterSpecial(1, "system.OnWorldDisconnect ()", 12)
end