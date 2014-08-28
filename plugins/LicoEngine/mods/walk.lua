--Module: walk.lua
--行走模块
require "tprint"
require "addxml"

loadmod("walk_path.lua")

--会产生busy的动作
--你的动作还没有完成，不能移动。
--local busy_actions = {"buy", "dive", "withdraw", "deposit", "cast", "exert", "dazuo", "mingsi", "lian", "study", "learn", "fly"}
--local busy_waitseconds = 2	--busy动作导致的延时

local walk_success_pattern = "^(?P<room_name>\\S+)\\s\\-\\s$"
local walk_failed_patterns = {"^这个方向没有出路。$", 
					"^你的动作还没有完成，不能移动。$", 
					"^你现在正忙着呢。$",
					"^(?P<blocker_name>\\S+)一把抓住了你！$", 
					"^你正要离开，忽然看见什么东西在眼前一晃，不由得停了下来。$",
					"^什么？$",
					--"^当铺里没有这种货品。$",
					"^你没有足够的钱。$"}
local action_failed_patterns = {"^你的动作还没有完成，不能移动。$", 
					"^你现在正忙着呢。$",
					"^(?P<blocker_name>\\S+)一把抓住了你！$", 
					"^你正要离开，忽然看见什么东西在眼前一晃，不由得停了下来。$",
					"^什么？$",
					--"^当铺里没有这种货品。$",
					"^你没有足够的钱。$"}
local walk_block_wait = 0		--受到阻拦时等待的时间

--方向列表
local dir_list = {"n", "e", "s", "w", "ne", "se", "sw", "nw", "u", "d", "nu", "nd", "eu", "ed", "su", "sd", "wu", "wd", "enter", "out", "backyard", "frontyard", "swim", "dive", "right", "left", "climb tree"}

--与方向对应的反方向列表
local dirb_list={"s", "w", "n", "e", "sw", "nw", "ne", "se", "d", "u", "sd", "su", "wd", "wu", "nd", "nu", "ed", "eu", "out", "enter", "frontyard", "backyard", "swim", "u", "left", "right", "d"}

--state: 0-正常, 1-暂停, 2-忙, 3-被阻拦, 4-停止
local walk_state_normal = 0
local walk_state_pause = 1
local walk_state_busy = 2
local walk_state_blocked = 3
local walk_state_stop = 4

--行动列表：step-当前步数，steps-总步数，command-当前指令，zone-目标区域，state-是否被阻塞，blocker-阻塞者
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

--目标路径
local target_path = {}
local target_zone = ""

--需要进行寻找对象，由外部指定
local object_tofind = {id="", name=""}

walk = {}

--进入到房间中的触发函数
--room_name: 房间名
--real_entered: 是否真正进入到房间，有可能是因为look导致房间触发
function walk.EnterRoomCallback_Inner(room_name, real_entered)
	if ( real_entered ) then
		print ("进入：", room_name)
	else
		print ("看到：", room_name)
	end
end
walk.EnterRoomCallback = walk.EnterRoomCallback_Inner

--目标物件找到了的回调函数
function walk.TargetFindCallback_Inner(room_name)
	message.Note("找到"..object_tofind.name.."了")
end
walk.TargetFindCallback = walk.TargetFindCallback_Inner

--受到阻拦的回调函数
function walk.BlockedCallback_Inner(room_name, blocker)
	message.Note("被"..blocker.."阻拦")
end
walk.BlockedCallback = walk.BlockedCallback_Inner

function walk.WalkEndCallback_Inner(object_found, walk_end, state)
	print("遍历结束")
end
--遍历结束回调函数
walk.WalkEndCallback = walk.WalkEndCallback_Inner

--遍历结束
local function WalkEnd()
	--如果设置了找怪，而且已经找到了的情况下，清理触发器（如果没找到，则先不删除触发器，手动找）
	if( action_flag.need_find_object and object_found) then
		DeleteTrigger("object_tofind")
	end

	walk.WalkEndCallback(action_flag.object_found, (action_flag.step == action_flag.steps), action_flag.state)
	--恢复事件入口
	walk.WalkEndCallback = walk.WalkEndCallback_Inner
end --WalkEnd

--进行一步行动
local function WalkOneStep ( )
	--如果行动的步数已经达到总步数，则停止行走
	if ( action_flag.step >= action_flag.steps ) then
		return WalkEnd()
	end

	action_flag.step = action_flag.step + 1
	action_flag.command = target_path[action_flag.step]

	print("Current command:", action_flag.command)
	print("Current step:", action_flag.step)

	-- 检查当前动作是否需要进行行动确认，即为行走动作
	local failedpatterns = action_failed_patterns
	action_flag.state=walk_state_normal
	local v
	for _, v in pairs(dir_list) do
		if ( action_flag.command == v ) then
			action_flag.state=walk_state_blocked	--如果是行走动作，确认处于被阻止状态，只有进入房间后，才设置为正常状态
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

--按照指定的路径进行行走
local function WalkPathAndZone( path_list, zone_name )
	need_stop = false

	--由于传入路径参数为以;号分隔的字符串，因此要转换为表格
	--tprint(split(path_list, ";"))
	target_path = utils.split(path_list, ";")
	target_zone = zone_name

	action_flag.steps=table.getn(target_path)

	--防止发呆定时器干扰
	system.ResetTimers ()

	WalkOneStep()
end

--设置需要寻找的目标
--id: 目标id
--name: 目标名
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

--行走遍历指定的区域
--target_zone: 目标区域，英文名
function walk.WalkZone ( target_zone )
	action_flag.init()
	if ( not target_zone ) then
		Note("没有定义目标区域")
		return
	end
	local path_list = pathes[target_zone]
	if ( not path_list ) then
		Note("目标区域未找到")
		return
	end
	WalkPathAndZone ( path_list, target_zone )
end --WalkTo

--按照指定的路径行走
function walk.WalkPath ( path_list )
	action_flag.init()
	if ( not path_list ) then
		Note("没有定义路径")
		return
	end

	WalkPathAndZone( path_list, "" )
end

--行走指定的区域以及寻找对象
function walk.WalkZoneAndFindObject (target_zone, obj_id, obj_name)
	action_flag.init()

	if ( obj_id and obj_name ) then
		SetObjectToFind (obj_id, obj_name)
	end

	if ( not target_zone ) then
		return Note("没有定义目标区域")
	end
	local path_list = pathes[target_zone]
	if ( not path_list ) then
		return Note("目标区域未找到")
	end
	if ( not obj_id or not obj_name ) then
		return Note("没有定义查找对象的id或名称")
	end

	WalkPathAndZone ( path_list, target_zone )
end

--暂停行走
function walk.Pause()
	message.Note("暂停")
	action_flag.state = walk_state_pause
end

--继续行走
function walk.Continue()
	message.Note("继续")
	action_flag.state = walk_state_normal
	WalkOneStep ()
end

--停止行走
function walk.Stop()
	action_flag.state = walk_state_stop
end

-- 行动输出结束触发函数
function walk.OnActionOutputEnd ()
	if ( action_flag.state == walk_state_stop or ( action_flag.need_find_object and action_flag.object_found ) ) then
		--停止状态或找到了物体，行走结束
		return WalkEnd()
	elseif ( action_flag.state == walk_state_pause ) then
		--暂停状态下，不行动
	elseif ( action_flag.state == walk_state_blocked ) then
		--阻止状态下，如果设置了等待时间，则等待一段时间后继续执行
		action_flag.step = action_flag.step - 1

		if ( walk_block_wait == 0 ) then
			walk_block_wait = tonumber(GetVariable("walk_block_wait"))
		end

		if ( walk_block_wait > 0 ) then
			message.Note("被阻止，等待"..walk_block_wait.."秒")
			DoAfterSpecial (walk_block_wait, "walk.Continue()", 12)
		else
			message.Note("被阻止，暂停")
		end
	elseif ( action_flag.state == walk_state_busy ) then
		action_flag.step = action_flag.step - 1
		message.Note ("正忙，等待2秒后继续执行")
		DoAfterSpecial (2, "walk.Continue()", 12)
	else --正常状态下
		WalkOneStep ()
	end
end

--行走下一步成功
function walk.OnWalkSuccess ( line, wildcards )
	action_flag.state = walk_state_normal
	if ( wildcards ) then
		room_name = wildcards["room_name"]
		walk.EnterRoomCallback ( room_name, string.sub(action_flag.command, 1, 1) ~= "l" )
		walk.EnterRoomCallback = walk.EnterRoomCallback_Inner
	end
end

--行走失败
function walk.OnWalkFailed (line, wildcards)
	local i, j, v
	if ( line == "这个方向没有出路。" ) then
		message.Note("路径错误")
		walk.Stop()
	elseif ( line == "你的动作还没有完成，不能移动。" ) then
		action_flag.state = walk_state_busy
	elseif ( line == "你现在正忙着呢。" ) then
		action_flag.state = walk_state_busy
	elseif ( line == "什么？" ) then
		--无法识别的指令，需要继续执行下一条指令
		action_flag.state = walk_state_normal
	elseif ( line == "当铺里没有这种货品。") then
		--没有买到必要的东西，需要暂停
		action_flag.state = walk_state_pause
	elseif ( line == "你没有足够的钱。") then
		--没有足够的钱买东西
		action_flag.state = walk_state_pause
	else
		i, j = string.find(line, "一把抓住了你！")
		if ( i and i > 0 ) then
			--被怪拦路
			walk.SomeOneBlocked (line, wildcards)
		else
			i, j = string.find(line, "你正要离开，忽然看见什么东西在眼前一晃，不由得停了下来。")
			if ( i and i > 0 ) then
				walk.SomeOneBlocked (line, wildcards)
			else
				--其他未知情况，需要暂停行走
				walk.Pause()
			end
		end
	end
end --OnWalkFailed

--被人阻止
function walk.SomeOneBlocked (line, wildcards)
	action_flag.state = walk_state_blocked
	walk.BlockedCallback(action_flag.room_name, wildcards["blocker_name"] or "")
	walk.BlockedCallback = walk.BlockedCallback_Inner
end --SomeOneBlocked

--设置被阻止后，等待多久再继续行走
function walk.SetBlockWaitTime( seconds )
	walk_block_wait  = seconds
end

--触发函数：找到了目标物体
function walk.OnFoundObject (name, line, wildcards, styles)
	action_flag.object_found = true
	action_flag.need_stop = true
	EnableTrigger("object_tofind", false)
	return DoAfterSpecial(0.5, "walk.OnFoundObjectExec()", 12)
end  -- FoundObject

-- 延时后继续执行处理
function walk.OnFoundObjectExec ()
	--调用回调函数，通知外部目标已经找到
	walk.TargetFindCallback(action_flag.room_name)
	walk.TargetFindCallback = walk.TargetFindCallback_Inner
end
