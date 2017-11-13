local mt={} --metatable

local function new(x,y,z)
	x = x or 0	-- equal to: if nil==x then x=0 end
	y = y or 0
	z = z or 0
	
	local v={ x=x, y=y, z=z }

	local function lengthsq()
		return v.x*v.x + v.y*v.y + v.z*v.z
	end

	local function length()
		return math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z )
	end

	local function normalize()
		local l=length()
		v.x=v.x/l
		v.y=v.y/l
		v.z=v.z/l
	end

	local function clone()
		return new(v.x,v.y,v.z)
	end

	v.lengthsq=lengthsq
	v.length=length
	v.normalize=normalize
	v.clone=clone

	setmetatable(v, mt)
	return v;
end

local function add(v1,v2)
	return new( v1.x + v2.x, v1.y + v2.y, v1.z + v2.z )
end

local function sub(v1,v2)
	return new( v1.x - v2.x, v1.y - v2.y, v1.z - v2.z )
end

local function mul(v,n)
	return new( v.x*n, v.y*n, v.z*n )
end

local function div(v,n)
	return new( v.x/n, v.y/n, v.z/n )
end

local function eq(v1,v2)
	return v1.x==v2.x and v1.y==v2.y and v1.z==v2.z
end

local function unm(v)
	return new(-v.x,-v.y,-v.z)
end

local function index(v,i)
	if (0==i) then return v.x
	elseif (1==i) then return v.y
	elseif (2==i) then return v.z end
end

local function newindex(v,i,n)
	if (0==i) then v.x=n
	elseif (1==i) then v.y=n
	elseif (2==i) then v.z=n
	else error("out of index: "..i) end
end

local function dot(v1,v2)
	return v1.x*v2.x + v1.y * v2.y + v1.z*v2.z
end

local function cross(v1,v2)
	return new( v1.y * v2.z - v1.z * v2.y,
			v1.z * v2.x - v1.x * v2.z,
			v1.x * v2.y - v1.y * v2.x )
end



local P = {
	new = new,
	add = add,
	sub = sub,
	mul = mul,
	div = div,
	eq  = eq,
	unm	= unm,
	dot = dot,
	cross = cross,
}

mt.__add=add;	-- '+'
mt.__sub=sub;	-- '-'
mt.__mul=mul;	-- '*'
mt.__div=div;	-- '/'
mt.__eq=eq;		-- '=='
mt.__unm=unm;	-- '-'
mt.__index=index;	-- 'v[i]'
mt.__newindex=newindex;	-- 'v[i]=n'

if _REQUIREDNAME == nil then
	vec = P
else
	_G[_REQUIREDNAME] = P
end

return P