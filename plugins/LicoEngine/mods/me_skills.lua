-- Module "char_skills"
-- ���ڼ�¼��ɫ�ļ�����Ϣ
-- ���ߣ� Li Ying
-- ���ڣ� 2010/12/21

require "tprint"
require "addxml"

--���ܼ����б�Ϊ���飬�ڲ�Ϊskill�б�
--skill�б�ĳ�ԱΪ id-Ӣ����, name-������, description-����, 
--				level-����, point-����, ismaxpoint-�Ƿ�ﵽ������

me.skills = {}

--��ȡ���ܽ����ص�����������ģ����Ը��Ĵ�ֵ�����лص�����
function me.skills.GetSkillEndCallback_Inner()
	--print("skills�������")
end
me.skills.GetSkillEndCallback = me.skills.GetSkillEndCallback_Inner

--��ȡĳ�����ܼ��������ܵ�
function me.skills.GetMaxPoint(level)
	return (level+1) * (level+1)
end

--ͨ�����ܵ�Ӣ������ȡ����
function me.skills.GetSkillById(id)
	local v
	for _, v in ipairs(me.skills) do
		if( v.id and v.id == id ) then
			return v
		end
	end
	return nil
end

--ͨ�����ܵ���������ȡ����
function me.skills.GetSkillByName(name)
	local v
	for _, v in ipairs(me.skills) do
		if( v.name and v.name == name ) then
			return v
		end
	end
	return nil
end

-- ����skillsָ��󣬴������¼�����ȡ�����б�
function me.skills.StartGetSkills (name, line, wildcards, styles)
	me.skills.RemoveAllSkills()

	--���ӻ�ȡ���ܵĴ�����
	addxml.trigger { name="get_skill", 
				match="^��(��|\\s*)(?P<name>\\S+)\\s\\((?P<id>\\S+)\\)\\s+\\-\\s+(?P<description>\\S+)\\s+(?P<level>\\d+)/\\s*(?P<point>\\d+)��$",
				group="Char_Info",
				enabled=true,
				sequence=100,
				script="me.skills.GetCharSkill",
				regexp="y"}

	return command.RegisterCmdEndCallback ( me.skills.OnSkillsOutputEnd )
end --OnStartGetSkills

--��ȡ����
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

--�����������
function me.skills.OnSkillsOutputEnd ()
	DeleteTrigger("get_skill")
	--tprint(char_skills)
	me.skills.GetSkillEndCallback()
	me.skills.GetSkillEndCallback = me.skills.GetSkillEndCallback_Inner
end --OnSkillsOutputEnd

--��ռ��ܱ���е�����
function me.skills.RemoveAllSkills()
	local count = table.getn(me.skills)
	for i=1,count do
		table.remove(me.skills, 1)
	end
end
