

local function new( surfud )
	if (type(surfud) ~= "userdata") then error("d3dsurface expected") end
	
	local release	=	function()
								return surfud:release()
							end
	local getDesc	=	function()
							return surfud:get_desc()
						end

	local r=_new_udhead_tb(surfud)

	r.release=release
	r.getDesc=getDesc

	return r
end

-- export ----
_new_d3dsurface_tb=new
