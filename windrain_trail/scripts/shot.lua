

local function new( shotud )
	if (type(shotud) ~= "userdata") then error("shot expected") end
	
	local getTimeLength	=	function()
								return shotud:get_timelength()
							end
	local setTimeLength =	function(timelen)
								shotud:set_timelength(timelen)
							end
	local getPosition	=	function()
								return vec.new(shotud:get_position())
							end
	local setPosition	=	function(v)
								if (type(v) ~= "table") then error("vec expected") end
								shotud:set_position(v.x,v.y,v.z)
							end
	local getRotation = function()
							return vec.new(shotud:get_rotation())
						end
	local setRotation = function(rot)
							if (type(rot) ~= "table") then error("vec expected") end
							shotud:set_rotation(rot.x,rot.y,rot.z)
						end
	local getFOV	=	function()
							return shotud:get_fov()
						end
	local setFOV	=	function(fov)
							shotud:set_fov(fov)
						end
	local isOrtho	=	function()
							return shotud:is_ortho()
						end
	local setOrtho	=	function(bOrtho)
							shotud:set_ortho(bOrtho)
						end
						
	local getViewMatrix =	function()
								local handle=shotud:get_view_matrix()
								if (NULL==handle)	then return nil end
								return matrix.new(handle)
							end
						
	local getProjMatrix =	function()
								local handle=shotud:get_proj_matrix()
								if (NULL==handle)	then return nil end
								return matrix.new(handle)
							end


	local r=_new_resource_tb(shotud)

	r.getTimeLength=getTimeLength
	r.setTimeLength=setTimeLength
	r.getPosition=getPosition
	r.setPosition=setPosition
	r.getRotation=getRotation
	r.setRotation=setRotation
	r.getFOV=getFOV
	r.setFOV=setFOV
	r.isOrtho=isOrtho
	r.setOrtho=setOrtho
	r.getViewMatrix=getViewMatrix
	r.getProjMatrix=getProjMatrix

	return r
end

-- export ----
_new_shot_tb=new

function GetPlayingShot()
	local pshot = _GetPlayingShot()
	if not pshot then return end
	return _new_shot_tb( _new_shot_ud( pshot ) )
end

--styles--
SHOTS_CIRCLE		= toDWORD('00000001') -- circle
SHOTS_NOTAFFECTCAM	= toDWORD('00000002') -- not affect camera
