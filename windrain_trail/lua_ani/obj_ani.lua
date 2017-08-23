
local g_anilist = {}

local function _new()

	local r = {}

	return r
end

-- export ----

obj_ani		=	{
	new	=	function()
				local t = _new()
				table.insert(g_anilist, t)
				return t
			end,
}




function ani_framemove(timed)

	for k,v in pairs(g_anilist) do
		if (v) then
			if ( v.framemove(timed) ) then
				g_anilist[k] = nil
			end
		end
	end

end