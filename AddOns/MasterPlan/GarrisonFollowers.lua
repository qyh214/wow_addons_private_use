local _, T = ...
if T.Mark ~= 23 then return end
local G, L = T.Garrison, T.L
local countFreeFollowers = G.countFreeFollowers

local mechanicsFrame = CreateFrame("Frame")
mechanicsFrame:SetSize(1,1) mechanicsFrame:Hide()
local floatingMechanics = CreateFrame("Frame", nil, mechanicsFrame)
floatingMechanics:EnableMouse(true)
local CreateMechanicButton do
	local function Mechanic_OnEnter(self)
		local ci, finfo = self.info, G.GetFollowerInfo()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		if self.isTrait then
			G.SetTraitTooltip(GameTooltip, self.id, ci)
		elseif self.isTraitGroup then
			floatingMechanics:SetOwner(self, ci, finfo)
			return
		elseif self.isDouble then
			local ico = "|T" .. self.Icon:GetTexture() .. ":0:0:0:0:64:64:4:60:4:60|t "
			GameTooltip:AddLine(ico .. self.name)
			for i=1,ci and #ci or 0 do
				GameTooltip:AddDoubleLine(G.GetFollowerLevelDescription(ci[i], nil, finfo[ci[i]]), G.GetOtherCounterIcons(finfo[ci[i]], self.id), 1,1,1)
			end
			if (ci and #ci or 0) == 0 then
				GameTooltip:AddLine(L"You have no followers with duplicate counter combinations.", 1,1,1, 1)
			end
		else
			G.SetThreatTooltip(GameTooltip, self.id, ci)
		end
		GameTooltip:Show()
		if GameTooltip:GetRight() > GarrisonMissionFrame:GetRight() then
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
		end
	end
	local function Mechanic_OnLeave(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end
	local function Mechanic_OnClick(self)
		local nt = self.name or (self.info and self.info.name)
		local sb = GarrisonMissionFrameFollowers.SearchBox:IsVisible() and GarrisonMissionFrameFollowers.SearchBox or
		           GarrisonLandingPage.FollowerList.SearchBox:IsVisible() and GarrisonLandingPage.FollowerList.SearchBox

		if sb and nt then
			if IsAltKeyDown() then
				nt = "+" .. nt
			end
			if IsShiftKeyDown() then
				local ot = (sb:GetText() or ""):match("[^;]*$")
				if ot and ot ~= "" then
					nt = ot .. ";" .. nt
				end
			end
			sb:SetText(nt)
			sb.clearText = nt
		end
	end
	function CreateMechanicButton(parent)
		local f = CreateFrame("Button", nil, parent, "GarrisonAbilityCounterTemplate")
		f:SetNormalFontObject(GameFontHighlightOutline) f:SetText("0")
		f.Count = f:GetFontString()
		f.Count:ClearAllPoints() f.Count:SetPoint("BOTTOMRIGHT", 0, 2)
		f:SetFontString(f.Count)
		f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

		f.Border:Hide()
		f:SetScript("OnClick", Mechanic_OnClick)
		f:SetScript("OnEnter", Mechanic_OnEnter)
		f:SetScript("OnLeave", Mechanic_OnLeave)
		return f
	end
	T.Mechanic_OnClick = Mechanic_OnClick
end

floatingMechanics:SetFrameStrata("DIALOG")
floatingMechanics:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
floatingMechanics:SetBackdropBorderColor(1, 0.85, 0.6)
floatingMechanics.buttons = {}
function floatingMechanics:SetOwner(owner, info, finfo)
	self.owner, self.expire = owner
	self:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 16, -2)
	self:SetSize(10 + 24 * #info, 34)
	for i=1,#info do
		local ico, ci = self.buttons[i], info[i]
		if not ico then
			ico = CreateMechanicButton(self)
			ico:SetPoint("LEFT", 24 * i - 18, 0)
			self.buttons[i] = ico
		end
		ico.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(ci.id))
		local nf = countFreeFollowers(ci, finfo)
		ico.Count:SetText(nf > 0 and nf or "")
		ico.id, ico.name, ico.isTrait, ico.info = ci.id, C_Garrison.GetFollowerAbilityName(ci.id), true, ci
		ico:Show()
	end
	for i=#info+1, #self.buttons do
		self.buttons[i]:Hide()
	end
	self:Show()
end
floatingMechanics:SetScript("OnUpdate", function(self, elapsed)
	local isOver = self:IsMouseOver(0, -6, -10, 10) or (self.owner and self.owner:IsMouseOver(2,-8,-6,6))
	if isOver then
		self.expire = nil
	else
		self.expire = (self.expire or 0.35) - elapsed
		if self.expire < 0 then
			self:Hide()
			self.expire = nil
		end
	end
end)
floatingMechanics:Hide()
GameTooltip:HookScript("OnShow", function(self)
	local owner = self:GetOwner()
	if floatingMechanics:IsShown() and owner and (owner:IsForbidden() or owner:GetParent() ~= floatingMechanics) then
		floatingMechanics:Hide()
	end
end)

local icons = setmetatable({}, {__index=function(self, k)
	local f = CreateMechanicButton(mechanicsFrame)
	f:SetPoint("LEFT", 23*k-20, 0)
	self[k] = f
	return f
end})
local traits, traitGroups = {221, 76, 77, 79, 256}, {
	{80, 236, 29, icon="Interface\\Icons\\XPBonus_Icon"},
	{63,64,65,66,67,68,69,70,71,72,73,74,75,252,253,254,255,  icon="Interface\\Icons\\PetBattle_Health", affinities=true},
	{4,36,37,38,39,40,41,42,43, 7,8,9,44,45,46,48,49, icon="Interface\\Icons\\Ability_Hunter_MarkedForDeath"},
	{52,53,54,55,56,57,58,59,60,61,62,227,231, icon="Interface\\Icons\\Trade_Engineering"},
}
local function syncTotals()
	local finfo, cinfo, tinfo, i = G.GetFollowerInfo(), G.GetCounterInfo(), G.GetFollowerTraits(), 1
	for k=1,10 do
		local _, name, tex = G.GetMechanicInfo(k)
		if tex then
			local ico = icons[i]
			ico.Icon:SetTexture(tex)
			ico.Count:SetText(cinfo[k] and countFreeFollowers(cinfo[k], finfo) or "")
			ico:Show()
			ico.id, ico.name, ico.info, i, ico.isTrait = k, name, cinfo[k], i + 1
		end
	end
	for k=1,#traits do
		local ico, tid = icons[i], traits[k]
		ico.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(tid))
		ico.Count:SetText(tinfo[tid] and countFreeFollowers(tinfo[tid], finfo) or "")
		ico.id, ico.name, ico.isTrait, ico.info, i = traits[k], C_Garrison.GetFollowerAbilityName(tid), true, tinfo[tid], i + 1
	end
	for k=1,#traitGroups do
		local ico, c, tg, m = icons[i], 0, traitGroups[k], {g=traitGroups[k]}
		for i=1,#tg do
			local tid = tg[i]
			local v = tinfo[tid] or {}
			m[#m+1], c, v.id, v.affine = v, c + countFreeFollowers(v, finfo), tid, v.affine or tg.affinities
		end
		ico.Icon:SetTexture(tg.icon or C_Garrison.GetFollowerAbilityIcon(tg[1]))
		ico.Count:SetText(c > 0 and c or "")
		ico.info, ico.isTraitGroup = m, true
		i = i + 1
	end

	local di, doubles, t = G.GetDoubleCounters(finfo), {}, {}
	for k,v in pairs(di) do
		if k > 0 and #v > 1 then
			G.sortByFollowerLevels(v, finfo)
			for i=1,#v do
				doubles[#doubles+1] = v[i]
			end
			wipe(t)
		end
	end
	local ico, cc = icons[i], countFreeFollowers(doubles, finfo)
	ico.Icon:SetTexture("Interface\\Icons\\Inv_Misc_Book_11")
	ico.Count:SetText(cc and cc > 0 and cc or "")
	ico.info, ico.name, ico.isDouble = doubles, L"Duplicate counters", true
end
GarrisonMissionFrame.FollowerTab:HookScript("OnShow", function(self)
	mechanicsFrame:SetParent(self)
	mechanicsFrame:ClearAllPoints()
	mechanicsFrame:SetPoint("LEFT", self.NumFollowers, "RIGHT", 11, 0)
	mechanicsFrame:Show()
	syncTotals()
end)
GarrisonLandingPage.FollowerTab:HookScript("OnShow", function(self)
	mechanicsFrame:SetParent(self)
	mechanicsFrame:ClearAllPoints()
	mechanicsFrame:SetPoint("LEFT", GarrisonLandingPage.HeaderBar, "LEFT", 200, 0)
	mechanicsFrame:Show()
	syncTotals()
end)
hooksecurefunc(C_Garrison, "SetFollowerInactive", function()
	C_Timer.After(0.25, syncTotals)
	C_Timer.After(1, syncTotals)
end)

local UpgradesFrame = CreateFrame("FRAME")
UpgradesFrame:SetSize(237, 42)
UpgradesFrame:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
UpgradesFrame:SetBackdropBorderColor(0.15, 1, 0.25)
UpgradesFrame:Hide()
UpgradesFrame:SetScript("OnHide", function(self)
	self:Hide()
	if self.owner and not self.owner:IsMouseOver() and self.owner.UpgradeIcon then
		self.owner.UpgradeIcon:SetAlpha(0.6)
	end
	self.owner = nil
end)
UpgradesFrame:SetScript("OnUpdate", function(self, elapsed)
	local isOver = self.owner:IsMouseOver(4,-4,-4,4) or self:IsMouseOver(4,-4,-4,4)
	if isOver then
		self.elapsed = 0
	else
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 0.5 then
			self:Hide()
		end
	end
end)
T.Evie.RegisterEvent("PLAYER_REGEN_DISABLED", function()
	UpgradesFrame:Hide()
	UpgradesFrame:SetParent(nil)
	UpgradesFrame:ClearAllPoints()
end)
T.Evie.RegisterEvent("BAG_UPDATE_DELAYED", function()
	if UpgradesFrame:IsVisible() then
		UpgradesFrame:Update()
	end
end)

local function UpgradeItem_SetItem(self, id)
	self.itemID = id
	local count, itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemCount(id), GetItemInfo(id)
	if itemName then
		self.Icon:SetTexture(itemTexture)
		self.Name:SetText(itemName)
		self.Count:SetText(count > 1 and count or "")
		self.Name:SetTextColor(GetItemQualityColor(itemQuality))
		self.ItemLevel:SetFormattedText("")
	end
	self:SetAttribute("macrotext", SLASH_STOPSPELLTARGET1 .. "\n" .. SLASH_USE1 .. " item:" .. id)
	self:Show()
end
local function UpgradeItem_OnClick(self)
	C_Garrison.CastSpellOnFollower(GarrisonMissionFrame.FollowerTab.followerID)
end
local function CreateFollowerItemHighlight(b)
	local t1, t2, t3, t4 = b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT"), b:CreateTexture(nil, "HIGHLIGHT")
	t1:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Left-Hi")
	t1:SetSize(32, 63)
	t1:SetPoint("TOPLEFT", 43, 2)
	t3:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Right-Hi")
	t3:SetSize(32, 63)
	t3:SetPoint("TOPRIGHT", 1, 2)
	t2:SetTexture("Interface\\Buttons\\UI-SilverButtonLG-Mid-Hi")
	t2:SetHeight(63)
	t2:SetPoint("LEFT", t1, "RIGHT")
	t2:SetPoint("RIGHT", t3, "LEFT")
	t4:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	t4:SetBlendMode("ADD")
	t4:SetAllPoints(b.Icon)
	return {t1, t2, t3, t4}
end
local function UpgradeItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -32)
	GameTooltip:SetItemByID(self.itemID)
	GameTooltip:Show()
end
local upgradeItems = setmetatable({}, {__index=function(self, i)
	local b = CreateFrame("Button", nil, UpgradesFrame, "GarrisonFollowerItemButtonTemplate,SecureActionButtonTemplate")
	b.Count = b:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
	b.Count:SetPoint("BOTTOMRIGHT", b.Icon, "BOTTOMRIGHT", -1, 2)
	b:SetAttribute("type", "macro")
	b:SetPoint("BOTTOM", i > 1 and self[i-1] or UpgradesFrame, i > 1 and "TOP" or "BOTTOM", 0, i > 1 and 4 or 6)
	b:SetScript("OnEnter", UpgradeItem_OnEnter)
	b:SetScript("OnLeave", GameTooltip_Hide)
	b:HookScript("OnClick", UpgradeItem_OnClick)
	CreateFollowerItemHighlight(b)
	b.Name:SetFontObject(GameFontNormal)
	b.Name:SetHeight(0)
	self[i] = b
	return b
end})
function UpgradesFrame:Update()
	local up = {G.GetUpgradeItems(self.itemLevel, self.isWeapon)}
	if #up == 0 then return self:Hide() end
	self:SetHeight(8+46*#up)
	for i=1,#up do
		UpgradeItem_SetItem(upgradeItems[i], up[i])
	end
	for i=#up+1,#upgradeItems do
		upgradeItems[i]:Hide()
	end
end
function UpgradesFrame:DisplayFor(owner, itemLevel, isWeapon)
	self:SetParent(owner)
	self.owner, self.itemLevel, self.isWeapon = owner, itemLevel, isWeapon
	self:SetPoint("BOTTOM", owner, "TOP")
	self:Show()
	UpgradesFrame:Update()
end


local function FollowerItem_OnClick(self, button)
	if InCombatLockdown() then return end
	if UpgradesFrame:IsShown() and UpgradesFrame.owner == self then
		UpgradesFrame:Hide()
	else
		UpgradesFrame:DisplayFor(self, self.itemLevel, self:GetParent().ItemWeapon == self)
		if not UpgradesFrame:IsShown() then
			self.UpgradeIcon:Hide()
		end
	end
end
local function FollowerItem_OnEnter(self)
	if self.UpgradeIcon:IsShown() then
		self.UpgradeIcon:SetAlpha(1)
		GameTooltip:AddLine(L"Click to view upgrade options")
		GameTooltip:Show()
	end
end
local function FollowerItem_OnLeave(self)
	if not UpgradesFrame:IsShown() or UpgradesFrame.owner ~= self then
		self.UpgradeIcon:SetAlpha(0.6)
	end
end
hooksecurefunc("GarrisonFollowerPage_SetItem", function(self, itemID, iLevel)
	if not self.UpgradeIcon then
		local ico = self:CreateTexture(nil, "ARTWORK")
		ico:SetSize(28, 28)
		ico:SetTexture("Interface\\LevelUp\\LevelUpTex")
		ico:SetTexCoord(unpack(SUBICON_TEXCOOR_ARROW))
		ico:SetPoint("RIGHT", -3, 0)
		ico:SetAlpha(0.6)
		self.UpgradeIcon = ico
		self:SetScript("OnMouseUp", FollowerItem_OnClick)
		self:HookScript("OnEnter", FollowerItem_OnEnter)
		self:HookScript("OnLeave", FollowerItem_OnLeave)
		self:SetScript("OnHide", FollowerItem_OnLeave)
		self.HighlightBorder = CreateFollowerItemHighlight(self)
	end
	local isWeapon = self:GetParent().ItemWeapon == self
	self.hasUpgrade = G.GetUpgradeItems(iLevel, isWeapon)
	self.UpgradeIcon:SetShown(self.hasUpgrade ~= nil)
	for i=1,#self.HighlightBorder do
		self.HighlightBorder[i]:SetShown(self.hasUpgrade)
	end
	if UpgradesFrame:IsVisible() and UpgradesFrame.owner == self then
		UpgradesFrame:DisplayFor(self, iLevel, isWeapon)
	end
end)
local function resetOnShow(self)
	if self.itemID and self.itemLevel then
		GarrisonFollowerPage_SetItem(self, self.itemID, self.itemLevel)
	end
end
GarrisonMissionFrame.FollowerTab.ItemWeapon:HookScript("OnShow", resetOnShow)
GarrisonMissionFrame.FollowerTab.ItemArmor:HookScript("OnShow", resetOnShow)
GarrisonMissionFrame.FollowerTab.ItemWeapon:HookScript("OnUpdate", function()
	local self = GarrisonMissionFrame.FollowerTab
	if self.ItemWeapon.hasUpgrade and GetItemCount(self.ItemWeapon.hasUpgrade) == 0 then
		GarrisonFollowerPage_SetItem(self.ItemWeapon, self.ItemWeapon.itemID, self.ItemWeapon.itemLevel)
	end
	if self.ItemArmor.hasUpgrade and GetItemCount(self.ItemArmor.hasUpgrade) == 0 then
		GarrisonFollowerPage_SetItem(self.ItemArmor, self.ItemArmor.itemID, self.ItemArmor.itemLevel)
	end
end)
GarrisonMissionFrame.FollowerTab.AbilitiesFrame.Counters[1]:SetScript("OnEnter", GarrisonMissionMechanic_OnEnter)
GarrisonMissionFrame.FollowerTab.AbilitiesFrame.Counters[1]:SetScript("OnLeave", function(self)
	GarrisonMissionMechanicTooltip:Hide()
end)

local function ShowPotentialAbilityTooltip(owner, classSpec, dropCounter, altTitle)
	GameTooltip:SetOwner(owner, "ANCHOR_NONE")
	return G.SetClassSpecTooltip(GameTooltip, classSpec, altTitle, dropCounter)
end
local function RecruitAbility_OnEnter(self)
	if self.abilityID == -1 then
		local cs, other, p = self.classSpec, self.otherCounter, self:GetParent()
		if p and not cs then cs, other = p.classSpec, p.otherCounter end
		if cs and ShowPotentialAbilityTooltip(self, cs, other) then
			GameTooltip:SetPoint("TOPLEFT", self.Icon, "BOTTOMRIGHT")
			GameTooltip:Show()
		end
	elseif self.abilityID and self.abilityID > 0 then
		GarrisonFollowerAbilityTooltip:ClearAllPoints()
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", self.Icon, "BOTTOMRIGHT")
		GarrisonFollowerAbilityTooltip_Show(self.abilityID)
	end
end
local function RecruitAbility_OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	else
		GarrisonFollowerAbilityTooltip:Hide()
	end
end
for i=1,3 do
	local f = GarrisonRecruitSelectFrame.FollowerSelection["Recruit" .. i]
	f.Affinity = CreateMechanicButton(f)
	f.Affinity:SetPoint("TOPRIGHT", -4, 4)
end
hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", function(waiting)
	if not waiting then
		local followers, rf = C_Garrison.GetAvailableRecruits(), GarrisonRecruitSelectFrame.FollowerSelection
		local tinfo, finfo = G.GetFollowerTraits(), G.GetFollowerInfo()
		for i=1,3 do
			local f, ff = followers[i], rf["Recruit" .. i]
			if f and ff and f.quality < 4 then
				local af = GarrisonRecruitSelectFrame_GetAbilityUIEntry(ff.Abilities, 2)
				af.abilityID, af.classSpec, af.otherCounter = -1, f.classSpec, C_Garrison.GetFollowerAbilityCounterMechanicInfo(ff.Abilities.Entries[1].abilityID)
				af.Icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
				af.Name:SetText(L"Epic Ability")
				af:SetScript("OnEnter", RecruitAbility_OnEnter)
				af:SetScript("OnLeave", RecruitAbility_OnLeave)
				af:Show()
				ff.Abilities:SetHeight(16 + 28*2)
				local afid, ico = T.Affinities[f.followerID], ff.Affinity
				if afid and afid > 0 then
					ico.id, ico.name, ico.isTrait, ico.info = afid, C_Garrison.GetFollowerAbilityName(afid), true, tinfo[afid]
					ico.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(afid) or "")
					local cnt = G.countFreeFollowers(tinfo[afid], finfo)
					ico.Count:SetText(cnt > 0 and cnt or "")
					ico:Show()
				else
					ico:Hide()
				end
			end
		end
	end
end)
local function ClassSpecFrame_OnEnter(self)
	if ShowPotentialAbilityTooltip(self, self.follower) then
		GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
		GameTooltip:Show()
	end
end
hooksecurefunc("GarrisonMissionFrame_SetFollowerPortrait", function(port, fi)
	if not (port == GarrisonMissionFrame.FollowerTab.PortraitFrame or port == GarrisonLandingPage.FollowerTab.PortraitFrame) then
		return
	end
	local p = port:GetParent()
	if fi and fi.classSpec then
		local c, hadAbilities = T.SpecCounters[fi.classSpec], fi.abilities
		if c then
			fi.abilities = fi.abilities or C_Garrison.GetFollowerAbilities(fi.followerID)
			local na, oi = 0
			for i=1,#fi.abilities do
				local a = fi.abilities[i]
				if not a.isTrait then
					oi, na = oi or i, na + 1
				end
			end

			local other = oi and C_Garrison.GetFollowerAbilityCounterMechanicInfo(fi.abilities[oi].id)
			if p then
				p.classSpec, p.otherCounter = fi.classSpec, other
			end
			
			if na < 2 and not hadAbilities then
				local at = {name=L"Epic Ability", description=L"An additional random ability is unlocked when this follower reaches epic quality.", id=-1, spec=fi.classSpec, other=other, isTrait=false, icon="Interface\\Icons\\INV_Misc_QuestionMark", counters={}}
				for i=1,#c do
					if c[i] == other then
						other = nil
					elseif not at.counters[c[i]] then
						local _, name, icon, desc = G.GetMechanicInfo(c[i])
						at.counters[c[i]] = {icon=icon, name=name, description=desc}
					end
				end
				table.insert(fi.abilities, (oi or 0) + 1, at)
			end
		end
	end
	if p and p.Class and p.ClassSpec then
		if not p.Class.HoverFrame then
			local hf = CreateFrame("Frame", nil, p)
			hf:SetAllPoints(p.Class)
			hf:SetScript("OnEnter", ClassSpecFrame_OnEnter)
			hf:SetScript("OnLeave", RecruitAbility_OnLeave)
			p.Class.HoverFrame = hf
		end
		p.Class.HoverFrame.follower = fi
		p.Class.HoverFrame:SetShown(not not p.classSpec)
	end
end)
local function FollowerPageAbility_OnEnter(self)
	local ppp = self:GetParent():GetParent():GetParent()
	self.classSpec, self.otherCounter = ppp.classSpec, ppp.otherCounter
	return RecruitAbility_OnEnter(self)
end
hooksecurefunc("GarrisonFollowerPage_ShowFollower", function(self, fid)
	local af = self.AbilitiesFrame.Abilities
	for i=1,#af do
		af[i].IconButton:SetScript("OnEnter", FollowerPageAbility_OnEnter)
		af[i].IconButton:SetScript("OnLeave", RecruitAbility_OnLeave)
	end
end)

if GarrisonThreatCountersFrame then
	GarrisonThreatCountersFrame:SetScript("OnShow", GarrisonThreatCountersFrame.Hide)
end

local function Recruiter_ShowTraitTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	G.SetTraitTooltip(GameTooltip, self.value)
	GameTooltip:Show()
end
local function Recruiter_ShowCounterTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	G.SetThreatTooltip(GameTooltip, self.value)
	GameTooltip:Show()
end
hooksecurefunc("GarrisonRecruiterFrame_Init", function(self, level)
	local lf, bn
	if level == 2 then
		lf, bn = DropDownList2, "DropDownList2Button"
	elseif level == 1 and #GarrisonRecruiterFrame.Pick.entries > 0 then
		lf, bn = DropDownList1, "DropDownList1Button"
	end
	for i=1,lf and lf.numButtons or 0 do
		local b = _G[bn .. i]
		local entry = b.arg1
		if type(entry) == "table" and entry.id then
			b.tooltipTitle, b.tooltipText = level == 2 and Recruiter_ShowTraitTooltip or Recruiter_ShowCounterTooltip
		end
	end
end)

local GarrisonFollowerList_SortFollowers = GarrisonFollowerList_SortFollowers
function _G.GarrisonFollowerList_SortFollowers(followerList)
	local searchString = followerList.SearchBox and followerList.SearchBox:GetText() or ""
	local dupQuery, lss = (L"Duplicate counters"):lower(), searchString:lower()
	
	if (searchString:match("[;+]") and searchString:match("[^%s;+]")) or (lss == dupQuery or lss == "duplicate counters") then
		local showUncollected, list, q, s = followerList.showUncollected, followerList.followersList, {}
		
		for qs in searchString:gmatch("[^;]+") do
			local pl, qs = qs:match("^%s*(%+?)%s*(.-)%s*$")
			if (qs or "") == "" then
			elseif pl == "+" then
				s = s or {}
				s[#s+1] = qs:lower():gsub("[-%%%[%]().+*?]", "%%%0")
				s[-#s] = qs
			else
				q[#q+1] = qs
			end
		end
		
		wipe(list)
		local dupSet
		for i=1, #followerList.followers do
			local fi = followerList.followers[i]
			if showUncollected or fi.isCollected then
				local matched, id, spec, filterDup = true, fi.followerID, T.SpecCounters[fi.classSpec], false
				for i=1,#q do
					local q = q[i]
					local ql = q:lower()
					if ql == dupQuery or ql == "duplicate counters" then
						filterDup = true
					elseif not C_Garrison.SearchForFollower(id, q) then
						matched = false
						break
					end
				end
				if matched and filterDup then
					if not dupSet then
						dupSet = {}
						for k,v in pairs(G.GetDoubleCounters(G.GetFollowerInfo())) do
							if k > 0 and #v > 1 then
								for i=1,#v do
									dupSet[v[i]] = 1
								end
							end
						end
					end
					matched = not not dupSet[id]
				end
				
				for i=1,s and matched and #s or 0 do
					local ok, qm = false, s[i]
					for j=1,#spec do
						local _, n, _, d = G.GetMechanicInfo(spec[j] or 10)
						if n:lower():match(qm) or d:lower():match(qm) then
							ok = true
							break
						end
					end
					if not (ok or C_Garrison.SearchForFollower(id, s[-i])) then
						matched = false
						break
					end
				end
				
				if matched then
					list[#list+1] = i
				end
			end
		end
	end
	
	return GarrisonFollowerList_SortFollowers(followerList)
end
GarrisonMissionFrameFollowers.SearchBox:SetMaxLetters(0)
GarrisonLandingPage.FollowerList.SearchBox:SetMaxLetters(0)

do -- Reroll items
	local af = GarrisonMissionFrame.FollowerTab.AbilitiesFrame
	local rb = {T.CreateLazyItemButton(af, 122274), T.CreateLazyItemButton(af, 122273), T.CreateLazyItemButton(af, 122272), (T.CreateLazyItemButton(af, 118354))}
	local function TargetFollower()
		GarrisonMissionFrame.FollowerTab.UpgradeClickTarget:Click()
	end
	for i=1,#rb do rb[i]:SetSize(24, 24) rb[i].real:SetScript("PostClick", TargetFollower) end
	hooksecurefunc("GarrisonFollowerPage_ShowFollower", function(self, id)
		local x = -16
		for i=1,#rb do
			local b = rb[i]
			if GetItemCount(b.itemID) > 0 then
				b:SetPoint("TOPRIGHT", x, -88)
				b:Show()
				x = x - 28
			else
				b:Hide()
			end
		end
	end)
	af.MPUpgradeItems = rb
end


hooksecurefunc("UIDropDownMenu_StopCounting", function(self)
	local mf = self and GetMouseFocus()
	local tt, tf = mf and mf.tooltipTitle, mf and mf.tooltipFunc
	if mf and (tt or tf) and not mf:IsForbidden() and mf:GetParent() == self then
		if type(tt) == "function" and mf.tooltipText == nil then
			mf.tooltipFunc, mf.tooltipText, tf, tt, mf.tooltipTitle = tt, tt, tt
		end
		if tf and tt == nil and mf.tooltipText == tf then
			self.tooltipOwner, self.tooltipOnLeave = mf, securecall(tf, mf, mf.arg1, mf.arg2)
		end
	end
end)
hooksecurefunc("UIDropDownMenu_StartCounting", function(self)
	if self and self.tooltipOwner and type(self.tooltipOnLeave) == "function" then
		securecall(self.tooltipOnLeave, self.tooltipOwner)
		self.tooltipOnLeave, self.tooltipOwner = nil
	end
end)