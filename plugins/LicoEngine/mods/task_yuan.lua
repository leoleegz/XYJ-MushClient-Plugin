-- Module: task_yuan.lua
-- 从袁天罡那里要任务

require "addxml"
require "tprint"

task.yuan = {}

function task.yuan.Ask()
	addxml.trigger { name="begin_yuan_task", 
				match="^你向袁天罡打听有关『kill』的消息。$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.BeginTask",
				regexp="y"}
	command.Run("ask yuan about kill")
end

function task.yuan.BeginTask (name, line, wildcards, styles)
	EnableTrigger("begin_yuan_task", false)
	addxml.trigger { name="get_yuan_task", 
				match="^袁天罡将手中桃木剑向四方一划，对你说道：$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.GetTask",
				regexp="y"}
	addxml.trigger { name="no_yuan_task", 
				match="^袁天罡将手中桃木剑缓缓放下，说：多谢\\S+,妖魔已经除尽了。$",
				group="Task",
				enabled=true,
				sequence=100,
				script="task.yuan.NoTask",
				regexp="y"}
	addxml.trigger { name="reget_yuan_task", 
				match="^袁天罡说道：在下不是请您去收服(\\S+)吗？$",
				group="Task",
				enabled=true,
				sequence=100,
				script="task.yuan.RegetTask",
				regexp="y"}
end

function task.yuan.NoTask (name, line, wildcards, styles)
	message.Note("暂时没有任务")
	EnableTrigger("get_yuan_task", false)
	DoAfterSpecial(0.5, "task.yuan.RemoveInfoTriggers()", 12)
end

function task.yuan.RegetTask (name, line, wildcards, styles)
	message.Note(wildcards[1].."还在")
	DoAfterSpecial(0.5, "task.yuan.RemoveInfoTriggers()", 12)
end

function task.yuan.GetTask (name, line, wildcards, styles)
	EnableTrigger("no_yuan_task", false)
	addxml.trigger { name="get_task_info", 
				match="^　　近有(?P<mobname>\\S+)\\((?P<mobid>.*)\\)在(?P<moblocation>\\S+)出没，为害不小，请速去收服！$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.GetTaskInfo",
				regexp="y"}
	task.GetTaskInfoEndCallback = task.yuan.GetTipsInfo
end

function task.yuan.GetTipsInfo()
	--
	--增加统计数字
	local count = tonumber(GetVariable("task_yuan_count")) or 0
	count = count + 1
	SetVariable("task_yuan_count", tostring(count))

	EnableTrigger("get_task_info", false)
	addxml.trigger { name="get_tips_info", 
				match="^袁天罡略有所思地顿了一顿，又道：若能求得清虚观雾渊道长的符咒，也许会对你有帮助。$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.GotoGetTips",
				regexp="y"}
	
end

function task.yuan.GotoGetTips (name, line, wildcards, styles)
	EnableTrigger("get_tips_info", false)
	walk.WalkEndCallback = task.yuan.EndGetTips
	--先去道长那拿符
	walk.WalkPath(pathes.wuxudaozhang)
end

--拿到符了
function task.yuan.EndGetTips(object_found, walk_end, state)
	task.has_tip = true
	task.yuan.RemoveInfoTriggers()
	message.Note("拿到符了，开始找怪")
	DoAfterSpecial(0.5, "task.yuan.StartLookup()", 12)
end

--开始寻找目标对象
function task.yuan.StartLookup()
	task.TaskEndCallback = task.yuan.OnTaskEnd
	return task.GeneralLookup("^"..task.target.name.."惨叫一声，死了。$", "^"..task.target.name.."死了，但是你没有得到武学经验和潜能。")
end

function task.yuan.RemoveInfoTriggers()
	--print("删除任务信息触发器")
	DeleteTrigger("begin_yuan_task")
	DeleteTrigger("get_yuan_task")
	DeleteTrigger("no_yuan_task")
	DeleteTrigger("get_task_info")
	DeleteTrigger("get_tips_info")
	DeleteTrigger("reget_yuan_task")
end

function task.yuan.GetStatData()
	addxml.trigger { name="get_wx_qn", 
				match="^你得到了(?P<wx_count>\\S+)点武学经验和(?P<qn_count>\\S+)点潜能！$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.TaskStat",
				regexp="y"}
end

function task.yuan.TaskStat (name, line, wildcards, styles)
	task.TaskStat ( tonumber(ConvertChineseNumber(wildcards["wx_count"])),  tonumber(ConvertChineseNumber(wildcards["qn_count"])))
	DoAfterSpecial(0.5, "task.yuan.ClearTriggers()", 12)
end

function task.yuan.OnTaskEnd (is_success)
	if( is_success ) then
		--统计数字
		local success = tonumber(GetVariable("task_yuan_success")) or 0
		local count = tonumber(GetVariable("task_yuan_count")) or 0
		success = success + 1
		message.Note ("已成功" .. success .. "/" .. count .. "次（袁）")

		if ( task.stat.recount ) then
			success = 0
			count = 0
			task.stat.recount = false
		end
		SetVariable("task_yuan_count", tostring(count))
		SetVariable("task_yuan_success", tostring(success))

		task.yuan.GetStatData()
	end
end

function task.yuan.ClearTriggers()
	DeleteTrigger("get_wx_qn")
	task.CleanTriggers()
end
