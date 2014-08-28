--Module: study_patch_tianmotai.lua

--天魔台练妖法的补丁
require "tprint"
require "addxml"

study.patch.tianmotai={}

--local exitfromhonglou="u;ask girl about back"
local taiaction="pa tai"
local dongrooms="大殿;殿门;后洞;彩楼;寝室;偏洞;甬道;兵器库;厨房;前洞;卧房;洞门"
local fromdongtocliff="set brief;west;west;south;south;south;south;south;east;south;south;south;n;n;n;e;e;push men"
local hillrooms="山腹;山谷;黑松林;山顶"
local fromhilltocliff="set brief;southwest;southup;southup;westup;dive dong;n;n;n;e;e;push men"
local entertai="set brief;w;turn 9657;pa tai"

local jumpfrom = false

--从天魔台进入红楼了
function study.patch.tianmotai.Invoke()
	addxml.trigger { name="patch_getexitroom", 
					match="^(?P<room_name>\\S+)\\s\\-\\s$",
					group="Patch",
					enabled=false,
					sequence=20,
					script="study.patch.tianmotai.OnGetExitRoom",
					regexp="y"}
	addxml.trigger { name="patch_actionend", 
					match="^>",
					group="Patch",
					enabled=false,
					sequence=20,
					script="study.patch.tianmotai.OnActionEnd",
					regexp="y"}
	addxml.trigger { name="patch_faint", 
					match="^慢慢地你终于又有了知觉",
					group="Patch",
					enabled=false,
					sequence=20,
					script="study.patch.tianmotai.OnWakeup",
					regexp="y"}
	addxml.trigger { name="patch_needwait", 
					match="^你现在不能用魔法！$",
					group="Patch",
					enabled=false,
					sequence=20,
					script="study.patch.tianmotai.OnNeedWait",
					regexp="y"}

	walk.WalkEndCallback = study.patch.tianmotai.Begin
	walk.WalkPath ( "u" )
end

function study.patch.tianmotai.Begin()
	EnableTrigger("patch_getexitroom", true)
	command.RunOnly("ask girl about back")
end

study.patch.tianmotai.roomname=""
function study.patch.tianmotai.OnGetExitRoom (name, line, wildcards, styles)
	EnableTrigger("patch_getexitroom", false)
	EnableTrigger("patch_needwait", false)
	
	--判断出来的房间
	study.patch.tianmotai.roomname=wildcards["room_name"]
	if ( study.patch.tianmotai.roomname == "崖底" ) then
		if ( jumpfrom ) then
			--跳到悬崖下面了，等待醒来
			jumpfrom = false
			return EnableTrigger("patch_faint", true)
		end
	end

	--等待输出结束
	EnableTrigger("patch_actionend", true)
end

function study.patch.tianmotai.OnActionEnd (name, line, wildcards, styles)
	EnableTrigger("patch_actionend", false)
	if ( study.patch.tianmotai.roomname == "暗室" ) then
		--在天魔台房间，直接继续学习吧
		command.Run(taiaction, study.patch.tianmotai.End)
	elseif ( study.patch.tianmotai.roomname == "秘洞" ) then
		study.patch.tianmotai.Jump()
	elseif ( study.patch.tianmotai.roomname == "绝崖" ) then
		walk.WalkEndCallback = study.patch.tianmotai.End
		walk.WalkPath ( entertai )
	else
		--判断是不是在后山
		local room_list = utils.split (hillrooms, ";")
		for _, v in pairs(room_list) do
			if ( study.patch.tianmotai.roomname == v ) then
				return study.patch.tianmotai.FindWayBack (fromhilltocliff)
			end
		end
		--判断是不是在洞内
		room_list = utils.split(dongrooms,  ";")
		for _, v in pairs(room_list) do
			if ( study.patch.tianmotai.roomname == v ) then
				return study.patch.tianmotai.FindWayBack (fromdongtocliff)
			end
		end
		--如果不是，则不断用土遁
		study.patch.tianmotai.Tudun()
	end
end

--用cast tudun
function study.patch.tianmotai.Tudun()
	--判断是否需要恢复体力，否则无法土遁
	command.Run("hp", study.patch.tianmotai.Recover)
end

function study.patch.tianmotai.Recover()
	--先进行恢复
	me.state.RecoverEndCallback = study.patch.tianmotai.OnRecoverEnd
	me.state.Recover()
end

function study.patch.tianmotai.OnRecoverEnd()
	--恢复完毕，就进行土遁
	EnableTrigger("patch_getexitroom", true)
	EnableTrigger("patch_needwait", true)

	jumpfrom = false
	command.RunOnly("cast tudun")
end

function study.patch.tianmotai.OnNeedWait (name, line, wildcards, styles)
	--如果需要等待，则等待10秒再用土遁
	return DoAfterSpecial(10, "study.patch.tianmotai.OnRecoverEnd()", 12)
end

--醒来后再次土遁
function study.patch.tianmotai.OnWakeup (name, line, wildcards, styles)
	EnableTrigger("patch_faint", false)
	study.patch.tianmotai.Tudun()
end

--找到去秘洞的路
function study.patch.tianmotai.FindWayBack (pathes)
	walk.WalkEndCallback = study.patch.tianmotai.Jump
	walk.WalkPath ( pathes )
end

--跳过悬崖
function study.patch.tianmotai.Jump()
	EnableTrigger("patch_getexitroom", true)
	jumpfrom = true
	DoAfterSpecial(1, "jump", 10)
end

function study.patch.tianmotai.End()
	DeleteTrigger("patch_getexitroom")
	DeleteTrigger("patch_faint")
	DeleteTrigger("patch_needwait")
	DeleteTrigger("patch_actionend")
	study.patch.EndInvoke()
end