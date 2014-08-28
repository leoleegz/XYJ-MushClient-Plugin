-- Module: command_serial.lua
-- �������ж���ָ��

--�ж��б�step-��ǰ������steps-�ܲ�����command-��ǰָ��
local run_flag = {step=0, steps=0, command="", is_failed=false, is_stop=false}

function run_flag.init ()
	run_flag.step=0
	run_flag.steps=0
	run_flag.command=""
	run_flag.is_failed=false
	run_flag.is_stop = false
end

local cmds_table = {}

--����ָ�����н���ʱ�Ļص�����
function command.SerialCmdsEndCallback_Inner()
	print("�������н���")
end
command.SerialCmdsEndCallback = command.SerialCmdsEndCallback_Inner

-- ����ָ���������ʱ�Ļص�����
function command.StepOutputEndCallback_Inner( )
	print ("ָ���������")
end --OutputEndCallback_Inner
command.StepOutputEndCallback = command.StepOutputEndCallback_Inner

--����ָ��ɹ��Ļص�����
--line: ƥ�����
--wildcards: ƥ����
function command.StepCmdSuccessCallback_Inner(line, wildcards)
	print("ָ��ɹ�")
end
command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner

--����ָ��ʧ�ܵĻص�����
--line: ƥ�����
--wildcards: ƥ����
function command.StepCmdFailedCallback_Inner(line, wildcards)
	print("ָ��ʧ��")
end
command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner

--����ָ���������ʱ�Ĵ��������ú���
function command.OnStepOutputEnd (name, line, wildcards, styles)
	command.StepOutputEndCallback()

	--�ָ�ԭʼ����
	EnableTrigger("cmd_outputend", false)
	EnableTrigger("cmd_success", false)
	EnableTriggerGroup("Cmds_Failed" ,false)

	command.StepOutputEndCallback = command.StepOutputEndCallback_Inner
	command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner
	command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner
	--ɾ���ж�ʧ�ܵĴ�������
	SetTriggerOption ("cmd_success", "match", "")
	DeleteTriggerGroup ("Cmds_Failed")
end

--����ָ��ɹ�ʱ�Ĵ��������ú���
function command.OnStepCmdSuccess (name, line, wildcards, styles)
	command.StepCmdSuccessCallback(line, wildcards)
	--�ָ�ԭʼ״̬
	command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner
end

--����ָ��ʧ��ʱ�Ĵ��������ú���
function command.OnStepCmdFailed (name, line, wildcards, styles)
	command.StepCmdFailedCallback(line, wildcards)
	command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner
end

--
function command.OnSerialCmdsEnd ()
end

--����������һ��ָ��
function command.RunOneStepCommand ( is_continue )
	
end

--�������ж���ָ�ǰһ��ָ��������ϲ�������һ��ָ��
function command.RunSerialCommands ( commands, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	local v
	cmds_table = utils.split( commands, splitchar)

	command.RunOneStepCommand ( true )
end

--ֹͣ���ж���ָ��
function command.Stop()
	run_flag.is_stop = true
end
