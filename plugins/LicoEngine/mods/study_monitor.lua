--Module: study_monitor.lua

--��ֹ����������

--��Ȼһ��Ʒ��Х�����������ɼ������˽�ȥ��l
--�㱻�ص�һ��ˤ�ڵ��ϣ�
--���� - 
--zuan
--��������ŵ����һ��С���������ˣ�����
--�����һ�������ص�ˤ����ȥ��
--��Ķ�����û����ɣ������ƶ���
--out
--������ - 
--    ����Ψһ�ĳ����� westdown��
--���ݸ� - 
--    �������Եĳ����� southdown��north �� enter��

require "addxml"
require "tprint"

study.monitor = {}

function study.monitor.OnFallInToJail()
	message.Note("����������")
	DoAfterSpecial(5, "study.monitor.StartEscape()", 12)
end

function study.monitor.StartEscape()
	addxml.trigger { name="monitor_escape", 
						match="^���μ��Ѿ�������",
						group="Study",
						enabled=true,
						sequence=20,
						keep_evaluating="y",
						script="study.monitor.OnZuanEnd",
						regexp="y"}
	command.RunOnly ( "l;zuan;l;l;l;uptime")
end

function study.monitor.OnRoomEntered( room )
	local j = table.getn(room.exits)
	for i = 1, j do
		if ( room.exits[i] == "out" ) then
			print("�ҵ�������")
			map.EndTraverse()
			DoAfterSpecial(1, "study.monitor.AfterAction()", 12)
			return false
		end
	end
	return true
end

function study.monitor.OnZuanEnd(name, line, wildcards, styles)
	DoAfterSpecial(1, "study.monitor.FindWayOut ()", 12)
	EnableTrigger("monitor_escape", false)
end

--�ҵ���·
function study.monitor.FindWayOut ()
	DeleteTrigger("monitor_escape")
	map.EnterRoomCallback = study.monitor.OnRoomEntered
	map.BeginTraverse()
end

function study.monitor.AfterAction()
	message.Note("�ҵ���·�ˣ���ȥ")

	--local backpath = GetVariable("escape_path")
	local backpath = study.places.escape_path[study.place]
	walk.WalkEndCallback = study.monitor.OnBack
	walk.WalkPath ( backpath )
end

function study.monitor.OnBack()
	message.Note("�����ˣ�����ѧϰ")
	command.RunOnly("xx")
end