
local function new( text2d )
	if (type(text2d) ~= "userdata") then error("text2d expected") end
	
	local getColor =	function()
							return text2d:get_color()
						end
	local setColor =	function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							text2d:set_color(dwcolor)
						end
	local getText =		function()
							return text2d:get_text()
						end
	local setText =		function(text)
							text2d:set_text(text)
						end
	local getHorzScale =function()
							return text2d:get_horzscale()
						end
	local getVertScale =function()
							return text2d:get_vertscale()
						end
	local setScale	=	function(horz,vert)
							return text2d:set_scale(horz,vert)
						end
	local getEncoding = function()
							return text2d:get_encoding()
						end
	local setEncoding = function(encoding)
							return text2d:set_encoding(encoding)
						end


	local r=_new_overlay_tb(text2d)

	r.getColor=getColor
	r.setColor=setColor
	r.getText=getText
	r.setText=setText
	r.getHorzScale=getHorzScale
	r.getVertScale=getVertScale
	r.setScale=setScale
	r.getEncoding=getEncoding
	r.setEncoding=setEncoding

	return r
end

-- export ----
_new_text2d_tb=new

TEXT_ENCODING_ANSI = 1
TEXT_ENCODING_UNICODE = 2
