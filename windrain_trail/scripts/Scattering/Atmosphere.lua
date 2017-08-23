--Atmosphere--

-- see <<Rendering Outdoor Light Scattering in Real Time>>
-- by Naty Hoffman (Westwood Studios) & Arcot Preetham (ATI Research)

local function _new( MaterialList )	

	local m_fHGg=0.8;		-- g value in Henyey Greenstein approximation function.

	-- The final color of an object in atmosphere is sum of inscattering term and extinction term. 
	local m_fInscatteringMultiplier=0.3;	-- Multiply inscattering term with this factor.
	local m_fExtinctionMultiplier=1.0;		-- Multiply extinction term with this factor.
	local m_fInscatteringAdd=0;	-- Add inscattering term with this factor.
	local m_fExtinctionAdd=0;	-- Add extinction term with this factor.


	local m_fBetaRayMultiplier=0.2;			-- Multiply Rayleigh scattering coefficient with this factor
	local m_fBetaMieMultiplier=0.01;			-- Multiply  Mie scattering coefficient with this factor

	local m_vBetaRay=vec.new();				-- Rayleigh scattering coeff
	local m_vBetaDashRay=vec.new();			-- Rayleigh Angular scattering coeff without phase term.
	local m_vBetaMie=vec.new();				-- Mie scattering coeff
	local m_vBetaDashMie=vec.new();			-- Mie Angular scattering coeff without phase term.

	local m_fSunny=0.5;
	local m_fDistanceScale=1.0;
	local m_fSkyDistanceAdjust=1.0;


	local CalculateScatteringConstants = function()
		local pi = 3.14159265358;
		local n = 1.003; -- refractive index
		local N = 2.545e25;
		local pn = 0.035;

		local fLambda = { 1/650e-9, 1/570e-9, 1/475e-9};
		local fLambda2={};
		local fLambda4={};
		for i=1,3 do
			fLambda2[i] = fLambda[i]*fLambda[i];
			fLambda4[i] = fLambda2[i]*fLambda2[i];
		end

		local vLambda2 = vec.new(fLambda2[1], fLambda2[2], fLambda2[3]);
		local vLambda4 = vec.new(fLambda4[1], fLambda4[2], fLambda4[3]);

		-- Rayleigh scattering constants.
		local fTemp = pi*pi*(n*n-1)*(n*n-1)*(6+3*pn)/(6-7*pn)/N;
		local fBeta = 8*fTemp*pi/3;
		m_vBetaRay = vLambda4 * fBeta;

		local fBetaDash = fTemp/2;
		m_vBetaDashRay = vLambda4 * fBetaDash;

		-- Mie scattering constants.
		local T = 2.0;
		local c = (6.544*T - 6.51)*1e-17; -- from page 57 of my thesis.
		local fTemp2 = 0.434*c*(2*pi)*(2*pi)*0.5;
		m_vBetaDashMie = vLambda2 * fTemp2;

		local K = {0.685, 0.679, 0.670}; -- from pg 64 of my thesis.
		local fTemp3 = 0.434*c*pi*(2*pi)*(2*pi);
		local vBetaMieTemp = vec.new( K[1]*fLambda2[1], K[2]*fLambda2[2], K[3]*fLambda2[3] );
		m_vBetaMie = vBetaMieTemp * fTemp3;
	end


	local GetBetaRayleigh = function()
		return m_vBetaRay.clone();
	end

	local GetBetaDashRayleigh = function()
		return m_vBetaDashRay.clone();
	end

	local GetBetaMie = function()
		return m_vBetaMie.clone();
	end

	local GetBetaDashMie = function()
		return m_vBetaDashMie.clone();
	end


	local UpdateMaterial = function()
		local fRayMult = m_fBetaRayMultiplier;
		local fMieMult = m_fBetaMieMultiplier;

		-- Rayleigh
		local vBetaR = GetBetaRayleigh();
		vBetaR = vBetaR * fRayMult;

		local vBetaDashR = GetBetaDashRayleigh();
		vBetaDashR = vBetaDashR * fRayMult;

		-- Mie
		local vBetaM = GetBetaMie();
		vBetaM = vBetaM * fMieMult;

		local vBetaDashM = GetBetaDashMie();
		vBetaDashM = vBetaDashM * fMieMult;

		-- Rayleigh + Mie (optimization)
		local vBetaRM = vBetaR + vBetaM;

		local vOneOverBetaRM=vec.new()
		vOneOverBetaRM[0] = 1.0/vBetaRM[0];
		vOneOverBetaRM[1] = 1.0/vBetaRM[1];
		vOneOverBetaRM[2] = 1.0/vBetaRM[2];

		-- Henyey Greenstein's G value.
		local g = m_fHGg;
		local vG = vec.new(1-g*g, 1+g, 2*g);

		-- constants.
		--float l2e = 1/log(2);
		--D3DXVECTOR4 vNumbers(1.0, l2e, 0.5, 0);
		--g_Device->SetVertexShaderConstant( CV_CONSTANTS, &vNumbers, 1 );

		-- each term (extinction, inscattering multiplier)
		local fExt = m_fExtinctionMultiplier;
		local fIns = m_fInscatteringMultiplier;
		local vTermMultipliers = vec4.new(fExt,fIns,m_fExtinctionAdd,m_fInscatteringAdd);

		for k,v in pairs(MaterialList) do
			v.setEffectVector('vBetaDash1',vec4.new(vBetaDashR.x,vBetaDashR.y,vBetaDashR.z,1))
			v.setEffectVector('vBetaDash2',vec4.new(vBetaDashM.x,vBetaDashM.y,vBetaDashM.z,1))
			v.setEffectVector('vBeta1Beta2',vec4.new(vBetaRM.x,vBetaRM.y,vBetaRM.z,1))
			v.setEffectVector('vOneOverBeta',vec4.new(vOneOverBetaRM.x,vOneOverBetaRM.y,vOneOverBetaRM.z,1))
			v.setEffectVector('vHG',vec4.new(vG.x,vG.y,vG.z,1))
			v.setEffectVector('vTermMulti',vTermMultipliers)
			v.setEffectVector('vSunny', vec4.new(m_fSunny*0.5,m_fDistanceScale,m_fSkyDistanceAdjust,1))
		end
	end

	
	local GetHG = function() return m_fHGg end
	local GetInscatteringMultiplier = function() return m_fInscatteringMultiplier, m_fInscatteringAdd end
	local GetExtinctionMultiplier = function() return m_fExtinctionMultiplier, m_fExtinctionAdd end
	local GetRayMultiplier = function() return m_fBetaRayMultiplier end
	local GetMieMultiplier = function() return m_fBetaMieMultiplier end
	local GetSunny = function() return m_fSunny end
	local GetDistanceScale = function() return m_fDistanceScale end
	local GetSkyDistanceAdjust = function() return m_fSkyDistanceAdjust end

	local SetInscatteringMultiplier = function(fM,fAdd)
		m_fInscatteringMultiplier=fM;
		m_fInscatteringAdd = fAdd or m_fInscatteringAdd;
		UpdateMaterial();
	end

	local SetExtinctionMultiplier = function(fM,fAdd)
		m_fExtinctionMultiplier=fM;
		m_fExtinctionAdd = fAdd or m_fExtinctionAdd;
		UpdateMaterial();
	end

	local SetRayMultiplier = function(fM)
		m_fBetaRayMultiplier=fM;
		UpdateMaterial();
	end

	local SetMieMultiplier = function(fM)
		m_fBetaMieMultiplier=fM;
		UpdateMaterial();
	end

	local SetHG = function(hg)
		m_fHGg=hg;
		UpdateMaterial();
	end

	local SetSunny = function(sunny)
		m_fSunny=sunny;
		UpdateMaterial();
	end

	local SetDistanceScale = function( fscale )
		m_fDistanceScale=fscale;
		UpdateMaterial();
	end

	local SetSkyDistanceAdjust = function ( fadjust )
		m_fSkyDistanceAdjust=fadjust;
		UpdateMaterial();
	end

	CalculateScatteringConstants();

	local atmo={};

	atmo.getHG=GetHG;
	atmo.getInscattering=GetInscatteringMultiplier;
	atmo.getExtinction=GetExtinctionMultiplier;
	atmo.getRay=GetRayMultiplier;
	atmo.getMie=GetMieMultiplier;
	atmo.getSunny=GetSunny;
	atmo.getDistanceScale=GetDistanceScale;
	atmo.getSkyDistanceAdjust=GetSkyDistanceAdjust;

	atmo.setHG=SetHG;
	atmo.setInscattering=SetInscatteringMultiplier;
	atmo.setExtinction=SetExtinctionMultiplier;
	atmo.setRay=SetRayMultiplier;
	atmo.setMie=SetMieMultiplier;
	atmo.setSunny=SetSunny;
	atmo.setDistanceScale=SetDistanceScale;
	atmo.setSkyDistanceAdjust=SetSkyDistanceAdjust;


	return atmo;
end

-- export ----
Atmosphere	=	{
	new	= _new
}