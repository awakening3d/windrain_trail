-- item.lua
-- v0.2 --


local function _new(id)
	local ItemID = id
	local rectImage = rect.new(0,0,16,16)
	local image=nil
	local hidden=false
	local txtDesc=''
	local amount=1

	local function getID()
		return ItemID
	end

	local function getRect()
		return rectImage.clone()
	end

	local function setRect(r)
		rectImage=r.clone()
	end

	local function getImage()
		return image
	end

	local function setImage(img)
		image=img
	end

	local function getDesc()
		return txtDesc
	end

	local function setDesc(desc)
		txtDesc=desc
	end

	local function getAmount()
		return amount
	end

	local function setAmount(a)
		amount = a
	end

	local function isHidden()
		return hidden
	end

	local function hide(h)
		hidden=h
	end

	local it={}

	it.getID=getID
	it.getRect=getRect
	it.setRect=setRect
	it.getImage=getImage
	it.setImage=setImage
	it.getDesc=getDesc
	it.setDesc=setDesc
	it.getAmount=getAmount
	it.setAmount=setAmount
	it.isHidden=isHidden
	it.hide=hide

	return it

end

-- export ----
item	=	{
	new	= _new
}