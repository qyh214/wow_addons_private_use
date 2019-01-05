local VERSION = 2

local function Calc(L)
	for i=1,#L do
		for j=#L[i]+1,32 do
			L[i] = L[i] .. "-"
		end
	end
	local N,R,M,B,Bl,Mr = {},{},{},{},{},{}
	for i=1,#L do
		N[i] = {}	--count of interracts
		R[i] = {}	--numeris values
		M[i] = {}	--interracts list
		Mr[i] = {}
		B[i] = {}	--count of interracts uses
		Bl[i] = {}	--blacklist
		for j=1,32 do
			N[i][j] = 0
			R[i][j] = 0
			M[i][j] = {}
			Mr[i][j] = {}
			B[i][j] = 0
			Bl[i][j] = 0
		end
	end
	for i=1,#L do
		for j=1,#L[i] do
			local s = L[i]:sub(j,j)
			if s == "+" then
				for xL = j-1,1,-1 do
					local c = L[i]:sub(xL,xL)
					if c == "G" or c == "W" or c == "Y" or c == "R" then
						N[i][xL] = N[i][xL] + 1
						tinsert(M[i][xL],{s,i,j})
						tinsert(Mr[i][j],{i,xL})
					else
						break
					end
				end
				for xR = j+1,#L[i] do
					local c = L[i]:sub(xR,xR)
					if c == "G" or c == "W" or c == "Y" or c == "R" then
						N[i][xR] = N[i][xR] + 1
						tinsert(M[i][xR],{s,i,j})
						tinsert(Mr[i][j],{i,xR})
					else
						break
					end
				end				
				for yT = i-1,1,-1 do
					local c = L[yT]:sub(j,j)
					if c == "G" or c == "W" or c == "Y" or c == "R" then
						N[yT][j] = N[yT][j] + 1
						tinsert(M[yT][j],{s,i,j})
						tinsert(Mr[i][j],{yT,j})
					else
						break
					end
				end
				for yB = i+1,#L do
					local c = L[yB]:sub(j,j)
					if c == "G" or c == "W" or c == "Y" or c == "R" then
						N[yB][j] = N[yB][j] + 1
						tinsert(M[yB][j],{s,i,j})
						tinsert(Mr[i][j],{yB,j})
					else
						break
					end
				end
			elseif s == "o" then
				for x = j-1,j+1 do
					for y = i-1,i+1 do
						if L[y] and x <= #L[y] and x > 0 then
							local c = L[y]:sub(x,x)
							if c == "G" or c == "W" or c == "Y" or c == "R" then
								N[y][x] = N[y][x] + 1
								tinsert(M[y][x],{s,i,j})
								tinsert(Mr[i][j],{y,x})
							end
						end
					end
				end
			elseif s == "x" then
				local dX,dY,x,y
				for k=1,4 do
					if k == 1 then dX,dY = -1,-1
					elseif k == 2 then dX,dY = 1,-1
					elseif k == 3 then dX,dY = -1,1
					elseif k == 4 then dX,dY = 1,1 end
					x,y = j,i
					while true do
						x = x + dX
						y = y + dY
						if L[y] and x <= #L[y] and x > 0 then
							local c = L[y]:sub(x,x)
							if c == "G" or c == "W" or c == "Y" or c == "R" then
								N[y][x] = N[y][x] + 1
								tinsert(M[y][x],{s,i,j})
								tinsert(Mr[i][j],{y,x})
							else
								break
							end
						else
							break
						end
					end
				end
			end
		end
	end

	--G > W > Y > R > G
	--1 > 2 > 3 > 4 > 1

	local cG,cW,cY,cR = 1,2,3,4

	for i=#N,1,-1 do
		for j=1,#N[i] do
			local s = N[i][j]
			local c = L[i]:sub(j,j)
			if c == "G" or c == "W" or c == "Y" or c == "R" then
				if s == 0 then
					if c == "G" then cG,cW,cY,cR = 4,1,2,3 end
					if c == "W" then cG,cW,cY,cR = 3,4,1,2 end
					if c == "Y" then cG,cW,cY,cR = 2,3,4,1 end
					if c == "R" then cG,cW,cY,cR = 1,2,3,4 end
				end
			end
		end
	end

	for i=#N,1,-1 do
		for j=1,#N[i] do
			local s = N[i][j]
			local c = L[i]:sub(j,j)
			if c == "G" or c == "W" or c == "Y" or c == "R" then
				if c == "G" then s = cG end
				if c == "W" then s = cW end
				if c == "Y" then s = cY end
				if c == "R" then s = cR end
				R[i][j] = s
				B[i][j] = -1
			elseif c == "x" or c == "o" or c == "+" then
				if c == "o" then c = "Рї" end
				s = c
			else
				B[i][j] = -2
				s = "-"
			end
		end
	end

	local function Click(s,X,Y)
		if s == "+" then
			local dX,dY,x,y
			for k=1,4 do
				if k == 1 then dX,dY = -1,0
				elseif k == 2 then dX,dY = 1,0
				elseif k == 3 then dX,dY = 0,1
				elseif k == 4 then dX,dY = 0,-1 end
				x,y = X,Y
				while true do
					x = x + dX
					y = y + dY
					if R[y] and x <= #R[y] and x > 0 then
						if R[y][x] > 0 then
							R[y][x] = R[y][x] + 1
							if R[y][x] > 4 then R[y][x] = 1 end
						else
							break
						end
					else
						break
					end
				end
			end
		elseif s == "o" then
			for x = X-1,X+1 do
				for y = Y-1,Y+1 do
					if R[y] and x <= #R[y] and x > 0 then
						if R[y][x] > 0 then
							R[y][x] = R[y][x] + 1
							if R[y][x] > 4 then R[y][x] = 1 end
						end
					end
				end
			end
		elseif s == "x" then
			local dX,dY,x,y
			for k=1,4 do
				if k == 1 then dX,dY = -1,-1
				elseif k == 2 then dX,dY = 1,-1
				elseif k == 3 then dX,dY = -1,1
				elseif k == 4 then dX,dY = 1,1 end
				x,y = X,Y
				while true do
					x = x + dX
					y = y + dY
					if R[y] and x <= #R[y] and x > 0 then
						if R[y][x] > 0 then
							R[y][x] = R[y][x] + 1
							if R[y][x] > 4 then R[y][x] = 1 end
						else
							break
						end
					else
						break
					end
				end
			end
		end
	end

	local function Proc1()
		local count = 0
		for i=1,#N do
			for j=1,#N[i] do
				if N[i][j] == 1 then
					local s = M[i][j][1][1]
					local X,Y = M[i][j][1][3],M[i][j][1][2]
					Bl[Y][X] = 1
					for l=R[i][j]+1,4 do
						B[Y][X] = B[Y][X] + 1
						Click(s,X,Y)
					end
					for l=1,#Mr[Y][X] do
						local y,x = Mr[Y][X][l][1],Mr[Y][X][l][2]
						N[y][x] = N[y][x] - 1
						for k=1,#M[y][x] do
							if M[y][x][k][2] == Y and M[y][x][k][3] == X then
								tremove(M[y][x],k)
								break
							end
						end
					end
					count = count+1
				end
			end
		end
		return count
	end

	local p = 1
	while p > 0 do
		p = Proc1()
	end

	local res = {}
	for i=1,#N do
		res[i] = ""
		for j=1,#N[i] do
			local s = ""
			local c = L[i]:sub(j,j)
			if c == "G" or c == "W" or c == "Y" or c == "R" then
				if R[i][j] == cG then s = "G" end
				if R[i][j] == cW then s = "W" end
				if R[i][j] == cY then s = "Y" end
				if R[i][j] == cR then s = "R" end
			elseif c == "x" or c == "o" or c == "+" then
				s = B[i][j]
			else
				s = "-"
			end
			res[i] = res[i] .. s
		end
	end
	return res
end


local SIZE = 16
local Frame = CreateFrame("Frame",nil,UIParent)
Frame:SetPoint("CENTER")
Frame:SetSize(SIZE * 32 + 10,SIZE * (32 + 2) + 20)
Frame:Hide()

Frame:EnableMouse(true)
Frame:SetMovable(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", function(self)
	if self:IsMovable() then
		self:StartMoving()
	end
end)
Frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)
Frame:SetFrameStrata("DIALOG")

Frame.b = Frame:CreateTexture(nil,"BACKGROUND")
Frame.b:SetAllPoints()
Frame.b:SetColorTexture(0.04,0.04,0.04,.9)

Frame.shadow = CreateFrame("Frame",nil,Frame)
do
	local size,edgeSize = 20,28
	Frame.shadow:SetPoint("LEFT",-size,0)
	Frame.shadow:SetPoint("RIGHT",size,0)
	Frame.shadow:SetPoint("TOP",0,size)
	Frame.shadow:SetPoint("BOTTOM",0,-size)
	Frame.shadow:SetBackdrop({edgeFile="Interface/AddOns/HHPH/shadow",edgeSize=edgeSize or 28,insets={left=size,right=size,top=size,bottom=size}})
	Frame.shadow:SetBackdropBorderColor(0,0,0,.45)
end

Frame.Close = CreateFrame("Button",nil,Frame,"UIPanelCloseButton")
Frame.Close:SetPoint("TOPRIGHT",3,3)
Frame.Close:SetScale(.8)

Frame.Tooltip = Frame:CreateFontString(nil,"ARTWORK","GameFontWhite")
Frame.Tooltip:SetPoint("TOPLEFT",5,-2)
Frame.Tooltip:SetText("Fill your pattern with buttons at bottom")

local grayPos = [=[---------Y++WGRoo+xYGW+---------
--------WYGWYYoW+WRRxGoR--------
-------RWWxYo+xWRoWWxGRoW-------
------RWWGWW+WYG+GYYRRWRYW------
-----YRxGRRRWYxxYWGGW+WYGRG-----
----GYWRRWWGYWRGRoGW+WYYoYW+----
---GGGYGWRo+RoGG+RGRWYGRGGWYY---
--WW+GYRGG+YGYWYWWGWWoYYWxxRRR--
-xGGWYRGWYx+RRWoGRRYYRYRYRRoWxR-
G++GRRGWYRoRRYYGRGRRYRGYRYxRoYYR
GxRGYYRGWYYxxRWWGWYW+GGxGGYGoYRY
GYxRW+GW+GGGR------GWYRRYWWRxWRR
+WW+RYGWWoWW--------WGRRGYoWWY+G
GRWYYWRGGWG----------YYWWR+Y+WRW
GWRoGRRGGWR----------RGG+WYGWGxR
oWoW+GG+GGG----------oWGY+GGGWRG
WWWWx+xxWRR----------RWGGRWRYYWR
WRGRRGG+GGG----------RYxGYRY+WG+
GoWoRYRYWRR----------WYGxYGYG+R+
G+RWxYRYoRWR--------YRRGxRGxWGoR
RRxWGG+YWWWWR------RoGGGYGGRYGxG
YxRRYGRYYGGWWWRRRWRGWoxY+WRGxRxG
GooYRYRoYoGRxWRoRRYYRRYxRYYG+RRY
-RWYYRWRYYYWR+RGR+YRYGR+WGWoYYW-
--WRYYGRWW+WxRRYRWRoWRRxRYWoWY--
---G+oRGoYYGRYG+GGYRoGGYxRoGW---
----GRRGWYxRYxYWWYG++RGYGGGR----
-----WRxoW+YYWGGWW+WW+YWWYW-----
------xYW+RRWWWRGRRYo+++Yx------
-------xWR+W+RYxYWGxxYoWY-------
--------GWWoRRxRRxWY+GYG--------
---------GRWGW+GYGGWWGR---------]=]
grayPos = {strsplit("\n",grayPos:gsub("[^\n-]","0"),nil)}
--grayPos = {strsplit("\n",grayPos,nil)}
local R = {}
local currX,currY = 1,1
local highlightedButton = nil
local currData = {}
for i=1,#grayPos do currData[i] = grayPos[i] end

local function UpdatePos(moveToNext)
	if highlightedButton then
		highlightedButton.b1:SetColorTexture(0,0,0)
		highlightedButton = nil
	end
	if moveToNext then
		if currX % 2 == 1 then
			currY = currY + 1
			if currY > 32 then
				currX = currX + 1
				currY = 32
			end
		else
			currY = currY - 1
			if currY < 1 then
				currX = currX + 1
				currY = 1
			end
		end
		if currX > 32 then
			currX = 1
			currY = 1
		end
	end
	while grayPos[currX]:sub(currY,currY) == "-" do
		if currX % 2 == 1 then
			currY = currY + 1
			if currY > 32 then
				currX = currX + 1
				currY = 32
			end
		else
			currY = currY - 1
			if currY < 1 then
				currX = currX + 1
				currY = 1
			end
		end
		if currX > 32 then
			currX = 1
			currY = 1
		end
	end
	highlightedButton = R[currX][currY]
	highlightedButton.b1:SetColorTexture(1,0,0)
end

local function UpdateData()
	for i=1,32 do
		for j=1,32 do
			local s = currData[i]:sub(j,j)
			local button = R[i][j]
			button.b2:SetColorTexture(.3,.3,.3)
			button.n:SetText("")

			if s == "R" then button.b2:SetColorTexture(1,0,0)
			elseif s == "G" then button.b2:SetColorTexture(0,1,0)
			elseif s == "Y" then button.b2:SetColorTexture(1,1,0)
			elseif s == "W" then button.b2:SetColorTexture(.7,.7,1)
			elseif s == "+" then button.n:SetText("+")
			elseif s == "x" then button.n:SetText("X")
			elseif s == "o" then button.n:SetText("O")
			elseif s and (tonumber(s) or 0) > 0 then button.n:SetText(s)
			elseif s == "-" then button.b2:SetColorTexture(.1,.1,.1)
			end
		end
	end
end

for i=1,32 do
	R[i] = R[i] or {}
	for j=1,32 do
		local button = CreateFrame("Button",nil,Frame)
		R[i][j] = button
		button:SetSize(SIZE,SIZE)
		button:SetPoint("TOPLEFT",5 + (j-1)*SIZE,-15 - (i-1)*SIZE)

		button.b1 = button:CreateTexture(nil,"BACKGROUND",nil,-2)
		button.b1:SetAllPoints()
		button.b1:SetColorTexture(0,0,0)

		button.b2 = button:CreateTexture(nil,"BACKGROUND",nil,1)
		button.b2:SetPoint("CENTER")
		button.b2:SetSize(SIZE-2,SIZE-2)
		button.b2:SetColorTexture(.3,.3,.3)

		button.t = button:CreateTexture(nil,"BACKGROUND")
		button.t:SetPoint("CENTER")
		button.t:SetSize(SIZE*0.8,SIZE*0.8)
		button.t:SetColorTexture(1,0,0)

		button.n = button:CreateFontString(nil,"ARTWORK","GameFontWhite")
		button.n:SetPoint("CENTER")

		button._I = i
		button._J = j
		button:SetScript("OnClick",function(self)
			currX,currY = self._I,self._J
			UpdatePos()
		end)

		if grayPos[i]:sub(j,j) == "-" then
			button:Disable()
			button.b2:SetColorTexture(.1,.1,.1)
		end
	end
end

for i=1,7 do
	local button = CreateFrame("Button",nil,Frame)
	button:SetSize(SIZE*2,SIZE*2)
	button:SetPoint("BOTTOM",-(7)*SIZE*2/2 + SIZE/2 + (i-1)*SIZE*2,5)
	button.b1 = button:CreateTexture(nil,"BACKGROUND",nil,-2)
	button.b1:SetAllPoints()
	button.b1:SetColorTexture(0,0,0)
	
	button.b2 = button:CreateTexture(nil,"BACKGROUND",nil,1)
	button.b2:SetPoint("CENTER")
	button.b2:SetSize((SIZE-2)*2,(SIZE*2)-2)
	button.b2:SetColorTexture(.4,.4,.1)
	
	button.t = button:CreateTexture(nil,"BACKGROUND")
	button.t:SetPoint("CENTER")
	button.t:SetSize(SIZE*0.8*2,SIZE*0.8*2)
	
	button.n = button:CreateFontString(nil,"ARTWORK","GameFontWhite")
	button.n:SetPoint("CENTER")
	button.n:SetScale(2)

	if i == 1 then button.b2:SetColorTexture(1,0,0)
	elseif i == 2 then button.b2:SetColorTexture(0,1,0)
	elseif i == 3 then button.b2:SetColorTexture(1,1,0)
	elseif i == 4 then button.b2:SetColorTexture(.7,.7,1)
	elseif i == 5 then button.n:SetText("+")
	elseif i == 6 then button.n:SetText("X")
	elseif i == 7 then button.n:SetText("O")
	end

	if i == 1 then button.S = "R"
	elseif i == 2 then button.S = "G"
	elseif i == 3 then button.S = "Y"
	elseif i == 4 then button.S = "W"
	elseif i == 5 then button.S = "+"
	elseif i == 6 then button.S = "x"
	elseif i == 7 then button.S = "o"
	end

	button:SetScript("OnClick",function(self)
		currData[currX] = currData[currX]:sub(1,currY-1)..self.S..currData[currX]:sub(currY+1)
		UpdateData()
		UpdatePos(true)
	end)
end

Frame.GoButton = CreateFrame("Button",nil,Frame,"UIPanelButtonTemplate")
Frame.GoButton:SetPoint("BOTTOMRIGHT")
Frame.GoButton:SetSize(100,22)
Frame.GoButton:SetText("GO")
Frame.GoButton:SetScript("OnClick",function(self)
	if not self.save then
		self.save = currData
		local res = Calc(currData)
		currData = res
		UpdateData()
		self:SetText("Back (undo)")
		Frame.Tooltip:SetText("Result: Click on ingame switches as many times as number tells (or 0 if no number)")
	else
		currData = self.save
		self.save = nil
		UpdateData()
		self:SetText("GO")
		Frame.Tooltip:SetText("Fill your pattern with buttons at bottom")
	end
end)

Frame.ClearButton = CreateFrame("Button",nil,Frame,"UIPanelButtonTemplate")
Frame.ClearButton:SetPoint("BOTTOMLEFT")
Frame.ClearButton:SetSize(100,22)
Frame.ClearButton:SetText("Clear")
Frame.ClearButton:SetScript("OnClick",function()
	for i=1,#grayPos do currData[i] = grayPos[i] end
	VHHPH.C = currData
	UpdateData()
	Frame.GoButton.save = nil
	Frame.GoButton:SetText("GO")
end)

SlashCmdList["HMHSlash"] = function(arg)
	if arg and arg:lower() == "reset" then
		for i=1,#grayPos do currData[i] = grayPos[i] end
		VHHPH.C = currData
		UpdateData()
		return
	end
	Frame:Show()
end
SLASH_HMHSlash1 = "/hhph"

Frame:RegisterEvent("ADDON_LOADED")
Frame:SetScript("OnEvent",function(self,event,...)
	if event == "ADDON_LOADED" then
		self:UnregisterEvent("ADDON_LOADED")
		VHHPH = VHHPH or {}
		VHHPH.V = VERSION
		VHHPH.C = VHHPH.C or currData
		currData = VHHPH.C

		UpdateData()
		UpdatePos(true)
	end
end)