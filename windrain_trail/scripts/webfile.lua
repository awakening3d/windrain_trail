
local function new( webfile )
	if (type(webfile) ~= "userdata") then error("webfile expected") end

	local seek	=	function(lOffset,nFrom)
						return webfile:seek(lOffset,nFrom)
					end

	local release = function()
						webfile:release()
					end

	local setDestFile = function(szdestfile)
							return webfile:set_dest_file(szdestfile)
						end

	local read		=	function( cachesize )
							return webfile:read( cachesize )
						end



	local r=_new_udhead_tb(webfile)

	r.seek=seek
	r.release=release
	r.setDestFile=setDestFile
	r.read=read

	return r
end

-- export ----
_new_webfile_tb=new



webfile	=	{
	new	=	function(handle)
				return _new_webfile_tb( _new_webfile_ud(handle) )
			end,
}
