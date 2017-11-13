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



local function getSpheremapMaterial()
	local pos,mater = scene.getMaterialsHead()
	while pos do
		mater,pos = scene.getMaterialsNext(pos)
		if mater.getName()=='spheremap' then return mater end
	end
	-- no found
	mater = scene.createMaterial('spheremap')
	mater.setD3DEffect('\\SpheremapDiffuse.fx')
	return mater
end

local function createSwordMobiles()
	local swordmov = scene.createMobile('\\sword.tri')
	if swordmov then
		swordmov.noShadow( true )
		swordmov.setTexture(texturelist.addTexture('\\Metal2.bmp'))
		swordmov.setStyle( orDWORD( swordmov.getStyle(), MOVS_NOCLIP ) )
		-- handle
		local hand = scene.createMobile('\\swordhand.tri')
		hand.noShadow( true )
		hand.setTexture(texturelist.addTexture('\\Metal.bmp'))
		hand.setMaterial( getSpheremapMaterial() )
		hand.setStyle( orDWORD( hand.getStyle(), MOVS_NOCLIP ) )
		hand.setParent( swordmov )
		local hand1 = scene.createMobile('\\swordhand1.tri')
		hand1.noShadow( true )
		hand1.setTexture(texturelist.addTexture('\\wood5.dds'))
		hand1.setStyle( orDWORD( hand1.getStyle(), MOVS_NOCLIP ) )
		hand1.setParent( swordmov )

		return swordmov, hand, hand1
	end
end



local function _new()
	local w = weapon.new()

	w.getType = function()
		return goodsID.sword
	end

	local mov, hand, hand1 = createSwordMobiles()

	w.roty = 0;

	local _frameMove=w.frameMove
	w.frameMove	=	function(timed)
						
						if mov then
							if g_config.vr then
								local mat = matrix.new()
								mat.translation(-ControllerA.getFront()*15)
								mov.setMatrix( ControllerA.getMatrix() * mat )
							else
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
			scene.deleteMobile(hand)
			scene.deleteMobile(hand1)
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
	new	= _new,
	createSwordMobiles = createSwordMobiles
}
