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

--进入到房间的回调函数
function map.EnterRoomCallback_Inner(room)
	--print ( "到了新房间：" .. room.exits )
	return true
end
map.EnterRoomCallback = map.EnterRoomCallback_Inner

--在一个地图里面找到指定的出口
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
			print("找到".. map.exit_need .. "了")
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
		--第一次走
		current_room = map.Room:new()
		current_isnew = true
		current_name = ""
		last_room = current_room
	else
		last_room = current_room
		if ( last_room[direction] ) then		--如果有该方向
			if ( last_room[direction].nextroom ) then	--该方向已经有房间记录
				current_room = last_room[direction].nextroom
				current_isnew = false
			else
				current_room = map.Room:new()
				current_isnew = true
				current_name = ""

				--下一个房间的反方向为上一个房间
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

--设置触发器，获取房间的出口
function map.SetTriggers()
	addxml.trigger { name="get_roomname", 
				match="^(?P<room_name>\\S+)\\s\\-\\s$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnGetRoomName",
				regexp="y"}
	addxml.trigger { name="get_directions", 
				match="^\\s+这里(明显|唯一)的出口是\\s(?P<dir>.+)。$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnGetDirections",
				regexp="y"}
	addxml.trigger { name="no_directions", 
				match="^\\s+这里没有明显的出口。$",
				group="Map",
				enabled=true,
				sequence=100,
				script="map.OnNoDirection",
				regexp="y"}
end

function map.OnGetRoomName (name, line, wildcards, styles)
	current_name = wildcards["room_name"]
end

--拿到房间的出口信息了，解析出口
function map.OnGetDirections (name, line, wildcards, styles)
	if ( wildcards[1] == "唯一" ) then
		current_exits = {}
		current_exits[1] = wildcards[2]
	else
		local dirlist = string.gsub(wildcards[2], " 和 ", ",")
		dirlist = string.gsub(dirlist, "、", ",")

		current_exits = utils.split(dirlist, ",")
	end
	--tprint(current_exits)
end

--该房间没有任何出口
function map.OnNoDirection (name, line, wildcards, styles)
	current_exits = {}
end

function map.NewRoomEntered()
	map.ClearTriggers()
	
	if ( current_isnew ) then			--如果是新房间
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
		print("遍历结束")
		return
	end
	
	local dir = map.FindDirectionNotwalked( current_room )

	if ( dir ) then
		map.GotoNextRoom(dir)
	else
		--遍历结束
		print("遍历结束，所有房间已经走遍")
	end
end

--找到房间里没有走过的方向
function map.FindDirectionNotwalked(room)
	local j = table.getn(room.exits)

	--找出一个没有走过的方向，并且不是反向的
	for i = 1, j do
		local dir = room.exits[i]
		if( not room[dir].walked and room[dir].nextroom == nil) then
			return dir
		end
	end

	--找到没走过的反向
	for i = 1, j do
		local dir = room.exits[i]
		if( not room[dir].walked) then
			return dir
		end
	end

	--如果没有找到，则返回空值
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
