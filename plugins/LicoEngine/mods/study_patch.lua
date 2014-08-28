
--Module: study_patch.lua

--特殊补丁

study.patch = {}

function study.patch.BeginInvoke()
	--判断调用哪个补丁
	if ( study.study_flag.action == "duxueshu" ) then	--读枯骨刀血书
		study.patch.xueshu.Invoke()
	elseif ( study.place == "tianmotai" ) then	--在天魔台练妖法
		study.patch.tianmotai.Invoke()
	end
end

function study.patch.EndInvoke()
	study.Begin()
	walk.WalkEndCallback = walk.WalkEndCallback_Inner
end