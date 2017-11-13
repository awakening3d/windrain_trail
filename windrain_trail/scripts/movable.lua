

local function new( movable )
	if (type(movable) ~= "userdata") then error("movable expected") end
	


	local setMatrix = function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							movable:set_matrix(mat.getUD())
						end


	local getLocalBoundingBox =	function()
									local handle=movable:get_local_boundingbox()
									if (NULL==handle) then return nil end
									return bbox.new(handle)
								end
	local getInvMatrix =	function()
								local handle=movable:get_invmatrix()
								if (NULL==handle)	then return nil end
								return matrix.new(handle)
							end

	local getStyle	=	function()
							return movable:get_style()
						end
	local setStyle	=	function(style)
							movable:set_style(style)
						end

	local getRotation = function()
							return vec.new(movable:get_rotation())
						end
	local setRotation = function(rot)
							if (type(rot) ~= "table") then error("vec expected") end
							movable:set_rotation(rot.x,rot.y,rot.z)
						end
	local getScale	=	function()
							return vec.new(movable:get_scale())
						end
	local setScale	=	function(scale)
							if (type(scale) ~= "table") then error("vec expected") end
							movable:set_scale(scale.x,scale.y,scale.z)
						end
	local getMaterial = function()
							local handle=movable:get_material()
							if (NULL==handle)	then return nil end
							return MaterialFromHandle(handle)
						end
	local setMaterial = function(mater)
							if (nil==mater) then return movable:set_material(_new_material_ud(nil)) end
							if (type(mater) ~= "table") then error("material expected") end
							movable:set_material(mater.getUD())
						end
	local intersectRay	=	function(_ray,bCalcDis,bIgnoreBack)
								return movable:intersect_ray(_ray.getUD(),bCalcDis,bIgnoreBack)
							end
	local intersectSegment	=	function(_segment,bCalcDis,bIgnoreBack)
									return movable:intersect_segment(_segment.getUD(),bCalcDis,bIgnoreBack)
								end


	local function get_mov_from_type(pmov,type)
		local mov=nil
		if ('mobile'==type) then
			mov=MobileFromHandle(pmov)
		elseif ('skinmesh'==type) then
			mov=SkinMeshFromHandle(pmov)
		elseif ('cloth'==type) then
			mov=ClothFromHandle(pmov)
		elseif ('group'==type) then
			mov=MovGroupFromHandle(pmov)
		end
		return mov
	end


	local getParent			=	function()
									local pmov,type=movable:get_parent()
									if (NULL==pmov or nil==pmov) then return nil end
									local mov=get_mov_from_type(pmov,type)
									return mov,type
								end
	local setParent			=	function(mov)
									if (NULL==mov or nil==mov) then
										movable:set_parent()
									else
										movable:set_parent( mov.getUD() )
									end
								end

	local getChildrenHead	=	function()
									return movable:get_children_head()
								end

	local getChildrenNext =	function(pos)
								local pmov,pos,type=movable:get_children_next(pos)
								local mov=get_mov_from_type(pmov,type)
								return mov,pos,type
							end
							
	local cloneInstance		=	function()
									local proot=movable:clone_instance(_GetScene())
									if (not proot) then return nil end
									local cid=movable:get_classid()
									if (UD_MOBILE==cid) then
										return MobileFromHandle(proot)
									elseif (UD_MOVGROUP==cid) then
										return MovGroupFromHandle(proot)
									elseif (UD_CLOTH==cid) then
										return ClothFromHandle(proot)
									elseif (UD_CLOTHEX==cid) then
										return ClothExFromHandle(proot)
									elseif (UD_SKINMESH==cid) then
										return SkinMeshFromHandle(proot)
									elseif (UD_PLAYER==cid) then
										return PlayerFromHandle(proot)
									end
								end							
							
	local bind			=	function(skinmesh,bone)
								if (nil==skinmesh) then return movable:bind(_new_skinmesh_ud(nil),0) end
								if (type(skinmesh) ~= "table") then error("skinmesh expected") end
								movable:bind(skinmesh.getUD(),bone)
							end
	local getBind		=	function()
								local handle, bone = movable:get_bind()
								if (NULL==handle)	then return nil end
								return SkinMeshFromHandle(handle), bone
							end
							

	local r=_new_root_tb(movable)

	r.setMatrix=setMatrix
	r.getLocalBoundingBox=getLocalBoundingBox
	r.getInvMatrix=getInvMatrix
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.getRotation=getRotation
	r.setRotation=setRotation
	r.getScale=getScale
	r.setScale=setScale
	r.getMaterial=getMaterial
	r.setMaterial=setMaterial
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment

	r.getParent=getParent
	r.setParent=setParent
	r.getChildrenHead=getChildrenHead
	r.getChildrenNext=getChildrenNext
	
	r.cloneInstance=cloneInstance
	r.bind=bind
	r.getBind=getBind

	return r
end

-- export ----
_new_movable_tb=new

--style

MOVS_FIXED			=toDWORD('00000001') --固定
MOVS_NOCLIP			=toDWORD('00000002') --不影响碰撞检测
MOVS_DOUBLESIDE		=toDWORD('00000004') --双面
MOVS_SHADOW			=toDWORD('00000010') --阴影
MOVS_SHADOW_REVERSE	=toDWORD('00000020') --反转阴影
MOVS_SHADOWMAP		=toDWORD('00000040') --使用阴影贴图
MOVS_HOLLOW		=toDWORD('00000100') --空心的，碰撞检测时可以从内部出来

