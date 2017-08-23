require 'obj_ani'

local function _new( obj )
	
	local amp = 80
	local speed = 260

	local dec = true
	local framemove = function(timed)

		if (amp<=0 and dec==false) then return true end

		if (amp<=0) then
		   amp = 80
		   dec = not dec
		end

		local degree = speed*timed
		if ( degree > amp ) then degree = amp end

		local r = obj.roty

		if (dec) then
			r = r - degree
		else
			r = r + degree
		end

		obj.roty = r

		amp = amp - degree

		return false
	end


	local r = obj_ani.new()

	r.framemove = framemove

	return r
end

-- export ----

sword_ani		=	{
	new	=	function( obj )
				return _new( obj )
			end,
}
