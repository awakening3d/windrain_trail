--local mt={} --metatable

local function new(x,y,z,w)
	x = x or 0	-- equal to: if nil==x then x=0 end
	y = y or 0
	z = z or 0
	w = w or 0
	
	local v={ x=x, y=y, z=z, w=w }

	local function clone()
		return new(v.x,v.y,v.z,v.w)
	end

	v.clone=clone

--	setmetatable(v, mt)
	return v;
end


local P = {
	new = new,
}


if _REQUIREDNAME == nil then
	vec4 = P
else
	_G[_REQUIREDNAME] = P
end

return P