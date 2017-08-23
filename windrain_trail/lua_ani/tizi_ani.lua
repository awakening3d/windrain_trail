require 'obj_ani'

local function _new( obj, dec )
	
	local amp = 260
	local speed = 200

	obj.setName( string.reverse( obj.getName() ) )

	local framemove = function(timed)
		
		if (amp<=0) then
			obj.setName( string.reverse( obj.getName() ) )
			return true
		end

		local degree = speed*timed
		if ( degree > amp ) then degree = amp end

		local r = obj.getPosition()

		if (dec) then
			r.y = r.y + degree
			r.z = r.z - degree*0.3
		else
			r.y = r.y - degree
			r.z = r.z + degree*0.3
		end

		obj.setPosition(r)

		amp = amp - degree

		return false
	end


	local r = obj_ani.new()

	r.framemove = framemove

	PlaySound('\\drawerout.wav')

	return r
end

-- export ----

tizi_ani		=	{
	new	=	function( obj, dec )
				return _new( obj, dec )
			end,
}
