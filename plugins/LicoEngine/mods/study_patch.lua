
--Module: study_patch.lua

--���ⲹ��

study.patch = {}

function study.patch.BeginInvoke()
	--�жϵ����ĸ�����
	if ( study.study_flag.action == "duxueshu" ) then	--���ݹǵ�Ѫ��
		study.patch.xueshu.Invoke()
	elseif ( study.place == "tianmotai" ) then	--����ħ̨������
		study.patch.tianmotai.Invoke()
	end
end

function study.patch.EndInvoke()
	study.Begin()
	walk.WalkEndCallback = walk.WalkEndCallback_Inner
end