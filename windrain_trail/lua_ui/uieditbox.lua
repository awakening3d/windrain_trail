
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("editbox expected") end

	local getText = function()
		return ctrl:get_text()
	end

	local setText = function( text )
		return ctrl:set_text( text )
	end
	
	local r=_new_uictrl_tb(ctrl)

	r.getText = getText
	r.setText = setText

	return r
end

-- export ----
_new_uieditbox_tb = new

