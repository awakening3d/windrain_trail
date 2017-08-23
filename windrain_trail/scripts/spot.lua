
local function new( spot )
	if (type(spot) ~= "userdata") then error("spot expected") end

	local getTexture =	function()
							return spot:get_texture()
						end
	local setTexture =	function( tex )
							spot:set_texture(tex)
						end

	local r=_new_effect_tb(spot)

	r.getTexture=getTexture
	r.setTexture=setTexture

	return r
end

-- export ----
_new_spot_tb=new
