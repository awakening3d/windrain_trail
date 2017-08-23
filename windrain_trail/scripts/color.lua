local mt={} --metatable

local function new(r,g,b,a)
	r = r or 0	-- equal to: if nil==r then r=0 end
	g = g or 0
	b = b or 0
	a = a or 0
	local col={ r=r, g=g, b=b, a=a }

	local function clone()
		return new(col.r,col.g,col.b,col.a)
	end

	col.clone=clone

	setmetatable(col, mt)
	return col;
end

local function add(c1,c2)
	return new( c1.r + c2.r, c1.g + c2.g, c1.b + c2.b, c1.a + c2.a )
end

local function sub(c1,c2)
	return new( c1.r - c2.r, c1.g - c2.g, c1.b - c2.b, c1.a - c2.a )
end

local function mul(c,n)
	return new( c.r*n, c.g*n, c.b*n, c.a*n )
end

local function div(c,n)
	return new( c.r/n, c.g/n, c.b/n, c.a/n )
end

local function eq(c1,c2)
	return c1.r==c2.r and c1.g==c2.g and c1.b==c2.b and c1.a==c2.a
end


local P = {
	new = new,
	add = add,
	sub = sub,
	mul = mul,
	div = div,
	eq  = eq,
}

mt.__add=add;
mt.__sub=sub;
mt.__mul=mul;
mt.__div=div;
mt.__eq=eq;


if _REQUIREDNAME == nil then
	color = P
else
	_G[_REQUIREDNAME] = P
end

return P