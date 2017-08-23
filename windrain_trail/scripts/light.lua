
local function new( light )
	if (type(light) ~= "userdata") then error("light expected") end
	
	local getType		=	function()
								return light:get_type()
							end
	local setType		=	function(type)
								light:set_type(type)
							end
	local getDirection =	function()
								return vec.new(light:get_direction())
							end
	local setDirection =	function(v)
								if (type(v) ~= "table") then error("vec expected") end
								light:set_direction(v.x,v.y,v.z)
							end
	local getDiffuse = function()
							return color.new(light:get_diffuse())
						end
	local setDiffuse = function(col)
							if (type(col) ~= "table") then error("color expected") end
							light:set_diffuse(col.r,col.g,col.b,col.a)
						end
	local getAmbient = function()
							return color.new(light:get_ambient())
						end
	local setAmbient = function(col)
							if (type(col) ~= "table") then error("color expected") end
							light:set_ambient(col.r,col.g,col.b,col.a)
						end
	local getSpecular = function()
							return color.new(light:get_specular())
						end
	local setSpecular = function(col)
							if (type(col) ~= "table") then error("color expected") end
							light:set_specular(col.r,col.g,col.b,col.a)
						end
	local getRange	=	function()
							return light:get_range()
						end
	local setRange	=	function(f)
							light:set_range(f)
						end
	local getFalloff =	function()
							return light:get_falloff()
						end
	local setFalloff =	function(f)
							light:set_falloff(f)
						end
	local getAttenuation =	function()
								return light:get_attenuation()
							end
	local setAttenuation =	function(a0,a1,a2)
								light:set_attenuation(a0,a1,a2)
							end
	local getTheta	=	function()
							return light:get_theta()
						end
	local setTheta	=	function(f)
							light:set_theta(f)
						end
	local getPhi	=	function()
							return light:get_phi()
						end
	local setPhi	=	function(f)
							light:set_phi(f)
						end
	local getStyle	=	function()
							return light:get_style()
						end
	local setStyle	=	function(style)
							light:set_style(style)
						end
	local getChannel	=	function()
								return light:get_channel()
							end
	local setChannel	=	function(dw)
								light:set_channel(dw)
							end

	local bind		=	function( movable )
								if (nil == movable) then return light:bind(_new_skinmesh_ud(nil),0) end
								light:bind( movable.getUD() )
							end
	local getBind		=	function()
								return light:get_bind()
							end



	local r=_new_root_tb(light)

	r.getType=getType
	r.setType=setType
	r.getDirection=getDirection
	r.setDirection=setDirection
	r.getDiffuse=getDiffuse
	r.setDiffuse=setDiffuse
	r.getAmbient=getAmbient
	r.setAmbient=setAmbient
	r.getSpecular=getSpecular
	r.setSpecular=setSpecular
	r.getRange=getRange
	r.setRange=setRange
	r.getFalloff=getFalloff
	r.setFalloff=setFalloff
	r.getAttenuation=getAttenuation
	r.setAttenuation=setAttenuation
	r.getTheta=getTheta
	r.setTheta=setTheta
	r.getPhi=getPhi
	r.setPhi=setPhi
	r.getStyle=getStyle
	r.setStyle=setStyle
	r.getChannel=getChannel
	r.setChannel=setChannel
	r.bind = bind
	r.getBind = getBind
	return r
end

-- export ----
_new_light_tb=new


LIGHT_TYPE_POINT          = 1	-- point
LIGHT_TYPE_SPOT           = 2	-- spot
LIGHT_TYPE_DIRECTIONAL    = 3	-- direction

LS_DISABLE		=toDWORD('00000021')		--关闭
LS_DYNAMIC		=toDWORD('00000002')		--动态
LS_SPECULARSPOT	=toDWORD('00000004')		-- specular spot
LS_REVERSE		=toDWORD('00000008')		--反转(产生阴影)
LS_SHAKE		=toDWORD('00000010')		--晃动(动态灯有效)
LS_DYNAMICSHADOW =toDWORD('00000100')		--投射动态阴影
LS_BAKED	= toDWORD('00000200')	--only for baking
LS_DYNAMICLIGHTMAP = toDWORD('00000400') --dynamic lightmap

