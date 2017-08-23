
local function new( image2d )
	if (type(image2d) ~= "userdata") then error("image2d expected") end

	local getColor = function()
							return image2d:get_color()
						end
	local setColor = function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							image2d:set_color(dwcolor)
						end
	local getTexture =	function()
							return image2d:get_texture()
						end
	local setTexture =	function( tex )
							image2d:set_texture(tex)
						end


	local r=_new_overlay_tb(image2d)

	r.getColor=getColor
	r.setColor=setColor
	r.getTexture=getTexture
	r.setTexture=setTexture

	return r
end

-- export ----
_new_image2d_tb=new
