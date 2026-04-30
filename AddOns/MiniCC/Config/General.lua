---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
---@class GeneralConfig
local M = {}

addon.Config.General = M

function M:Build(panel)
	local contentWidth = mini.ContentWidth

	-- "MiniCC" splash title
	local titleFont = GameFontNormalHuge:GetFont()
	local titleText = panel:CreateFontString(nil, "ARTWORK")
	titleText:SetFont(titleFont, 30)
	titleText:SetText("MiniCC")
	titleText:SetTextColor(0.9, 0.2, 0.2, 1)
	titleText:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
	titleText:SetWidth(contentWidth)
	titleText:SetJustifyH("CENTER")

	local subtitleText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitleText:SetText(L["Mini addon, massive awareness."])
	subtitleText:SetTextColor(0.7, 0.7, 0.7, 1)
	subtitleText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -6)
	subtitleText:SetWidth(contentWidth)
	subtitleText:SetJustifyH("CENTER")

	local discordBox = mini:EditBox({
		Parent = panel,
		LabelText = L["Discord"],
		GetValue = function()
			return "https://discord.gg/UruPTPHHxK"
		end,
		SetValue = function(_) end,
		Width = contentWidth / 2,
	})

	discordBox.Label:SetPoint("TOP", subtitleText, "BOTTOM", 0, -verticalSpacing * 2)
	discordBox.Label:SetWidth(contentWidth / 2)
	discordBox.Label:SetJustifyH("CENTER")
	discordBox.EditBox:SetPoint("TOP", discordBox.Label, "BOTTOM", 0, -4)

	local newsDivider = mini:Divider({
		Parent = panel,
		Text = L["Important News"],
	})
	newsDivider:SetPoint("TOP", discordBox.EditBox, "BOTTOM", 0, -verticalSpacing * 2)
	newsDivider:SetPoint("LEFT", panel, "LEFT", 0, 0)
	newsDivider:SetWidth(contentWidth)

	local newsFontPath = GameFontNormal:GetFont()
	local newsText = panel:CreateFontString(nil, "ARTWORK")
	newsText:SetFont(newsFontPath, 14)
	newsText:SetTextColor(1, 1, 1, 1)
	newsText:SetWidth(contentWidth - 40)
	newsText:SetJustifyH("LEFT")
	newsText:SetText(L["With the new Blizzard restrictions in 12.0.5, this is what has changed in MiniCC.\n\nThe good news:\n* Cooldown tracking still works mostly fine in arena and dungeons.\n* Added support for multiple spell charges (e.g. 2x Pain Suppression, 2x Blur) for both friendly and enemy CDs.\n\nThe bad news:\n* Friendly externals no longer track in Raids and Battlegrounds.\n* Predictive glows are less reliable.\n* PvP kick tracking can no longer identify the kicker. Now just displays a generic icon using the shortest known enemy kick cooldown.\n\nWe've put a lot of work into this update, but there may still be issues. \nPlease report any bugs you find in our Discord so we can address them."])
	newsText:SetPoint("TOPLEFT", newsDivider, "BOTTOMLEFT", 0, -verticalSpacing)
end
