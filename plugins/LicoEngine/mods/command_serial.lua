-- Module: command_serial.lua
-- 串行运行多条指令

--行动列表：step-当前步数，steps-总步数，command-当前指令
local run_flag = {step=0, steps=0, command="", is_failed=false, is_stop=false}

function run_flag.init ()
	run_flag.step=0
	run_flag.steps=0
	run_flag.command=""
	run_flag.is_failed=false
	run_flag.is_stop = false
end

local cmds_table = {}

--所有指令运行结束时的回调函数
function command.SerialCmdsEndCallback_Inner()
	print("串行运行结束")
end
command.SerialCmdsEndCallback = command.SerialCmdsEndCallback_Inner

-- 单步指令输出结束时的回调函数
function command.StepOutputEndCallback_Inner( )
	print ("指令输出结束")
end --OutputEndCallback_Inner
command.StepOutputEndCallback = command.StepOutputEndCallback_Inner

--单步指令成功的回调函数
--line: 匹配的行
--wildcards: 匹配项
function command.StepCmdSuccessCallback_Inner(line, wildcards)
	print("指令成功")
end
command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner

--单步指令失败的回调函数
--line: 匹配的行
--wildcards: 匹配项
function command.StepCmdFailedCallback_Inner(line, wildcards)
	print("指令失败")
end
command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner

--单步指令输出结束时的触发器调用函数
function command.OnStepOutputEnd (name, line, wildcards, styles)
	command.StepOutputEndCallback()

	--恢复原始环境
	EnableTrigger("cmd_outputend", false)
	EnableTrigger("cmd_success", false)
	EnableTriggerGroup("Cmds_Failed" ,false)

	command.StepOutputEndCallback = command.StepOutputEndCallback_Inner
	command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner
	command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner
	--删除判断失败的触发器组
	SetTriggerOption ("cmd_success", "match", "")
	DeleteTriggerGroup ("Cmds_Failed")
end

--单步指令成功时的触发器调用函数
function command.OnStepCmdSuccess (name, line, wildcards, styles)
	command.StepCmdSuccessCallback(line, wildcards)
	--恢复原始状态
	command.StepCmdSuccessCallback = command.StepCmdSuccessCallback_Inner
end

--单步指令失败时的触发器调用函数
function command.OnStepCmdFailed (name, line, wildcards, styles)
	command.StepCmdFailedCallback(line, wildcards)
	command.StepCmdFailedCallback = command.StepCmdFailedCallback_Inner
end

--
function command.OnSerialCmdsEnd ()
end

--继续运行下一条指令
function command.RunOneStepCommand ( is_continue )
	
end

--串行运行多条指令，前一条指令运行完毕才运行下一条指令
function command.RunSerialCommands ( commands, cmd_end_callback, successpattern, cmd_success_callback, failedpatterns, cmd_failed_callback )
	local v
	cmds_table = utils.split( commands, splitchar)

	command.RunOneStepCommand ( true )
end

--停止运行多条指令
function command.Stop()
	run_flag.is_stop = true
end
