-- Module: misc.lua

local chn_num_map ={["��"]=0,["һ"]=1, ["��"]=2, ["��"]=3, ["��"]=4, ["��"]=5, 
	["��"]=6, ["��"]=7, ["��"]=8, ["��"]=9, ["ʮ"]=10, 
	["��"]=100, ["ǧ"]=1000, ["��"]=10000, ["��"]=100000000}

local chn_splitter = {"��", "��", "ǧ", "��", "ʮ"}

--��������ת�����ڲ��ݹ麯��
local function InnerConvertChnNumber(chn_num, pre_number)
	--print(chn_num)
	local i, j = string.find(chn_num, "��")
	if i and i == 1  then
		if string.len(chn_num) == 2 then
			return 0
		else
			return InnerConvertChnNumber( string.sub(chn_num, j+1, -1), 1 )
		end
	end

	--�������ķ��뵥Ԫ���и���Ԫ��ת��
	local v
	for _, v in ipairs(chn_splitter) do
		--print("for v value:" .. v)
		local left, right = 0, 0
		local i, j = string.find(chn_num, v)
		if i and i >= 1 then
			if j < string.len(chn_num) then
				right = InnerConvertChnNumber( string.sub(chn_num, j+1, -1), 1 )
			end
			if i == 1 then
				left = chn_num_map[v]
			else
				left = InnerConvertChnNumber( string.sub(chn_num, 1, i - 1), 1 ) * chn_num_map[v]
			end
			--print ("left:".. left)
			--print ("right:"..right)
			return left + right
		end
	end
	
	if string.len(chn_num) == 2 then
		return chn_num_map[chn_num] * pre_number
	end
end -- InnerConvertChnNumber

-- ����������ת���ɰ���������
-- e.g. ConvertChineseNumber("һ�ٶ�ʮ�������İ���ʮ")
function ConvertChineseNumber(chn_num)
	return InnerConvertChnNumber(chn_num, 1)
end --ConvertChineseNumber
