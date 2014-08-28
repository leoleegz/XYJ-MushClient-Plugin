-- Module "char_info"
-- ���ڼ�¼��ɫ��״̬����Ǯ�����ܵ���Ϣ
-- ���ߣ� Li Ying
-- ���ڣ� 2010/12/21

require "serialize"
require "tprint"
require "addxml"

--hp:��Ѫ  mp:����  neili:����  fali:����  food:ʳ��  drink:��ˮ  
--wuxue:��ѧ daoxing:����  qn:Ǳ��  shaqi:ɱ��
--dxjj:���о��� wxjj:��ѧ����  flxw:������Ϊ  nlxw:������Ϊ
me.state = {hp=0,hpmax=0,hprate=0,mp=0,mpmax=0,mprate=0,
	neili=0,neilimax=0,fali=0,falimax=0,
	food=0,foodmax=0,drink=0,drinkmax=0,
	wuxue=0,daoxing=0,qn=0,shaqi=0,
	dxjj="",wxjj="",flxw="",nlxw=""}

--��ȡ״̬�����ص�����������ģ����Ը��Ĵ�ֵ�����лص�����
function me.state.GetHpEndCallback_Inner()
	--print("hp�������")
end
me.state.GetHpEndCallback = me.state.GetHpEndCallback_Inner

--��ȡScore�����ص�����������ģ����Ը��Ĵ�ֵ�����лص�����
function me.state.GetScoreEndCallback_Inner()
	--print("score�������")
end
me.state.GetScoreEndCallback = me.state.GetScoreEndCallback_Inner

--״̬�ָ��ص�����
function me.state.RecoverEndCallback_Inner()
	print("�ָ����")
end
me.state.RecoverEndCallback = me.state.RecoverEndCallback_Inner

local status_win_plugin_id = "02a068ee44c6e2a9ba0df18c"

--HPָ������ĵ�һ��
function me.state.HPLine1 (name, line, wildcards, styles)
	--record data
	me.state.hp = tonumber(wildcards["hp"])
	me.state.hpmax = tonumber(wildcards["hpmax"])
	me.state.hprate = tonumber(wildcards["hprate"])
	me.state.neili = tonumber(wildcards["neili"])
	me.state.neilimax = tonumber(wildcards["neilimax"])
	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusClear")
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HPָ������ĵڶ���
function me.state.HPLine2 (name, line, wildcards, styles)
	--record data
	me.state.mp = tonumber(wildcards["mp"])
	me.state.mpmax = tonumber(wildcards["mpmax"])
	me.state.mprate = tonumber(wildcards["mprate"])
	me.state.fali = tonumber(wildcards["fali"])
	me.state.falimax = tonumber(wildcards["falimax"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HPָ������ĵ�����
function me.state.HPLine3 (name, line, wildcards, styles)
	--record data
	me.state.food = tonumber(wildcards["food"])
	me.state.foodmax = tonumber(wildcards["foodmax"])
	me.state.wuxue = tonumber(wildcards["wuxue"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HPָ������ĵ�����
function me.state.HPLine4 (name, line, wildcards, styles)
	--record data
	me.state.drink = tonumber(wildcards["drink"])
	me.state.drinkmax = tonumber(wildcards["drinkmax"])
	me.state.daoxing = wildcards["daoxing"]

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end -- HPLine1

--HPָ������ĵ�����
function me.state.HPLine5 (name, line, wildcards, styles)
	--record data
	me.state.qn = tonumber(wildcards["qn"])
	me.state.shaqi = tonumber(wildcards["shaqi"])

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
	CallPlugin (status_win_plugin_id, "StatusRefresh")

	--������������ص�
	--SetTriggerOption("output_end", "script", "me.state.HpOutputEnd")
	--EnableTrigger("output_end", true)
	command.RegisterCmdEndCallback( me.state.OnHpOutputEnd )
end -- HPLine1

function me.state.OnHpOutputEnd ()
	me.state.GetHpEndCallback()
	me.state.GetHpEndCallback = me.state.GetHpEndCallback_Inner
end --OnHpOutputEnd

--Scoreָ�����������1
function me.state.ScoreLine1 (name, line, wildcards, styles)
	me.state.dxjj = wildcards["dxjj"]
	me.state.wxjj = wildcards["wxjj"]

	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
end --ScoreLine1

--Scoreָ�����������2
function me.state.ScoreLine2 (name, line, wildcards, styles)
	--record data
	me.state.flxw = wildcards["flxw"]
	me.state.nlxw = wildcards["nlxw"]

	--tprint(styles)
	local result, t = serialize.save ("styles", styles)
	CallPlugin (status_win_plugin_id, "StatusLineWithStyles", result)
	CallPlugin (status_win_plugin_id, "StatusRefresh")

	--������������ص�
	--SetTriggerOption("output_end", "script", "me.state.ScoreOutputEnd")
	--EnableTrigger("output_end", true)
	command.RegisterCmdEndCallback( me.state.OnScoreOutputEnd )
end -- ScoreLine2

function me.state.OnScoreOutputEnd (name, line, wildcards, styles)
	me.state.GetScoreEndCallback()
	me.state.GetScoreEndCallback = me.state.GetScoreEndCallback_Inner
end --OnScoreOutputEnd

--��õ���XX���С�
function me.state.GetDx (name, line, wildcards, styles)
	message.Note("���" .. wildcards["dx"] .. "����")
end

me.state.recover_stage = ""

--ͨ��dazuo,mingsi �ָ���Ѫ�����������񡢷�������Ҫ��hpָ���ִ��
function me.state.Recover()
	me.state.recover_stage = ""
	if ( me.state.hp < me.state.hpmax - 5 ) then
		--��Ѫ����
		if ( me.state.neili >= 50 or dummy.mode == 2) then
			--��������������д��ף���ô�Ȼظ���Ѫ
			return me.state.ExertRecover()
		elseif ( me.state.hp < 50 ) then
			--�����ѪҲ���㣬��ô��Ҫ�ȴ�һ��ʱ���ٻָ�
			local wait_time = GetVariable("wait_time")
			print("��Ѫ���������ϵͣ��ȴ�" .. wait_time .. "���ٻָ�")
			return DoAfterSpecial ( tonumber(wait_time), "me.state.Recover()", 12 )
		else
			return me.state.Dazuo()
		end
	elseif ( me.state.neili < me.state.neilimax - 10 ) then
		--�������������������ָ�����
		return me.state.Dazuo()
	elseif ( me.state.hprate < 98 ) then
		--�����ˣ���Ҫ��������
		return command.Run("exert heal", me.state.OnExertHealEnd)
	elseif ( me.state.mp < me.state.mpmax - 5 ) then
		--���񲻹���ͨ��exert refresh���ָ�����
		return me.state.ExertRefresh()
	elseif ( me.state.fali < me.state.falimax - 10 ) then
		--����������ͨ��mingsi���ָ�����
		return me.state.MingSi()
	else
		--״̬ȫ��
		return me.state.OnRecoverEnd()
	end
end

function me.state.Dazuo()
	--������Ҫ��������
	local ratio = tonumber( GetVariable("neili_ratio") ) or 1

	addxml.trigger { name="dazuo_end", 
				match="^���й���ϣ���һ����������վ��������$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnDazuoEnd",
				regexp="y"}
	
	addxml.trigger { name="dazuo_neiliup", 
				match="^���������ǿ�ˣ�$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnNeiliUp",
				regexp="y"}

	addxml.trigger { name="dazuo_max", 
				match="^������������ӵ�˲�����Ȼ���û���һ���ƺ������������Ѿ�����ƿ����$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnDazuoEnd",
				regexp="y"}
	
	local pt = (me.state.neilimax * 2 - 50 - me.state.neili) / ratio
	if ( pt < 20 ) then
		-- ��������Ϊ20��
		pt = 20
	end
	if ( pt > me.state.hp - 1 ) then
		pt = me.state.hp - 1
	else
		pt = math.floor( pt )
	end

	me.state.recover_stage = "dazuo"
	command.RunOnly ("dazuo " .. pt)
end

--������Ȼ�����ˣ�˵��ϵ����Ҫ����
function me.state.OnNeiliUp (name, line, wildcards, styles)
	local ratio = tonumber( GetVariable("neili_ratio") ) or 1
	ratio = ratio + 0.1
	SetVariable("neili_ratio", tostring(ratio))
end

--��������
function me.state.OnDazuoEnd (name, line, wildcards, styles)
	--3��֮���ٻָ���Ѫ
	DoAfterSpecial ( 3, "me.state.ExertRecover()", 12 )
end

--�������ָ���Ѫ
function me.state.ExertRecover()
	DeleteTrigger("dazuo_end")
	DeleteTrigger("dazuo_neiliup")
	DeleteTrigger("dazuo_max")

	if ( dummy.mode == 2 ) then		--����������ڴ��ף���ôͨ�����׻ָ���Ѫ
		dummy.requirer.HelpEndCallback = me.state.OnExertRecoverEnd
		dummy.requirer.CallRecover()
	else
		command.Run("exert recover", me.state.OnExertRecoverEnd)
	end
end

function me.state.OnExertRecoverEnd()
	command.Run("hp", me.state.Recover)
end

function me.state.OnExertHealEnd()
	command.Run("hp", me.state.Recover)
end

--ͨ��exert refresh�ָ�����
function me.state.ExertRefresh()
	DeleteTrigger("mingsi_end")
	DeleteTrigger("mingsi_faliup")
	DeleteTrigger("mingsi_max")

	if ( dummy.mode == 2 ) then		--����������ڴ��ף���ôͨ�����׻ָ�����
		dummy.requirer.HelpEndCallback = me.state.OnExertRefreshEnd
		dummy.requirer.CallRefresh()
	else
		command.Run("exert refresh", me.state.OnExertRefreshEnd)
	end
end

function me.state.OnExertRefreshEnd()
	command.Run("hp", me.state.Recover)
end

function me.state.MingSi()
	--������Ҫڤ˼����
	local ratio = tonumber( GetVariable("fali_ratio") ) or 1

	addxml.trigger { name="mingsi_end", 
				match="^���й���ϣ���ڤ˼�лع�������$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnMingSiEnd",
				regexp="y"}

	addxml.trigger { name="mingsi_faliup", 
				match="^��ķ�����ǿ�ˣ�$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnFaliUp",
				regexp="y"}

	addxml.trigger { name="mingsi_max", 
				match="^����ķ������ӵ�˲�����Ȼ��������һƬ���ң��ƺ������������Ѿ�����ƿ����$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnMingSiEnd",
				regexp="y"}
	
	--local pt = (me.state.falimax * 2 -50 - me.state.fali) / ratio
	local pt = (me.state.falimax + 100 - me.state.fali) / ratio
	if ( pt < 20 ) then
		-- ڤ˼����Ϊ20��
		pt = 20
	end
	if ( pt > me.state.mp - 1 ) then
		pt = me.state.mp - 1
	else
		pt = math.floor( pt )
	end

	me.state.recover_stage = "mingsi"
	command.RunOnly ("mingsi " .. pt)
end

--������Ȼ�����ˣ�˵��ϵ����Ҫ����
function me.state.OnFaliUp (name, line, wildcards, styles)
	local ratio = tonumber( GetVariable("fali_ratio") ) or 1
	--if ( ratio < 1 ) then
	--	ratio = 1
	--end
	ratio = ratio + 0.1
	SetVariable("fali_ratio", tostring(ratio))
end

--ڤ˼����
function me.state.OnMingSiEnd (name, line, wildcards, styles)
	--3��֮���ٻָ���Ѫ
	DoAfterSpecial ( 3, "me.state.ExertRefresh()", 12 )
end

--�ָ�����������enforce��
--Ok.
function me.state.OnRecoverEnd()
	addxml.trigger { name="jiali_end", 
				match="^Ok.$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnEnforceEnd",
				regexp="y"}

	local jiali = tonumber(GetVariable("jiali"))
	return command.RunOnly("jiali " .. jiali)
end

function me.state.OnEnforceEnd (name, line, wildcards, styles)
	EnableTrigger("jiali_end", false)
	addxml.trigger { name="enchant_end", 
				match="^Ok.$",
				group="Char_Info",
				enabled=true,
				sequence=50,
				script="me.state.OnEnchantEnd",
				regexp="y"}

	local enchant = tonumber(GetVariable("enchant"))
	return command.RunOnly("enchant " .. enchant)
end

function me.state.OnEnchantEnd (name, line, wildcards, styles)
	EnableTrigger("enchant_end", false)
	DoAfterSpecial(0.5, "me.state.AllEnd()", 12)
end

function me.state.AllEnd()
	DeleteTrigger("jiali_end")
	DeleteTrigger("enchant_end")
	me.state.RecoverEndCallback()
	me.state.RecoverEndCallback = me.state.RecoverEndCallback_Inner
end


--ֹͣ�ָ�
function me.state.StopRecover()
	if ( me.state.recover_stage == "dazuo" ) then
		DeleteTrigger("dazuo_end")
		DeleteTrigger("dazuo_neiliup")
		DeleteTrigger("dazuo_max")
		command.RunOnly ("dazuo 0")
	end
	if ( me.state.recover_stage == "mingsi" ) then
		DeleteTrigger("mingsi_end")
		DeleteTrigger("mingsi_faliup")
		DeleteTrigger("mingsi_max")
		command.RunOnly ("mingsi 0")
	end
end