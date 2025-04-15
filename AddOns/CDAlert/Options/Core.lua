local addonName,ns = ...
local DB = ns.PlateColorDB
local L = ns.L

ns.CVarFrames = {TextFrames = {},Frames = {}}--记录CVar框体
ns.Y = {}	--用于分页行数自动拓展

local addontext = ns.RCTexts(addonName)
local PCGUI = CreateFrame("Frame")
local category = Settings.RegisterCanvasLayoutCategory(PCGUI, addontext)
Settings.RegisterAddOnCategory(category)

SlashCmdList["CDALERT"] = function()
	Settings.OpenToCategory(category:GetID())
end
SLASH_CDALERT1 = "/cda"
SLASH_CDALERT2 = "/cdalert"

ns.event("PLAYER_LOGIN", function()

--标题文本
local TiText = PCGUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
TiText:SetPoint("TOPLEFT",PCGUI,"TOPLEFT", 0, -10)
TiText:SetText(addontext)
TiText:SetFont("fonts\\ARHei.ttf", 50, "OUTLINE")
--标题文本2
local TiText2 = PCGUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
TiText2:SetPoint("BOTTOMLEFT",TiText,"BOTTOMRIGHT", 5, 8)
TiText2:SetFont("fonts\\ARHei.ttf", 20, "OUTLINE")
TiText2:SetText(L["冷却提醒"])
TiText2:SetVertexColor(1.0, 1.0, 1.0)

--版本信息
local versiontext = PCGUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
versiontext:SetPoint("TOPRIGHT", 0, 5)
versiontext:SetText("|cff00FFFF"..C_AddOns.GetAddOnMetadata(addonName,"Version"))
versiontext:SetJustifyH("RIGHT")
versiontext:SetVertexColor(0, 1, 1)


-- 创建主背景框架
local parentBackdrop = CreateFrame("Frame", "PCparentFrame", PCGUI, "BackdropTemplate")
parentBackdrop:SetSize(680, 500)
parentBackdrop:SetPoint("BOTTOMLEFT",-14,-2)
parentBackdrop:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
parentBackdrop:SetBackdropColor(0, 0, 0, 0.5)
parentBackdrop:SetBackdropBorderColor(0.7, 0.7, 0.7)

--创建ns.tabframe分页
ns.tabframe1 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe2 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe3 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe4 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe5 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe6 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe7 = CreateFrame("Frame", nil, parentBackdrop)
ns.tabframe1:SetAllPoints(parentBackdrop)
ns.tabframe2:SetAllPoints(parentBackdrop)
ns.tabframe3:SetAllPoints(parentBackdrop)
ns.tabframe4:SetAllPoints(parentBackdrop)
ns.tabframe5:SetAllPoints(parentBackdrop)
ns.tabframe6:SetAllPoints(parentBackdrop)
ns.tabframe7:SetAllPoints(parentBackdrop)
--绑定到放大按钮
ns.AddClickBC(parentBackdrop,ns.tabframe1,1,72, ABILITIES,42)
ns.AddClickBC(parentBackdrop,ns.tabframe2,2,72, ITEMS)
ns.AddClickBC(parentBackdrop,ns.tabframe3,3,72, AURAS)


--重载按钮
local reload = CreateFrame("Button", nil, PCGUI, "UIPanelButtonTemplate")
reload:SetText(L["重载"])
reload:SetWidth(92)
reload:SetHeight(22)
reload:SetPoint("BOTTOMRIGHT", -132, -31)
reload:SetScript("OnClick", function()
	 ReloadUI()
end)

--测试按钮
local csbutton = CreateFrame("Button", nil, PCGUI, "UIPanelButtonTemplate")
csbutton:SetText(L["测试"])
csbutton:SetWidth(222)
csbutton:SetHeight(22)
csbutton:SetPoint("TOPRIGHT", 0, -20)
csbutton:SetScript("OnClick", function()
	local text = "这是一段测试语音,1 2 3 4,one two three four"
	print("你点击了CDAlert的测试按钮")
	 C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
end)
--测试文本说明
local cstext = PCGUI:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
cstext:SetPoint("TOPRIGHT", 0, -45)
cstext:SetText(L["测试文本"])
cstext:SetFont("fonts\\ARHei.ttf", 15, "OUTLINE")
cstext:SetJustifyH("RIGHT")


end)