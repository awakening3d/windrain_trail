
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("button expected") end

	local r=_new_uistatic_tb(ctrl)

	return r
end

-- export ----
_new_uibutton_tb = new

