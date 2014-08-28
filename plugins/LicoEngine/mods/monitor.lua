-- Module: monitor.lua
-- ���ģ�飬��ֹ����

monitor = {}

-- ��Ӽ��Ӵ�����
addxml.trigger { name="monitor_mobs", 
				match="^(?P<killer_name>\\S+)�����㣬����ֱ����ˮ���ٺ٣�����$",
				group="Monitor",
				enabled=false,
				sequence=50,
				script="monitor.FocusedByMobs",
				regexp="y"}

addxml.trigger { name="warn_mobs", 
				match="^��������ɱ���㣡$",
				group="Monitor",
				enabled=false,
				sequence=50,
				script="monitor.SomeWantKillMe",
				regexp="y"}

function monitor.SomeWantKillMeCallback_Inner ( )
	message.Note("��ˮ��Ҫɱ��", "red")
	command.RunOnly("quit")
end
monitor.SomeWantKillMeCallback = monitor.SomeWantKillMeCallback_Inner


--����ˮ�ֶ���
function monitor.FocusedByMobs (name, line, wildcards, styles)
	local mob_name = wildcards["killer_name"]
	message.Note("����ˮ��"..wildcards["killer_name"].."����", "red")
	SetTriggerOption("warn_mobs", "match", "^������"..mob_name.."��ɱ���㣡$")
	EnableTrigger("warn_mobs", true)
end

--��ˮ��Ҫɱ��
function monitor.SomeWantKillMe (name, line, wildcards, styles)
	monitor.SomeWantKillMeCallback ( )
	monitor.SomeWantKillMeCallback = monitor.SomeWantKillMeCallback_Inner
end

function monitor.KeepConnected (name, line, wildcards, styles)
	if ( not world.IsConnected() ) then
		message.Note("���ߣ���������")
		world.Connect ( )
	end
end
