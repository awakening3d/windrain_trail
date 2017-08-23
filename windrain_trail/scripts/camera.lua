
local function new( camera )
	if (type(camera) ~= "userdata") then error("camera expected") end
	
	local getRotation = function()
							return vec.new(camera:get_rotation())
						end
	local setRotation = function(rot)
							if (type(rot) ~= "table") then error("vec expected") end
							camera:set_rotation(rot.x,rot.y,rot.z)
						end
	local getRight =	function()
							return vec.new(camera:get_right())
						end
	local getUp =		function()
							return vec.new(camera:get_up())
						end
	local getFront =	function()
							return vec.new(camera:get_front())
						end
	local getViewMatrix =	function()
								local handle=camera:get_view_matrix()
								if (NULL==handle)	then return nil end
								return matrix.new(handle)
							end
	local getInvViewMatrix =	function()
									local handle=camera:get_inv_view_matrix()
									if (NULL==handle)	then return nil end
									return matrix.new(handle)
								end
	local getProjMatrix =	function()
								local handle=camera:get_proj_matrix()
								if (NULL==handle)	then return nil end
								return matrix.new(handle)
							end
	local circlePoint	=	function(yaw,pitch,pos)
								camera:circle_point(yaw,pitch,pos.x,pos.y,pos.z)
							end
	
	local r=_new_root_tb(camera)

	r.getRotation=getRotation
	r.setRotation=setRotation
	r.getRight=getRight
	r.getUp=getUp
	r.getFront=getFront
	r.getViewMatrix=getViewMatrix
	r.getInvViewMatrix=getInvViewMatrix
	r.getProjMatrix=getProjMatrix
	r.circlePoint=circlePoint

	return r
end

-- export ----
_new_camera_tb=new
