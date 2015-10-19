local _, T = ...
if T.Mark ~= 50 then return end
local G, L, E = T.Garrison, T.L, T.Evie

local function Ship_OnEnter(self, ...)
	if self.buildingID == -1 and self.plotID == -42 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(GARRISON_CACHE)
		local cv, mv, st, md = G.GetResourceCacheInfo()
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
		GameTooltip:AddLine(" ")
		if cv > 0 then
			local cc = cv == mv and 0.1 or 1
			GameTooltip:AddLine(GARRISON_LANDING_COMPLETED:format(cv, mv), cc,1,cc)
			local _, cur, _, _, _, tmax = GetCurrencyInfo(824)
			if cur and tmax and tmax > 0 then
				GameTooltip:AddLine("|n" .. CURRENCY_TOTAL_CAP:format(cur == tmax and "|cffff0000" or (cur + cc > tmax) and "|cffffe000" or "|cffffffff", cur, tmax))
			end
		end
		self.UpdateTooltip = Ship_OnEnter
		GameTooltip:Show()
	else
		GarrisonLandingPageReportShipment_OnEnter(self, ...)
		local n = C_Garrison.GetFollowerInfoForBuilding(self.plotID)
		if n and GameTooltip:IsShown() then
			GameTooltipTextLeft2:SetText(GARRISON_LANDING_SHIPMENT_LABEL .. " |cff909090(" .. n .. ")")
			GameTooltip:Show()
		end
	end
end
hooksecurefunc("GarrisonLandingPageReport_GetShipments", function(self)
	local cv, mv, st, md = G.GetResourceCacheInfo()
	if not cv then return end

	local ships = self.Shipments
	for i=1,#ships do
		local ship = ships[i]
		ship:SetScript("OnEnter", Ship_OnEnter)
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
			ship:Show()
			break
		elseif C_Garrison.GetFollowerInfoForBuilding(ship.plotID) then
			ship.Name:SetText("|cff90e090" .. ship.Name:GetText())
		end
	end
end)
function E:SHOW_LOOT_TOAST(rt, rl, _q, _4, _5, _6, source)
	if rt == "currency" and source == 10 and rl:match("currency:824") then
		GarrisonLandingPageReport_GetShipments(GarrisonLandingPageReport)
	end
end
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

hooksecurefunc("GarrisonLandingPageReportList_UpdateAvailable", function()
	local items, buttons = GarrisonLandingPageReport.List.AvailableItems, GarrisonLandingPageReport.List.listScroll.buttons
	for i=1,#buttons do
		local item = buttons[i]:IsShown() and items[buttons[i].id]
		if item and item.offerTimeRemaining and item.offerEndTime then
			if item.offerEndTime - 8640000 <= GetTime() then
				buttons[i].MissionType:SetFormattedText("%s |cffa0a0a0(%s %s)|r",
					item.durationSeconds >= GARRISON_LONG_MISSION_TIME and (GARRISON_LONG_MISSION_TIME_FORMAT):format(item.duration) or item.duration,
					L"Expires in:", item.offerTimeRemaining)
			end
		end
	end
end)