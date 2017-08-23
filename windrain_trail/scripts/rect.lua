local mt={} --metatable

local function new(left,top,right,bottom)
	left = left or 0	-- equal to: if nil==left then left=0 end
	top = top or 0
	right = right or 0
	bottom = bottom or 0
	
	local r={ left=left, top=top, right=right, bottom=bottom }

	local function width()
		return r.right-r.left
	end

	local function height()
		return r.bottom-r.top
	end

	local function offset(x,y)
		r.left=r.left+x
		r.top=r.top+y
		r.right=r.right+x
		r.bottom=r.bottom+y
	end

	local function topLeft()
		return point.new(r.left,r.top)
	end

	local function bottomRight()
		return point.new(r.right,r.bottom)
	end

	local function centerPoint()
		return point.new( (r.left+r.right)/2, (r.top+r.bottom)/2 )
	end

	local function ptInRect(p)
		if (p.x>=r.left and p.x<r.right and p.y>=r.top and p.y<r.bottom) then
			return true
		else
			return false
		end
	end

	local function clone()
		return new(r.left,r.top,r.right,r.bottom)
	end

	r.width=width
	r.height=height
	r.offset=offset
	r.topLeft=topLeft
	r.bottomRight=bottomRight
	r.centerPoint=centerPoint
	r.ptInRect=ptInRect
	r.clone=clone

	setmetatable(r, mt)
	return r;
end

local function eq(r1,r2)
	return r1.left==r2.left and r1.top==r2.top and r1.right==r2.right and r1.bottom==r2.bottom
end


local P = {
	new	= new,
	eq  = eq,
}

mt.__eq=eq;		-- '=='

if _REQUIREDNAME == nil then
	rect = P
else
	_G[_REQUIREDNAME] = P
end

return P