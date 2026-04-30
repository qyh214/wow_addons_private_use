
---@type details
---@diagnostic disable-next-line: undefined-field
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil
local L = detailsFramework.Language.GetLanguageTable(addonName)

local dropdownPaddingWithAlt =    "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
local dropdownPaddingWithoutAlt = "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"

function addon.CreateRunSelectorDropdown(readyFrame)
    local buildRunInfoListFromCompressed = function()
        ---@type dropdownoption[]
        local runInfoList = {}
        local headers = addon.Compress.GetHeaders()

        --get the current run showing
        local selectedRunIndex = addon.GetSelectedRunIndex()
        local playerName = UnitName("player")

		local optionIndex = 0
        for runIndex = 1, #headers do
            local thisHeader = headers[runIndex]
			if (addon.IsRunVisible(thisHeader)) then
				optionIndex = optionIndex + 1
	            local isPlayerCharacterInThisRun = true
	            local playersInThisRun = thisHeader.groupMembers
	            if (playersInThisRun) then
	                isPlayerCharacterInThisRun = playersInThisRun[playerName] and true or false
	            end

	            ---@type dropdownoption
	            local option = {
	                label = table.concat({isPlayerCharacterInThisRun and dropdownPaddingWithoutAlt or dropdownPaddingWithAlt, optionIndex, thisHeader.runId}, "@"),
	                value = runIndex,
	                onclick = function()
	                    addon.SetSelectedRunIndex(runIndex)
	                end,
	                color = isPlayerCharacterInThisRun and "white" or "gray",
	            }

	            if (runIndex == selectedRunIndex) then
	                option.statusbar = [[Interface\AddOns\Details_MythicPlus\Assets\Textures\bar_serenity]]
	                option.statusbarcolor = {0.4, 0.4, 0, 0.5}
	                option.color = "yellow"
	            end

	            runInfoList[#runInfoList+1] = option
	        end
	    end

        return runInfoList
    end

    local runInfoDropdown = detailsFramework:CreateDropDown(readyFrame, buildRunInfoListFromCompressed, addon.GetSelectedRunIndex(), addon.templates.dropdownRunSelector.width, addon.templates.dropdownRunSelector.height, "selectRunInfoDropdown", "DetailsMythicPlusRunSelectorDropdown", detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    runInfoDropdown:SetPoint("right", readyFrame.ConfigButton, "left", -3, 0)
    readyFrame.RunInfoDropdown = runInfoDropdown
    runInfoDropdown:UseSimpleHeader(true)
    runInfoDropdown:SetMenuSize(nil, addon.templates.dropdownRunSelector.dropdownHeight)

    runInfoDropdown.OnCreateOptionFrame = function(dropdown, optionFrame, optionTable)
    	if (optionFrame.columnsCreated) then
    		return
    	end

        optionFrame.label1 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label2 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label3 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label4 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label5 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label6 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.label7 = optionFrame:CreateFontString(nil, "overlay", "GameFontNormal")

        optionFrame.label1:SetPoint("left", optionFrame, "left", 5, 0)
        optionFrame.label2:SetPoint("left", optionFrame, "left", 35, 0)
        optionFrame.label3:SetPoint("left", optionFrame, "left", 220, 0)
        optionFrame.label4:SetPoint("left", optionFrame, "left", 250, 0)
        optionFrame.label5:SetPoint("left", optionFrame, "left", 295, 0)
        optionFrame.label6:SetPoint("left", optionFrame, "left", 325, 0)
        optionFrame.label7:SetPoint("left", optionFrame, "left", 410, 0)

        local fontFace, fontSize, fontFlags = optionFrame.label:GetFont()
        optionFrame.label1:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label2:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label3:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label4:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label5:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label6:SetFont(fontFace, fontSize, fontFlags)
        optionFrame.label7:SetFont(fontFace, fontSize, fontFlags)

        optionFrame.label1:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label2:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label3:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label4:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label5:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label6:SetTextColor(optionFrame.label:GetTextColor())
        optionFrame.label7:SetTextColor(optionFrame.label:GetTextColor())

        optionFrame.ExportButton = CreateFrame("Button", nil, optionFrame)
        optionFrame.ExportButton:SetSize(60, 18)
        optionFrame.ExportButton:SetNormalTexture([[Interface\AddOns\Details\images\export]]) --this image does not exists in Details
        optionFrame.ExportButton:SetPoint("right", optionFrame, "right", -5, 0)
        optionFrame.ExportButton:SetText("export")

        --make the export function pass the onenter event to the frame below it
        optionFrame.ExportButton:SetScript("OnEnter", function()
            optionFrame:GetScript("OnEnter")(optionFrame)
        end)
        optionFrame.ExportButton.label = optionFrame.ExportButton:CreateFontString(nil, "overlay", "GameFontNormal")
        optionFrame.ExportButton.label:SetPoint("left", optionFrame.ExportButton, "left", 0, 0)
        optionFrame.ExportButton.label:SetText("export")
        optionFrame.ExportButton.label:SetTextColor(1, 1, 1, 0.3)
        detailsFramework:SetFontSize(optionFrame.ExportButton.label, 10)

        optionFrame.columnsCreated = true
    end

    runInfoDropdown.OnUpdateOptionFrame = function(dropdown, optionFrame, optionTable)
        ---@type fontstring
        local index, runId = optionFrame.label:GetText():match("[M]+@(%d+)@(%d+)")
        runId = tonumber(runId)

        local header = addon.Compress.GetRunHeaderById(runId)

        --get the alt name, playerOwns is true when the player itself played the character when doing the run
        local altName = ""
        local playerName = UnitName("player")

        if (header.groupMembers) then
        	local class = header.groupMembers[header.playerName];
            if (header.playerName ~= playerName) then
                altName = detailsFramework:AddClassColorToText(header.playerName, class)
            end
        end

        optionFrame.label:SetText("")
        optionFrame.label1:SetText(index .. ".")
        if (addon.profile.developer_mode) then
            optionFrame.label2:SetText(string.format("%s (%d)", header.dungeonName, header.runId))
        else
            optionFrame.label2:SetText(header.dungeonName)
        end
        optionFrame.label3:SetText(header.keyLevel)
        optionFrame.label4:SetText(detailsFramework:IntegerToTimer(header.endTime - header.startTime))

        if (tonumber(header.keyUpgradeLevels) > 0) then
            optionFrame.label5:SetText("+" .. header.keyUpgradeLevels)
        else
            optionFrame.label5:SetText("")
        end

        optionFrame.label6:SetText(addon.ToTimeAgo(header))
        optionFrame.label7:SetText(altName ~= "0" and altName or "") --when no altName is found, it returns "0"

        optionFrame.ExportButton:SetScript("OnClick", function()
            local jsonString = addon.ExportToJson(addon.GetRunIndexById(runId))
            addon.ShowExportFrame(jsonString)
        end)
    end

    hooksecurefunc(runInfoDropdown, "Selected", function(self, thisOption)
        local index, runId = thisOption.label:match("[M]+@(%d+)@(%d+)")
        runId = tonumber(runId)
        local header = addon.Compress.GetRunHeaderById(runId)

		local dungeonName = header.dungeonName
        if (header.dungeonId == 370) then
            dungeonName = dungeonName:gsub("^.+%-", "")
        end

        self.label:SetText(index .. ". " .. dungeonName:sub(1, 22) .. " +" .. header.keyLevel .. " (" .. addon.ToTimeAgo(header) .. ")")
    end)
    --DropDownMetaFunctions:Selected(thisOption)

    runInfoDropdown.widget:HookScript("OnMouseDown", function(self)

    end)
end
