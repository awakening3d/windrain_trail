
local mt={} --metatable

local function new( matud )
	if (type(matud) ~= "userdata") then error("matrix expected") end
	
	local getElement =	function(row,col)
							return matud:get_element(row,col)
						end
	local setElement =	function(row,col,value)
							return matud:set_element(row,col,value)
						end
	local identity	=	function()
							matud:identity()
						end
	local inverse	=	function()
							matud:inverse()
						end
	local transpose	=	function()
							matud:transpose()
						end
	local isIdentity =	function()
							return matud:is_identity()
						end
	local translation =	function(x,y,z)
							if type(x) == 'table' then
								matud:translation( x.x, x.y, x.z )
							else
								matud:translation(x,y,z)
							end
						end
	local rotationx	=	function(angle)
							matud:rotationx(angle)
						end
	local rotationy	=	function(angle)
							matud:rotationy(angle)
						end
	local rotationz	=	function(angle)
							matud:rotationz(angle)
						end
	local rotationAxis =function(axis,angle)
							matud:rotation_axis(axis.x,axis.y,axis.z,angle)
						end
	local rotationYawPitchRoll = function(yaw,pitch,roll)
									matud:rotation_yaw_pitch_roll(yaw,pitch,roll)
								 end
	local rotationQuaternion = function( qua )
							matud:rotation_quaternion( qua.getUD() )
						end


	local scaling	=	function(x,y,z)
							matud:scaling(x,y,z)
						end

	local determinant = function()
							return matud:determinant()
						end
	local getPosition = function()
							return vec.new( matud:get_position() )
						end
	local getFront = function()
							return vec.new( matud:get_front() )
						end
	local getRight = function()
							return vec.new( matud:get_right() )
						end
	local getUp = function()
							return vec.new( matud:get_up() )
						end

	
	
	local clone = function()
							return new( _new_matrix_ud( matud:get_pointer() ) )
						end

	local r=_new_udhead_tb(matud)

	r.getElement=getElement
	r.setElement=setElement
	r.identity=identity
	r.inverse=inverse
	r.transpose=transpose
	r.isIdentity=isIdentity
	r.translation=translation
	r.rotationx=rotationx
	r.rotationy=rotationy
	r.rotationz=rotationz
	r.rotationAxis=rotationAxis
	r.rotationYawPitchRoll=rotationYawPitchRoll
	r.rotationQuaternion=rotationQuaternion
	r.scaling=scaling
	r.determinant=determinant

	r.getPosition = getPosition
	r.getFront = getFront
	r.getRight = getRight
	r.getUp = getUp

	r.clone=clone

	setmetatable(r, mt)
	return r;
end


local function mul(m1,m2)
	if (m2.x and m2.y and m2.z) then --m2 is a vector
		return vec.new( _matrix_transform_coord( m1.getUD(), m2.x, m2.y, m2.z ) )
	else
		return new( _new_matrix_ud( _matrix_multiply(m1.getUD(),m2.getUD()) ) )
	end
end


mt.__mul=mul


-- export ----
_new_matrix_tb=new


matrix	=	{
	new	=	function(handle) --handle里的内容是拷贝到matrix table中，并且handle可以为空。 
				local m = _new_matrix_tb( _new_matrix_ud(handle) )
				if type(handle) == 'table' and handle.getClassID and UD_QUATERNION==handle.getClassID() then
					m.rotationQuaternion( handle )
				end
				return m
			end,
	VectorTransformCoord =	function(m,v)
								return vec.new( _matrix_transform_coord( m.getUD(), v.x, v.y, v.z ) )
							end,
	VectorTransformNormal =	function(m,v)
								return vec.new( _matrix_transform_normal( m.getUD(), v.x, v.y, v.z ) )
							end,
	}
