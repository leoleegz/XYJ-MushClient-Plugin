-- dummy_requirer.lua

dummy.requirer = {}

function dummy.requirer.HelpEnd_Inner()
end
dummy.requirer.HelpEndCallback = dummy.requirer.HelpEnd_Inner

--需要恢复气血
function dummy.requirer.CallRecover()
	dummy.Send("recover")
end

--需要恢复精神
function dummy.requirer.CallRefresh()
	dummy.Send("refresh")
end

--需要气血和精神同时恢复
function dummy.requirer.CallHuifu()
	dummy.Send("huifu")
end

--接收消息，用于结束求助
function dummy.requirer.Receive (message)
	if ( message == dummy.endflag) then		-- 求助结束
		print ("帮助结束")
		dummy.requirer.HelpEndCallback ()
		dummy.requirer.HelpEndCallback = dummy.requirer.HelpEnd_Inner
	end
end