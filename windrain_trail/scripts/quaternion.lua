
local mt={} --metatable

local function new( quaud )
	if (type(quaud) ~= "userdata") then error("quaternion expected") end
	
	local getElement =	function()
							return quaud:get_element()
						end
	local setElement =	function(x,y,z,w)
							return quaud:set_element(x,y,z,w)
						end
	local identity	=	function()
							quaud:identity()
						end
	local inverse	=	function()
							quaud:inverse()
						end
	local isIdentity =	function()
							return quaud:is_identity()
						end
	local length =		function()
							return quaud:length()
						end
	local lengthsq =	function()
							return quaud:lengthsq()
						end
	local normalize =	function()
							return quaud:normalize()
						end

	

	local rotationAxis =function(axis,angle)
							quaud:rotation_axis(axis.x,axis.y,axis.z,angle)
						end
	local rotationYawPitchRoll = function(yaw,pitch,roll)
									quaud:rotation_yaw_pitch_roll(yaw,pitch,roll)
								 end
	local rotationMatrix = function( m )
		quaud:rotation_matrix( m.getUD() )
	end

	local toAxisAngle = function()
		local x,y,z,angle = quaud:to_axis_angle()
		return vec.new(x,y,z), angle
	end

	local toYawPitchRoll = function()
		return quaud:to_yaw_pitch_roll()
	end

	local clone = function()
							return new( _new_quaternion_ud( quaud:get_pointer() ) )
						end

	local r=_new_udhead_tb(quaud)

	r.getElement=getElement
	r.setElement=setElement
	r.identity=identity
	r.inverse=inverse
	r.isIdentity=isIdentity
	r.length=length
	r.lengthsq=lengthsq
	r.normalize=normalize
	r.rotationAxis=rotationAxis
	r.rotationYawPitchRoll=rotationYawPitchRoll
	r.rotationMatrix=rotationMatrix
	r.toAxisAngle=toAxisAngle
	r.toYawPitchRoll=toYawPitchRoll

	r.clone=clone

	setmetatable(r, mt)
	return r;
end


local function add(v1,v2)
	local x,y,z,w = v1.getElement()
	local x2,y2,z2,w2 = v2.getElement()
	local r = new( _new_quaternion_ud() )
	r.setElement( x+x2, y+y2, z+z2, w+w2 )
	return r
end

local function sub(v1,v2)
	local x,y,z,w = v1.getElement()
	local x2,y2,z2,w2 = v2.getElement()
	local r = new( _new_quaternion_ud() )
	r.setElement( x-x2, y-y2, z-z2, w-w2 )
	return r
end

local function mul(m1,m2)
	if type(m2) == 'number' then -- m2 is a number
		local x,y,z,w = m1.getElement()
		local q = new( _new_quaternion_ud() )
		q.setElement( x*m2, y*m2, z*m2, w*m2 )
		return q
	elseif m2.getUD then -- m2 is quaternion
		return new( _new_quaternion_ud( _quaternion_multiply(m1.getUD(),m2.getUD()) ) )
	else --m2 is a vector
		return vec.new( _quaternion_transform_normal( m1.getUD(), m2.x, m2.y, m2.z ) )
	end
end

local function div(v,n)
	local x,y,z,w = v.getElement()
	local r = new( _new_quaternion_ud() )
	r.setElement( x/n, y/n, z/n, w/n )
	return r
end


local function eq(v1,v2)
	local x,y,z,w = v1.getElement()
	local x2,y2,z2,w2 = v2.getElement()
	return x==x2 and y==y2 and z==z2 and w==w2
end

local function unm(v)
	local x,y,z,w = v.getElement()
	local r = new( _new_quaternion_ud() )
	r.setElement(-x,-y,-z,w)
	return r
end

local function index(v,i)
	local x,y,z,w = v.getElement()
	if (0==i or 'x'==i) then return x
	elseif (1==i or 'y'==i) then return y
	elseif (2==i or 'z'==i) then return z
	elseif (3==i or 'w'==i) then return w end
end

local function newindex(v,i,n)
	local x,y,z,w = v.getElement()
	if (0==i or 'x'==i) then x=n
	elseif (1==i or 'y'==i) then y=n
	elseif (2==i or 'z'==i) then z=n
	elseif (3==i or 'w'==i) then w=n
	else error("out of index: "..i) end
	v.setElement(x,y,z,w)
end


mt.__add=add;	-- '+'
mt.__sub=sub;	-- '-'
mt.__mul=mul;	-- '*'
mt.__div=div;	-- '/'
mt.__eq=eq;		-- '=='
mt.__unm=unm;	-- '-'
mt.__index=index;	-- 'v[i]'
mt.__newindex=newindex;	-- 'v[i]=n'


-- export ----
_new_quaternion_tb=new


quaternion	=	{
	new	=	function(handle, y, z, w) --handle里的内容是拷贝到quaternion table中，并且handle可以为空。 
				local q = _new_quaternion_tb( _new_quaternion_ud(handle) )

				if type(handle) == 'table' and handle.getClassID and UD_MATRIX==handle.getClassID() then
					q.rotationMatrix( handle )
				elseif handle and y and z and w then
					q.setElement( handle, y, z, w )
				end

				return q
			end,

	dot	=	function( q1, q2 )
				return _quaternion_dot( q1.getUD(), q2.getUD() )
			end,

	VectorTransformNormal =	function(m,v)
								return vec.new( _quaternion_transform_normal( m.getUD(), v.x, v.y, v.z ) )
							end,
	}
