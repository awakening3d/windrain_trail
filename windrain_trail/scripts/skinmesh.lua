
local function new( skinmesh )
	if (type(skinmesh) ~= "userdata") then error("skinmesh expected") end
	
	local getTexture =	function()
							return skinmesh:get_texture()
						end
	local setTexture =	function( tex )
							skinmesh:set_texture(tex)
						end
	local getBonesAni = function()
							local handle=skinmesh:get_bonesani()
							if (NULL==handle)	then return nil end
							return BonesAniFromHandle(handle)
						end
	local setBonesAni = function(ba)
							if (nil==ba) then return skinmesh:set_bonesani(_new_bonesani_ud(nil)) end
							if (type(ba) ~= "table") then error("bonesani expected") end
							skinmesh:set_bonesani(ba.getUD())
						end
	local getTimeAmp =	function()
							local handle=skinmesh:get_time_amp()
							if (not handle or NULL==handle)	then return nil end
							return AmplifierFromHandle(handle)
						end
	local getFrameTime =	function()
					return skinmesh:get_frame_time()
				end
	local setFrameTime =	function(time)
					return skinmesh:set_frame_time(time)
				end
	
	local getSynchShot =	function()
					return skinmesh:get_synch_shot()
				end
	
	local setSynchShot =	function(shotname)
					return skinmesh:set_synch_shot(shotname)
				end
	local clearCollision =	function()
					return skinmesh:clear_collision()
				end
	local buildCollision =	function()
					return skinmesh:build_collision()
				end


	local r=_new_movable_tb(skinmesh)

	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getBonesAni=getBonesAni
	r.setBonesAni=setBonesAni
	r.getTimeAmp=getTimeAmp
	r.getFrameTime=getFrameTime
	r.setFrameTime=setFrameTime
	r.getSynchShot=getSynchShot
	r.setSynchShot=setSynchShot
	r.clearCollision=clearCollision
	r.buildCollision=buildCollision

	return r
end

-- export ----
_new_skinmesh_tb=new
