--Module: study_patch_tianmotai.lua

--��ħ̨�������Ĳ���
require "tprint"
require "addxml"

study.patch.tianmotai={}

--local exitfromhonglou="u;ask girl about back"
local taiaction="pa tai"
local dongrooms="���;����;��;��¥;����;ƫ��;��;������;����;ǰ��;�Է�;����"
local fromdongtocliff="set brief;west;west;south;south;south;south;south;east;south;south;south;n;n;n;e;e;push men"
local hillrooms="ɽ��;ɽ��;������;ɽ��"
local fromhilltocliff="set brief;southwest;southup;southup;westup;dive dong;n;n;n;e;e;push men"
local entertai="set brief;w;turn 9657;pa tai"

local jumpfrom = false

--����ħ̨�����¥��
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
					match="^������������������֪��",
					group="Patch",
					enabled=false,
					sequence=20,
					script="study.patch.tianmotai.OnWakeup",
					regexp="y"}
	addxml.trigger { name="patch_needwait", 
					match="^�����ڲ�����ħ����$",
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
	
	--�жϳ����ķ���
	study.patch.tianmotai.roomname=wildcards["room_name"]
	if ( study.patch.tianmotai.roomname == "�µ�" ) then
		if ( jumpfrom ) then
			--�������������ˣ��ȴ�����
			jumpfrom = false
			return EnableTrigger("patch_faint", true)
		end
	end

	--�ȴ��������
	EnableTrigger("patch_actionend", true)
end

function study.patch.tianmotai.OnActionEnd (name, line, wildcards, styles)
	EnableTrigger("patch_actionend", false)
	if ( study.patch.tianmotai.roomname == "����" ) then
		--����ħ̨���䣬ֱ�Ӽ���ѧϰ��
		command.Run(taiaction, study.patch.tianmotai.End)
	elseif ( study.patch.tianmotai.roomname == "�ض�" ) then
		study.patch.tianmotai.Jump()
	elseif ( study.patch.tianmotai.roomname == "����" ) then
		walk.WalkEndCallback = study.patch.tianmotai.End
		walk.WalkPath ( entertai )
	else
		--�ж��ǲ����ں�ɽ
		local room_list = utils.split (hillrooms, ";")
		for _, v in pairs(room_list) do
			if ( study.patch.tianmotai.roomname == v ) then
				return study.patch.tianmotai.FindWayBack (fromhilltocliff)
			end
		end
		--�ж��ǲ����ڶ���
		room_list = utils.split(dongrooms,  ";")
		for _, v in pairs(room_list) do
			if ( study.patch.tianmotai.roomname == v ) then
				return study.patch.tianmotai.FindWayBack (fromdongtocliff)
			end
		end
		--������ǣ��򲻶�������
		study.patch.tianmotai.Tudun()
	end
end

--��cast tudun
function study.patch.tianmotai.Tudun()
	--�ж��Ƿ���Ҫ�ָ������������޷�����
	command.Run("hp", study.patch.tianmotai.Recover)
end

function study.patch.tianmotai.Recover()
	--�Ƚ��лָ�
	me.state.RecoverEndCallback = study.patch.tianmotai.OnRecoverEnd
	me.state.Recover()
end

function study.patch.tianmotai.OnRecoverEnd()
	--�ָ���ϣ��ͽ�������
	EnableTrigger("patch_getexitroom", true)
	EnableTrigger("patch_needwait", true)

	jumpfrom = false
	command.RunOnly("cast tudun")
end

function study.patch.tianmotai.OnNeedWait (name, line, wildcards, styles)
	--�����Ҫ�ȴ�����ȴ�10����������
	return DoAfterSpecial(10, "study.patch.tianmotai.OnRecoverEnd()", 12)
end

--�������ٴ�����
function study.patch.tianmotai.OnWakeup (name, line, wildcards, styles)
	EnableTrigger("patch_faint", false)
	study.patch.tianmotai.Tudun()
end

--�ҵ�ȥ�ض���·
function study.patch.tianmotai.FindWayBack (pathes)
	walk.WalkEndCallback = study.patch.tianmotai.Jump
	walk.WalkPath ( pathes )
end

--��������
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