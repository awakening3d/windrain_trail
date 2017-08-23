
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("slider expected") end

	local getValue = function()
		return ctrl:get_value()
	end

	local setValue = function( v )
		return ctrl:set_value( v )
	end

	local getRange = function()
		return ctrl:get_range()
	end

	local setRange = function(min, max)
		return ctrl:set_range(min, max)
	end
	
	local r=_new_uictrl_tb(ctrl)

	r.getValue = getValue
	r.setValue = setValue
	r.getRange = getRange
	r.setRange = setRange

	return r
end

-- export ----
_new_uislider_tb = new

