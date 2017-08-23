
local function new( overlay )
	if (type(overlay) ~= "userdata") then error("overlay expected") end
	
	local getWidth =	function()
							return overlay:get_width()
						end
	local getHeight =	function()
							return overlay:get_height()
						end
	local setWidthHeight =	function(w,h)
								return overlay:set_widthheight(w,h)
							end	
	local getStyle =	function()
							return overlay:get_style()
						end
	local setStyle =	function( style )
							overlay:set_style(style)
						end
	local getCommandTar =	function()
								local handle=overlay:get_commandtar()
								if (NULL==handle) then return nil end
								return CommandTarFromHandle(handle)
							end


	local r=_new_root_tb(overlay)

	r.getWidth=getWidth
	r.getHeight=getHeight
	r.setWidthHeight=setWidthHeight
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.getCommandTar=getCommandTar

	return r
end

-- export ----
_new_overlay_tb=new


-------style-------
OVERS_BACKGROUND		=toDWORD('00000001')		--background
