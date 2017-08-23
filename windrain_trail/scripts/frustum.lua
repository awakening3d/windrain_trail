
local function new( frustum )
	if (type(frustum) ~= "userdata") then error("frustum expected") end
	
	local calc		=	function(matView,matInvView,matProj,nVPWidth,nVPHeight,rt)
							if (rt) then
								frustum:calc(matView.getUD(),matInvView.getUD(),matProj.getUD(),nVPWidth,nVPHeight,rt.left,rt.top,rt.right,rt.bottom)
							else
								frustum:calc(matView.getUD(),matInvView.getUD(),matProj.getUD(),nVPWidth,nVPHeight)
							end
						end
	local isBoxOutView	=	function(box)
								return frustum:is_box_out_view(box.getUD())
							end
	local isBoxInView	=	function(box)
								return frustum:is_box_in_view(box.getUD())
							end
	local isSphereOutView =	function(bs)
								return frustum:is_sphere_out_view(bs.getUD())
							end
	local isSphereInView =	function(bs)
								return frustum:is_sphere_in_view(bs.getUD())
							end
	local isPointOutView =	function(v)
								return frustum:is_point_out_view(v.x,v.y,v.z)
							end

	local r=_new_udhead_tb(frustum)

	r.calc=calc
	r.isBoxOutView=isBoxOutView
	r.isBoxInView=isBoxInView
	r.isSphereOutView=isSphereOutView
	r.isSphereInView=isSphereInView
	r.isPointOutView=isPointOutView

	return r

end

-- export ----
_new_frustum_tb=new



frustum	=	{
	new	=	function(handle) --handle里的内容是拷贝到frustum table中，并且handle可以为空。 
				return _new_frustum_tb( _new_frustum_ud(handle) )
			end,
}
