-- Module: task_lijing.lua
-- 李靖灭妖模块

require "addxml"
require "tprint"

task.lijing = {}

--李靖说道：老夫不是派你去降服灰斑蛇怪吗？
function task.lijing.Ask( is_newkill )
	local beforeaction = GetVariable("task_lj_beforetaskaction")
	command.RunOnly(beforeaction)
	local ask_target
	if ( is_newkill ) then
		ask_target = "newkill"
	else
		ask_target = "oldkill"
	end
	addxml.trigger { name="begin_lijing_task", 
				match="^你向李靖打听有关『" .. ask_target .. "』的消息。$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.lijing.BeginTask",
				regexp="y"}
	command.Run("ask li jing about " .. ask_target)
end

function task.lijing.BeginTask (name, line, wildcards, styles)
	EnableTrigger("begin_lijing_task", false)
	addxml.trigger { name="get_task_info", 
				match="^李靖对你说道：近有(?P<mobname>\\S+)\\((?P<mobid>.*)\\)在(?P<moblocation>\\S+)为非作歹，请速去降服！$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.GetTaskInfo",
				regexp="y"}
	task.GetTaskInfoEndCallback = task.lijing.OnGetTaskInfoEnd
end

--怪还在
function task.lijing.RegetTask (name, line, wildcards, styles)
	message.Note(wildcards[1].."还在")
	DoAfterSpecial(0.5, "task.lijing.RemoveInfoTriggers()", 12)
end

function task.lijing.OnGetTaskInfoEnd()
	EnableTrigger("get_task_info", false)
	local pathes = GetVariable("task_lj_aftertaskaction")
	--walk.WalkEndCallback = task.lijing.Recover
	--walk.WalkPath ( pathes )
	command.RunOnly( pathes )
	task.lijing.Recover ()
end

function task.lijing.Recover (object_found, walk_end, state)
	if ( dummy.mode < 2 ) then
		me.state.RecoverEndCallback = task.lijing.GotoChangan
		me.state.Recover()
	else
		task.lijing.GotoChangan()
	end
end

--要任务结束
function task.lijing.GotoChangan()
	--增加统计数字
	local count = tonumber(GetVariable("task_lj_count")) or 0
	count = count + 1
	SetVariable("task_lj_count", tostring(count))

	--EnableTrigger("get_task_info", false)

	addxml.trigger { name="reach_changan", 
				match="^只见\\S+，你(.*)从里面走了出来。$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.lijing.OnReached",
				regexp="y"}
	--command.RunOnly("d")
	command.RunOnly("lj2ca")
	--walk.WalkEndCallback = task.lijing.OnReached
	--walk.WalkZone("lijing")
end

--到达长安+
function task.lijing.OnReached (name, line, wildcards, styles)
	EnableTrigger ("reach_changan", false)
	message.Note("开始找怪")
	DoAfterSpecial(0.5, "task.lijing.StartLookup()", 12)
	DoAfterSpecial(0.2, "task.lijing.RemoveInfoTriggers()", 12)
end

function task.lijing.RemoveInfoTriggers()
	DeleteTrigger("begin_lijing_task")
	DeleteTrigger("get_task_info")
	DeleteTrigger("reach_changan")
end

--开始寻找目标对象
function task.lijing.StartLookup()
	task.TaskEndCallback = task.lijing.OnTaskEnd
	return task.GeneralLookup("^从天上徐徐飘下几页天书，落入你的怀中。$")
end

--你得到了一级法术。
--任务结束
function task.lijing.OnTaskEnd( is_success )
	if( is_success ) then
		--统计数字
		local success = tonumber(GetVariable("task_lj_success")) or 0
		local count = tonumber(GetVariable("task_lj_count")) or 0
		success = success + 1
		message.Note ("已成功" .. success .. "/" .. count .. "次（李）")

		if ( task.stat.recount ) then
			success = 0
			count = 0
			task.stat.recount = false
		end
		SetVariable("task_lj_count", tostring(count))
		SetVariable("task_lj_success", tostring(success))

		addxml.trigger { name="stat_task_wx", 
				match="^你灭妖得到了(?P<wx_count>\\S+)点武学！$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.lijing.TaskStatWx",
				regexp="y"}
		addxml.trigger { name="stat_task_qn", 
				match="^你灭妖得到了(?P<qn_count>\\S+)点潜能！$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.lijing.TaskStatQn",
				regexp="y"}
	end
end

function task.lijing.TaskStatWx (name, line, wildcards, styles)
	task.TaskStat ( tonumber(ConvertChineseNumber(wildcards["wx_count"])), 0)
end

function task.lijing.TaskStatQn (name, line, wildcards, styles)
	task.TaskStat ( 0,  tonumber(ConvertChineseNumber(wildcards["qn_count"])))
	DoAfterSpecial(0.5, "task.lijing.ClearTriggers()", 12)
end

function task.lijing.ClearTriggers()
	DeleteTrigger("stat_task_wx")
	DeleteTrigger("stat_task_qn")
	task.CleanTriggers()
end