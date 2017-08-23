
local function new( segment )
	if (type(segment) ~= "userdata") then error("segment expected") end
	
	local getStart	=	function()
							return vec.new(segment:get_start())
						end
	local setStart	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							segment:set_start(v.x,v.y,v.z)
						end
	local getEnd	=	function()
							return vec.new(segment:get_end())
						end
	local setEnd	=	function(v)
							if (type(v) ~= "table") then error("vec expected") end
							segment:set_end(v.x,v.y,v.z)
						end

	local r=_new_udhead_tb(segment)

	r.getStart=getStart
	r.setStart=setStart
	r.getEnd=getEnd
	r.setEnd=setEnd
	
	return r
end

-- export ----
_new_segment_tb=new



segment	=	{
	new	=	function(handle) --handle里的内容是拷贝到segment table中，并且handle可以为空。 
				return _new_segment_tb( _new_segment_ud(handle) )
			end,
}
