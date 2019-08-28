
local addon = TinyTooltip

local isClassicWow = GetMaxPlayerLevel() < 70

local function ParseHyperLink(link)
    local name, value = string.match(link or "", "|?H?(%a+):(%d+):")
    if (name and value) then
        return name:gsub("^([a-z])", strupper), value
    end
end

local function ShowId(tooltip, name, value, noBlankLine)
    if (not name or not value) then return end
    if (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() or addon.db.general.alwaysShowIdInfo) then
        local line = addon:FindLine(tooltip, name)
        if (not line) then
            if (not noBlankLine) then tooltip:AddLine(" ") end
            tooltip:AddLine(format("%s: |cffffffff%s|r", name, value), 0, 1, 0.8)
            --tooltip:AddDoubleLine(name .. " ID", format("|cffffffff%s|r", value))
            tooltip:Show()
        end
    end
end

local function ShowLinkIdInfo(tooltip, link)
    ShowId(tooltip, ParseHyperLink(link or select(2,tooltip:GetItem())))
end

-- keystone
local function KeystoneAffixDescription(self, link)
    link = link or select(2, self:GetItem())
    local data, name, description, AffixID
    if (link and strfind(link, "keystone:")) then
        link = link:gsub("|H(keystone:.-)|.+", "%1")
        data = {strsplit(":", link)}
        self:AddLine(" ")
        for i = 5, 8 do
            AffixID = tonumber(data[i])
            if (AffixID and AffixID > 0) then
                name, description = C_ChallengeMode.GetAffixInfo(AffixID)
                if (name and description) then
                    self:AddLine(format("|cffffcc33%s:|r%s", name, description), 0.1, 0.9, 0.1, true)
                end
            end
        end
        self:Show()
    end
end
GameTooltip:HookScript("OnTooltipSetItem", KeystoneAffixDescription)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", KeystoneAffixDescription)

-- Item
hooksecurefunc(GameTooltip, "SetHyperlink", ShowLinkIdInfo)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", ShowLinkIdInfo)
hooksecurefunc("SetItemRef", function(link) ShowLinkIdInfo(ItemRefTooltip, link) end)
GameTooltip:HookScript("OnTooltipSetItem", ShowLinkIdInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowLinkIdInfo)
ShoppingTooltip1:HookScript("OnTooltipSetItem", ShowLinkIdInfo)
ShoppingTooltip2:HookScript("OnTooltipSetItem", ShowLinkIdInfo)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", ShowLinkIdInfo)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", ShowLinkIdInfo)

-- Spell
GameTooltip:HookScript("OnTooltipSetSpell", function(self) ShowId(self, "Spell", (select(2,self:GetSpell()))) end)
hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...) ShowId(self, "Spell", (select(10,UnitAura(...)))) end)
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...) ShowId(self, "Spell", (select(10,UnitBuff(...)))) end)
hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...) ShowId(self, "Spell", (select(10,UnitDebuff(...)))) end)
if (not isClassicWow) then
    hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(self, powerID)
        ShowId(self, "Power", powerID)
        ShowId(self, "Spell", C_ArtifactUI.GetPowerInfo(powerID).spellID, 1)
    end)
end

-- Quest
if (QuestMapLogTitleButton_OnEnter) then
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        if (self.questID) then ShowId(GameTooltip, "Quest", self.questID) end
    end)
end

-- Achievement UI
local function ShowAchievementId(self)
    if ((IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() or addon.db.general.alwaysShowIdInfo) and self.id) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -32)
        GameTooltip:SetText("|cffffdd22Achievement:|r " .. self.id, 0, 1, 0.8)
        GameTooltip:Show()
    end
end

hooksecurefunc("HybridScrollFrame_CreateButtons", function(self, buttonTemplate)
    if (buttonTemplate == "StatTemplate") then
        for _, button in pairs(self.buttons) do
            button:HookScript("OnEnter", ShowAchievementId)
        end
    elseif (buttonTemplate == "AchievementTemplate") then
        for _, button in pairs(self.buttons) do
            button:HookScript("OnEnter", ShowAchievementId)
            button:HookScript("OnLeave", GameTooltip_Hide)
        end
    end
end)
