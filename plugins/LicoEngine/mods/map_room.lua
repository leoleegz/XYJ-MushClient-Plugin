--Module: map_room.lua

--用于遍历房间的数据

map.Room = {
	name="",
	exits = {}						--房间有哪些出口
}

--构造函数
function map.Room:new ( o )
	o = o or {	name="", exits = {}	}   --房间有哪些出口
	setmetatable(o, self)
	self.__index = self
	return o
end

map.Direction = {nextroom = nil, walked = false}

--构造函数
function map.Direction:new ( o )
	o = o or {nextroom = nil, walked = false}
	setmetatable(o, self)
	self.__index = self
	return o
end
--function Room: