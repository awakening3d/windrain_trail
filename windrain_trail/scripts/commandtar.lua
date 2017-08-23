

local function new( commtar )
	if (type(commtar) ~= "userdata") then error("command target expected") end

	local getStyle =	function()
							return commtar:get_style()
						end
	local setStyle =	function( style )
							commtar:set_style(style)
						end

	local sendMessage =	function( msg )
					_SendMessageToCommandTar(commtar:get_pointer(),msg)
				end

	local r=_new_udhead_tb(commtar)

	r.getStyle=getStyle
	r.setStyle=setStyle
	r.sendMessage=sendMessage

	return r
end

-- export ----
_new_commandtar_tb=new

-------style-------
COMTARS_TRANSPARENT			=toDWORD('00000001') --transparent, means this Command Target is disabled, don't accept any messages