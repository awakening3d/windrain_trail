
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("checkbox expected") end
--[[
	local getStyle = function()
		return ctrl:get_style()
	end

	local setStyle = function( style )
		return ctrl:set_style( style )
	end
--]]
	local isChecked = function()
		return ctrl:is_checked()
	end

	local setChecked = function( checked )
		return ctrl:set_checked( checked )
	end

	local r=_new_uibutton_tb(ctrl)

--	r.getStyle = getStyle
--	r.setStyle = setStyle
	r.isChecked = isChecked
	r.setChecked = setChecked

	return r
end

-- export ----
_new_uicheckbox_tb = new
