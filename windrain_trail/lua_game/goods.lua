require 'item'
require 'showmessage'

goodsID = {
	xinfeng = toDWORD('500'),
	yifu	= toDWORD('501'),
	huishengdan = toDWORD('502'),
	diaogan = toDWORD('600'),
	qiuyin = toDWORD('700'),
	liyu = toDWORD('710'),
	jiyu = toDWORD('711'),
	qingyu = toDWORD('712'),
	nianyu = toDWORD('713'),
	sword = toDWORD('800'),
}

goodsUseFunction = {
}

local goodsDictionary = {
	xinfeng = { goodsID.xinfeng, '书信', '\\goods\\shuxin.dds', '\\takepaper.wav' },
	yifu	= { goodsID.yifu, '衣服', '\\goods\\yifu.dds', '\\take1.wav' },
	huishengdan = { goodsID.huishengdan, '回神丹', '\\goods\\danyao.dds', '\\take.wav' },
	diaogan = { goodsID.diaogan, '钓竿', '\\goods\\diaogan.dds', '\\take1.wav' },
	qiuyin = { goodsID.qiuyin, '蚯蚓', '\\goods\\qiuyin.dds', '' },
	liyu = { goodsID.liyu, '鲤鱼', '\\goods\\liyu.dds', '\\take1.wav' },
	jiyu = { goodsID.jiyu, '鲫鱼', '\\goods\\jiyu.dds', '\\take1.wav' },
	qingyu = { goodsID.qingyu, '青鱼', '\\goods\\qingyu.dds', '\\take1.wav' },
	nianyu = { goodsID.nianyu, '鲶鱼', '\\goods\\nianyu.dds', '\\take1.wav' },
	sword = { goodsID.sword, '剑', '\\ui\\cursor_sword.png', '\\take.wav' },
}


-- find in goods dict
local function findByID( id )
	for k, v in pairs(goodsDictionary) do
		if v[1] == id then
			return v
		end
	end
end



local itemlist = array.new()


local function findByIDinList( id )
	for i=1, itemlist.size() do
		if itemlist[i].getID() == id then
			return i
		end
	end
end

local function goodsGetItemByID( id )
	local idx = findByIDinList(id)
	if not idx then return end
	return itemlist[idx]
end



---- export ----
function goodsGetItem( id )
	local it = goodsGetItemByID( id )
	if not it then return end
	return it.getDesc(), it.getAmount(), it.getImage()
end

function goodsPick( id, nosound, nomsg )
	local g = findByID( id )  -- find in goods dict
	if not g then return end

	local it = goodsGetItemByID(id)
	if it then --列表里已经有该物品，则数量加 1
		it.setAmount( it.getAmount() + 1 )
	else
		it = item.new(id)
		it.setDesc( g[2] )
		it.setImage( g[3] )
		itemlist.add( it )
	end

	if cb_OnItemListChanged then cb_OnItemListChanged(itemlist) end

	if not nosound then PlaySound( g[4] ) end
	if not nomsg then message_Push( '获得 '..it.getDesc() ) end
end

function goodsDrop( id, nosound )
	local idx = findByIDinList( id )
	if not idx then return end
	itemlist.remove(idx)
	if cb_OnItemListChanged then cb_OnItemListChanged(itemlist) end
end


function goodsUse( id, nosound )
	local it = goodsGetItemByID( id )

	if not it then return end

	local  f = goodsUseFunction[id]

	if f then f() end
end

-- 消耗指定数量的物品
function goodsConsume( id, amount )
	local idx = findByIDinList( id )
	if not idx then return end

	amount = amount or 1
	
	amount = itemlist[idx]. getAmount() - amount;
	if amount < 1 then -- 物品消耗光，则从队列中删除
		itemlist.remove(idx)
	else
		itemlist[idx]. setAmount( amount )
	end

	if cb_OnItemListChanged then cb_OnItemListChanged(itemlist) end
end
