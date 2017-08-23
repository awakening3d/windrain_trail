require 'obj_ani'

local function _new( obj, dec )
	
	local amp = 80
	local speed = 60

	obj.setName( string.reverse( obj.getName() ) )

	local framemove = function(timed)
		
		if (amp<=0) then
			obj.setName( string.reverse( obj.getName() ) )
			return true
		end

		local degree = speed*timed
		if ( degree > amp ) then degree = amp end

		local r = obj.getRotation()

		if (dec) then
			r.y = r.y - degree
		else
			r.y = r.y + degree
		end

		obj.setRotation(r)

		amp = amp - degree

		return false
	end


	local r = obj_ani.new()

	r.framemove = framemove

	PlaySound('\\door.wav')

	return r
end

-- export ----

men_ani		=	{
	new	=	function( obj, dec )
				return _new( obj, dec )
			end,
}
