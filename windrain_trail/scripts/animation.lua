
local mt={} --metatable


local function new( animation )
	if (type(animation) ~= "userdata") then error("animation expected") end
	
	local getPointer =	function()
					return animation:get_pointer()
				end
	local clearController =	function()
					return animation:clear_controller()
				end

	local r=_new_udhead_tb(animation)

	r.getPointer=getPointer
	r.clearController=clearController

	setmetatable(r, mt)
	return r
end


local function eq(r1,r2)
	return r1.getPointer()==r2.getPointer()
end


mt.__eq=eq;		-- '=='


-- export ----
_new_animation_tb=new
