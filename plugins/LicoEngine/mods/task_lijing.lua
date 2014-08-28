-- Module: task_lijing.lua
-- �����ģ��

require "addxml"
require "tprint"

task.lijing = {}

--�˵�����Ϸ�������ȥ�����Ұ��߹���
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
				match="^����������йء�" .. ask_target .. "������Ϣ��$",
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
				match="^�����˵��������(?P<mobname>\\S+)\\((?P<mobid>.*)\\)��(?P<moblocation>\\S+)Ϊ������������ȥ������$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.GetTaskInfo",
				regexp="y"}
	task.GetTaskInfoEndCallback = task.lijing.OnGetTaskInfoEnd
end

--�ֻ���
function task.lijing.RegetTask (name, line, wildcards, styles)
	message.Note(wildcards[1].."����")
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

--Ҫ�������
function task.lijing.GotoChangan()
	--����ͳ������
	local count = tonumber(GetVariable("task_lj_count")) or 0
	count = count + 1
	SetVariable("task_lj_count", tostring(count))

	--EnableTrigger("get_task_info", false)

	addxml.trigger { name="reach_changan", 
				match="^ֻ��\\S+����(.*)���������˳�����$",
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

--���ﳤ��+
function task.lijing.OnReached (name, line, wildcards, styles)
	EnableTrigger ("reach_changan", false)
	message.Note("��ʼ�ҹ�")
	DoAfterSpecial(0.5, "task.lijing.StartLookup()", 12)
	DoAfterSpecial(0.2, "task.lijing.RemoveInfoTriggers()", 12)
end

function task.lijing.RemoveInfoTriggers()
	DeleteTrigger("begin_lijing_task")
	DeleteTrigger("get_task_info")
	DeleteTrigger("reach_changan")
end

--��ʼѰ��Ŀ�����
function task.lijing.StartLookup()
	task.TaskEndCallback = task.lijing.OnTaskEnd
	return task.GeneralLookup("^����������Ʈ�¼�ҳ���飬������Ļ��С�$")
end

--��õ���һ��������
--�������
function task.lijing.OnTaskEnd( is_success )
	if( is_success ) then
		--ͳ������
		local success = tonumber(GetVariable("task_lj_success")) or 0
		local count = tonumber(GetVariable("task_lj_count")) or 0
		success = success + 1
		message.Note ("�ѳɹ�" .. success .. "/" .. count .. "�Σ��")

		if ( task.stat.recount ) then
			success = 0
			count = 0
			task.stat.recount = false
		end
		SetVariable("task_lj_count", tostring(count))
		SetVariable("task_lj_success", tostring(success))

		addxml.trigger { name="stat_task_wx", 
				match="^�������õ���(?P<wx_count>\\S+)����ѧ��$",
				group="Task",
				enabled=true,
				sequence=50,
				script="task.lijing.TaskStatWx",
				regexp="y"}
		addxml.trigger { name="stat_task_qn", 
				match="^�������õ���(?P<qn_count>\\S+)��Ǳ�ܣ�$",
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