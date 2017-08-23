
local function new( ocean )
	if (type(ocean) ~= "userdata") then error("ocean expected") end
	
	local getGridNum	=	function()
								return ocean:get_gridnum()
							end
	local setGridNum	=	function(grid)
								ocean:set_gridnum(grid)
							end
	local getMaterial = function()
							local handle=ocean:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return ocean:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							ocean:set_material(mater.getUD())
						end
	local getStyle	=	function()
							return ocean:get_style()
						end
	local setStyle	=	function(style)
							ocean:set_style(style)
						end
	local intersectRay	=	function(_ray,bCalcDis,bIgnoreBack)
								return ocean:intersect_ray(_ray.getUD(),bCalcDis,bIgnoreBack)
							end
	local intersectSegment	=	function(_segment,bCalcDis,bIgnoreBack)
									return ocean:intersect_segment(_segment.getUD(),bCalcDis,bIgnoreBack)
								end

	local getUVScale =	function()
						return ocean:get_uvscale()
					end
	local setUVScale	=	function(uv)
							return ocean:set_uvscale(uv)
						end
	local getClipOffset =	function()
							return ocean:get_clip_offset()
						end
	local setClipOffset =	function(clipofs)
							ocean:set_clip_offset(clipofs)
						end

	local getPlane	=	function()
							local handle=ocean:get_plane()
							if (NULL==handle) then return nil end
							return plane.new(handle)
						end


	local r=_new_root_tb(ocean)

	r.getGridNum=getGridNum
	r.setGridNum=setGridNum
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment

	r.getUVScale=getUVScale
	r.setUVScale=setUVScale

	r.getClipOffset=getClipOffset
	r.setClipOffset=setClipOffset

	r.getPlane=getPlane

	return r
end

-- export ----
_new_ocean_tb=new


-- style ---
