--temporary object

require('gameutil')

local tempobjlist={}

local function _new(t)

	local fLifeTime=5;
	
	local getLifeTime	=	function() return fLifeTime; end
	local setLifeTime	=	function(lt) fLifeTime=lt; end
--	local isLifeTimeOut	=	function()	return fLifeTime<=0; end	--是否已超过生存时间
	local frameMove	=	function(timed)
							fLifeTime=fLifeTime-timed
							if (fLifeTime<=0) then --超过生存时间
								return true;
							end
							return false;
						end
	local deleteThis	=	function()
							end
	

	if (type(t)~='table') then t={} end
	t.getLifeTime=getLifeTime
	t.setLifeTime=setLifeTime
	t.frameMove=frameMove
	t.deleteThis=deleteThis

	add_to_list(tempobjlist,t)

	return t
end





-- export ----
tempobj	=	{
	new	= _new
}


function frameMoveTempObjs(timed)

	for _,b in ipairs(tempobjlist) do
	--for _,b in pairs(tempobjlist) do
		if (b) then
			if (b.frameMove(timed)) then
				remove_from_list(tempobjlist,b)
				b.deleteThis()
			end
		end
	end	

end

function clearTempObjs()
	for _,b in ipairs(tempobjlist) do
		if (b) then
			remove_from_list(tempobjlist,b)
			b.deleteThis()
		end
	end
	tempobjlist={}
end