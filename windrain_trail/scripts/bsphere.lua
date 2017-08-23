
local function new( bsphere )
	if (type(bsphere) ~= "userdata") then error("bounding sphere expected") end
	
	local getCenter	=	function()
							return vec.new(bsphere:get_center())
						end
	local setCenter	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							bsphere:set_center(v.x,v.y,v.z)
						end
	local getRadius =	function()
							return bsphere:get_radius()
						end
	local setRadius =	function(r)
							bsphere:set_radius(r)
						end
	local clear		=	function()
							bsphere:clear()
						end
	local fromBBox	=	function(bb)
							bsphere:from_bbox(bb.getUD())
						end
	local offset	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							bsphere:offset(v.x,v.y,v.z)
						end
	local intersectRay =	function(ray)
								return bsphere:intersect_ray(ray.getUD())
							end
	local isOutPlane =	function(plane)
							return bsphere:is_out_plane(plane.getUD())
						end


	local r=_new_udhead_tb(bsphere)

	r.getCenter=getCenter
	r.setCenter=setCenter
	r.getRadius=getRadius
	r.setRadius=setRadius
	r.clear=clear
	r.fromBBox=fromBBox
	r.offset=offset
	r.intersectRay=intersectRay
	r.isOutPlane=isOutPlane

	return r;
end

-- export ----
_new_bsphere_tb=new



bsphere	=	{
	new	=	function(handle) --handle里的内容是拷贝到bsphere table中，并且handle可以为空。 
				return _new_bsphere_tb( _new_bsphere_ud(handle) )
			end,
}
