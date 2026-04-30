---@type string, Addon
local _, addon = ...
local mini = addon.Core.Framework
local L = addon.L
local verticalSpacing = mini.VerticalSpacing
local horizontalSpacing = mini.HorizontalSpacing
local config = addon.Config

---@class OtherAddonsConfig
local M = {}

config.OtherAddons = M

local cols       = 3
local iconSize   = 40
local cardPad    = 10
local cardHeight = 68

local addonName = (select(1, ...))
local iconBase  = "Interface\\AddOns\\" .. addonName .. "\\Icons\\"

local function BuildAddonCard(parent, name, description, cardWidth, icon)
	local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	card:SetSize(cardWidth, cardHeight)
	card:SetBackdrop({
		bgFile   = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 1,
	})
	card:SetBackdropColor(0.08, 0.08, 0.10, 0.6)
	card:SetBackdropBorderColor(0.25, 0.25, 0.30, 0.8)

	local iconTex = card:CreateTexture(nil, "ARTWORK")
	iconTex:SetSize(iconSize, iconSize)
	iconTex:SetPoint("LEFT", card, "LEFT", cardPad, 0)
	iconTex:SetTexture(iconBase .. icon)

	local nameLabel = card:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	nameLabel:SetPoint("LEFT",  iconTex, "RIGHT", cardPad,  8)
	nameLabel:SetPoint("RIGHT", card,    "RIGHT", -cardPad, 0)
	nameLabel:SetJustifyH("LEFT")
	nameLabel:SetText(name)

	local descLabel = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	descLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -3)
	descLabel:SetPoint("RIGHT",   card,      "RIGHT", -cardPad, 0)
	descLabel:SetJustifyH("LEFT")
	descLabel:SetText(description)
	descLabel:SetTextColor(0.72, 0.72, 0.72, 1)

	return card
end

local function BuildGrid(panel, anchorFrame, addonDefs, cardWidth)
	local firstInRow, prev

	for i, def in ipairs(addonDefs) do
		local col  = (i - 1) % cols
		local card = BuildAddonCard(panel, def.Name, L[def.Desc], cardWidth, def.Name)

		if i == 1 then
			card:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -verticalSpacing)
			firstInRow = card
		elseif col == 0 then
			card:SetPoint("TOPLEFT", firstInRow, "BOTTOMLEFT", 0, -verticalSpacing)
			firstInRow = card
		else
			card:SetPoint("TOPLEFT", prev, "TOPRIGHT", horizontalSpacing, 0)
		end

		prev = card
	end

	return firstInRow  -- first card of the last row, useful for anchoring below
end

function M:Build(panel)
	local cardWidth = math.floor((mini.ContentWidth - horizontalSpacing * (cols - 1)) / cols)

	local subtitle = mini:TextLine({
		Parent = panel,
		Text   = L["My other addons to enhance your gaming experience:"],
	})
	subtitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

	local mainAddons = {
		{ Name = "FrameSort",           Desc = "Sorts party/raid/arena frames and places you at the top/middle/bottom."    },
		{ Name = "MiniMarkers",         Desc = "Shows markers above your team mates."                                      },
		{ Name = "MiniOvershields",     Desc = "Shows overshields on frames and nameplates."                               },
		{ Name = "MiniPressRelease",    Desc = "Basically doubles your APM."                                               },
		{ Name = "MiniArenaDebuffs",    Desc = "Shows your debuffs on enemy arena frames."                                 },
		{ Name = "MiniKillingBlow",     Desc = "Plays sound effects when getting killing blows."                           },
		{ Name = "MiniMeter",           Desc = "Shows fps and ping on a draggable UI element."                             },
		{ Name = "MiniQueueTimer",      Desc = "Shows a draggable timer on your UI when in queue."                         },
		{ Name = "MiniTabTarget",       Desc = "Changes your tab key to target enemy players."                             },
		{ Name = "MiniCombatNotifier",  Desc = "Notifies you when entering or leaving combat."                             },
		{ Name = "MiniResourceDisplay", Desc = "Simple personal resource-style health + power bar you can tweak."          },
		{ Name = "MiniFader",           Desc = "Fades out certain frames including bags, micro menu, and quest tracker."   },
	}

	local lastMainRowFirst = BuildGrid(panel, subtitle, mainAddons, cardWidth)

	local url = mini:EditBox({
		Parent   = panel,
		Width    = 400,
		LabelText = "",
		GetValue = function()
			return "https://www.curseforge.com/members/verz/projects"
		end,
		SetValue = function(_) end,
	})
	url.EditBox:SetPoint("TOPLEFT", lastMainRowFirst, "BOTTOMLEFT", 4, -verticalSpacing)

	local styleSubtitle = mini:TextLine({
		Parent = panel,
		Text   = L["Other addons to customize MiniCC further:"],
	})
	styleSubtitle:SetPoint("TOPLEFT", url.EditBox, "BOTTOMLEFT", -4, -verticalSpacing)

	local styleAddons = {
		{ Name = "MiniCE",  Desc = "Customize the cooldown timers." },
		{ Name = "Masque",  Desc = "Powerful icon skinning tool."   },
	}

	BuildGrid(panel, styleSubtitle, styleAddons, cardWidth)
end
