--Module: map_room.lua

--���ڱ������������

map.Room = {
	name="",
	exits = {}						--��������Щ����
}

--���캯��
function map.Room:new ( o )
	o = o or {	name="", exits = {}	}   --��������Щ����
	setmetatable(o, self)
	self.__index = self
	return o
end

map.Direction = {nextroom = nil, walked = false}

--���캯��
function map.Direction:new ( o )
	o = o or {nextroom = nil, walked = false}
	setmetatable(o, self)
	self.__index = self
	return o
end
--function Room: