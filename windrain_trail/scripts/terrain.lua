
local function new( terrain )
	if (type(terrain) ~= "userdata") then error("terrain expected") end
	
	local getTexture	=	function()
								return terrain:get_texture()
							end
	local setTexture	=	function(tex)
								terrain:set_texture(tex)
							end
	local getMaterial = function()
							local handle=terrain:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return terrain:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							terrain:set_material(mater.getUD())
						end
	local getStyle	=	function()
							return terrain:get_style()
						end
	local setStyle	=	function(style)
							terrain:set_style(style)
						end
	local intersectRay	=	function(_ray,bCalcDis,bIgnoreBack,hollow)
								return terrain:intersect_ray(_ray.getUD(),bCalcDis,bIgnoreBack,hollow)
							end
	local intersectSegment	=	function(_segment,bCalcDis,bIgnoreBack,hollow)
									return terrain:intersect_segment(_segment.getUD(),bCalcDis,bIgnoreBack,hollow)
								end

	local getAlt =	function(x,z,hollow)
						local alt, nx,ny,nz = terrain:get_alt(x,z,hollow)
						return alt, vec.new(nx,ny,nz)
					end
	local setAlt =	function(nx,nz,alt,bUpdate)
						return terrain:set_alt(nx,nz,alt,bUpdate)
					end

	local getRow =	function()
						return terrain:get_row()
					end
	local getCol =	function()
						return terrain:get_col()
					end
	local setRowCol	=	function(r,c)
							return terrain:set_rowcol(r,c)
						end
	local getInterval =	function()
							return terrain:get_interval()
						end
	local setInterval =	function(interval)
							terrain:set_interval(interval)
						end
	local offset	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							terrain:offset(v.x,v.y,v.z)
						end
	local scale	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							terrain:scale(v.x,v.y,v.z)
						end
	local computeNormal =	function()
								return terrain:compute_normal()
							end

	local r=_new_root_tb(terrain)

	r.setPosition=function(pos) end		-- do nothing for terrain
	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment
	r.getAlt=getAlt
	r.setAlt=setAlt
	r.getRow=getRow
	r.getCol=getCol
	r.setRowCol=setRowCol
	r.getInterval=getInterval
	r.setInterval=setInterval
	r.offset=offset
	r.scale=scale
	r.computeNormal=computeNormal

	return r
end

-- export ----
_new_terrain_tb=new


-- style ---
