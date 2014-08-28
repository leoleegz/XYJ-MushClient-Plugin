-- dummy.lua
require "addxml"
require "tprint"

dummy = {}

dummy.mode = 0

dummy.endflag = "ok"

--进入Dummy模式
function dummy.Start (name, line, wildcards, styles)
	local mode = tonumber(GetVariable("dummy_mode")) or 0
	local id = GetVariable("dummy_id")
	local name= GetVariable("dummy_name")

	dummy.mode = mode

	if ( mode > 0 ) then
		addxml.trigger { name="dummy_receive", 
				match="^" .. name .. "\\(" .. id .. "\\)告诉你：(?P<message>.*)$",
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

	print ("大米模式启动")
end

--向另一方发送指令
function dummy.Send (message)
	local id = GetVariable("dummy_id")
	print ("发送:" .. message)
	command.RunOnly("tell " .. id .. " " .. message)
end

--接收来自另一方的消息
function dummy.OnReceive (name, line, wildcards, styles)
	local message = wildcards["message"]

	print ("收到大米的消息: " .. message )
	if ( dummy.mode == 1 ) then
		dummy.helper.Receive(message)
	elseif ( dummy.mode == 2 ) then
		dummy.requirer.Receive(message)
	end
end

--退出Dummy模式
function dummy.Stop (name, line, wildcards, styles)
	dummy.mode = 0

	DeleteTrigger("dummy_receive")
	command.RunOnly ("follow none")
	print ("大米模式结束")
end