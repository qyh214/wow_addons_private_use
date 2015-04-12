local _, T = ...
if T.Mark ~= 40 then return end
local G = T.Garrison

local function Ship_OnEnter(self, ...)
	if self.buildingID == -1 and self.plotID == -42 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(GARRISON_CACHE)
		local cv, mv, st, md = G.GetResourceCacheInfo()
		GameTooltip:AddLine(" ")
		local tl = st+md-time()
		if tl > 5400 then
			tl = SPELL_TIME_REMAINING_HOURS:format((tl+3599)/3600)
		elseif tl > 90 then
			tl = SPELL_TIME_REMAINING_MIN:format((tl+59)/60)
		elseif tl > 0 then
			tl = SPELL_TIME_REMAINING_SEC:format(tl)
		else
			tl = nil
		end
		if tl then
			GameTooltip:AddLine(tl, 0.25,1,0.15)
		end
		if cv > 0 then
			local cc = cv == mv and 0.1 or 1
			GameTooltip:AddLine(GARRISON_LANDING_COMPLETED:format(cv, mv), cc,1,cc)
		end
		self.UpdateTooltip = Ship_OnEnter
		GameTooltip:Show()
	else
		return GarrisonLandingPageReportShipment_OnEnter(self, ...)
	end
end
hooksecurefunc("GarrisonLandingPageReport_GetShipments", function(self)
	local cv, mv, st, md = G.GetResourceCacheInfo()
	if not cv then return end

	local ships = self.Shipments
	for i=1,#ships do
		local ship = ships[i]
		if not ship:IsShown() then
			ship.Done:SetShown(cv == mv)
			ship.Border:SetShown(cv < mv)
			ship.BG:SetShown(cv < mv)
			ship.Count:SetText(cv > 0 and cv or "")
			SetPortraitToTexture(ship.Icon, "Interface\\Icons\\INV_Garrison_Resource")
			ship.Icon:SetDesaturated(true)
			ship.Name:SetText(GARRISON_CACHE)
			if cv == mv then
				ship.Swipe:SetCooldownUNIX(0, 0);
			else
				ship.Swipe:SetCooldownUNIX(st, md);
			end
			ship.buildingID, ship.plotID = -1, -42
			ship:SetScript("OnEnter", Ship_OnEnter)
			ship:Show()
			break
		end
	end
end)
local function addCacheResources(self, id)
	if id == 824 then
		local cv, mv = G.GetResourceCacheInfo()
		if cv and cv > 0 then
			self:AddLine(GARRISON_CACHE .. ": |cffff" .. (cv < mv and "ffff" or "1010") .. cv .. "/" .. mv)
			return true
		end
	end
end
hooksecurefunc(GameTooltip, "SetCurrencyByID", addCacheResources)
hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", addCacheResources)
hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, idx)
	if addCacheResources(self, tonumber((GetCurrencyListLink(idx) or ""):match("currency:(%d+)") or 0)) then
		self:Show()
	end
end)