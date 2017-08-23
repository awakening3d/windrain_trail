
local function new( websession )
	if (type(websession) ~= "userdata") then error("websession expected") end

	local openURL	=	function(url,context)
							local filehandle = websession:open_url(url,context);
							if NULL==filehandle then return end
							return webfile.new(filehandle)
						end

	local release	=	function()
							websession:release()
						end

	local r=_new_udhead_tb(websession)

	r.openURL=openURL
	r.release=release

	return r
end

-- export ----
_new_websession_tb=new



websession	=	{
	new	=	function()
				return _new_websession_tb( _new_websession_ud() )
			end
}
