
local function new( trace )
	if (type(trace) ~= "userdata") then error("trace expected") end
	
	local getPointer =	function()
							return trace:get_pointer()
						end
	local isPoint	=	function()
							return trace:is_point()
						end
	local pointed		=	function(p)
								trace:pointed(p)
							end
	local getRadius		=	function()
								return trace:get_radius()
							end
	local setRadius		=	function(radius)
								trace:set_radius(radius)
							end
	local getBoundingBox =	function()
								local handle=trace:get_boundingbox()
								if (NULL==handle) then return nil end
								return bbox.new(handle)
							end
	local setBoundingBox =	function(bb)
								if (type(bb) ~= "table") then error("bounding box expected") end
								trace:set_boundingbox(bb.getUD())
							end

	local getStart	=	function()
							return vec.new(trace:get_start())
						end
	local setStart	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							trace:set_start(v.x,v.y,v.z)
						end
	local getEnd	=	function()
							return vec.new(trace:get_end())
						end
	local setEnd	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							trace:set_end(v.x,v.y,v.z)
						end

	local getNoClipMask =	function()
								return trace:get_noclip_mask()
							end
	local setNoClipMask =	function(mask)
								trace:set_noclip_mask(mask)
							end



	local getFraction =	function()
							return trace:get_fraction()
						end
	local getStop	=	function()
							return vec.new(trace:get_stop())
						end
	local getPlane =	function()
							local handle=trace:get_plane()
							if (NULL==handle) then return nil end
							return plane.new(handle)
						end
	local getOffset =	function()
							return trace:get_offset()
						end
	local getBlockObject=	function()
					local pobj,type=trace:get_block_object()
					if ('surface'==type) then
						pobj=SurfaceFromHandle(pobj)
					elseif ('staticmesh'==type) then
						pobj=StaticMeshFromHandle(pobj)
					elseif ('terrain'==type) then
						pobj=TerrainFromHandle(pobj)
					elseif ('ocean'==type) then
						pobj=OceanFromHandle(pobj)
					elseif ('mobile'==type) then
						pobj=MobileFromHandle(pobj)
					elseif ('skinmesh'==type) then
						pobj=SkinMeshFromHandle(pobj)
					elseif ('player'==type) then
						pobj=PlayerFromHandle(pobj)
					elseif ('group'==type) then
						pobj=MovGroupFromHandle(pobj)
					elseif ('movtar'==type) then
						pobj=MovTarFromHandle(pobj)
					elseif ('unknown'==type) then
						pobj=UnknownObjFromHandle(pobj)
					end
					return pobj,type
				end


	local r=_new_udhead_tb(trace)

	r.getPointer=getPointer
	r.isPoint=isPoint
	r.pointed=pointed
	r.getRadius=getRadius
	r.setRadius=setRadius
	r.getBoundingBox=getBoundingBox
	r.setBoundingBox=setBoundingBox
	r.getStart=getStart
	r.setStart=setStart
	r.getEnd=getEnd
	r.setEnd=setEnd
	r.getNoClipMask=getNoClipMask
	r.setNoClipMask=setNoClipMask
	
	r.getFraction=getFraction
	r.getStop=getStop
	r.getPlane=getPlane
	r.getOffset=getOffset
	r.getBlockObject=getBlockObject
	
	return r
end

-- export ----
_new_trace_tb=new



trace	=	{
	new	=	function(handle) --handle里的内容是拷贝到trace table中，并且handle可以为空。 
				return _new_trace_tb( _new_trace_ud(handle) )
			end,
}
