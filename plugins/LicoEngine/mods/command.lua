-- Module: command.lua
-- ָ��ϵͳ
require "tprint"
require "addxml"

command = {}

local splitchar = ";"
--��Ҫ�������⴦�������
--local special_cmds = {"#wa;#wait"}

function command.init_env ()
	--���ָ������Ĵ�����
	addxml.trigger { name="cmd_outputend", 
					match="^>",
					group="Cmds",
					enabled=false,
					sequence=20,
					script="command.OnOutputEnd",
					regexp="y"}

	--���ָ��ɹ��Ĵ�����
	addxml.trigger { name="cmd_success", 
					match="temp_match",
					group="Cmds",
					enabled=false,
					sequence=20,
					script="command.OnCmdSuccess",
					regexp="y"}
	--����addxml��matchΪ���ַ���ʱ���������Ҫ����һ����ʱ��ƥ��ģʽ
	SetTriggerOption ("cmd_success", "match", "")

	addxml.trigger { name="cmd_waittrigger", 
				match="temp_match",
				group="Cmds",
				enabled=false,
				sequence=20,
				script="command.OnTriggered",
				regexp="y"}
	SetTriggerOption ("cmd_waittrigger", "match", "")
end
command.init_env ()  -- ��ʼ��ָ���

-- ָ���������ʱ�Ļص�����
function command.OutputEndCallback_Inner( )
	print ("ָ���������")
end --OutputEndCallback_Inner
command.OutputEndCallback = command.OutputEndCallback_Inner

--ָ��ɹ��Ļص�����
--line: ƥ�����
--wildcards: ƥ����
function command.CmdSuccessCallback_Inner(line, wildcards)
	print("ָ��ɹ�")
end
command.CmdSuccessCallback = command.CmdSuccessCallback_Inner

--ָ��ʧ�ܵĻص�����
--line: ƥ�����
--wildcards: ƥ����
function command.CmdFailedCallback_Inner(line, wildcards)
	print("ָ��ʧ��")
end
command.CmdFailedCallback = command.CmdFailedCallback_Inner

--ָ���������ʱ�Ĵ��������ú���
function command.OnOutputEnd (name, line, wildcards, styles)
	local temp_func 
	temp_func = command.OutputEndCallback
	command.OutputEndCallback = command.OutputEndCallback_Inner

	--�ָ�ԭʼ����
	EnableTrigger("cmd_outputend", false)
	EnableTrigger("cmd_success", false)
	EnableTriggerGroup("Cmds_Failed" ,false)
	
	command.CmdSuccessCallback = command.CmdSuccessCallback_Inner
	command.CmdFailedCallback = command.CmdFailedCallback_Inner

	--ɾ���ж�ʧ�ܵĴ�������
	SetTriggerOption ("cmd_success", "match", "")
	DeleteTriggerGroup ("Cmds_Failed")
	
	return temp_func()
end

--ָ��ɹ�ʱ�Ĵ��������ú���
function command.OnCmdSuccess (name, line, wildcards, styles)
	command.CmdSuccessCallback(line, wildcards)
	--�ָ�ԭʼ״̬
	command.CmdSuccessCallback = command.CmdSuccessCallback_Inner
end

--ָ��ʧ��ʱ�Ĵ��������ú���
function command.OnCmdFailed (name, line, wildcards, styles)
	command.CmdFailedCallback (line, wildcards)
	command.CmdFailedCallback = command.CmdFailedCallback_Inner
end

function command.OnTriggered (name, line, wildcards, styles)
	EnableTrigger("cmd_waittrigger", false)
	SetTriggerOption ("cmd_waittrigger", "match", "")
	command.OnOutputEnd()
end

--ע���ⲿ��ָ��������ú���
function command.RegisterCmdEndCallback ( cmd_end_callback )
	--�����������������ص�����
	if ( cmd_end_callback ) then
		command.OutputEndCallback = cmd_end_callback
	end
	EnableTrigger("cmd_outputend", true)
end

--����������
function command.RunOnly ( commandstring )
	if ( not commandstring ) then
		print ("�����ʽ����û��ָ��")
		return
	end
	--��¼���е�ʱ�䣬���ڼ�� idle
	system.ResetTimers ()
	--todo:?

	world.Execute ( commandstring )
end

-- ����һ��ָ��
function command.Run ( commandstring, cmd_end_callback )
	system.ResetTimers ()
	--��������ָ��
	if ( commandstring == "hp" ) then
		me.state.GetHpEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	elseif ( commandstring == "skills" ) then
		me.skills.GetSkillEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	elseif ( commandstring == "i" ) then
		me.items.GetItemsEndCallback = cmd_end_callback
		return command.RunOnly ( commandstring )
	end

	--�����������������ص�����
	if ( cmd_end_callback ) then
		command.OutputEndCallback = cmd_end_callback
	end
	EnableTrigger("cmd_outputend", true)
	--��¼���е�ʱ�䣬���ڼ�� idle
	--todo:?

	--�����Ƿ�Ϊ�ȴ�ָ��������ȴ�һ��ʱ�䣬����ֱ��ִ��ָ��
	local i, j, v

	i, j, v = string.find(commandstring, "^#wait (%d+)$")
	if ( i and i == 1 ) then
		--�ȴ�һ��ʱ��
		print("�ȴ�" .. tonumber(v) .. "������ִ��")
		return DoAfterSpecial (tonumber(v), 'command.OnOutputEnd()', 12)
	end

	i, j, v = string.find(commandstring, "^#tri (.*)$")
	if ( i and i == 1 ) then
		--���ô�������
		print("�ȴ�����:" .. v )
		SetTriggerOption ("cmd_waittrigger", "match", v)
		EnableTrigger("cmd_waittrigger", true)
		return
	end

	i, j, v = string.find(commandstring, "^#dummy (.*)$")
	if ( i and i == 1 ) then
		if ( dummy.mode >= 2 ) then
			--���ߴ����ж�
			print("֪ͨ�����ж�:" .. v)
			local id = GetVariable("dummy_id")
			commandstring = "tell " .. id .. " " .. v
		else
			commandstring = "uptime"
		end
	end

	world.Execute ( commandstring )
end

-- ����һ��ָ���Ҫ���гɹ������ж�
function command.RunWithConfirm ( commandstring, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	system.ResetTimers ()

	-- ����ָ��ɹ��Ĵ�����
	if ( successpattern ) then
		SetTriggerOption ("cmd_success", "match", successpattern)
		EnableTrigger("cmd_success", true)
		if ( cmd_success_callback ) then	-- ��������˻ص������������ûص�����
			command.CmdSuccessCallback = cmd_success_callback
		end
	end

	-- ����ָ��ʧ�ܵĴ�������failedpatternsΪ����
	if( failedpatterns ) then
		local v, i
		i = 0
		for _, v in pairs(failedpatterns) do
			-- ���ʧ���жϵĴ�����
			i = i + 1
			addxml.trigger { name="cmdfailed"..i,
				match=v,
				group="Cmds_Failed",
				enabled=true,
				sequence=50,
				script="command.OnCmdFailed",
				regexp="y"}
		end
		if ( cmd_failed_callback ) then
			command.CmdFailedCallback = cmd_failed_callback
		end
	end
	command.Run (commandstring, cmd_end_callback)
end

--���ж���ָ�����ȴ�ǰһ��ָ��ɹ�
function command.RunMultipleCommands ( commands, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	local v
	local cmd_table = utils.split( commands, splitchar)
	system.ResetTimers ()
	for _, v in pairs(cmd_table) do
		command.RunWithConfirm ( v, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	end
end
