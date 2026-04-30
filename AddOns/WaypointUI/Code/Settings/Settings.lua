local env = select(2, ...)
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local Settings_Preload = env.modules:Import("@\\Settings\\Preload")
local Settings_Constructor = env.modules:Await("@\\Settings\\Constructor")
local Settings_Schema = env.modules:Await("@\\Settings\\Schema")
local Setting = env.modules:New("@\\Settings")

local SettingFrame = _G[Settings_Preload.FRAME_NAME]
local SettingsCanvas = SettingsPanel.Container.SettingsCanvas
local IsAddonLoaded = C_AddOns.IsAddOnLoaded



local isElvUILoaded = false
local selectedTabIndex = nil
local categoryId = nil

local function GetSelectedTabFrame()
    if not selectedTabIndex then return end
    return Settings_Constructor.Tabs[selectedTabIndex]
end

function Setting:OpenTabByIndex(index)
    selectedTabIndex = index

    for i = 1, #Settings_Constructor.Tabs do
        local tab = Settings_Constructor.Tabs[i]
        local tabButton = Settings_Constructor.TabButtons[i]
        local isSelected = i == index

        if isSelected and not tab:IsShown() then tab:PlayIntro() end
        tab:SetShown(isSelected)
        tabButton:SetSelected(isSelected)

        if isSelected and not tab.hasRendered then
            tab:_Render()
            tab.hasRendered = true
        end

        Settings_Constructor:Refresh(true)
    end
end



local SettingFrameAnchor = CreateFrame("Frame", nil, UIParent)
local SettingFrameInset = 8
local isInitialized = false

function Setting.OpenSettingsUI()
    if not categoryId then return end
    Settings.OpenToCategory(categoryId)
end

local function SetupSettingUI()
    Settings_Constructor:SetBuildTargetFrame(SettingFrame.Content.Container)
    Settings_Constructor:Build(Settings_Schema.SCHEMA)

    SettingFrame:SetParent(SettingFrameAnchor)
    SettingFrame:SetPoint("CENTER", SettingFrameAnchor)
    SettingFrame:SetSize(SettingFrameAnchor:GetSize())
    SettingFrame:_Render()

    Setting:OpenTabByIndex(1)
end



local function OnShow(self)
    if not isElvUILoaded then isElvUILoaded = IsAddonLoaded("ElvUI") end

    SettingFrameAnchor:ClearAllPoints()
    if isElvUILoaded then
        SettingFrameAnchor:SetAllPoints(SettingsCanvas)
    else
        SettingFrameAnchor:SetPoint("CENTER", SettingsCanvas, -SettingFrameInset, SettingFrameInset)
        SettingFrameAnchor:SetSize(math.ceil(SettingsCanvas:GetWidth() + SettingFrameInset * 2), math.ceil(SettingsCanvas:GetHeight() + SettingFrameInset / 2))
    end

    SettingFrame:Show()
    if not isInitialized then
        SetupSettingUI()
        isInitialized = true
    end
end

local function OnHide(self)
    SettingFrame:Hide()
end

local function RenderUI()
    if SettingFrame:IsShown() and isInitialized then
        SettingFrame:_Render()

        for i = 1, #Settings_Constructor.Tabs do
            Settings_Constructor.Tabs[i].hasRendered = false
        end

        local currentTab = GetSelectedTabFrame()
        if currentTab then
            currentTab.hasRendered = true
            currentTab:_Render()
        end
    end
end

SettingFrameAnchor:HookScript("OnShow", OnShow)
SettingFrameAnchor:HookScript("OnHide", OnHide)
CallbackRegistry.Add("WoWClient.OnUIScaleChanged", RenderUI)
SavedVariables.OnChange(Settings_Preload.DB_GLOBAL_NAME, "fontPath", RenderUI, 10)



local function OnAddonLoaded()
    SettingFrameAnchor:Hide()
    SettingFrame:Hide()

    local category = Settings.RegisterCanvasLayoutCategory(SettingFrameAnchor, Settings_Preload.NAME)
    Settings.RegisterAddOnCategory(category)
    categoryId = category:GetID()
end
CallbackRegistry.Add("Preload.AddonReady", OnAddonLoaded)
