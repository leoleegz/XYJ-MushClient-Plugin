-- Module: misc.lua

local chn_num_map ={["零"]=0,["一"]=1, ["二"]=2, ["三"]=3, ["四"]=4, ["五"]=5, 
	["六"]=6, ["七"]=7, ["八"]=8, ["九"]=9, ["十"]=10, 
	["百"]=100, ["千"]=1000, ["万"]=10000, ["亿"]=100000000}

local chn_splitter = {"亿", "万", "千", "百", "十"}

--中文数字转换的内部递归函数
local function InnerConvertChnNumber(chn_num, pre_number)
	--print(chn_num)
	local i, j = string.find(chn_num, "零")
	if i and i == 1  then
		if string.len(chn_num) == 2 then
			return 0
		else
			return InnerConvertChnNumber( string.sub(chn_num, j+1, -1), 1 )
		end
	end

	--按照中文分离单元进行各单元的转换
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

-- 将中文数字转换成阿拉伯数字
-- e.g. ConvertChineseNumber("一百二十三万零四百五十")
function ConvertChineseNumber(chn_num)
	return InnerConvertChnNumber(chn_num, 1)
end --ConvertChineseNumber
