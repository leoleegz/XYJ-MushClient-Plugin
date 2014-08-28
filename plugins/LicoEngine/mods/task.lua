-- Module: task.lua
-- 通用任务模块

task = {}

task.target = {name="", id=""}
task.location = {name="", id=""}
task.has_tip = false
task.stat = {wx=0, qn=0, recount=false}

--获取任务信息结束的回调函数，调用方进行下一步动作
function task.GetTaskInfoEndCallback_Inner()
end
task.GetTaskInfoEndCallback = task.GetTaskInfoEndCallback_Inner

--任务结束时的回调函数
function task.TaskEndCallback_Inner( is_success )
end
task.TaskEndCallback = task.TaskEndCallback_Inner

-- 设置任务信息
-- target_name: 目标名称
-- target_id: 目标id
-- target_location: 目标所在地点
function task.SetTaskInfo ( target_name, target_id, target_location )

	message.Note("任务：" .. target_location .. "-" .. target_name .. "(" .. target_id .. ")", "yellow")

	task.target.name = target_name
	task.target.id = target_id
	task.location.name = target_location
	task.location.id = zone_map[target_location]
	if ( not task.location.id ) then
		message.Note("没有找到对应的地点", "red")
	end

	if ( task.location.id == "putuo" and me.state.falimax > 360 ) then
		--能飞到普陀山
		task.location.id = "putuo2"
	end

	task.AlarmNextTask()
end

--获取任务信息
function task.GetTaskInfo (name, line, wildcards, styles)
	task.SetTaskInfo (wildcards["mobname"], wildcards["mobid"], wildcards["moblocation"])
	task.GetTaskInfoEndCallback()
	task.GetTaskInfoEndCallback = task.GetTaskInfoEndCallback_Inner
end

--开始执行任务
function task.GeneralLookup(success_pattern, failed_pattern)
	if ( success_pattern ) then
		addxml.trigger { name="task_success",
				match=success_pattern,
				group="Task",
				enabled=true,
				sequence=50,
				script="task.EndTaskSuccess",
				regexp="y"}
	end
	if ( failed_pattern ) then
		addxml.trigger { name="task_failed",
				match=failed_pattern,
				group="Task",
				enabled=true,
				sequence=50,
				script="task.EndTaskFailed",
				regexp="y"}
	end
	addxml.trigger { name="stat_task_skill",
				match="^你得到了一级(?P<skill_name>\\S+)。$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.SkillUp",
				regexp="y"}
	walk.TargetFindCallback = task.OnTargetFound
	return DoAfterSpecial(0.5, "task.StartLookup()", 12)
end

function task.StartLookup()
	--解除监控
	EnableTrigger("monitor_mobs", false)
	EnableTrigger("warn_mobs", false)
	walk.WalkZoneAndFindObject ( task.location.id, task.target.id, task.target.name )
end

function task.OnTargetFound(room_name)
	message.Note("找到".. task.target.name.."了", "yellow")
	--EnableTrigger("task_success", true)
	command.RunOnly("l " .. string.lower(task.target.id) .. ";check ".. string.lower(task.target.id))
end

function task.SkillUp (name, line, wildcards, styles)
	message.Note("获得一级技能 ".. wildcards["skill_name"])
	task.stat.recount = true
end

function task.EndTaskSuccess ( target_name, target_id, target_location )
	message.Note ("任务成功", "yellow")

	task.TaskEndCallback ( true )
	task.TaskEndCallback = task.OnTaskEndCallback_Inner
end

--结束任务，进行任务统计
function task.TaskStat ( rw_wx, rw_qn )
	task.stat.wx = task.stat.wx + rw_wx
	task.stat.qn = task.stat.qn + rw_qn
	if ( rw_wx > 0 ) then
		message.Note("获得武学 ".. rw_wx)
	end
	if( rw_qn > 0 ) then
		message.Note("获得潜能 " .. rw_qn)
	end
end

--任务失败
function task.EndTaskFailed ( target_name, target_id, target_location )
	message.Note ("任务失败", "red")
	--task.stat.failed = task.stat.failed + 1
	task.TaskEndCallback ( false )
	task.TaskEndCallback = task.OnTaskEndCallback_Inner
end

function task.CleanTriggers()
	DeleteTrigger("task_success")
	DeleteTrigger("task_failed")
	DeleteTrigger("stat_task_skill")
end

--任务闹钟
function task.AlarmNextTask()
	EnableTimer("task_alarmer", true)
	ResetTimer("task_alarmer")
end

--可以要新任务了
function task.CanAskNewTask()
	EnableTimer("task_alarmer", false)
	ResetTimer("task_alarmer")
	message.Note ("可以开始下个任务")
end

--杀怪
function task.KillGuai (name, line, wildcards, styles)
	--command.Run("perform qianyan")
	command.Run("follow " .. string.lower(task.target.id))
	command.Run("fight ".. string.lower(task.target.id))
end

--杀怪2，用kill指令
function task.KillGuai2 (name, line, wildcards, styles)
	command.Run("kill ".. string.lower(task.target.id))
end

--贴符到怪身上
function task.TieGuai(name, line, wildcards, styles)
	command.Run("tie ".. string.lower(task.target.id))
end

--施法术
function task.CastOnGuai ( commandstring )
	command.Run(commandstring .. " " .. string.lower(task.target.id))
end

--你大喝一声：八仙何在！
