-- Module "char_items"
-- ���ڼ�¼��ɫ����Ʒ��Ϣ
-- ���ߣ� Li Ying
-- ���ڣ� 2010/12/21

require "tprint"
require "addxml"

--��ɫӵ�еĽ�Ǯ��Ŀ
me.money = {gold=0, silver=0, coin=0}

me.items = {}

--��ȡ��Ʒ�����ص�����������ģ����Ը��Ĵ�ֵ�����лص�����
function me.items.GetItemsEndCallback_Inner()
	--print("iָ���������")
end
me.items.GetItemsEndCallback = me.items.GetItemsEndCallback_Inner

--����iָ��󣬴������¼�����ȡ����Я������Ʒ
function me.items.StartGetItems (name, line, wildcards, styles)
	me.money.gold = 0
	me.money.silver = 0
	me.money.coin = 0
	
	--print("Now add triggers")
	--���ӻ�ȡ��Ǯ��Ŀ�Ĵ�����
	addxml.trigger { name="get_money", 
				match="^\\s+(?P<item_count>\\S+)(���ƽ�|������|��Ǯ)\\((Gold|Silver|Coin)\\)$",
				group="Char_Info",
				enabled=true,
				sequence=100,
				script="me.items.GetCharMoney",
				regexp="y"}
	--SetTriggerOption("output_end", "script", "me.items.ItemsOutputEnd")
	--EnableTrigger("output_end", true)
	command.RegisterCmdEndCallback ( me.items.OnItemsOutputEnd )
	--tprint(GetTriggerList())
end  -- StartGetItems

--���ÿ���Ǯ����Ŀ����������Ŀת����������Ŀ
function me.items.GetCharMoney (name, line, wildcards, styles)
	--print(line)
	local i, j = string.find(line, "(Gold)")
	if i and i > 1 then
		me.money.gold = tonumber(ConvertChineseNumber(wildcards["item_count"]))
		return
	end
	i, j = string.find(line, "(Silver)")
	if i and i > 1 then
		me.money.silver = tonumber(ConvertChineseNumber(wildcards["item_count"]))
		return
	end
	i, j = string.find(line, "(Coin)")
	if i and i > 1 then
		me.money.coin = tonumber(ConvertChineseNumber(wildcards["item_count"]))
		return
	end
end --OnGetItem

-- ��Ʒ�б��������
function me.items.OnItemsOutputEnd ()
	--print("Item output end. Now delete triggers")
	DeleteTrigger("get_money")
	
	--���ûص�����
	me.items.GetItemsEndCallback()
	me.items.GetItemsEndCallback = me.items.GetItemsEndCallback_Inner
end --OnItemOutputEnd

--�ڳ���+����savemoney�����д�Ǯ�Ĳ���
function me.items.SaveMoney ()
	me.items.GetItemsEndCallback = me.items.BeginSave
	walk.WalkPath("w;s;mi")
end

function me.items.BeginSave()
	local action_string = "#wait 2;"
	for k, v in pairs(me.money) do
		if ( v > 0 ) then
			action_string = action_string .. "deposit " .. v .." " .. k ..";#wait 2;"
		end
	end 
	action_string = action_string .. "n;e"
	walk.WalkPath(action_string)
end