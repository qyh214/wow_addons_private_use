local _, T = ...
local E = T.Evie

hooksecurefunc("UIDropDownMenu_StopCounting", function(self)
	local mf = self and GetMouseFocus()
	if mf and mf.tooltipTitle == nil and mf.tooltipText == nil and type(mf.tooltipOnButton) == "function" and
	   not mf:IsForbidden() and mf:GetParent() == self then
		self.tooltipOwner, self.tooltipOnLeave = mf, securecall(mf.tooltipOnButton, mf, mf.arg1, mf.arg2)
	else
		self.tooltipOwner, self.tooltipOnLeave = nil
	end
end)
hooksecurefunc("UIDropDownMenu_StartCounting", function(self)
	if self and self.tooltipOwner and type(self.tooltipOnLeave) == "function" then
		securecall(self.tooltipOnLeave, self.tooltipOwner)
		self.tooltipOnLeave, self.tooltipOwner = nil
	end
end)

local CreateLazyActionButton do
	local buttons = {}
	function CreateLazyActionButton(parent, templates)
		local container = CreateFrame("Frame", nil, parent)
		local button = securecall(CreateFrame, "Button", nil, nil, "SecureActionButtonTemplate" .. (templates and "," .. templates or ""))
		buttons[container], container.real, button.slot = button, button, container
		if not InCombatLockdown() then
			button:SetParent(container)
			button:SetAllPoints(container)
		end
		return container, button
	end
	T.CreateLazyActionButton = CreateLazyActionButton
	function E:PLAYER_REGEN_DISABLED()
		for _,v in pairs(buttons) do
			v:ClearAllPoints()
			v:SetParent(nil)
			v:Hide()
		end
	end
	function E:PLAYER_REGEN_ENABLED()
		for k,v in pairs(buttons) do
			v:SetParent(k)
			v:SetAllPoints()
			v:Show()
		end
	end
end
local CreateLazyItemButton do
	local itemIDs = {}
	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(itemIDs[self])
		GameTooltip:Show()
	end
	local function OnLeave(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end
	local function OnShow(self)
		self.slot.Count:SetText((GetItemCount(itemIDs[self])))
	end
	function CreateLazyItemButton(parent, itemID)
		local f, b = CreateLazyActionButton(parent)
		b:SetScript("OnShow", OnShow)
		itemIDs[b], f.itemID = itemID, itemID
		f.Icon = b:CreateTexture(nil, "ARTWORK")
		f.Icon:SetAllPoints()
		f.Icon:SetTexture(GetItemIcon(itemID))
		f.Count = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
		f.Count:SetPoint("BOTTOMRIGHT", -1, 2)
		b:SetAttribute("type", "macro")
		b:SetAttribute("macrotext", SLASH_STOPSPELLTARGET1 .. "\n" .. SLASH_USE1 .. " item:" .. itemID)
		b:SetScript("OnEnter", OnEnter)
		b:SetScript("OnLeave", OnLeave)
		b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		return f,b
	end
	function E:BAG_UPDATE_DELAYED()
		for k in pairs(itemIDs) do
			if k:IsVisible() then
				OnShow(k)
			end
		end
	end
	T.CreateLazyItemButton = CreateLazyItemButton
end