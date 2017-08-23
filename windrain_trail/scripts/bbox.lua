
local function new( bbox )
	if (type(bbox) ~= "userdata") then error("bounding box expected") end
	
	local getMin	=	function()
							return vec.new(bbox:get_min())
						end
	local setMin	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							bbox:set_min(v.x,v.y,v.z)
						end
	local getMax	=	function()
							return vec.new(bbox:get_max())
						end
	local setMax	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							bbox:set_max(v.x,v.y,v.z)
						end
	local getCenter	=	function()
							return vec.new(bbox:get_center())
						end
	local clear		=	function()
							bbox:clear()
						end
	local fromBSphere =	function(bs)
							bbox:from_bsphere(bs.getUD())
						end
	local offset	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							bbox:offset(v.x,v.y,v.z)
						end
	local transform	=	function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							return bbox:transform(mat.getUD())
						end
	local intersectRay =	function(ray)
								return bbox:intersect_ray(ray.getUD())
							end
	local isPointInBox	=	function(v)
								if (type(v) ~= "table") then error("vec expected") end
								return bbox:is_point_in_box(v.x,v.y,v.z)
							end
	local isSphereOutBox	=	function(bs)
									return bbox:is_sphere_out_box(bs.getUD())
								end
	local isOutPlane =	function(plane)
							return bbox:is_out_plane(plane.getUD())
						end
	local boxRelation =	function(box)
							return bbox:box_relation(box.getUD())
						end

	
	local r=_new_udhead_tb(bbox)

	r.getMin=getMin
	r.setMin=setMin
	r.getMax=getMax
	r.setMax=setMax
	r.getCenter=getCenter
	r.clear=clear
	r.fromBSphere=fromBSphere
	r.offset=offset
	r.transform=transform
	r.intersectRay=intersectRay
	r.isPointInBox=isPointInBox
	r.isSphereOutBox=isSphereOutBox
	r.isOutPlane=isOutPlane
	r.boxRelation=boxRelation

	return r
end

-- export ----
_new_bbox_tb=new


-- Relations between two boxes: b1, b2 --
BBOXR_OUT=1			-- not intersect
BBOXR_IN=2			-- b2 within b1
BBOXR_INTERSECT=3	-- intersect ( include case of b1 within b2 )


bbox	=	{
	new	=	function(handle) --handle里的内容是拷贝到bbox table中，并且handle可以为空。 
				return _new_bbox_tb( _new_bbox_ud(handle) )
			end,
}
