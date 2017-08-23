
local function new( surface )
	if (type(surface) ~= "userdata") then error("surface expected") end
	
	local getTexture	=	function()
								return surface:get_texture()
							end
	local setTexture	=	function(tex)
								surface:set_texture(tex)
							end
	local transTexture	=	function(u,v)
								surface:trans_texture(u,v)
							end
	local rotateTexture	=	function(angle)
								surface:rotate_texture(angle)
							end
	local scaleTexture	=	function(u,v)
								surface:scale_texture(u,v)
							end
	local getMaterial = function()
							local handle=surface:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return surface:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							surface:set_material(mater.getUD())
						end
	local getStyle	=	function()
							return surface:get_style()
						end
	local setStyle	=	function(style)
							surface:set_style(style)
						end
	local getPlane	=	function()
							local handle=surface:get_plane()
							if (NULL==handle) then return nil end
							return plane.new(handle)
						end
	local getLmOrg	=	function()
							return vec.new(surface:get_lmorg())
						end
	local getLmU	=	function()
							return vec.new(surface:get_lmu())
						end
	local getLmV	=	function()
							return vec.new(surface:get_lmv())
						end
	local intersectRay	=	function(_ray,bCalcDis,bIgnoreBack)
								return surface:intersect_ray(_ray.getUD(),bCalcDis,bIgnoreBack)
							end
	local intersectSegment	=	function(_segment,bCalcDis,bIgnoreBack)
									return surface:intersect_segment(_segment.getUD(),bCalcDis,bIgnoreBack)
								end


	local r=_new_root_tb(surface)

	r.getTexture=getTexture
	r.setTexture=setTexture
	r.transTexture=transTexture
	r.rotateTexture=rotateTexture
	r.scaleTexture=scaleTexture
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.getPlane=getPlane
	r.getLmOrg=getLmOrg
	r.getLmU=getLmU
	r.getLmV=getLmV
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment

	return r
end

-- export ----
_new_surface_tb=new


-- style ---
SURFS_REFLECTION			=toDWORD('00000002') -- reflection
SURFS_SPECULARSPOT			=toDWORD('00000008') -- specular spot
SURFS_ALPHATEST				=toDWORD('00000010') -- alpha test
SURFS_ALPHABLEND			=toDWORD('00000020') -- alpha blend
SURFS_COLORADD				=toDWORD('00000040') -- color add
SURFS_DOUBLESIDE			=toDWORD('00000080') -- double side
SURFS_NOCLIP				=toDWORD('00000200') -- don't affect collision detection
SURFS_NOLIGHTMAP			=toDWORD('00000400') -- no lightmap
