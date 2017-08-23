
-- global variable --
NULL	=	toDWORD('0')

AXIS_NONE	=	255
AXIS_X		=	0
AXIS_Y		=	1
AXIS_Z		=	2
AXIS_ALL	=	3


-- global function --

function UnknownObjFromHandle(handle)
	local obj={}
	obj.handle=handle;
	obj.getClassID =	function()
							return UD_NONE;
						end

	return obj
end

function MobileFromHandle(handle)
	return _new_mobile_tb( _new_mobile_ud(handle) )
end

function MovGroupFromHandle(handle)
	return _new_movgroup_tb( _new_movgroup_ud(handle) )
end

function SkinMeshFromHandle(handle)
	return _new_skinmesh_tb( _new_skinmesh_ud(handle) )
end

function ClothFromHandle(handle)
	return _new_cloth_tb( _new_cloth_ud(handle) )
end

function ClothExFromHandle(handle)
	return _new_clothex_tb( _new_clothex_ud(handle) )
end

function Text2DFromHandle(handle)
	return _new_text2d_tb( _new_text2d_ud(handle) )
end

function Image2DFromHandle(handle)
	return _new_image2d_tb( _new_image2d_ud(handle) )
end

function BillboardFromHandle(handle)
	return _new_billboard_tb( _new_billboard_ud(handle) )
end

function ParticlesFromHandle(handle)
	return _new_particles_tb( _new_particles_ud(handle) )
end

function SpotFromHandle(handle)
	return _new_spot_tb( _new_spot_ud(handle) )
end

function LightFromHandle(handle)
	return _new_light_tb( _new_light_ud(handle) )
end

function SurfaceFromHandle(handle)
	return _new_surface_tb( _new_surface_ud(handle) )
end

function StaticMeshFromHandle(handle)
	return _new_staticmesh_tb( _new_staticmesh_ud(handle) )
end

function TerrainFromHandle(handle)
	return _new_terrain_tb( _new_terrain_ud(handle) )
end

function OceanFromHandle(handle)
	return _new_ocean_tb( _new_ocean_ud(handle) )
end

function MaterialFromHandle(handle)
	return _new_material_tb( _new_material_ud(handle) )
end

function PostFromHandle(handle)
	return _new_post_tb( _new_post_ud(handle) )
end

function ShotFromHandle(handle)
	return _new_shot_tb( _new_shot_ud(handle) )
end

function BonesAniFromHandle(handle)
	return _new_bonesani_tb( _new_bonesani_ud(handle) )
end

function AmplifierFromHandle(handle)
	return _new_amplifier_tb( _new_amplifier_ud(handle) )
end

function TexturePlayFromHandle(handle)
	return _new_textureplay_tb( _new_textureplay_ud(handle) )
end

function CommandTarFromHandle(handle)
	return _new_commandtar_tb( _new_commandtar_ud(handle) )
end

function CameraFromHandle(handle)
	return _new_camera_tb( _new_camera_ud(handle) )
end

function MovTarFromHandle(handle)
	return _new_movtar_tb( _new_movtar_ud(handle) )
end

function PlayerFromHandle(handle)
	return _new_player_tb( _new_player_ud(handle) )
end


function DWORDtoColor(dw)
	r,g,b,a=DWORDtoRGBA(dw)
	return color.new(r,g,b,a)
end

function ColortoDWORD(color)
	return RGBAtoDWORD(color.r,color.g,color.b,color.a)
end


function WorldToScreen(v)
	return vec.new(_WorldToScreen(v.x,v.y,v.z))
end

function ScreenToWorld(v)
	return vec.new(_ScreenToWorld(v.x,v.y,v.z))
end

function GetSceneCenter()
	return vec.new(_GetSceneCenter())
end

function SetSceneCenter(v)
	return _SetSceneCenter(v.x,v.y,v.z)
end

function GetRayFromPoint(x,y)
	local handle=_GetRayFromPoint(x,y)
	if (NULL==handle) then return nil end -- create failed
	return ray.new(handle)
end

function MatrixToYawPitchRoll(m)
	return _MatrixToYawPitchRoll(m.getUD())
end

function VectorToYawPitch(v)
	return _VectorToYawPitch(v.x,v.y,v.z)
end

function ModifyStyle(dwStyle, dwRemove, dwAdd)
	dwStyle = andDWORD(dwStyle, notDWORD(dwRemove) )
	dwStyle = orDWORD(dwStyle, dwAdd)
	return dwStyle;	
end
