
local function new( resource )
	if (type(resource) ~= "userdata") then error("resource expected") end
	
	local getName	=	function()
							return resource:get_name()
						end
	local setName	=	function(name)
							resource:set_name(name)
						end
	local getStyle =	function()
							return resource:get_style()
						end
	local setStyle =	function( style )
							resource:set_style(style)
						end

	local r=_new_animation_tb(resource)

	r.getName=getName
	r.setName=setName
	r.getStyle=getStyle
	r.setStyle=setStyle

	return r
end


-- export ----
_new_resource_tb=new
