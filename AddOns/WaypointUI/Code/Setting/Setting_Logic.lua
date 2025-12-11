local env                 = select(2, ...)

local SettingsCanvas      = SettingsPanel.Container.SettingsCanvas
local IsAddonLoaded       = C_AddOns.IsAddOnLoaded

local CallbackRegistry    = env.WPM:Import("wpm_modules/callback-registry")
local SavedVariables      = env.WPM:Import("wpm_modules/saved-variables")
local Setting_Shared      = env.WPM:Import("@/Setting/Shared")
local Setting_Constructor = env.WPM:Await("@/Setting/Constructor")
local Setting_Schema      = env.WPM:Await("@/Setting/Schema")
local Setting_Logic       = env.WPM:New("@/Setting/Logic")


-- Shared
--------------------------------

local isElvUILoaded = false
local SettingFrame = _G[Setting_Shared.FRAME_NAME]


-- Tab
--------------------------------

local selectedTabIndex = nil
local categoryId = nil


local function getSelectedTabFrame()
    if not selectedTabIndex then return end
    return Setting_Constructor.Tabs[selectedTabIndex]
end

function Setting_Logic:OpenTabByIndex(index)
    selectedTabIndex = index

    for i = 1, #Setting_Constructor.Tabs do
        local tab = Setting_Constructor.Tabs[i]
        local tabButton = Setting_Constructor.TabButtons[i]
        local isSelected = i == index


        if isSelected and not tab:IsShown() then tab:PlayIntro() end
        tab:SetShown(isSelected)
        tabButton:SetSelected(isSelected)


        -- Dynamic rendering, only render elements when tab is selected
        if isSelected and not tab.hasRendered then
            tab:_Render()
            tab.hasRendered = true
        end


        -- Refresh widgets
        Setting_Constructor:Refresh(true)
    end
end


-- Setup
--------------------------------

local SettingFrameAnchor = CreateFrame("Frame", nil, UIParent)
local SettingFrameInset = 8
local isSetup = false

function Setting_Logic.OpenSettingUI()
    if not categoryId then return end
    Settings.OpenToCategory(categoryId)
end

local function setupSettingUI()
    Setting_Constructor:SetBuildTargetFrame(SettingFrame.Content.Container)
    Setting_Constructor:Build(Setting_Schema.SCHEMA)

    SettingFrame:SetParent(SettingFrameAnchor)
    SettingFrame:SetPoint("CENTER", SettingFrameAnchor)
    SettingFrame:SetSize(SettingFrameAnchor:GetSize())
    SettingFrame:_Render()

    Setting_Logic:OpenTabByIndex(1)
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



    if not isSetup then
        setupSettingUI()
        isSetup = true
    end
end

local function OnHide(self)
    SettingFrame:Hide()
end

local function RenderUI()
    if SettingFrame:IsShown() and isSetup then
        SettingFrame:_Render()

        for i = 1, #Setting_Constructor.Tabs do
            Setting_Constructor.Tabs[i].hasRendered = false
        end

        local currentTab = getSelectedTabFrame()
        if currentTab then
            currentTab.hasRendered = true
            currentTab:_Render()
        end
    end
end

SettingFrameAnchor:HookScript("OnShow", OnShow)
SettingFrameAnchor:HookScript("OnHide", OnHide)
SettingFrameAnchor:SetScript("OnEvent", RenderUI)
CallbackRegistry:Add("WoWClient.OnUIScaleChanged", RenderUI)
SavedVariables.OnChange(Setting_Shared.DB_GLOBAL_NAME, "PrefFont", RenderUI, 10)



local function OnAddonLoaded()
    -- Hide frame
    SettingFrameAnchor:Hide()
    SettingFrame:Hide()

    -- Add to Blizzard in-game add-on setting page
    local category = Settings.RegisterCanvasLayoutCategory(SettingFrameAnchor, Setting_Shared.NAME)
    Settings.RegisterAddOnCategory(category)

    categoryId = category:GetID()
end
CallbackRegistry:Add("Preload.AddonReady", OnAddonLoaded)
