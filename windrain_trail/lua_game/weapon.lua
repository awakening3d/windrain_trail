require('gameutil')

local function _new()
	local fAttackSpaceTime=0.3 --攻击间隔时间
	local timedFromLastAttack=999999 --上一次攻击后到现在的时间

	local getType = function()	-- 子类必须覆盖这个函数，返回武器类型
		print('weapon.getType: error weapon class')
	end

	local takeoff = function()
		print('weapon.takeoff: error weapon class') -- 子类必须覆盖这个函数，卸载武器
	end

	local frameMove	=	function(timed)
							timedFromLastAttack=timedFromLastAttack+timed; --上一次攻击后到现在的时间
						end

	local attack		=	function()
							if (timedFromLastAttack<fAttackSpaceTime) then return false; end --两次攻击时间间隔太短
							timedFromLastAttack=0;
							return true
						end

	local getAttackSpaceTime =	function()
									return fAttackSpaceTime
								end
	local setAttackSpaceTime =	function( stime )
									fAttackSpaceTime=stime
								end

	local getTimeFromLastAttack = function() return timedFromLastAttack end


	return {
				getType = getType,
				frameMove=frameMove,
				attack=attack,
				getAttackSpaceTime=getAttackSpaceTime,
				setAttackSpaceTime=setAttackSpaceTime,
				getTimeFromLastAttack=getTimeFromLastAttack,

			}
end

-- export ----
weapon	=	{
	new	= _new
}
