--Module: study_special.lua
--����ѧϰģ��

require "addxml"
require "tprint"

study.special = {}

--lianwu:
--enable dodge none;wield plow;wear golden armor

--����ѧϰ֧�ֵ�ģʽ
study.special.support={"act", "examine", "touch", "skate", "climb", "lianwu"}

study.special.policy = {act={skill="unarmed", action="#20 (act yong)", up=0, recover=study_state_needhuifu}, 
				examine={skill="literate", action="#20 (examine bei)", up=0, recover=study_state_needhuifu}, 
				touch={skill="force", action="#20 (touch gui)", up=0, recover=study_state_needhuifu},
				skate={skill="dodge", action="skate", up=1, recover=study_state_needrecover},
				climb={skill="dodge", action="#10 (climb tree)", up=1, recover=study_state_needrecover},
				lianwu={skill="dodge", action="bian leolg;#20 (lianwu);bian", up=1, recover=study_state_needrecover}}

study.special.action = ""

function study.special.EndCallback_Inner()
	if ( study.study_flag.state == study_state_skillup ) then
		--������������ˣ���ô����skillsָ��
		command.Run("skills", study.OnCurrentEnd)
	else
		DoAfterSpecial(0.1, "study.OnCurrentEnd()", 12)
	end
end
study.special.EndCallback = study.special.EndCallback_Inner

function study.special.Execute ( cmd_action, commandstring )
	study.special.action = cmd_action

	local real_action = study.special.policy[study.special.action].action
	local up = study.special.policy[study.special.action].up

	--�����꼴�ָ�
	study.study_flag.state = study.special.policy[study.special.action].recover

	--���
	--ʲô��
	addxml.trigger { name="target_out", 
					match="^ʲô��$",
					group="Study",
					enabled=true,
					sequence=20,
					script="study.special.OnTargetOut",
					regexp="y"}
	
	if ( up == 1 ) then
		local successpattern = "^��ġ�(?P<skill_name>\\S+)�������ˣ�$"
		addxml.trigger { name="skill_up", 
						match=successpattern,
						group="Study",
						enabled=true,
						sequence=20,
						script="study.special.OnSkillUp",
						regexp="y"}
	end

	addxml.trigger { name="skill_actionend", 
						match="^���μ��Ѿ�������",
						group="Study",
						enabled=true,
						sequence=20,
						keep_evaluating="y",
						script="study.special.OnActionEnd",
						regexp="y"}

	--ִ��N��ѧϰ����
	command.RunOnly ( real_action .. ";uptime")
end

--ѧϰ�Ķ���û���ˣ��ȴ�ˢ��
function study.special.OnTargetOut (name, line, wildcards, styles)
	study.study_flag.state = study_state_pause
end

--��ϰ����
function study.special.OnActionEnd()
	EnableTrigger("skill_actionend", false)
	DoAfterSpecial ( 3, "study.special.NeedCheckSkill()", 12 )
end

function study.special.NeedCheckSkill()
	DeleteTrigger("skill_actionend")
	command.Run("skills", study.special.CheckSkillUp)
end

--��鼼���Ƿ�ﵽ����Ҫ��
function study.special.CheckSkillUp()
	local skill_id = study.special.policy[study.special.action].skill
	local skill = me.skills.GetSkillById( skill_id )
	local up = study.special.policy[study.special.action].up

	DeleteTrigger("target_out")

	if ( skill.ismaxpoint and up == 0) then
		print("��Ҫȥ����" .. skill.name)
		local successpattern = "^��ġ�(?P<skill_name>\\S+)�������ˣ�$"
		addxml.trigger { name="skill_up", 
						match=successpattern,
						group="Study",
						enabled=true,
						sequence=20,
						script="study.special.OnSkillUp",
						regexp="y"}

		local pathes = GetVariable( "xx_".. study.special.action .. "_up")
		walk.WalkEndCallback = study.special.OnSkillUpEnd
		walk.WalkPath( pathes )
	else
		study.special.OnSkillEnd()
	end
end

function study.special.OnSkillUp (name, line, wildcards, styles)
	study.study_flag.state = study_state_skillup
	study.study_flag.current_skill = wildcards["skill_name"]
end

function study.special.OnSkillUpEnd(object_found, walk_end, state)
	DoAfterSpecial(0.1, "study.special.OnStudySpecialEnd()", 12)
end

function study.special.OnSkillEnd()
	DoAfterSpecial(0.1, "study.special.OnStudySpecialEnd()", 12)
end

function study.special.OnStudySpecialEnd()
	DeleteTrigger("skill_up")
	study.special.EndCallback ()
	study.special.EndCallback = study.special.EndCallback_Inner
end
