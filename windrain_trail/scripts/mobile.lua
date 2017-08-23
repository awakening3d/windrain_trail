
local function new( mobile )
	if (type(mobile) ~= "userdata") then error("mobile expected") end
	
	local getTexture =	function()
							return mobile:get_texture()
						end
	local setTexture =	function( tex )
							mobile:set_texture(tex)
						end

	local r=_new_movable_tb(mobile)

	r.getTexture=getTexture
	r.setTexture=setTexture

	return r
end

-- export ----
_new_mobile_tb=new
