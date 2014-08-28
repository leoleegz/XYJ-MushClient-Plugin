-- Module "char_items"
-- 用于记录角色的物品信息
-- 作者： Li Ying
-- 日期： 2010/12/21

require "tprint"
require "addxml"

--角色拥有的金钱数目
me.money = {gold=0, silver=0, coin=0}

me.items = {}

--获取物品结束回调函数，其他模块可以更改此值来进行回调操作
function me.items.GetItemsEndCallback_Inner()
	--print("i指令输出结束")
end
me.items.GetItemsEndCallback = me.items.GetItemsEndCallback_Inner

--输入i指令后，触发该事件，获取身上携带的物品
function me.items.StartGetItems (name, line, wildcards, styles)
	me.money.gold = 0
	me.money.silver = 0
	me.money.coin = 0
	
	--print("Now add triggers")
	--增加获取金钱数目的触发器
	addxml.trigger { name="get_money", 
				match="^\\s+(?P<item_count>\\S+)(两黄金|两银子|文钱)\\((Gold|Silver|Coin)\\)$",
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

--获得每项金钱的数目，从中文数目转换成数字数目
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

-- 物品列表输出结束
function me.items.OnItemsOutputEnd ()
	--print("Item output end. Now delete triggers")
	DeleteTrigger("get_money")
	
	--调用回调函数
	me.items.GetItemsEndCallback()
	me.items.GetItemsEndCallback = me.items.GetItemsEndCallback_Inner
end --OnItemOutputEnd

--在长安+输入savemoney，进行存钱的操作
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