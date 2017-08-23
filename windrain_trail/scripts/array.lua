--array.lua

local function new()
	local t={}
	
	local function size()
		return #t
	end

	local function clear()
		local len=#t
		for i=1,len do
			t[i]=nil
		end
	end

	local function add(e)
		table.insert(t,e)
		return true
	end

	local function insert(i,e)
		if (i<1) or (i>#t) then return false end
		table.insert(t, i, e)
		return true
	end

	local function remove(i)
		if (i<1) or (i>#t) then return false end
		table.remove(t, i)
		return true
	end

	local function get(i)
		if (i<1) or (i>#t) then return nil end
		return t[i]
	end

	local function set(i,e)
		if (i<1) or (i>#t) then return false end
		t[i]=e
		return true
	end

	local function find(e,i)
		i = i or 1
		if (i<1) or (i>#t) then return false end

		local num=#t
		for n=i,num do
			if (t[n]==e) then
				return n
			end
		end
	end

	local function sort(comp)
		if (comp) then
			table.sort(t,comp)
		else
			table.sort(t)
		end
	end
	
	local function append(a)
		local num=a.size()
		for i=1,num do
			add(a[i])
		end
	end

	t.size=size
	t.clear=clear

	t.add=add
	t.insert=insert
	t.remove=remove

	t.get=get
	t.set=set
	
	t.find=find
	t.sort=sort

	t.append=append

	return t;
end


local P = {
	new = new,
}


if _REQUIREDNAME == nil then
	array = P
else
	_G[_REQUIREDNAME] = P
end

return P