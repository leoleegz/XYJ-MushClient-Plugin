-- Module: task_yuan.lua
-- ��Ԭ�������Ҫ����

require "addxml"
require "tprint"

task.yuan = {}

function task.yuan.Ask()
	addxml.trigger { name="begin_yuan_task", 
				match="^����Ԭ������йء�kill������Ϣ��$",
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
				match="^Ԭ���������ľ�����ķ�һ��������˵����$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.GetTask",
				regexp="y"}
	addxml.trigger { name="no_yuan_task", 
				match="^Ԭ���������ľ���������£�˵����л\\S+,��ħ�Ѿ������ˡ�$",
				group="Task",
				enabled=true,
				sequence=100,
				script="task.yuan.NoTask",
				regexp="y"}
	addxml.trigger { name="reget_yuan_task", 
				match="^Ԭ���˵�������²�������ȥ�շ�(\\S+)��$",
				group="Task",
				enabled=true,
				sequence=100,
				script="task.yuan.RegetTask",
				regexp="y"}
end

function task.yuan.NoTask (name, line, wildcards, styles)
	message.Note("��ʱû������")
	EnableTrigger("get_yuan_task", false)
	DoAfterSpecial(0.5, "task.yuan.RemoveInfoTriggers()", 12)
end

function task.yuan.RegetTask (name, line, wildcards, styles)
	message.Note(wildcards[1].."����")
	DoAfterSpecial(0.5, "task.yuan.RemoveInfoTriggers()", 12)
end

function task.yuan.GetTask (name, line, wildcards, styles)
	EnableTrigger("no_yuan_task", false)
	addxml.trigger { name="get_task_info", 
				match="^��������(?P<mobname>\\S+)\\((?P<mobid>.*)\\)��(?P<moblocation>\\S+)��û��Ϊ����С������ȥ�շ���$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.GetTaskInfo",
				regexp="y"}
	task.GetTaskInfoEndCallback = task.yuan.GetTipsInfo
end

function task.yuan.GetTipsInfo()
	--
	--����ͳ������
	local count = tonumber(GetVariable("task_yuan_count")) or 0
	count = count + 1
	SetVariable("task_yuan_count", tostring(count))

	EnableTrigger("get_task_info", false)
	addxml.trigger { name="get_tips_info", 
				match="^Ԭ���������˼�ض���һ�٣��ֵ�����������������Ԩ�����ķ��䣬Ҳ�������а�����$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.yuan.GotoGetTips",
				regexp="y"}
	
end

function task.yuan.GotoGetTips (name, line, wildcards, styles)
	EnableTrigger("get_tips_info", false)
	walk.WalkEndCallback = task.yuan.EndGetTips
	--��ȥ�������÷�
	walk.WalkPath(pathes.wuxudaozhang)
end

--�õ�����
function task.yuan.EndGetTips(object_found, walk_end, state)
	task.has_tip = true
	task.yuan.RemoveInfoTriggers()
	message.Note("�õ����ˣ���ʼ�ҹ�")
	DoAfterSpecial(0.5, "task.yuan.StartLookup()", 12)
end

--��ʼѰ��Ŀ�����
function task.yuan.StartLookup()
	task.TaskEndCallback = task.yuan.OnTaskEnd
	return task.GeneralLookup("^"..task.target.name.."�ҽ�һ�������ˡ�$", "^"..task.target.name.."���ˣ�������û�еõ���ѧ�����Ǳ�ܡ�")
end

function task.yuan.RemoveInfoTriggers()
	--print("ɾ��������Ϣ������")
	DeleteTrigger("begin_yuan_task")
	DeleteTrigger("get_yuan_task")
	DeleteTrigger("no_yuan_task")
	DeleteTrigger("get_task_info")
	DeleteTrigger("get_tips_info")
	DeleteTrigger("reget_yuan_task")
end

function task.yuan.GetStatData()
	addxml.trigger { name="get_wx_qn", 
				match="^��õ���(?P<wx_count>\\S+)����ѧ�����(?P<qn_count>\\S+)��Ǳ�ܣ�$",
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
		--ͳ������
		local success = tonumber(GetVariable("task_yuan_success")) or 0
		local count = tonumber(GetVariable("task_yuan_count")) or 0
		success = success + 1
		message.Note ("�ѳɹ�" .. success .. "/" .. count .. "�Σ�Ԭ��")

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
