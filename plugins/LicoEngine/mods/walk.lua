--Module: walk.lua
--����ģ��
require "tprint"
require "addxml"

loadmod("walk_path.lua")

--�����busy�Ķ���
--��Ķ�����û����ɣ������ƶ���
--local busy_actions = {"buy", "dive", "withdraw", "deposit", "cast", "exert", "dazuo", "mingsi", "lian", "study", "learn", "fly"}
--local busy_waitseconds = 2	--busy�������µ���ʱ

local walk_success_pattern = "^(?P<room_name>\\S+)\\s\\-\\s$"
local walk_failed_patterns = {"^�������û�г�·��$", 
					"^��Ķ�����û����ɣ������ƶ���$", 
					"^��������æ���ء�$",
					"^(?P<blocker_name>\\S+)һ��ץס���㣡$", 
					"^����Ҫ�뿪����Ȼ����ʲô��������ǰһ�Σ����ɵ�ͣ��������$",
					"^ʲô��$",
					--"^������û�����ֻ�Ʒ��$",
					"^��û���㹻��Ǯ��$"}
local action_failed_patterns = {"^��Ķ�����û����ɣ������ƶ���$", 
					"^��������æ���ء�$",
					"^(?P<blocker_name>\\S+)һ��ץס���㣡$", 
					"^����Ҫ�뿪����Ȼ����ʲô��������ǰһ�Σ����ɵ�ͣ��������$",
					"^ʲô��$",
					--"^������û�����ֻ�Ʒ��$",
					"^��û���㹻��Ǯ��$"}
local walk_block_wait = 0		--�ܵ�����ʱ�ȴ���ʱ��

--�����б�
local dir_list = {"n", "e", "s", "w", "ne", "se", "sw", "nw", "u", "d", "nu", "nd", "eu", "ed", "su", "sd", "wu", "wd", "enter", "out", "backyard", "frontyard", "swim", "dive", "right", "left", "climb tree"}

--�뷽���Ӧ�ķ������б�
local dirb_list={"s", "w", "n", "e", "sw", "nw", "ne", "se", "d", "u", "sd", "su", "wd", "wu", "nd", "nu", "ed", "eu", "out", "enter", "frontyard", "backyard", "swim", "u", "left", "right", "d"}

--state: 0-����, 1-��ͣ, 2-æ, 3-������, 4-ֹͣ
local walk_state_normal = 0
local walk_state_pause = 1
local walk_state_busy = 2
local walk_state_blocked = 3
local walk_state_stop = 4

--�ж��б�step-��ǰ������steps-�ܲ�����command-��ǰָ�zone-Ŀ������state-�Ƿ�������blocker-������
local action_flag = {step=0, steps=0, command="", 
			state=walk_state_normal, blocker="",
			need_find_object=false, object_found=false, room_name = ""}

function action_flag.init ()
	action_flag.step=0
	action_flag.steps=0
	action_flag.command=""
	action_flag.state=walk_state_normal
	action_flag.blocker=""
	action_flag.need_find_object=false
	action_flag.object_found=false
	action_flag.room_name = ""
end

--Ŀ��·��
local target_path = {}
local target_zone = ""

--��Ҫ����Ѱ�Ҷ������ⲿָ��
local object_tofind = {id="", name=""}

walk = {}

--���뵽�����еĴ�������
--room_name: ������
--real_entered: �Ƿ��������뵽���䣬�п�������Ϊlook���·��䴥��
function walk.EnterRoomCallback_Inner(room_name, real_entered)
	if ( real_entered ) then
		print ("���룺", room_name)
	else
		print ("������", room_name)
	end
end
walk.EnterRoomCallback = walk.EnterRoomCallback_Inner

--Ŀ������ҵ��˵Ļص�����
function walk.TargetFindCallback_Inner(room_name)
	message.Note("�ҵ�"..object_tofind.name.."��")
end
walk.TargetFindCallback = walk.TargetFindCallback_Inner

--�ܵ������Ļص�����
function walk.BlockedCallback_Inner(room_name, blocker)
	message.Note("��"..blocker.."����")
end
walk.BlockedCallback = walk.BlockedCallback_Inner

function walk.WalkEndCallback_Inner(object_found, walk_end, state)
	print("��������")
end
--���������ص�����
walk.WalkEndCallback = walk.WalkEndCallback_Inner

--��������
local function WalkEnd()
	--����������ҹ֣������Ѿ��ҵ��˵�����£��������������û�ҵ������Ȳ�ɾ�����������ֶ��ң�
	if( action_flag.need_find_object and object_found) then
		DeleteTrigger("object_tofind")
	end

	walk.WalkEndCallback(action_flag.object_found, (action_flag.step == action_flag.steps), action_flag.state)
	--�ָ��¼����
	walk.WalkEndCallback = walk.WalkEndCallback_Inner
end --WalkEnd

--����һ���ж�
local function WalkOneStep ( )
	--����ж��Ĳ����Ѿ��ﵽ�ܲ�������ֹͣ����
	if ( action_flag.step >= action_flag.steps ) then
		return WalkEnd()
	end

	action_flag.step = action_flag.step + 1
	action_flag.command = target_path[action_flag.step]

	print("Current command:", action_flag.command)
	print("Current step:", action_flag.step)

	-- ��鵱ǰ�����Ƿ���Ҫ�����ж�ȷ�ϣ���Ϊ���߶���
	local failedpatterns = action_failed_patterns
	action_flag.state=walk_state_normal
	local v
	for _, v in pairs(dir_list) do
		if ( action_flag.command == v ) then
			action_flag.state=walk_state_blocked	--��������߶�����ȷ�ϴ��ڱ���ֹ״̬��ֻ�н��뷿��󣬲�����Ϊ����״̬
			failedpatterns = walk_failed_patterns
			break
		end
	end
	command.RunWithConfirm ( action_flag.command, 
							walk.OnActionOutputEnd,  
							walk_success_pattern, 
							walk.OnWalkSuccess,
							failedpatterns,
							walk.OnWalkFailed)
end --WalkOneStep

--����ָ����·����������
local function WalkPathAndZone( path_list, zone_name )
	need_stop = false

	--���ڴ���·������Ϊ��;�ŷָ����ַ��������Ҫת��Ϊ���
	--tprint(split(path_list, ";"))
	target_path = utils.split(path_list, ";")
	target_zone = zone_name

	action_flag.steps=table.getn(target_path)

	--��ֹ������ʱ������
	system.ResetTimers ()

	WalkOneStep()
end

--������ҪѰ�ҵ�Ŀ��
--id: Ŀ��id
--name: Ŀ����
local function SetObjectToFind(id, name)
	object_tofind = {id=id, name=name}
	action_flag.need_find_object = true
	action_flag.object_found = false

	local pattern = "^\\s+(?P<desp>\\S+)\\s+" .. name .. "\\(" .. id .. "\\)$"
	addxml.trigger { name="object_tofind", 
				match=pattern,
				group="Walk",
				enabled=true,
				sequence=100,
				script="walk.OnFoundObject",
				regexp="y"}
end --SetObjectToFind

--���߱���ָ��������
--target_zone: Ŀ������Ӣ����
function walk.WalkZone ( target_zone )
	action_flag.init()
	if ( not target_zone ) then
		Note("û�ж���Ŀ������")
		return
	end
	local path_list = pathes[target_zone]
	if ( not path_list ) then
		Note("Ŀ������δ�ҵ�")
		return
	end
	WalkPathAndZone ( path_list, target_zone )
end --WalkTo

--����ָ����·������
function walk.WalkPath ( path_list )
	action_flag.init()
	if ( not path_list ) then
		Note("û�ж���·��")
		return
	end

	WalkPathAndZone( path_list, "" )
end

--����ָ���������Լ�Ѱ�Ҷ���
function walk.WalkZoneAndFindObject (target_zone, obj_id, obj_name)
	action_flag.init()

	if ( obj_id and obj_name ) then
		SetObjectToFind (obj_id, obj_name)
	end

	if ( not target_zone ) then
		return Note("û�ж���Ŀ������")
	end
	local path_list = pathes[target_zone]
	if ( not path_list ) then
		return Note("Ŀ������δ�ҵ�")
	end
	if ( not obj_id or not obj_name ) then
		return Note("û�ж�����Ҷ����id������")
	end

	WalkPathAndZone ( path_list, target_zone )
end

--��ͣ����
function walk.Pause()
	message.Note("��ͣ")
	action_flag.state = walk_state_pause
end

--��������
function walk.Continue()
	message.Note("����")
	action_flag.state = walk_state_normal
	WalkOneStep ()
end

--ֹͣ����
function walk.Stop()
	action_flag.state = walk_state_stop
end

-- �ж����������������
function walk.OnActionOutputEnd ()
	if ( action_flag.state == walk_state_stop or ( action_flag.need_find_object and action_flag.object_found ) ) then
		--ֹͣ״̬���ҵ������壬���߽���
		return WalkEnd()
	elseif ( action_flag.state == walk_state_pause ) then
		--��ͣ״̬�£����ж�
	elseif ( action_flag.state == walk_state_blocked ) then
		--��ֹ״̬�£���������˵ȴ�ʱ�䣬��ȴ�һ��ʱ������ִ��
		action_flag.step = action_flag.step - 1

		if ( walk_block_wait == 0 ) then
			walk_block_wait = tonumber(GetVariable("walk_block_wait"))
		end

		if ( walk_block_wait > 0 ) then
			message.Note("����ֹ���ȴ�"..walk_block_wait.."��")
			DoAfterSpecial (walk_block_wait, "walk.Continue()", 12)
		else
			message.Note("����ֹ����ͣ")
		end
	elseif ( action_flag.state == walk_state_busy ) then
		action_flag.step = action_flag.step - 1
		message.Note ("��æ���ȴ�2������ִ��")
		DoAfterSpecial (2, "walk.Continue()", 12)
	else --����״̬��
		WalkOneStep ()
	end
end

--������һ���ɹ�
function walk.OnWalkSuccess ( line, wildcards )
	action_flag.state = walk_state_normal
	if ( wildcards ) then
		room_name = wildcards["room_name"]
		walk.EnterRoomCallback ( room_name, string.sub(action_flag.command, 1, 1) ~= "l" )
		walk.EnterRoomCallback = walk.EnterRoomCallback_Inner
	end
end

--����ʧ��
function walk.OnWalkFailed (line, wildcards)
	local i, j, v
	if ( line == "�������û�г�·��" ) then
		message.Note("·������")
		walk.Stop()
	elseif ( line == "��Ķ�����û����ɣ������ƶ���" ) then
		action_flag.state = walk_state_busy
	elseif ( line == "��������æ���ء�" ) then
		action_flag.state = walk_state_busy
	elseif ( line == "ʲô��" ) then
		--�޷�ʶ���ָ���Ҫ����ִ����һ��ָ��
		action_flag.state = walk_state_normal
	elseif ( line == "������û�����ֻ�Ʒ��") then
		--û���򵽱�Ҫ�Ķ�������Ҫ��ͣ
		action_flag.state = walk_state_pause
	elseif ( line == "��û���㹻��Ǯ��") then
		--û���㹻��Ǯ����
		action_flag.state = walk_state_pause
	else
		i, j = string.find(line, "һ��ץס���㣡")
		if ( i and i > 0 ) then
			--������·
			walk.SomeOneBlocked (line, wildcards)
		else
			i, j = string.find(line, "����Ҫ�뿪����Ȼ����ʲô��������ǰһ�Σ����ɵ�ͣ��������")
			if ( i and i > 0 ) then
				walk.SomeOneBlocked (line, wildcards)
			else
				--����δ֪�������Ҫ��ͣ����
				walk.Pause()
			end
		end
	end
end --OnWalkFailed

--������ֹ
function walk.SomeOneBlocked (line, wildcards)
	action_flag.state = walk_state_blocked
	walk.BlockedCallback(action_flag.room_name, wildcards["blocker_name"] or "")
	walk.BlockedCallback = walk.BlockedCallback_Inner
end --SomeOneBlocked

--���ñ���ֹ�󣬵ȴ�����ټ�������
function walk.SetBlockWaitTime( seconds )
	walk_block_wait  = seconds
end

--�����������ҵ���Ŀ������
function walk.OnFoundObject (name, line, wildcards, styles)
	action_flag.object_found = true
	action_flag.need_stop = true
	EnableTrigger("object_tofind", false)
	return DoAfterSpecial(0.5, "walk.OnFoundObjectExec()", 12)
end  -- FoundObject

-- ��ʱ�����ִ�д���
function walk.OnFoundObjectExec ()
	--���ûص�������֪ͨ�ⲿĿ���Ѿ��ҵ�
	walk.TargetFindCallback(action_flag.room_name)
	walk.TargetFindCallback = walk.TargetFindCallback_Inner
end
