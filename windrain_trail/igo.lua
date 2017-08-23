
--- you need define blackstone,whitestone,transblackstone,transwhitestone, and stonedesk in your scene file.

-- variable define ----
local bGoGame=false;
local bShowResult=false;
local vInterPos=nil; -- intersect point on chessboard, in world space
local vGridOrg=vec.new(-48,15,-52); -- origin of chess grid, in object space
local GRIDSIZE=5.1; -- grid size
local row,col=0,0

local stonearray={}
local nstonecount=0

local buncharray={}
local nbunchcount=0

local bkstones={}
local bkstones2={}
local bkbunchs={}
local bkbunchs2={}



local function getInterPoint(x,y)
	local ray=GetRayFromPoint(x,y)
	local binter, fdist=stonedesk.intersectRay(ray,true,true)
	if (binter) then
		return true, ray.getOrg()+ray.getDir()*fdist
	else
		return false
	end
end

local function copyArray(dest, sour)
	for r=0,18 do
		local acol={}
		for c=0,18 do acol[c]=sour[r][c] end
		dest[r]=acol
	end
end

local function compareArray(dest, sour)
	for r=0,18 do
		for c=0,18 do
			if (dest[r][c]~=sour[r][c]) then return 1 end
		end
	end

	return 0
end

local function countBunch(x,y) -- group all stones to bunchs
	local nstone=stonearray[x][y] -- current stone
	if (0==nstone) then return end -- no stone

	local bunch={}
	local bi=0

	if (x>0) then
		if (stonearray[x-1][y]==nstone) then
			bunch[bi]=buncharray[x-1][y]
			bi=bi+1
		end
	end
	if (x<18) then
		if (stonearray[x+1][y]==nstone) then
			bunch[bi]=buncharray[x+1][y]
			bi=bi+1
		end
	end
	if (y>0) then
		if (stonearray[x][y-1]==nstone) then
			bunch[bi]=buncharray[x][y-1]
			bi=bi+1
		end
	end
	if (y<18) then
		if (stonearray[x][y+1]==nstone) then
			bunch[bi]=buncharray[x][y+1]
			bi=bi+1
		end
	end

	if (bi==0) then --new bunch
		buncharray[x][y]=nbunchcount+nstone -- black bunch indexed as odd number, and even number for white bunch
		nbunchcount=nbunchcount+2
	elseif (bi==1) then -- join current stone to the only bunch
		buncharray[x][y]=bunch[0]
	else -- multi bunchs, contact them to one
		for r=0,18 do
			for c=0,18 do
				for b=0,bi-1 do
					if (buncharray[r][c]==bunch[b]) then buncharray[r][c]=bunch[0] end
				end
			end
		end
		buncharray[x][y]=bunch[0]
	end
end


-- count breaths for assigned bunch
-- not accurate yet, because does't exclude repeated breath; but accurate for zero breath case

local function countBreath(nbunch)

	local nbreath=0

	for r=0,18 do
		for c=0,18 do
			if (buncharray[r][c]==nbunch) then
				if (r>0) then
					if (0==stonearray[r-1][c]) then nbreath=nbreath+1 end
				end
				if (r<18) then
					if (0==stonearray[r+1][c]) then nbreath=nbreath+1 end
				end
				if (c>0) then
					if (0==stonearray[r][c-1]) then nbreath=nbreath+1 end
				end
				if (c<18) then
					if (0==stonearray[r][c+1]) then nbreath=nbreath+1 end
				end
			end
		end
	end

	return nbreath

end

-- nside : 1 or 2 means clear black stone or white stone
local function clearDeadStones(nside)
	
	local nclear=0

	local breaths={}
	for b=0, nbunchcount do
		breaths[b]=countBreath(b)
	end

	for b=0, nbunchcount do
		if (0==breaths[b]) then -- no breath bunch must be clear from chessboard
			for r=0,18 do
				for c=0,18 do
					if (buncharray[r][c]==b and stonearray[r][c]==nside) then
						nclear=nclear+1
						stonearray[r][c]=0
						buncharray[r][c]=0
					end
				end
			end
		end
	end

	return nclear
end


local function updateStones()

	-- clear stones
	local pos=scene.getMobilesHead()
	while (pos) do
		local mov,typename
		mov,pos,typename=scene.getMobilesNext(pos)
		if (mov) then
			if (mov.getName()=='bkstone' or  mov.getName()=='wtstone') then
				scene.deleteMobile(mov)
			end
		end
	end


	for r=0,18 do
		for c=0,18 do
			local nstone=stonearray[r][c]
			local p=vGridOrg+vec.new(r*GRIDSIZE,0,c*GRIDSIZE)
			p=stonedesk.getMatrix()*p

			if (1==nstone) then -- black
				local mov=blackstone.clone()
				mov.setName('bkstone')
				mov.hide(false)
				mov.setPosition(p)
			elseif (2==nstone) then -- white
				local mov=whitestone.clone()
				mov.setName('wtstone')
				mov.hide(false)
				mov.setPosition(p)
			end

		end
	end
end

local function isValidCross(r,c,side)
	if (r<0 or r>18) then return false end
	if (c<0 or c>18) then return false end

	if (stonearray[r][c]==side) then return true end

	for x=r,0,-1 do
		if (side==stonearray[x][c]) then break end
		if ( 0~=stonearray[x][c] and side~=stonearray[x][c] ) then return false end
	end
	for x=r,18,1 do
		if (side==stonearray[x][c]) then break end
		if ( 0~=stonearray[x][c] and side~=stonearray[x][c] ) then return false end
	end
	for y=c,0,-1 do
		if (side==stonearray[r][y]) then break end
		if ( 0~=stonearray[r][y] and side~=stonearray[r][y] ) then return false end
	end
	for y=c,18,1 do
		if (side==stonearray[r][y]) then break end
		if ( 0~=stonearray[r][y] and side~=stonearray[r][y] ) then return false end
	end

	return true
end


function igo_showResult()
	bShowResult = not bShowResult
end

function igo_isGameOn()
	return bGoGame
end

function igo_turnonGoGame(bon, bcontinue)

	bGoGame=bon

	if (bcontinue and nstonecount>0) then return end -- ÐøÏÂ


	local pos=scene.getMobilesHead()
	while (pos) do
		local mov,typename
		mov,pos,typename=scene.getMobilesNext(pos)
		if (mov) then
			if (mov.getName()=='blackstone' or  mov.getName()=='whitestone') then
				mov.hide(bGoGame)
			end
		end
	end

	if (bGoGame) then
		PlayShot('GoGame')
	end
	
	for r=0,18 do
		local acol={}
		for c=0,18 do acol[c]=0 end
		stonearray[r]=acol
	end

	nstonecount=0


	for r=0,18 do
		local acol={}
		for c=0,18 do acol[c]=0 end
		buncharray[r]=acol
	end

	nbunchcount=0

	copyArray(bkstones,stonearray)
	copyArray(bkbunchs,buncharray)

	copyArray(bkstones2,stonearray)
	copyArray(bkbunchs2,buncharray)

	updateStones()
end


-- take a snapshot of current game
function igo_SaveToFile(fn)		-- export function
	if ( 'string' ~= type(fn) ) then return false end
	local file=io.open(fn,'w')
	if (not file) then return false end

	for i=0,7 do file:write('reserved line\n') end -- reserved for future use

	local function savearray(ary)
		for x=0,18 do
			for y=0,18 do
				file:write(ary[x][y],'\n')
			end
		end
	end

	savearray(stonearray)
	savearray(buncharray)
	savearray(bkstones)
	savearray(bkbunchs)
	savearray(bkstones2)
	savearray(bkbunchs2)

	file:write(nstonecount,'\n')
	file:write(nbunchcount,'\n')

	file:close()
	return true
end

-- recove game from snapshot file
function igo_LoadFromFile(fn)		-- export function
	if ( 'string' ~= type(fn) ) then return false end
	local file=io.open(fn,'r')
	if (not file) then return false end


	for i=0,7 do file:read('*l') end -- reserved for future use

	local function loadarray(ary)
		for x=0,18 do
			for y=0,18 do
				ary[x][y]=tonumber(file:read('*l'))
			end
		end
	end

	loadarray(stonearray)
	loadarray(buncharray)
	loadarray(bkstones)
	loadarray(bkbunchs)
	loadarray(bkstones2)
	loadarray(bkbunchs2)

	nstonecount=tonumber(file:read('*l'))
	nbunchcount=tonumber(file:read('*l'))

	file:close()

	updateStones()

	return true
end




--- Mouse Input Messages ---

function igo_OnMouseMove(x,y)
	if (not bGoGame) then return false end

	vInterPos=nil
	local binter, pos=getInterPoint(x,y)
	if (binter) then vInterPos=pos end


	if (vInterPos) then
		local invmat=stonedesk.getInvMatrix()
		local p=invmat*vInterPos
		
		p = p - vGridOrg

		row = (p.x+GRIDSIZE*0.5)/GRIDSIZE
		col = (p.z+GRIDSIZE*0.5)/GRIDSIZE

		if (row<0) then row=0 end
		if (row>18) then row=18 end
		if (col<0) then col=0 end
		if (col>18) then col=18 end

		row = math.floor(row)
		col = math.floor(col)

	end

	return true
end



function igo_OnLButtonUp(x,y)

	if (not bGoGame) then return false end

	if (vInterPos and 0==stonearray[row][col]) then
		
		local bPlaced=false

		local bkstones3={}
		local bkbunchs3={}
		copyArray(bkstones3, bkstones2)
		copyArray(bkbunchs3, bkbunchs2)
		
		copyArray(bkstones2, bkstones)
		copyArray(bkbunchs2, bkbunchs)

		copyArray(bkstones,stonearray)
		copyArray(bkbunchs,buncharray)

		local nextStone = nstonecount % 2 + 1
		stonearray[row][col] = nextStone
		countBunch(row,col)

		local nbreath=countBreath(buncharray[row][col])
		local nclear=clearDeadStones( (nstonecount+1) % 2 + 1 )

		if (nclear>0 or 0~=nbreath) then
			bPlaced=true
		else -- cann't place on no breath / no clearing position
			copyArray(stonearray,bkstones)
			copyArray(buncharray,bkbunchs)
		end

		if (bPlaced) then
			--- rob (kosmi) ---
			if (0==compareArray(stonearray,bkstones2)) then
				bPlaced=false
				copyArray(stonearray,bkstones)
				copyArray(buncharray,bkbunchs)
				
				copyArray(bkstones, bkstones2)
				copyArray(bkbunchs, bkbunchs2)

				copyArray(bkstones2,bkstones3)
				copyArray(bkbunchs2,bkbunchs3)
			end
		end

		if (bPlaced) then
			nstonecount=nstonecount+1
			updateStones()
			PlaySound('\\beat.wav')
			if (nclear>8) then
				PlaySound('\\clearstone2.wav')
			elseif (nclear>0) then
				PlaySound('\\clearstone.wav')
			end
		end

	end

	if vInterPos then return true end

	return false
end






--- app flow --

function igo_FrameMove()
	
	if (not bGoGame) then return end

	if (stonedesk.getPosition()-camera.getPosition()).lengthsq() > 40000 then
		bGoGame=false
		if (igo_on_deactive) then igo_on_deactive() end
	end

	transblackstone.hide(true)
	transwhitestone.hide(true)

	if (bGoGame and vInterPos and 0==stonearray[row][col]) then
		local p=vGridOrg+vec.new(row*GRIDSIZE,0,col*GRIDSIZE)
		p=stonedesk.getMatrix()*p

		if (0==nstonecount%2) then -- black
			transblackstone.setPosition(p)
			transblackstone.hide(false)
		else -- white
			transwhitestone.setPosition(p)
			transwhitestone.hide(false)
		end
	end
end

function igo_Render2D(draw)
	
	if (bGoGame) then

		-- test bunch
		--[[
		for r=0,18 do
			for c=0,18 do
				local nbunch=buncharray[r][c]
				if (nbunch) then
					local p=vGridOrg+vec.new(r*GRIDSIZE,0,c*GRIDSIZE)
					p=stonedesk.getMatrix()*p
					p=WorldToScreen(p)
					draw.setcolor(COLOR_GREEN)
					draw.textout(p.x,p.y,string.format('%d',nbunch))
				end
			end
		end
		--]]

		-- view result
		if (bShowResult) then
			local whitecount=0
			local blackcount=0

			for r=0,18 do
				for c=0,18 do
					draw.setbkcolor(toDWORD('0'))
					if (isValidCross(r,c,1)) then
						draw.setbkcolor(COLOR_RED)
						blackcount=blackcount+1
					end
					if (isValidCross(r,c,2)) then
						draw.setbkcolor(COLOR_GREEN)
						whitecount=whitecount+1
					end

					local p=vGridOrg+vec.new(r*GRIDSIZE,0,c*GRIDSIZE)
					p=stonedesk.getMatrix()*p
					p=WorldToScreen(p)
					draw.fillrect(rect.new(p.x-3,p.y-3,p.x+3,p.y+3))
				end
			end

			local pos=showresult.getPosition()
			draw.setcolor(COLOR_LIGHTCYAN)
			draw.textout(pos.x,pos.y+90,string.format('black : %d',blackcount))
			draw.textout(pos.x,pos.y+120,string.format('white : %d',whitecount))
		end
	end

end

