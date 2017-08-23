
local function new( movgroup )
	if (type(movgroup) ~= "userdata") then error("movgroup expected") end
	
	local r=_new_movable_tb(movgroup)

	return r
end

-- export ----
_new_movgroup_tb=new
