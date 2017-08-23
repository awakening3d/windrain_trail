require 'weapon'
require 'goods'

--- Ê¹ÓÃ½£ ---
goodsUseFunction[ goodsID.sword ] = function()
	if IsPlayingShot() then return end
	if ( pplayer.getWeapon() and goodsID.sword == pplayer.getWeapon().getType() ) then return end

	pplayer.setWeapon( sword.new() )
	goodsConsume(goodsID.sword)

	if math.random()>0.5 then
		PlaySound('\\throw.wav',-2000)
	else
		PlaySound('\\throw1.wav',-2000)
	end
end



local function _new()
	local w = weapon.new()

	w.getType = function()
		return goodsID.sword
	end

	local mov = scene.createMobile('\\sword.tri')
	if mov then
		--mov.bumpEnable( true )
		mov.noShadow( true )
		--mov.setMaterial( mat_gun )
		mov.setTexture(texturelist.addTexture('\\Metal2.bmp'))
		mov.setStyle( orDWORD( mov.getStyle(), MOVS_NOCLIP ) )
	end

	w.roty = 0;

	local _frameMove=w.frameMove
	w.frameMove	=	function(timed)
						
						if mov then
							local ofs = math.sin(GetAppTime())*.1
							local matofs=matrix.new()
							matofs.translation(3,-3+ofs,0)
							local matscale=matrix.new()
							matscale.scaling(.1,.1,.1)
							local matrotate = matrix.new()
							matrotate.rotationx(-20-ofs)
							local matroty = matrix.new()
							matroty.rotationy( w.roty )
							mov.setMatrix(matscale*matrotate*matroty*matofs*camera.getInvViewMatrix())
						end

						if w.getTimeFromLastAttack()<3 then
						end

						return _frameMove(timed)
					end

	local _attack=w.attack
	w.attack	=	function()
					if not _attack() then return false end
					if math.random()>0.5 then
						PlaySound('\\throw.wav',-2000)
					else
						PlaySound('\\throw1.wav',-2000)
					end

					sword_ani.new( w )

					--w.frameMove(0)

				end


	w.takeoff = function()
		if mov then
			scene.deleteMobile( mov )
			mov = nil
		end
		goodsPick(goodsID.sword, true, true)
	end


	w.setAttackSpaceTime(1)
	return w
end

-- export ----
sword	=	{
	new	= _new
}
