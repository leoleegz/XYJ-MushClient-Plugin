-- Module: system.lua
-- 执行系统

system = {}

current_action_type = { dotask=false, walk=false, study=false, idle=false }

local last_send_time

--设置当前动作类型
function system.SetActionType( action_type )
	
end  --system.SetActionType

function system.ResetTimers ()
	--防止发呆定时器干扰
	ResetTimer("fadai")
end

--发呆时需要处理的动作
function system.Idle(command)
end --system.Idle

local retry_time = 10

--断线时自动重新连接
function system.OnWorldDisconnect ()
	if ( not world.IsConnected() ) then
		message.Note("断线，" .. retry_time .. "秒后重新连接")
		DoAfterSpecial(retry_time, "system.CheckConnState()", 12)

		--重新连接的间隔时间，每次增长
		retry_time = 2 * retry_time
		if ( retry_time > 300 ) then
			retry_time = 300	--最长为5分钟
		end
	else
		retry_time = 10
	end
end

function system.CheckConnState()
	world.Connect ()
	DoAfterSpecial(1, "system.OnWorldDisconnect ()", 12)
end