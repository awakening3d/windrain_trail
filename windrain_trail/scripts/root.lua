
local function new( root )
	if (type(root) ~= "userdata") then error("root expected") end
	
	local getName	=	function()
							return root:get_name()
						end
	local setName	=	function(name)
							root:set_name(name)
						end
	local getPosition = function()
							return vec.new(root:get_position())
						end
	local setPosition = function(pos)
							if (type(pos) ~= "table") then error("vec expected") end
							root:set_position(pos.x,pos.y,pos.z)
						end
	local getBoundingBox =	function()
								local handle=root:get_boundingbox()
								if (NULL==handle) then return nil end
								return bbox.new(handle)
							end
	local getMatrix =	function()
							local handle=root:get_matrix()
							if (NULL==handle)	then return nil end
							return matrix.new(handle)
						end
	local isHidden	=	function()
							return root:is_hidden()
						end
	local hide		=	function(hidden)
							root:hide(hidden)
						end
	local clone		=	function()
							local proot=root:clone(_GetScene())
							if (not proot) then return nil end
							local cid=root:get_classid()
							if (UD_LIGHT==cid) then
								return LightFromHandle(proot)
							elseif (UD_MOBILE==cid) then
								return MobileFromHandle(proot)
							elseif (UD_MOVGROUP==cid) then
								return MovGroupFromHandle(proot)
							elseif (UD_CLOTH==cid) then
								return ClothFromHandle(proot)
							elseif (UD_CLOTHEX==cid) then
								return ClothExFromHandle(proot)
							elseif (UD_BILLBOARD==cid) then
								return BillboardFromHandle(proot)
							elseif (UD_PARTICLES==cid) then
								return ParticlesFromHandle(proot)
							elseif (UD_SPOT==cid) then
								return SpotFromHandle(proot)
							elseif (UD_IMAGE2D==cid) then
								return Image2DFromHandle(proot)
							elseif (UD_TEXT2D==cid) then
								return Text2DFromHandle(proot)
							elseif (UD_CAMERA==cid) then
								return CameraFromHandle(proot)
							elseif (UD_SURFACE==cid) then
								return SurfaceFromHandle(proot)
							elseif (UD_SKINMESH==cid) then
								return SkinMeshFromHandle(proot)
							elseif (UD_STATICMESH==cid) then
								return StaticMeshFromHandle(proot)
							elseif (UD_TERRAIN==cid) then
								return TerrainFromHandle(proot)
							elseif (UD_OCEAN==cid) then
								return OceanFromHandle(proot)
							elseif (UD_PLAYER==cid) then
								return PlayerFromHandle(proot)
							end
						end

		local testFlag =	function(flag)
								return root:test_flag(flag)
							end
		local getNoClipMask =	function()
									return root:get_noclip_mask()
								end
		local setNoClipMask =	function(mask)
									root:set_noclip_mask(mask)
								end
		
		local getZOrder	=	function()
									return root:get_zorder()
								end
		local setZOrder =	function(zorder)
									root:set_zorder(zorder)
								end

		local isBumpEnable	=	function()
									return root:root_is_bump_enable()
								end
		local bumpEnable	=	function(bump)
									root:root_bump_enable(bump)
								end
		local noRTTRender =	function(nortt)
									return root:root_no_rtt_render(nortt)
								end
		local noShadow =	function(noshadow)
									return root:root_no_shadow(noshadow)
								end
		local getUserData =		function()
								return vec4.new( root:root_get_userdata() )
							end
		local setUserData =		function( v )
								return root:root_set_userdata( v.x, v.y, v.z, v.w )
							end

	local r=_new_animation_tb(root)
	
	r.getName=getName
	r.setName=setName
	r.getPosition=getPosition
	r.setPosition=setPosition
	r.getBoundingBox=getBoundingBox
	r.getMatrix=getMatrix
	r.isHidden=isHidden
	r.hide=hide
	r.clone=clone
	r.testFlag=testFlag
	r.getNoClipMask=getNoClipMask
	r.setNoClipMask=setNoClipMask
	r.getZOrder=getZOrder
	r.setZOrder=setZOrder
	r.isBumpEnable=isBumpEnable
	r.bumpEnable=bumpEnable
	r.noRTTRender=noRTTRender
	r.noShadow=noShadow
	r.getUserData=getUserData
	r.setUserData=setUserData
	return r
end

-- export ----
_new_root_tb=new


--flag
RTF_HIDE		=toDWORD('00000001') --“˛≤ÿ
RTF_FREEZE		=toDWORD('00000002') --∂≥Ω·
RTF_NORENDER	=toDWORD('00000004') --≤ª‰÷»æ
RTF_INSTANCE	=toDWORD('00000008') -- µ¿˝
RTF_NORTTRENDER	=toDWORD('00000010') --RenderToTexture ±≤ª‰÷»æ
RTF_NOSHADOW	=toDWORD('00000020') --not cast shadow


--noclip mask
NOCLIPMASK_ROOT			=toDWORD('40000000') -- root
NOCLIPMASK_MOVABLE		=toDWORD('20000000') -- movable
NOCLIPMASK_STATICMESH		=toDWORD('10000000') -- static mesh
NOCLIPMASK_SURFACE		=toDWORD('08000000') -- surface
NOCLIPMASK_TERRAIN		=toDWORD('04000000') -- terrain
NOCLIPMASK_OCEAN		=toDWORD('02000000') -- ocean

NOCLIPMASK_MOBILE		=toDWORD('00800000') -- mobile
NOCLIPMASK_CLOTH		=toDWORD('00400000') -- cloth
NOCLIPMASK_SKINMESH		=toDWORD('00200000') -- skin mesh
NOCLIPMASK_PLAYER		=toDWORD('00100000') -- player

NOCLIPMASK_MOVTAR		=toDWORD('00020000') -- movtar
NOCLIPMASK_BLOCKEDGE	=toDWORD('00010000') -- block edge
