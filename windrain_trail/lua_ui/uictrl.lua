
local function new( ctrl )
	if (type(ctrl) ~= "userdata") then error("control expected") end

	local getVisible = function()
		return ctrl:get_visible()
	end

	local setVisible = function( bVisible )
		return ctrl:set_visible(bVisible)
	end

	local getEnable = function()
		return ctrl:get_enable()
	end

	local setEnable = function( bEnable )
		return ctrl:set_enable(bEnable)
	end

	local getType = function()
		return ctrl:get_type()
	end

	local getID = function()
		return ctrl:get_id()
	end

	local setID = function( id )
		return ctrl:set_id( id )
	end

	local function getRect()
		return rect.new( ctrl:get_rect() )
	end

	local function setRect( r )
		return ctrl:set_rect( r.left, r.top, r.right, r.bottom )
	end


	
	local r=_new_udhead_tb(ctrl)

	r.getVisible = getVisible
	r.setVisible = setVisible
	r.getEnable = getEnable
	r.setEnable = setEnable
	r.getType = getType
	r.getID = getID
	r.setID = setID
	r.getRect = getRect
	r.setRect = setRect

	return r
end

-- export ----
_new_uictrl_tb = new

