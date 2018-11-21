--[[
	MoveAnything by Wagthaa @ Earthen Ring EU
	MoP version: Resike
	FanUpdate by Alea @ Gordynni EU
	Vanilla & TBC versions by: Skrag, Jason, Vincent
]]

local _G = _G
local format = format
local getmetatable = getmetatable
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local math = math
local pairs = pairs
local print = print
local select = select
local setmetatable = setmetatable
local string = string
local table = table
local time = time
local tinsert = tinsert
local tonumber = tonumber
local tostring = tostring
local tremove = tremove
local type = type
local unpack = unpack
local xpcall = xpcall

local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local GetCVar = GetCVar
local GetMouseFocus = GetMouseFocus
local GetRealmName = GetRealmName
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsAltKeyDown = IsAltKeyDown
local IsInInstance = IsInInstance
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local RegisterStateDriver = RegisterStateDriver
local UnitName = UnitName

local UIParent = UIParent

local MOVANY = _G.MOVANY
local MAOptions

function MA_tdeepcopy(object)
	local lookup_table = { }
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = { }
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function MA_tcopy(object)
	if type(object) ~= "table" then
		return object
	end
	local new_table = { }
	for index, value in pairs(object) do
		new_table[index] = value
	end
	return setmetatable(new_table, getmetatable(object))
end

local function tlen(t)
	local i = 0
	if t ~= nil then
		for k in pairs(t) do
			i = i + 1
		end
	end
	return i
end

local API

MADB = {
	tooltips = true,
	characters = { },
	profiles = { },
}

local MovAny = {
	fVoid = function() end,
	guiLines = - 1,
	resetConfirm = "",
	bagFrames = { },
	cats = { },
	collapsed = true,
	defFrames = { },
	frames = { },
	framesCount = 0,
	framesIdx = { },
	initRun = nil,
	lastFrameName = nil,
	lSafeRelatives = { },
	lAllowedTypes = {
		["Frame"] = true,
		["FontString"] = true,
		["Texture"] = true,
		["Button"] = true,
		["CheckButton"] = true,
		["StatusBar"] = true,
		["GameTooltip"] = true,
		["MessageFrame"] = true,
		["PlayerModel"] = true,
		["ColorSelect"] = true,
		["EditBox"] = true,
		["ScrollingMessageFrame"] = true,
		["Slider"] = true,
		["Minimap"] = true
	},
	lDisallowedFrames = {
		["UIParent"] = true,
		["WorldFrame"] = true,
		["CinematicFrame"] = true,
		["ArenaPrepFrames"] = true,
		--["ArenaEnemyFrames"] = true,
		["PetBattleFrame"] = true,
		["StoreFrame"] = true
	},
	lCreateVMs = {
		"BagFrame1",
		"BagFrame2",
		"BagFrame3",
		"BagFrame4",
		"BagFrame5",
	},
	lForceProtected = {
		["ArenaPrepFrames"] = true,
		["ArenaEnemyFrames"] = true,
		["WorldStateAlwaysUpFrame"] = true,
		["AlwaysUpFrame1"] = true,
		["AlwaysUpFrame2"] = true,
		["AlwaysUpFrame3"] = true,
		["CompactRaidFrameManager"] = true,
	},
	lForcedLock = {
		["Boss1TargetFrame"] = true,
		["Boss2TargetFrame"] = true,
		["Boss3TargetFrame"] = true,
		["Boss4TargetFrame"] = true,
		["Boss5TargetFrame"] = true,
		["ActionButton1"] = true,
		--[[["ArenaEnemyFrame1"] = true,
		["ArenaEnemyFrame2"] = true,
		["ArenaEnemyFrame3"] = true,
		["ArenaEnemyFrame4"] = true,
		["ArenaEnemyFrame5"] = true,
		["ArenaPrepFrame1"] = true,
		["ArenaPrepFrame2"] = true,
		["ArenaPrepFrame3"] = true,
		["ArenaPrepFrame4"] = true,
		["ArenaPrepFrame5"] = true,
		["ArenaPrepFrames"] = true,
		["ArenaEnemyFrames"] = true,
		["ArenaEnemyFrame1PetFrame"] = true,
		["ArenaEnemyFrame2PetFrame"] = true,
		["ArenaEnemyFrame3PetFrame"] = true,
		["ArenaEnemyFrame4PetFrame"] = true,
		["ArenaEnemyFrame5PetFrame"] = true,--]]
		["PetFrame"] = true,
		--["BuffFrame"] = true,
		["MinimapCluster"] = true,
		["WorldStateAlwaysUpFrame"] = true,
		["AlwaysUpFrame1"] = true,
		["AlwaysUpFrame2"] = true,
		["AlwaysUpFrame3"] = true,
		["TargetBuffsMover"] = true,
		["TargetDebuffsMover"] = true,
		["TargetFrameToTDebuffsMover"] = true,
		["FocusBuffsMover"] = true,
		["FocusDebuffsMover"] = true,
		["FocusFrameToTDebuffsMover"] = true,
		--["TargetFrameBuff1"] = true,
		--["TargetFrameDebuff1"] = true,
	},
	lEnableMouse = {
		ObjectiveTrackerFrameMover,
		ObjectiveTrackerFrameScaleMover,
		DurabilityFrame,
		CastingBarFrame,
		WorldStateScoreFrame,
		WorldStateAlwaysUpFrame,
		AlwaysUpFrame1,
		AlwaysUpFrame2,
		AlwaysUpFrame3,
		WorldStateCaptureBar1,
		VehicleMenuBar,
		TargetFrameSpellBar,
		FocusFrameSpellBar,
		MirrorTimer1,
		MiniMapInstanceDifficulty,
		VoidStorageFrame,
		ComboPointPlayerFrame,
		RuneFrame,
		MageArcaneChargesFrame,
		PaladinPowerBarFrame,
		WarlockPowerFrame,
		MonkHarmonyBarFrame,
		MonkStaggerBar,
	},
	lTranslate = {
		minimap = "MinimapCluster",
		tooltip = "TooltipMover",
		player = "PlayerFrame",
		target = "TargetFrame",
		tot = "TargetFrameToT",
		targetoftarget = "TargetFrameToT",
		pet = "PetFrame",
		focus = "FocusFrame",
		bags = "BagButtonsMover",
		--keyring = "KeyRingFrame",
		castbar = "CastingBarFrame",
		buffs = "PlayerBuffsMover",
		debuffs = "PlayerDebuffsMover",
		GameTooltip = "TooltipMover",
		StanceBarFrame = "StanceButtonsMover",
		TemporaryEnchantFrame = "PlayerBuffsMover",
		TempEnchant1 = "PlayerBuffsMover",
		ConsolidatedBuffs = "PlayerBuffsMover",
		BuffFrame = "PlayerBuffsMover",
		Minimap = "MinimapCluster",
		Boss = "PlayerPowerBarAltMover",
	},
	lTranslateSec = {
		BuffFrame = "PlayerBuffsMover",
		ConsolidatedBuffFrame = "PlayerBuffsMover",
		--[[ChatFrame1EditBox = "ChatEditBoxesMover",
		ChatFrame2EditBox = "ChatEditBoxesMover",
		ChatFrame3EditBox = "ChatEditBoxesMover",
		ChatFrame4EditBox = "ChatEditBoxesMover",
		ChatFrame5EditBox = "ChatEditBoxesMover",
		ChatFrame6EditBox = "ChatEditBoxesMover",
		ChatFrame7EditBox = "ChatEditBoxesMover",
		ChatFrame8EditBox = "ChatEditBoxesMover",
		ChatFrame9EditBox = "ChatEditBoxesMover",
		ChatFrame10EditBox = "ChatEditBoxesMover",]]
	},
	lTransContainerToBag = {
		ContainerFrame1 = "BagFrame1",
		ContainerFrame2 = "BagFrame2",
		ContainerFrame3 = "BagFrame3",
		ContainerFrame4 = "BagFrame4",
		ContainerFrame5 = "BagFrame5",
		ContainerFrame6 = "BankBagFrame1",
		ContainerFrame7 = "BankBagFrame2",
		ContainerFrame8 = "BankBagFrame3",
		ContainerFrame9 = "BankBagFrame4",
		ContainerFrame10 = "BankBagFrame5",
		ContainerFrame11 = "BankBagFrame6",
		ContainerFrame12 = "BankBagFrame7",
		--ContainerFrame13 = "KeyRingFrame",
	},
	lFrameNameRewrites = {
		--CompactRaidFrameContainer = "RaidUnitFramesMover",
		--CompactRaidFrameManager = "RaidUnitFramesManagerMover",
		TargetOfFocusDebuffsMover = "FocusFrameToTDebuffsMover",
	},
	lDeleteFrameNames = {
		BuffFrame = "BuffFrame",
		ConsolidatedBuffFrame = "ConsolidatedBuffFrame",
		TemporaryEnchantFrame = "TemporaryEnchantFrame",
	},
	rendered = nil,
	nextFrameIdx = 1,
	pendingActions = { },
	pendingFrames = { },
	pendingMovers = { },
	minimizedMovers = { },
	SCROLL_HEIGHT = 24,
	currentMover = nil,
	moverPrefix = "MAMover",
	moverNextId = 1,
	movers = { },
	frameEditors = { },
	DDMPointList = {
		{"Top Left", "TOPLEFT"},
		{"Top", "TOP"},
		{"Top Right", "TOPRIGHT"},
		{"Left", "LEFT"},
		{"Center", "CENTER"},
		{"Right", "RIGHT"},
		{"Bottom Left", "BOTTOMLEFT"},
		{"Bottom", "BOTTOM"},
		{"Bottom Right", "BOTTOMRIGHT"},
	},
	DDMStrataList = {
		{"Background", "BACKGROUND"},
		{"Low", "LOW"},
		{"Medium", "MEDIUM"},
		{"High", "HIGH"},
		{"Dialog", "DIALOG"},
		{"Fullscreen", "FULLSCREEN"},
		{"Fullscreen Dialog", "FULLSCREEN_DIALOG"},
		{"Tooltip", "TOOLTIP"},
	},
	DetachFromParent = {
		--MainMenuBarPerformanceBarFrame = "UIParent",
		TargetofFocusFrame = "UIParent",
		PetFrame = "UIParent",
		PartyMemberFrame1PetFrame = "UIParent",
		PartyMemberFrame2PetFrame = "UIParent",
		PartyMemberFrame3PetFrame = "UIParent",
		PartyMemberFrame4PetFrame = "UIParent",
		DebuffButton1 = "UIParent",
		ReputationWatchBar = "UIParent",
		--MainMenuExpBar = "UIParent",
		TimeManagerClockButton = "UIParent",
		OverrideMenuBarHealthBar = "UIParent",
		OverrideMenuBarLeaveButton = "UIParent",
		OverrideMenuBarPowerBar = "UIParent",
		MultiCastActionBarFrame = "UIParent",
		--MainMenuBarRightEndCap = "UIParent",
		--MainMenuBarMaxLevelBar = "UIParent",
		TargetFrameSpellBar = "UIParent",
		FocusFrameSpellBar = "UIParent",
		MultiBarBottomLeft = "UIParent",
		MANudger = "UIParent",
		MultiBarBottomRight = "UIParent",
		MultiBarBottomLeft = "UIParent",
		PlayerDebuffsMover = "UIParent",
		TotemFrame = "UIParent",
		Boss1TargetFrame = "UIParent",
		Boss2TargetFrame = "UIParent",
		Boss3TargetFrame = "UIParent",
		Boss4TargetFrame = "UIParent",
		Boss5TargetFrame = "UIParent",
		RuneFrame = "UIParent",
		--ArenaEnemyFrame1 = "UIParent",
	},
	NoReparent = {
		TargetFrameSpellBar = "TargetFrameSpellBar",
		FocusFrameSpellBar = "FocusFrameSpellBar",
		OverrideMenuBarHealthBar = "OverrideMenuBarHealthBar",
		OverrideMenuBarLeaveButton = "OverrideMenuBarLeaveButton",
		OverrideMenuBarPowerBar = "OverrideMenuBarPowerBar",
		ArenaPrepFrames = "ArenaPrepFrames",
		--ArenaEnemyFrames = "ArenaEnemyFrames",
		MinimapCluster = "MinimapCluster",
		ObjectiveTrackerFrameMover = "ObjectiveTrackerFrameMover",
		ObjectiveTrackerFrameScaleMover = "ObjectiveTrackerFrameScaleMover",
	},
	NoUnanchoring = {
		BuffFrame = "BuffFrame",
		RuneFrame = "RuneFrame",
		TotemFrame = "TotemFrame",
		ComboFrame = "ComboFrame",
		MANudger = "MANudger",
		TimeManagerClockButton = "TimeManagerClockButton",
		PartyMember1DebuffsMover = "PartyMember1DebuffsMover",
		PartyMember2DebuffsMover = "PartyMember2DebuffsMover",
		PartyMember3DebuffsMover = "PartyMember3DebuffsMover",
		PartyMember4DebuffsMover = "PartyMember4DebuffsMover",
		PetDebuffsMover = "PetDebuffsMover",
		TargetBuffsMover = "TargetBuffsMover",
		TargetDebuffsMover = "TargetDebuffsMover",
		FocusBuffsMover = "FocusBuffsMover",
		FocusDebuffsMover = "FocusDebuffsMover",
		TargetFrameToTDebuffsMover = "TargetFrameToTDebuffsMover",
		FocusFrameToTDebuffsMover = "FocusFrameToTDebuffsMover",
		TemporaryEnchantFrame = "TemporaryEnchantFrame",
		AuctionDressUpFrame = "AuctionDressUpFrame",
		MinimapCluster = "MinimapCluster",
		--[[ArenaEnemyFrame1PetFrame = "ArenaEnemyFrame1PetFrame",
		ArenaEnemyFrame2PetFrame = "ArenaEnemyFrame2PetFrame",
		ArenaEnemyFrame3PetFrame = "ArenaEnemyFrame3PetFrame",
		ArenaEnemyFrame4PetFrame = "ArenaEnemyFrame4PetFrame",
		ArenaEnemyFrame5PetFrame = "ArenaEnemyFrame5PetFrame",
		ArenaEnemyFrame1CastingBar = "ArenaEnemyFrame1CastingBar",
		ArenaEnemyFrame2CastingBar = "ArenaEnemyFrame2CastingBar",
		ArenaEnemyFrame3CastingBar = "ArenaEnemyFrame3CastingBar",
		ArenaEnemyFrame4CastingBar = "ArenaEnemyFrame4CastingBar",
		ArenaEnemyFrame5CastingBar = "ArenaEnemyFrame5CastingBar",--]]
	},
	lAllowedMAFrames = {
		MAOptions = "MAOptions",
		MANudger = "MANudger",
		MAPortDialog = "MAPortDialog",
		GameMenuButtonMoveAnything = "GameMenuButtonMoveAnything",
		--MACompactRaidFrameManagerToggleButton = "MACompactRaidFrameManagerToggleButton",
		--MA_FEMover = "MA_FEMover",
	},
	CONTAINER_FRAME_TABLE = {
		[0] = {"Interface\\ContainerFrame\\UI-BackpackBackground", 256, 256, 239},
		[1] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
		[2] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
		[3] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
		[4] = {"Interface\\ContainerFrame\\UI-Bag-1x4", 256, 128, 96},
		[5] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
		[6] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
		[7] = {"Interface\\ContainerFrame\\UI-Bag-1x4+2", 256, 128, 116},
		[8] = {"Interface\\ContainerFrame\\UI-Bag-2x4", 256, 256, 137},
		[9] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
		[10] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
		[11] = {"Interface\\ContainerFrame\\UI-Bag-2x4+2", 256, 256, 157},
		[12] = {"Interface\\ContainerFrame\\UI-Bag-3x4", 256, 256, 178},
		[13] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
		[14] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
		[15] = {"Interface\\ContainerFrame\\UI-Bag-3x4+2", 256, 256, 198},
		[16] = {"Interface\\ContainerFrame\\UI-Bag-4x4", 256, 256, 219},
		[18] = {"Interface\\ContainerFrame\\UI-Bag-4x4+2", 256, 256, 239},
		[20] = {"Interface\\ContainerFrame\\UI-Bag-5x4", 256, 256, 259},
		[22] = {"Interface\\ContainerFrame\\UI-Bag-5x4+2", 256, 256, 279},
		[24] = {"Interface\\ContainerFrame\\UI-Bag-5x5", 256, 256, 299},
		[26] = {"Interface\\ContainerFrame\\UI-Bag-5x5+2", 256, 256, 319},
		[28] = {"Interface\\ContainerFrame\\UI-Bag-5x6", 256, 256, 339},
		[30] = {"Interface\\ContainerFrame\\UI-Bag-5x6+2", 256, 256, 359},
		[32] = {"Interface\\ContainerFrame\\UI-Bag-5x7", 256, 256, 379},
		[34] = {"Interface\\ContainerFrame\\UI-Bag-5x7+2", 256, 256, 399},
		[36] = {"Interface\\ContainerFrame\\UI-Bag-5x8", 256, 256, 419},
		[38] = {"Interface\\ContainerFrame\\UI-Bag-5x8+2", 256, 256, 439},
		[40] = {"Interface\\ContainerFrame\\UI-Bag-5x9", 256, 256, 459},
	},
	-- X: hook replacements
	ContainerFrame_GenerateFrame = function(frame, size, id)
		MovAny:GrabContainerFrame(frame, MovAny:GetBag(id))
	end,
	hCreateFrame = function(frameType, name, parent, inherit, dontHook)
		if name and not MovAny.lForceProtected[name] then
			if dontHook == "MADontHook" then
				return
			end
			API:SyncElement(name)
		end
	end,
	hBlizzard_TalentUI = function(self)
		if PlayerTalentFrame_Toggle then
			hooksecurefunc("PlayerTalentFrame_Toggle", function()
				API:SyncElement("PlayerTalentFrame", true)
			end)
			MovAny.hBlizzard_TalentUI = nil
		end
	end,
	hReputationWatchBar_Update = function()
		API:SyncElement("ReputationWatchBar")
	end,
	--[[hChatFrame_OnUpdate = function(arg1)
		local b = arg1
		if MovAny:IsModified(b) then
			b:SetWidth(200)
			b:SetPoint("TOPLEFT", ChatEditBoxesMover, "TOPLEFT", 0, 0)
			b:SetPoint("BOTTOMRIGHT", ChatEditBoxesMover, "BOTTOMRIGHT", 0, 0)
		end
	end,]]
	--[[hCaptureBar_Create = function(id)
		local f = MovAny.oCaptureBar_Create(id)
		local e = API:GetElement("WorldStateCaptureBar1")
		if e then
			e:Sync()
			if not e.userData or not e.userData.pos then
				f:ClearAllPoints()
				f:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, -175)
			end
		end
		return f
	end,]]
	hAchievementAlertFrame_OnLoad = function(f)
		f.RegisterForClicks = MovAny.fVoid
		MovAny.oAchievementAlertFrame_OnLoad(f)
		API:SyncElement(f:GetName())
	end,
	hAchievementAlertFrame_GetAlertFrame = function()
		local f = MovAny.oAchievementAlertFrame_GetAlertFrame()
		if not f then
			return
		end
		API:SyncElement(f:GetName())
		return f
	end,
	hStanceBar_Update = function()
		API:SyncElement("StanceButtonsMover")
		API:SyncElement("StanceButtonsVerticalMover")
	end,
	hStanceBar_UpdateState = function()
		API:SyncElement("StanceButtonsMover")
		API:SyncElement("StanceButtonsVerticalMover")
	end,
	--[[hookArenaEnemyFrames = function()
		if ArenaPrepFrames and not ArenaPrepFrames.hooked_ma then
			ArenaPrepFrames.hooked_ma = true
			ArenaPrepFrames.Hide = function()end
			ArenaPrepFrames:Show()
			ArenaPrepFrames.Show = function()end
			ArenaPrepFrames.clear_all_points = ArenaPrepFrames.ClearAllPoints
			ArenaPrepFrames.ClearAllPoints = function(self)
				if not InCombatLockdown() then
					self:clear_all_points()
				end
			end
			ArenaPrepFrames.set_points = ArenaPrepFrames.SetPoint
			ArenaPrepFrames.SetPoint = function(self, ...)
				if not InCombatLockdown() then
					self:set_points(...)
				end
			end
		end
		if ArenaEnemyFrames and not ArenaEnemyFrames.hooked_ma then
			ArenaEnemyFrames.hooked_ma = true
			ArenaEnemyFrames.Hide = function()end
			ArenaEnemyFrames:Show()
			ArenaEnemyFrames.Show = function()end
			ArenaEnemyFrames.clear_all_points = ArenaEnemyFrames.ClearAllPoints
			ArenaEnemyFrames.ClearAllPoints = function(self)
				if not InCombatLockdown() then
					self:clear_all_points()
				end
			end
			ArenaEnemyFrames.set_points = ArenaEnemyFrames.SetPoint
			ArenaEnemyFrames.SetPoint = function(self, ...)
				if not InCombatLockdown() then
					self:set_points(...)
				end
			end
		end
	end,--]]
	--arenaframes15hooked = false,
	--[[hookArenaEnemyFrames15 = function(self)
		if InCombatLockdown() then
			return
		end
		if not MovAny:IsModified("ArenaEnemyFrame1") then
			ArenaEnemyFrame1:SetPoint("TOP", UIParent, "TOP", 600, - 300)
			ArenaEnemyFrame1:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame2:SetPoint("TOP", ArenaEnemyFrame1, "BOTTOM", 0, - 20)
			ArenaEnemyFrame2:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame3:SetPoint("TOP", ArenaEnemyFrame2, "BOTTOM", 0, - 20)
			ArenaEnemyFrame3:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame4:SetPoint("TOP", ArenaEnemyFrame3, "BOTTOM", 0, - 20)
			ArenaEnemyFrame4:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame5:SetPoint("TOP", ArenaEnemyFrame4, "BOTTOM", 0, - 20)
			ArenaEnemyFrame5:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
		end
		if not MovAny:IsModified("ArenaPrepFrame1") then
			ArenaPrepFrame1:SetPoint("TOP", UIParent, "TOP", 600, - 300)
			ArenaPrepFrame1:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaPrepFrame2:SetPoint("TOP", ArenaPrepFrame1, "BOTTOM", 0, - 20)
			ArenaPrepFrame2:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaPrepFrame3:SetPoint("TOP", ArenaPrepFrame2, "BOTTOM", 0, - 20)
			ArenaPrepFrame3:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaPrepFrame4:SetPoint("TOP", ArenaPrepFrame3, "BOTTOM", 0, - 20)
			ArenaPrepFrame4:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaPrepFrame5:SetPoint("TOP", ArenaPrepFrame4, "BOTTOM", 0, - 20)
			ArenaPrepFrame5:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
		end
	end,
	hookArenaEnemyPets15 = function() end,
	hArenaEnemyFrames_Enable = function()
		ArenaPrepFrames:ma_Show()
		ArenaEnemyFrames:ma_Show()
	end,
	hArenaEnemyFrames_Disable = function()
		ArenaPrepFrames:ma_Hide()
		ArenaEnemyFrames:ma_Hide()
	end,--]]
	--[[hWatchFrameExpand = function()
		if ArenaEnemyFrames then
			local _, instanceType = IsInInstance()
			if not WatchFrame:IsUserPlaced() then
				if ArenaEnemyFrames:IsShown() then
					if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
						ArenaEnemyFrames.hidWatchedQuests = true
					end
				elseif instanceType == "arena" or instanceType == "pvp" then
					if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
						ArenaEnemyFrames.hidWatchedQuests = true
					end
				else
					if ArenaEnemyFrames.hidWatchedQuests then
						WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
						ArenaEnemyFrames.hidWatchedQuests = false
					end
				end
			elseif ArenaEnemyFrames.hidWatchedQuests then
				WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
				ArenaEnemyFrames.hidWatchedQuests = false
			end
		elseif ArenaPrepFrames then
			local _, instanceType = IsInInstance()
			if not WatchFrame:IsUserPlaced() then
				if ArenaPrepFrames:IsShown() then
					if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
						ArenaPrepFrames.hidWatchedQuests = true
					end
				elseif instanceType == "arena" or instanceType == "pvp" then
					if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
						ArenaPrepFrames.hidWatchedQuests = true
					end
				else
					if ArenaPrepFrames.hidWatchedQuests then
						WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
						ArenaPrepFrames.hidWatchedQuests = false
					end
				end
			elseif ArenaPrepFrames.hidWatchedQuests then
				WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
				ArenaPrepFrames.hidWatchedQuests = false
			end
		end
	end,]]
	hFocusFrame_Update = function()
		if MovAny:IsModified(FocusFrame) then
			RegisterStateDriver("FocusFrame", "visibility", "hide")
		else
			RegisterStateDriver("FocusFrame", "visibility", "show")
		end
	end,
	--[[hPetActionBarFrame_OnUpdate = function()
		if MovAny:IsModified(PetActionButtonsMover) or MovAny:IsModified(PetActionButtonsVerticalMover) then
			API:SyncElement("PetActionButtonsMover")
			API:SyncElement("PetActionButtonsVerticalMover")
		end
	end,]]
	hAddFrameLock = function()
		MultiBarBottomLeft:Hide()
		MultiBarBottomRight:Hide()
	end,
	hRemoveFrameLock = function()
		if SHOW_MULTI_ACTIONBAR_1 then
			MultiBarBottomLeft:Show()
		elseif (MovAny:IsModified(MultiBarBottomLeft) and not MovAny:IsModified(MultiBarBottomLeft)) then
			MultiBarBottomLeft:Show()
		end
		if SHOW_MULTI_ACTIONBAR_2 then
			MultiBarBottomRight:Show()
		elseif (MovAny:IsModified(MultiBarBottomRight) and not MovAny:IsModified(MultiBarBottomRight)) then
			MultiBarBottomRight:Show()
		end
	end
}

if ChatEdit_ActivateChat then
	hooksecurefunc("ChatEdit_ActivateChat", function(self)
		if MovAny:IsModified("ChatEditBoxesMover") then
			MovAny.API:SyncElement("ChatEditBoxesMover")
		end
	end)
end

if InterfaceOptionsFrame then
	InterfaceOptionsFrame:HookScript("OnShow", function(self)
		MovAny_OptionsOnShow()
	end)
end

if CompactRaidFrameManager_Expand then
	hooksecurefunc("CompactRaidFrameManager_Expand", function(self)
		if InCombatLockdown() then
			return
		end
		if MovAny:IsModified(self) then
			MovAny:UnlockPoint(self)
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xOfs + 175, yOfs)
			MovAny:LockPoint(self)
		end
	end)
end

if CompactRaidFrameManager_Collapse then
	hooksecurefunc("CompactRaidFrameManager_Collapse", function(self)
		if InCombatLockdown() then
			return
		end
		if MovAny:IsModified(self) then
			MovAny:UnlockPoint(self)
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xOfs - 175, yOfs)
			MovAny:LockPoint(self)
		end
	end)
end
if WorldMap_ToggleSizeDown then
	hooksecurefunc("WorldMap_ToggleSizeDown", function()
		if MovAny:IsModified(WorldMapFrame) then
			MovAny.API:SyncElement("WorldMapFrame")
		end
	end)
end

--[[OverrideActionBar:HookScript("OnShow", function(self)
	if not MovAny:IsModified(MicroButtonsMover) and not MovAny:IsModified(MicroButtonsSplitMover) and not MovAny:IsModified(MicroButtonsVerticalMover) then
		return
	end
	local children = {
		CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		AchievementMicroButton,
		QuestLogMicroButton,
		GuildMicroButton,
		--PVPMicroButton,
		LFDMicroButton,
		CollectionsMicroButton,
		EJMicroButton,
		StoreMicroButton,
		MainMenuMicroButton
	}
	for i = 1, #children, 1 do
		MovAny:UnlockPoint(children[i])
		MovAny:UnlockScale(children[i])
		children[i]:ClearAllPoints()
		children[i]:SetScale(1)
		if i == 1 then
			children[i]:SetPoint("LEFT", OverrideActionBarLeaveFrame, "LEFT", - 165, 20)
		elseif children[i] == LFDMicroButton then
			children[i]:SetPoint("LEFT", CharacterMicroButton, "LEFT", 0, - 34)
		else
			children[i]:SetPoint("LEFT", children[i - 1], "RIGHT", - 2, 0)
		end
		MovAny:LockPoint(children[i])
		MovAny:LockScale(children[i])
	end
end)

OverrideActionBar:HookScript("OnHide", function(self)
	if not MovAny:IsModified(MicroButtonsMover) and not MovAny:IsModified(MicroButtonsSplitMover) and not MovAny:IsModified(MicroButtonsVerticalMover) then
		return
	end
	if MovAny:IsModified(MicroButtonsMover) then
		MovAny.API:SyncElement("MicroButtonsMover")
	elseif MovAny:IsModified(MicroButtonsSplitMover) then
		MovAny.API:SyncElement("MicroButtonsSplitMover")
	elseif MovAny:IsModified(MicroButtonsVerticalMover) then
		MovAny.API:SyncElement("MicroButtonsVerticalMover")
	end
end)--]]

_G.MovAny = MovAny

BINDING_HEADER_MOVEANYTHING = "MoveAnything"

StaticPopupDialogs["MOVEANYTHING_RESET_ALL_CONFIRM"] = {
	preferredIndex = 3,
	text = MOVANY.RESET_ALL_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		MovAny:CompleteReset()
	end,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

function MovAny:Load()
	if self.inited then
		return
	end
	MAOptions = _G["MAOptions"]
	if not MADB.noMMMW and Minimap:GetScript("OnMouseWheel") == nil then
		Minimap:SetScript("OnMouseWheel", function(self, dir)
			if dir < 0 then
				Minimap_ZoomOut()
			else
				Minimap_ZoomIn()
			end
		end)
		Minimap:EnableMouseWheel(true)
	end
	local MADB_Defaults = {
		frameListRows = 18,
	}
	for i, v in pairs(MADB_Defaults) do
		if MADB[i] == nil then
			MADB[i] = v
		end
	end
	if tlen(MADB.profiles) == 0 then
		MADB.autoShowNext = true
	end
	self:VerifyData()
	if MADB.squareMM then
		Minimap:SetMaskTexture("Interface\\AddOns\\MoveAnything\\Textures\\MinimapMaskSquare")
	end
	self:SetNumRows(MADB.frameListRows, false)
	if MADB.closeGUIOnEscape then
		tinsert(UISpecialFrames, "MAOptions")
	end
	MAOptionsMoveHeader:SetText(MOVANY.LIST_HEADING_MOVER)
	MAOptionsHideHeader:SetText(MOVANY.LIST_HEADING_HIDE)
	MAOptionsToggleFrameEditors:SetChecked(true)
	self.userData = MADB.profiles[self:GetProfileName()].frames
	for i, m in pairs(self.core) do
		if m.Init then
			m:Init()
		end
	end
	for i, m in pairs(self.core) do
		if m.Enable then
			m:Enable()
		end
	end
	for i, m in pairs(self.modules) do
		if m.Enable then
			m:Enable()
		end
	end
	API = self.API
	local ar = { }
	local e
	for n, v in pairs(self.userData) do
		e = API:GetElement(n)
		if not e then
			tinsert(ar, n)
		else
			e:SetUserData(v)
		end
	end
	table.sort(ar, function(o1, o2)
		return o1:lower() < o2:lower()
	end)
	for _, fn in ipairs(ar) do
		e = API:AddElement({name = fn})
		e:SetUserData(self.userData[fn])
	end
	if self.lVirtualMovers then
		if type(self.lCreateVMs) == "table" then
			if not MADB.noBags then
				for _, name in pairs(self.lCreateVMs) do
					if not _G[name] then
						self:CreateVM(name)
					end
				end
			end
			self.lCreateVMs = nil
		end
		local vmClosure = function(name)
			return function()
				if not _G[name] then
					MovAny:CreateVM(name)
				end
			end
		end
		local el, vm
		for name, data in pairs(self.lVirtualMovers) do
			vm = _G[name]
			if not vm then
				el = API:GetElement(name)
				if el then
					el.runOnce = vmClosure(name)
				end
			end
			if not data.notMAParent then
				if type(data.count) == "number" then
					for i = 1, data.count, 1 do
						local child = _G[data.prefix..i..(data.postfix or "")]
						if child then
							if not self:IsModified(child:GetName()) then
								child.MAParent = vm or name
							end
						else
							break
						end
					end
				end
				if type(data.children) == "table" then
					for i, v in pairs(data.children) do
						local child = v
						if type(v) == "string" then
							child = _G[v]
						end
						if child then
							if not self:IsModified(child:GetName()) then
								child.MAParent = name
							end
						else
							break
						end
					end
				end
			end
		end
	end
	if not MADB.noBags then
		MAOptions:RegisterEvent("BANKFRAME_OPENED")
		MAOptions:RegisterEvent("BANKFRAME_CLOSED")
	end
	MAOptions:RegisterUnitEvent("UNIT_AURA", "player")
	MAOptions:RegisterEvent("BAG_UPDATE")
	--MAOptions:RegisterEvent("PET_BATTLE_OPENING_START")
	--MAOptions:RegisterEvent("PET_BATTLE_CLOSE")
end

function MovAny:Boot()
	if self.inited then
		return
	end
	if not MADB.dontHookCreateFrame and CreateFrame then
		hooksecurefunc("CreateFrame", self.hCreateFrame)
	end
	--[[if ContainerFrame_GenerateFrame then
		hooksecurefunc("ContainerFrame_GenerateFrame", self.ContainerFrame_GenerateFrame)
	end]]
	if ShowUIPanel then
		hooksecurefunc("ShowUIPanel", self.SyncUIPanels)
	end
	if HideUIPanel then
		hooksecurefunc("HideUIPanel", self.SyncUIPanels)
	end
	if UpdateUIPanelPositions then
		hooksecurefunc("UpdateUIPanelPositions", self.SyncUIPanels)
	end
	if GameTooltip_SetDefaultAnchor then
		hooksecurefunc("GameTooltip_SetDefaultAnchor", self.hGameTooltip_SetDefaultAnchor)
	end
	if StanceBar_Update then
		hooksecurefunc("StanceBar_Update", self.hStanceBar_Update)
	end
	if StanceBar_UpdateState then
		hooksecurefunc("StanceBar_UpdateState", self.hStanceBar_UpdateState)
	end
	--[[if false then
		hooksecurefunc("PetActionBar_Update", self.hPetActionBar_Update)
	end]]
	if GameTooltip and GameTooltip.SetBagItem then
		hooksecurefunc(GameTooltip, "SetBagItem", self.hGameTooltip_SetBagItem)
	end
	if GameTooltip and GameTooltip.SetGuildBankItem then
		hooksecurefunc(GameTooltip, "SetGuildBankItem", self.hGameTooltip_SetGuildBankItem)
	end
	if ContainerFrameItemButton_CalculateItemTooltipAnchors then
		hooksecurefunc("ContainerFrameItemButton_CalculateItemTooltipAnchors", self.hGameTooltip_SetBagItem)
	end
	if AddFrameLock then
		hooksecurefunc("AddFrameLock", self.hAddFrameLock)
	end
	if RemoveFrameLock then
		hooksecurefunc("RemoveFrameLock", self.hRemoveFrameLock)
	end
	if UpdateContainerFrameAnchors then
		hooksecurefunc("UpdateContainerFrameAnchors", self.hUpdateContainerFrameAnchors)
	end
	if SpellBookFrame_Update then
		hooksecurefunc("SpellBookFrame_Update", function()
			SpellBookPage1:SetPoint("LEFT", SpellBookFrame)
		end)
	end
	--[[if WatchFrame_Update then
		hooksecurefunc("WatchFrame_Update", self.hWatchFrameExpand)
	end]]
	--setfenv(WorldMapFrame_OnShow, setmetatable({UpdateMicroButtons = function() end }, { __index = _G}))
	--[[hooksecurefunc("PetActionBar_UpdatePositionValues", function()
		if MovAny:IsModified(PetActionButtonsVerticalMover) or MovAny:IsModified(PetActionButtonsMover) then
			--print("PetActionBar_UpdatePositionValues()", MovAny:IsModified(PetActionButtonsVerticalMover), MovAny:IsModified(PetActionButtonsMover))
			PetActionBarFrame:SetPoint("TOPLEFT", PetActionBarFrame:GetParent(), "BOTTOMLEFT", 500, 0)
		end
	end)
	hooksecurefunc("ShowPetActionBar", function()
		if MovAny:IsModified(PetActionButtonsVerticalMover) or MovAny:IsModified(PetActionButtonsMover) then
			--print("ShowPetActionBar()", MovAny:IsModified(PetActionButtonsVerticalMover), MovAny:IsModified(PetActionButtonsMover))
			PetActionBarFrame:SetPoint("TOPLEFT", PetActionBarFrame:GetParent(), "BOTTOMLEFT", 500, 0)
		end
	end)]]
	--[[hooksecurefunc("ChatEdit_UpdateHeader",function(arg1, arg2)
		local b = arg1
		if MovAny:IsModified(b) then
			b:SetWidth(ChatFrame1:GetWidth())
			b:SetPoint("TOPLEFT", ChatEditBoxesMover, "TOPLEFT", 0, 0)
			b:SetPoint("BOTTOMRIGHT", ChatEditBoxesMover, "BOTTOMRIGHT", 0, 0)
		end
	end)]]
	--[[if ExtendedUI and ExtendedUI.CAPTUREPOINT then
		self.oCaptureBar_Create = ExtendedUI.CAPTUREPOINT.create
		ExtendedUI.CAPTUREPOINT.create = self.hCaptureBar_Create
	end]]
	if AchievementAlertFrame_OnLoad then
		self.oAchievementAlertFrame_OnLoad = AchievementAlertFrame_OnLoad
		AchievementAlertFrame_OnLoad = self.hAchievementAlertFrame_OnLoad
	end
	if AchievementAlertFrame_GetAlertFrame then
		self.oAchievementAlertFrame_GetAlertFrame = AchievementAlertFrame_GetAlertFrame
		AchievementAlertFrame_GetAlertFrame = self.hAchievementAlertFrame_GetAlertFrame
	end
	--[[if LootWonAlertFrame_SetUp then
		hooksecurefunc("LootWonAlertFrame_SetUp", function(self, arg1, ...)
			--print("TestDone", self, arg1, select(1, ...), select(2, ...), select(3, ...), select(4, ...), select(5, ...))
			if self == LOOT_WON_ALERT_FRAMES[1] and MovAny:IsModified(LootWonAlertMover1) then
				print("LootWonAlert1 - Find")
				LOOT_WON_ALERT_FRAMES[1]:SetPoint("BOTTOMLEFT", LootWonAlertMover1, "BOTTOMLEFT", 0, 0)
			end
			if self == LOOT_WON_ALERT_FRAMES[2] and MovAny:IsModified(LootWonAlertMover2) then
				print("LootWonAlert2 - Find")
				LOOT_WON_ALERT_FRAMES[2]:SetPoint("BOTTOMLEFT", LootWonAlertMover2, "BOTTOMLEFT", 0, 0)
			end
			if self == LOOT_WON_ALERT_FRAMES[3] and MovAny:IsModified(LootWonAlertMover3) then
				print("LootWonAlert3 - Find")
				LOOT_WON_ALERT_FRAMES[3]:SetPoint("BOTTOMLEFT", LootWonAlertMover3, "BOTTOMLEFT", 0, 0)
			end
			if self == LOOT_WON_ALERT_FRAMES[4] and MovAny:IsModified(LootWonAlertMover4) then
				print("LootWonAlert4 - Find")
				LOOT_WON_ALERT_FRAMES[4]:SetPoint("BOTTOMLEFT", LootWonAlertMover4, "BOTTOMLEFT", 0, 0)
			end
			if self == LOOT_WON_ALERT_FRAMES[5] and MovAny:IsModified(LootWonAlertMover5) then
				print("LootWonAlert5 - Find")
				LOOT_WON_ALERT_FRAMES[5]:SetPoint("BOTTOMLEFT", LootWonAlertMover5, "BOTTOMLEFT", 0, 0)
			end
		end)
	end]]
	--[[if GroupLootContainer_AddFrame then
		hooksecurefunc("GroupLootContainer_AddFrame", function(self, ...)
			--print(self, select(1, ...), select(2, ...))
			if MovAny:IsModified(GroupLootFrameMover1) then
				GroupLootFrame1:SetPoint("BOTTOMLEFT", GroupLootFrameMover1, "BOTTOMLEFT", 0, 0)
			end
			if MovAny:IsModified(GroupLootFrameMover2) then
				GroupLootFrame2:SetPoint("BOTTOMLEFT", GroupLootFrameMover2, "BOTTOMLEFT", 0, 0)
			end
			if MovAny:IsModified(GroupLootFrameMover3) then
				GroupLootFrame1:SetPoint("BOTTOMLEFT", GroupLootFrameMover3, "BOTTOMLEFT", 0, 0)
			end
			if MovAny:IsModified(GroupLootFrameMover4) then
				GroupLootFrame4:SetPoint("BOTTOMLEFT", GroupLootFrameMover4, "BOTTOMLEFT", 0, 0)
			end
		end)
	end]]
	self.inited = true
	if IsAddOnLoaded("Blizzard_TalentUI") and self.hBlizzard_TalentUI then
		self:hBlizzard_TalentUI()
	end
end

function MovAny:OnPlayerLogout()
	if not MAOptions then
		return
	end
	if MAOptions:IsShown() then
		MADB.autoShowNext = true
	end
	if type(self.movers) == "table" then
		for i, v in ipairs(MA_tcopy(self.movers)) do
			self:StopMoving(v.tagged:GetName())
		end
	end
	--[[if type(MADB.profiles) == "table" then
		for i, v in pairs(MADB.profiles) do
			MovAny:CleanProfile(i)
		end
	end]]
end

function MovAny:VerifyData()
	if MoveAnything_CharacterSettings then
		MADB.profiles = { }
		for i, v in pairs(MoveAnything_CharacterSettings) do
			if type(v) == "table" then
				MADB.profiles[i] = {name = i, frames = v}
			end
		end
		MoveAnything_CharacterSettings = nil

		MADB.characters = { }
		if MoveAnything_UseCharacterSettings then
			for i, _ in pairs(MADB.profiles) do
				MADB.characters[i] = {profile = i}
			end
		end
	end
	if type(MADB) ~= "table" then
		MADB = { }
	end
	if type(MADB.profiles) ~= "table" then
		MADB.profiles = { }
	end
	if type(MADB.characters) ~= "table" then
		MADB.characters = { }
	end
	if MADB.profiles["default"] == nil then
		self:AddProfile("default", true, true)
	end
	if MADB.profiles[self:GetProfileName()] == nil then
		local char = MADB.characters[self:GetCharacterIndex()]
		if char then
			char.profile = nil
		end
	end
	local remList = { }
	local addList = { }
	local rewriteName
	for pi, profile in pairs(MADB.profiles) do
		table.wipe(remList)
		table.wipe(addList)
		if type(profile.frames) ~= "table" then
			profile.frames = { }
		end
		for fn, opt in pairs(profile.frames) do
			if type(fn) ~= "string" or type(opt) ~= "table" or self.lDeleteFrameNames[fn] then
				tinsert(remList, fn)
			else
				rewriteName = nil
				if self.lFrameNameRewrites[fn] then
					rewriteName = fn
					fn = self.lFrameNameRewrites[fn]
				end
				opt.cat = nil
				if opt.name ~= fn then
					opt.name = fn
				end
				opt.originalLeft = nil
				opt.originalBottom = nil
				opt.originalWidth = nil
				opt.orgWidth = nil
				opt.originalHeight = nil
				opt.orgHeight = nil
				opt.orgPos = nil
				opt.originalScale = nil
				opt.orgScale = nil
				opt.originalAlpha = nil
				opt.origAlpha = nil
				opt.MANAGED_FRAME = nil
				opt.UIPanelWindows = nil
				if type(opt.scale) == "number" then
					if opt.scale > 0.991 and opt.scale < 1.009 then
						opt.scale = 1
					end
				else
					opt.scale = nil
				end
				if opt.x ~= nil and opt.y ~= nil then
					local f = _G[fn]
					local fRel = self:ForcedDetachFromParent(fn, opt)
					local p
					if not fRel then
						p = f and f.GetParent and f:GetParent() ~= nil and f:GetParent():GetName() or "UIParent"
					end
					opt.pos = {"BOTTOMLEFT", p, "BOTTOMLEFT", opt.x, opt.y}
					opt.x = nil
					opt.y = nil
				else
					opt.x = nil
					opt.y = nil
				end
				if type(opt.pos) == "table" then
					local relTo = opt.pos[2]
					if type(relTo) == "table" and relTo.GetName and relTo:GetName() then
						opt.pos[2] = relTo:GetName()
					end
				end
				--[[if opt.width and opt.orgWidth and opt.width == opt.orgWidth then
					opt.width = nil
				end
				if opt.height and opt.orgHeight and opt.height == opt.orgHeight then
					opt.height = nil
				end]]
				if rewriteName then
					if not self:IsModified(fn, nil, opt) then
						tinsert(remList, rewriteName)
					else
						tinsert(remList, rewriteName)
						addList[fn] = opt
					end
				elseif not self:IsModified(fn, nil, opt) then
					tinsert(remList, fn)
				end
			end
		end
		for i, v in ipairs(remList) do
			MADB.profiles[pi].frames[v] = nil
		end
		for i, opt in pairs(addList) do
			MADB.profiles[pi].frames[i] = opt
		end
	end
	self.lFrameNameRewrites = nil
	self.lDeleteFrameNames = nil
end

function MovAny:VerifyFrameData(fn)
	local e = API:GetElement(fn)
	if e.userData and not e:IsModified() then
		e:SetUserData(nil)
		MovAny.userData[fn] = nil
	end
end

function MovAny:ForcedDetachFromParent(fn, opt)
	if self.DetachFromParent[fn] then
		return self.DetachFromParent[fn]
	end
	if UIPanelWindows[fn] then
		return "UIParent"
	end
	opt = opt or self.userData[fn]
	if not opt or opt.UIPanelWindows then
		return "UIParent"
	end
end

function MovAny:ErrorNotInCombat(f, quiet)
	if f and self:IsProtected(f) and InCombatLockdown() then
		if not quiet then
			maPrint(string.format(MOVANY.FRAME_PROTECTED_DURING_COMBAT, f:GetName()))
		end
		return true
	end
end

function MovAny:IsValidObject(f, silent)
	if type(f) == "string" then
		f = _G[f]
	end
	if not f then
		return
	end
	if type(f) ~= "table" then
		if not silent then
			maPrint(string.format(MOVANY.UNSUPPORTED_TYPE, type(f)))
		end
		return
	end
	if self.lDisallowedFrames[f:GetName()] then
		if not silent then
			maPrint(string.format(MOVANY.UNSUPPORTED_FRAME, f:GetName()))
		end
		return
	end
	if not self.lAllowedTypes[f:GetObjectType()] then
		if not silent then
			maPrint(string.format(MOVANY.UNSUPPORTED_TYPE, f:GetObjectType()))
		end
		return
	end
	if MovAny:IsMAFrame(f:GetName()) then
		if MovAny.lAllowedMAFrames[f:GetName()] or string.sub(f:GetName(), 1, 5) == "MA_FE" then
			return true
		end
		return
	end
	return true
end

function MovAny:SyncAllFrames(dontReset)
	if not self.rendered then
		dontReset = true
	end
	table.wipe(self.pendingFrames)
	if type(self.userData) == "table" then
		for i, v in pairs(self.userData) do
			if i ~= "ArenaPrepFrames" or i ~= "ArenaEnemyFrames" then
				self.pendingFrames[i] = API:GetElement(i)
			end
		end
	end
	self:SyncFrames(dontReset)
end

function MovAny:SyncFrames(dontReset)
	if not self.inited or self.syncingFrames then
		return
	end
	local i = 0
	for k in pairs(self.pendingFrames) do
		i = i + 1
		break
	end
	if i == 0 then
		return
	end
	self.syncingFrames = true
	local f, parent, handled
	local skippedFrames = { }
	if dontReset then
		for fn, e in pairs(self.pendingFrames) do
			f = _G[fn]
			if f and not e.noMove then
				self:UnanchorRelatives(e, f, e.userData)
			end
		end
	end
	for fn, e in pairs(self.pendingFrames) do
		if not self:GetMoverByFrame(fn) then
			self.curSync = e
			local _, ret = xpcall(function()
				return e:Sync()
			end, self.SyncErrorHandler, self)
			if not ret or self.syncError then
				skippedFrames[fn] = e
			end

			self.curSync = nil
			self.syncError = nil
		end
	end
	self.pendingFrames = skippedFrames
	local postponed = { }
	for k, f in pairs(self.pendingActions) do
		if f() then
			tinsert(postponed, f)
		end
	end
	self.pendingActions = postponed
	self:SyncUIPanels()
	self.rendered = true
	self.syncingFrames = nil
	if MADB.autoShowNext then
		MAOptions:Show()
	end
end

function MovAny.SyncErrorHandler(msg, frame, stack,  ...)
	if MADB.disableErrorMessages then
		return
	end
	local e = MovAny.curSync
	if e then
		MovAny.syncError = 1
		stack = stack or debugstack(2, 20, 20)
		local funcs = ""
		for m in string.gmatch(stack, "function (%b`')") do
			if m ~= "xpcall" then
				if funcs == "" then
					funcs = m
				else
					funcs = funcs..", "..m
				end
			end
		end
		maPrint(string.format(MOVANY.ERROR_FRAME_FAILED, e.name, e.name, GetAddOnMetadata("MoveAnything", "Version"), msg, funcs))
	end
	local errorHandler = geterrorhandler()
	if type(errorHandler) == "function" and errorHandler ~= _ERRORMESSAGE then
		errorHandler(msg, frame, stack, ...)
	end
end

function MovAny:IsProtected(f)
	if not f then
		return
	end
	local isProtected = f:IsProtected()
	if isProtected or f.MAProtected or MovAny.lForceProtected[f:GetName()] then
		return true
	else
		return nil
	end
end

function MovAny:GetCharacterIndex()
	return GetRealmName().." "..UnitName("player")
end

function MovAny:ClearUserData(fn)
	self.userData[fn] = nil
	API:RemoveCustomElement(fn)
end

function MovAny:GetUserData(fn, noSymLink, create)
	if self.userData == nil then
		return nil
	end
	if not noSymLink and not self.userData[fn] and self.lTranslateSec[fn] then
		fn = self.lTranslateSec[fn]
	end
	if create and self.userData[fn] == nil then
		local ud = {name = fn}
		local e = API:AddElementIfNew(fn)
		MovAny.userData[fn] = ud
		e:SetUserData(ud)
		return ud
	else
		return MovAny.userData[fn]
	end
end

function MovAny.hShow(f, ...)
	if not f then
		return
	end
	if f.MAHidden then
		if MovAny:IsProtected(f) and InCombatLockdown() then
			local e = API:GetElement(f:GetName())
			if e ~= nil and e.userData then
				MovAny.pendingFrames[f:GetName()] = e
			end
		else
			f.MAHidden = nil
			f:Hide()
			f.MAHidden = true
		end
	end
end

--[[local hider = CreateFrame("Frame")
hider:Hide()]]

function MovAny:LockVisibility(f, dontHide)
	if not f then
		return
	end
	if f.MAHidden then
		return
	end
	f.MAHidden = true
	if not f.MAShowHook then
		hooksecurefunc(f, "Show", MovAny.hShow)
		f.MAShowHook = true
	end
	f.MAWasShown = f:IsShown()
	if not dontHide and f.MAWasShown then
		f:Hide()
		--f.my_real_parent = f:GetParent()
		--f:SetParent(hider)
	end
end

function MovAny:UnlockVisibility(f)
	if not f then
		return
	end
	if not f.MAHidden then
		return
	end
	f.MAHidden = nil
	if f.MAWasShown then
		f.MAWasShown = nil
		--[[if f.my_real_parent then
			f:SetParent(f.my_real_parent)
		end]]
		f:Show()
	end
end

function MovAny.hSetPoint(f, ...)
	if not f then
		return
	end
	--[[if MovAny.lForceProtected[f:GetName()] then
		print(f:GetName())
		return
	end]]
	if f.MAPoint then
		local fn = f:GetName()
		if fn and string.match(fn, "^ContainerFrame[1-9][0-9]*$") then
			local bag = MovAny:GetBagInContainerFrame(f)
			if not bag then
				return
			end
			fn = bag:GetName()
		end
		if InCombatLockdown() and MovAny:IsProtected(f) then
			local closure = function(f)
				return function()
					local p = f.MAPoint
					f.MAPoint = nil
					f:ClearAllPoints()
					if p then
						f:SetPoint(unpack(p))
						f.MAPoint = p
					end
					p = nil
				end
			end
			MovAny.pendingActions[fn..":SetPoint"] = closure(f)
		else
			local p = f.MAPoint
			f.MAPoint = nil
			f:ClearAllPoints()
			f:SetPoint(unpack(p))
			f.MAPoint = p
			p = nil
		end
	end
end

function MovAny:LockPoint(f, opt)
	if not f then
		return
	end
	if not f.MAPoint then
		if f:GetName() and (MovAny.lForcedLock[f:GetName()] or (opt and opt.forcedLock))  then
			if not f.MASetPoint then
				f.MASetPoint = f.SetPoint
				f.SetPoint = MovAny.fVoid
			end
		else
			if not f.MALockPointHook then
				hooksecurefunc(f, "SetPoint", MovAny.hSetPoint)
				f.MALockPointHook = true
			end
			f.MAPoint = {f:GetPoint(1)}
		end
	end
end

function MovAny:UnlockPoint(f)
	if not f then
		return
	end
	f.MAPoint = nil
end

function MovAny:LockParent(f)
	if not f then
		return
	end
	if not f.MAParented and not f.MAParentHook then
		hooksecurefunc(f, "SetParent", MovAny.hSetParent)
		f.MAParentHook = true
	end
	f.MAParented = f:GetParent()
end

function MovAny:UnlockParent(f)
	if not f then
		return
	end
	f.MAParented = nil
end

function MovAny.hSetParent(f, ...)
	if not f then
		return
	end
	if f.MAParented then
		if InCombatLockdown() and MovAny:IsProtected(f) then
			MovAny.pendingFrames[f:GetName()] = API:GetElement(f:GetName())
		else
			local p = f.MAParented
			MovAny:UnlockParent(f)
			f:SetParent(p)
			MovAny:LockParent(f)
		end
	end
end

--[[function MovAny.hSetWidth(f, ...)
	if f.MAScaled then
		local fn = f:GetName()
		if string.match(fn, "^ContainerFrame[0-9]+$") then
			local bag = MovAny:GetBagInContainerFrame(f)
			fn = bag:GetName()
		end
		MovAny.pendingFrames[fn] = API:GetElement(fn)
		if not MovAny:IsProtected(f) or not InCombatLockdown() then
			MovAny:SyncFrames()
		end
	end
end

function MovAny.hSetHeight(f, ...)
	if f.MAScaled then
		local fn = f:GetName()
		if string.match(fn, "^ContainerFrame[0-9]+$") then
			local bag = MovAny:GetBagInContainerFrame(f)
			fn = bag:GetName()
		end
		MovAny.pendingFrames[fn] = API:GetElement(fn)
		if not MovAny:IsProtected(f) or not InCombatLockdown() then
			MovAny:SyncFrames()
		end
	end
end

function MovAny.hSetScale(f, ...)
	if f.MAScaled then
		local fn = f:GetName()
		if string.match(fn, "^ContainerFrame[0-9]+$") then
			local bag = MovAny:GetBagInContainerFrame(f)
			fn = bag:GetName()
		end
		MovAny.pendingFrames[fn] = API:GetElement(fn)
		if not MovAny:IsProtected(f) or not InCombatLockdown() then
			MovAny:SyncFrames()
		end
	end
end

function MovAny:LockScale(f)
	if f.SetScale and not f.MAScaleLocked then
		if not f.MAScaleHook then
			-- the following doesnt work. it needs to be hooked through the metatable somehow, these hooksecurefunc's never fires
			if f.SetWidth then
				hooksecurefunc(f, "SetWidth", MovAny.hSetWidth)
			end
			if f.SetHeight then
				hooksecurefunc(f, "SetHeight", MovAny.hSetHeight)
			end
			if f.SetScale then
				hooksecurefunc(f, "SetScale", MovAny.hSetScale)
			end
			f.MAScaleHook = true
		end
	end
end

function MovAny:UnlockScale(f)
	f.MAScaleLocked = nil
end]]

function MovAny.hSetScale(f)
	if not f then
		return
	end
	if f.MAScaled then
		local fn = f:GetName()
		if string.match(fn, "^ContainerFrame[1-9][0-9]*$") then
			local bag = MovAny:GetBagInContainerFrame(f)
			if not bag then
				if MovAny:IsProtected(f) and InCombatLockdown() then
					MovAny.pendingActions[f:GetName()..":SetScale"] = function()
						if MovAny:IsProtected(f) and InCombatLockdown() then
							return true
						end
						MovAny:Rescale(f, f.MAScaled)
					end
				else
					MovAny:Rescale(f, f.MAScaled)
				end
				return
			end
			fn = bag:GetName()
			if MovAny:IsProtected(f) and InCombatLockdown() then
				MovAny.pendingFrames[fn] = API:GetElement(fn)
			else
				MovAny:Rescale(f, f.MAScaled)
			end
		else
			if MovAny:IsProtected(f) and InCombatLockdown() then
				MovAny.pendingFrames[fn] = API:GetElement(fn)
			else
				MovAny:Rescale(f, f.MAScaled)
			end
		end
	end
end

function MovAny:LockScale(f)
	if not f then
		return
	end
	if f.SetScale and not f.MAScaled then
		local meta = getmetatable(f).__index
		if not meta.MAScaleHook then
			if meta.SetScale then
				hooksecurefunc(meta, "SetScale", MovAny.hSetScale)
			end
			meta.MAScaleHook = true
		end
		f.MAScaled = f:GetScale()
	end
end

function MovAny:UnlockScale(f)
	if not f then
		return
	end
	f.MAScaled = nil
end

function MovAny:Rescale(f, scale)
	if not f then
		return
	end
	MovAny:UnlockScale(f)
	f:SetScale(scale)
	MovAny:LockScale(f)
end

function MovAny.hSyncIfScaled(self, f)
	if not f then
		return
	end
	if f.MAScaled and f:GetName() ~= nil then
		API:SyncElement(f:GetName())
	end
end

function MovAny:LockWH(f)
	if not f then
		return
	end
	if f.SetScale and not f.MAScaled then
		if not f.MAScaleHook then
			if f.SetWidth then
				hooksecurefunc(f, "SetWidth", MovAny.hSyncIfScaled)
			end
			if f.SetHeight then
				hooksecurefunc(f, "SetHeight", MovAny.hSyncIfScaled)
			end
			f.MAScaleHook = true
		end
		f.MAScaled = f:GetScale()
	end
end

function MovAny:HookFrame(e, f, dontUnanchor, runBeforeInteract)
	if not f then
		f = e.f
		if not f then
			return
		end
	end
	if InCombatLockdown() and MovAny:IsProtected(f) then
		return
	end
	if not self:IsValidObject(f) then
		return
	end
	if not runBeforeInteract and e and e.runBeforeInteract and e.runBeforeInteract() then
		return
	end
	local fn = f:GetName()
	local opt = self:GetUserData(fn, nil, true)
	if opt.name == nil then
		opt.name = fn
	end
	if opt.disabled then
		return
	end
	if f.MAOrgScale then
		self:UnlockScale(f)
		f:SetScale(f.MAOrgScale)
		f.MAOrgScale = nil
	end
	if f.MAOrgAlpha then
		f:SetAlpha(f.MAOrgAlpha)
		f.MAOrgAlpha = nil
	end
	if fn == "FocusFrame" then
		f.orgScale = f:GetScale()
		f.scale = f:GetScale()
	end
	if f.SetMovable and e and not e.noMove then
		if f:IsUserPlaced() then
			f.MAWasUserPlaced = true
		end
		if f:IsMovable() then
			f.MAWasMovable = true
		end
		if f:IsResizable() then
			f.MAWasResizable = true
		end
		f:SetMovable(true)
		if f ~= MainMenuBar then
			f:SetUserPlaced(true)
		end
	end
	f.MAE = e
	if not opt.orgPos and e and not e.noMove then
		self.Position:StoreOrgPoints(f, opt)
	end
	if not f.MAHooked then
		if f.OnMAHook and f:OnMAHook() ~= nil then
			return
		end
		f.MAHooked = true
	end
	if not dontUnanchor and e and not e.noUnanchorRelatives and not e.noMove then
		self:UnanchorRelatives(e, f, opt)
	end
	if self.DetachFromParent[fn] and not self.NoReparent[fn] and not f.MAOrgParent then
		f.MAOrgParent = f:GetParent()
		f:SetParent(_G[ self.DetachFromParent[fn] ])
		--self:LockParent(f)
	end
	if f.OnMAPostHook and f.OnMAPostHook(f) ~= nil then
		return
	end
	return opt
end

function MovAny:IsModified(fn, var, opt)
	if fn == nil then
		return
	end
	if type(fn) == "table" then
		fn = fn:GetName()
	end
	opt = opt or self:GetUserData(fn)
	if opt then
		if var then
			if opt[var] then
				return true
			end
		elseif opt.pos or opt.hidden or opt.scale ~= nil or opt.alpha ~= nil or opt.frameStrata ~= nil or opt.disableLayerArtwork ~= nil or opt.disableLayerBackground ~= nil or opt.disableLayerBorder ~= nil or opt.disableLayerHighlight ~= nil or opt.disableLayerOverlay ~= nil or opt.unregisterAllEvents ~= nil or opt.groups ~= nil or opt.forcedLock ~= nil then
			return true
		end
	else
		if MovAny:GetMoverByFrameName(fn) then
			return true
		end
	end
	return false
end

function MovAny:AttachMover(fn, displayName)
	local f = _G[fn]
	if self:ErrorNotInCombat(f) then
		return
	end
	local e = API:AddElementIfNew(fn)
	if e.unsupported then
		string.format(MOVANY.UNSUPPORTED_FRAME, fn)
		return
	end
	if e.noMove and e.noScale and e.noAlpha then
		maPrint(string.format(MOVANY.FRAME_VISIBILITY_ONLY, fn))
		return
	end
	if e.onlyOnceCreated and (f == nil or not f:IsShown()) then
		maPrint(string.format(MOVANY.ONLY_ONCE_CREATED, fn))
		return
	end
	if e and e.refuseSync then
		if type(e.refuseSync) == "string" then
			maPrint(string.format(e.refuseSync, fn))
		end
		return
	end
	if f and type(f) ~= "table" then
		maPrint(string.format(MOVANY.ERROR_NOT_A_TABLE, fn))
		return
	end
	if not self:GetMoverByFrame(f) then
		if e then
			if e.runOnce then
				if not e:runOnce() then
					e.runOnce = nil
				else
					return
				end
			end
			if e.runBeforeInteract and e:runBeforeInteract() then
				return
			end
		end
		local created = nil
		local handled = nil
		if e then
			if e.create and _G[fn] == nil then
				f = CreateFrame("Frame", fn, UIParent, e.create)
				created = true
			else
				f = _G[fn]
			end
		end
		if f and fn ~= f:GetName() then
			fn = f:GetName()
			f = _G[fn]
			e = API:GetElement(fn)
		end
		self.lastFrameName = fn
		if self:IsValidObject(f) then
			local mover = self:GetAvailableMover()
			mover.tagged = f
			if f.OnMAAttach then
				f.OnMAAttach(f, mover)
			end
			API:AddElementIfNew(fn, displayName)
			if self:HookFrame(e, f) then
				if self:AttachMoverToFrame(mover, f) then
					handled = true
					mover.createdTagged = created
					if f.OnMAPostAttach then
						f.OnMAPostAttach(f, mover)
					end
					self:UpdateGUIIfShown()
				end
			end
		end
		if e and e.runAfterInteract then
			e:runAfterInteract(handled)
		end
		return true
	end
end

function MovAny:GetAvailableMover()
	local f
	for id = 1, 1000000, 1 do
		f = _G[self.moverPrefix..id]
		if not f then
			f = CreateFrame("Frame", self.moverPrefix..id, UIParent, "MAMoverTemplate")
			f:SetID(id)
			break
		end
		if not f.tagged then
			break
		end
	end
	if f then
		tinsert(self.movers, f)
		return f
	end
end

function MovAny:GetDefaultFrameParent(f)
	local c = f
	while c and c ~= UIParent and c ~= nil do
		if c.GetName and c:GetName() ~= nil and c:GetName() ~= "" then
			local m = string.match(c:GetName(),"^ContainerFrame[1-9][0-9]*$")
			if m then
				local bag = self:GetBagInContainerFrame(_G[ m ])
				if bag and self:IsModified(bag:GetName()) then
					return _G[bag:GetName()]
				end
			end
			local maParent = c.MAParent
			if maParent then
				if type(maParent) == "string" then
					maParent = self:CreateVM(maParent)
				end
				return maParent
			end
			local transName = self:Translate(c:GetName(),true,true)
			if self:IsModified(transName) then
				return _G[ transName ]
			else
				local frame = API:GetElement(transName)
				if frame then
					return _G[frame.name]
				end
			end
		end
		c = c:GetParent()
	end
	return nil
end

function MovAny:GetTopFrameParent(f)
	local c = f
	local l = nil
	local ln
	local n
	while c and c ~= UIParent do
		if c:IsToplevel() then
			n = c:GetName()
			if n ~= nil and n ~= "" then
				return c
			elseif ln ~= nil then
				return ln
			else
				maPrint(MOVANY.NO_NAMED_FRAMES_FOUND)
				return nil
			end
		end
		l = c
		n = c:GetName()
		if n ~= nil and n ~= "" then
			ln = c
		end
		c = c:GetParent()
	end
	if c == UIParent then
		return l
	end
	return nil
end

function MovAny:ToggleMove(fn)
	local ret = nil
	if self:GetMoverByFrame(fn) then
		ret = self:StopMoving(fn)
	else
		ret = self:AttachMover(fn)
	end
	self.lastFrameName = fn
	self:UpdateGUIIfShown(true)
	return ret
end

function MovAny:ToggleHide(fn)
	local ret = nil
	local f = _G[fn]
	if f and type(f) ~= "table" then
		maPrint(string.format(MOVANY.ERROR_NOT_A_TABLE, fn))
		return
	end
	if f and fn ~= f:GetName() then
		fn = f:GetName()
	end
	self:AttachMover(fn)
	local opt = self:GetUserData(fn, nil, true)
	if not f or not opt.hidden then
		ret = self:HideFrame(fn)
	else
		ret = self:ShowFrame(fn)
	end
	self.lastFrameName = fn
	self:UpdateGUIIfShown(true)
	return ret
end

-- X: bindings
function MovAny:SafeMoveFrameAtCursor()
	local obj = GetMouseFocus()
	while true and obj do
		while true and obj do
			if self:IsMAFrame(obj:GetName()) then
				if self:IsMover(obj:GetName()) then
					if obj.tagged then
						obj = obj.tagged
					else
						return
					end
				elseif not self:IsValidObject(obj, true) then
					obj = obj:GetParent()
					if not obj or obj == UIParent then
						return
					end
				else
					break
				end
			else
				break
			end
		end
		local transName = self:Translate(obj:GetName(), 1)

		if transName ~= obj:GetName() then
			self:ToggleMove(transName)
			break
		end
		local p = obj:GetParent()
		-- check for minimap button
		if (p == MinimapBackdrop or p == Minimap or p == MinimapCluster) and obj ~= Minimap then
			self:ToggleMove(obj:GetName())
			break
		end
		local objTest = self:GetDefaultFrameParent(obj)
		if objTest then
			self:ToggleMove(objTest:GetName())
			break
		end
		objTest = self:GetTopFrameParent(obj)
		if objTest then
			self:ToggleMove(objTest:GetName())
			break
		end
		if obj and obj ~= WorldFrame and obj ~= UIParent and obj.GetName then
			self:ToggleMove(obj:GetName())
		end
		break
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:MoveFrameAtCursor()
	local obj = GetMouseFocus()
	if self:IsMAFrame(obj:GetName()) then
		if self:IsMover(obj:GetName()) and obj.tagged then
			obj = obj.tagged
		elseif not self:IsValidObject(obj) then
			return
		end
	end
	if not self:IsModified(obj:GetName()) and obj.MAParent then
		self:ToggleMove(type(obj.MAParent== "string") and obj.MAParent or obj.MAParent:GetName())
	else
		local transName = self:Translate(obj:GetName(), true, true)
		if transName ~= obj:GetName() then
			self:ToggleMove(transName)
		elseif obj and obj ~= WorldFrame and obj ~= UIParent and obj:GetName() then
			self:ToggleMove(obj:GetName())
		end
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:SafeHideFrameAtCursor()
	local obj = GetMouseFocus()
	while true do
		if self:IsMAFrame(obj:GetName()) then
			if self:IsMover(obj:GetName()) and obj.tagged then
				obj = obj.tagged
			elseif not self:IsValidObject(obj, true) then
				obj = obj:GetParent()
			end
		end
		local transName = self:Translate(obj:GetName(), 1)
		if transName ~= obj:GetName() then
			self:ToggleHide(transName)
			break
		end
		local objTest = self:GetDefaultFrameParent(obj)
		if objTest then
			self:ToggleHide(objTest:GetName())
			break
		end
		objTest = self:GetTopFrameParent(obj)
		if objTest then
			API:AddElementIfNew(objTest:GetName())
			self:ToggleHide(objTest:GetName())
			break
		end
		if obj and obj ~= WorldFrame and obj ~= UIParent then
			API:AddElementIfNew(obj:GetName())
			self:ToggleHide(obj:GetName())
			break
		end
		break
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:HideFrameAtCursor()
	local obj = GetMouseFocus()
	if self:IsMAFrame(obj:GetName()) then
		if self:IsMover(obj:GetName()) and obj.tagged then
			obj = obj.tagged
		else
			return
		end
	end
	if not self:IsModified(obj:GetName()) and obj.MAParent then
		self:ToggleHide(type(obj.MAParent== "string") and obj.MAParent or obj.MAParent:GetName())
	else
		local transName = self:Translate(obj:GetName(), true, true)
		if transName ~= obj:GetName() then
			self:ToggleHide(transName)
		elseif obj and obj ~= WorldFrame and obj ~= UIParent and obj:GetName() then
			self:ToggleHide(obj:GetName())
		end
	end

	self:UpdateGUIIfShown(true)
end

function MovAny:SafeResetFrameAtCursor()
	local obj = GetMouseFocus()
	local fn = obj:GetName()
	while true do
		if fn and self.userData[fn] then
			self:ResetFrameConfirm(fn)
			break
		end
		if self:IsMAFrame(fn) then
			if self:IsMover(fn) and obj.tagged then
				obj = obj.tagged
				self:ResetFrameConfirm(obj:GetName())
				break
			elseif not self:IsValidObject(obj, true) then
				obj = obj:GetParent()
			end
			fn = obj:GetName()
		end
		local transName = self:Translate(fn, 1)
		if transName ~= fn and self.userData[fn] then
			self:ResetFrameConfirm(fn)
			break
		end
		local objTest = self:GetDefaultFrameParent(obj)
		if objTest and self.userData[ objTest:GetName() ] then
			self:ResetFrameConfirm(objTest:GetName())
			break
		end
		objTest = self:GetTopFrameParent(obj)
		if objTest and self.userData[ objTest:GetName() ] then
			self:ResetFrameConfirm(objTest:GetName())
			break
		end
		if obj and obj ~= WorldFrame and obj ~= UIParent and self.userData[fn] then
			self:ResetFrameConfirm(fn)
			break
		end
		break
	end
end

function MovAny:ResetFrameAtCursor()
	local obj = GetMouseFocus()
	if self:IsMAFrame(obj:GetName()) then
		if self:IsMover(obj:GetName()) and obj.tagged then
			obj = obj.tagged
		else
			return
		end
	end
	if InCombatLockdown() and MovAny:IsProtected(obj) then
		self:ErrorNotInCombat(obj)
		return
	end
	local fn
	if not self:IsModified(obj:GetName()) and obj.MAParent then
		fn = type(obj.MAParent == "string") and obj.MAParent or obj.MAParent:GetName()
	else
		fn = self:Translate(obj:GetName(), true, true)
		if transName ~= obj:GetName() then
			fn = transName
		elseif obj and obj ~= WorldFrame and obj ~= UIParent and obj:GetName() then
			fn = obj:GetName()
		end
	end
	if fn and self.userData[fn] then
		self:ResetFrameConfirm(fn)
	end
end

function MovAny:SafeMAFEFrameAtCursor()
	local obj = GetMouseFocus()
	while true and obj do
		while true and obj do
			if self:IsMAFrame(obj:GetName()) then
				if self:IsMover(obj:GetName()) then
					if obj.tagged then
						obj = obj.tagged
					else
						return
					end
				elseif not self:IsValidObject(obj, true) then
					obj = obj:GetParent()
					if not obj or obj == UIParent then
						return
					end
				else
					break
				end
			else
				break
			end
		end
		local transName = self:Translate(obj:GetName(), 1)
		if transName ~= obj:GetName() then
			self:FrameEditor(transName)
			break
		end
		local p = obj:GetParent()
		-- check for minimap button
		if (p == MinimapBackdrop or p == Minimap or p == MinimapCluster) and obj ~= Minimap then
			self:FrameEditor(obj:GetName())
			break
		end
		local objTest = self:GetDefaultFrameParent(obj)
		if objTest then
			self:FrameEditor(objTest:GetName())
			break
		end
		objTest = self:GetTopFrameParent(obj)
		if objTest then
			self:FrameEditor(objTest:GetName())
			break
		end
		if obj and obj ~= WorldFrame and obj ~= UIParent and obj.GetName then
			self:FrameEditor(obj:GetName())
		end
		break
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:MAFEFrameAtCursor()
	local obj = GetMouseFocus()
	if self:IsMAFrame(obj:GetName()) then
		if self:IsMover(obj:GetName()) and obj.tagged then
			obj = obj.tagged
		elseif not self:IsValidObject(obj) then
			return
		end
	end
	if not self:IsModified(obj:GetName()) and obj.MAParent then
		self:FrameEditor(type(obj.MAParent== "string") and obj.MAParent or obj.MAParent:GetName())
	else
		local transName = self:Translate(obj:GetName(), true, true)
		if transName ~= obj:GetName() then
			self:FrameEditor(transName)
		elseif obj and obj ~= WorldFrame and obj ~= UIParent and obj:GetName() then
			self:FrameEditor(obj:GetName())
		end
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:IsMover(fn)
	if fn ~= nil and string.match(fn, "^"..self.moverPrefix.."[0-9]+$") ~= nil then
		return true
	end
end

function MovAny:IsMAFrame(fn)
	if fn ~= nil and (string.match(fn, "^MoveAnything") ~= nil or string.match(fn, "^MA") ~= nil) then
		return true
	end
end

function MovAny:IsContainer(fn)
	if type(fn) == "string" and string.match(fn, "^ContainerFrame[1-9][0-9]*$") then
		return true
	end
end

function MovAny:Translate(f, secondary, nofirst)
	if not nofirst and self.lTranslate[f] then
		return self.lTranslate[f]
	end
	if secondary and self.lTranslateSec[f] then
		return self.lTranslateSec[f]
	end
	if f == "last" then
		return MovAny.lastFrameName
	else
		return f
	end
end

function MovAny:ToggleMovers()
	if _G.MAOptionsToggleMovers:GetChecked() then
		local protected = { }
		for i, v in ipairs(self.minimizedMovers) do
			if InCombatLockdown() and self:IsProtected(v) then
				tinsert(protected, v)
			else
				self:AttachMover(v:GetName())
			end
		end
		table.wipe(self.minimizedMovers)
		self.minimizedMovers = protected
	else
		for i, v in ipairs(MA_tcopy(self.movers)) do
			tinsert(self.minimizedMovers, v.tagged)
			self:StopMoving(v.tagged:GetName())
		end
	end
end

function MovAny:GetMoverByFrame(f)
	if not f then
		return
	end
	if type(f) == "string" then
		f = _G[f]
	end
	for i, m in ipairs(self.movers) do
		if type(m) == "table" and m:IsShown() and m.tagged == f then
			return m
		end
	end
	return nil
end

function MovAny:GetMoverByFrameName(fn)
	if not fn then
		return
	end
	if type(fn) == "table" then
		fn = fn:GetName()
	end
	for i, m in ipairs(self.movers) do
		if type(m) == "table" and m:IsShown() and m.tagged and m.tagged:GetName() == fn then
			return m
		end
	end
	return nil
end

function MovAny:AttachMoverToFrame(mover, f)
	if f.MAHidden == true then
		return
	end
	self:UnlockPoint(f)
	local e = f.MAE
	if not e then
		self:DetachMover(mover)
		return
	end
	mover.MAE = e
	--[[if not string.find(e.name, "Mover") then
		self:ShowFrame(f)
	end]]
	local opt = e.userData or MovAny:GetUserData(e.name, nil, true)
	mover.displayName = e.displayName or f:GetName()
	f.MAMover = mover
	if f.OnMAMoving then
		if not f:OnMAMoving() then
			self:DetachMover(mover)
			return
		end
	end
	local x, y = 0, 0
	if f:GetLeft() == nil and not f:IsShown() then
		f:Show()
		f:Hide()
	end
	mover.attaching = true
	mover.dontUpdate = nil
	if f.IsClampedToScreen then
		mover:SetClampedToScreen(f:IsClampedToScreen())
	end
	opt.disabled = nil
	mover:ClearAllPoints()
	mover:SetPoint("CENTER", f, "CENTER")
	mover:SetWidth(f:GetWidth() * MAGetScale(f))
	mover:SetHeight(f:GetHeight() * MAGetScale(f))
	if f.GetFrameLevel then
		mover:SetFrameLevel(f:GetFrameLevel() + 1)
	end
	if not e.noMove then
		if not opt.pos then
			opt.pos = self:GetRelativePoint(self.Position:GetFirstOrgPoint(opt), f)
		end
		local p = self:GetRelativePoint({"BOTTOMLEFT", UIParent, "BOTTOMLEFT"}, mover)
		mover:ClearAllPoints()
		mover:SetPoint(unpack(p))
		mover.MAStartPoint = self:GetRelativePoint({"BOTTOMLEFT", UIParent, "BOTTOMLEFT"}, f)
		if f.GetScale then
			mover.MAStartScale = f:GetScale()
		end
		f:ClearAllPoints()
		if f.MASetPoint then
			f:MASetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", 0, 0)
		else
			f:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", 0, 0)
		end
		f.orgX = x
		f.orgY = y
	end
	mover.tagged = f
	local label = _G[ mover:GetName().."BackdropInfoLabel"]
	label:Hide()
	label:ClearAllPoints()
	label:SetPoint("CENTER", label:GetParent(), "CENTER", 0, 0)
	mover:Show()
	mover.attaching = nil
	return true
end

function MovAny:DetachMover(mover)
	mover.detaching = true
	local f = mover.tagged
	if mover.tagged and not mover.attaching and not f.MAHidden then
		if mover.MAE and not mover.MAE.noMove and not mover.dontUpdate then
			if mover.MAStartPoint then
				self:MoverUpdatePosition(mover)
			end
			self.Position:Apply(mover.MAE, f)
		end
		if mover.createdTagged then
			mover.tagged:Hide()
		end
		if f.OnMADetach then
			f.OnMADetach(f, mover)
		end
	end
	mover:Hide()
	mover.tagged = nil
	mover.attaching = nil
	mover.infoShown = nil
	mover.MAE = nil
	mover.MAStartPoint = nil
	mover.MAStartScale = nil
	mover.dontUpdate = nil
	if mover.tagged then
		mover.tagged.MAMover = nil
	end
	for i, m in ipairs(self.movers) do
		if m == mover then
			tremove(self.movers, i)
		end
	end
	if self.currentMover == mover then
		self:NudgerChangeMover(1)
	else
		self:NudgerFrameRefresh()
	end
	mover.detaching = nil
end

function MovAny:StopMoving(fn)
	local mover = self:GetMoverByFrame(fn)
	if mover and not self:ErrorNotInCombat(_G[fn]) then
		self:DetachMover(mover)
		self:UpdateGUIIfShown()
	end
end

function MovAny:ResetFrameConfirm(fn)
	local f = _G[fn]
	if InCombatLockdown() and self:IsProtected(f) then
		self:ErrorNotInCombat(f)
		return
	end
	if self.resetConfirm == fn and self.resetConfirmTime + 5 >= time() then
		self.resetConfirm = nil
		maPrint(string.format(MOVANY.RESETTING_FRAME, fn))
		self:ResetFrame(fn)
		return true
	else
		self.resetConfirm = fn
		self.resetConfirmTime = time()
		maPrint(string.format(MOVANY.RESET_FRAME_CONFIRM, fn))
	end
end

function MovAny:ResetFrame(f, dontUpdate, readOnly)
	if not f then
		return
	end
	local fn
	if type(f) == "string" then
		fn = f
		f = _G[fn]
	elseif f and f.GetName then
		fn = f:GetName()
	end
	if not fn then
		return
	end
	if self:ErrorNotInCombat(f) or (InCombatLockdown() and f.UMFP) then
		return
	end
	if not readOnly then
		self:ShowFrame(f)
	else
		self:ShowFrame(f, true, true)
	end
	self:StopMoving(fn)
	self.lastFrameName = fn
	if not f then
		if not readOnly then
			self:ClearUserData(fn)
		end
		if not dontUpdate then
			self:UpdateGUIIfShown(true)
		end
		return
	end
	local e = API:GetElement(fn)
	local opt = e.userData or self:GetUserData(fn)
	if opt == nil then
		opt = { }
	end
	if f.MAHooked then
		e:Reset(f, readOnly, opt)
	end
	if UIPanelWindows[fn] and (not self:IsProtected(f) or not InCombatLockdown()) then
		self:SyncUIPanels()
	end
	if not readOnly then
		e:SetUserData(nil)
		self:ClearUserData(fn)
	end
	if f.attachedChildren then
		table.wipe(f.attachedChildren)
	end
	if not dontUpdate then
		if f:GetObjectType() ~= "Texture" and f:GetObjectType() ~= "FontString" then
			f:SetMovable(true)
			f:SetUserPlaced(false)
			f:SetMovable(false)
		end
		self:UpdateGUIIfShown(true)
	end
end

function MovAny:ToggleGUI()
	if MAOptions:IsShown() then
		MAOptions:Hide()
	else
		MAOptions:Show()
	end
end

function MovAny:OnMoveCheck(button)
	local fn = API:GetItem(button:GetParent().idx).name
	if not self:ToggleMove(fn) then
		local f = _G[fn]
		if self:IsProtected(f) and not InCombatLockdown() then
			button:SetChecked(nil)
		end
	end
end

function MovAny:OnHideCheck(button)
	local fn = API:GetItem(button:GetParent().idx).name
	if not self:ToggleHide(fn) then
		local f = _G[fn]
		if self:IsProtected(f) and not InCombatLockdown() then
			button:SetChecked(nil)
		end
	end
end

function MovAny:OnResetCheck(button)
	local fn = API:GetItem(button:GetParent().idx).name
	local f =  _G[fn]
	if f then
		if fn ~= f:GetName() then
			fn = f:GetName()
			f = _G[fn]
		end
		if MovAny:ErrorNotInCombat(f) then
			return
		end
	end
	MovAny:ResetFrame(f or fn)
end

function MovAny:HideFrame(f, readOnly)
	if not self:IsModified(f) then
		return
	end
	local fn
	if type(f) == "string" then
		fn = f
		f = _G[fn]
	end
	if self:ErrorNotInCombat(f) then
		return
	end
	if not f then
		if self.lVirtualMovers[fn] then
			f = self:CreateVM(fn)
		else
			return
		end
	end
	if not fn then
		fn = f:GetName()
	end
	API:AddElementIfNew(fn)
	if fn == "PaladinPowerBarFrame" then
		f:UnregisterAllEvents()
	elseif fn == "CompactRaidFrameManager" then
		f:UnregisterAllEvents()
		CompactRaidFrameContainer:SetParent(UIParent)
	elseif fn == "Boss1TargetFrame" or fn == "Boss2TargetFrame" or fn == "Boss3TargetFrame" or fn == "Boss4TargetFrame" or fn == "Boss5TargetFrame" then
		f:UnregisterAllEvents()
		f:Hide()
		f.oldShow = f.Show
		f.Show = function()
			-- empty
		end
	elseif fn == "MicroButtonsMover" or fn == "MicroButtonsSplitMover" or fn == "MicroButtonsVerticalMover" or fn == "AchievementMicroButton" then
		AchievementMicroButton.IsShown = function(self)
			local opt = MovAny:GetUserData(fn)
			if opt and opt.hidden then
				return true
			else
				if self:IsShown() then
					return true
				else
					return false
				end
			end
		end
	end
	local e = API:GetElement(fn)
	local mover = self:GetMoverByFrame(f)
	if mover then
		self:DetachMover(mover)
	end
	local opt
	if readOnly then
		opt = { }
	else
		opt = self:GetUserData(fn, nil, true)
		opt.hidden = true
	end
	if not f then
		return true
	end
	if not self:IsValidObject(f) or not self:HookFrame(e, f) or self:ErrorNotInCombat(f) then
		return
	end
	f.MAWasShown = f:IsShown()
	if f.GetAttribute then
		opt.unit = f:GetAttribute("unit")
		if opt.unit then
			f:SetAttribute("unit", nil)
		end
	end
	if e and e.hideList then
		for hIndex, hideEntry in pairs(e.hideList) do
			local val = _G[hideEntry[1]]
			local hideType
			for i = 2, table.getn(hideEntry) do
				hideType = hideEntry[ i ]
				if type(hideType) == "function" then
					hideType(nil)
				elseif hideType == "DISABLEMOUSE" then
					val:EnableMouse(nil)
				elseif hideType == "FRAME" then
					self:LockVisibility(val)
				elseif hideType == "WH" then
					self:StopMoving(fn)
					val:SetWidth(1)
					val:SetHeight(1)
				else
					val:DisableDrawLayer(hideType)
				end
			end
		end
	elseif e and e.hideUsingWH then
		self:StopMoving(fn)
		f:SetWidth(1)
		f:SetHeight(1)
		self:LockVisibility(f)
	else
		self:LockVisibility(f)
	end
	if f.OnMAHide then
		f.OnMAHide(f, true)
	end
	return true
end

function MovAny:ShowFrame(f, readOnly, dontHook)
	local fn
	if type(f) == "string" then
		fn = f
		f = _G[f]
	end
	if self:ErrorNotInCombat(f) then
		return
	end
	if not f then
		if self.lVirtualMovers[fn] then
			f = self:CreateVM(fn)
		else
			return
		end
	end
	if not fn then
		fn = f:GetName()
	end
	API:AddElementIfNew(fn)
	if fn == "PaladinPowerBarFrame" then
		PaladinPowerBar.OnLoad(f)
	elseif fn == "CompactRaidFrameManager" then
		f:RegisterEvent("DISPLAY_SIZE_CHANGED")
		f:RegisterEvent("UI_SCALE_CHANGED")
		f:RegisterEvent("GROUP_ROSTER_UPDATE")
		f:RegisterEvent("UNIT_FLAGS")
		f:RegisterEvent("PLAYER_FLAGS_CHANGED")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("PARTY_LEADER_CHANGED")
		f:RegisterEvent("RAID_TARGET_UPDATE")
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		CompactRaidFrameContainer:ClearAllPoints()
		CompactRaidFrameContainer:SetParent(f)
		MovAny:UnlockPoint(CompactRaidFrameContainer)
		CompactRaidFrameContainer:SetPoint("TOPLEFT", CompactRaidFrameManagerContainerResizeFrame, "TOPLEFT", 4, - 7)
	elseif fn == "Boss1TargetFrame" or fn == "Boss2TargetFrame" or fn == "Boss3TargetFrame" or fn == "Boss4TargetFrame" or fn == "Boss5TargetFrame" then
		f.Show = f.oldShow
		f.oldShow = nil
	end
	--[[local mover = self:GetMoverByFrame(f)
	if mover then
		if not string.find(e.name, "Mover") then
			self:AttachMoverToFrame(mover, f)
		end
	end]]
	local e = API:GetElement(fn)
	local opt = self:GetUserData(fn, nil, true)
	--[[if e and e.userData then
		opt = e.userData
	end]]
	if not readOnly and opt then
		opt.hidden = nil
		opt.unit = nil
	end
	if not f then
		self:VerifyFrameData(fn)
		return true
	end
	if not self:IsValidObject(f) or (not dontHook and not self:HookFrame(e, f)) or self:ErrorNotInCombat(f) then
		return
	end
	if opt ~= nil and opt.unit and f.SetAttribute then
		f:SetAttribute("unit", opt.unit)
	end
	if e and e.hideList then
		for hIndex, hideEntry in pairs(e.hideList) do
			local val = _G[hideEntry[1]]
			for i = 2, table.getn(hideEntry) do
				local hideType = hideEntry[i]
				if type(hideType) == "function" then
					hideType(true)
				elseif hideType == "DISABLEMOUSE" then
					val:EnableMouse(true)
				elseif hideType == "FRAME" then
					self:UnlockVisibility(val)
				elseif hideType == "WH" then
					if type(opt.orgWidth) == "number" then
						val:SetWidth(opt.orgWidth)
					end
					if type(opt.orgHeight) == "number" then
						val:SetHeight(opt.orgHeight)
					end
				else
					val:EnableDrawLayer(hideType)
				end
			end
		end
		self.Layers:Apply(e, f)
	elseif e and e.hideUsingWH then
		if type(opt.orgWidth) == "number" then
			f:SetWidth(opt.orgWidth)
		end
		if type(opt.orgHeight) == "number" then
			f:SetHeight(opt.orgHeight)
		end
		self:UnlockVisibility(f)
	else
		self:UnlockVisibility(f)
	end
	if f.OnMAHide then
		f.OnMAHide(f, nil)
	end
	self:VerifyFrameData(fn)
	return true
end

function MovAny:OnCheckToggleCategories(button)
	local state = button:GetChecked()
	if state then
		self.collapsed = true
	else
		self.collapsed = nil
	end
	for i, v in pairs(API.cats) do
		v.collapsed = state
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:OnCheckToggleModifiedFramesOnly(button)
	local state = button:GetChecked()
	if state then
		MADB.modifiedFramesOnly = true
	else
		MADB.modifiedFramesOnly = nil
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:GroupMove(sender, groups, x, y)
	local f, e, mover
	for g in pairs(groups) do
		for fn, opt in pairs(self.userData) do
			if fn ~= sender.name and type(opt.groups) == "table" and opt.groups[g] and type(opt.pos) == "table" then
				f = _G[fn]
				if f then
					mover = self:GetMoverByFrame(f)
					if mover then
						mover.attaching = true
						self:DetachMover(mover)
					end
					e = API:GetElement(fn)
					if e and e:IsModified("pos") then
						opt.pos[4] = opt.pos[4] + (x / f:GetScale())
						opt.pos[5] = opt.pos[5] + (y / f:GetScale())
						self.Position:Apply(e, f)
					end
					if mover then
						self:AttachMover(fn)
					end
				end
			end
		end
	end
end

function MovAny:GroupScale(sender, groups, scaleMod, scale, dir)
	local f, e, mover
	for g in pairs(groups) do
		for fn, opt in pairs(self.userData) do
			if fn ~= sender.name and type(opt.groups) == "table" and opt.groups[g] then
				f = _G[fn]
				if f then
					mover = self:GetMoverByFrame(f)
					if mover then
						self:DetachMover(mover)
					end
				end
				e = API:GetElement(fn)
				local orgScale = opt.scale or (f and f:GetScale() or 1)
				if not e.scaleWH then
					if opt.pos then
						opt.pos[4] = opt.pos[4] * orgScale
						opt.pos[5] = opt.pos[5] * orgScale
					end
					opt.scale = orgScale + scaleMod
					if opt.pos then
						opt.pos[4] = opt.pos[4] / opt.scale
						opt.pos[5] = opt.pos[5] / opt.scale
					end
				else
					if f then
						if type(opt.orgWidth) ~= "number" then
							opt.orgWidth = f:GetWidth()
						end
						if type(opt.orgHeight) ~= "number" then
							opt.orgHeight = f:GetHeight()
						end
					end
					if dir == 0 then
						if type(opt.width) ~= "number" then
							opt.width = opt.orgWidth
						end
						if type(opt.width) == "number" then
							opt.width = opt.width * (1 + scaleMod)
						end
					elseif dir == 1 then
						if type(opt.height) ~= "number" then
							opt.height = opt.orgHeight
						end
						if type(opt.height) == "number" then
							opt.height = opt.height * (1 + scaleMod)
						end
					end
				end
				if f then
					self.Scale:Apply(e, f)
					if opt.pos then
						self.Position:Apply(e, f)
					end
					if mover then
						self:AttachMover(fn)
					end
				end
			end
		end
	end
end

function MovAny:GroupAlpha(sender, groups, alphaMod, alpha)
	local f, e, fAlpha, mover
	for g in pairs(groups) do
		for fn, opt in pairs(self.userData) do
			if fn ~= sender.name and type(opt.groups) == "table" and opt.groups[g] then
				f = _G[fn]
				if f then
					mover = self:GetMoverByFrame(f)
					if mover then
						self:DetachMover(mover)
					end
				end
				e = API:GetElement(fn)
				if not opt.alpha then
					fAlpha = (f and (f.GetAlpha and f:GetAlpha() or 1) + alphaMod) or alpha
				else
					fAlpha = opt.alpha + alphaMod
				end
				if fAlpha < 0 then
					fAlpha = 0
				elseif fAlpha > 1 then
					fAlpha = 1
				end
				opt.alpha = fAlpha
				self.Alpha:Apply(e, f)
				if mover then
					self:AttachMover(fn)
				end
			end
		end
	end
end

function MovAny:GroupBackdropAlpha(sender, groups, alphaMod, alpha)
	local f, e, fAlpha, mover
	for g in pairs(groups) do
		for fn, opt in pairs(self.userData) do
			if fn ~= sender.name and type(opt.groups) == "table" and opt.groups[g] then
				f = _G[fn]
				if f then
					mover = self:GetMoverByFrame(f)
					if mover then
						self:DetachMover(mover)
					end
				end
				e = API:GetElement(fn)
				if not opt.backdropAlpha then
					local _
					_, _, _, fAlpha = f:GetBackdropColor()
					fAlpha = fAlpha or alpha
				else
					fAlpha = opt.backdropAlpha + alphaMod
				end
				if fAlpha < 0 then
					fAlpha = 0
				elseif fAlpha > 1 then
					fAlpha = 1
				end
				opt.backdropAlpha = fAlpha
				self.Alpha:Apply(e, f)
				if mover then
					self:AttachMover(fn)
				end
			end
		end
	end
end

function MovAny:GroupLayers(sender, groups, layer, opt)
	local f, e
	for g in pairs(groups) do
		for fn, fOpt in pairs(self.userData) do
			if fn ~= sender.name and fOpt.groups and fOpt.groups[g] then
				f = _G[fn]
				if f then
					e = API:GetElement(fn)
					self.Layers:Reset(e, f, true, fOpt)
				end
				fOpt[layer] = opt[layer]
				if f then
					self.Layers:Apply(e, f, fOpt)
				end
			end
		end
	end
end

function MovAny:MoverUpdatePosition(mover)
	if mover.attaching then
		return
	end
	if mover.tagged then
		if not mover.MAE or mover.MAE.noMove then
			return
		end
		local f = mover.tagged
		local opt = mover.MAE.userData
		local p = self:GetRelativePoint({"BOTTOMLEFT", "UIParent", "BOTTOMLEFT"}, f)
		if mover.MAStartPoint and (mover.MAStartPoint[1] == p[1] and mover.MAStartPoint[2] == p[2] and mover.MAStartPoint[3] == p[3] and (mover.MAStartPoint[4] * (mover.MAStartScale or 1)) == p[4]  and (mover.MAStartPoint[5] * (mover.MAStartScale or 1)) == p[5]) then
			return
		end
		p = self:GetRelativePoint(opt.pos or self.Position:GetFirstOrgPoint(opt) or {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT"}, f)
		if not skipGroups and opt.groups and not IsShiftKeyDown() then
			local _, _, _, x, y = unpack(self:GetRelativePoint(p, f, true))
			x = x - opt.pos[4]
			y = y - opt.pos[5]
			if not mover.MAE.scaleWH then
				x = x * (opt.scale or (f.GetScale and f:GetScale()) or 1)
				y = y * (opt.scale or (f.GetScale and f:GetScale()) or 1)
			end
			MovAny:GroupMove(mover.MAE, opt.groups, x, y)
		end
		opt.pos = p
		table.wipe(mover.MAStartPoint)
		for i = 1, 5, 1 do
			mover.MAStartPoint[i] = p[i]
		end
		if f.OnMAPosition then
			f:OnMAPosition()
		end
		self:UpdateGUIIfShown()
	end
end

function MovAny:MoverOnSizeChanged(mover)
	if mover.attaching or mover.detaching then
		return
	end
	if mover.tagged then
		local s, w, h, f, opt
		f = mover.tagged
		local opt = mover.MAE.userData
		if mover.MAE.scaleWH then
			if opt.width ~= mover:GetWidth() or opt.height ~= mover:GetHeight() then
				if not mover.skipGroups and opt.groups and not IsShiftKeyDown() then
					local dir = mover:GetHeight() ~= opt.height and 1 or 0
					if dir == 0 then
						s = mover:GetWidth() / f:GetWidth()
						s = s / MAGetScale(f:GetParent(), 1 ) * UIParent:GetScale()
					else
						s = mover:GetHeight() / f:GetHeight()
						s = s / MAGetScale(f:GetParent(), 1 ) * UIParent:GetScale()
					end
					self:GroupScale(mover.MAE, opt.groups, s - 1, s, dir)
				end
				opt.width = mover:GetWidth()
				opt.height = mover:GetHeight()
				self.Scale:Apply(mover.MAE, f, opt)
				mover.skipGroups = true
				self:MoverUpdatePosition(mover)
				mover.skipGroups = nil
			end
		else
			if mover.MASizingAnchor == "LEFT" or mover.MASizingAnchor == "RIGHT" then
				w = mover:GetWidth()
				h = w * (f:GetHeight() / f:GetWidth())
				if h < 8 then
					h = 8
					w = h * (f:GetWidth() / f:GetHeight())
				end
			else
				h = mover:GetHeight()
				w = h * (f:GetWidth() / f:GetHeight())
				if w < 8 then
					w = 8
					h = w * (f:GetHeight() / f:GetWidth())
				end
			end
			s = mover:GetWidth() / f:GetWidth()
			s = s / MAGetScale(f:GetParent(), 1) * UIParent:GetScale()
			if s > 0.991 and s < 1 then
				s = 1
			end
			if f.GetScale and s ~= f:GetScale() then
				if not mover.skipGroups and opt.groups and not IsShiftKeyDown() then
					self:GroupScale(mover.MAE, opt.groups, s - (opt.scale or f:GetScale()), s)
				end
				opt.scale = s
				self.Scale:Apply(mover.MAE, f)
				--self:MoverUpdatePosition(mover)
				mover.skipGroups = true
				self:MoverUpdatePosition(mover)
				mover.skipGroups = nil
			end
			mover:SetWidth(w)
			mover:SetHeight(h)
			local label = _G[ mover:GetName().."BackdropInfoLabel"]
			label:SetWidth(w+100)
			label:SetHeight(h)
		end
		local label = _G[ mover:GetName().."BackdropInfoLabel"]
		label:ClearAllPoints()
		label:SetPoint("TOP", label:GetParent(), "TOP", 0, 0)
		local brief, long
		if MovAny.Scale:CanBeScaled(f) then
			if mover.MAE.scaleWH then
				brief = "W: "..MANumFor(f:GetWidth()).." H:"..MANumFor(f:GetHeight())
				long = brief
			else
				brief = MANumFor(f:GetScale())
				long = "Scale: "..brief
			end
			label:Show()
			label:SetText(brief)
			if mover == self.currentMover then
				_G[ "MANudgerInfoLabel"]:Show()
				_G[ "MANudgerInfoLabel"]:SetText(long)
			end
		end
		label = _G[ mover:GetName().."BackdropMovingFrameName" ]
		label:ClearAllPoints()
		label:SetPoint("TOP", label:GetParent(), "TOP", 0, 20)
		self:UpdateGUIIfShown(true)
	end
end

function MovAny:MoverOnMouseWheel(mover, arg1)
	if not mover.tagged or mover.MAE.noAlpha then
		return
	end
	local alpha
	if IsAltKeyDown() then
		local r, g, b
		r, g, b, alpha = mover.tagged:GetBackdropColor()
		alpha = alpha or 1
	else
		alpha = mover.tagged:GetAlpha()
	end
	if type(alpha) ~= "number" then
		return
	end
	local alphaMod
	if arg1 > 0 then
		alphaMod = 0.05
	else
		alphaMod = - 0.05
	end
	alpha = alpha + alphaMod
	if alpha < 0 then
		alpha = 0
		mover.tagged.alphaAttempts = nil
	elseif alpha > 0.99 then
		alpha = 1
		mover.tagged.alphaAttempts = nil
	elseif alpha > 0.92 then
		if not mover.tagged.alphaAttempts then
			mover.tagged.alphaAttempts = 1
		elseif mover.tagged.alphaAttempts > 2 then
			alpha = 1
			mover.tagged.alphaAttempts = nil
		else
			mover.tagged.alphaAttempts = mover.tagged.alphaAttempts + 1
		end
	else
		mover.tagged.alphaAttempts = nil
	end
	alpha = tonumber(MANumFor(alpha))
	local opt = mover.MAE.userData
	if IsAltKeyDown() then
		if not mover.skipGroups and opt.groups and not IsShiftKeyDown() then
			self:GroupBackdropAlpha(mover.MAE, opt.groups, alphaMod, alpha)
		end
		opt.backdropAlpha = alpha
		if opt.backdropAlpha == opt.orgBackdropAlpha then
			opt.backdropAlpha = nil
			opt.orgBackdropAlpha = nil
		end
	else
		if not mover.skipGroups and opt.groups and not IsShiftKeyDown() then
			self:GroupAlpha(mover.MAE, opt.groups, alphaMod, alpha)
		end
		opt.alpha = alpha
		if opt.alpha == opt.orgAlpha then
			opt.alpha = nil
			opt.orgAlpha = nil
		end
	end
	self.Alpha:Apply(mover.tagged.MAE, mover.tagged)
	local label = _G[ mover:GetName().."BackdropInfoLabel"]
	label:Show()
	label:SetText(MANumFor(alpha * 100).."%")
	if mover == self.currentMover then
		_G["MANudgerInfoLabel"]:Show()
		_G["MANudgerInfoLabel"]:SetText("Alpha:"..MANumFor(alpha * 100).."%")
	end
	self:UpdateGUIIfShown(true)
end

function MovAny:CompleteReset()
	for i, v in pairs(self.userData) do
		self:ResetFrame(v.name, true, true)
	end
	self:ReanchorRelatives()
	if MADB.squareMM then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
	end
	MADB = {
		collapsed = true,
		frameListRows = 18,
		tooltips = true,
	}
	MADB.profiles = { }
	MADB.characters = { }
	self.userData = { }
	MADB.profiles[self:GetProfileName()] = {frames = self.userData}
	MAOptionsToggleCategories:SetChecked(true)
	MovAny:OnCheckToggleCategories(MAOptionsToggleCategories)
	MovAny_OptionsOnShow()
	self:UpdateGUIIfShown(true)
end

function MovAny:OnShow()
	if MADB.playSound then
		PlaySound(850)
	end
	MADB.autoShowNext = true
	MANudger:Show()
	self:NudgerFrameRefresh()
	self:UpdateGUI()
	for i, v in pairs(self.lEnableMouse) do
		if v and v.EnableMouse and (not MovAny:IsProtected(v) or not InCombatLockdown()) then
			v:EnableMouse(true)
		end
	end
end

function MovAny:OnHide()
	if MADB.playSound then
		PlaySound(851)
	end
	MADB.autoShowNext = nil
	if not self.currentMover then
		MANudger:Hide()
	end
	for i, v in pairs(self.lEnableMouse) do
		if v and v.EnableMouse and (not MovAny:IsProtected(v) or not InCombatLockdown()) then
			v:EnableMouse(nil)
		end
	end
end

function MovAny:RowTitleClicked(title)
	local o = API:GetItem(MAGetParent(title).idx)
	if o.elems then
		if o.collapsed then
			o.collapsed = nil
		else
			o.collapsed = true
		end
		self:UpdateGUI(1)
	else
		if self.FrameEditor then
			self:FrameEditor(o.name)
		end
	end
end

local uiDisplayedFrameNames = { }

function MovAny:CountGUIItems()
	if API.compile then
		API:CompileList()
	end
	local items = 0
	local curCatItems = 0
	local curCat = nil
	if self.searchWord and self.searchWord ~= "" then
		local uiDisplayedFrameNames = { }
		for i, o in pairs(API.all) do
			if not o.elems and not uiDisplayedFrameNames[o.name] then
				if (not MADB.dontSearchFrameNames and string.match(string.lower(tostring(o.name)), self.searchWord)) or (o.displayName and string.match(string.lower(tostring(o.displayName)), self.searchWord)) then
					if MADB.modifiedFramesOnly then
						if MovAny:IsModified(o.name) then
							uiDisplayedFrameNames[o.name] = 1
							items = items + 1
						end
					else
						uiDisplayedFrameNames[o.name] = 1
						items = items + 1
					end
				end
			end
		end
	else
		for i, o in pairs(API.all) do
			if o.elems then
				if curCat then
					curCat.items = curCatItems
					curCatItems = 0
				end
				curCat = o
			elseif not o.hidden then
				if MADB.modifiedFramesOnly then
					if MovAny:IsModified(o.name) then
						curCatItems = curCatItems + 1
					end
				else
					curCatItems = curCatItems + 1
				end
			end
		end
		if curCat then
			curCat.items = curCatItems
		end
		for i, o in pairs(API.all) do
			if o.elems then
				if not MADB.modifiedFramesOnly then
					if o.collapsed then
						items = items + 1
					else
						items = items + o.items + 1
					end
				else
					if o.items > 0 then
						if o.collapsed then
							items = items + 1
						else
							items = items + o.items + 1
						end
					end
				end
			end
		end
	end
	self.guiLines = items
end

function MovAny:UpdateGUI(recount)
	if recount or MovAny.guiLines == - 1 then
		MovAny:CountGUIItems()
	end
	FauxScrollFrame_Update(MAScrollFrame, MovAny.guiLines, MADB.frameListRows, MovAny.SCROLL_HEIGHT)
	local topOffset = FauxScrollFrame_GetOffset(MAScrollFrame)
	local displayList = { }
	local lastCat = nil
	local uiDisplayedFrameNames = { }
	if MovAny.searchWord and MovAny.searchWord ~= "" then
		local results = { }
		local skip = topOffset
		for i, o in pairs(API.all) do
			if not o.elems and not uiDisplayedFrameNames[o.name] then
				if (not MADB.dontSearchFrameNames and string.match(string.lower(o.name), MovAny.searchWord)) or (o.displayName and string.match(string.lower(o.displayName), MovAny.searchWord)) then
					if MADB.modifiedFramesOnly then
						if o:IsModified() then
							uiDisplayedFrameNames[o.name] = 1
							tinsert(results, o)
						end
					else
						uiDisplayedFrameNames[o.name] = 1
						tinsert(results, o)
					end
				end
			end
		end
		table.sort(results, function(o1,o2)
			return o1.displayName:lower() < o2.displayName:lower()
		end)
		for i, o in pairs(results) do
			if skip > 0 then
				skip = skip - 1
			else
				tinsert(displayList, o)
			end
		end
		results = nil
	else
		local startOffset = 0
		local hidden = 0
		local shown = 0
		for i, o in pairs(API.all) do
			if startOffset == 0 and shown >= topOffset then
				startOffset = topOffset + hidden
				break
			end
			if o.elems then
				lastCat = o
				if o.items == 0 then
					hidden = hidden + 1
				else
					shown = shown + 1
				end
			else
				if lastCat and lastCat.collapsed then
				else
					if lastCat.items > 0 then
						shown = shown + 1
					else
						hidden = hidden + 1
					end
				end
			end
		end
		if startOffset ~= 0 then
			-- X: fix off by one
			if startOffset > 0 then
				startOffset = startOffset + 1
			end
		end
		local sepOffset, wtfOffset
		sepOffset = 0
		wtfOffset = 0
		local skip = topOffset
		for i = 1, MADB.frameListRows, 1 do
			local index = i + sepOffset + wtfOffset
			local o
			-- forward to next shown element
			while true do
				if index > API.allCount then
					o = nil
					break
				end
				o = API.all[ index ]
				if o.elems then
					lastCat = o
					if o.items > 0 then
						if skip > 0 then
							index = index + 1
							wtfOffset = wtfOffset + 1
							skip = skip -1
						else
							if o.elems and o.collapsed then
								sepOffset = sepOffset + o.items
							end
							break
						end
					else
						index = index + 1
						wtfOffset = wtfOffset + 1
					end
				else
					local c = lastCat or o:GetCategory()
					if c.collapsed then
						index = index + 1
						wtfOffset = wtfOffset + 1
					else
						if MADB.modifiedFramesOnly then
							if MovAny:IsModified(o.name) then
								if skip > 0 then
									index = index + 1
									wtfOffset = wtfOffset + 1
									skip = skip -1
								else
									break
								end
							else
								index = index + 1
								wtfOffset = wtfOffset + 1
							end
						else
							if skip > 0 then
								index = index + 1
								wtfOffset = wtfOffset + 1
								skip = skip -1
							else
								break
							end
						end
					end
				end
			end
			if o then
				tinsert(displayList, o)
			else
				break
			end
		end
	end
	local prefix, move, backdrop, hide
	prefix = "MAMove"
	move = "Move"
	hide = "Hide"
	local skip = topOffset
	for i = 1, MADB.frameListRows, 1 do
		local o = displayList[i]
		local row = _G[ prefix..i ]
		if not o then
			row:Hide()
		else
			local fn = o.name
			local opts = o.userData
			local moveCheck = _G[ prefix..i..move ]
			local hideCheck = _G[ prefix..i..hide ]
			local text, frameNameLabel
			local idx = o:GetAllIndex()
			frameNameLabel = _G[ prefix..i.."FrameName" ]
			if not frameNameLabel then
				break
			end
			frameNameLabel.idx = idx
			row.idx = idx
			row.name = o.name
			row:Show()
			if o.elems then
				text = _G[ prefix..i.."FrameNameText" ]
				text:Hide()
				text = _G[ prefix..i.."FrameNameHighlight" ]
				text:Show()
				if o.collapsed and o.items > 0 then
					text:SetText("+ "..o.name)
				else
					text:SetText("   "..o.name)
				end
				frameNameLabel.tooltipLines = nil
			else
				text = _G[ prefix..i.."FrameNameHighlight" ]
				text:Hide()
				text = _G[ prefix..i.."FrameNameText" ]
				text:Show()
				text:SetText((opts and opts.disabled and "*" or "")..o.displayName)
			end
			if not o.unsupported and not o.elems and fn then
				_G[ prefix..i.."Backdrop" ]:Show()
				if o.noMove and o.noScale and o.noAlpha then
					moveCheck:Hide()
				else
					moveCheck:SetChecked(MovAny:GetMoverByFrame(fn) and 1 or nil)
					moveCheck:Show()
				end
				if o.noHide then
					hideCheck:Hide()
				else
					hideCheck:SetChecked(opts and opts.hidden or nil)
					hideCheck:Show()
				end
				if MovAny:IsModified(fn) then
					_G[ prefix..i.."Reset" ]:Show()
				else
					_G[ prefix..i.."Reset" ]:Hide()
				end
			else
				_G[ prefix..i.."Backdrop" ]:Hide()
				moveCheck:Hide()
				hideCheck:Hide()
				_G[ prefix..i.."Reset" ]:Hide()
			end
		end
	end
	MAOptionsToggleCategories:SetChecked(MovAny.collapsed)
	MAOptionsToggleModifiedFramesOnly:SetChecked(MADB.modifiedFramesOnly)
	if MovAny.searchWord and MovAny.searchWord ~= "" then
		MAOptionsFrameNameHeader:SetText(string.format(MOVANY.LIST_HEADING_SEARCH_RESULTS, MovAny.guiLines))
	else
		MAOptionsFrameNameHeader:SetText(MOVANY.LIST_HEADING_CATEGORY_AND_FRAMES)
	end
	MovAny:TooltipHide()
end

function MovAny:UpdateGUIIfShown(recount, dontUpdateEditors)
	if recount then
		self.guiLines = - 1
	end
	if MAOptions and MAOptions:IsShown() then
		self:UpdateGUI()
	end
	if not dontUpdateEditors then
		for fn, fe in pairs(self.frameEditors) do
			if fe:IsShown() and not fe.updating then
				fe:UpdateEditor()
			end
		end
	end
	if self.portDlg and self.portDlg:IsShown() then
		self.portDlg:Reload()
	end
end

function MovAny:NudgerChangeMover(dir)
	local p
	local first, sel
	local cur = self.currentMover
	local matchNext = false
	for i, m in ipairs(self.movers) do
		if not first then
			first = m
		end
		if matchNext then
			self.currentMover = m
			matchNext = nil
			break
		end
		if m == cur then
			if dir < 0 then
				if first == m then
					for i2, m2 in ipairs(self.movers) do
						sel = m2
					end
					self.currentMover = sel
				else
					self.currentMover = p
				end
				break
			else
				matchNext = true
			end
		end
		p = m
	end
	if matchNext then
		self.currentMover = first
	end
	self:NudgerFrameRefresh()
end

function MovAny:GetFirstMover()
	for i, m in ipairs(self.movers) do
		if m and m.IsShown and m:IsShown() then
			return m
		end
	end
	return nil
end

function MovAny:MoverOnShow(mover)
	local mn = mover:GetName()
	MANudger:Show()
	self.currentMover = mover
	self:NudgerFrameRefresh()
	mover.startAlpha = mover.tagged:GetAlpha()
	_G[mn.."Backdrop"]:Show()
	_G[mn.."BackdropMovingFrameName"]:SetText(mover.displayName)
	if not mover.tagged or not MovAny.Scale:CanBeScaled(mover.tagged) then
		_G[mn.."Resize_TOP"]:Hide()
		_G[mn.."Resize_LEFT"]:Hide()
		_G[mn.."Resize_BOTTOM"]:Hide()
		_G[mn.."Resize_RIGHT"]:Hide()
	else
		_G[mn.."Resize_TOP"]:Show()
		_G[mn.."Resize_LEFT"]:Show()
		_G[mn.."Resize_BOTTOM"]:Show()
		_G[mn.."Resize_RIGHT"]:Show()
	end
	_G[ mn.."BackdropInfoLabel"]:SetText("")
	if mover == self.currentMover then
		_G[ "MANudgerInfoLabel"]:SetText("")
	end
end

function MovAny:MoverOnHide()
	local firstMover = self:GetFirstMover()
	if not MADB.alwaysShowNudger and firstMover == nil then
		MANudger:Hide()
	else
		self.currentMover = firstMover
		self:NudgerFrameRefresh()
	end
end

function MovAny:NudgerOnShow()
	if not MADB.alwaysShowNudger then
		local firstMover = self:GetFirstMover()
		if firstMover == nil then
			MANudger:Hide()
			return
		end
	end
	self:NudgerFrameRefresh()
end

function MovAny:NudgerFrameRefresh()
	local labelText = ""
	if self.currentMover ~= nil then
		local cur = 0
		for i, m in ipairs(self.movers) do
			cur = cur + 1
			if m == self.currentMover then
				break
			end
		end
		local f = self.currentMover.tagged
		if f then
			labelText = cur.." / "..#self.movers
			local fn = f:GetName()
			if fn then
				labelText = labelText.."\n"..fn
				MANudger.idx = API:GetElement(fn).idx
				if self.currentMover.MAE and self.currentMover.MAE.noHide then
					MANudger_Hide:Hide()
				else
					MANudger_Hide:Show()
				end
			end
		end
	end
	local moverCount = #self.movers
	if moverCount > 0 then
		MANudger_CenterH:Show()
		MANudger_CenterV:Show()
		MANudger_NudgeLeft:Show()
		MANudger_NudgeUp:Show()
		MANudger_NudgeDown:Show()
		MANudger_NudgeRight:Show()
		MANudger_CenterMe:Show()
		MANudger_Detach:Show()
		MANudger_Hide:Show()
		MANudgerMouseOver:ClearAllPoints()
		MANudgerMouseOver:SetPoint("BOTTOM", MANudger, "BOTTOM", 0, 6)
		MANudgerInfoLabel:Show()
		if #self.movers > 1 then
			MANudger_MoverMinus:Show()
			MANudger_MoverPlus:Show()
		else
			MANudger_MoverMinus:Hide()
			MANudger_MoverPlus:Hide()
		end
	else
		MANudger_CenterH:Hide()
		MANudger_CenterV:Hide()
		MANudger_NudgeLeft:Hide()
		MANudger_NudgeUp:Hide()
		MANudger_NudgeDown:Hide()
		MANudger_NudgeRight:Hide()
		MANudger_CenterMe:Hide()
		MANudger_Detach:Hide()
		MANudger_Hide:Hide()
		MANudgerMouseOver:ClearAllPoints()
		MANudgerMouseOver:SetPoint("CENTER", MANudger, "CENTER", 0, 0)
		MANudgerInfoLabel:Hide()
		MANudgerInfoLabel:SetText("")
		MANudger_MoverMinus:Hide()
		MANudger_MoverPlus:Hide()
	end
	MANudgerTitle:SetText(labelText)
end

function MovAny:NudgerOnUpdate()
	local obj = GetMouseFocus()
	local text = ""
	local text2 = ""
	local label = MANudgerMouseOver
	local labelSafe = MANudgerMouseOver
	local name
	if obj and obj ~= WorldFrame and obj:GetName() then
		local objTest = self:GetDefaultFrameParent(obj)
		if objTest then
			name = objTest:GetName()
			if name then
				text = text.."Safe: "..name
			end
		else
			objTest = self:GetTopFrameParent(obj)
			if objTest then
				name = objTest:GetName()
				if name then
					text = text.."Safe: "..objTest:GetName()
				end
			end
		end
	end
	if obj and obj ~= WorldFrame and obj:GetName() then
		name = obj:GetName()
		if name then
			text2 = "Mouseover: "..text2..name
		end
		if obj:GetParent()  and obj:GetParent() ~= WorldFrame and obj:GetParent():GetName() then
			name = obj:GetParent():GetName()
			if name then
				text2 = text2.."\nParent: "..name
			end
			if obj:GetParent():GetParent() and obj:GetParent():GetParent() ~= WorldFrame and obj:GetParent():GetParent():GetName() then
				name = obj:GetParent():GetParent():GetName()
				if name then
					text2 = text2.."\nParent's Parent: "..name
				end
			end
		end
	end
	if not string.find(text2, "MANudger") then
		label:SetText(text2.."\n"..text)
	else
		label:SetText(text)
	end
end

function MovAny:Center(lock)
	local mover = self.currentMover
	local x, y
	if lock == 0 then
		-- Both
		mover:ClearAllPoints()
		mover:SetPoint("CENTER",0,0)
		x = mover:GetLeft()
		y = mover:GetBottom()
		mover:ClearAllPoints()
		mover:SetPoint("BOTTOMLEFT",x,y)
	else
		x = mover:GetLeft()
		y = mover:GetBottom()
		mover:ClearAllPoints()
		if lock == 1 then
			-- Horizontal
			mover:SetPoint("CENTER",0,0)
			x = mover:GetLeft()
			mover:ClearAllPoints()
			mover:SetPoint("BOTTOMLEFT",x,y)
		elseif lock == 2 then
			-- Vertical
			mover:SetPoint("CENTER",0,0)
			y = mover:GetBottom()
			mover:ClearAllPoints()
			mover:SetPoint("BOTTOMLEFT",x,y)
		end
	end
	mover.skipGroups = true
	self:MoverUpdatePosition(mover)
	mover.skipGroups = nil
end

function MovAny:Nudge(dir, button)
	local x, y, offsetX, offsetY, parent, mover, offsetAmount
	mover = self.currentMover
	if not mover:IsShown() then
		return
	end
	x = mover:GetLeft()
	y = mover:GetBottom()
	if button == "RightButton" then
		if IsShiftKeyDown() then
			offsetAmount = 250
		else
			offsetAmount = 50
		end
	else
		if IsShiftKeyDown() then
			offsetAmount = 10
		elseif IsAltKeyDown() then
			offsetAmount = 0.1
		else
			offsetAmount = 1
		end
	end
	if dir == 1 then
		offsetX = 0
		offsetY = offsetAmount
	elseif dir == 2 then
		offsetX = 0
		offsetY = - offsetAmount
	elseif dir == 3 then
		offsetX = - offsetAmount
		offsetY = 0
	elseif dir == 4 then
		offsetX = offsetAmount
		offsetY = 0
	end
	mover:ClearAllPoints()
	mover:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x + offsetX, y + offsetY)
	self:MoverUpdatePosition(mover)
end

function MovAny:SizingAnchor(button)
	local s, e = string.find(button:GetName(), "Resize_")
	local anchorto = string.sub(button:GetName(), e + 1)
	local anchor
	if anchorto == "LEFT"  then
		anchor = "RIGHT"
	elseif anchorto == "RIGHT" then
		anchor = "LEFT"
	elseif anchorto == "TOP"  then
		anchor = "BOTTOM"
	elseif anchorto == "BOTTOM" then
		anchor = "TOP"
	end
	return anchorto, anchor
end

function MovAny:SyncUIPanel(mn, f)
	local mover = _G[mn]
	if f and (f ~= LootFrame or GetCVar("lootUnderMouse") ~= "1") and not MovAny:IsModified(f) and not MovAny:GetMoverByFrame(f) then
		if self:IsModified(mn) then
			if MovAny:IsProtected(f) and InCombatLockdown() then
				local closure = function(f)
					return function()
						if MovAny:IsProtected(f) and InCombatLockdown() then
							return true
						end
						MovAny:UnlockPoint(f)
						f:ClearAllPoints()
						local UIPOpt = UIPanelWindows[f:GetName()]
						local x = 0
						local y = 0
						if not UIPOpt or not UIPOpt.xoffset then
							x = 16
							y  = -12
						end
						f:SetPoint("TOPLEFT", mn, "TOPLEFT", x, y)
						if not f.MAOrgScale then
							f.MAOrgScale = f:GetScale()
						end
						f:SetScale(mover:GetScale())
						if not f.MAOrgAlpha then
							f.MAOrgAlpha = f:GetAlpha()
						end
						f:SetAlpha(mover:GetAlpha())
					end
				end
				MovAny.pendingActions[f:GetName()..":UIPanel"] = closure(f)
			else
				MovAny:UnlockPoint(f)
				f:ClearAllPoints()
				local UIPOpt = UIPanelWindows[f:GetName()]
				local x = 0
				local y = 0
				if not UIPOpt or not UIPOpt.xoffset then
					x = 16
					y  = -12
				end
				f:SetPoint("TOPLEFT", mn, "TOPLEFT", x, y)

				if not f.MAOrgScale then
					f.MAOrgScale = f:GetScale()
				end
				f:SetScale(mover:GetScale())

				if not f.MAOrgAlpha then
					f.MAOrgAlpha = f:GetAlpha()
				end
				f:SetAlpha(mover:GetAlpha())
			end
		elseif f.MAOrgScale or f.MAOrgAlpha then
			if MovAny:IsProtected(f) and InCombatLockdown() then
				local closure = function(f)
					return function()
						if MovAny:IsProtected(f) and InCombatLockdown() then
							return true
						end
						if f.MAOrgScale then
							f:SetScale(f.MAOrgScale)
							f.MAOrgScale = nil
						end
						if f.MAOrgAlpha then
							f:SetAlpha(f.MAOrgAlpha)
							f.MAOrgAlpha = nil
						end
					end
				end
				MovAny.pendingActions[f:GetName()..":UIPanel"] = closure(f)
			else
				if f.MAOrgScale then
					f:SetScale(f.MAOrgScale)
					f.MAOrgScale = nil
				end
				if f.MAOrgAlpha then
					f:SetAlpha(f.MAOrgAlpha)
					f.MAOrgAlpha = nil
				end
			end
		end
	end
end

function MovAny:SyncUIPanels()
	local self = MovAny
	local f = GetUIPanel("left")
	if f then
		self:SyncUIPanel("UIPanelMover1", f)
		f = GetUIPanel("center")
		if f then
			self:SyncUIPanel("UIPanelMover2", f)
			f = GetUIPanel("right")
			if f then
				self:SyncUIPanel("UIPanelMover3", f)
			end
		end
	else
		f = GetUIPanel("doublewide")
		if f then
			self:SyncUIPanel("UIPanelMover1", f)
			f = GetUIPanel("right")
			if f then
				self:SyncUIPanel("UIPanelMover3", f)
			end
		end
	end
end

function MovAny:GetContainerFrame(id)
	local i = 1
	local container
	while true do
		container = _G["ContainerFrame"..i]
		if not container then
			break
		end
		if container:IsShown() and container:GetID() == id then
			return container
		end
		i = i + 1
	end
	return nil
end

function MovAny:GetBagInContainerFrame(f)
	return self:GetBag(f:GetID())
end

function MovAny:GetBag(id)
	return self.bagFrames[id]
end

function MovAny:SetBag(id, bag)
	self.bagFrames[id] = bag
end

function MovAny:GrabContainerFrame(container, movableBag)
	if movableBag and MovAny:IsModified(movableBag) then
		movableBag:Show()
		MovAny:UnlockScale(container)
		container:SetScale(MAGetScale(movableBag))
		MovAny:LockScale(container)
		MovAny:UnlockPoint(container)
		container:ClearAllPoints()
		container:SetPoint("CENTER", movableBag, "CENTER", 0, 0)
		MovAny:LockPoint(container)
		movableBag.attachedChildren = { }
		tinsert(movableBag.attachedChildren, container)
		container:SetAlpha(movableBag:GetAlpha())
	end
end

function MovAny:UnanchorRelatives(e, f, opt)
	if f.GetName and f:GetName() ~= nil and e.noUnanchorRelatives then
		return
	end
	if not f.GetParent then
		return
	end
	local p = f:GetParent()
	if not p then
		return
	end
	opt = opt or self:GetUserData(f:GetName())
	local named = { }
	self:_AddNamedChildren(named, f)
	local relatives = MA_tcopy(named)
	relatives[f] = f
	if p.GetRegions then
		local children = {p:GetRegions()}
		if children ~= nil then
			for i, v in ipairs(children) do
				self:_AddDependents(relatives, v)
			end
		end
	end
	--local num = p:GetNumChildren()
	--assert((num < 8000), "Too much childrens stuck in owerflow")
	if p.GetChildren then
		local children = {p:GetChildren()}
		if children ~= nil then
			for i, v in ipairs(children) do
				if not v:IsForbidden() and not v:IsProtected() then
					self:_AddDependents(relatives, v)
				end
			end
		end
	end
	relatives[f] = nil
	relatives[GameTooltip] = nil
	for i, v in pairs(named) do
		relatives[v] = nil
	end
	-- local fRel = self:ForcedDetachFromParent(f:GetName())
	local fRel = (select(2, opt.orgPos))
	if fRel == nil then
		fRel = (select(2, f:GetPoint(1)))
	end
	local size = tlen(relatives)
	if size > 0 then
		local unanchored = { }
		local x, y, i
		for i, v in pairs(relatives) do
			if v:GetName() ~= nil and not self:IsContainer(v:GetName()) and not string.match(v:GetName(), "BagFrame[1-9][0-9]*") and not self.NoUnanchoring[v:GetName()] and not v.MAPoint then
				-- alternatively use not self:GetUserData(v:GetName()) instead of v.MAPoint
				if v:GetRight() ~= nil and v:GetTop() ~= nil then
					local p = {v:GetPoint(1)}
					p[2] = fRel
					p = MovAny:GetRelativePoint(p, v, true)
					if MovAny:IsProtected(v) and InCombatLockdown() then
						MovAny:AddPendingPoint(v, p)
					else
						v.MAOrgPoint = {v:GetPoint(1)}
						MovAny:UnlockPoint(v)
						v:ClearAllPoints()
						v:SetPoint(unpack(p))
						MovAny:LockPoint(v)
					end
					unanchored[ i ] = v
				end
			end
		end
		if i ~= nil then
			f.MAUnanchoredRelatives = unanchored
		end
	end
end

function MovAny:_AddDependents(l, f)
	if MovAny:IsProtected(f) and InCombatLockdown() then
		return
	end
	local _, relativeTo = f:GetPoint(1)
	if relativeTo and l[relativeTo] then
		l[f] = f
	end
end

function MovAny:_AddNamedChildren(l, f)
	if f.GetChildren then
		local children = {f:GetChildren()}
		if children ~= nil then
			for i, v in pairs(children) do
				self:_AddNamedChildren(l, v)
				if v.GetName then
					local n = v:GetName()
					if n then
						l[v] = v
					end
				end
			end
		end
	end
	if f.attachedChildren then
		local children = f.attachedChildren
		if children ~= nil then
			for i, v in pairs(children) do
				self:_AddNamedChildren(l, v)
				if v.GetName then
					local n = v:GetName()
					if n then
						l[v] = v
					end
				end
			end
		end
	end
end

function MovAny:ReanchorRelatives()
	for i, v in pairs(self.userData) do
		local f = _G[v.name]
		if f and f.MAUnanchoredRelatives then
			for k, r in pairs(f.MAUnanchoredRelatives) do
				if not MovAny:IsModified(r) then
					MovAny:UnlockPoint(r)
					if r.MAOrgPoint then
						r:SetPoint(unpack(r.MAOrgPoint))
						r.MAOrgPoint = nil
					end
				end
			end
			f.MAUnanchoredRelatives = nil
		end
	end
end

function MovAny:AddPendingPoint(f, p)
	local closure = function(f, p)
		return function()
			if MovAny:IsProtected(f) and InCombatLockdown() then
				return true
			end
			if not f.MAOrgPoint then
				f.MAOrgPoint = {f:GetPoint(1)}
			end
			MovAny:UnlockPoint(f)
			f:ClearAllPoints()
			--MovAny:SetPoint(f, p)
			if f.MASetPoint then
				f:MASetPoint(unpack(p))
			else
				f:SetPoint(unpack(p))
			end
			MovAny:LockPoint(f)
		end
	end
	local fn = f:GetName()
	MovAny.pendingActions[fn..":Point"] = closure(f, p)
end

function MovAny:GetSerializedPoint(f, num)
	num = num or 1
	local point, rel, relPoint, x, y = f:GetPoint(num)
	if point then
		if rel and rel.GetName and rel:GetName() ~= "" then
			rel = rel:GetName()
		else
			rel = "UIParent"
		end
		return {point, rel, relPoint, x, y}
	end
	return nil
end

function MovAny:GetRelativePoint(o, f, lockRel)
	if not o then
		o = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT"}
	end
	local rel = o[2]
	if rel == nil then
		rel = UIParent
	end
	if type(rel) == "string" then
		rel = _G[rel]
	end
	if not rel then
		return
	end
	local point = o[1]
	local relPoint = o[3]
	if not lockRel then
		local newRel = self:ForcedDetachFromParent(f:GetName())
		if newRel then
			rel = _G[newRel]
			point = "BOTTOMLEFT"
			relPoint = "BOTTOMLEFT"
		end
		if not rel then
			return
		end
	end
	local rX, rY, pX, pY
	if rel:GetLeft() ~= nil then
		if relPoint == "TOPRIGHT" then
			rY = rel:GetTop()
			rX = rel:GetRight()
		elseif relPoint == "TOPLEFT" then
			rY = rel:GetTop()
			rX = rel:GetLeft()
		elseif relPoint == "TOP" then
			rY = rel:GetTop()
			rX = (rel:GetRight() + rel:GetLeft()) / 2
		elseif relPoint == "BOTTOMRIGHT" then
			rY = rel:GetBottom()
			rX = rel:GetRight()
		elseif relPoint == "BOTTOMLEFT" then
			rY = rel:GetBottom()
			rX = rel:GetLeft()
		elseif relPoint == "BOTTOM" then
			rY = rel:GetBottom()
			rX = (rel:GetRight() + rel:GetLeft()) / 2
		elseif relPoint == "CENTER" then
			rY = (rel:GetTop() + rel:GetBottom()) / 2
			rX = (rel:GetRight() + rel:GetLeft()) / 2
		elseif relPoint == "LEFT" then
			rY = (rel:GetTop() + rel:GetBottom()) / 2
			rX = rel:GetLeft()
		elseif relPoint == "RIGHT" then
			rY = (rel:GetTop() + rel:GetBottom()) / 2
			rX = rel:GetRight()
		else
			return
		end
		if rel.GetEffectiveScale then
			rY = rY * rel:GetEffectiveScale()
			rX = rX * rel:GetEffectiveScale()
		else
			rY = rY * UIParent:GetEffectiveScale()
			rX = rX * UIParent:GetEffectiveScale()
		end
	end
	if f:GetLeft() ~= nil then
		if point == "TOPRIGHT" then
			pY = f:GetTop()
			pX = f:GetRight()
		elseif point == "TOPLEFT" then
			pY = f:GetTop()
			pX = f:GetLeft()
		elseif point == "TOP" then
			pY = f:GetTop()
			pX = (f:GetRight() + f:GetLeft()) / 2
		elseif point == "BOTTOMRIGHT" then
			pY = f:GetBottom()
			pX = f:GetRight()
		elseif point == "BOTTOMLEFT" then
			pY = f:GetBottom()
			pX = f:GetLeft()
		elseif point == "BOTTOM" then
			pY = f:GetBottom()
			pX = (f:GetRight() + f:GetLeft()) / 2
		elseif point == "CENTER" then
			pY = (f:GetTop() + f:GetBottom()) / 2
			pX = (f:GetRight() + f:GetLeft()) / 2
		elseif point == "LEFT" then
			pY = (f:GetTop() + f:GetBottom()) / 2
			pX = f:GetLeft()
		elseif point == "RIGHT" then
			pY = (f:GetTop() + f:GetBottom()) / 2
			pX = f:GetRight()
		else
			return
		end
		if f.GetEffectiveScale then
			pY = pY * f:GetEffectiveScale()
			pX = pX * f:GetEffectiveScale()
		else
			pY = pY * UIParent:GetEffectiveScale()
			pX = pX * UIParent:GetEffectiveScale()
		end
	end
	if rY ~= nil and rX ~= nil and pY ~= nil and pX ~= nil then
		rX = pX - rX
		rY = pY - rY
		if f.GetEffectiveScale then
			rY = rY / f:GetEffectiveScale()
			rX = rX / f:GetEffectiveScale()
		else
			rY = rY / UIParent:GetEffectiveScale()
			rX = rX / UIParent:GetEffectiveScale()
		end
	else
		rX = 0
		rY = 0
	end
	return {point, rel:GetName(), relPoint, rX, rY}
end

-- modfied version of blizzards updateContainerFrameAnchors
local MARefBlizzBags = { }
function MovAny:hUpdateContainerFrameAnchors()
	if MADB.noBags then
		return
	end
	local bagsMover = _G.BagsMover
	local bagsHooked = bagsMover and bagsMover.MAHooked or nil
	local xRemaining, yRemaining, column, frame, frameHeight, visibleSpacing, bag, xOffset, yOffset, containerScale, xAvail, yAvail
	local highestFrame = 0
	if bagsHooked then
		containerScale = BagsMover:GetScale()
		xOffset, yOffset = math.abs(BagsMover:GetRight() * containerScale - GetScreenWidth()), BagsMover:GetBottom() * containerScale
	else
		containerScale = 1
		xOffset, yOffset = CONTAINER_OFFSET_X , CONTAINER_OFFSET_Y --/ containerScale
	end
	while containerScale > 0.02 do
		xAvail, yAvail = (GetScreenWidth() - xOffset) / containerScale, (GetScreenHeight() - yOffset) / containerScale
		if BankFrame:IsShown() and not BankFrame.MAHooked then
			xAvail = xAvail + (20 / containerScale) - (BankFrame:GetRight() * BankFrame:GetScale()) / containerScale
		end
		yRemaining = yAvail
		column = 1
		highestFrame = 0
		--visibleSpacing = VISIBLE_CONTAINER_SPACING * containerScale
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frame = MARefBlizzBags[frameName]
			if frame == nil then
				frame = _G[frameName]
				MARefBlizzBags[frameName] = frame
			end
			bag = MovAny:GetBagInContainerFrame(frame)
			if not bag or (bag and not MovAny:IsModified(bag, "pos") and not MovAny:GetMoverByFrame(bag)) then
				frameHeight = frame:GetHeight() --* containerScale

				if yRemaining < frameHeight + VISIBLE_CONTAINER_SPACING then
					column = column + 1
					yRemaining = yAvail
				end
				if frameHeight > highestFrame then
					highestFrame = frameHeight
				end
				yRemaining = yRemaining - frameHeight - VISIBLE_CONTAINER_SPACING
			end
		end
		if highestFrame > yAvail or column * ((CONTAINER_WIDTH --[[* containerScale]]) + VISIBLE_CONTAINER_SPACING) > xAvail then
			containerScale = containerScale - .01
		else
			break
		end
	end
	if not bagsHooked and containerScale < CONTAINER_SCALE then
		containerScale = CONTAINER_SCALE
	end
	column = 0
	yRemaining = yAvail
	local lastFrame, firstFrame, skippedFrame = nil, nil, nil
	for i = 1, 13, 1 do
		frame = _G["ContainerFrame"..i]
		bag = MovAny:GetBagInContainerFrame(frame)
		if not bag or (bag and not MovAny:IsModified(bag, "pos") and not MovAny:GetMoverByFrame(bag)) then
			MovAny:UnlockPoint(frame)
			--MovAny:UnlockScale(frame)
			frame:ClearAllPoints()
			frame:SetScale(containerScale)
			frame:SetAlpha(1)
			frameHeight = frame:GetHeight() --* containerScale
			if firstFrame == nil then
				firstFrame = frame
				if bagsHooked then
					frame:SetPoint("BOTTOMRIGHT", BagsMover, "BOTTOMRIGHT", 0, 0)
				else
					frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -xOffset, yOffset )
				end
			elseif yRemaining < frameHeight then
				yRemaining = yAvail
				frame:SetPoint("BOTTOMRIGHT", firstFrame, "BOTTOMLEFT", -(column * CONTAINER_WIDTH), 0)
				column = column + 1
			else
				frame:SetPoint("BOTTOMRIGHT", lastFrame, "TOPRIGHT", 0, -CONTAINER_SPACING)
			end
			yRemaining = yRemaining - frameHeight - VISIBLE_CONTAINER_SPACING
			lastFrame = frame
		end
	end
end

-- X: slash commands
SLASH_MAMOVE1 = "/move"
SlashCmdList["MAMOVE"] = function(msg)
	if msg == nil or string.len(msg) == 0 then
		MovAny:ToggleGUI()
	else
		MovAny:ToggleMove(MovAny:Translate(msg))
	end
end

SLASH_MAUNMOVE1= "/unmove"
SlashCmdList["MAUNMOVE"] = function(msg)
	if msg then
		if MovAny.userData[ msg ] then
			MovAny:ResetFrame(msg)
		elseif MovAny.userData[ MovAny:Translate(msg) ] then
			MovAny:ResetFrame(MovAny:Translate(msg))
		end
	else
		maPrint(MOVANY.CMD_SYNTAX_UNMOVE)
	end
end

SLASH_MAHIDE1 = "/hide"
SlashCmdList["MAHIDE"] = function(msg)
	if msg == nil or string.len(msg) == 0 then
		maPrint(MOVANY.CMD_SYNTAX_HIDE)
		return
	end
	MovAny:ToggleHide(MovAny:Translate(msg))
end

SLASH_MAIMPORT1 = "/moveimport"
SlashCmdList["MAIMPORT"] = function(msg)
	if msg == nil or string.len(msg) == 0 then
		maPrint(MOVANY.CMD_SYNTAX_IMPORT)
		return
	end
	if InCombatLockdown() then
		maPrint(MOVANY.DISABLED_DURING_COMBAT)
		return
	end

	if MADB.profiles[msg] == nil then
		maPrint(string.format(MOVANY.PROFILE_UNKNOWN, msg))
		return
	end
	MovAny:CopyProfile(msg, MovAny:GetProfileName())
	MovAny:UpdateProfile()
	maPrint(string.format(MOVANY.PROFILE_IMPORTED, msg, MovAny:GetProfileName()))
end

SLASH_MAEXPORT1 = "/moveexport"
SlashCmdList["MAEXPORT"] = function(msg)
	if msg == nil or string.len(msg) == 0 then
		maPrint(MOVANY.CMD_SYNTAX_EXPORT)
		return
	end

	MovAny:CopyProfile(MovAny:GetProfileName(), msg)
	maPrint(string.format(MOVANY.PROFILE_EXPORTED, MovAny:GetProfileName(), msg))
end

SLASH_MALIST1 = "/movelist"
SlashCmdList["MALIST"] = function(msg)
	maPrint(MOVANY.PROFILES..":")
	for i, val in pairs(MADB.profiles) do
		local str = " \""..i.."\""
		if  val == MovAny.userData then
			str = str.." <- "..MOVANY.PROFILE_CURRENT
		end
		maPrint(str)
	end
end

SLASH_MADELETE1 = "/movedelete"
SLASH_MADELETE2 = "/movedel"
SlashCmdList["MADELETE"] = function(msg)
	if msg == nil or string.len(msg) == 0 then
		maPrint(MOVANY.CMD_SYNTAX_DELETE)
		return
	end
	if MADB.profiles[msg] == nil then
		maPrint(string.format(MOVANY.PROFILE_UNKNOWN, msg))
		return
	end
	if msg == MovAny:GetProfileName() and InCombatLockdown() then
		maPrint(MOVANY.PROFILE_CANT_DELETE_CURRENT_IN_COMBAT)
		return
	end
	if MovAny:DeleteProfile(msg) then
		maPrint(string.format(MOVANY.PROFILE_DELETED, msg))
	end
end

SLASH_MAMAFE1 = "/mafe"
SlashCmdList["MAMAFE"] = function(msg)
	if string.len(msg) > 0 then
		MovAny:FrameEditor(MovAny:Translate(msg))
	else
		maPrint(MOVANY.CMD_SYNTAX_MAFE)
	end
end

SLASH_MAINFO1 = "/info"
SlashCmdList["MAINFO"] = function(msg)
	GetParentInfoFromCursor()
end

-- X: global functions
function MANumFor(n, decimals)
	if n == nil then
		return "nil"
	end
	n = string.format("%."..(decimals or 2).."f", n)
	if decimals == nil then
		decimals = 2
	end
	while decimals > 0 do
		if string.sub(n, - 1) == "0" then
			n = string.sub(n, 1, - 2)
		end
		decimals = decimals - 1
	end
	if string.sub(n, - 1) == "." then
		n = string.sub(n, 1, - 2)
	end
	return n
end

function MAGetParent(f)
	if not f or not f.GetParent then
		return
	end
	local p = f:GetParent()
	if p == nil then
		return UIParent
	end
	return p
end

function MAGetScale(f, effective)
	if not f or not f.GetScale then
		return 1
	elseif f.MAE and f.MAE.noScale then
		return f:GetScale()
	else
		if not f.GetScale or f:GetScale() == nil then
			return 1
		end
		if effective then
			return f:GetEffectiveScale()
		else
			return f:GetScale()
		end
	end
end

function maPrint(msgKey, msgHighlight, msgAdditional, r, g, b, frame)
	local msgOutput
	if frame then
		msgOutput = frame
	else
		msgOutput = DEFAULT_CHAT_FRAME
	end
	if msgKey == "" then
		return
	end
	if msgKey == nil then
		msgKey = "<nomsg>"
	end
	if msgHighlight == nil or msgHighlight == "" then
		msgHighlight  = " "
	end
	if msgAdditional == nil or msgAdditional == "" then
		msgAdditional = " "
	end
	if msgOutput then
		msgOutput:AddMessage("|caaff0000MoveAnything|r|caaffff00>|r "..msgKey.." |caaaaddff"..msgHighlight.."|r"..msgAdditional, r, g, b)
	end
end

function MovAny:ToggleEnableFrame(fn, opt)
	local f = _G[fn]
	if f and fn ~= f:GetName() then
		fn = f:GetName()
	end
	local opt = opt or MovAny:GetUserData(fn, nil, true)
	if opt.disabled then
		self:EnableFrame(fn)
	else
		self:DisableFrame(fn)
	end
	MovAny:UpdateGUIIfShown()
end

function MovAny:EnableFrame(fn)
	local f = _G[fn]
	if not fn then
		return
	end
	if not f then
		return
	end
	local opt = self:GetUserData(f:GetName())
	if not opt then
		return
	end
	opt.disabled = nil
	local e = API:GetElement(fn)
	e:Sync(f)
	if f.MAOnEnable then
		f:MAOnEnable()
	end
end

function MovAny:DisableFrame(fn)
	if fn == nil then
		return
	end
	self:StopMoving(fn)
	local opt = self:GetUserData(fn, nil, true)
	if not opt then
		return
	end
	local f = _G[fn]
	if f then
		self:ResetFrame(f, nil, true)
	end
	opt.disabled = true
end

function MovAny:UnhookTooltip()
	local tooltip = _G.GameTooltip
	if tooltip.MAMover then
		local e = tooltip.MAMover.MAE
		local opt = e.userData
		if type(opt) == "table" then
			if opt.hidden then
				tooltip.MAHidden = nil
			end
			MovAny.Alpha:Reset(e, tooltip, true)
			MovAny.Scale:Reset(e, tooltip, true)
			MovAny.Misc:Reset(e, tooltip, true)
		end
		tooltip.MAMover = nil
	end
end

function MovAny:HookTooltip(mover)
	if not mover then
		return
	end
	local l, r, t, b, anchor
	local tooltip = _G.GameTooltip
	self:UnhookTooltip()
	--[[local opt = MovAny:GetUserData(mover:GetName())
	opt = mover.MAE.userData
	if type(opt) ~= "table" then
		return
	end]]
	tooltip.MAMover = mover
	l = mover:GetLeft() * mover:GetEffectiveScale()
	r = mover:GetRight() * mover:GetEffectiveScale()
	t = mover:GetTop() * mover:GetEffectiveScale()
	b = mover:GetBottom() * mover:GetEffectiveScale()
	anchor = "CENTER"
	if ((b + t) / 2) < ((UIParent:GetTop() * UIParent:GetScale()) / 2) - 25 then
		anchor = "BOTTOM"
	elseif ((b + t) / 2) > ((UIParent:GetTop() * UIParent:GetScale()) / 2) + 25 then
		anchor = "TOP"
	end
	if anchor ~= "CENTER" then
		if ((l + r) / 2) > ((UIParent:GetRight() * UIParent:GetScale()) / 2) + 25 then
			anchor = anchor.."RIGHT"
		elseif ((l + r) / 2) < ((UIParent:GetRight() * UIParent:GetScale()) / 2) - 25 then
			anchor = anchor.."LEFT"
		end
	end
	--MovAny:UnlockPoint(tooltip)
	tooltip:ClearAllPoints()
	tooltip:SetPoint(anchor, mover, anchor, 0, 0)
	--MovAny:LockPoint(tooltip)
	local opt = MovAny:GetUserData(mover:GetName())
	if opt and opt.hidden then
		self:LockVisibility(tooltip)
	end
	MovAny.Alpha:Apply(mover.MAE, tooltip)
	MovAny.Scale:Apply(mover.MAE, tooltip)
	MovAny.Misc:Apply(mover.MAE, tooltip)
end

function MovAny:hGameTooltip_SetDefaultAnchor(relative)
	local tooltip = _G.GameTooltip
	if tooltip.MASkip then
		return
	end
	if MovAny:IsModified("TooltipMover") then
		MovAny:HookTooltip(_G["TooltipMover"])
	elseif MovAny:IsModified("BagItemTooltipMover") then
		MovAny:UnlockPoint(tooltip)
	end
end

function MovAny:hGameTooltip_SetBagItem(container, slot)
	if MovAny:IsModified("BagItemTooltipMover") then
		MovAny:HookTooltip(_G["BagItemTooltipMover"])
	end
end

function MovAny:hGameTooltip_SetGuildBankItem(container, slot)
	if MovAny:IsModified("GuildBankItemTooltipMover") then
		MovAny:HookTooltip(_G["GuildBankItemTooltipMover"])
	end
end

-- X: MA tooltip funcs
function MovAny:TooltipShow(self)
	if not self.tooltipText then
		return
	end
	if self.alwaysShowTooltip or (MADB.tooltips and not IsShiftKeyDown() and not self.neverShowTooltip) or (not MADB.tooltips and IsShiftKeyDown()) or (self.neverShowTooltip and IsShiftKeyDown()) then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end
end

function MovAny:TooltipHide()
	GameTooltip:Hide()
end

function MovAny:TooltipShowMultiline(self)
	local tooltipLines = self.tooltipLines
	if tooltipLines == nil then
		local el = API:GetItem(self.idx)
		if el.elems then
			return
		end
		tooltipLines = MovAny:GetFrameTooltipLines(el.name)
	end
	if tooltipLines == nil then
		return
	end
	local g = 0
	for k in pairs(tooltipLines) do
		g = 1
		break
	end
	if g == 0 then
		return
	end
	if self.alwaysShowTooltip or (self.neverShowTooltip and IsShiftKeyDown()) or (MADB.tooltips and not IsShiftKeyDown() and not self.neverShowTooltip) or (not MADB.tooltips and IsShiftKeyDown()) then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:ClearLines()
		for i,v in ipairs(tooltipLines) do
			GameTooltip:AddLine(v)
		end
		GameTooltip:Show()
	end
end

function MovAny:GetFrameTooltipLines(fn)
	if not fn then
		return
	end
	local o = API:GetElement(fn)
	if not o then
		return
	end
	local opts = o.userData
	local msgs = { }
	local enough = nil
	local added = nil
	tinsert(msgs, o.displayName or fn)
	if opts then
		if opts.hidden then
			if o.hideList then
				tinsert(msgs, "Specially hidden")
			else
				tinsert(msgs, "Hidden")
			end
			enough = true
		end
	end
	if o and o.displayName and o.displayName ~= fn and fn ~= nil then
		tinsert(msgs, " ")
		tinsert(msgs, "Frame: "..fn)
	end
	if opts then
		if opts.pos then
			if not added then
				tinsert(msgs, " ")
			end
			tinsert(msgs, "Position: "..MANumFor(opts.pos[4])..", "..MANumFor(opts.pos[5]))
			enough = true
			added = true
		end
		if opts.scale then
			if not added then
				tinsert(msgs, " ")
			end
			tinsert(msgs, "Scale: "..MANumFor(opts.scale))
			enough = true
			added = true
		end
		if opts.alpha then
			if not added then
				tinsert(msgs, " ")
			end
			tinsert(msgs, "Alpha: "..MANumFor(opts.alpha))
			enough = true
			added = true
		end
		added = nil
		if opts.scale then
			if not added then
				tinsert(msgs, " ")
			end
			tinsert(msgs, "Original Scale: "..MANumFor(opts.orgScale or 1))
			enough = true
			added = true
		end
		if opts.alpha and opts.orgAlpha and opts.alpha ~= opts.orgAlpha then
			if not added then
				tinsert(msgs, " ")
			end
			tinsert(msgs, "Original Alpha: "..MANumFor(opts.orgAlpha))
			enough = true
			added = true
		end
	end
	-- enable this to only show tooltips if actual modifications have been made to the frame
	--[[if not enough then
		table.wipe(msgs)
	end]]
	return msgs
end

-- X: debugging code
function echo(...)
	local msg = ""
	for k, v in pairs({...}) do
		msg = msg..k.."=["..tostring(v) .."] "
	end
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function decho(ar, limit)
	local msg = ""
	for k, v in pairs(ar) do
		if type(v) == "table" then
			msg = msg..k.."=["..dechoSub(v, 1, limit) .."] \n"
		else
			msg = msg..k.."=["..tostring(v) .."] \n"
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function dechoSub(t, d, limit)
	local msg = ""
	if d > 10 or (type(limit) == "number" and d <= limit) then
		return msg
	end
	for k, v in pairs(t) do
		if type(v) == "table" then
			msg = msg..k.."=["..dechoSub(v, d + 1) .."] \n"
		else
			msg = msg..k.."=["..tostring(v) .."] \n"
		end
	end
	return msg
end

function necho(...)
	local msg = ""
	for k,v in pairs({...}) do
		if type(v) == "table" then
			for k2,v2 in pairs(v) do
				msg = msg..k2.."=("..type(v2) ..") "
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function MovAny:DebugFrameAtCursor()
	local o = GetMouseFocus()
	if o then
		if self:IsMAFrame(o:GetName()) then
			if self:IsMover(o:GetName()) and o.tagged then
				o = o.tagged
			end
		end
		if o ~= WorldFrame and o ~= UIParent then
			MovAny:Dump(o)
		end
	end
end

function MovAny:Dump(o)
	if type(o) ~= "table" then
		maPrint(string.format(MOVANY.UNSUPPORTED_TYPE, type(o)))
		return
	end
	local s = " Name: "..o:GetName()
	if o.GetObjectType then
		s = s.."  Type: "..o:GetObjectType()
	end
	local p = o:GetParent()
	if p == nil then
		p = UIParent
	end
	if o ~= p then
		s = s.."  Parent: "..(p:GetName() or "unnamed")
	end
	if o.MAParent then
		s = s.." MA Parent: "..((type(o.MAParent) == "table" and o.MAParent:GetName()) or (type(o.MAParent) == "string" and o.MAParent) or "unnamed")
	end
	if s ~= "" then
		maPrint(s)
	end
	if o.IsProtected and o:IsProtected() then
		maPrint(" Protected: true")
	elseif o.MAProtected then
		maPrint(" Virtually protected: true")
	end
	s = ""
	if o.IsShown then
		if o:IsShown() then
			s = s.." Shown: true"
		else
			s = s.." Shown: false"
		end
		if o.IsVisible then
			if o:IsVisible() then
				s = s.." Visible: true"
			else
				s = s.." Visible: false"
			end
		end
	end
	if o.IsTopLevel and o:IsToplevel() then
		s = s.." Top Level: true"
	end
	if o.GetFrameLevel then
		s = s.." Level: "..o:GetFrameLevel()
	end
	if o.GetFrameStrata then
		s = s.." Strata: "..o:GetFrameStrata()
	end
	if s ~= "" then
		maPrint(s)
	end
	local point = {o:GetPoint()}
	if point and point[1] and point[2] and point[3] and point[4] and point[5] then
		if not point[2] then
			point[2] = UIParent
		end
		maPrint(" Point: "..point[1]..", "..point[2]:GetName()..", "..point[3]..", "..point[4]..", "..point[5])
	end
	s = ""
	if o:GetTop() then
		s = " Top: "..o:GetTop()
	end
	if o:GetRight() then
		s = s.." Right: "..o:GetRight()
	end
	if o:GetBottom() then
		s = s.." Bottom: "..o:GetBottom()
	end
	if o:GetLeft() then
		s = s.." Left: "..o:GetLeft()
	end
	if s ~= "" then
		maPrint(s)
	end
	s = ""
	if o:GetHeight() then
		s = " Height: "..o:GetHeight()
	end
	if o:GetWidth() then
		s = s.." Width: "..o:GetWidth()
	end
	if s ~= "" then
		maPrint(s)
	end
	s = ""
	if o.GetScale then
		s = s.." Scale: "..o:GetScale()
	end
	if o.GetEffectiveScale then
		s = s.." Effective: "..o:GetEffectiveScale()
	end
	if s ~= "" then
		maPrint(s)
	end
	s = ""
	if o.GetAlpha then
		s = s.." Alpha: "..o:GetAlpha()
	end
	if o.GetEffectiveAlpha then
		s = s.." Effective: "..o:GetEffectiveAlpha()
	end
	if s ~= "" then
		maPrint(s)
	end
	s = ""
	if o.IsUserPlaced then
		if o:IsUserPlaced() then
			s = s.." UserPlaced: true"
		else
			s = s.." UserPlaced: false"
		end
	end
	if o.IsMovable then
		if o:IsMovable() then
			s = s.." Movable: true"
		else
			s = s.." Movable: false"
		end
	end
	if o.IsResizable then
		if o:IsResizable() then
			s = s.." Resizable: true"
		else
			s = s.." Resizable: false"
		end
	end
	if s ~= "" then
		maPrint(s)
	end
	s = ""
	if o.IsKeyboardEnabled then
		if o:IsKeyboardEnabled() then
			s = s.." KeyboardEnabled: true"
		else
			s = s.." KeyboardEnabled: false"
		end
	end
	if o.IsMouseEnabled then
		if o:IsMouseEnabled() then
			s = s.." MouseEnabled: true"
		else
			s = s.." MouseEnabled: false"
		end
	end
	if o.IsMouseWheelEnabled then
		if o:IsMouseWheelEnabled() then
			s = s.." MouseWheelEnabled: true"
		else
			s = s.." MouseWheelEnabled: false"
		end
	end
	if s ~= "" then
		maPrint(s)
	end
	local opts = self:GetUserData(o:GetName())
	if opts ~= nil then
		maPrint(" MA stored variables:")
		for i, v in pairs(opts) do
			if i ~= "cat" and i ~= "name" then
				if v == nil then
					maPrint("   "..i..": nil")
				elseif v == true then
					maPrint("   "..i..": true")
				elseif v == false then
					maPrint("   "..i..": false")
				elseif type(v) == "string" then
					maPrint("   "..i..": "..v)
				elseif type(v) == "number" then
					maPrint("   "..i..": "..MANumFor(v))
				elseif type(v) == "table" then
					s = ""
					for i2, v2 in pairs(v) do
						if type(v2) == "table" then
							s = s.."  "..i2..": "
							for i3, v3 in pairs(v2) do
								s = s.." "..v3
							end
						else
							s = s.."  "..v2
						end
					end
					maPrint("   "..i..":"..s)
				else
					maPrint("   "..i.." is a "..type(v).."")
				end
			end
		end
	end
end

SLASH_MADBG1 = "/madbg"
SlashCmdList["MADBG"] = function(msg)
	if msg == nil or msg == "" then
		return
	end
	local f = _G[msg]
	if f == nil then
		local tr = MovAny:Translate(msg)
		if tr then
			f = _G[tr]
		end
	end
	if f == nil then
		maPrint(string.format(MOVANY.ELEMENT_NOT_FOUND_NAMED, msg))
	else
		MovAny:Dump(f)
	end
end

MovAny.dbg = dbg

-- X: Blizzard Interface Options functions
function MovAny:OptionCheckboxChecked(button, var)
	if var == "squareMM" then
		if button:GetChecked() then
			Minimap:SetMaskTexture("Interface\\AddOns\\MoveAnything\\Textures\\MinimapMaskSquare")
		else
			Minimap:SetMaskTexture("Textures\\MinimapMask")
		end
	elseif var =="closeGUIOnEscape" then
		if button:GetChecked() then
			tinsert(UISpecialFrames, "MAOptions")
		else
			for i, v in pairs(UISpecialFrames) do
				if v == "MAOptions" then
					tremove(UISpecialFrames, i)
					break
				end
			end
		end
	end
	MADB[var] = button:GetChecked()
	MovAny:UpdateGUIIfShown()
end

function MovAny:SetOptions()
	MADB.alwaysShowNudger = MAOptAlwaysShowNudger:GetChecked()
	MADB.noBags = MAOptNoBags:GetChecked()
	MADB.noMMMW = MAOptNoMMMW:GetChecked()
	MADB.playSound = MAOptPlaySound:GetChecked()
	MADB.tooltips = MAOptShowTooltips:GetChecked()
	if MAOptCloseGUIOnEscape:GetChecked() then
		MADB.closeGUIOnEscape = true
	else
		MADB.closeGUIOnEscape = false
	end
	MADB.squareMM = MAOptsSquareMM:GetChecked()
	MADB.dontHookCreateFrame = MAOptDontHookCreateFrame:GetChecked()
	MADB.dontSyncWhenLeavingCombat = MAOptDontSyncWhenLeavingCombat:GetChecked()
	MADB.dontSearchFrameNames = MAOptDontSearchFrameNames:GetChecked()
	MADB.disableErrorMessages = MAOptDisableErrorMessages:GetChecked()
	MADB.frameListRows = MAOptRowsSlider:GetValue()
	if MADB.closeGUIOnEscape then
		tinsert(UISpecialFrames, "MAOptions")
	else
		for i, v in pairs(UISpecialFrames) do
			if v == "MAOptions" then
				tremove(UISpecialFrames, i)
				break
			end
		end
	end
end

function MovAny:SetDefaultOptions()
	if MADB.squareMM then
		Minimap:SetMaskTexture("Textures\\MinimapMask")
	end
	if MADB.closeGUIOnEscape then
		for i, v in pairs(UISpecialFrames) do
			if v == "MAOptions" then
				tremove(UISpecialFrames, i)
				break
			end
		end
	end
	MADB.alwaysShowNudger = nil
	MADB.noBags = nil
	MADB.noMMMW = nil
	MADB.playSound = nil
	MADB.tooltips = true
	MADB.closeGUIOnEscape = nil
	MADB.squareMM = nil
	MADB.dontHookCreateFrame = nil
	MADB.dontSyncWhenLeavingCombat = nil
	MADB.dontSearchFrameNames = nil
	MADB.frameListRows = 18
	MovAny_OptionsOnShow()
	MovAny:UpdateGUIIfShown()
end

function MovAny_OptionsOnLoad(f)
	f.name = GetAddOnMetadata("MoveAnything", "Title")
	f.okay = MovAny.SetOptions
	f.default = MovAny.SetDefaultOptions
	InterfaceOptions_AddCategory(f)
end

function MovAny_OptionsOnShow()
	MAOptVersion:SetText("Version: |cffeeeeee"..GetAddOnMetadata("MoveAnything", "Version").."|r")
	MAOptAlwaysShowNudger:SetChecked(MADB.alwaysShowNudger)
	MAOptNoBags:SetChecked(MADB.noBags)
	MAOptPlaySound:SetChecked(MADB.playSound)
	MAOptShowTooltips:SetChecked(MADB.tooltips)
	MAOptCloseGUIOnEscape:SetChecked(MADB.closeGUIOnEscape)
	MAOptSquareMM:SetChecked(MADB.squareMM)
	MAOptNoMMMW:SetChecked(MADB.noMMMW)
	MAOptDontHookCreateFrame:SetChecked(MADB.dontHookCreateFrame)
	MAOptDontSyncWhenLeavingCombat:SetChecked(MADB.dontSyncWhenLeavingCombat)
	MAOptDontSearchFrameNames:SetChecked(MADB.dontSearchFrameNames)
	MAOptDisableErrorMessages:SetChecked(MADB.disableErrorMessages)
	if MADB.frameListRows then
		MAOptRowsSlider:SetValue(MADB.frameListRows)
	end
	if type(MADB.characters) == "table" then
		local profile = MovAny:GetProfileName()
		Lib_UIDropDownMenu_Initialize(MAOptProfileDropDown, MovAny.ProfileDropDownInit)
		Lib_UIDropDownMenu_SetSelectedValue(MAOptProfileDropDown, profile)
		if "default" == profile then
			MAOptProfileRename:Disable()
			MAOptProfileDelete:Disable()
		else
			MAOptProfileRename:Enable()
			MAOptProfileDelete:Enable()
		end
	end
end

--[[function MovAny:ProfileRenameClicked(b)
	MoveAny_ProfileRename:Show()
	MoveAny_ProfileRename.editBox:SetText(MovAny:GetProfileName())
end

function MovAny:ProfileSaveAsClicked(b)
	MoveAny_SaveAs:Show()
end

function MovAny:ProfileAddClicked(b)
	MoveAny_ProfileAdd:Show()
end

function MovAny:ProfileDeleteClicked(b)
	StaticPopup_Show("MOVEANYTHING_PROFILE_DELETE", MovAny:GetProfileName())
	MoveAny_ProfileDelete:Show()
end

function MovAny.ProfileDropDownClicked(b)
	MovAny:ChangeProfile(b.value)
	MovAny_OptionsOnShow()
end]]

function MovAny:ProfileRenameClicked(b)
	local dlg = StaticPopup_Show("MOVEANYTHING_PROFILE_RENAME", MovAny:GetProfileName())
	if dlg then
		dlg.editBox:SetText(MovAny:GetProfileName())
	end
end

function MovAny:ProfileSaveAsClicked(b)
	StaticPopup_Show("MOVEANYTHING_PROFILE_SAVE_AS")
end

function MovAny:ProfileAddClicked(b)
	StaticPopup_Show("MOVEANYTHING_PROFILE_ADD")
end

function MovAny:ProfileDeleteClicked(b)
	StaticPopup_Show("MOVEANYTHING_PROFILE_DELETE", MovAny:GetProfileName())
end

function MovAny.ProfileDropDownClicked(b)
	MovAny:ChangeProfile(b.value)
	MovAny_OptionsOnShow()
end
function MovAny.ProfileDropDownInit()
	local sel = MovAny:GetProfileName()
	local info
	info = Lib_UIDropDownMenu_CreateInfo()
	info.text = "default"
	info.value = "default"
	info.func = MovAny.ProfileDropDownClicked
	if "default" == sel then
		info.checked = true
	end
	Lib_UIDropDownMenu_AddButton(info)
	local names = { }
	for name, _ in pairs(MADB.profiles) do
		tinsert(names, name)
	end
	table.sort(names, function(o1, o2)
		return o1:lower() < o2:lower()
	end)
	for _, name in pairs(names) do
		if "default" ~= name then
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = name
			info.value = name
			info.func = MovAny.ProfileDropDownClicked
			if name == sel then
				info.checked = true
			end
			Lib_UIDropDownMenu_AddButton(info)
		end
	end
end

function MovAny:SetNumRows(num, dontUpdate)
	if not MAOptions then
		return
	end
	num = tonumber(format("%.0f", tostring(num)))
	MADB.frameListRows = num
	local base = 0
	local h = 24
	MAOptions:SetHeight(base + 81 + (num * h))
	MAScrollFrame:SetHeight(base + 11 + (num * h))
	MAScrollBorder:SetHeight(base - 22 + (num * h))
	for i = 1, 100, 1 do
		local row = _G["MAMove"..i]
		if num >= i then
			if not row then
				row = CreateFrame("Frame", "MAMove"..i, MAOptions, "MAListRowTemplate")
				if i == 1 then
					row:SetPoint("TOPLEFT", "MAOptionsFrameNameHeader", "BOTTOMLEFT", -8, -4)
				else
					row:SetPoint("TOPLEFT", "MAMove"..(i - 1), "BOTTOMLEFT")
				end
				local label = _G[ "MAMove"..i.."FrameName" ]
				label:SetScript("OnEnter", MovAny_TooltipShowMultiline)
				label:SetScript("OnLeave", MovAny_TooltipHide)
			end
		else
			if row then
				row:Hide()
			end
		end
	end
	_G["MAOptRowsSliderText"]:SetText(num)
	if not dontUpdate then
		self:UpdateGUIIfShown(true)
	end
end

function MovAny_TooltipShow(a, b, c, d, e)
	MovAny:TooltipShow(a,b,c,d,e)
end

function MovAny_TooltipHide(a, b, c, d, e)
	MovAny:TooltipHide(a,b,c,d,e)
end

function MovAny_TooltipShowMultiline(a, b, c, d, e)
	MovAny:TooltipShowMultiline(a,b,c,d,e)
end

local stateMonitor = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

function MovAny:Search(searchWord)
	if searchWord ~= MOVANY.SEARCH_TEXT then
		searchWord = string.gsub(string.gsub(string.lower(searchWord), "([%(%)%%%.%[%]%+%-%?])", "%%%1"), "%*", "[%%w %%c]*")
		if self.searchWord ~= searchWord then
			-- searchWord ~= MOVANY.SEARCH_TEXT
			self.searchWord = searchWord
			self:UpdateGUIIfShown(true)
		end
	else
		self.searchWord = nil
		self:UpdateGUIIfShown()
	end
end

function MovAny_OnEvent(self, event, arg1)
	if event == "PLAYER_REGEN_DISABLED" then
		if #MovAny.movers > 0 then
			for i, v in ipairs(MA_tcopy(MovAny.movers)) do
				if MovAny:IsProtected(v.tagged) then
					tinsert(MovAny.pendingMovers, v.tagged)
					MovAny:StopMoving(v.tagged:GetName())
				end
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if #MovAny.pendingMovers > 0 then
			for i, v in ipairs(MovAny.pendingMovers) do
				if _G.MAOptionsToggleMovers:GetChecked() then
					MovAny:AttachMover(v:GetName())
				else
					tinsert(MovAny.minimizedMovers, v)
				end
			end
			table.wipe(MovAny.pendingMovers)
		end
		if not MADB.dontSyncWhenLeavingCombat then
			MovAny:SyncFrames()
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == "MoveAnything" then
			if MovAny.Load ~= nil then
				MovAny:Load()
				MovAny.Load = nil
				if MovAny:IsModified(LFRParentFrame) then
					MovAny:ResetFrame(LFRParentFrame)
				end
				if MovAny:IsModified(QuestLogFrame) then
					MovAny:ResetFrame(QuestLogFrame)
				end
				if MovAny:IsModified(QuestLogDetailFrame) then
					MovAny:ResetFrame(QuestLogDetailFrame)
				end
				if MovAny:IsModified(PlayerPowerBarAltCounterBar) then
					MovAny:ResetFrame(PlayerPowerBarAltCounterBar)
				end
				for k, v in pairs(MADB.profiles) do
					if v.frames["PaladinPowerBar"] then
						v.frames["PaladinPowerBar"] = nil
					end
					for i = 1, 10 do
						if v.frames["LootWonAlertMover"..i] then
							v.frames["LootWonAlertMover"..i] = nil
						end
					end
					for i = 1, 5 do
						if v.frames["MoneyWonAlertMover"..i] then
							v.frames["MoneyWonAlertMover"..i] = nil
						end
					end
				end
			end
		elseif arg1 == "Blizzard_TalentUI" and MovAny.hBlizzard_TalentUI then
			MovAny:hBlizzard_TalentUI()
		--[[elseif arg1 == "Blizzard_AchievementUI" then
			setfenv(AchievementFrame_OnShow, setmetatable({UpdateMicroButtons = function()
				if (AchievementFrame and AchievementFrame:IsShown()) then
					AchievementMicroButton:SetButtonState("PUSHED", 1)
				end
			end }, { __index = _G}))
		elseif arg1 == "Blizzard_PetJournal" then
			setfenv(PetJournalParent_OnShow, setmetatable({UpdateMicroButtons = function()
				if (PetJournalParent and PetJournalParent:IsShown()) then
					CollectionsMicroButton:Enable()
					CollectionsMicroButton:SetButtonState("PUSHED", 1)
				end
			end }, { __index = _G}))]]
		--[=[elseif arg1 == "Blizzard_ArenaUI" then
			ArenaEnemyFrame_UpdatePet = function() end
			ArenaEnemyFrames_UpdateWatchFrame = function()
				local _, instanceType = IsInInstance()
				if not WatchFrame:IsUserPlaced() then
					if ArenaEnemyFrames:IsShown() then
						if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
							ArenaEnemyFrames.hidWatchedQuests = true
						end
					elseif instanceType == "arena" or instanceType == "pvp" then
						if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
							ArenaEnemyFrames.hidWatchedQuests = true
						end
					else
						if ArenaEnemyFrames.hidWatchedQuests then
							WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
							ArenaEnemyFrames.hidWatchedQuests = false
						end
					end
					WatchFrame_ClearDisplay()
					WatchFrame_Update()
				elseif ArenaEnemyFrames.hidWatchedQuests then
					WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
					ArenaEnemyFrames.hidWatchedQuests = false
					WatchFrame_ClearDisplay()
					WatchFrame_Update()
				end
			end
			ArenaPrepFrames_UpdateWatchFrame = function()
				local _, instanceType = IsInInstance()
				if not WatchFrame:IsUserPlaced() then
					if ArenaPrepFrames:IsShown() then
						if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
							ArenaPrepFrames.hidWatchedQuests = true
						end
					elseif instanceType == "arena" or instanceType == "pvp" then
						if WatchFrame_RemoveObjectiveHandler(WatchFrame_DisplayTrackedQuests) then
							ArenaPrepFrames.hidWatchedQuests = true
						end
					else
						if ArenaPrepFrames.hidWatchedQuests then
							WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
							ArenaPrepFrames.hidWatchedQuests = false
						end
					end
					WatchFrame_ClearDisplay()
					WatchFrame_Update()
				elseif ArenaPrepFrames.hidWatchedQuests then
					WatchFrame_AddObjectiveHandler(WatchFrame_DisplayTrackedQuests)
					ArenaPrepFrames.hidWatchedQuests = false
					WatchFrame_ClearDisplay()
					WatchFrame_Update()
				end
			end
			hooksecurefunc("ArenaEnemyFrame_UpdatePlayer", MovAny.hookArenaEnemyFrames15)
			hooksecurefunc("UpdatePrepFrames", MovAny.hookArenaEnemyFrames15)
			hooksecurefunc("ArenaEnemyFrames_UpdateVisible", MovAny.hookArenaEnemyFrames15)
			hooksecurefunc("ArenaEnemyFrames_Enable", MovAny.hArenaEnemyFrames_Enable)
			hooksecurefunc("ArenaEnemyFrames_Disable", MovAny.hArenaEnemyFrames_Disable)
			--hooksecurefunc("ArenaEnemyFrames_UpdateWatchFrame", MovAny.hWatchFrameExpand)
			if ArenaPrepFrames and not ArenaPrepFrames.hooked_ma then
				ArenaPrepFrames.hooked_ma = true
				ArenaPrepFrames.ma_Show = ArenaPrepFrames.Show
				--[[ArenaPrepFrames.Show = function(self)
					if not InCombatLockdown() then
						self:ma_Show()
					end
				end]]
				ArenaPrepFrames.Hide = function()
					ArenaPrepFrames.ma_isshown = false
					ArenaPrepFrames_UpdateWatchFrame()
				end
				ArenaPrepFrames.IsShown = function()
					local _, instanceType = IsInInstance()
					if instanceType == "arena" or instanceType == "pvp" then
						return true
					else
						if ArenaPrepFrame1:IsShown() then
							return true
						end
						if ArenaPrepFrame2:IsShown() then
							return true
						end
						if ArenaPrepFrame3:IsShown() then
							return true
						end
						if ArenaPrepFrame4:IsShown() then
							return true
						end
						if ArenaPrepFrame5:IsShown() then
							return true
						end
					end
					return false
				end
				if GetCVarBool("showArenaEnemyFrames") then
					ArenaPrepFrames:Show()
				else
					ArenaPrepFrames:Hide()
				end
				ArenaPrepFrames.Show = function()
						ArenaPrepFrames.ma_isshown = true
						ArenaPrepFrames_UpdateWatchFrame()
					end
				ArenaPrepFrames.ma_Hide = ArenaPrepFrames.Hide
				--[[ArenaPrepFrames.Hide = function(self)
					if not InCombatLockdown() then
						self:ma_Hide()
					end
				end]]
				ArenaPrepFrames.clear_all_points = ArenaPrepFrames.ClearAllPoints
				ArenaPrepFrames.ClearAllPoints = function(self)
					if not InCombatLockdown() then
						self:clear_all_points()
					end
				end
				ArenaPrepFrames.set_points = ArenaPrepFrames.SetPoint
				ArenaPrepFrames.SetPoint = function(self, ...)
					if not InCombatLockdown() then
						self:set_points(...)
					end
				end
			end
			if ArenaEnemyFrames and not ArenaEnemyFrames.hooked_ma then
				ArenaEnemyFrames.hooked_ma = true
				ArenaEnemyFrames.ma_Show = ArenaEnemyFrames.Show
				--[[ArenaEnemyFrames.Show = function(self)
					if not InCombatLockdown() then
						self:ma_Show()
					end
				end]]
				ArenaEnemyFrames.IsShown = function()
					local _, instanceType = IsInInstance()
					if instanceType == "arena" or instanceType == "pvp" then
						return true
					else
						if ArenaEnemyFrame1:IsShown() then
							return true
						end
						if ArenaEnemyFrame2:IsShown() then
							return true
						end
						if ArenaEnemyFrame3:IsShown() then
							return true
						end
						if ArenaEnemyFrame4:IsShown() then
							return true
						end
						if ArenaEnemyFrame5:IsShown() then
							return true
						end
					end
					return false
				end
				ArenaEnemyFrames.ma_Hide = ArenaEnemyFrames.Hide
				--[[ArenaEnemyFrames.Hide = function(self)
					if not InCombatLockdown() then
						self:ma_Hide()
					end
				end]]
				ArenaEnemyFrames.Hide = function()
					ArenaEnemyFrames.ma_isshown = false
					ArenaEnemyFrames_UpdateWatchFrame()
				end
				if GetCVarBool("showArenaEnemyFrames") then
					ArenaEnemyFrames:Show()
				else
					ArenaEnemyFrames:Hide()
				end
				ArenaEnemyFrames.Show = function()
					ArenaEnemyFrames.ma_isshown = true
					ArenaEnemyFrames_UpdateWatchFrame()
				end
				ArenaEnemyFrames.clear_all_points = ArenaEnemyFrames.ClearAllPoints
				ArenaEnemyFrames.ClearAllPoints = function(self)
					if not InCombatLockdown() then
						self:clear_all_points()
					end
				end
				ArenaEnemyFrames.set_points = ArenaEnemyFrames.SetPoint
				ArenaEnemyFrames.SetPoint = function(self, ...)
					if not InCombatLockdown() then
						self:set_points(...)
					end
				end
			end
			--ArenaEnemyFrame1:ClearAllPoints()
			ArenaEnemyFrame1:SetPoint("TOP", UIParent, "TOP", 600, - 300)
			ArenaEnemyFrame1:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame2:SetPoint("TOP", ArenaEnemyFrame1, "BOTTOM", 0, - 20)
			ArenaEnemyFrame2:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame3:SetPoint("TOP", ArenaEnemyFrame2, "BOTTOM", 0, - 20)
			ArenaEnemyFrame3:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame4:SetPoint("TOP", ArenaEnemyFrame3, "BOTTOM", 0, - 20)
			ArenaEnemyFrame4:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			ArenaEnemyFrame5:SetPoint("TOP", ArenaEnemyFrame4, "BOTTOM", 0, - 20)
			ArenaEnemyFrame5:SetPoint("RIGHT", ArenaEnemyFrames, "RIGHT", - 18, 0)
			for i = 1, 5 do
				local frame = "ArenaEnemyFrame"..i
				if _G[frame] and not _G[frame].hooked_ma then
					_G[frame].hooked_ma = true
					_G[frame].clear_all_points = _G[frame].ClearAllPoints
					_G[frame].ClearAllPoints = function(self)
						if InCombatLockdown() then
							return
						end
						self:clear_all_points()
					end
					_G[frame].set_point = _G[frame].SetPoint
					_G[frame].SetPoint = function(self, ...)
						if InCombatLockdown() then
							return
						end
						self:set_point(...)
					end
				end
				MovAny.API:SyncElement(frame)
				local frame = "ArenaEnemyFrame"..i.."PetFrame"
				if _G[frame] and not _G[frame].hooked_ma then
					_G[frame].hooked_ma = true
					_G[frame]:SetAttribute("unit", "arenapet"..i)
					stateMonitor:WrapScript(_G[frame], "OnAttributeChanged", [[
						if name == "state-unitexists" then
							if UnitExists(self:GetAttribute("unit")) then
								self:Show()
							else
								self:Hide()
							end
						end
					]])
					RegisterUnitWatch(_G[frame], true)
					--RegisterStateDriver(_G[frame], "visibility", "[@arenapet"..i", exists] show hide")
				end
				MovAny.API:SyncElement(frame)
			end]=]
		end
		MovAny:SyncFrames()
	elseif event == "GROUP_ROSTER_UPDATE" then
		if not MovAny:IsModified(RaidUnitFramesMover) then
			return
		end
		if InCombatLockdown() then
			return
		end
		--[[local f = _G["CompactRaidFrameManager"]
		if f then
			f.MAParent = "RaidUnitFramesManagerMover"
		end]]
		local f = _G["CompactRaidFrameContainer"]
		if f then
			f.MAParent = "RaidUnitFramesMover"
		end
		--MovAny.API:SyncElement("RaidUnitFramesManagerMover")
		MovAny.API:SyncElement("RaidUnitFramesMover")
	--[[elseif event == "PET_BATTLE_OPENING_START" then
		if not MovAny:IsModified(MicroButtonsMover) and not MovAny:IsModified(MicroButtonsSplitMover) and not MovAny:IsModified(MicroButtonsVerticalMover) then
			return
		end
		local children = {
			CharacterMicroButton,
			SpellbookMicroButton,
			TalentMicroButton,
			AchievementMicroButton,
			QuestLogMicroButton,
			GuildMicroButton,
			LFDMicroButton,
			CollectionsMicroButton,
			EJMicroButton,
			StoreMicroButton,
			MainMenuMicroButton
		}
		for i = 1, #children, 1 do
			MovAny:UnlockPoint(children[i])
			MovAny:UnlockScale(children[i])
			children[i]:ClearAllPoints()
			children[i]:SetScale(1)
			if i == 1 then
				children[i]:SetPoint("TOPLEFT", PetBattleFrame.BottomFrame, "TOPRIGHT", - 180, 0)
			elseif children[i] == LFDMicroButton then
				children[i]:SetPoint("LEFT", CharacterMicroButton, "LEFT", 0, - 34)
			else
				children[i]:SetPoint("LEFT", children[i - 1], "RIGHT", - 2, 0)
			end
			MovAny:LockPoint(children[i])
			MovAny:LockScale(children[i])
		end
	elseif event == "PET_BATTLE_CLOSE" then
		if not MovAny:IsModified(MicroButtonsMover) and not MovAny:IsModified(MicroButtonsSplitMover) and not MovAny:IsModified(MicroButtonsVerticalMover) then
			return
		end
		if MovAny:IsModified(MicroButtonsMover) then
			MovAny.API:SyncElement("MicroButtonsMover")
		elseif MovAny:IsModified(MicroButtonsSplitMover) then
			MovAny.API:SyncElement("MicroButtonsSplitMover")
		elseif MovAny:IsModified(MicroButtonsVerticalMover) then
			MovAny.API:SyncElement("MicroButtonsVerticalMover")
		end--]]
	elseif event == "PLAYER_FOCUS_CHANGED" then
		MovAny.API:SyncElement("FocusFrame")
	elseif event == "BANKFRAME_OPENED" then
		local e
		for i = 1, 7, 1 do
			e = API:GetElement("BankBagFrame"..i)
			if e then
				e.refuseSync = nil
			end
		end
		MovAny:SyncFrames()
		for i = 1, 7, 1 do
			MovAny:CreateVM("BankBagFrame"..i)
		end
	elseif event == "BANKFRAME_CLOSED" then
		local e
		for i = 1, 7, 1 do
			e = API:GetElement("BankBagFrame"..i)
			--[[if e then
				e.refuseSync = MOVANY.FRAME_ONLY_WHEN_BANK_IS_OPEN
			end]]
		end
	elseif event == "PLAYER_LOGOUT" then
		MovAny:OnPlayerLogout()
	elseif event == "PLAYER_ENTERING_WORLD" then
		if MovAny.Boot ~= nil then
			MovAny:Boot()
			MovAny.Boot = nil
		end
		MovAny:SyncAllFrames()
	elseif event == "BAG_UPDATE" then
		local e
		if arg1 < 6 then
			e = API:GetElement("BagFrame"..(arg1))
			if e then
				e.refuseSync = nil
				e:Sync()
			end
		else
			for i = 1, 5, 1 do
				e = API:GetElement("BagFrame"..(arg1))
				if e then
					e.refuseSync = nil
					e:Sync()
				end
			end
			MAOptions:UnregisterEvent("BAG_UPDATE")
		end
	elseif event == "UNIT_AURA" then
		if MovAny:IsModified("PlayerBuffsMover") or MovAny:IsModified("PlayerBuffsMover2") then
			MovAny.API:SyncElement(PlayerBuffsMover)
		end
	else
		MovAny:SyncAllFrames()
	end
end

function MAMoverTemplate_OnMouseWheel(self, dir)
	MovAny:MoverOnMouseWheel(self, dir)
end

function MANudgeButton_OnClick(self, event, button)
	MovAny:Nudge(self.dir, button)
end

function MANudger_OnMouseWheel(self, dir)
	MovAny:NudgerChangeMover(dir)
end

function MovAny:CreateVM(name)
	local data = MovAny.lVirtualMovers[name]
	if not data then
		return
	end
	if data.created then
		return _G[name]
	end
	local vm = CreateFrame("Frame", name, UIParent, data.inherits, "MADontHook")
	vm.MAEVM = API:GetElement(name)
	--[[if vm.MAEVM and vm.MAEVM.runOnce then
		vm.MAEVM:runOnce()
		vm.MAEVM.runOnce = nil
	end]]
	vm.opt = MovAny:GetUserData(name)
	local opt = vm.opt
	if data.id then
		vm:SetID(data.id)
	end
	vm.data = data
	if data.linkedSize then
		local ref = _G[data.linkedSize]
		if ref then
			vm:SetWidth(ref:GetWidth())
			vm:SetHeight(ref:GetHeight())
		end
	else
		if data.w then
			vm:SetWidth(data.w)
		end
		if data.h then
			vm:SetHeight(data.h)
		end
	end
	if data.s then
		vm:SetScale(data.s)
	end
	if data.dontLock then
		vm.MADontLock = true
	end
	if data.dontHide then
		vm.MADontHide = true
	end
	vm.FoundChild = function(self, index, child)
		if not self.firstChild then
			self.firstChild = child
		end
		child.MAParent = self
		if data.OnMAFoundChild then
			data.OnMAFoundChild(self, index, child)
			--[[xpcall(function()
				data.OnMAFoundChild(self, index, child)
			end,
			function()
				--print("Error: "..debugstack(2, 20, 20))
			end)]]
		end
		if not self.MADontLock then
			MovAny:LockPoint(child)
		end
		if self.MAHidden and not child.MAHidden then
			MovAny:LockVisibility(child)
		end
		self.attachedChildren[index] = child
		self.lastChild = child
		return child
	end
	vm.ReleaseChild = function(self, index)
		local child = self.attachedChildren[index]
		if not child then
			return
		end
		if not self.MADontLock then
			MovAny:UnlockPoint(child)
		end
		if data.OnMAReleaseChild then
			data.OnMAReleaseChild(self, index, child)
		end
		self.lastChild = child
	end
	vm.ReleaseChildByName = function(self, name)
		for i, c in pairs(self.attachedChildren) do
			if c:GetName() == name then
				self:ReleaseChild(i)
				return true
			end
		end
		return false
	end
	local MAScanForChildren = function (self, dontCallNewChild, dontSync)
		if not self.attachedChildren then
			return
		end
		local newChild = false
		if type(data.count) == "number" then
			local name, child
			if data.prefix == "ContainerFrame" then
				for i = 1, data.count, 1 do
					name = data.prefix..i..(data.postfix or "")
					if not self.attachedChildren[name] then
						child = _G[name]
						if child then
							local bag = MovAny:GetBagInContainerFrame(child)
							if not bag or not MovAny:IsModified(bag:GetName()) then
								newChild = self:FoundChild(i, child, 1)
							end
						else
							break
						end
					end
				end
			else
				for i = 1, data.count, 1 do
					name = data.prefix..i..(data.postfix or "")
					if not self.attachedChildren[name] then
						child = _G[name]
						if child then
							if not MovAny:IsModified(name) then
								newChild = self:FoundChild(i, child, 1)
							end
						else
							break
						end
					end
				end
			end
			if data.prefix1 then
				for i = 1, data.count, 1 do
					name = data.prefix1..i..(data.postfix1 or "")
					if not self.attachedChildren[name] then
						child = _G[name]
						if child then
							if not MovAny:IsModified(name) then
								newChild = self:FoundChild(i, child, 2)
							end
						else
							break
						end
					end
				end
			end
			if data.prefix2 then
				for i = 1, data.count, 1 do
					name = data.prefix2..i..(data.postfix2 or "")
					if not self.attachedChildren[name] then
						child = _G[name]
						if child then
							if not MovAny:IsModified(name) then
								newChild = self:FoundChild(i, child, 3)
							end
						else
							break
						end
					end
				end
			end
		end
		if type(data.children) == "table" then
			for i, v in pairs(data.children) do
				local child = type(v) == "string" and _G[v] or v
				if type(child) == "table" and not self.attachedChildren[child:GetName()] then
					if not MovAny:IsModified(child) then
						newChild = self:FoundChild(child:GetName(), child)
					end
				end
			end
		end
		if not dontCallNewChild and newChild and self.OnMANewChild then
			self:OnMANewChild()
		end
		if newChild and not dontSync then
			self.MAEVM:Sync(self)
		end
	end
	vm.MAScanForChildren = function(vm, dontCallNewChild, dontSync)
		--[[xpcall(function()
			MAScanForChildren(vm, dontCallNewChild, dontSync)
		end,]]
		xpcall(function()
			MAScanForChildren(vm, dontCallNewChild, dontSync)
		end, MovAny.SyncErrorHandler)
	end
	if not vm.MAPoint then
		if data.point then
			vm:SetPoint(unpack(data.point))
			if opt and opt.pos and not opt.orgPos then
				opt.orgPos = data.point
			end
		elseif data.relPoint then
			vm:SetPoint(unpack(data.relPoint))
			vm:SetPoint(unpack(self:GetRelativePoint(nil, vm)))
			if opt and opt.pos and not opt.orgPos then
				opt.orgPos = data.point
			end
		elseif not opt or not opt.pos then
			if data.linkedPoint then
				local ref = _G[data.linkedPoint]
				if ref then
					local p = MovAny:GetRelativePoint(nil, ref)
					if p then
						vm:SetPoint(unpack(p))
					end
				end
			end
		end
	elseif data.point then
		opt.orgPos = data.point
	end
	if opt and opt.pos and data.point and not opt.orgPos then
		opt.orgPos = data.point
	end
	if data.protected then
		vm.MAProtected = true
	end
	if data.dontScale then
		vm.MADontScaleChildren = true
	end
	if data.dontAlpha then
		vm.MADontAlphaChildren = true
	end
	if data.frameStrata and (not opt or not opt.frameStrata) then
		vm:SetFrameStrata(data.frameStrata)
	end
	vm.orgOnMAAttach = vm.OnMAAttach
	vm.OnMAAttach = function(self, mover)
		if data.linkedSize then
			local ref = _G[data.linkedSize]
			if ref then
				self:SetWidth(ref:GetWidth())
				self:SetHeight(ref:GetHeight())
			end
		end
		if not self.MAEVM.userData or not self.MAEVM.userData.pos then
			if data.linkedPoint then
				local ref = _G[data.linkedPoint]
				if ref then
					local p = MovAny:GetRelativePoint(nil, ref)
					if p then
						self:SetPoint(unpack(p))
					end
				end
			end
		end
		if data.OnMAAttach then
			data.OnMAAttach(self, mover)
		end
		if data.OnMAPosition then
			data.OnMAPosition(self)
		end
		if vm.orgOnMAAttach then
			vm.orgOnMAAttach(self, mover)
		end
	end
	if data.OnMAPosition then
		vm.OnMAPosition = data.OnMAPosition
	end
	if data.OnMAAlpha then
		vm.OnMAAlpha = data.OnMAAlpha
	end
	if data.OnMAScale then
		vm.OnMAScale = data.OnMAScale
	end
	if data.OnMAPostAttach then
		vm.OnMAPostAttach = data.OnMAPostAttach
	end

	if data.OnMAPostHook then
		vm.OnMAPostHook = data.OnMAPostHook
	end
	vm.OnMAHide = function(self, hidden)
		if hidden then
			if self.attachedChildren then
				for i, v in pairs(self.attachedChildren) do
					MovAny:LockVisibility(v)
				end
			end
		else
			if self.attachedChildren then
				for i, v in pairs(self.attachedChildren) do
					MovAny:UnlockVisibility(v)
				end
			end
		end
		if data.OnMAHide then
			data.OnMAHide(self, hidden)
		end
	end
	if data.OnMAMoving then
		vm.OnMAMoving = data.OnMAMoving
	end
	if data.OnMADetach then
		vm.OnMADetach = data.OnMADetach
	end
	if data.OnMAPositionReset then
		vm.OnMAPositionReset = data.OnMAPositionReset
	end

	if vm.OnMAHook and not data.OnMAHook then
		data.OnMAHook = vm.OnMAHook
	end
	vm.OnMAHook = function(self)
		self.MAEVM = MovAny.API:GetElement(self:GetName())
		self.opt = MovAny:GetUserData(self:GetName())
		if self.opt and self.opt.disabled then
			return
		end
		if data.excludes and MovAny:IsModified(data.excludes) then
			MovAny:ResetFrame(data.excludes)
			MovAny:UpdateGUIIfShown(true)
		end
		if data.excludes2 and MovAny:IsModified(data.excludes2) then
			MovAny:ResetFrame(data.excludes2)
			MovAny:UpdateGUIIfShown(true)
		end
		if self.attachedChildren then
			table.wipe(self.attachedChildren)
		else
			self.attachedChildren = { }
		end
		self:MAScanForChildren(true, true)
		if data.OnMAHook then
			data.OnMAHook(self)
		end
		self:Show()
	end
	if vm.OnMAPostReset and not data.OnMAPostReset then
		data.OnMAPreReset = vm.OnMAPreReset
	end
	vm.OnMAPreReset = function(self, readOnly)
		if data.OnMAPreReset then
			if data.OnMAPreReset(self, readOnly) then
				return
			end
		end
		if type(self.attachedChildren) == "table" then
			if type(data.count) == "number" then
				local name
				for i = 1, data.count, 1 do
					self:ReleaseChild(i)
				end
			end
			if type(self.data.children) == "table" then
				self.lastChild = nil
				for _, name in pairs(self.data.children) do
					self:ReleaseChild(name)
				end
			end
			table.wipe(self.attachedChildren)
		end
		self.firstChild = nil
		self.lastChild = nil
	end
	if vm.OnMAPostReset and not data.OnMAPostReset then
		data.OnMAPostReset = vm.OnMAPostReset
	end
	vm.OnMAPostReset = function(self, readOnly)
		if data.OnMAPostReset then
			if data.OnMAPostReset(self, readOnly) then
				return
			end
		end
		self:Hide()
	end
	if data.OnMAScanForChildren then
		vm.OnMAScanForChildren = data.OnMAScanForChildren
	end
	vm.OnMANewChild = data.OnMANewChild
	vm.MAOnEnable = function(self)
		self:MAScanForChildren()
	end
	if data.inherits then
		local super = _G[data.inherits]
		if super and super.OnMACreateVM then
			vm.OnMACreateVM = super.OnMACreateVM
			vm:OnMACreateVM()
			vm.OnMACreateVM = nil
		end
	end
	if data.OnLoad then
		vm.MAOnLoad = data.OnLoad
		vm:MAOnLoad()
		vm.MAOnLoad = nil
	end
	if data.OnMACreateVM then
		data.OnMACreateVM(vm)
	end
	if vm.OnMACreateVM then
		vm:OnMACreateVM()
	end
	data.created = true
	return vm
end

function MovAny:UnserializeProfile(str)
	str = string.gsub(str, "^%s+", "")
	str = string.gsub(str, "%s+$", "")
	str = string.gsub(str, "[\r\n]", "")
	local sName
	for i, v in string.gmatch(str, ",name:\"(.-)\"") do
		sName = i
	end
	if not sName then
		maPrint(MOVANY.UNSERIALIZE_PROFILE_NO_NAME)
		return
	end
	local frames = { }
	local opt
	str = str..","
	for i in string.gmatch(str, "frames:{(.+)}") do
		for j in string.gmatch(i, "(%[.-%])") do
			opt = MovAny:UnserializeFrame(j)
			if opt then
				frames[opt.name] = opt
			end
		end
	end
	local tName = sName
	local ct = 1
	while MADB.profiles[tName] do
		tName = sName.." ("..ct..")"
		ct = ct + 1
	end
	MovAny:AddProfile(tName)
	MADB.profiles[tName].frames = frames
	maPrint(string.format(MOVANY.UNSERIALIZE_PROFILE_COMPLETED, tlen(frames), tName))
	return true
end

function MovAny:UnserializeFrame(str, name)
	str = string.gsub(str, "^%s+", "")
	str = string.gsub(str, "%s+$", "")
	str = string.gsub(str, "[\r\n]", "")
	str = string.match(str, "%[(.+)%]")
	--[[s:0.70035458463692, h:1, p:("CENTER", "UIParent", "CENTER", 1028.675318659, 84.760391583122), n:"MAOptions"]]
	if not str then
		maPrint(MOVANY.UNSERIALIZE_FRAME_INVALID_FORMAT)
		return nil
	end
	str = str..","
	local scannedName
	local opt = { }
	for m1, m2, m3 in string.gmatch(str, "(%a+):(.-),") do
		if m1 == "s" then
			opt.scale = tonumber(m2)
		elseif m1 == "hi" then
			opt.hidden = true
		elseif m1 == "a" then
			opt.alpha = tonumber(m2)
		elseif m1 == "w" then
			opt.width = tonumber(m2)
		elseif m1 == "h" then
			opt.height = tonumber(m2)
		elseif m1 == "fs" then
			opt.frameStrata = string.sub(m2, 2, - 2)
		elseif m1 == "cts" then
			opt.clampToScreen = true
		elseif m1 == "em" then
			opt.enableMouse = true
		elseif m1 == "m" then
			opt.movable = true
		elseif m1 == "uae" then
			opt.unregisterAllEvents = true
		elseif m1 == "dla" then
			opt.disableLayerArtwork = true
		elseif m1 == "dlb" then
			opt.disableLayerBackground = true
		elseif m1 == "dlbo" then
			opt.disableLayerBorder = true
		elseif m1 == "dlh" then
			opt.disableLayerHighlight = true
		elseif m1 == "dlo" then
			opt.disableLayerOverlay = true
		elseif m1 == "n" then
			scannedName = string.sub(m2, 2, - 2)
		end
		-- XXX: what to do about groups?
	end
	for m1, m2, m3, m4, m5 in string.gmatch(str, "p:%(\"(.-)\",\"(.-)\",\"(.-)\",(-?%d+%.*%d*),(-?%d+%.*%d*)%)") do
		opt.pos = {m1, m2, m3, tonumber(m4), tonumber(m5)}
	end
	if name and name ~= scannedName then
		maPrint(MOVANY.UNSERIALIZE_FRAME_NAME_DIFFERS)
		return
	end
	opt.name = scannedName or name
	return opt
end

function MovAny:SerializeProfile(pn)
	local p = MADB.profiles[pn]
	local s = ""
	for i, v in pairs(p.frames) do
		s = s..","..self:SerializeFrame(i, v)
	end
	s = "frames:{"..string.sub(s, 2).."},name:\""..string.gsub(string.gsub(pn, "%]", ")"), "%[", "(").."\""
	return s
end

function MovAny:SerializeFrame(fn, opt)
	opt = opt or self:GetUserData(fn)
	local s = "["
	for i, v in pairs(opt) do
		if i == "pos" then
			s = s.."p:(\""..v[1].."\",\""..v[2].."\",\""..v[3].."\","..v[4]..","..v[5].."),"
		elseif i == "hidden" then
			s = s.."hi:1,"
		elseif i == "alpha" then
			s = s.."a:"..v..","
		elseif i == "scale" then
			s = s.."s:"..v..","
		elseif i == "width" then
			s = s.."w:"..v..","
		elseif i == "height" then
			s = s.."h:"..v..","
		elseif i == "frameStrata" then
			s = s.."fs:\""..v.."\","
		elseif i == "clampToScreen" then
			s = s.."cts:1,"
		elseif i == "enableMouse" then
			s = s.."em:1,"
		elseif i == "movable" then
			s = s.."m:1,"
		elseif i == "unregisterAllEvents" then
			s = s.."uae:1,"
		elseif i == "disableLayerArtwork" then
			s = s.."dla:1,"
		elseif i == "disableLayerBackground" then
			s = s.."dlb:1,"
		elseif i == "disableLayerBorder" then
			s = s.."dlbo:1,"
		elseif i == "disableLayerHighlight" then
			s = s.."dlh:1,"
		elseif i == "disableLayerOverlay" then
			s = s.."dlo:1,"
		end
	end
	s = s.."n:\""..fn.."\"".."]"
	return s
end

MovAny.core = { }
function MovAny:AddCore(name, m)
	m.name = name
	tinsert(self.core, m)
	self[name] = m
	return m
end

MovAny.modules = { }
function MovAny:AddModule(name, m)
	m.name = name
	tinsert(self.modules, m)
	self[name] = m
	return m
end

function MovAny:DeleteModule(m)
	for i, v in ipairs(self.modules) do
		if v == m then
			tremove(self.modules, i)
			break
		end
	end
	self[m.name] = nil
end

function GetParentInfo(f)
	local fn = f:GetName()
	print("|cFF50C0FF".."<---------------------------------------------->".."|r")
	print("|cFF50C0FF".."Frame:".."|r", fn)
	local p = f:GetParent()
	print("|cFF50C0FF".."Parent:".."|r", p:GetName())
	for i = 1, f:GetNumPoints() do
		local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
		if relativeTo then
			print(i..".", "|cFF50C0FF".."p:".."|r", point, "|cFF50C0FF".."rfn:".."|r", relativeTo:GetName(), "|cFF50C0FF".."rp:".."|r", relativePoint, "|cFF50C0FF".."x:".."|r", xOfs, "|cFF50C0FF".."y:".."|r", yOfs)
		end
	end
	print("|cFF50C0FF".."Width:".."|r", f:GetWidth())
	print("|cFF50C0FF".."Height:".."|r", f:GetHeight())
end

function GetParentInfoFromCursor()
	local fn = GetMouseFocus():GetName()
	local f = _G[fn]
	print("|cFF50C0FF".."<---------------------------------------------->".."|r")
	print("|cFF50C0FF".."Frame:".."|r", fn)
	local p = f:GetParent()
	print("|cFF50C0FF".."Parent:".."|r", p:GetName())
	for i = 1, f:GetNumPoints() do
		local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
		if relativeTo then
			print(i..".", "|cFF50C0FF".."p:".."|r", point, "|cFF50C0FF".."rfn:".."|r", relativeTo:GetName(), "|cFF50C0FF".."rp:".."|r", relativePoint, "|cFF50C0FF".."x:".."|r", xOfs, "|cFF50C0FF".."y:".."|r", yOfs)
		end
	end
	print("|cFF50C0FF".."Width:".."|r", f:GetWidth())
	print("|cFF50C0FF".."Height:".."|r", f:GetHeight())
end
