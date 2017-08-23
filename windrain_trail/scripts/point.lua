local mt={} --metatable

local function new(x,y)
	x = x or 0	-- equal to: if nil==x then x=0 end
	y = y or 0
	
	local p={ x=x, y=y }

	local function lengthsq()
		return p.x*p.x + p.y*p.y
	end

	local function length()
		return math.sqrt( p.x*p.x + p.y*p.y )
	end

	local function normalize()
		local l=length()
		p.x=p.x/l
		p.y=p.y/l
	end

	local function clone()
		return new(p.x,p.y)
	end

	p.lengthsq=lengthsq
	p.length=length
	p.normalize=normalize
	p.clone=clone

	setmetatable(p, mt)
	return p;
end

local function add(p1,p2)
	return new( p1.x + p2.x, p1.y + p2.y )
end

local function sub(p1,p2)
	return new( p1.x - p2.x, p1.y - p2.y )
end

local function mul(p,n)
	return new( p.x*n, p.y*n )
end

local function div(p,n)
	return new( p.x/n, p.y/n )
end

local function eq(p1,p2)
	return p1.x==p2.x and p1.y==p2.y
end

local function unm(p)
	return new(-p.x,-p.y)
end

local function index(p,i)
	if (0==i) then return p.x
	elseif (1==i) then return p.y
	else error("out of index") end
end

local function newindex(p,i,n)
	if (0==i) then p.x=n
	elseif (1==i) then p.y=n
	else error("out of index") end
end

local function dot(p1,p2)
	return p1.x*p2.x + p1.y * p2.y
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
}

mt.__add=add;	-- '+'
mt.__sub=sub;	-- '-'
mt.__mul=mul;	-- '*'
mt.__div=div;	-- '/'
mt.__eq=eq;		-- '=='
mt.__unm=unm;	-- '-'
mt.__index=index;	-- 'p[i]'
mt.__newindex=newindex;	-- 'p[i]=n'

if _REQUIREDNAME == nil then
	point = P
else
	_G[_REQUIREDNAME] = P
end

return P