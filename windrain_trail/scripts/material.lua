

local function new( matud )
	if (type(matud) ~= "userdata") then error("material expected") end
	
	local getDiffuse = function()
							return color.new(matud:get_diffuse())
						end
	local setDiffuse = function(col)
							if (type(col) ~= "table") then error("color expected") end
							matud:set_diffuse(col.r,col.g,col.b,col.a)
						end
	local getAmbient = function()
							return color.new(matud:get_ambient())
						end
	local setAmbient = function(col)
							if (type(col) ~= "table") then error("color expected") end
							matud:set_ambient(col.r,col.g,col.b,col.a)
						end
	local getSpecular = function()
							return color.new(matud:get_specular())
						end
	local setSpecular = function(col)
							if (type(col) ~= "table") then error("color expected") end
							matud:set_specular(col.r,col.g,col.b,col.a)
						end
	local getEmissive = function()
							return color.new(matud:get_emissive())
						end
	local setEmissive = function(col)
							if (type(col) ~= "table") then error("color expected") end
							matud:set_emissive(col.r,col.g,col.b,col.a)
						end
	local getPower	=	function()
							return matud:get_power()
						end
	local setPower	=	function(power)
							matud:set_power(power)
						end
	local getShadeMode =	function()
								return matud:get_shade_mode()
							end
	local setShadeMode =	function(sm)
								matud:set_shade_mode(sm)
							end
	local getTexture =	function(layer)
							return matud:get_texture(layer)
						end
	local setTexture =	function(layer,tex)
							matud:set_texture(layer,tex)
						end
	local getD3DEffect	=	function()
								return matud:get_d3deffect()
							end
	local setD3DEffect	=	function(filename)
								matud:set_d3deffect(filename)
							end
	local getTexturePlay =	function()
								local handle=matud:get_texture_play()
								if (NULL==handle)	then return nil end
								return TexturePlayFromHandle(handle)
							end
	local setTexturePlay =	function(tp)
								if (nil==tp) then return matud:set_texture_play(_new_textureplay_ud(nil)) end
								if (type(tp) ~= "table") then error("texture play expected") end
								matud:set_texture_play(tp.getUD())
							end

	local getShadowSource = function()
								local handle = matud:get_shadow_source()
								if (NULL==handle) then return nil end
								return MaterialFromHandle(handle)
							end
	
	local getShadowDest = function()
								local handle = matud:get_shadow_dest()
								if (NULL==handle) then return nil end
								return MaterialFromHandle(handle)
							end

	local getShadowDepth = function()
								local handle = matud:get_shadow_depth()
								if (NULL==handle) then return nil end
								return MaterialFromHandle(handle)
							end

	local setShadowSource =	function(mater)
								if (nil==mater) then return matud:set_shadow_source(_new_material_ud(nil)) end
								if (type(mater) ~= "table") then error("material expected") end
								matud:set_shadow_source(mater.getUD())
							end

	local setShadowDest =	function(mater)
								if (nil==mater) then return matud:set_shadow_dest(_new_material_ud(nil)) end
								if (type(mater) ~= "table") then error("material expected") end
								matud:set_shadow_dest(mater.getUD())
							end

	local setShadowDepth =	function(mater)
								if (nil==mater) then return matud:set_shadow_depth(_new_material_ud(nil)) end
								if (type(mater) ~= "table") then error("material expected") end
								matud:set_shadow_depth(mater.getUD())
							end
	local getFactor = function()
								return matud:get_factor()
							end
	local setFactor = function(x,y,z,w)
								return matud:set_factor(x,y,z,w)
							end


	local findValidTechnique = function(name)		return matud:find_valid_technique(name)
							end
	local getTechnique = function()				return matud:get_technique()
							end
	local setTechnique = function(name)			return matud:set_technique(name)
							end
	local validateEffect = function()		
								return matud:validate_effect()
							end

	local getEffectBool =	function(name)
								return matud:get_effect_bool(name)
							end
	local setEffectBool =	function(name,bValue)
								return matud:set_effect_bool(name,bValue)
							end
	local getEffectDword =	function(name)
								return matud:get_effect_dword(name)
							end
	local setEffectDword =	function(name,dwValue)
								return matud:set_effect_dword(name,dwValue)
							end
	local getEffectFloat =	function(name)
								return matud:get_effect_float(name)
							end
	local setEffectFloat =	function(name,fValue)
								return matud:set_effect_float(name,fValue)
							end
	local getEffectVector =	function(name)
								return vec4.new(matud:get_effect_vector(name))
							end
	local setEffectVector =	function(name,vValue)
								return matud:set_effect_vector(name,vValue.x,vValue.y,vValue.z,vValue.w)
							end
	local getEffectMatrix =	function(name)
								local handle=matud:get_effect_matrix(name)
								if (nil==handle) then return nil end
								return matrix.new(handle)
							end
	local setEffectMatrix =	function(name,mat)
								if (type(mat) ~= "table") then error("matrix expected") end
								matud:set_effect_matrix(name,mat.getUD())
							end
	local getEffectString =	function(name)
								return matud:get_effect_string(name)
							end
	local setEffectString =	function(name,str)
								matud:set_effect_string(name,str)
							end
	local setEffectTexture = function(name,ntex)
								matud:set_effect_texture(name,ntex)
							 end


	local r=_new_resource_tb(matud)

	r.getDiffuse=getDiffuse
	r.setDiffuse=setDiffuse
	r.getAmbient=getAmbient
	r.setAmbient=setAmbient
	r.getSpecular=getSpecular
	r.setSpecular=setSpecular
	r.getEmissive=getEmissive
	r.setEmissive=setEmissive
	r.getPower=getPower
	r.setPower=setPower
	r.getShadeMode=getShadeMode
	r.setShadeMode=setShadeMode
	r.getTexture=getTexture
	r.setTexture=setTexture
	r.getD3DEffect=getD3DEffect
	r.setD3DEffect=setD3DEffect
	r.getTexturePlay=getTexturePlay
	r.setTexturePlay=setTexturePlay

	r.getShadowSource = getShadowSource
	r.getShadowDest = getShadowDest
	r.getShadowDepth = getShadowDepth

	r.setShadowSource = setShadowSource
	r.setShadowDest = setShadowDest
	r.setShadowDepth = setShadowDepth

	r.getFactor = getFactor
	r.setFactor = setFactor

	r.findValidTechnique=findValidTechnique
	r.getTechnique=getTechnique
	r.setTechnique=setTechnique
	r.validateEffect=validateEffect

	r.getEffectBool=getEffectBool
	r.setEffectBool=setEffectBool
	r.getEffectDword=getEffectDword
	r.setEffectDword=setEffectDword
	r.getEffectFloat=getEffectFloat
	r.setEffectFloat=setEffectFloat
	r.getEffectVector=getEffectVector
	r.setEffectVector=setEffectVector
	r.getEffectMatrix=getEffectMatrix
	r.setEffectMatrix=setEffectMatrix
	r.getEffectString=getEffectString
	r.setEffectString=setEffectString
	r.setEffectTexture=setEffectTexture

	return r
end

-- export ----
_new_material_tb=new

SHADEMODE_FLAT               = 1
SHADEMODE_GOURAUD            = 2
SHADEMODE_PHONG              = 3

--styles--
MATERS_SPECULAR			= toDWORD('00000001') --specular
MATERS_CAUSTIC			= toDWORD('00000002') --caustic
MATERS_TRANSPARENCE		= toDWORD('00000004') --transparence
MATERS_NORECEIVESHADOW		= toDWORD('00000008') --no receive shadow
