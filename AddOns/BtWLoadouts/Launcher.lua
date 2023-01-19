-- Create and update LDB launcher
local ADDON_NAME, Internal = ...
local L = Internal.L
local Settings = Internal.Settings

local launcher
function Internal.CreateLauncher()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    if LDB then
        local tempTooltip
        launcher = LDB:NewDataObject(ADDON_NAME, {
            type = "data source",
            label = L["BtWLoadouts"],
            icon = [[Interface\ICONS\Ability_marksmanship]],
            OnClick = function(clickedframe, button)
                if button == "LeftButton" then
                    BtWLoadoutsFrame:SetShown(not BtWLoadoutsFrame:IsShown());
                elseif button == "RightButton" then
                    if tempTooltip then
                        tempTooltip:Hide()
                    end

                    if not BtWLoadoutsMinimapButton.Menu then
                        BtWLoadoutsMinimapButton.Menu = CreateFrame("Frame", BtWLoadoutsMinimapButton:GetName().."Menu", BtWLoadoutsMinimapButton, "UIDropDownMenuTemplate");
                        UIDropDownMenu_Initialize(BtWLoadoutsMinimapButton.Menu, BtWLoadoutsMinimapMenu_Init, "MENU");
                    end

                    ToggleDropDownMenu(1, nil, BtWLoadoutsMinimapButton.Menu, clickedframe, 0, -5);
                end
            end,
            OnTooltipShow = function(tooltip)
                tempTooltip = tooltip

                tooltip:SetText(L["BtWLoadouts"], 1, 1, 1);
                tooltip:AddLine(L["Click to open BtWLoadouts.\nRight Click to enable and disable settings."], nil, nil, nil, true);
                if Internal.IsActivatingLoadout() then
                    tooltip:AddLine(" ");
                    tooltip:AddLine(L["Activating Loadout"], 1, 1, 1);
                    tooltip:AddLine(Internal.GetWaitReason())
                end

                if IsShiftKeyDown() then
                    local bossID = Internal.GetConditionBossID()
                    tooltip:AddLine(" ");
                    if bossID then
                        tooltip:AddLine(format(L["Current Condition Boss: %s (%d)"], EJ_GetEncounterInfo(bossID) or "Unknown", bossID), 1, 1, 1);
                    else
                        tooltip:AddLine(format(L["Current Condition Boss: %s (%d)"], "None", 0), 1, 1, 1);
                    end
                end

                tooltip:Show()
            end,
        })
    end
end

function Internal.UpdateLauncher(text)
    if launcher then
        launcher.text = text
    end
end
local function Reanchor(button, frame)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", button, "CENTER", 0, 0)
    frame:SetParent(button)

    return frame
end
function Internal.CreateLauncherMinimapIcon()
    if not launcher then
        return
    end

    local icon = LibStub and LibStub("LibDBIcon-1.0", true)
    if icon then
        BtWLoadoutsSettings.LDBIcon = BtWLoadoutsSettings.LDBIcon or {
            minimapPos = BtWLoadoutsSettings.minimapAngle,
        }

        BtWLoadoutsMinimapButton:SetEnabled(false)

        icon:Register(ADDON_NAME, launcher, BtWLoadoutsSettings.LDBIcon)
        icon:Refresh(ADDON_NAME)

        if ElvUI and ElvUI[1] and ElvUI[1].GetModule then
            local MB = ElvUI[1]:GetModule("MinimapButtons", true)
            if MB then
                MB:SkinMinimapButtons()
            end
        end

        local button = icon:GetMinimapButton(ADDON_NAME)

        button.Progess = Reanchor(button, BtWLoadoutsMinimapButton.Progress)
        button.CircleMask = Reanchor(button, BtWLoadoutsMinimapButton.CircleMask)
        do
            local ProgressAnim = button.Progess:CreateAnimationGroup()

            local Rotation = ProgressAnim:CreateAnimation("Rotation")
            Rotation:SetSmoothing("NONE")
            Rotation:SetDuration(1)
            Rotation:SetDegrees(-360)

            ProgressAnim:SetLooping("REPEAT")
            ProgressAnim:SetScript("OnPlay", function (self) self:GetParent():Show() end)
            ProgressAnim:SetScript("OnStop", function (self) self:GetParent():Hide() end)

            BtWLoadoutsMinimapButton.ProgressAnim = ProgressAnim
        end

        function Internal.ShowMinimap()
            icon:Show(ADDON_NAME)
        end
        function Internal.HideMinimap()
            icon:Hide(ADDON_NAME)
        end

        C_Timer.After(0, function ()
            if not Settings.minimapShown then
                icon:Hide(ADDON_NAME)
            end
        end)
    else
        BtWLoadoutsMinimapButton.isSkinned = nil
    end
end
