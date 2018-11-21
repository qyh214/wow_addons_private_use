local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

local MovAny = _G.MovAny
local MOVANY = _G.MOVANY

local cats = {
	{name = "Achievements & Quests"},
	{name = "Arena"},
	{name = "Blizzard Action Bars"},
	{name = "Blizzard Bags"},
	{name = "Blizzard Bank and VoidStorage"},
	{name = "Blizzard Bottom Bar"},
	{name = "Battlegrounds & PvP"},
	{name = "Class Specific"},
	{name = "Dungeons & Raids"},
	{name = "Boss Specific Frames"},
	{name = "Game Menu"},
	{name = "Garrison"},
	{name = "Shipyard"},
	{name = "Order Hall"},
	{name = "Guild"},
	{name = "Info Panels"},
	{name = "Loot"},
	{name = "Map"},
	{name = "Minimap"},
	{name = "Miscellaneous"},
	{name = "MoveAnything"},
	{name = "Unit: Focus"},
	{name = "Unit: Party"},
	{name = "Unit: Pet"},
	{name = "Unit: Player"},
	{name = "Unit: Target"},
	{name = "Vehicle"},
	{name = "PetBattle"},
	{name = "Store"},
}

local API

local m = {
	Enable = function(self)
		API = MovAny.API
		self:LoadList()
		MovAny:DeleteModule(self)
		API = nil
		--m = nil
	end,
	LoadList = function(self)
		API.default = true
		for i, c in ipairs(cats) do
			API:AddCategory(c)
		end
		cats = nil
		local c, e
		c = API:GetCategory("Achievements & Quests")
		API:AddElement({name = "AchievementFrame", displayName = "Achievements"}, c)
		API:AddElement({name = "AchievementAlertFrame1", displayName = "Achievement Alert 1", runOnce = AchievementFrame_LoadUI, create = "AchievementAlertFrameTemplate"}, c)
		API:AddElement({name = "AchievementAlertFrame2", displayName = "Achievement Alert 2", runOnce = AchievementFrame_LoadUI, create = "AchievementAlertFrameTemplate"}, c)
		API:AddElement({name = "CriteriaAlertFrame1", displayName = "Criteria Alert 1", create = "CriteriaAlertFrameTemplate"}, c)
		API:AddElement({name = "CriteriaAlertFrame2", displayName = "Criteria Alert 2", create = "CriteriaAlertFrameTemplate"}, c)
		local gcaf = API:AddElement({name = "GuildChallengeAlertFrame", displayName = "Guild Challenge Achievement Alert"}, c)
		API:AddElement({name = "ObjectiveTrackerFrameMover", displayName = "Objectives Window", scaleWH = 1}, c)
		API:AddElement({name = "ObjectiveTrackerFrameScaleMover", displayName = "Objectives Window Scale"}, c)
		API:AddElement({name = "ObjectiveTrackerBonusBannerFrame", displayName = "Objectives Banner Frame"}, c)
		--[[local qldf = API:AddElement({name = "QuestLogDetailFrame", displayName = "Quest Details", runOnce = function()
			if not QuestLogDetailFrame:IsShown() then
				ShowUIPanel(QuestLogDetailFrame)
				HideUIPanel(QuestLogDetailFrame)
			end
		end}, c)]]
		API:AddElement({name = "QuestLogPopupDetailFrame", displayName = "Quest Details"}, c)
		API:AddElement({name = "QuestNPCModel", displayName = "Quest Log NPC Model"}, c)
		--local qlf = API:AddElement({name = "QuestLogFrame", displayName = "Quest Log"}, c)
		local qf = API:AddElement({name = "QuestFrame", displayName = "Quest Offer / Return", runOnce = function()
			hooksecurefunc(QuestFrame, "Show", function()
				if MovAny:IsModified("QuestFrame") then
					HideUIPanel(GossipFrame)
				end
			end)
			hooksecurefunc("DeclineQuest", function()
				HideUIPanel(GossipFrame)
			end)
		end}, c)
		API:AddElement({name = "QuestChoiceFrame", displayName = "Quest Choice Frame"}, c)
		API:AddElement({name = "WorldQuestCompleteAlertFrame", displayName = "World Quest Complete Alert"}, c)
		API:AddElement({name = "TalkingHeadFrame", displayName = "Quest Talking Head Frame", runOnce = TalkingHead_LoadUI}, c)
		--API:AddElement({name = "QuestTimerFrame", displayName = "Quest Timer"}, c)
		c = API:GetCategory("Arena")
		--API:AddElement({name = "ArenaEnemyFrames", displayName = "ArenaEnemyFrames", noScale = 1}, c)
		--API:AddElement({name = "ArenaPrepFrames", displayName = "ArenaPrepFrames", noScale = 1}, c)
		API:AddElement({name = "ArenaEnemyFrame1", displayName = "Arena Enemy 1", create = "ArenaEnemyFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame2", displayName = "Arena Enemy 2", create = "ArenaEnemyFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame3", displayName = "Arena Enemy 3", create = "ArenaEnemyFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame4", displayName = "Arena Enemy 4", create = "ArenaEnemyFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame5", displayName = "Arena Enemy 5", create = "ArenaEnemyFrameTemplate", runOnce = Arena_LoadUI}, c)
		local ttt1 = API:AddElement({name = "TimerTrackerTimer1", displayName = "Timer tracker"}, c)
		API:AddElement({name = "ArenaEnemyFrame1PetFrame", displayName = "Arena Enemy Pet 1", create = "ArenaEnemyPetFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame2PetFrame", displayName = "Arena Enemy Pet 2", create = "ArenaEnemyPetFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame3PetFrame", displayName = "Arena Enemy Pet 3", create = "ArenaEnemyPetFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame4PetFrame", displayName = "Arena Enemy Pet 4", create = "ArenaEnemyPetFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame5PetFrame", displayName = "Arena Enemy Pet 5", create = "ArenaEnemyPetFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame1CastingBar", displayName = "Arena Enemy Casting Bar 1", create = "ArenaCastingBarFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame2CastingBar", displayName = "Arena Enemy Casting Bar 2", create = "ArenaCastingBarFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame3CastingBar", displayName = "Arena Enemy Casting Bar 3", create = "ArenaCastingBarFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame4CastingBar", displayName = "Arena Enemy Casting Bar 4", create = "ArenaCastingBarFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaEnemyFrame5CastingBar", displayName = "Arena Enemy Casting Bar 5", create = "ArenaCastingBarFrameTemplate", runOnce = Arena_LoadUI}, c)
		--API:AddElement({name = "PVPTeamDetails", displayName = "Arena Team Details"}, c)
		--API:AddElement({name = "ArenaFrame", displayName = "Arena Queue List"}, c)
		--API:AddElement({name = "ArenaRegistrarFrame", displayName = "Arena Registrar"}, c)
		--API:AddElement({name = "PVPBannerFrame", displayName = "Arena Banner"}, c)
		API:AddElement({name = "ArenaPrepFrame1", displayName = "Arena Prep 1", create = "ArenaPrepFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaPrepFrame2", displayName = "Arena Prep 2", create = "ArenaPrepFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaPrepFrame3", displayName = "Arena Prep 3", create = "ArenaPrepFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaPrepFrame4", displayName = "Arena Prep 4", create = "ArenaPrepFrameTemplate", runOnce = Arena_LoadUI}, c)
		API:AddElement({name = "ArenaPrepFrame5", displayName = "Arena Prep 5", create = "ArenaPrepFrameTemplate", runOnce = Arena_LoadUI}, c)
		c = API:GetCategory("Battlegrounds & PvP")
		local pvpf = API:AddElement({name = "PVPUIFrame", displayName = "PVP Window"}, c)
		ttt1:AddCategory(c)
		--API:AddElement({name = "BattlefieldMinimap", displayName = "Battlefield Mini Map"}, c)
		--API:AddElement({name = "MiniMapBattlefieldFrame", displayName = "Battleground Minimap Button"}, c)
		API:AddElement({name = "QueueStatusMinimapButton", displayName = "Battleground Minimap Button"}, c)
		API:AddElement({name = "QueueStatusFrame", displayName = "Battleground Minimap Button Tooltip"}, c)
		--API:AddElement({name = "BattlefieldFrame", displayName = "Battleground Queue"}, c)
		API:AddElement({name = "WorldStateScoreFrame", displayName = "Battleground Scoreboard"}, c)
		API:AddElement({name = "WorldStateCaptureBar1", displayName = "Flag Capture Timer Bar", onlyOnceCreated = 1}, c)
		local wsauf = API:AddElement({name = "WorldStateAlwaysUpFrame", displayName = "Top Center Status Display", noUnanchorRelatives = 1}, c)
		API:AddElement({name = "AlwaysUpFrame1", displayName = "AlwaysUp Frame 1", create = "WorldStateAlwaysUpTemplate", onlyOnceCreated = 1}, c)
		API:AddElement({name = "AlwaysUpFrame2", displayName = "AlwaysUp Frame 2", create = "WorldStateAlwaysUpTemplate", onlyOnceCreated = 1}, c)
		API:AddElement({name = "AlwaysUpFrame3", displayName = "AlwaysUp Frame 3", create = "WorldStateAlwaysUpTemplate", onlyOnceCreated = 1}, c)
		API:AddElement({name = "PrestigeLevelUpBanner", displayName = "Prestige Banner"}, c)
		c = API:GetCategory("Blizzard Bags")
		API:AddElement({name = "BagsMover", displayName = "All Bags", noHide = 1}, c)
		API:AddElement({name = "BagButtonsMover", displayName = "Bag Buttons"}, c)
		API:AddElement({name = "BagButtonsVerticalMover", displayName = "Bag Buttons - Vertical"}, c)
		API:AddElement({name = "BagItemSearchBox", displayName = "Bag Item Search"}, c)
		API:AddElement({name = "BagItemAutoSortButton", displayName = "Clean Up Bags"}, c)
		API:AddElement({name = "BagFrame1", displayName = "Backpack"}, c)
		API:AddElement({name = "BagFrame2", displayName = "Bag 1"}, c) --refuseSync = 1
		API:AddElement({name = "BagFrame3", displayName = "Bag 2"}, c)
		API:AddElement({name = "BagFrame4", displayName = "Bag 3"}, c)
		API:AddElement({name = "BagFrame5", displayName = "Bag 4"}, c)
		--API:AddElement({name = "KeyRingFrame", displayName = "Key Ring"}, c)
		API:AddElement({name = "MainMenuBarBackpackButton", displayName = "Backpack Button"}, c)
		API:AddElement({name = "CharacterBag0Slot", displayName = "Bag Button 1"}, c)
		API:AddElement({name = "CharacterBag1Slot", displayName = "Bag Button 2"}, c)
		API:AddElement({name = "CharacterBag2Slot", displayName = "Bag Button 3"}, c)
		API:AddElement({name = "CharacterBag3Slot", displayName = "Bag Button 4"}, c)
		--API:AddElement({name = "KeyRingButton", displayName = "Key Ring Button"}, c)
		c = API:GetCategory("Blizzard Action Bars")
		API:AddElement({name = "BasicActionButtonsMover", displayName = "Action Bar", linkedScaling = {"ActionBarDownButton", "ActionBarUpButton"}}, c)
		API:AddElement({name = "BasicActionButtonsVerticalMover", displayName = "Action Bar - Vertical"}, c)
		API:AddElement({name = "MultiBarBottomLeft", displayName = "Bottom Left Action Bar"}, c)
		API:AddElement({name = "MultiBarBottomRight", displayName = "Bottom Right Action Bar"}, c)
		--[[API:AddElement({name = "MultiBarRightMovert", displayName = "Right Action Bar", run = function()
			if MovAny:IsModified("MultiBarRightHorizontalMover") then
				MovAny:ResetFrame("MultiBarRightHorizontalMover")
			end
		end}, c)]]
		API:AddElement({name = "MultiBarRightMover", displayName = "Right Action Bar"}, c)
		API:AddElement({name = "MultiBarRightHorizontalMover", displayName = "Right Action Bar - Horizontal"}, c)
		--[[API:AddElement({name = "MultiBarLeft", displayName = "Right Action Bar 2", run = function()
			if MovAny:IsModified("MultiBarLeftHorizontalMover") then
				MovAny:ResetFrame("MultiBarLeftHorizontalMover")
			end
		end}, c)]] --MultiBarLeftMover
		API:AddElement({name = "MultiBarLeftMover", displayName = "Right Action Bar 2"}, c)
		API:AddElement({name = "MultiBarLeftHorizontalMover", displayName = "Right Action Bar 2 - Horizontal"}, c)
		API:AddElement({name = "MainMenuBarPageNumber", displayName = "Action Bar Page Number"}, c)
		API:AddElement({name = "ActionBarUpButton", displayName = "Action Bar Page Up"}, c)
		API:AddElement({name = "ActionBarDownButton", displayName = "Action Bar Page Down"}, c)
		API:AddElement({name = "ExtraActionBarFrame", displayName = "Extra Action Bar"}, c)
		API:AddElement({name = "ZoneAbilityFrame", displayName = "Zone Ability"}, c)
		API:AddElement({name = "PetActionButtonsMover", displayName = "Pet Action Bar"}, c)
		API:AddElement({name = "PetActionButtonsVerticalMover", displayName = "Pet Action Bar - Vertical"}, c)
		API:AddElement({name = "StanceButtonsMover", displayName = "Stance Buttons"}, c)
		API:AddElement({name = "StanceButtonsVerticalMover", displayName = "Stance Buttons - Vertical"}, c)
		c = API:GetCategory("Blizzard Bank and VoidStorage")
		local bf = API:AddElement({name = "BankFrame", displayName = "Bank"}, c)
		API:AddElement({name = "BankItemSearchBox", displayName = "Bank Item Search"}, c)
		API:AddElement({name = "BankItemAutoSortButton", displayName = "Bank Cleanup"}, c)
		API:AddElement({name = "BankBagItemsMover", displayName = "Bank Bag Items"}, c)
		API:AddElement({name = "BankBagSlotsMover", displayName = "Bank Bag Slots"}, c)
		--[[API:AddElement({name = "BankFrameBag1", displayName = "Bank Bag Slot 1"}, c)
		API:AddElement({name = "BankFrameBag2", displayName = "Bank Bag Slot 2"}, c)
		API:AddElement({name = "BankFrameBag3", displayName = "Bank Bag Slot 3"}, c)
		API:AddElement({name = "BankFrameBag4", displayName = "Bank Bag Slot 4"}, c)
		API:AddElement({name = "BankFrameBag5", displayName = "Bank Bag Slot 5"}, c)
		API:AddElement({name = "BankFrameBag6", displayName = "Bank Bag Slot 6"}, c)
		API:AddElement({name = "BankFrameBag7", displayName = "Bank Bag Slot 7"}, c)]]
		API:AddElement({name = "BankFrameMoneyFrame", displayName = "Bank Money"}, c)
		API:AddElement({name = "BankFrameMoneyFrameGoldButton", displayName = "Bank Money Gold"}, c)
		API:AddElement({name = "BankFrameMoneyFrameSilverButton", displayName = "Bank Money Silver"}, c)
		API:AddElement({name = "BankFrameMoneyFrameCopperButton", displayName = "Bank Money Copper"}, c)
		--API:AddElement({name = "BankFrameMoneyFrameBorder", displayName = "Bank Money Border"}, c)
		--API:AddElement({name = "BankFrameMoneyFrameInset", displayName = "Bank Money Inset"}, c)
		API:AddElement({name = "BankBagFrame1", displayName = "Bank Bag 1"}, c)
		API:AddElement({name = "BankBagFrame2", displayName = "Bank Bag 2"}, c)
		API:AddElement({name = "BankBagFrame3", displayName = "Bank Bag 3"}, c)
		API:AddElement({name = "BankBagFrame4", displayName = "Bank Bag 4"}, c)
		API:AddElement({name = "BankBagFrame5", displayName = "Bank Bag 5"}, c)
		API:AddElement({name = "BankBagFrame6", displayName = "Bank Bag 6"}, c)
		API:AddElement({name = "BankBagFrame7", displayName = "Bank Bag 7"}, c)
		local gbf = API:AddElement({name = "GuildBankFrame", displayName = "Guild Bank"}, c)
		local gbt1 = API:AddElement({name = "GuildBankTab1", displayName = "Guild Bank Tab 1"}, c)
		local gbt2 = API:AddElement({name = "GuildBankTab2", displayName = "Guild Bank Tab 2"}, c)
		local gbt3 = API:AddElement({name = "GuildBankTab3", displayName = "Guild Bank Tab 3"}, c)
		local gbt4 = API:AddElement({name = "GuildBankTab4", displayName = "Guild Bank Tab 4"}, c)
		local gbt5 = API:AddElement({name = "GuildBankTab5", displayName = "Guild Bank Tab 5"}, c)
		local gbt6 = API:AddElement({name = "GuildBankTab6", displayName = "Guild Bank Tab 6"}, c)
		local gbt7 = API:AddElement({name = "GuildBankTab7", displayName = "Guild Bank Tab 7"}, c)
		local gbt8 = API:AddElement({name = "GuildBankTab8", displayName = "Guild Bank Tab 8"}, c)
		local gisb = API:AddElement({name = "GuildItemSearchBox", displayName = "Guild Bank Item Seach"}, c)
		local gbis = API:AddElement({name = "GuildBankInfoSaveButton", displayName = "Guild Bank Save Button"}, c)
		local gbfw = API:AddElement({name = "GuildBankFrameWithdrawButton", displayName = "Guild Bank Withdraw Button"}, c)
		local gbfd = API:AddElement({name = "GuildBankFrameDepositButton", displayName = "Guild Bank Deposit Button"}, c)
		local gbwm = API:AddElement({name = "GuildBankWithdrawMoneyFrame", displayName = "Guild Bank Withdraw Money"}, c)
		local gbwmg = API:AddElement({name = "GuildBankWithdrawMoneyFrameGoldButton", displayName = "Guild Bank Withdraw Money Gold"}, c)
		local gbwms = API:AddElement({name = "GuildBankWithdrawMoneyFrameSilverButton", displayName = "Guild Bank Withdraw Money Silver"}, c)
		local gbwmc = API:AddElement({name = "GuildBankWithdrawMoneyFrameCopperButton", displayName = "Guild Bank Withdraw Money Copper"}, c)
		local gbmf = API:AddElement({name = "GuildBankMoneyFrame", displayName = "Guild Bank Money"}, c)
		local gbmfg = API:AddElement({name = "GuildBankMoneyFrameGoldButton", displayName = "Guild Bank Money Gold"}, c)
		local gbmfs = API:AddElement({name = "GuildBankMoneyFrameSilverButton", displayName = "Guild Bank Money Silver"}, c)
		local gbmfc = API:AddElement({name = "GuildBankMoneyFrameCopperButton", displayName = "Guild Bank Money Copper"}, c)
		API:AddElement({name = "VoidStorageFrame", displayName = "Void Storage"}, c) --refuseSync = MOVANY.FRAME_ONLY_WHEN_VOIDSTORAGE_IS_OPEN
		c = API:GetCategory("Blizzard Bottom Bar")
		API:AddElement({name = "MainMenuBar", displayName = "Main Bar", run = function ()
			if not MovAny:IsModified(OverrideActionBar) then
				local v = _G["OverrideActionBar"]
				v:ClearAllPoints()
				v:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (UIParentGetWidth() / 2) - (v:GetWidth() / 2), 0)
			end
		end, hideList = {
			{"MainMenuBarArtFrame", "BACKGROUND","ARTWORK"},
			{"PetActionBarFrame", "OVERLAY"},
			{"StanceBarFrame", "OVERLAY"},
			{"MainMenuBar", "DISABLEMOUSE"},
			}
		}, c)
		API:AddElement({name = "MainMenuBarArtFrameLeftEndCapMover", displayName = "Left Gryphon", noScale = 1}, c)
		API:AddElement({name = "MainMenuBarArtFrameRightEndCapMover", displayName = "Right Gryphon", noScale = 1}, c)
		API:AddElement({name = "MainMenuExpBar", displayName = "Experience Bar", scaleWH = 1, hideOnScale = {
			MainMenuXPBarTexture0,
			MainMenuXPBarTexture1,
			MainMenuXPBarTexture2,
			MainMenuXPBarTexture3,
			ExhaustionTick,
			ExhaustionTickNormal,
			ExhaustionTickHighlight,
			ExhaustionLevelFillBar,
			MainMenuXPBarTextureLeftCap,
			MainMenuXPBarTextureRightCap,
			MainMenuXPBarTextureMid,
			MainMenuXPBarDiv1,
			MainMenuXPBarDiv2,
			MainMenuXPBarDiv3,
			MainMenuXPBarDiv4,
			MainMenuXPBarDiv5,
			MainMenuXPBarDiv6,
			MainMenuXPBarDiv7,
			MainMenuXPBarDiv8,
			MainMenuXPBarDiv9,
			MainMenuXPBarDiv10,
			MainMenuXPBarDiv11,
			MainMenuXPBarDiv12,
			MainMenuXPBarDiv13,
			MainMenuXPBarDiv14,
			MainMenuXPBarDiv15,
			MainMenuXPBarDiv16,
			MainMenuXPBarDiv17,
			MainMenuXPBarDiv18,
			MainMenuXPBarDiv19,
			}, runOnce = function()
				hooksecurefunc("MainMenuExpBar_SetWidth", function()
					MovAny.API:SyncElement("MainMenuExpBar")
				end)
			end
		}, c)
		API:AddElement({name = "HonorWatchBar", displayName = "Honor Bar"}, c)
		API:AddElement({name = "ArtifactWatchBar", displayName = "Artifact Bar"}, c)
		--API:AddElement({name = "MainMenuBarMaxLevelBar", displayName = "Max Level Bar Filler", noFE = 1, noScale = 1}, c)
		API:AddElement({name = "ReputationWatchBar", displayName = "Reputation Tracker Bar", runOnce = function()
			if ReputationWatchBar_Update then
				hooksecurefunc("ReputationWatchBar_Update", MovAny.hReputationWatchBar_Update)
			end
		end, scaleWH = 1, linkedScaling = {"ReputationWatchStatusBar"}, hideOnScale = {
				ReputationWatchBarTexture0,
				ReputationWatchBarTexture1,
				ReputationWatchBarTexture2,
				ReputationWatchBarTexture3,
				ReputationXPBarTexture0,
				ReputationXPBarTexture1,
				ReputationXPBarTexture2,
				ReputationXPBarTexture3,
			}
		}, c)
		API:AddElement({name = "MicroButtonsMover", displayName = "Micro Menu"}, c)
		--API:AddElement({name = "MicroButtonsSplitMover", displayName = "Micro Menu - Split"}, c)
		--API:AddElement({name = "MicroButtonsVerticalMover", displayName = "Micro Menu - Vertical"}, c)
		API:AddElement({name = "MainMenuBarVehicleLeaveButton", displayName = "Leave Vehicle Button"}, c)
		c = API:GetCategory("Class Specific")
		API:AddElement({name = "PlayerFrameAlternateManaBar", displayName = "Alternate Mana Bar"}, c)
		API:AddElement({name = "ComboPointPlayerFrame", displayName = "Combo Point Frame"}, c)
		API:AddElement({name = "RuneFrame", displayName = "Deathknight Rune Frame"}, c)
		API:AddElement({name = "PaladinPowerBarFrame", displayName = "Paladin Power Frame"}, c)
		API:AddElement({name = "MageArcaneChargesFrame", displayName = "Mage Arcane Charges Power Frame"}, c)
		API:AddElement({name = "WarlockPowerFrame", displayName = "Warlock Power Frame"}, c)
		API:AddElement({name = "MonkHarmonyBarFrameMover", displayName = "Monk Chi Frame"}, c)
		API:AddElement({name = "MonkStaggerBar", displayName = "Monk Stagger Frame"}, c)
		API:AddElement({name = "MultiCastActionBarFrame", displayName = "Shaman Totem Frame"}, c)
		API:AddElement({name = "TotemFrame", displayName = "Totem Frame"}, c)
		c = API:GetCategory("Dungeons & Raids")
		API:AddElement({name = "PVEFrame", displayName = "Dungeon Finder"}, c)
		API:AddElement({name = "EncounterJournal", displayName = "Dungeon Journal"}, c)
		--API:AddElement({name = "LFGSearchStatus", displayName = "Dungeon/Raid Finder Queue Status"}, c)
		API:AddElement({name = "ChallengesKeystoneFrame", displayName = "Challenge Keystone"}, c)
		API:AddElement({name = "DungeonCompletionAlertFrame1", displayName = "Dungeon Completion Alert"}, c)
		API:AddElement({name = "ScenarioAlertFrame1", displayName = "Scenario Completion Alert 1"}, c)
		API:AddElement({name = "ScenarioAlertFrame2", displayName = "Scenario Completion Alert 2"}, c)
		API:AddElement({name = "LevelUpDisplay", displayName = "LevelUpDisplay"}, c)
		API:AddElement({name = "QueueStatusMinimapButton", displayName = "Dungeon Status Button"}, c)
		API:AddElement({name = "QueueStatusFrame", displayName = "Dungeon Status Button Tooltip"}, c)
		API:AddElement({name = "LFGDungeonReadyDialog", displayName = "Dungeon Ready Dialog"}, c)
		API:AddElement({name = "LFGDungeonReadyPopup", displayName = "Dungeon Ready Popup"}, c)
		API:AddElement({name = "LFGDungeonReadyStatus", displayName = "Dungeon Ready Status"}, c)
		API:AddElement({name = "LFDRoleCheckPopup", displayName = "Dungeon Role Check Popup"}, c)
		API:AddElement({name = "RaidBossEmoteFrame", displayName = "Raid Boss Emote Display"}, c)
		API:AddElement({name = "Boss1TargetFrame", displayName = "Raid Boss Health Bar 1", create = "BossTargetFrameTemplate"}, c)
		API:AddElement({name = "Boss1TargetFramePowerBarAlt", displayName = "Raid Boss Power Bar 1"}, c)
		API:AddElement({name = "Boss2TargetFrame", displayName = "Raid Boss Health Bar 2", create = "BossTargetFrameTemplate"}, c)
		API:AddElement({name = "Boss2TargetFramePowerBarAlt", displayName = "Raid Boss Power Bar 2"}, c)
		API:AddElement({name = "Boss3TargetFrame", displayName = "Raid Boss Health Bar 3", create = "BossTargetFrameTemplate"}, c)
		API:AddElement({name = "Boss3TargetFramePowerBarAlt", displayName = "Raid Boss Power Bar 3"}, c)
		API:AddElement({name = "Boss4TargetFrame", displayName = "Raid Boss Health Bar 4", create = "BossTargetFrameTemplate"}, c)
		API:AddElement({name = "Boss4TargetFramePowerBarAlt", displayName = "Raid Boss Power Bar 4"}, c)
		API:AddElement({name = "Boss5TargetFrame", displayName = "Raid Boss Health Bar 5", create = "BossTargetFrameTemplate"}, c)
		API:AddElement({name = "Boss5TargetFramePowerBarAlt", displayName = "Raid Boss Power Bar 5"}, c)
		API:AddElement({name = "RaidBrowserFrame", displayName = "Other Raids"}, c)
		--API:AddElement({name = "RaidParentFrame", displayName = "Raid Finder"}, c)
		API:AddElement({name = "CompactRaidGroup1", displayName = "Raid Group 1"}, c)
		API:AddElement({name = "CompactRaidGroup2", displayName = "Raid Group 2"}, c)
		API:AddElement({name = "CompactRaidGroup3", displayName = "Raid Group 3"}, c)
		API:AddElement({name = "CompactRaidGroup4", displayName = "Raid Group 4"}, c)
		API:AddElement({name = "CompactRaidGroup5", displayName = "Raid Group 5"}, c)
		API:AddElement({name = "CompactRaidGroup6", displayName = "Raid Group 6"}, c)
		API:AddElement({name = "CompactRaidGroup7", displayName = "Raid Group 7"}, c)
		API:AddElement({name = "CompactRaidGroup8", displayName = "Raid Group 8"}, c)
		API:AddElement({name = "CompactRaidFrameManager", displayName = "Raid Manager"}, c)
		API:AddElement({name = "CompactRaidFrameManagerToggleButton", displayName = "Raid Manager Toggle Button", onlyOnceCreated = 1}, c)
		API:AddElement({name = "CompactRaidFrameBuffTooltipsMover", displayName = "Raid Frame Buff Tooltips"}, c)
		API:AddElement({name = "CompactRaidFrameDebuffTooltipsMover", displayName = "Raid Frame Debuff Tooltips"}, c)
		API:AddElement({name = "RolePollPopup", displayName = "Raid Role Popup"}, c)
		API:AddElement({name = "RaidUnitFramesMover", displayName = "Raid Unit Frames"}, c)
		API:AddElement({name = "RaidWarningFrame", displayName = "Raid Warnings"}, c)
		API:AddElement({name = "ReadyCheckFrame", displayName = "Ready Check"}, c)
		c = API:GetCategory("Boss Specific Frames")
		API:AddElement({name = "BossBanner", displayName = "Boss Banner"}, c)
		local pbab = API:AddElement({name = "PlayerPowerBarAltMover", displayName = "Player Alternative Power Bar"}, c)
		local tbab = API:AddElement({name = "TargetFramePowerBarAltMover", displayName = "Target Alternative Power Bar"}, c)
		c = API:GetCategory("Game Menu")
		API:AddElement({name = "GameMenuFrame", displayName = "Game Menu",
			hideList = {
				{"GameMenuFrame", "BACKGROUND","ARTWORK","BORDER"},
			}
		}, c)
		API:AddElement({name = "VideoOptionsFrame", displayName = "Video Options", runOnce = function()
				hooksecurefunc(VideoOptionsFrame, "Show", function()
					if MovAny:IsModified("VideoOptionsFrame") then
						HideUIPanel(GameMenuFrame)
					end
				end)
			end, positionReset = function(self, f, opt, readOnly)
		end}, c)
		API:AddElement({name = "AudioOptionsFrame", displayName = "Sound & Voice Options", runOnce = function()
			hooksecurefunc(AudioOptionsFrame, "Show", function()
				if MovAny:IsModified("AudioOptionsFrame") then
					HideUIPanel(GameMenuFrame)
				end
			end)
		end}, c)
		API:AddElement({name = "InterfaceOptionsFrame", displayName = "Interface Options", runOnce = function()
			hooksecurefunc(InterfaceOptionsFrame, "Show", function()
				if MovAny:IsModified("InterfaceOptionsFrame") then
					HideUIPanel(GameMenuFrame)
				end
			end)
		end}, c)
		API:AddElement({name = "KeyBindingFrame", displayName = "Keybinding Options"}, c)
		API:AddElement({name = "MacroFrame", displayName = "Macro Options"}, c)
		c = API:GetCategory("Garrison")
		API:AddElement({name = "GarrisonLandingPage", displayName = "Garrison Report"}, c)
		API:AddElement({name = "GarrisonLandingPageMinimapButton", displayName = "Garrison Minimap Button"}, c)
		API:AddElement({name = "GarrisonBuildingFrame", displayName = "Garrison Architect"}, c)
		API:AddElement({name = "GarrisonMissionFrame", displayName = "Garrison Missions"}, c)
		API:AddElement({name = "GarrisonMissionAlertFrame", displayName = "Garrison Mission Alert"}, c)
		API:AddElement({name = "GarrisonBuildingAlertFrame", displayName = "Garrison Building Alert"}, c)
		API:AddElement({name = "GarrisonFollowerAlertFrame", displayName = "Garrison Follower Alert"}, c)
		API:AddElement({name = "GarrisonCapacitiveDisplayFrame", displayName = "Garrison Work Order"}, c)
		API:AddElement({name = "GarrisonMonumentFrame", displayName = "Garrison Monuments"}, c)
		c = API:GetCategory("Shipyard")
		API:AddElement({name = "GarrisonShipyardFrame", displayName = "Naval Operations"}, c)
		API:AddElement({name = "GarrisonShipMissionAlertFrame", displayName = "Shipyard Mission Alert"}, c)
		API:AddElement({name = "GarrisonShipFollowerAlertFrame", displayName = "Shipyard Follower Alert"}, c)
		c = API:GetCategory("Order Hall")
		API:AddElement({name = "OrderHallCommandBar", displayName = "Order Hall Command Bar"}, c)
		API:AddElement({name = "OrderHallMissionFrame", displayName = "Order Hall Missions"}, c)
		API:AddElement({name = "OrderHallTalentFrame", displayName = "Order Hall Talents"}, c)
		API:AddElement({name = "GarrisonTalentAlertFrame", displayName = "Order Hall Talent Alert"}, c)
		c = API:GetCategory("Guild")
		API:AddElement({name = "GuildFrame", displayName = "Guild"}, c)
		gbf:AddCategory(c)
		gbt1:AddCategory(c)
		gbt2:AddCategory(c)
		gbt3:AddCategory(c)
		gbt4:AddCategory(c)
		gbt5:AddCategory(c)
		gbt6:AddCategory(c)
		gbt7:AddCategory(c)
		gbt8:AddCategory(c)
		gisb:AddCategory(c)
		gbis:AddCategory(c)
		gbfw:AddCategory(c)
		gbfd:AddCategory(c)
		gbwm:AddCategory(c)
		gbwmg:AddCategory(c)
		gbwms:AddCategory(c)
		gbwmc:AddCategory(c)
		gbmf:AddCategory(c)
		gbmfg:AddCategory(c)
		gbmfs:AddCategory(c)
		gbmfc:AddCategory(c)
		gcaf:AddCategory(c)
		API:AddElement({name = "GuildControlUI", displayName = "Guild Control"}, c)
		local lfgf = API:AddElement({name = "LookingForGuildFrame", displayName = "Guild Finder"}, c)
		--API:AddElement({name = "GuildInfoFrame", displayName = "Guild Info"}, c)
		API:AddElement({name = "GuildInviteFrame", displayName = "Guild Invite"}, c)
		--API:AddElement({name = "GuildLogContainer", displayName = "Guild Log"}, c)
		API:AddElement({name = "GuildMemberDetailFrame", displayName = "Guild Member Details"}, c)
		API:AddElement({name = "GuildRegistrarFrame", displayName = "Guild Registrar"}, c)
		c = API:GetCategory("Info Panels")
		API:AddElement({name = "UIPanelMover1", displayName = "Generic Info Panel 1 Left", noHide = 1}, c)
		API:AddElement({name = "UIPanelMover2", displayName = "Generic Info Panel 2 Center", noHide = 1}, c)
		API:AddElement({name = "UIPanelMover3", displayName = "Generic Info Panel 3 Right", noHide = 1}, c)
		bf:AddCategory(c)
		API:AddElement({name = "CharacterFrame", displayName = "Character / Reputation / Currency"}, c)
		API:AddElement({name = "DressUpFrame", displayName = "Dressing Room"}, c)
		--API:AddElement({name = "LFDParentFrame", displayName = "Dungeon Finder"}, c)
		API:AddElement({name = "ArtifactFrame", displayName = "Artifact Frame"}, c)
		API:AddElement({name = "TaxiFrame", displayName = "Flight Paths"}, c)
		API:AddElement({name = "FlightMapFrame", displayName = "Flight Map"}, c)
		lfgf:AddCategory(c)
		API:AddElement({name = "GossipFrame", displayName = "Gossip"}, c)
		API:AddElement({name = "InspectFrame", displayName = "Inspect"}, c)
		--API:AddElement({name = "LFRParentFrame", displayName = "Looking For Raid"}, c)
		--API:AddElement({name = "MacroFrame", displayName = "Macros"}, c)
		API:AddElement({name = "MailFrame", displayName = "Mailbox"}, c)
		API:AddElement({name = "MerchantFrame", displayName = "Merchant"}, c)
		API:AddElement({name = "OpenMailFrame", displayName = "Open Mail"}, c)
		API:AddElement({name = "PetStableFrame", displayName = "Pet Stable"}, c)
		API:AddElement({name = "FriendsFrame", displayName = "Social - Friends / Who / Guild / Chat / Raid"}, c)
		API:AddElement({name = "WardrobeFrame", displayName = "Transmogrification"}, c)
		pvpf:AddCategory(c)
		--qldf:AddCategory(c)
		--qlf:AddCategory(c)
		qf:AddCategory(c)
		API:AddElement({name = "SpellBookFrame", displayName = "Spellbook / Professions"}, c)
		API:AddElement({name = "ItemUpgradeFrame", displayName = "Item Upgrade"}, c)
		API:AddElement({name = "CollectionsJournal", displayName = "Collections"}, c)
		API:AddElement({name = "TabardFrame", displayName = "Tabard Design"}, c)
		API:AddElement({name = "PlayerTalentFrame", displayName = "Specialization / Talents / Glyphs", refuseSync = MOVANY.FRAME_ONLY_ONCE_OPENED}, c)
		API:AddElement({name = "TradeFrame", displayName = "Trade"}, c)
		API:AddElement({name = "ArchaeologyFrame", displayName = "Archaeology"}, c)
		API:AddElement({name = "ReforgingFrame", displayName = "Reforge"}, c)
		API:AddElement({name = "TradeSkillFrame", displayName = "Trade Skills"}, c)
		API:AddElement({name = "ClassTrainerFrame", displayName = "Class Trainer"}, c)
		API:AddElement({name = "GarrisonCapacitiveDisplayFrame", displayName = "Work Order"}, c)
		API:AddElement({name = "ReportPlayerNameDialog", displayName = "Report Player Name"}, c)
		API:AddElement({name = "ReportCheatingDialog", displayName = "Report Player Cheating"}, c)
		c = API:GetCategory("Loot")
		API:AddElement({name = "LootFrame", displayName = "Loot"}, c)
		API:AddElement({name = "AlertFrame", displayName = "Alerts Frames"}, c)
		--API:AddElement({name = "LootWonAlertFrame1", displayName = "Loot Won Alert Frame 1"}, c)
		--API:AddElement({name = "GroupLootContainer", displayName = "All Loot Roll Frame", create = "GroupLootFrameTemplate", noScale = 1}, c)
		--API:AddElement({name = "LootWonAlertMover1", displayName = "Loot Won Alert Frame1"}, c)
		--API:AddElement({name = "LootWonAlertMover2", displayName = "Loot Won Alert Frame2"}, c)
		--API:AddElement({name = "LootWonAlertMover3", displayName = "Loot Won Alert Frame3"}, c)
		--API:AddElement({name = "LootWonAlertMover4", displayName = "Loot Won Alert Frame4"}, c)
		--API:AddElement({name = "LootWonAlertMover5", displayName = "Loot Won Alert Frame5"}, c)
		--API:AddElement({name = "LootWonAlertMover6", displayName = "Loot Won Alert Frame6"}, c)
		--API:AddElement({name = "LootWonAlertMover7", displayName = "Loot Won Alert Frame7"}, c)
		--API:AddElement({name = "LootWonAlertMover8", displayName = "Loot Won Alert Frame8"}, c)
		--API:AddElement({name = "LootWonAlertMover9", displayName = "Loot Won Alert Frame9"}, c)
		--API:AddElement({name = "LootWonAlertMover10", displayName = "Loot Won Alert Frame10"}, c)
		API:AddElement({name = "BonusRollFrame", displayName = "Bonus Roll Frame", create = "BonusRollFrameTemplate"}, c)
		API:AddElement({name = "BonusRollLootWonFrame", displayName = "BonusRoll Item Won", create = "LootWonAlertFrameTemplate"}, c)
		API:AddElement({name = "BonusRollMoneyWonFrame", displayName = "BonusRoll Money Won", create = "MoneyWonAlertFrameTemplate"}, c)
		--API:AddElement({name = "MoneyWonAlertMover1", displayName = "Money Won Frame1"}, c)
		--API:AddElement({name = "MoneyWonAlertMover2", displayName = "Money Won Frame2"}, c)
		--API:AddElement({name = "MoneyWonAlertMover3", displayName = "Money Won Frame3"}, c)
		--API:AddElement({name = "MoneyWonAlertMover4", displayName = "Money Won Frame4"}, c)
		--API:AddElement({name = "MoneyWonAlertMover5", displayName = "Money Won Frame5"}, c)
		--API:AddElement({name = "MissingLootFrame", displayName = "Missing Loot Frame"}, c)
		API:AddElement({name = "GroupLootFrame1", displayName = "Loot Roll 1", create = "GroupLootFrameTemplate"}, c)
		API:AddElement({name = "GroupLootFrame2", displayName = "Loot Roll 2", create = "GroupLootFrameTemplate"}, c)
		API:AddElement({name = "GroupLootFrame3", displayName = "Loot Roll 3", create = "GroupLootFrameTemplate"}, c)
		API:AddElement({name = "GroupLootFrame4", displayName = "Loot Roll 4", create = "GroupLootFrameTemplate"}, c)
		c = API:GetCategory("Map")
		API:AddElement({name = "WorldMapFrame", displayName = "World Map"}, c)
		--API:AddElement({name = "WorldMapLevelDropDown", displayName = "Map Level"}, c)
		--API:AddElement({name = "WorldMapShowDropDown", displayName = "Map Options"}, c)
		--API:AddElement({name = "WorldMapTrackQuest", displayName = "Map Track Quest"}, c)
		--API:AddElement({name = "WorldMapPositioningGuide", displayName = "Map Coordinates"}, c)
		c = API:GetCategory("Minimap")
		API:AddElement({name = "MinimapCluster", displayName = "Minimap"}, c)
		API:AddElement({name = "MinimapBorder", displayName = "Minimap Border Texture"}, c)
		API:AddElement({name = "MinimapZoneTextButton", displayName = "Minimap Zone Text"}, c)
		API:AddElement({name = "MinimapBorderTop", displayName = "Minimap Top Border", noScale = 1}, c)
		API:AddElement({name = "MinimapBackdrop", displayName = "Minimap Round Border", noAlpha = 1, noScale = 1, hideList = {{"MinimapBackdrop", "ARTWORK"}}}, c)
		API:AddElement({name = "MinimapNorthTag", displayName = "Minimap North Indicator", noScale = 1}, c)
		API:AddElement({name = "GameTimeFrame", displayName = "Minimap Calendar Button"}, c)
		API:AddElement({name = "TimeManagerClockButton", displayName = "Minimap Clock Button"}, c)
		API:AddElement({name = "MiniMapInstanceDifficulty", displayName = "Minimap Dungeon Difficulty"}, c)
		API:AddElement({name = "GuildInstanceDifficulty", displayName = "Minimap Guild Group Flag"}, c)
		API:AddElement({name = "QueueStatusMinimapButton", displayName = "Minimap Queue Status Button"}, c)
		API:AddElement({name = "MiniMapMailFrame", displayName = "Minimap Mail Notification"}, c)
		API:AddElement({name = "MiniMapTracking", displayName = "Minimap Tracking Button"}, c)
		API:AddElement({name = "MinimapZoomIn", displayName = "Minimap Zoom In Button"}, c)
		API:AddElement({name = "MinimapZoomOut", displayName = "Minimap Zoom Out Button"}, c)
		API:AddElement({name = "MiniMapWorldMapButton", displayName = "Minimap World Map Button"}, c)
		API:AddElement({name = "BattlefieldMinimap", displayName = "Zone Minimap"}, c)
		c = API:GetCategory("Miscellaneous")
		API:AddElement({name = "ActionStaus", displayName = "Action Staus"}, c)
		API:AddElement({name = "TimeManagerFrame", displayName = "Alarm Clock"}, c)
		API:AddElement({name = "BlackMarketFrame", displayName = "Black Market Auction", runOnce = BlackMarketFrame_Show}, c)
		API:AddElement({name = "AuctionFrame", displayName = "Auction House", runOnce = function()
			local af = _G.AuctionFrame
			if not af then
				return true
			end
			local f = _G.SideDressUpFrame
			if f and not MovAny:IsModified(f) then
				f:ClearAllPoints()
				f:SetPoint("TOPLEFT", af, "TOPRIGHT", - 2, - 28)
			end
		end}, c)
		API:AddElement({name = "SideDressUpFrame", displayName = "Auction House Dressing Room"}, c)
		API:AddElement({name = "AuctionProgressFrame", displayName = "Auction Creation Progress"}, c)
		API:AddElement({name = "BarberShopFrame", displayName = "Barber Shop"}, c)
		API:AddElement({name = "BNToastFrame", displayName = "Battle.Net Popup Message"}, c)
		API:AddElement({name = "QuickJoinToastMover", displayName = "Quick Join Toast"}, c)
		API:AddElement({name = "QuickJoinToast2Mover", displayName = "Quick Join Toast 2"}, c)
		API:AddElement({name = "QuickJoinToastButton", displayName = "Quick Join Toast Button"}, c)
		API:AddElement({name = "MirrorTimer1", displayName = "BreathFatigue Bar"}, c)
		API:AddElement({name = "CalendarFrame", displayName = "Calendar"}, c)
		API:AddElement({name = "CalendarViewEventFrame", displayName = "Calendar Event"}, c)
		API:AddElement({name = "ChannelPullout", displayName = "Channel Pullout"}, c)
		API:AddElement({name = "ChatConfigFrame", displayName = "Chat Channel Configuration"}, c)
		API:AddElement({name = "ChatEditBoxesMover", displayName = "Chat Edit Box"}, c)
		API:AddElement({name = "ChatEditBoxesLengthMover", displayName = "Chat Edit Box Length", scaleWH = 1}, c)
		API:AddElement({name = "ColorPickerFrame", displayName = "Color Picker"}, c)
		API:AddElement({name = "TokenFramePopup", displayName = "Currency Options"}, c)
		API:AddElement({name = "ItemRefTooltip", displayName = "Chat Popup Tooltip"}, c)
		API:AddElement({name = "DurabilityFrame", displayName = "Durability Figure"}, c)
		API:AddElement({name = "UIErrorsFrame", displayName = "Errors & Warning Display"}, c)
		API:AddElement({name = "FramerateLabelMover", displayName = "Framerate", noScale = 1, noUnanchorRelatives = 1}, c)
		API:AddElement({name = "ItemSocketingFrame", displayName = "Gem Socketing"}, c)
		API:AddElement({name = "HelpFrame", displayName = "GM Help"}, c)
		API:AddElement({name = "LevelUpDisplay", displayName = "Level Up Display"}, c)
		API:AddElement({name = "MacroPopupFrame", displayName = "Macro Name & Icon"}, c)
		API:AddElement({name = "StaticPopup1", displayName = "Static Popup 1"}, c)
		API:AddElement({name = "StaticPopup2", displayName = "Static Popup 2"}, c)
		API:AddElement({name = "StaticPopup3", displayName = "Static Popup 3"}, c)
		API:AddElement({name = "StaticPopup4", displayName = "Static Popup 4"}, c)
		API:AddElement({name = "StreamingIcon", displayName = "Streaming Download Icon"}, c)
		API:AddElement({name = "ItemTextFrame", displayName = "Reading Materials"}, c)
		API:AddElement({name = "ReputationDetailFrame", displayName = "Reputation Details"}, c)
		API:AddElement({name = "GhostFrame", displayName = "Return to Graveyard Button"}, c)
		API:AddElement({name = "HelpOpenWebTicketButton", displayName = "Ticket Status"}, c)
		API:AddElement({name = "HelpOpenTicketButtonTutorial", displayName = "Ticket Status Tutorial"}, c)
		API:AddElement({name = "TooltipMover", displayName = "Tooltip"}, c)
		API:AddElement({name = "BagItemTooltipMover", displayName = "Tooltip - Bag Item"}, c)
		API:AddElement({name = "GuildBankItemTooltipMover", displayName = "Tooltip - Guild Bank Item"}, c)
		wsauf:AddCategory(c)
		API:AddElement({name = "TalentMicroButtonAlert", displayName = "Unsaved Talent Changes Alert"}, c)
		API:AddElement({name = "TutorialFrameAlertButton", displayName = "Tutorials Alert Button"}, c)
		API:AddElement({name = "VoiceChatTalkers", displayName = "Voice Chat Talkers"}, c)
		API:AddElement({name = "ZoneTextFrame", displayName = "Zoning Zone Text"}, c)
		API:AddElement({name = "SubZoneTextFrame", displayName = "Zoning Subzone Text"}, c)
		c = API:GetCategory("MoveAnything")
		API:AddElement({name = "MAOptions", displayName = "MoveAnything Window",
			hideList = {
				{"MAOptions", "ARTWORK","BORDER"},
			}
		}, c)
		--API:AddElement({name = "MA_FEMover", displayName = "MoveAnything Frame Editor Config", noHide = 1}, c)
		API:AddElement({name = "MANudger", displayName = "MoveAnything Nudger"}, c)
		API:AddElement({name = "GameMenuButtonMoveAnything", displayName = "MoveAnything Game Menu Button"}, c)
		c = API:GetCategory("Unit: Focus")
		API:AddElement({name = "FocusFrame", displayName = "Focus"}, c)
		API:AddElement({name = "FocusFrameTextureFramePVPIcon", displayName = "Focus PVP Icon"}, c)
		API:AddElement({name = "FocusBuffsMover", displayName = "Focus Buffs"}, c)
		API:AddElement({name = "FocusDebuffsMover", displayName = "Focus Debuffs"}, c)
		API:AddElement({name = "FocusFrameSpellBar", displayName = "Focus Casting Bar", noAlpha = 1}, c)
		API:AddElement({name = "FocusFrameToT", displayName = "Target of Focus"}, c)
		API:AddElement({name = "FocusFrameToTDebuffsMover", displayName = "Target of Focus Debuffs"}, c)
		c = API:GetCategory("Unit: Party")
		API:AddElement({name = "PartyMemberFrame1", displayName = "Party Member 1"}, c)
		API:AddElement({name = "PartyMember1DebuffsMover", displayName = "Party Member 1 Debuffs"}, c)
		API:AddElement({name = "PartyMemberFrame2", displayName = "Party Member 2"}, c)
		API:AddElement({name = "PartyMember2DebuffsMover", displayName = "Party Member 2 Debuffs"}, c)
		API:AddElement({name = "PartyMemberFrame3", displayName = "Party Member 3"}, c)
		API:AddElement({name = "PartyMember3DebuffsMover", displayName = "Party Member 3 Debuffs"}, c)
		API:AddElement({name = "PartyMemberFrame4", displayName = "Party Member 4"}, c)
		API:AddElement({name = "PartyMember4DebuffsMover", displayName = "Party Member 4 Debuffs"}, c)
		c = API:GetCategory("Unit: Pet")
		API:AddElement({name = "PetFrame", displayName = "Pet"}, c)
		API:AddElement({name = "PetCastingBarFrame", displayName = "Pet Casting Bar"}, c)
		API:AddElement({name = "PetDebuffsMover", displayName = "Pet Debuffs"}, c)
		API:AddElement({name = "PartyMemberFrame1PetFrame", displayName = "Party Pet 1"}, c)
		API:AddElement({name = "PartyMemberFrame2PetFrame", displayName = "Party Pet 2"}, c)
		API:AddElement({name = "PartyMemberFrame3PetFrame", displayName = "Party Pet 3"}, c)
		API:AddElement({name = "PartyMemberFrame4PetFrame", displayName = "Party Pet 4"}, c)
		c = API:GetCategory("Unit: Player")
		API:AddElement({name = "PlayerFrame", displayName = "Player"}, c)
		API:AddElement({name = "PlayerPVPIcon", displayName = "Player PVP Icon"}, c)
		API:AddElement({name = "PlayerRestIcon", displayName = "Player Rest Icon"}, c)
		API:AddElement({name = "PlayerRestGlow", displayName = "Player Rest Icon's Glow"}, c)
		API:AddElement({name = "PlayerAttackIcon", displayName = "Player Attack Icon"}, c)
		API:AddElement({name = "PlayerAttackGlow", displayName = "Player Attack Icon's Glow"}, c)
		API:AddElement({name = "PlayerAttackBackground", displayName = "Player Attack Icon's Background"}, c)
		API:AddElement({name = "PlayerStatusTexture", displayName = "Player Status Texture"}, c)
		API:AddElement({name = "PlayerStatusGlow", displayName = "Player Status Glow"}, c)
		API:AddElement({name = "PlayerLeaderIcon", displayName = "Player Leader Icon"}, c)
		API:AddElement({name = "PlayerMasterIcon", displayName = "Player Master Icon"}, c)
		API:AddElement({name = "PlayerBuffsMover", displayName = "Player Buffs Default"}, c)
		API:AddElement({name = "PlayerBuffsMover2", displayName = "Player Buffs From Right to Left"}, c)
		--API:AddElement({name = "ConsolidatedBuffs", displayName = "Consolidated Buffs"}, c)
		--API:AddElement({name = "ConsolidatedBuffsTooltip", displayName = "Player Buffs - Consolidated Buffs Tooltip"}, c)
		API:AddElement({name = "PlayerDebuffsMover", displayName = "Player Debuffs Default"}, c)
		API:AddElement({name = "PlayerDebuffsMover2", displayName = "Player Debuffs From Right to Left"}, c)
		API:AddElement({name = "DigsiteCompleteToastFrame", displayName = "Digsite Complete Toast Frame"}, c)
		API:AddElement({name = "ArcheologyDigsiteProgressBar", displayName = "Archeology Digsite ProgressBar"}, c)
		API:AddElement({name = "PlayerHitIndicator", displayName = "Heal/Damage Numbers"}, c)
		API:AddElement({name = "CastingBarFrame", displayName = "Casting Bar", noAlpha = 1}, c)
		API:AddElement({name = "PlayerFrameGroupIndicator", displayName = "Player Group Indicator"}, c)
		API:AddElement({name = "LossOfControlFrame", displayeName = "Loss Of Control"}, c)
		pbab:AddCategory(c)
		API:AddElement({name = "SpellActivationOverlayFrame", displayName = "Class Ability Proc"}, c)
		API:AddElement({name = "PlayerTalentFrame", displayName = "Talents / Glyphs"}, c)
		c = API:GetCategory("Unit: Target")
		API:AddElement({name = "TargetFrame", displayName = "Target"}, c)
		API:AddElement({name = "TargetFrameTextureFramePVPIcon", displayName = "Target PVP Icon"}, c)
		API:AddElement({name = "TargetBuffsMover", displayName = "Target Buffs"}, c)
		API:AddElement({name = "TargetDebuffsMover", displayName = "Target Debuffs"}, c)
		--API:AddElement({name = "ComboFrame", displayName = "Target Combo Points Display"}, c)
		API:AddElement({name = "TargetFrameSpellBar", displayName = "Target Casting Bar", noAlpha = 1}, c)
		API:AddElement({name = "TargetFrameToT", displayName = "Target of Target"}, c)
		API:AddElement({name = "TargetFrameToTDebuffsMover", displayName = "Target of Target Debuffs"}, c)
		API:AddElement({name = "TargetFrameNumericalThreat", displayName = "Target Threat Indicator"}, c)
		tbab:AddCategory(c)
		c = API:GetCategory("Vehicle")
		API:AddElement({name = "OverrideActionBar", displayName = "Vehicle Bar",
			hideList = {
				{"OverrideActionBar", "ARTWORK","BACKGROUND","BORDER","OVERLAY"},
				{"OverrideActionBarLeaveFrame", "ARTWORK","BACKGROUND","BORDER","OVERLAY"},
				--{"OverrideActionBarArtFrame", "ARTWORK","BACKGROUND","BORDER","OVERLAY"},
				--{"OverrideActionBarButtonFrame", "ARTWORK","BACKGROUND","BORDER","OVERLAY"}
			}
		}, c)
		API:AddElement({name = "OverrideActionBarExpBar", displayName = "Vehicle Experience Bar", onlyOnceCreated = 1}, c)
		API:AddElement({name = "OverrideActionButtonsMover", displayName = "Vehicle Action Bar", runOnce = function()
			OverrideActionBarButtonFrame:SetSize((OverrideActionBarButton1:GetWidth() + 2) * VEHICLE_MAX_ACTIONBUTTONS, OverrideActionBarButton1:GetHeight() + 2)
		 end}, c)
		API:AddElement({name = "OverrideActionBarHealthBar", displayName = "Vehicle Health Bar", onlyOnceCreated = 1}, c)
		API:AddElement({name = "OverrideActionBarPowerBar", displayName = "Vehicle Power Bar", onlyOnceCreated = 1}, c)
		API:AddElement({name = "OverrideActionBarLeaveFrame", displayName = "Vehicle Leave Frame"}, c)
		--API:AddElement({name = "MicroButtonsVehicleMover", displayName = "Vehicle Micro Bar"}, c)
		API:AddElement({name = "VehicleSeatIndicator", displayName = "Vehicle Seat Indicator"}, c)
		c = API:GetCategory("PetBattle")
		API:AddElement({name = "PetBattleMover7", displayName = "Top Right Art", noScale = 1}, c)
		API:AddElement({name = "PetBattleMover8", displayName = "Top Left Art", noScale = 1}, c)
		API:AddElement({name = "PetBattleMover9", displayName = "Top Left Center", noScale = 1}, c)
		API:AddElement({name = "PetBattleMover3", displayName = "Weather"},c)
		API:AddElement({name = "PetBattleMover1", displayName = "Player Pet Frame"}, c)
		API:AddElement({name = "PetBattleMover2", displayName = "Enemy Pet Frame"}, c)
		API:AddElement({name = "PetBattleMover6", displayName = "Bottom Frame"}, c)
		API:AddElement({name = "PetBattleMover5", displayName = "Pet Selection Frame"}, c)
		API:AddElement({name = "PetBattleMover4", displayName = "Pass Button"}, c)
		API:AddElement({name = "PetBattleMover11", displayName = "Ally Pet 2"}, c)
		API:AddElement({name = "PetBattleMover12", displayName = "Ally Pet 3"}, c)
		API:AddElement({name = "PetBattleMover22", displayName = "Enemy Pet 2"}, c)
		API:AddElement({name = "PetBattleMover23", displayName = "Enemy Pet 3"}, c)
		API:AddElement({name = "PetBattleMover24", displayName = "Ally Pet Buffs"}, c)
		API:AddElement({name = "PetBattleMover25", displayName = "Ally Pet Debuffs"}, c)
		API:AddElement({name = "PetBattleMover26", displayName = "Ally Pet Pad Buffs"}, c)
		API:AddElement({name = "PetBattleMover27", displayName = "Ally Pet Pad Debuffs"}, c)
		API:AddElement({name = "PetBattleMover28", displayName = "Enemy Pet Buffs"}, c)
		API:AddElement({name = "PetBattleMover29", displayName = "Enemy Pet Debuffs"}, c)
		API:AddElement({name = "PetBattleMover30", displayName = "Enemy Pet Pad Buffs"}, c)
		API:AddElement({name = "PetBattleMover31", displayName = "Enemy Pet Pad Debuffs"}, c)
		API:AddElement({name = "PetBattlePrimaryAbilityTooltip", displayName = "PetBattle Primary Ability Tooltip"}, c)
		API:AddElement({name = "PetBattlePrimaryUnitTooltip", displayName = "PetBattle Primary Unit Tooltip"}, c)
		API:AddElement({name = "BattlePetTooltip", displayName = "BattlePetTooltip"}, c)
		API:AddElement({name = "FloatingBattlePetTooltip", displayName = "FloatingBattlePetTooltip"}, c)
		API:AddElement({name = "FloatingPetBattleAbilityTooltip", displayName = "FloatingPetBattleAbilityTooltip"}, c)
		API:AddElement({name = "StartSplash", displayName = "StartSplash"}, c)
		c = API:GetCategory("Store")
		API:AddElement({name = "StorePurchaseAlertFrame", displayName = "Store Purchase Alert"}, c)
		API:AddElement({name = "ModelPreviewFrame", displayName = "Store Model Preview"}, c)
		c = API:AddCategory({name = "MA Internal Elements"})
		--API:AddElement({name = "AlwaysUpFrame1", hidden = 1, onlyOnceCreated = 1}, c)
		--API:AddElement({name = "AlwaysUpFrame2", hidden = 1, onlyOnceCreated = 1}, c)
		--API:AddElement({name = "AlwaysUpFrame3", hidden = 1, onlyOnceCreated = 1}, c)
		--API:AddElement({name = "MainMenuBarArtFrame", hidden = 1, noScale = 1}, c)
		--API:AddElement({name = "WorldMapFrame", hidden = 1, refuseSync = "Unsuppported", unsupported = 1}, c)
		API:AddElement({name = "PaperDollFrame", hidden = 1, unsupported = 1}, c)
		API.default = nil
		API.customCat = API:AddCategory({name = "Custom Frames"})
	end
}

MovAny:AddCore("FrameList", m)
