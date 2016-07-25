-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Warehousing") -- loads the localization table
local BankUI = TSM:NewModule("BankUI", "AceEvent-3.0")
local private = {frame=nil, currentBank=nil}

function BankUI:OnEnable()
	BankUI:RegisterEvent("GUILDBANKFRAME_OPENED", function() private.currentBank = "guildbank" end)
	BankUI:RegisterEvent("BANKFRAME_OPENED", function(event) private.currentBank = "bank" end)
	BankUI:RegisterEvent("GUILDBANKFRAME_CLOSED", function() private.currentBank = nil end)
	BankUI:RegisterEvent("BANKFRAME_CLOSED", function() private.currentBank = nil end)
end

function BankUI:createTab(parent)
	if private.frame then return private.frame end
	
	local BFC = TSMAPI.GUI:GetBuildFrameConstants()
	local frameInfo = {
		type = "Frame",
		parent = parent,
		hidden = true,
		points = "ALL",
		children = {
			{
				type = "GroupTreeFrame",
				key = "groupTree",
				groupTreeInfo = {"Warehousing", "Warehousing_Bank"},
				points = {{"TOPLEFT"}, {"BOTTOMRIGHT", 0, 137}},
			},
			{
				type = "Frame",
				key = "buttonFrame",
				points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, 0}, {"BOTTOMRIGHT"}},
				children = {
					{
						type = "Button",
						key = "btnToBank",
						text = L["Move Group to Bank"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", 5, -5}, {"TOPRIGHT", -5, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnToBags",
						text = L["Move Group to Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "HLine",
						size = {0, 2},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", -5, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 5, -5}},
					},
					{
						type = "Button",
						key = "btnRestock",
						text = L["Restock Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 5, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", -5, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnReagents",
						text = L["Deposit Reagents"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", BFC.PREV, "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", BFC.PREV, "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnEmpty",
						text = L["Empty Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", "btnReagents", "BOTTOMLEFT", 0, -5}, {"TOPRIGHT", "btnReagents", "BOTTOM", -3, -5}},
						scripts = {"OnClick"},
					},
					{
						type = "Button",
						key = "btnRestore",
						text = L["Restore Bags"],
						textHeight = 16,
						size = {0, 20},
						points = {{"TOPLEFT", "btnReagents", "BOTTOM", 3, -5}, {"TOPRIGHT", "btnReagents", "BOTTOMRIGHT", 0, -5}},
						scripts = {"OnClick"},
					},
				},
			},
		},
		handlers = {
			buttonFrame = {
				btnToBank = {
					OnClick = function() TSM.move:groupTree(private.frame.groupTree:GetSelectedGroupInfo(), "bags", private.currentBank) end,
				},
				btnToBags = {
					OnClick = function() TSM.move:groupTree(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnRestock = {
					OnClick = function() TSM.move:restockGroup(private.frame.groupTree:GetSelectedGroupInfo(), private.currentBank) end,
				},
				btnReagents = {
					OnClick = function() 
						if private.currentBank == "bank" then
							if IsReagentBankUnlocked() then
								DepositReagentBank()
							else
								TSMAPI.Util:ShowStaticPopupDialog("CONFIRM_BUY_REAGENTBANK_TAB");
							end
						end
					end,
				},
				btnEmpty = {
					OnClick = function() TSM.move:EmptyRestore(private.currentBank) end,
				},
				btnRestore = {
					OnClick = function() TSM.move:EmptyRestore(private.currentBank, true) end,
				},
			},
		},
	}
	
	private.frame = TSMAPI.GUI:BuildFrame(frameInfo)

	local helpPlateInfo = {
		FramePos = { x = -5, y = 100 },
		FrameSize = { width = 275, height = 490 },
		{
			ButtonPos = { x = 115, y = -66 },
			HighLightBox = { x = 0, y = -75, width = 275, height = 27 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["These will toggle between the module specific tabs."],
		},
		{
			ButtonPos = { x = 115, y = -196 },
			HighLightBox = { x = 0, y = -103, width = 275, height = 243 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["Lists the groups with warehousing operations. Left click to select/deselect the group, Right click to expand/collapse the group."],
		},
		{
			ButtonPos = { x = 52.5, y = -335 },
			HighLightBox = { x = 0, y = -347, width = 136, height = 23 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will select all groups."],
		},
		{
			ButtonPos = { x = 182.5, y = -335 },
			HighLightBox = { x = 138, y = -347, width = 136, height = 23 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will de-select all groups."],
		},
		{
			ButtonPos = { x = -10, y = -361 },
			HighLightBox = { x = 0, y = -371, width = 275, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will move items in the selected groups from your bags to the bank."],
		},
		{
			ButtonPos = { x = 240, y = -388 },
			HighLightBox = { x = 0, y = -398, width = 275, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will move items in the selected groups from the bank to your bags."],
		},
		{
			ButtonPos = { x = -10, y = -417 },
			HighLightBox = { x = 0, y = -427, width = 275, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will move all items in the selected groups using the operation restock settings from the bank to your bags."],
		},
		{
			ButtonPos = { x = 240, y = -443 },
			HighLightBox = { x = 0, y = -453, width = 275, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will deposit all reagents to your reagent bank (if unlocked)."],
		},
		{
			ButtonPos = { x = -10, y = -470 },
			HighLightBox = { x = 0, y = -480, width = 136, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will empty the contents of your bags and move them all to the bank. It will remember what you moved so that you can use the restore button to put them back"],
		},
		{
			ButtonPos = { x = 240, y = -470 },
			HighLightBox = { x = 138, y = -480, width = 136, height = 25 },
			ToolTipDir = "RIGHT",
			ToolTipText = L["This button will restore the items to your bags from the last time you clicked empty bags."],
		},
	}

	local mainHelpBtn = CreateFrame("Button", nil, private.frame, "MainHelpPlateButton")
	mainHelpBtn:SetPoint("TOPRIGHT", private.frame, 45, 70)
	mainHelpBtn:SetScript("OnClick", function() BankUI:ToggleHelpPlate(private.frame, helpPlateInfo, mainHelpBtn, true) end)
	mainHelpBtn:SetScript("OnHide", function() if HelpPlate_IsShowing(helpPlateInfo) then BankUI:ToggleHelpPlate(private.frame, helpPlateInfo, mainHelpBtn, false) end end)

	return private.frame
end

function BankUI:ToggleHelpPlate(frame, info, btn, isUser)
	if not HelpPlate_IsShowing(info) then
		HelpPlate:SetParent(frame)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Show(info, frame, btn, isUser)
	else
		HelpPlate:SetParent(UIParent)
		HelpPlate:SetFrameStrata("DIALOG")
		HelpPlate_Hide(isUser)
	end
end