--lipper--

-- you need create a material with name 'mater_lipper' in your scene, load the 'water\\lakeSpotLipper.fx' shader,
-- assign 5 textures: reflect, refract, depth, bump, ripple,
-- and check it's Transparence in D3D Effect rollout.

require('tempobj')

local function _new(pos, lifetime, scale, strength  )
	if not pos then return end
	local mov=scene.createMobile('\\planeHi.tri')
	if not mov then return end
	mov.noRTTRender(true)
	mov.setStyle( ModifyStyle( mov.getStyle(), 0, MOVS_NOCLIP ) )

	local t=tempobj.new()
	lifetime = lifetime or 1
	scale = scale or .3
	t.setLifeTime(lifetime)
	strength = strength or 1

	local mater=find_material('mater_lipper')
	if mater then mov.setMaterial(mater) end
	mov.setScale(vec.new(scale,scale,scale))
	mov.setPosition(pos)

	local R = scale * 50 -- °ë¾¶

	local _frameMove = t.frameMove
	t.frameMove	=	function(timed)
						local ret=_frameMove(timed)
						R = R + timed*40
						local S  = R/50
						mov.setScale( vec.new(S,S,S) )
						mov.setUserData( vec4.new( strength* t.getLifeTime() / lifetime, 0,0,0) )
						return ret
					end

	local _deleteThis	=	t.deleteThis
	t.deleteThis	=	function()
						scene.deleteMobile(mov)
						return _deleteThis()
					end

	t.setPosition	=	function(pos)
						mov.setPosition(pos)
					end

	return t
end

-- export ----
lipper	=	{
	new	= _new
}
