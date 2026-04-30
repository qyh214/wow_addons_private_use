local _, core = ...

core.MAX_LEVEL = 100

if MurlokExportConfig == nil then
	MurlokExportConfig = {}
end

function core:Toggle()
	UIMurlokExport:SetShown(not UIMurlokExport:IsShown())
end

function core:Capitialize(str)
	return (str:gsub("^%l", string.upper))
end

function core:Pairs(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function ()
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i], t[a[i]]
	  end
	end
	return iter
end

function core:IPairs(t, f, asc)
	local a = {}
	for n, m in pairs(t) do table.insert(a, {n, m}) end
	if f == nil then
		if not asc then
			table.sort(a, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2] > k2[2] end)
		else
			table.sort(a, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2] < k2[2] end)
		end
	else
		table.sort(a, f)
	end
	local i = 0
	local iter = function ()
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i][1], a[i][2]
	  end
	end
	return iter
end

function core:TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function core:Artwork(path)
	return "Interface\\AddOns\\MurlokExport\\Artwork\\" .. path
end

function core:GetRankColor(rank)
	if not rank then
		return
	end
	if rank == 0 then
		return ITEM_LEGENDARY_COLOR:GenerateHexColorMarkup()
	elseif rank >= 1 and rank < 5 then
		return EPIC_PURPLE_COLOR:GenerateHexColorMarkup()
	elseif rank == 6 then
		return NEUTRAL_STATUS_COLOR:GenerateHexColorMarkup()
	else
		return WHITE_FONT_COLOR:GenerateHexColorMarkup()
	end
end

function core:GetPlayerClassSpecHero()
    local specId = GetSpecializationInfo(GetSpecialization())
	local _, classId = UnitClassBase("player")
	local heroId = C_ClassTalents.GetActiveHeroTalentSpec()
    return classId, specId, heroId
end

UIMurlokExportMixin = CreateFromMixins(PortraitFrameMixin)
function UIMurlokExportMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName())
	self:SetTitle(MURLOKEXPORT_TITLE)

	self:SetTabs(4, MURLOKEXPORT_CATEGORY_STATS, MURLOKEXPORT_CATEGORY_TALENTS, MURLOKEXPORT_CATEGORY_TRAITS, MURLOKEXPORT_CATEGORY_EQUIPMENT)

	self.MaximizeMinimizeButton:SetOnMaximizedCallback(GenerateClosure(self.OnManualMaximizeClicked, self))
	self.MaximizeMinimizeButton:SetOnMinimizedCallback(GenerateClosure(self.OnManualMinimizeClicked, self))

	self.PortraitContainer.portrait:SetTexture(core:Artwork(MURLOKEXPORT_TITLE))
	self.DataExportTime:SetText(MURLOKEXPORT_DATA_EXPORT_TIME .. MurlokExport["timestamp"])
	self:RegisterForDrag("LeftButton")
	self.ClassListFrame:OnLoad()
	self.TalentsListFrame:OnLoad()
	self.TraitsTreeFrame:OnLoad()
	self.EquipmentsListFrame:OnLoad()
end

function UIMurlokExportMixin:SetTabs(numTabs, ...)
	self.numTabs = numTabs

	local frameName = self:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName .. "CoreTab" .. i, self, "PanelTabButtonTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", function() self:TabOnClick(tab) end)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 300, 2)
		else
			tab:SetPoint("TOPLEFT", _G[frameName .. "CoreTab" .. (i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

function UIMurlokExportMixin:SetTabsShown(isShown)
	local frameName = self:GetName()
	for i = 1, self.numTabs do
		local tab = _G[frameName .. "CoreTab" .. i]
		if tab then
			tab:SetShown(isShown)
		end
	end
end

function UIMurlokExportMixin:SelectedTabOnClick()
	local tabId = 1
	if self.selectedTab and self.selectedTab > 0 then
		tabId = self.selectedTab
	end
	self:TabOnClick(_G[self:GetName() .. "CoreTab" .. tabId])
end

function UIMurlokExportMixin:GetTabByText(text)
	for i = 1, self.numTabs do
		if self.Tabs[i]:GetText() == text then
			return self.Tabs[i]
		end
	end
end

function UIMurlokExportMixin:TabOnClick(tab)
	PanelTemplates_SetTab(self, tab:GetID())
	local activeFrame
	if tab:GetID() == 1 then
		activeFrame = self.StatsFrame
		self.TalentsListFrame:Hide()
		self.TraitsTreeFrame:Hide()
		self.EquipmentsListFrame:Hide()
	elseif tab:GetID() == 2 then
		activeFrame = self.TalentsListFrame
		self.StatsFrame:Hide()
		self.TraitsTreeFrame:Hide()
		self.EquipmentsListFrame:Hide()
	elseif tab:GetID() == 3 then
		activeFrame = self.TraitsTreeFrame
		self.StatsFrame:Hide()
		self.TalentsListFrame:Hide()
		self.EquipmentsListFrame:Hide()
	elseif tab:GetID() == 4 then
		activeFrame = self.EquipmentsListFrame
		self.StatsFrame:Hide()
		self.TalentsListFrame:Hide()
		self.TraitsTreeFrame:Hide()
	end
	activeFrame:Show()
	activeFrame:SetSize(425, 520)
	activeFrame:ClearAllPoints()
	activeFrame:SetPoint("TOPLEFT", self.ClassListFrame, "TOPRIGHT", 25, 0)
end

function UIMurlokExportMixin:OnManualMaximizeClicked()
	MurlokExportConfig.CompactView = false
	self:UpdateView()
end

function UIMurlokExportMixin:OnManualMinimizeClicked()
	MurlokExportConfig.CompactView = true
	self:UpdateView()
end

function UIMurlokExportMixin:UpdateView()
	self:SetTabsShown(MurlokExportConfig.CompactView)
	if MurlokExportConfig.CompactView then
		self:SetWidth(math.max(740, self:GetWidth() - 900))
		self:SelectedTabOnClick()
	else
		self:SetWidth(math.min(1640, self:GetWidth() + 900))
		self.StatsFrame:Show()
		self.StatsFrame:ClearAllPoints()
		self.StatsFrame:SetSize(450, 225)
		self.StatsFrame:SetPoint("TOPLEFT", self.ClassListFrame, "TOPRIGHT", 25, 0)
		self.StatsFrame:SetPoint("BOTTOMRIGHT", self.ClassListFrame, "BOTTOMRIGHT", 450, 275)

		self.TalentsListFrame:Show()
		self.TalentsListFrame:ClearAllPoints()
		self.TalentsListFrame:SetSize(450, 250)
		self.TalentsListFrame:SetPoint("TOPLEFT", self.StatsFrame, "BOTTOMLEFT", 0, -25)
		self.TalentsListFrame:SetPoint("BOTTOMRIGHT", self.ClassListFrame, "BOTTOMRIGHT", 450, 0)

		self.TraitsTreeFrame:Show()
		self.TraitsTreeFrame:ClearAllPoints()
		self.TraitsTreeFrame:SetSize(450, 520)
		self.TraitsTreeFrame:SetPoint("TOPLEFT", self.StatsFrame, "TOPRIGHT", 25, 0)
		self.TraitsTreeFrame:SetPoint("BOTTOMRIGHT", self.TalentsListFrame, "BOTTOMRIGHT", 450, 0)

		self.EquipmentsListFrame:Show()
		self.EquipmentsListFrame:ClearAllPoints()
		self.EquipmentsListFrame:SetSize(450, 520)
		self.EquipmentsListFrame:SetPoint("TOPLEFT", self.TraitsTreeFrame, "TOPRIGHT", 25, 0)
		self.EquipmentsListFrame:SetPoint("BOTTOMRIGHT", self.TraitsTreeFrame, "BOTTOMRIGHT", 450, 0)
	end
end

function UIMurlokExportMixin:OnShow()
	C_AddOns.LoadAddOn("Blizzard_PlayerSpells")

	if MurlokExportConfig.CompactView then
		self.MaximizeMinimizeButton:Minimize(false, false)
	else
		self.MaximizeMinimizeButton:Maximize(false, false)
	end

	self.ClassListFrame:OnShow()
end