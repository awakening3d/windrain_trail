
-- public class --
local function new( draw )
	if (type(draw) ~= "userdata") then error("draw expected") end

	local setcolor =	function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							return draw:set_color(dwcolor)
						end
	local setbkcolor =	function(dwcolor)
							if (type(dwcolor) ~= "userdata") then error("dwcolor expected") end
							return draw:set_bk_color(dwcolor)
						end
	local gradingmode	=	function(grading)
								return draw:grading_mode(grading)
							end
	local setBlendMode =	function(src,dest)
								return draw:set_blend_mode(src,dest)
							end

	local getRenderTarget = function(index)
								local rt=draw:get_rendertarget(index)
								if NULL==rt then return nil end
								return _new_d3dsurface_tb( _new_d3dsurface_ud( rt ) )
							end

	local setRenderTarget = function(surf,index)
								draw:flush()
								return draw:set_rendertarget(surf.getUD(),index)
							end

	local getTextExtent	=	function(text)
								return draw:get_text_extent_2d(text)
							end

	local getFont		=	function()
								local handle=draw:get_font()
								if (NULL==handle) then return nil end
								return FontFromHandle(handle)
							end
	local setFont		=	function(mfont)
							if (nil==mfont) then return draw:set_font(_new_font_ud(nil)) end
							if (type(mfont) ~= "table") then error("font expected") end
							draw:set_font(mfont.getUD())
						end

	local createFont =	function(height, fontname, texsize)
								local handle=draw:create_font(height, fontname, texsize)
								if (nil==handle) then return nil end -- create failed
								return FontFromHandle(handle)
							end
	local createBMFont =	function( fontDescFile )
								local handle=draw:create_bmfont( fontDescFile )
								if (nil==handle) then return nil end -- create failed
								return FontFromHandle(handle)
							end
	local deleteFont =	function(font)
								local bret=draw:delete_font(font.getPointer())
								if bret then
									_InvalidateUserdata(font.getUD())
								end
								return bret
							end
	local getFontsHead =function()
								return draw:get_fonts_head()
							end
	local getFontsNext =function(pos)
								local pfont,pos=draw:get_fonts_next(pos)
								return FontFromHandle(pfont),pos
							end


	local r=_new_udhead_tb(draw)

	r.setcolor=setcolor
	r.setbkcolor=setbkcolor
	r.gradingmode=gradingmode
	r.setBlendMode=setBlendMode
	r.getRenderTarget=getRenderTarget
	r.setRenderTarget=setRenderTarget
	r.getTextExtent=getTextExtent
	r.getFont = getFont
	r.setFont = setFont
	r.createFont = createFont
	r.createBMFont = createBMFont
	r.deleteFont = deleteFont
	r.getFontsHead = getFontsHead
	r.getFontsNext = getFontsNext

	r.BLEND_ZERO				= toDWORD('00000001')
	r.BLEND_ONE                	= toDWORD('00000002')
    r.BLEND_SRCCOLOR			= toDWORD('00000003')
    r.BLEND_INVSRCCOLOR			= toDWORD('00000004')
    r.BLEND_SRCALPHA			= toDWORD('00000005')
    r.BLEND_INVSRCALPHA			= toDWORD('00000006')
    r.BLEND_DESTALPHA			= toDWORD('00000007')
    r.BLEND_INVDESTALPHA		= toDWORD('00000008')
    r.BLEND_DESTCOLOR			= toDWORD('00000009')
    r.BLEND_INVDESTCOLOR		= toDWORD('0000000a')
    r.BLEND_SRCALPHASAT			= toDWORD('0000000b')

	return r
end

-- draw2d class --
local function new2d( draw )
	if (type(draw) ~= "userdata") then error("draw expected") end
	
	local _point	=	function(x,y)
							return draw:point_2d(x,y)
						end
	local moveto	=	function(x,y)
							return point.new(draw:move_to_2d(x,y))
						end
	local lineto	=	function(x,y)
							return draw:line_to_2d(x,y)
						end
	local _triangle =		function(p1,p2,p3)
								return draw:triangle_2d(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y)
							end
	local filltriangle =	function(p1,p2,p3)
								return draw:filltriangle_2d(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y)
							end
	local _circle	=	function(center,radius,segments, seg)
							return draw:circle_2d(center.x,center.y, radius, segments, seg)
						end
	local fillcircle=	function(center,radius,segments, seg)
							return draw:fillcircle_2d(center.x,center.y, radius, segments, seg)
						end
	local _rect		=	function(r)
							return draw:rect_2d(r.left,r.top,r.right,r.bottom)
						end
	local fillrect	=	function(r)
							return draw:fillrect_2d(r.left,r.top,r.right,r.bottom)
						end
	local textout	=	function(x,y,text, widthscale, heightscale)
							return draw:textout_2d(x,y,text, widthscale, heightscale)
						end
	local blt	=		function(x,y,tex)
							return draw:blt_2d(x,y,tex)
						end
	local stretchblt =	function(rect,tex)
							return draw:stretchblt_2d(rect.left,rect.top,rect.right,rect.bottom,tex)
						end

	local d=new(draw)
	d.point=_point
	d.moveto=moveto
	d.lineto=lineto
	d.triangle=_triangle
	d.filltriangle=filltriangle
	d.circle=_circle
	d.fillcircle=fillcircle
	d.rect=_rect
	d.fillrect=fillrect
	d.textout=textout
	d.blt=blt
	d.stretchblt=stretchblt
	return d
end


-- draw3d class --
local function new3d( draw )
	if (type(draw) ~= "userdata") then error("draw expected") end
	
	local _point		=	function(v)
							return draw:point_3d(v.x,v.y,v.z)
						end
	local moveto	=	function(v)
							return vec.new(draw:move_to_3d(v.x,v.y,v.z))
						end
	local lineto	=	function(v)
							return draw:line_to_3d(v.x,v.y,v.z)
						end
	local _triangle =		function(v1,v2,v3)
								return draw:triangle_3d(v1.x,v1.y,v1.z, v2.x,v2.y,v2.z, v3.x,v3.y,v3.z)
							end
	local filltriangle =	function(v1,v2,v3, t1,t2,t3, tex)
					if tex then
						return draw:fill_triangle_3d_tex(v1.x,v1.y,v1.z, v2.x,v2.y,v2.z, v3.x,v3.y,v3.z, t1.x,t1.y, t2.x,t2.y, t3.x,t3.y, tex)
					else
						return draw:filltriangle_3d(v1.x,v1.y,v1.z, v2.x,v2.y,v2.z, v3.x,v3.y,v3.z)
					end
				end

	local rect =	function( corner, width, height)
				moveto( corner )
				lineto( corner + width )
				lineto( corner + width + height )
				lineto( corner + height )
				lineto( corner)
			end

	local fillrect = function( corner, width, height, tex )
				local p1 = corner + width
				local p2 = p1 + height
				local p3 = corner + height
				if tex then
					filltriangle( corner, p1, p2, point.new(0,0), point.new(1,0), point.new(1,1), tex )
					filltriangle( corner, p2, p3, point.new(0,0), point.new(1,1), point.new(0,1), tex )
				else
					filltriangle( corner, p1, p2 )
					filltriangle( corner, p2, p3 )
				end
			end


	local _circle	=	function(center,dir,radius,segments,newmode, seg)
							return draw:circle_3d(center.x,center.y,center.z, dir.x,dir.y,dir.z, radius, segments, newmode, seg)
						end
	local fillcircle=	function(center,dir,radius,segments,newmode, seg)
							return draw:fillcircle_3d(center.x,center.y,center.z, dir.x,dir.y,dir.z, radius, segments, newmode, seg)
						end
	local _box		=	function(min,max)
							return draw:box_3d(min.x,min.y,min.z,max.x,max.y,max.z)
						end
	local cylinder	=	function(center,dir,height,radius1,radius2,segments,newmode, seg)
							return draw:cylinder_3d(center.x,center.y,center.z, dir.x,dir.y,dir.z, height, radius1, radius2, segments, newmode, seg)
						end

	local textout =		function( org, widthdir, heightdir, text, widthscale, heightscale )
					return draw:textout_3d( org.x, org.y, org.z, widthdir.x, widthdir.y, widthdir.z, heightdir.x, heightdir.y, heightdir.z, text, widthscale, heightscale )
				end


	local setmatrix =	function(mat)
							if (type(mat) ~= "table") then error("matrix expected") end
							local handle=draw:set_matrix(mat.getUD());
							if (NULL==handle)	then return nil end
							return matrix.new(handle)
						end
	local ztest	=		function(zenable)
							return draw:set_zenable(zenable);
						end

	local d=new(draw)
	d.point=_point
	d.moveto=moveto
	d.lineto=lineto
	d.triangle=_triangle
	d.filltriangle=filltriangle
	d.rect = rect
	d.fillrect = fillrect
	d.circle=_circle
	d.fillcircle=fillcircle
	d.box=_box
	d.cylinder=cylinder
	d.textout=textout
	d.setmatrix=setmatrix
	d.ztest=ztest
	return d
end


local drawud=_new_draw_ud()

local draw2d = new2d(drawud)
local draw3d = new3d(drawud)

function _Render2D()
	if (Render2D) then Render2D(draw2d) end
end

function _Render3D( mode )
	if (Render3D) then Render3D( draw3d, mode ) end
end


--- export ----
_new_draw_tb=new


-- color define --
COLOR_BLACK		=	toDWORD('ff000000')
COLOR_BLUE		=	toDWORD('ff0000a8')
COLOR_GREEN		=	toDWORD('ff00a800')
COLOR_CYAN		=	toDWORD('ff00a8a8')
COLOR_RED		=	toDWORD('ffa80000')
COLOR_MAGENTA		=	toDWORD('ffa800a8')
COLOR_BROWN		=	toDWORD('ffa85400')
COLOR_LIGHTGRAY		=	toDWORD('ffa8a8a8')
COLOR_DARKGRAY		=	toDWORD('ff545454')
COLOR_LIGHTBLUE		=	toDWORD('ff5454fc')
COLOR_LIGHTGREEN	=	toDWORD('ff54fc54')
COLOR_LIGHTCYAN		=	toDWORD('ff54fcfc')
COLOR_LIGHTRED		=	toDWORD('fffc5454')
COLOR_LIGHTMAGENTA	=	toDWORD('fffc54fc')
COLOR_YELLOW		=	toDWORD('fffcfc54')
COLOR_WHITE		=	toDWORD('fffcfcfc')






