

local function new( ampud )
	if (type(ampud) ~= "userdata") then error("amplifier expected") end
	
	local getPreOffset	=	function()
								return ampud:get_preoffset()
							end
	local setPreOffset	=	function(num)
								return ampud:set_preoffset(num)
							end
	local getZoom	=		function()
								return ampud:get_zoom()
							end
	local setZoom	=		function(num)
								return ampud:set_zoom(num)
							end
	local getPostOffset	=	function()
								return ampud:get_postoffset()
							end
	local setPostOffset	=	function(num)
								return ampud:set_postoffset(num)
							end
	local amplify		=	function(num)
						return ampud:amplify(num)
					end


	local r=_new_udhead_tb(ampud)

	r.getPreOffset=getPreOffset
	r.setPreOffset=setPreOffset
	r.getZoom=getZoom
	r.setZoom=setZoom
	r.getPostOffset=getPostOffset
	r.setPostOffset=setPostOffset
	r.amplify=amplify

	return r
end

-- export ----
_new_amplifier_tb=new
