
local function new( staticmesh )
	if (type(staticmesh) ~= "userdata") then error("staticmesh expected") end
	
	local getTexture	=	function()
								return staticmesh:get_texture()
							end
	local setTexture	=	function(tex)
								staticmesh:set_texture(tex)
							end
	local getMaterial = function()
							local handle=staticmesh:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return staticmesh:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							staticmesh:set_material(mater.getUD())
						end
	local getStyle	=	function()
							return staticmesh:get_style()
						end
	local setStyle	=	function(style)
							staticmesh:set_style(style)
						end
	local intersectRay	=	function(_ray,bCalcDis,bIgnoreBack)
								return staticmesh:intersect_ray(_ray.getUD(),bCalcDis,bIgnoreBack)
							end
	local intersectSegment	=	function(_segment,bCalcDis,bIgnoreBack)
									return staticmesh:intersect_segment(_segment.getUD(),bCalcDis,bIgnoreBack)
								end


	local r=_new_root_tb(staticmesh)

	r.setPosition=function(pos) end		-- do nothing for static mesh
	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment

	return r
end

-- export ----
_new_staticmesh_tb=new


-- style ---
