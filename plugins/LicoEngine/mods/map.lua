--Module: map.lua
require "tprint"
require "addxml"

map = {}

local dir_map = {
	east="west", west="east", north="south", south="north", up="down", 	down="up", out="enter", enter="out",
	northeast="southwest", southeast="northwest", southwest="northeast", northwest="southeast", 
	northup="southdown", eastup="westdown", southup="northdown", westup="eastdown",
	northdown="eastup", westdown="eastup", southdown="northup", westdown="eastup",
	backyard="frontyard", frontyard="backyard", left="right", right="left"
	}

--local root_room = nil
local last_room = nil
current_room = nil
local current_isnew = true
local current_exits = {}
local current_name = ""

--���뵽����Ļص�����
function map.EnterRoomCallback_Inner(room)
	--print ( "�����·��䣺" .. room.exits )
	return true
end
map.EnterRoomCallback = map.EnterRoomCallback_Inner

--��һ����ͼ�����ҵ�ָ���ĳ���
map.exit_need = ""
function map.FindAnExit (exitname)
	map.exit_need = exitname
	map.EnterRoomCallback = map.OnRoomEntered
	map.BeginTraverse()
end

function map.OnRoomEntered(room)
	local j = table.getn(room.exits)
	for i = 1, j do
		if ( room.exits[i] == map.exit_need ) then
			print("�ҵ�".. map.exit_need .. "��")
			map.EndTraverse()
			return false
		end
	end
	return true
end

function map.BeginTraverse()
	--root_room = nil
	last_room = nil
	current_room = nil
	current_exits = {}
	current_isnew = true
	current_name = ""
	map.GotoNextRoom("l")
end

function map.GotoNextRoom(direction)
	if ( current_room == nil ) then
		--��һ����
		current_room = map.Room:new()
		current_isnew = true
		current_name = ""
		last_room = current_room
	else
		last_room = current_room
		if ( last_room[direction] ) then		--����и÷���
			if ( last_room[direction].nextroom ) then	--�÷����Ѿ��з����¼
				current_room = last_room[direction].nextroom
				current_isnew = false
			else
				current_room = map.Room:new()
				current_isnew = true
				current_name = ""

				--��һ������ķ�����Ϊ��һ������
				local reverse_dir = dir_map[direction]
				if ( reverse_dir ) then
					current_room[reverse_dir] = map.Direction:new()
					current_room[reverse_dir].nextroom = last_room
				end
				last_room[direction].nextroom = current_room
			end
			last_room[direction].walked = true
		end
	end

	map.SetTriggers()
	command.Run( direction, map.NewRoomEntered )
end

--���ô���������ȡ����ĳ���
function map.SetTriggers()
	addxml.trigger { name="get_roomname", 
				match="^(?P<room_name>\\S+)\\s\\-\\s$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnGetRoomName",
				regexp="y"}
	addxml.trigger { name="get_directions", 
				match="^\\s+����(����|Ψһ)�ĳ�����\\s(?P<dir>.+)��$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnGetDirections",
				regexp="y"}
	addxml.trigger { name="no_directions", 
				match="^\\s+����û�����Եĳ��ڡ�$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnNoDirection",
				regexp="y"}
end

function map.OnGetRoomName (name, line, wildcards, styles)
	current_name = wildcards["room_name"]
end

--�õ�����ĳ�����Ϣ�ˣ���������
function map.OnGetDirections (name, line, wildcards, styles)
	if ( wildcards[1] == "Ψһ" ) then
		current_exits = {}
		current_exits[1] = wildcards[2]
	else
		local dirlist = string.gsub(wildcards[2], " �� ", ",")
		dirlist = string.gsub(dirlist, "��", ",")

		current_exits = utils.split(dirlist, ",")
	end
	--tprint(current_exits)
end

--�÷���û���κγ���
function map.OnNoDirection (name, line, wildcards, styles)
	current_exits = {}
end

function map.NewRoomEntered()
	map.ClearTriggers()
	
	if ( current_isnew ) then			--������·���
		current_room.exits = current_exits
		current_room.name = current_name
		local j = table.getn(current_room.exits)
		for i = 1, j do
			local dir = current_room.exits[i]
			if ( current_room[dir] == nil ) then
				current_room[dir] = map.Direction:new()
			end
		end
	end

	local continue = map.EnterRoomCallback(current_room)
	if( not continue ) then
		print("��������")
		return
	end
	
	local dir = map.FindDirectionNotwalked( current_room )

	if ( dir ) then
		map.GotoNextRoom(dir)
	else
		--��������
		print("�������������з����Ѿ��߱�")
	end
end

--�ҵ�������û���߹��ķ���
function map.FindDirectionNotwalked(room)
	local j = table.getn(room.exits)

	--�ҳ�һ��û���߹��ķ��򣬲��Ҳ��Ƿ����
	for i = 1, j do
		local dir = room.exits[i]
		if( not room[dir].walked and room[dir].nextroom == nil) then
			return dir
		end
	end

	--�ҵ�û�߹��ķ���
	for i = 1, j do
		local dir = room.exits[i]
		if( not room[dir].walked) then
			return dir
		end
	end

	--���û���ҵ����򷵻ؿ�ֵ
	return nil
end

function map.ClearTriggers()
	DeleteTrigger("get_roomname")
	DeleteTrigger("get_directions")
	DeleteTrigger("no_directions")
end

function map.EndTraverse()
	map.EnterRoomCallback = map.EnterRoomCallback_Inner
end
