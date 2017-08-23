
local function new( player )
	if (type(player) ~= "userdata") then error("player expected") end
	
	local getMovTar	=	function()
							local handle=player:get_movtar()
							return MovTarFromHandle(handle)
						end
	local duck		=	function()
							player:duck()
						end
	local jump		=	function()
							player:jump()
						end
	local waterJump	=	function()
							player:water_jump()
						end
	local stand		=	function()
							player:stand()
						end
	local go		=	function(vel)
							if (type(vel) ~= "table") then error("vec expected") end
							player:go(vel.x,vel.y,vel.z)
						end
	local getFrontDir	=	function()
								return vec.new(player:get_front_dir())
							end
	local getEyePos		=	function()
								return vec.new(player:get_eye_pos())
							end
	
	local getGround		=	function()
						local pgr,type=player:get_ground()
						if ('surface'==type) then
							pgr=SurfaceFromHandle(pgr)
						elseif ('staticmesh'==type) then
							pgr=StaticMeshFromHandle(pgr)
						elseif ('terrain'==type) then
							pgr=TerrainFromHandle(pgr)
						elseif ('ocean'==type) then
							pgr=OceanFromHandle(pgr)
						elseif ('mobile'==type) then
							pgr=MobileFromHandle(pgr)
						elseif ('skinmesh'==type) then
							pgr=SkinMeshFromHandle(pgr)
						elseif ('player'==type) then
							pgr=PlayerFromHandle(pgr)
						elseif ('group'==type) then
							pgr=MovGroupFromHandle(pgr)
						elseif ('movtar'==type) then
							pgr=MovTarFromHandle(pgr)
						elseif ('unknown'==type) then
							pgr=UnknownObjFromHandle(pgr)
						end
						return pgr,type
					end

	local getJumpmoveStep = function()
		return player:get_jumpmove_step()
	end

	local setJumpmoveStep = function( step )
		return player:set_jumpmove_step(step)
	end


	local r=_new_movable_tb(player)

	r.getMovTar=getMovTar
	r.duck=duck
	r.jump=jump
--	r.waterJump=waterJump
	r.stand=stand
	r.go=go
--	r.getFrontDir=getFrontDir
	r.getEyePos=getEyePos
	r.getGround=getGround
	r.getJumpmoveStep=getJumpmoveStep
	r.setJumpmoveStep=setJumpmoveStep

	return r
end

-- export ----
_new_player_tb=new
