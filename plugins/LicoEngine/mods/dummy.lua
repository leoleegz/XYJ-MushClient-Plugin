-- dummy.lua
require "addxml"
require "tprint"

dummy = {}

dummy.mode = 0

dummy.endflag = "ok"

--����Dummyģʽ
function dummy.Start (name, line, wildcards, styles)
	local mode = tonumber(GetVariable("dummy_mode")) or 0
	local id = GetVariable("dummy_id")
	local name= GetVariable("dummy_name")

	dummy.mode = mode

	if ( mode > 0 ) then
		addxml.trigger { name="dummy_receive", 
				match="^" .. name .. "\\(" .. id .. "\\)�����㣺(?P<message>.*)$",
				group="Dummy",
				enabled=true,
				sequence=50,
				keep_evaluating="y",
				script="dummy.OnReceive",
				regexp="y"}

		if ( mode == 1 ) then
			command.RunOnly ("follow " .. id)
		end 
	end

	print ("����ģʽ����")
end

--����һ������ָ��
function dummy.Send (message)
	local id = GetVariable("dummy_id")
	print ("����:" .. message)
	command.RunOnly("tell " .. id .. " " .. message)
end

--����������һ������Ϣ
function dummy.OnReceive (name, line, wildcards, styles)
	local message = wildcards["message"]

	print ("�յ����׵���Ϣ: " .. message )
	if ( dummy.mode == 1 ) then
		dummy.helper.Receive(message)
	elseif ( dummy.mode == 2 ) then
		dummy.requirer.Receive(message)
	end
end

--�˳�Dummyģʽ
function dummy.Stop (name, line, wildcards, styles)
	dummy.mode = 0

	DeleteTrigger("dummy_receive")
	command.RunOnly ("follow none")
	print ("����ģʽ����")
end