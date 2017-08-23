
local function new( ud )
	if (type(ud) ~= "userdata") then error("userdata expected") end
	
	local getUD	=		function()
							return ud
						end
	local getClassID =	function()
							return ud:get_classid()
						end

	local t={	getUD=getUD,
				getClassID=getClassID,
			}
	return t
end


-- export ----
_new_udhead_tb=new


UD_NONE			=toDWORD('00000000') --none, invalid userdata
UD_MATRIX		=toDWORD('00000001') --matrix
UD_MATERIAL		=toDWORD('00000002') --material
UD_LIGHT		=toDWORD('00000003') --light
UD_MOBILE		=toDWORD('00000004') --mobile
UD_BILLBOARD	=toDWORD('00000005') --billbord
UD_PARTICLES	=toDWORD('00000006') --particles
UD_IMAGE2D		=toDWORD('00000007') --image2d
UD_TEXT2D		=toDWORD('00000008') --text2d
UD_CAMERA		=toDWORD('00000009') --camera
UD_DRAW			=toDWORD('0000000a') --draw
UD_SURFACE		=toDWORD('0000000b') --surface
UD_TEXTUREPLAY	=toDWORD('0000000c') --texture play
UD_COMMANDTAR	=toDWORD('0000000d') --command target
UD_SCENE		=toDWORD('0000000e') --scene
UD_BONESANI		=toDWORD('0000000f') --bones animation
UD_SKINMESH		=toDWORD('00000010') --skin mesh
UD_STATICMESH	=toDWORD('00000011') --static mesh
UD_MOVTAR		=toDWORD('00000012') --move target
UD_TEXTURELIST	=toDWORD('00000013') --texture list
UD_SPOT			=toDWORD('00000014') --spot
UD_MOVGROUP		=toDWORD('00000016') --mov group
UD_CLOTH		=toDWORD('00000018') --cloth
UD_TERRAIN		=toDWORD('0000001a') --terrain
UD_OCEAN		=toDWORD('0000001b') --ocean
UD_CLOTHEX		=toDWORD('0000001c') --clothex

UD_RAY			=toDWORD('00000100') --ray
UD_SEGMENT		=toDWORD('00000200') --segment
UD_PLANE		=toDWORD('00000300') --plane
UD_BSPHERE		=toDWORD('00000400') --bounding sphere
UD_BBOX			=toDWORD('00000500') --bounding box
UD_FRUSTUM		=toDWORD('00000600') --frustum

UD_PLAYER		=toDWORD('00010000') --player


--改变这个列表注意是否要更新root.lua中的clone()