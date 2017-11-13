-- inventory.lua
-- v0.3

require 'item'

local function _new()
	local bShow=false

	local bRelativeMode=true --relative based coordinate systems

	local itemlist=array.new()
	local area=rect.new(0,0,1,0.2)
	local coverarea=rect.new(0,0,1,1)
	local offsetx,offsety=0,0

	local backcolor=COLOR_LIGHTGRAY
	local textcolor=COLOR_GREEN
	local backimage=nil
	local coverimage=nil
	local winWidth, winHeight = 0, 0

	local selectedItem=nil
	local txtItemDesc=''


	local currentitem = nil
	local itemarea_lefttop, itemarea_w, itemarea_h, ia_w, ia_h -- define 3d items area

	local function isRelativeCoordMode()
		return bRelativeMode
	end

	local function setRelativeCoordMode(relative)
		bRelativeMode=relative
	end
	
	local function getBackColor()
		return backcolor
	end

	local function setBackColor(bkcolor)
		backcolor=bkcolor
	end

	local function getTextColor()
		return textcolor
	end

	local function setTextColor(txtcol)
		textcolor=txtcol
	end


	local function getBackImage()
		return backimage
	end

	local function setBackImage(bkimg)
		backimage=bkimg
	end

	local function getCoverImage()
		return coverimage
	end

	local function setCoverImage(img)
		coverimage=img
	end

	local function getArea()
		return area.clone()
	end

	local function setArea(ar)
		area=ar.clone()
	end

	local function getCoverArea()
		return coverarea.clone()
	end

	local function setCoverArea(ar)
		coverarea=ar.clone()
	end

	local function getItemOffset()
		return offsetx,offsety
	end

	local function setItemOffset(x,y)
		offsetx,offsety=x,y
	end

	local function getSelectedItem()
		return selectedItem
	end

	local function selectItem( it )
		if selectedItem and selectedItem.OnSelect then
			selectedItem.OnSelect(false)
		end

		selectedItem=it

		if selectedItem and selectedItem.OnSelect then
			selectedItem.OnSelect(true)
		end
	end

	local function onSize( type, cx, cy )
		winWidth=cx
		winHeight=cy
	end

	local function onMouseMove(x,y)
		if (coverimage) then return true end

		if not bShow then return false end

		if (not selectedItem) then txtItemDesc='' end

		local r
		if bRelativeMode then
			r=rect.new( area.left*winWidth, area.top*winHeight, area.right*winWidth, area.bottom*winHeight )
		else
			r=area
		end

		if ( not r.ptInRect(point.new(x,y)) ) then return false end

		--items
		if (selectedItem) then
			txtItemDesc=selectedItem.getDesc()
		else
			for n=1,itemlist.size() do
				local it=itemlist[n]
				local itr=it.getRect()
				if ( itr.ptInRect(point.new(x-r.left,y-r.top)) ) then
					currentitem = it
					txtItemDesc=it.getDesc()
				end
			end
		end

		return true
	end

	local function getItemOnRay( ray )
		if not itemarea_lefttop then return end
		local binter, t, u, v = RayIntersectTriangle( ray.getOrg(), ray.getDir(), itemarea_lefttop, itemarea_lefttop+itemarea_w, itemarea_lefttop+itemarea_h )
		if not binter then return end

		for n=1,itemlist.size() do
			local it=itemlist[n]
			if selectedItem~=it and not it.isHidden() then
				if ( u>=it.u/ia_w and v>=it.v/ia_h and u < (it.u + g_config.item_icon_width) / ia_w  and  v < (it.v + g_config.item_icon_height) / ia_h ) then
					return it, t
				end
			end
		end
	end

	local function onRayMove( ray )
		if (coverimage) then return true end

		if not bShow then return false end

		if (not selectedItem) then txtItemDesc='' end
		--items
		if (selectedItem) then
			txtItemDesc=selectedItem.getDesc()
			return true
		else
			local t
			currentitem,t = getItemOnRay( ray )
			if currentitem then txtItemDesc = currentitem.getDesc() end
			return currentitem, t
		end
	end

	local function onLButtonDown(x,y)
		if not bShow then return false end

		local r
		if bRelativeMode then
			r=rect.new( area.left*winWidth, area.top*winHeight, area.right*winWidth, area.bottom*winHeight )
		else
			r=area
		end

		if ( not r.ptInRect(point.new(x,y)) ) then return false end
		return true
	end

	local function onLButtonUp(x,y)
		if not bShow then return false end

		if selectedItem and selectedItem.OnSelect then
			selectedItem.OnSelect(false)
		end

		selectedItem=nil

		local r
		if bRelativeMode then
			r=rect.new( area.left*winWidth, area.top*winHeight, area.right*winWidth, area.bottom*winHeight )
		else
			r=area
		end

		if ( not r.ptInRect(point.new(x,y)) ) then return false end

		--items
		for n=1,itemlist.size() do
			local it=itemlist[n]
			local itr=it.getRect()
			if ( itr.ptInRect(point.new(x-r.left,y-r.top)) ) then
				selectedItem=it
				if (it.OnSelect) then it.OnSelect(true) end
			end
		end

		return true
	end
	
	local function isShow()
		return bShow
	end

	local function show(show)
		bShow=show
		itemarea_lefttop=nil
	end


	local function draw(dw)

		--draw cover image
		if (coverimage) then

			local r
			if bRelativeMode then
				r=rect.new( coverarea.left*winWidth, coverarea.top*winHeight, coverarea.right*winWidth, coverarea.bottom*winHeight )
			else
				r=coverarea
			end

			dw.setbkcolor(COLOR_WHITE)
			dw.stretchblt(r, coverimage)

			do return end
		end

		if not bShow then return end

		local r
		if bRelativeMode then
			r=rect.new( area.left*winWidth, area.top*winHeight, area.right*winWidth, area.bottom*winHeight )
		else
			r=area
		end

		dw.setbkcolor(backcolor)
		if (backimage) then
			dw.stretchblt(r,backimage)
		else
			dw.fillrect(r)
		end

		--draw items
		for n=1,itemlist.size() do
			local it=itemlist[n]
			if selectedItem~=it and not it.isHidden() then
				local itr=it.getRect()
				itr.offset(r.left,r.top)
				dw.setbkcolor(COLOR_WHITE)
				dw.stretchblt(itr, texturelist.addTexture(	it.getImage() ) )
			end
		end


		--draw item desc text
		dw.setcolor(textcolor)
		dw.textout(r.left,r.top,txtItemDesc)



	end



	local function draw3d(dw)

		--draw cover image
		if (coverimage) then
			local center = finalcamera.getPosition() + finalcamera.getFront() * g_config.cover_area_depth
			local w = finalcamera.getRight() * g_config.cover_area_width
			local h = -finalcamera.getUp() * g_config.cover_area_height
			local lefttop = center - w - h
			w = w*2
			h = h*2

			dw.setbkcolor(COLOR_WHITE)
			local ztestsave = dw.ztest( false )
			dw.fillrect( lefttop, w, h, coverimage )
			dw.ztest( ztestsave )

			do return end
		end

		if not bShow then return end


		dw.setbkcolor(backcolor)

		if not itemarea_lefttop then
			local up = vec.new(0,1,0)
			local front = vec.cross( finalcamera.getRight(), up )
			up = vec.cross( front, finalcamera.getRight() )
			local center = finalcamera.getPosition() + front * g_config.item_area_depth
			local w = finalcamera.getRight() * g_config.item_area_width
			local h = -up * g_config.item_area_height
			itemarea_lefttop = center - w - h
			itemarea_w = w*2
			itemarea_h = h*2
		end

		local ztestsave = dw.ztest( false ) -- save z state
		dw.fillrect( itemarea_lefttop, itemarea_w, itemarea_h )

		ia_w = g_config.item_area_width * 2 --itemarea_w.length()
		ia_h = g_config.item_area_height * 2 --itemarea_h.length()

		local maxcol = math.floor( ia_w / (g_config.item_icon_width + g_config.item_icon_gap) )
		local maxrow = math.floor( ia_h / (g_config.item_icon_height + g_config.item_icon_gap) )

		local leftspace = ia_w - maxcol*g_config.item_icon_width - (maxcol-1)*g_config.item_icon_gap
		local wnormal = itemarea_w / ia_w
		local hnormal = itemarea_h / ia_h

		--draw items
		for row=1, maxrow do
		   for col=1, maxcol do 
			local n = col + (row-1) * maxcol
			if n > itemlist.size() then break end

			-- draw a item icon
			local it=itemlist[n]
			if selectedItem~=it and not it.isHidden() then
				it.u = (leftspace + (col-1) * (g_config.item_icon_width + g_config.item_icon_gap))
				it.v = (leftspace + (row-1) * (g_config.item_icon_height + g_config.item_icon_gap))

				local corner = itemarea_lefttop + wnormal * it.u + hnormal * it.v
				local itemw = wnormal*g_config.item_icon_width
				local itemh = hnormal*g_config.item_icon_height

				dw.setbkcolor( COLOR_WHITE )
				dw.fillrect( corner, itemw, itemh, texturelist.addTexture(it.getImage()) )

				if currentitem == it then
					dw.setcolor(g_config.item_frame_color)
					dw.rect( corner, itemw, itemh )
					dw.setcolor(textcolor)
					dw.textout( corner + itemh, wnormal, hnormal, it.getDesc(), 0.3,0.3 )
				end
			end

		   end
		end

		dw.ztest( ztestsave ) -- restore z state
	end


	local function addItem(it)

		local maxleft=offsetx
		for n=1,itemlist.size() do
			local it=itemlist[n]
			maxleft=maxleft+it.getRect().width()
		end

		local r=it.getRect()
		r.offset(maxleft,offsety)
		it.setRect( r )

		itemlist.add(it)

	end


	local function deleteItem(id)
		for n=1,itemlist.size() do
			local it=itemlist[n]
			if (it.getID()==id) then
				if (selectedItem==it) then selectedItem=nil end
				itemlist.remove(n)
				break
			end
		end

		--rearrange item's position
		local left=0
		for n=1,itemlist.size() do
			local it=itemlist[n]
			local r=it.getRect()
			r.offset(left-r.left,0)
			it.setRect(r)
			left=r.right
		end
	end


	local function findItem(id)
		for n=1,itemlist.size() do
			local it=itemlist[n]
			if (it.getID()==id) then
				return it
			end
		end
	end

	local function getItemList()
		return itemlist
	end

	
	local invent={}

	invent.isRelativeCoordMode=isRelativeCoordMode
	invent.setRelativeCoordMode=setRelativeCoordMode
	invent.getBackColor=getBackColor
	invent.setBackColor=setBackColor
	invent.getTextColor=getTextColor
	invent.setTextColor=setTextColor
	invent.getBackImage=getBackImage
	invent.setBackImage=setBackImage
	invent.getCoverImage=getCoverImage
	invent.setCoverImage=setCoverImage
	invent.getArea=getArea
	invent.setArea=setArea
	invent.getCoverArea=getCoverArea
	invent.setCoverArea=setCoverArea
	invent.getItemOffset=getItemOffset
	invent.setItemOffset=setItemOffset
	invent.getSelectedItem=getSelectedItem
	invent.selectItem=selectItem
	invent.onSize=onSize
	invent.onMouseMove=onMouseMove
	invent.onRayMove = onRayMove
	invent.onLButtonDown=onLButtonDown
	invent.onLButtonUp=onLButtonUp
	invent.isShow=isShow
	invent.show=show
	invent.draw=draw
	invent.draw3d=draw3d
	invent.getItemOnRay = getItemOnRay

	invent.addItem=addItem
	invent.deleteItem=deleteItem
	invent.findItem=findItem
	invent.getItemList=getItemList

	return invent

end

-- export ----
inventory	=	{
	new	= _new
}