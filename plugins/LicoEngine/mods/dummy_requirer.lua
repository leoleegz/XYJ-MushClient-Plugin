-- dummy_requirer.lua

dummy.requirer = {}

function dummy.requirer.HelpEnd_Inner()
end
dummy.requirer.HelpEndCallback = dummy.requirer.HelpEnd_Inner

--��Ҫ�ָ���Ѫ
function dummy.requirer.CallRecover()
	dummy.Send("recover")
end

--��Ҫ�ָ�����
function dummy.requirer.CallRefresh()
	dummy.Send("refresh")
end

--��Ҫ��Ѫ�;���ͬʱ�ָ�
function dummy.requirer.CallHuifu()
	dummy.Send("huifu")
end

--������Ϣ�����ڽ�������
function dummy.requirer.Receive (message)
	if ( message == dummy.endflag) then		-- ��������
		print ("��������")
		dummy.requirer.HelpEndCallback ()
		dummy.requirer.HelpEndCallback = dummy.requirer.HelpEnd_Inner
	end
end