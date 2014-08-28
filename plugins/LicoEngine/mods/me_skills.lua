-- Module "char_skills"
-- 用于记录角色的技能信息
-- 作者： Li Ying
-- 日期： 2010/12/21

require "tprint"
require "addxml"

--技能技能列表，为数组，内部为skill列表
--skill列表的成员为 id-英文名, name-中文名, description-描述, 
--				level-级别, point-点数, ismaxpoint-是否达到最大点数

me.skills = {}

--获取技能结束回调函数，其他模块可以更改此值来进行回调操作
function me.skills.GetSkillEndCallback_Inner()
	--print("skills输出结束")
end
me.skills.GetSkillEndCallback = me.skills.GetSkillEndCallback_Inner

--获取某个技能级别的最大技能点
function me.skills.GetMaxPoint(level)
	return (level+1) * (level+1)
end

--通过技能的英文名获取技能
function me.skills.GetSkillById(id)
	local v
	for _, v in ipairs(me.skills) do
		if( v.id and v.id == id ) then
			return v
		end
	end
	return nil
end

--通过技能的中文名获取技能
function me.skills.GetSkillByName(name)
	local v
	for _, v in ipairs(me.skills) do
		if( v.name and v.name == name ) then
			return v
		end
	end
	return nil
end

-- 输入skills指令后，触发该事件，获取技能列表
function me.skills.StartGetSkills (name, line, wildcards, styles)
	me.skills.RemoveAllSkills()

	--增加获取技能的触发器
	addxml.trigger { name="get_skill", 
				match="^｜(□|\\s*)(?P<name>\\S+)\\s\\((?P<id>\\S+)\\)\\s+\\-\\s+(?P<description>\\S+)\\s+(?P<level>\\d+)/\\s*(?P<point>\\d+)｜$",
				group="Char_Info",
				enabled=true,
				sequence=100,
				script="me.skills.GetCharSkill",
				regexp="y"}

	return command.RegisterCmdEndCallback ( me.skills.OnSkillsOutputEnd )
end --OnStartGetSkills

--获取技能
function me.skills.GetCharSkill (name, line, wildcards, styles)
	--print(line)
	local skill = { name = wildcards["name"],
			id = wildcards["id"],
			description = wildcards["description"],
			level = tonumber(wildcards["level"]),
			point = tonumber(wildcards["point"]) }
	skill.ismaxpoint = (skill.point >= me.skills.GetMaxPoint(skill.level))
	table.insert(me.skills, skill)
end --OnGetSkill

--技能输出结束
function me.skills.OnSkillsOutputEnd ()
	DeleteTrigger("get_skill")
	--tprint(char_skills)
	me.skills.GetSkillEndCallback()
	me.skills.GetSkillEndCallback = me.skills.GetSkillEndCallback_Inner
end --OnSkillsOutputEnd

--清空技能表格中的数据
function me.skills.RemoveAllSkills()
	local count = table.getn(me.skills)
	for i=1,count do
		table.remove(me.skills, 1)
	end
end
