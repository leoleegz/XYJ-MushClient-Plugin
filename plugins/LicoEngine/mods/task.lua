-- Module: task.lua
-- ͨ������ģ��

task = {}

task.target = {name="", id=""}
task.location = {name="", id=""}
task.has_tip = false
task.stat = {wx=0, qn=0, recount=false}

--��ȡ������Ϣ�����Ļص����������÷�������һ������
function task.GetTaskInfoEndCallback_Inner()
end
task.GetTaskInfoEndCallback = task.GetTaskInfoEndCallback_Inner

--�������ʱ�Ļص�����
function task.TaskEndCallback_Inner( is_success )
end
task.TaskEndCallback = task.TaskEndCallback_Inner

-- ����������Ϣ
-- target_name: Ŀ������
-- target_id: Ŀ��id
-- target_location: Ŀ�����ڵص�
function task.SetTaskInfo ( target_name, target_id, target_location )

	message.Note("����" .. target_location .. "-" .. target_name .. "(" .. target_id .. ")", "yellow")

	task.target.name = target_name
	task.target.id = target_id
	task.location.name = target_location
	task.location.id = zone_map[target_location]
	if ( not task.location.id ) then
		message.Note("û���ҵ���Ӧ�ĵص�", "red")
	end

	if ( task.location.id == "putuo" and me.state.falimax > 360 ) then
		--�ܷɵ�����ɽ
		task.location.id = "putuo2"
	end

	task.AlarmNextTask()
end

--��ȡ������Ϣ
function task.GetTaskInfo (name, line, wildcards, styles)
	task.SetTaskInfo (wildcards["mobname"], wildcards["mobid"], wildcards["moblocation"])
	task.GetTaskInfoEndCallback()
	task.GetTaskInfoEndCallback = task.GetTaskInfoEndCallback_Inner
end

--��ʼִ������
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
				match="^��õ���һ��(?P<skill_name>\\S+)��$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.SkillUp",
				regexp="y"}
	walk.TargetFindCallback = task.OnTargetFound
	return DoAfterSpecial(0.5, "task.StartLookup()", 12)
end

function task.StartLookup()
	--������
	EnableTrigger("monitor_mobs", false)
	EnableTrigger("warn_mobs", false)
	walk.WalkZoneAndFindObject ( task.location.id, task.target.id, task.target.name )
end

function task.OnTargetFound(room_name)
	message.Note("�ҵ�".. task.target.name.."��", "yellow")
	--EnableTrigger("task_success", true)
	command.RunOnly("l " .. string.lower(task.target.id) .. ";check ".. string.lower(task.target.id))
end

function task.SkillUp (name, line, wildcards, styles)
	message.Note("���һ������ ".. wildcards["skill_name"])
	task.stat.recount = true
end

function task.EndTaskSuccess ( target_name, target_id, target_location )
	message.Note ("����ɹ�", "yellow")

	task.TaskEndCallback ( true )
	task.TaskEndCallback = task.OnTaskEndCallback_Inner
end

--�������񣬽�������ͳ��
function task.TaskStat ( rw_wx, rw_qn )
	task.stat.wx = task.stat.wx + rw_wx
	task.stat.qn = task.stat.qn + rw_qn
	if ( rw_wx > 0 ) then
		message.Note("�����ѧ ".. rw_wx)
	end
	if( rw_qn > 0 ) then
		message.Note("���Ǳ�� " .. rw_qn)
	end
end

--����ʧ��
function task.EndTaskFailed ( target_name, target_id, target_location )
	message.Note ("����ʧ��", "red")
	--task.stat.failed = task.stat.failed + 1
	task.TaskEndCallback ( false )
	task.TaskEndCallback = task.OnTaskEndCallback_Inner
end

function task.CleanTriggers()
	DeleteTrigger("task_success")
	DeleteTrigger("task_failed")
	DeleteTrigger("stat_task_skill")
end

--��������
function task.AlarmNextTask()
	EnableTimer("task_alarmer", true)
	ResetTimer("task_alarmer")
end

--����Ҫ��������
function task.CanAskNewTask()
	EnableTimer("task_alarmer", false)
	ResetTimer("task_alarmer")
	message.Note ("���Կ�ʼ�¸�����")
end

--ɱ��
function task.KillGuai (name, line, wildcards, styles)
	--command.Run("perform qianyan")
	command.Run("follow " .. string.lower(task.target.id))
	command.Run("fight ".. string.lower(task.target.id))
end

--ɱ��2����killָ��
function task.KillGuai2 (name, line, wildcards, styles)
	command.Run("kill ".. string.lower(task.target.id))
end

--������������
function task.TieGuai(name, line, wildcards, styles)
	command.Run("tie ".. string.lower(task.target.id))
end

--ʩ����
function task.CastOnGuai ( commandstring )
	command.Run(commandstring .. " " .. string.lower(task.target.id))
end

--����һ�������ɺ��ڣ�
