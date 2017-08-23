
local function new( plane )
	if (type(plane) ~= "userdata") then error("plane expected") end
	
	local getNormal	=	function()
							return vec.new(plane:get_normal())
						end
	local setNormal	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							plane:set_normal(v.x,v.y,v.z)
						end
	local getDistance =	function()
							return plane:get_distance()
						end
	local setDistance =	function(d)
							plane:set_distance(d)
						end
	local distanceToPoint =	function(v)
								if (type(v) ~= "table") then error("vec expected") end
								return plane:distance_to_point(v.x,v.y,v.z)
							end
	local intersectRay =	function(ray)
								if (type(ray) ~= "table") then error("ray expected") end
								x,y,z=plane:intersect_ray(ray.getUD())
								if (x) then
									return vec.new(x,y,z)
								else
									return nil
								end
							end
	local intersectSegment =	function(seg)
								if (type(seg) ~= "table") then error("segment expected") end
								x,y,z=plane:intersect_segment(seg.getUD())
								if (x) then
									return vec.new(x,y,z)
								else
									return nil
								end
							end
	local flip		=	function()
							return plane:flip()
						end
	local fast_transform	=	function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							return plane:fast_transform(mat.getUD())
						end
	local transform	=	function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							return plane:transform(mat.getUD())
						end


	local r=_new_udhead_tb(plane)

	r.getNormal=getNormal
	r.setNormal=setNormal
	r.getDistance=getDistance
	r.setDistance=setDistance
	r.distanceToPoint=distanceToPoint
	r.intersectRay=intersectRay
	r.intersectSegment=intersectSegment
	r.flip=flip
	r.fast_transform=fast_transform
	r.transform=transform

	return r
end

-- export ----
_new_plane_tb=new



plane	=	{
	new	=	function(handle) --handle里的内容是拷贝到plane table中，并且handle可以为空。 
				return _new_plane_tb( _new_plane_ud(handle) )
			end,
}
