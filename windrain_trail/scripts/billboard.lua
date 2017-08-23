
local function new( billboard )
	if (type(billboard) ~= "userdata") then error("billboard expected") end

	local getColor	=	function()
							return billboard:get_color()
						end
	local setColor	=	function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							billboard:set_color(dwcolor)
						end
	local getWidth	=	function()
							return billboard:get_width()
						end
	local getHeight	=	function()
							return billboard:get_height()
						end
	local getRotate	=	function()
							return billboard:get_rotate()
						end
	local setWidthHeight =	function(w,h,r)
								billboard:set_widthheight(w,h,r)
							end
	local getTexture =	function()
							return billboard:get_texture()
						end
	local setTexture =	function( tex )
							billboard:set_texture(tex)
						end
	local getAxis	=	function()
							return billboard:get_axis()
						end
	local setAxis	=	function( axis )
							billboard:set_axis(axis)
						end

	local r=_new_effect_tb(billboard)

	r.getColor=getColor
	r.setColor=setColor
	r.getWidth=getWidth
	r.getHeight=getHeight
	r.getRotate=getRotate
	r.setWidthHeight=setWidthHeight
	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getAxis=getAxis
	r.setAxis=setAxis

	return r
end

-- export ----
_new_billboard_tb=new

--style

BILLS_ALPHATEST			=toDWORD('00000002') --alpha test
