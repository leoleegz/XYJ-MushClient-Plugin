--Module: nk.lua
require "tprint"
require "addxml"

nk={}

nk.target = ""

--�����б�
nk.dir_list = {"n", "e", "s", "w", "ne", "se", "sw", "nw", "u", "d", "nu", "nd", "eu", "ed", "su", "sd", "wu", "wd", "enter", "out", "backyard", "frontyard", "swim", "dive", "right", "left", "climb tree"}

function nk.Start()
	local walk_path = GetVariable("nk_path")
	local walk_step = 0
	SetVariable("nk_step", walk_step)
	if ( walk_path and walk_path ~= "") then
		message.Note("��ʼ����NKģʽ")
		--ֹͣ����ֹ������ʱ����������м��д����򷢴��˳�
		EnableTimer("fadai", false)
		EnableTrigger("monitor_mobs", false)
		EnableTrigger ( "warn_mobs", false )

		--ִ��NK����
		nk.DoNK()
	end
end

function nk.Stop()
	nk.RemoveTriggers()
	SetVariable("nk_step", "-1")
	message.Note("�˳�NKģʽ")
	EnableTimer("fadai", true)
end

--ִ��һ��NKָ��
function nk.DoNK()
	local nk_command = GetVariable("nk_command")
	nk.target = ""
	nk.RemoveTriggers()

	addxml.trigger { name="nk_gettarget", 
				match="^������(?P<nk_name>\\S+)��ɱ���㣡$",
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnGetTarget",
				regexp="y"}
	addxml.trigger { name="nk_notarget", 
				match="^����û������ˡ�$",
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnNoTarget",
				regexp="y"}
	command.RunOnly(nk_command)
end

--�ҵ�Ŀ��
function nk.OnGetTarget (name, line, wildcards, styles)
	nk.target = wildcards["nk_name"]
	EnableTrigger("nk_gettarget", false)
	DoAfterSpecial (0.1, "nk.SetupEndTrigger()", 12)
end

--û���ҵ�Ŀ��
function nk.OnNoTarget (name, line, wildcards, styles)
	EnableTrigger("nk_notarget", false)
	DoAfterSpecial (0.1, "nk.BrowseNextStep ()", 12)
end

--���ñ��ν���������
function nk.SetupEndTrigger ()
	nk.RemoveTriggers()

	local pattern = "^" .. nk.target .. "���ˡ�$"

	addxml.trigger { name="nk_killedtarget", 
				match=pattern,
				group="NK",
				enabled=true,
				sequence=100,
				script="nk.OnKilledTarget",
				regexp="y"}
end 

--ɱ��Ŀ����
function nk.OnKilledTarget (name, line, wildcards, styles)
	EnableTrigger("nk_killedtarget", false)
	DoAfterSpecial (0.5, "nk.DoNK ()", 12)
end

function nk.RemoveTriggers()
	DeleteTrigger("nk_gettarget")
	DeleteTrigger("nk_notarget")
	DeleteTrigger("nk_killedtarget")
end

--����һ���ط���
function nk.BrowseNextStep ()
	nk.RemoveTriggers()

	local walk_path = GetVariable("nk_path")
	local walk_step = tonumber(GetVariable("nk_step"))
	local walk_list = utils.split ( walk_path, ";" )

	walk_step = walk_step + 1

	if ( walk_list[walk_step] ) then	--����������һ������
		local walk_dir = walk_list[walk_step]
		local do_nk = false
		SetVariable("nk_step", walk_step)
		command.RunOnly ( walk_dir )

		for _, v in pairs(nk.dir_list) do
			if ( walk_dir == v ) then
				do_nk = true
				break
			end
		end

		if ( do_nk ) then
			DoAfterSpecial (1, "nk.DoNK ()", 12)
		else
			DoAfterSpecial (0.5, "nk.BrowseNextStep ()", 12)
		end
	elseif ( walk_step >= table.getn(walk_list) ) then	-- ���ߵ�·��ĩβ����ͷ��ʼ
		--�ص���ʼ����
		walk_step = 0
		SetVariable("nk_step", walk_step)
		--�ȴ�ˢ�º��ٽ���NK
		print("ȥ��Ϣ����ˢ��")
		command.Run("hp", nk.DoRest)
		--DoAfterSpecial (2, "nk.DoRest ()", 12)
	else
		message.Note("·������")
	end
end

--��Ϣһ���ˢ��
function nk.DoRest()
	--me.state.RecoverEndCallback = nk.GotoHotel
	--me.state.Recover()
	nk.GotoHotel()
end

--ȥ��ջ����
function nk.GotoHotel()
	local rest_path = GetVariable("nk_restpath")
	walk.WalkEndCallback = nk.OnRestEnd
	walk.WalkPath ( rest_path )
end

--��Ϣ����
function nk.OnRestEnd(object_found, walk_end, state)
	print("���¿�ʼNK")
	DoAfterSpecial (0.5, "nk.DoNK ()", 12)
end
