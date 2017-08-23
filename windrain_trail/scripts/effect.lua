
local function new( effect )
	if (type(effect) ~= "userdata") then error("effect expected") end

	local getLifeTime = function()
							return effect:get_lifetime()
						end
	local setLifeTime = function(lt)
							return effect:set_lifetime(lt)
						end
	local getStyle	=	function()
							return effect:get_style()
						end
	local setStyle	=	function(style)
							effect:set_style(style)
						end
	local getMaterial = function()
							local handle=effect:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return effect:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							effect:set_material(mater.getUD())
						end

	local r=_new_root_tb(effect)

	r.getLifeTime=getLifeTime
	r.setLifeTime=setLifeTime
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial

	return r
end

-- export ----
_new_effect_tb=new

--style

EFFS_OPAQUE			=toDWORD('10000000') --opaque
