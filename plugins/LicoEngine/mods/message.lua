-- Module: message.lua


message = {}

function message.Note (text, textcolour, backcolour)
	if ( text and textcolour and backcolour ) then
		CallPlugin ("f7dae2294b76e02ff2fe1255", "MsgNote", text, textcolour, backcolour)
	elseif( text and textcolour ) then
		CallPlugin ("f7dae2294b76e02ff2fe1255", "MsgNote", text, textcolour)
	elseif( text ) then
		CallPlugin ("f7dae2294b76e02ff2fe1255", "MsgNote", text)
	end
end

function message.CatchMessage(name, line, wildcards, styles)
	message.Note (line)
end
