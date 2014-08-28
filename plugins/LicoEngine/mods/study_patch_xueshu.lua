--Module: study_patch_xueshu.lua

--¶Á¿Õ°×ÕË±¾µÄ²¹¶¡

study.patch.xueshu={}

function study.patch.xueshu.Invoke()
	local action = "unwield blade;wield bi shou;cut me;ran zhang ben;unwield bi shou;wield blade;exert heal;exert heal;exert heal;exert heal"
	walk.WalkEndCallback = study.patch.EndInvoke
	walk.WalkPath ( action )
end
