--Sun--

local function _new( MaterialList )	

	local m_fIntensity=30;

	local m_cColor=color.new(1,1,1,1);
	local m_vDir=vec.new(-0.0471744, 0.799484, 0.598423);
	local m_vNormalMapDir=nil;

	local GetDirection = function()
						return m_vDir.clone();
						end
	local GetColor = function()
						return m_cColor.clone();
						end
	local GetIntensity = function()
						return m_fIntensity
						end

	local GetColorAndIntensity = function()
										local col=GetColor()
										return vec4.new(col.r,col.g,col.b,GetIntensity())
									end

	local UpdateMaterial = function()
						for k,v in pairs(MaterialList) do
							v.setEffectVector('vSunColor',GetColorAndIntensity())
							local dir=GetDirection();
							v.setEffectVector('vSunDir',vec4.new(dir.x,dir.y,dir.z,1));

							if (m_vNormalMapDir) then
								dir=-m_vNormalMapDir;
							end

							local dd=vec.new(-dir.x,dir.z,dir.y);

							v.setEffectVector('vSunDirNM',vec4.new(dd.x,dd.y,dd.z,math.abs(dd.y)));

							dd = dd*0.5;
							dd = dd + vec.new(0.5,0.5,0.5);
							v.setEffectDword('dwSunDir',RGBAtoDWORD(dd.x,dd.y,dd.z,1));
						end
					  end

	local SetDirection = function(vDir,vNormalMapDir)
						m_vDir=vDir.clone();

						if (vNormalMapDir) then
							m_vNormalMapDir=vNormalMapDir.clone();
						else
							m_vNormalMapDir=nil
						end

						UpdateMaterial();
						end

	local SetColor = function(col)
						m_cColor=col.clone();
						UpdateMaterial();
						end

	local SetIntensity = function(fIntensity)
								m_fIntensity = fIntensity;
								UpdateMaterial();
							end


	local sun={};

	sun.getDirection=GetDirection;
	sun.getColor=GetColor;
	sun.getIntensity=GetIntensity;

	sun.setDirection=SetDirection;
	sun.setColor=SetColor;
	sun.setIntensity=SetIntensity;

	return sun;
end

-- export ----
Sun	=	{
	new	= _new
}