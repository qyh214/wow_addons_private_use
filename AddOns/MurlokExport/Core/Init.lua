local _, core = ...

local defaults = {
    CompactView = false,
    ShowOnlyCurrentClass = false,
    hide = false,
    minimapPos = 225
}

function core:init(event, name)
    if name == "Blizzard_PlayerSpells" then
        -- add cancel/delete button to loadouts
        local ls = PlayerSpellsFrame.TalentsFrame.LoadSystem
        local f = ls.Dropdown
        f.OnMenuOpened = function(dropdown)
            local menu = dropdown.menu
            local children = {menu:GetChildren()}
            local index = 1
            for _, child in ipairs(children) do
                if child:GetObjectType() == "Button" then
                    local id = ls.possibleSelections[index]
                    index = index + 1
                    if ls:IsSelectionIDValidAndEnabled(id) then
                        local buttons = {child:GetChildren()}
                        local cancelButton = MenuTemplates.AttachAutoHideCancelButton(child)
                        cancelButton:SetPoint("RIGHT", buttons[1], "LEFT")
                        cancelButton:SetScript("OnClick", function()
                            C_ClassTalents.DeleteConfig(id)
                            menu:Close()
                        end)
                    end
                end
            end
            f:TriggerEvent(f.Event.OnMenuOpen, f)
        end
        return
    end

	if (name ~= MURLOKEXPORT_TITLE) then return end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_ME1 = "/murlokexport"
    SLASH_ME2 = "/me"
    SlashCmdList.ME = function(msg, editBox) core:Toggle() end

    if UIMurlokExport.OptionsPanel == nil then
        local optionsPanel = CreateFrame("Frame", nil, nil, "OptionsPanelTemplate")
        optionsPanel:Register()
        UIMurlokExport.OptionsPanel = optionsPanel
    end

    MurlokExportConfig = MurlokExportConfig or CopyTable(defaults)

    core:RegisterMinimapButton()
end

UIMurlokExport:RegisterEvent("ADDON_LOADED")
UIMurlokExport:SetScript("OnEvent", core.init)