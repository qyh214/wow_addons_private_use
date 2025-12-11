local T, C, L, G = unpack(select(2, ...))

local IMAGE_ARROW = "Interface\\Addons\\JST\\media\\Arrow-1024"
local IMAGE_ARROW_UP = "Interface\\AddOns\\JST\\media\\Arrow-UP-1024"

--[[-------------------------------------------------------------------------
--      local angle = [0-360] left:90 right:270 up:0 down:180
--      arrowframe:SetArrowDirection(angle)

--      arrowframe:SetArrowColor(r, g, b)

--		arrowframe:SetGradientArrowColor(perc)

--		arrowframe:SetArrowTitle("Hijacked arrow", "Hijacked")
-------------------------------------------------------------------------]]--

local StringToAngle = {
	left = 90,
	right = 270,
	up = 0,
	down = 180,
}

T.GetArrowFrame = function(parent)	
	local arrowframe = CreateFrame("Button", parent:GetName().."Arrow", parent)
	arrowframe:SetSize(100, 100)
	arrowframe:SetFrameStrata("MEDIUM")
	arrowframe:Hide()
	
	arrowframe.movingname = string.format("%s [%s]", parent.movingname, L["箭头"])
	arrowframe.movingtag = parent.movingtag
	arrowframe.point = { a1 = "TOP", a2 = "CENTER", x = 0, y = 200}
	arrowframe.enable = true
	T.CreateDragFrame(arrowframe)
	T.PlaceFrame(arrowframe)
	
	arrowframe.title = T.createtext(arrowframe, "OVERLAY", 24, "OUTLINE", "CENTER") 
	arrowframe.title:SetPoint("BOTTOM", arrowframe, "BOTTOM", 0, 0)
	
	arrowframe.value = T.createtext(arrowframe, "OVERLAY", 24, "OUTLINE", "CENTER")
	arrowframe.value:SetPoint("TOP", arrowframe.title, "BOTTOM", 0, 0)
	
	arrowframe.arrow = arrowframe:CreateTexture(nil, "OVERLAY")
	arrowframe.arrow:SetTexture(IMAGE_ARROW)
	arrowframe.arrow:SetAllPoints()
	
	arrowframe.count = 0
	arrowframe.t = 0
	
	function arrowframe:SetArrowDirection(value)
		local angle
		
		if type(value) == "string" then
			angle = StringToAngle[value]
		else
			angle = value
		end
		
		if self.showDownArrow then
			self.arrow:SetSize(100, 100)
			self.arrow:SetTexture(IMAGE_ARROW)
			self:SetScript("OnUpdate", nil)
			self.showDownArrow = false
		end
		
		local cell = floor(angle / 360 * 108 + 0.5) % 108
		local column = cell % 9
		local row = floor(cell / 9)
		
		local xstart = (column * 56) / 512
		local ystart = (row * 42) / 512
		local xend = ((column + 1) * 56) / 512
		local yend = ((row + 1) * 42) / 512
		self.arrow:SetTexCoord(xstart,xend,ystart,yend)
	end
	
	function arrowframe:SetArrowDown()
		if not self.showDownArrow then
			self.arrow:SetSize(103, 140)
			self.arrow:SetTexture(IMAGE_ARROW_UP)
			self.arrow:SetVertexColor(0, 1, 0)
			
			self:SetScript("OnUpdate", function(s, elapsed)
				s.t = s.t + elapsed
				if s.t > .02 then
					s.count = s.count + 1
					if s.count >= 55 then
						s.count = 0
					end
				
					local cell = s.count
					local column = cell % 9
					local row = floor(cell / 9)
				
					local xstart = (column * 53) / 512
					local ystart = (row * 70) / 512
					local xend = ((column + 1) * 53) / 512
					local yend = ((row + 1) * 70) / 512
					s.arrow:SetTexCoord(xstart,xend,ystart,yend)
					s.t = 0
				end
			end)
			
			self.showDownArrow = true
		end
	end
	
	function arrowframe:SetArrowColor(r, g, b)
		self.arrow:SetVertexColor(r, g, b)
	end
	
	function arrowframe:SetGradientArrowColor(perc)
		local gr,gg,gb = 0, 1, 0
		local mr,mg,mb = 1, 1, 0
		local br,bg,bb = 1, 0, 0
		local r,g,b = T.ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)
		
		self.arrow:SetVertexColor(r, g, b)
	end
	
	function arrowframe:SetArrowTitle(title, value)
		self.title:SetText(title)
		self.value:SetText(value)
	end
	
	function arrowframe:PreviewShow()
		self:SetArrowTitle("", "")
		self:SetArrowColor(0,1,0)
		self:SetArrowDown()
		self:Show()
	end
	
	function arrowframe:PreviewHide()
		self:Hide()
	end
	
	if not parent.sub_frames then
		parent.sub_frames = {}
	end
	table.insert(parent.sub_frames, arrowframe)
	
	return arrowframe
end