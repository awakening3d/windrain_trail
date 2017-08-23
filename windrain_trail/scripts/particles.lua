
local function new( particles )
	if (type(particles) ~= "userdata") then error("particles expected") end
	
	local setMatrix =	function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							particles:set_matrix(mat.getUD())
						end
	local getColor	=	function()
							return particles:get_color()
						end
	local setColor	=	function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							particles:set_color(dwcolor)
						end
	local getAmount	=	function()
							return particles:get_amount()
						end
	local setAmount	=	function(am)
							return particles:set_amount(am)
						end
	local getSize	=	function()
							return particles:get_size()
						end
	local setSize	=	function(size)
							return particles:set_size(size)
						end
	local getBox	=	function()
							return vec.new(particles:get_box())
						end
	local setBox	=	function(pos)
							if (type(pos) ~= "table") then error("vec expected") end
							particles:set_box(pos.x,pos.y,pos.z)
						end
	local getAcceleration =	function()
								return vec.new(particles:get_acceleration())
							end
	local setAcceleration =	function(accel)
								if (type(accel) ~= "table") then error("vec expected") end
								particles:set_acceleration(accel.x,accel.y,accel.z)
							end
	local getVelocity	=	function()
								return vec.new(particles:get_velocity())
							end
	local setVelocity	=	function(vel)
								if (type(vel) ~= "table") then error("vec expected") end
								particles:set_velocity(vel.x,vel.y,vel.z)
							end
	local getType	=		function()
								return particles:get_type()
							end
	local setType	=		function(type)
								particles:set_type(type)
							end
	local getTexture =	function()
							return particles:get_texture()
						end
	local setTexture =	function( tex )
							particles:set_texture(tex)
						end
	local getMoveNoise =	function()
								return particles:get_move_noise()
							end
	local setMoveNoise =	function(noise)
								return particles:set_move_noise(noise)
							end
	local getSpinNoise =	function()
								return particles:get_spin_noise()
							end
	local setSpinNoise =	function(noise)
								return particles:set_spin_noise(noise)
							end


	local r=_new_effect_tb(particles)

	r.setMatrix=setMatrix
	r.getColor=getColor
	r.setColor=setColor
	r.getAmount=getAmount
	r.setAmount=setAmount
	r.getSize=getSize
	r.setSize=setSize
	r.getBox=getBox
	r.setBox=setBox
	r.getAcceleration=getAcceleration
	r.setAcceleration=setAcceleration
	r.getVelocity=getVelocity
	r.setVelocity=setVelocity
	r.getType=getType
	r.setType=setType
	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getMoveNoise=getMoveNoise
	r.setMoveNoise=setMoveNoise
	r.getSpinNoise=getSpinNoise
	r.setSpinNoise=setSpinNoise
	
	return r
end

-- export ----
_new_particles_tb=new

--type

PARTICLES_TYPE_RAIN	= 1			--ÏÂÓê(Ñ©)
PARTICLES_TYPE_EXPLODE	= 2		--±¬Õ¨

--style

PARS_CYCLE			=toDWORD('00000002') --Ñ­»·
PARS_SPINNOISE		=toDWORD('00000004') --Ðý×ªÈÅ¶¯
PARS_MOVENOISE		=toDWORD('00000008') --ÒÆ¶¯ÈÅ¶¯
PARS_FOLLOWCAMERA	=toDWORD('00000010') --¸úËæÉãÏñ»ú
PARS_ALPHATEST		=toDWORD('00000020') --alpha test
