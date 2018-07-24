local _G = _G
local hooksecurefunc = hooksecurefunc
local pairs = pairs
local string = string
local table = table
local tinsert = tinsert
local type = type
local xpcall = xpcall

local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetNumGroupMembers = GetNumGroupMembers
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsShiftKeyDown = IsShiftKeyDown
local UnitAura = UnitAura

local UIParent = UIParent

local MovAny = _G.MovAny

local HidenFrame = CreateFrame("Frame", "HidenFrame", UIParent)
HidenFrame.frameinfo = { }
HidenFrame:Hide()

local function ScaleChildren(self, scale)
	if self.attachedChildren then
		for i, child in pairs(self.attachedChildren) do
			child:SetScale(scale)
		end
	end
end

local function AlphaChildren(self, alpha)
	if self.attachedChildren then
		for i, child in pairs(self.attachedChildren) do
			child:SetAlpha(alpha)
		end
	end
end

local function ResetChildren(self, readOnly)
	if not readOnly then
		ScaleChildren(self, 1)
		AlphaChildren(self, 1)
	end
end

MovAny.lVirtualMovers = {
	UIPanelMover1 = {
		w = 384,
		h = 512,
		point = {"TOPLEFT", "UIParent", "TOPLEFT", 0, - 104},
		OnMAAttach = MovAny.SyncUIPanels,
		OnMAPosition = MovAny.SyncUIPanels,
		OnMAAlpha = MovAny.SyncUIPanels,
		OnMAScale = MovAny.SyncUIPanels
	},
	UIPanelMover2 = {
		w = 384,
		h = 512,
		point = {"TOPLEFT", "UIParent", "TOPLEFT", 384, - 104},
		OnMAAttach = MovAny.SyncUIPanels,
		OnMAPosition = MovAny.SyncUIPanels,
		OnMAAlpha = MovAny.SyncUIPanels,
		OnMAScale = MovAny.SyncUIPanels
	},
	UIPanelMover3 = {
		w = 384,
		h = 512,
		point = {"TOPLEFT", "UIParent", "TOPLEFT", 772, - 104},
		OnMAAttach = MovAny.SyncUIPanels,
		OnMAPosition = MovAny.SyncUIPanels,
		OnMAAlpha = MovAny.SyncUIPanels,
		OnMAScale = MovAny.SyncUIPanels
	},
	TooltipMover = {
		frameStrata = "TOOLTIP",
		w = 150,
		h = 80,
		point = {"TOP", "UIParent", 0, 0},
		OnLoad = function(self)
			self:SetFrameLevel(GameTooltip:GetFrameLevel() + 1)
		end,
		--[[OnMAPostHook = function(self)
			--MovAny:HookTooltip(self)
		end,
		OnMAPosition = function(self)
			--MovAny:HookTooltip(self)
		end,]]
		OnMAPreReset = function(self)
			local f = _G.GameTooltip
			self.MAE:Reset(f, true)
			f.MAHidden = nil
		end
	},
	PetBattleMover1 = {
		w = 270,
		h = 80,
		point = {"TOPLEFT", "UIParent", "TOP", - 459, - 5},
		OnMAHook = function(self)
			local b = PetBattleFrame.ActiveAlly
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover1, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.ActiveAlly
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.ActiveAlly
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.ActiveAlly
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.ActiveAlly
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.TopArtLeft, "TOPLEFT", 115, - 5)
		end
	},
	PetBattleMover11 = {
		w = 38,
		h = 38,
		point = {"TOPLEFT", "UIParent", "TOP", - 509, - 2},
		OnMAHook = function(self)
			local b = PetBattleFrame.Ally2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover11, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.Ally2
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.Ally2
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.Ally2
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.Ally2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.TopArtLeft, "TOPLEFT", 65, - 2)
		end
	},
	PetBattleMover12 = {
		w = 38,
		h = 38,
		point = {"TOPLEFT", "UIParent", "TOP", - 509, - 45},
		OnMAHook = function(self)
			local b = PetBattleFrame.Ally3
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover12, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.Ally3
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.Ally3
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.Ally3
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.Ally3
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.Ally2, "BOTTOMLEFT", 0, - 5)
		end
	},
	PetBattleMover2 = {
		w = 270,
		h = 80,
		point = {"TOPRIGHT", "UIParent", "TOP", 459, - 5},
		OnMAHook = function(self)
			local b = PetBattleFrame.ActiveEnemy
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover2, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.ActiveEnemy
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.ActiveEnemy
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.ActiveEnemy
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.ActiveEnemy
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.TopArtRight, "TOPRIGHT", - 115, - 5)
		end
	},
	PetBattleMover22 = {
		w = 38,
		h = 38,
		point = {"TOPRIGHT", "UIParent", "TOP", 509, - 2},
		OnMAHook = function(self)
			local b = PetBattleFrame.Enemy2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleMover22, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.Enemy2
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.Enemy2
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.Enemy2
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.Enemy2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.TopArtRight, "TOPRIGHT", - 65, - 2)
		end
	},
	PetBattleMover23 = {
		w = 38,
		h = 38,
		point = {"TOPRIGHT", "UIParent", "TOP", 509, - 45},
		OnMAHook = function(self)
			local b = PetBattleFrame.Enemy3
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleMover23, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.Enemy3
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.Enemy3
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.Enemy3
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.Enemy3
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.Enemy2, "BOTTOMRIGHT", 0, - 5)
		end
	},
	PetBattleMover3 = {
		w = 170,
		h = 40,
		point = {"TOPLEFT", "UIParent", "TOP", - 70, - 60},
		OnMAHook = function(self)
			local b = PetBattleFrame.WeatherFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover3, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.WeatherFrame
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.WeatherFrame
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.WeatherFrame
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.WeatherFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame, "TOP", - 70, - 60)
		end
	},
	PetBattleMover4 = {
		w = 140,
		h = 27,
		point = {"CENTER", "UIParent", "BOTTOM", 0, 95},
		OnMAHook = function(self)
			local b = PetBattleFrame.BottomFrame.TurnTimer
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", PetBattleMover4, "CENTER", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.BottomFrame.TurnTimer
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.BottomFrame.TurnTimer
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.BottomFrame.TurnTimer
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.BottomFrame.TurnTimer
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", PetBattleFrame.BottomFrame, "TOP", 0, - 5)
		end
	},
	PetBattleMover5 = {
		w = 636,
		h = 60,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 120},
		OnMAHook = function(self)
			local b = PetBattleFrame.BottomFrame.PetSelectionFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", PetBattleMover5, "BOTTOM", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.BottomFrame.PetSelectionFrame
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.BottomFrame.PetSelectionFrame
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.BottomFrame.PetSelectionFrame
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.BottomFrame.PetSelectionFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", PetBattleFrame.BottomFrame, "TOP", 0, 20)
		end
	},
	PetBattleMover6 = {
		w = 657,
		h = 100,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 0},
		OnMAHook = function(self)
			local b = PetBattleFrame.BottomFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", PetBattleMover6, "BOTTOM", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.BottomFrame
			b:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.BottomFrame
			b:SetScale(scale)
		end,
		OnMAHide = function(self, hidden)
			local b = PetBattleFrame.BottomFrame
			if hidden then
				MovAny:LockVisibility(b)
			else
				MovAny:UnlockVisibility(b)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.BottomFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 0)
		end
	},
	PetBattleMover7 = {
		w = 574,
		h = 118,
		point = {"TOPLEFT", "UIParent", "TOP", 0, 0},
		OnMAHook = function(self)
			local b = PetBattleFrame.TopArtRight
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleMover7, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.TopArtRight
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.TopArtRight
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", "UIParent", "TOP", 0, 0)
		end
	},
	PetBattleMover8 = {
		w = 574,
		h = 118,
		point = {"TOPRIGHT", "UIParent", "TOP", 0, 0},
		OnMAHook = function(self)
			local b = PetBattleFrame.TopArtLeft
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleMover8, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.TopArtLeft
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.TopArtLeft
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", "UIParent", "TOP", 0, 0)
		end
	},
	PetBattleMover9 = {
		w = 155,
		h = 65,
		point = {"TOP", "UIParent", "TOP", 0, 0},
		OnMAHook = function(self)
			local b = PetBattleFrame.TopVersus
			local c = PetBattleFrame.TopVersusText
			MovAny:UnlockPoint(b)
			MovAny:UnlockPoint(c)
			b:ClearAllPoints()
			c:ClearAllPoints()
			b:SetPoint("TOP", PetBattleMover9, "TOP", 0, 0)
			c:SetPoint("TOP", PetBattleFrame.TopVersus, "TOP", 0, - 6)
			MovAny:LockPoint(b)
			MovAny:LockPoint(c)
			b.ignoreFramePositionManager = true
			c.ignoreFramePositionManager = true
			self.sbf = b
			self.sbft = c
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.TopVersus
			local c = PetBattleFrame.TopVersusText
			b:SetAlpha(alpha)
			c:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
				MovAny:LockVisibility(self.sbft)
			else
				MovAny:UnlockVisibility(self.sbf)
				MovAny:UnlockVisibility(self.sbft)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.TopVersus
			local c = PetBattleFrame.TopVersusText
			MovAny:UnlockPoint(b)
			MovAny:UnlockPoint(c)
			b:ClearAllPoints()
			c:ClearAllPoints()
			b:SetPoint("TOP", "UIParent", "TOP", 0, 0)
			c:SetPoint("TOP", PetBattleFrame.TopVersus, "TOP", 0, - 6)
		end
	},
	PetBattleMover24 = {
		w = 222,
		h = 30,
		point = {"TOPLEFT", "UIParent", "TOP", - 504, - 98},
		OnMAHook = function(self)
			local b = PetBattleFrame.AllyBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.AllyBuffFrame
			b:SetScale(scale)
			if not MovAny:IsModified(PetBattleMover25) then
				local c = PetBattleFrame.AllyDebuffFrame
				c:SetScale(scale)
			end
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.AllyBuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.AllyBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.TopArtLeft, "BOTTOMLEFT", 70, 20)
		end
	},
	PetBattleMover25 = {
		w = 222,
		h = 30,
		point = {"TOPLEFT", "UIParent", "TOP", - 504, - 147},
		OnMAHook = function(self)
			local b = PetBattleFrame.AllyDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.AllyDebuffFrame
			b:SetScale(scale)
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.AllyDebuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.AllyDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.AllyBuffFrame, "BOTTOMLEFT", 0, 0)
		end
	},
	PetBattleMover26 = {
		w = 222,
		h = 30,
		point = {"TOPLEFT", "UIParent", "TOP", - 396, - 98},
		OnMAHook = function(self)
			local b = PetBattleFrame.AllyPadBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.AllyPadBuffFrame
			b:SetScale(scale)
			if not MovAny:IsModified(PetBattleMover27) then
				local c = PetBattleFrame.AllyPadDebuffFrame
				c:SetScale(scale)
			end
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.AllyPadBuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.AllyPadBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.TopArtLeft, "BOTTOMLEFT", 400, 20)
		end
	},
	PetBattleMover27 = {
		w = 222,
		h = 30,
		point = {"TOPLEFT", "UIParent", "TOP", - 396, - 147},
		OnMAHook = function(self)
			local b = PetBattleFrame.AllyPadDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.AllyPadDebuffFrame
			b:SetScale(scale)
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.AllyPadDebuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.AllyPadDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.AllyPadBuffFrame, "BOTTOMRIGHT", 0, 0)
		end
	},
	PetBattleMover28 = {
		w = 222,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOP", 504, - 98},
		OnMAHook = function(self)
			local b = PetBattleFrame.EnemyBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.EnemyBuffFrame
			b:SetScale(scale)
			if not MovAny:IsModified(PetBattleMover29) then
				local c = PetBattleFrame.EnemyDebuffFrame
				c:SetScale(scale)
			end
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.EnemyBuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.EnemyBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.TopArtRight, "BOTTOMRIGHT", - 70, 20)
		end
	},
	PetBattleMover29 = {
		w = 222,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOP", 504, - 147},
		OnMAHook = function(self)
			local b = PetBattleFrame.EnemyDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.EnemyDebuffFrame
			b:SetScale(scale)
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.EnemyDebuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.EnemyDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", PetBattleFrame.EnemyBuffFrame, "BOTTOMRIGHT", 0, 0)
		end
	},
	PetBattleMover30 = {
		w = 222,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOP", 396, - 98},
		OnMAHook = function(self)
			local b = PetBattleFrame.EnemyPadBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.EnemyPadBuffFrame
			b:SetScale(scale)
			if not MovAny:IsModified(PetBattleMover31) then
				local c = PetBattleFrame.EnemyPadDebuffFrame
				c:SetScale(scale)
			end
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.EnemyPadBuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.EnemyPadBuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.TopArtRight, "BOTTOMRIGHT", - 400, 20)
		end
	},
	PetBattleMover31 = {
		w = 222,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOP", 396, - 147},
		OnMAHook = function(self)
			local b = PetBattleFrame.EnemyPadDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PetBattleFrame.EnemyPadDebuffFrame
			b:SetScale(scale)
		end,
		OnMAAlpha = function(self, alpha)
			local b = PetBattleFrame.EnemyPadDebuffFrame
			b:SetAlpha(alpha)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAPostReset = function(self)
			local b = PetBattleFrame.EnemyPadDebuffFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", PetBattleFrame.EnemyPadBuffFrame, "BOTTOMLEFT", 0, 0)
		end
	},
	ObjectiveTrackerFrameMover = {
		w = 235,
		h = 700,
		point = {"TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -10, 0},
		OnMAHook = function(self)
			local b = ObjectiveTrackerFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetHeight(self:GetHeight())
			b:SetUserPlaced(true)
			--self.sbf = b
		end,
		OnMAPostReset = function(self)
			local b = ObjectiveTrackerFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -10, 0)
			--b:SetHeight(b:GetTop() - 85)
		end,
		OnMAScale = function(self)
			local b = ObjectiveTrackerFrame
			local scaleS = self:GetScale()
			local scaleH = self:GetHeight()
			local scaleW = self:GetWidth()
			b:SetHeight(scaleH)
			b:SetWidth(scaleW)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(_G["ObjectiveTrackerFrame"])
			else
				MovAny:UnlockVisibility(_G["ObjectiveTrackerFrame"])
			end
		end
	},
	ObjectiveTrackerFrameScaleMover = {
		w = 235,
		h = 700,
		point = {"TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -10, 0},
		OnMAHook = function(self)
			local b = ObjectiveTrackerFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetHeight(self:GetHeight())
			b:SetUserPlaced(true)
			--self.sbf = b
		end,
		OnMAPostReset = function(self)
			local b = ObjectiveTrackerFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -10, 0)
			--b:SetHeight(b:GetTop() - 85)
		end,
		OnMAScale = function(self)
			local b = ObjectiveTrackerFrame
			local scaleS = self:GetScale()
			b:SetScale(scaleS)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(_G["ObjectiveTrackerFrame"])
			else
				MovAny:UnlockVisibility(_G["ObjectiveTrackerFrame"])
			end
		end
	},
	PlayerPowerBarAltMover = {
		w = 256,
		h = 64,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 155},
		OnMAHook = function(self)
			local b = PlayerPowerBarAlt
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", PlayerPowerBarAltMover, "CENTER")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			--b:SetMovable(true)
			--b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = PlayerPowerBarAlt
			b:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			local b = PlayerPowerBarAlt
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 155)
		end
	},
	TargetFramePowerBarAltMover = {
		w = 128,
		h = 32,
		point = {"LEFT", "TargetFrame", "RIGHT", -25, 5},
		OnMAHook = function(self)
			local b = TargetFramePowerBarAlt
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", TargetFramePowerBarAltMover, "CENTER")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			--b:SetMovable(true)
			--b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = TargetFramePowerBarAlt
			b:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			local b = TargetFramePowerBarAlt
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("LEFT", "TargetFrame", "RIGHT", -25, 5)
		end
	},
	QuickJoinToastMover = {
		w = 301,
		h = 32,
		point = {"LEFT", "QuickJoinToastButton", "RIGHT", -13, -1},
		OnMAHook = function(self)
			local b = QuickJoinToastButton.Toast
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", QuickJoinToastMover, "CENTER")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			--b:SetMovable(true)
			--b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = QuickJoinToastButton.Toast
			b:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			local b = QuickJoinToastButton.Toast
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("LEFT", "QuickJoinToastButton", "RIGHT", -13, -1)
		end
	},
	QuickJoinToast2Mover = {
		w = 301,
		h = 32,
		point = {"LEFT", "QuickJoinToastButton", "RIGHT", -13, -1},
		OnMAHook = function(self)
			local b = QuickJoinToastButton.Toast2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", QuickJoinToastMover, "CENTER")
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			--b:SetMovable(true)
			--b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local b = QuickJoinToastButton.Toast2
			b:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			local b = QuickJoinToastButton.Toast2
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("LEFT", "QuickJoinToastButton", "RIGHT", -13, -1)
		end
	},
	BagItemTooltipMover = {
		frameStrata = "TOOLTIP",
		w = 150,
		h = 80,
		point = {"TOP", "UIParent", 0, 0},
		OnLoad = function(self)
			self:SetFrameLevel(GameTooltip:GetFrameLevel() + 1)
		end,
		OnMAPreReset = function(self)
			local f = _G.GameTooltip
			self.MAE:Reset(f, true)
			f.MAHidden = nil
		end
	},
	GuildBankItemTooltipMover = {
		frameStrata = "TOOLTIP",
		w = 150,
		h = 80,
		point = {"TOP", "UIParent", 0, 0},
		OnLoad = function(self)
			self:SetFrameLevel(GameTooltip:GetFrameLevel() + 1)
		end,
		OnMAPreReset = function(self)
			local f = _G.GameTooltip
			self.MAE:Reset(f, true)
			f.MAHidden = nil
		end
	},
	MainMenuBarArtFrameLeftEndCapMover = {
		w = 128,
		h = 76,
		point = {"BOTTOMLEFT", "MainMenuBar", "BOTTOMLEFT", -98, 0},
		OnMAHook = function(self)
			local b = MainMenuBarArtFrame.LeftEndCap
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			MovAny:LockPoint(b)
		end,
		OnMAPostReset = function(self)
			local b = MainMenuBarArtFrame.LeftEndCap
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", "MainMenuBar", "BOTTOMLEFT", -98, 0)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MainMenuBarArtFrame.LeftEndCap)
			else
				MovAny:UnlockVisibility(MainMenuBarArtFrame.LeftEndCap)
			end
		end
	},
	MainMenuBarArtFrameRightEndCapMover = {
		w = 128,
		h = 76,
		point = {"BOTTOMRIGHT", "MainMenuBar", "BOTTOMRIGHT", 98, 0},
		OnMAHook = function(self)
			local b = MainMenuBarArtFrame.RightEndCap
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			MovAny:LockPoint(b)
		end,
		OnMAPostReset = function(self)
			local b = MainMenuBarArtFrame.RightEndCap
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMRIGHT", "MainMenuBar", "BOTTOMRIGHT", 98, 0)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MainMenuBarArtFrame.RightEndCap)
			else
				MovAny:UnlockVisibility(MainMenuBarArtFrame.RightEndCap)
			end
		end
	},
	BagButtonsMover = {
		w = 158,
		h = 30,
		relPoint = {"BOTTOMRIGHT", "MainMenuBarArtFrame", "BOTTOMRIGHT", -4, 6},
		excludes = "BagButtonsVerticalMover",
		children = {
			"MainMenuBarBackpackButton",
			"CharacterBag0Slot",
			"CharacterBag1Slot",
			"CharacterBag2Slot",
			"CharacterBag3Slot"
		},
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			else
				child:SetPoint("RIGHT", self.lastChild, "LEFT", - 2, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMRIGHT", "MainMenuBarArtFrame", "BOTTOMRIGHT", - 4, 6)
			else
				child:SetPoint("RIGHT", self.lastChild, "LEFT", - 2, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	BagButtonsVerticalMover = {
		w = 30,
		h = 158,
		relPoint = {"BOTTOMRIGHT", "MainMenuBarArtFrame", "BOTTOMRIGHT", - 4, 6},
		excludes = "BagButtonsMover",
		notMAParent = true,
		children = {
			"MainMenuBarBackpackButton",
			"CharacterBag0Slot",
			"CharacterBag1Slot",
			"CharacterBag2Slot",
			"CharacterBag3Slot"
		},
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
			else
				child:SetPoint("BOTTOM", self.lastChild, "TOP", 0, 2)
			end
			child.MAParent = self
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMRIGHT", "MainMenuBarArtFrame", "BOTTOMRIGHT", - 4, 6)
			else
				child:SetPoint("RIGHT", self.lastChild, "LEFT", - 2, 0)
			end
			child.MAParent = "BagButtonsMover"
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	BagFrame1 = {
		inherits = "MovableBagFrame",
		id = 0,
	},
	BagFrame2 = {
		inherits = "MovableBagFrame",
		id = 1,
	},
	BagFrame3 = {
		inherits = "MovableBagFrame",
		id = 2,
	},
	BagFrame4 = {
		inherits = "MovableBagFrame",
		id = 3,
	},
	BagFrame5 = {
		inherits = "MovableBagFrame",
		id = 4,
	},
	BankBagItemsMover = {
		w = 331,
		h = 169,
		relPoint = {"TOPLEFT", "BankFrame", "TOPLEFT", 28, - 75},
		children = {
			"BankFrameItem1",
			"BankFrameItem2",
			"BankFrameItem3",
			"BankFrameItem4",
			"BankFrameItem5",
			"BankFrameItem6",
			"BankFrameItem7",
			"BankFrameItem8",
			"BankFrameItem9",
			"BankFrameItem10",
			"BankFrameItem11",
			"BankFrameItem12",
			"BankFrameItem13",
			"BankFrameItem14",
			"BankFrameItem15",
			"BankFrameItem16",
			"BankFrameItem17",
			"BankFrameItem18",
			"BankFrameItem19",
			"BankFrameItem20",
			"BankFrameItem21",
			"BankFrameItem22",
			"BankFrameItem23",
			"BankFrameItem24",
			"BankFrameItem25",
			"BankFrameItem26",
			"BankFrameItem27",
			"BankFrameItem28"
		},
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			elseif child == BankFrameItem8 then
				child:SetPoint("TOPLEFT", "BankFrameItem1", "BOTTOMLEFT", 0, - 7)
			elseif child == BankFrameItem15 then
				child:SetPoint("TOPLEFT", "BankFrameItem8", "BOTTOMLEFT", 0, - 7)
			elseif child == BankFrameItem22 then
				child:SetPoint("TOPLEFT", "BankFrameItem15", "BOTTOMLEFT", 0, - 7)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPRIGHT", 12, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOPLEFT", "BankFrame", "TOPLEFT", 28, - 75)
			elseif child == BankFrameItem8 then
				child:SetPoint("TOPLEFT", "BankFrameItem1", "BOTTOMLEFT", 0, - 7)
			elseif child == BankFrameItem15 then
				child:SetPoint("TOPLEFT", "BankFrameItem8", "BOTTOMLEFT", 0, - 7)
			elseif child == BankFrameItem22 then
				child:SetPoint("TOPLEFT", "BankFrameItem15", "BOTTOMLEFT", 0, - 7)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPRIGHT", 12, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	BankBagSlotsMover = {
		w = 331,
		h = 37,
		relPoint = {"TOPLEFT", "BankFrameItem1", "BOTTOMLEFT", 0, - 164},
		OnMAHook = function(self)
			local b = _G.BankSlotsFrame.Bag1
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("LEFT", self, "LEFT", 0, 0)
			b:SetMovable(true)
			b:SetUserPlaced(true)
		end,
		OnMAPostReset = function(self)
			MovAny:UnlockPoint(ActionButton1)
			local b = _G.BankSlotsFrame.Bag1
			b:SetPoint("TOPLEFT", "BankFrameItem1", "BOTTOMLEFT", 0, - 164)
			b:SetMovable(true)
			b:SetUserPlaced(false)
			b:SetMovable(false)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			local children = {
				BankSlotsFrame.Bag1,
				BankSlotsFrame.Bag2,
				BankSlotsFrame.Bag3,
				BankSlotsFrame.Bag4,
				BankSlotsFrame.Bag5,
				BankSlotsFrame.Bag6,
				BankSlotsFrame.Bag7
			}
			for i = 1, #children do
				local b = children[i]
				b:SetScale(scale)
			end
		end
		--[[OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("LEFT", self, "LEFT", 0, 0)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPRIGHT", 12, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOPLEFT", "BankFrameItem1", "BOTTOMLEFT", 0, - 164)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPRIGHT", 12, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren]]
	},
	BankBagFrame1 = {
		inherits = "MovableBagFrame",
		id = 5,
	},
	BankBagFrame2 = {
		inherits = "MovableBagFrame",
		id = 6,
	},
	BankBagFrame3 = {
		inherits = "MovableBagFrame",
		id = 7,
	},
	BankBagFrame4 = {
		inherits = "MovableBagFrame",
		id = 8,
	},
	BankBagFrame5 = {
		inherits = "MovableBagFrame",
		id = 9,
	},
	BankBagFrame6 = {
		inherits = "MovableBagFrame",
		id = 10,
	},
	BankBagFrame7 = {
		inherits = "MovableBagFrame",
		id = 11,
	},
	--[[KeyRingFrame = {
		inherits = "MovableBagFrame",
		id = - 2,
	},]]
	MicroButtonsMover = {
		w = 287,
		h = 37,
		relPoint = {"BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2},
		excludes = "MicroButtonsSplitMover",
		excludes2 = "MicroButtonsVerticalMover",
		children = {
			"CharacterMicroButton",
			"SpellbookMicroButton",
			"TalentMicroButton",
			"AchievementMicroButton",
			"QuestLogMicroButton",
			"GuildMicroButton",
			"LFDMicroButton",
			"CollectionsMicroButton",
			"EJMicroButton",
			"StoreMicroButton",
			"MainMenuMicroButton"
		},
		OnMAFoundChild = function(self, index, child)
			if child == self.firstChild then
				child:ClearAllPoints()
				child:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockPoint(child)
			MovAny:UnlockScale(child)
			ScaleChildren(self, 1)
			AlphaChildren(self, 1)
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", - 2, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	MicroButtonsSplitMover = {
		w = 158,
		h = 74,
		relPoint = {"BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2},
		excludes = "MicroButtonsMover",
		excludes2 = "MicroButtonsVerticalMover",
		notMAParent = true,
		children = {
			"CharacterMicroButton",
			"SpellbookMicroButton",
			"TalentMicroButton",
			"AchievementMicroButton",
			"QuestLogMicroButton",
			"GuildMicroButton",
			"LFDMicroButton",
			"CollectionsMicroButton",
			"EJMicroButton",
			"StoreMicroButton",
			"MainMenuMicroButton"
		},
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 20)
			elseif child == LFDMicroButton then
				child:SetPoint("TOP", CharacterMicroButton, "BOTTOM", 0, 24)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", - 2, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockPoint(child)
			MovAny:UnlockScale(child)
			ScaleChildren(self, 1)
			AlphaChildren(self, 1)
			child.MAParent = "MicroButtonsMover"
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", - 2, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	MicroButtonsVerticalMover = {
		w = 29,
		h = 379,
		relPoint = {"BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2},
		excludes = "MicroButtonsMover",
		excludes2 = "MicroButtonsSplitMover",
		notMAParent = true,
		children = {
			"CharacterMicroButton",
			"SpellbookMicroButton",
			"TalentMicroButton",
			"AchievementMicroButton",
			"QuestLogMicroButton",
			"GuildMicroButton",
			"LFDMicroButton",
			"CollectionsMicroButton",
			"EJMicroButton",
			"StoreMicroButton",
			"MainMenuMicroButton"
		},
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOP", self, "TOP", 0, 20)
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, 24)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockPoint(child)
			MovAny:UnlockScale(child)
			ScaleChildren(self, 1)
			AlphaChildren(self, 1)
			child.MAParent = "MicroButtonsMover"
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 556, 2)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", - 2, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	BasicActionButtonsMover = {
		w = 498,
		h = 38,
		relPoint = {"BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 3},
		protected = true,
		excludes = "BasicActionButtonsVerticalMover",
		prefix = "ActionButton",
		count = 12,
		--prefix1 = "ActionButton",
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if self.prefix == nil then
				if not self.lastChild then
					child:SetPoint("LEFT", self, "LEFT")
				else
					child:SetPoint("LEFT", self.lastChild, "RIGHT", 6, 0)
				end
			else
				child:SetPoint("CENTER", self.prefix..index, "CENTER")
			end
		end,
		OnMAReleaseChild = function(self, index, child, prefix)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 546, 2)
			else
				child:SetPoint("BOTTOMLEFT", prefix, "BOTTOMRIGHT", -2, 0)
			end
		end,
		OnMAHook = function(self)
			local b, bab
			ActionButton1:ClearAllPoints()
			if ActionButton1.MASetPoint then
				ActionButton1:MASetPoint("LEFT", self, "LEFT")
			else
				ActionButton1:SetPoint("LEFT", self, "LEFT")
			end
			ActionBarUpButton:ClearAllPoints()
			ActionBarUpButton:SetPoint("TOPLEFT", "ActionButton12", "TOPRIGHT", 0, 7)
			ActionBarDownButton:ClearAllPoints()
			ActionBarDownButton:SetPoint("BOTTOMLEFT", "ActionButton12", "BOTTOMRIGHT", 0, -9)
			for i = 1, 12, 1 do
				b = _G["ActionButton"..i]
				if i > 1 then
					b:ClearAllPoints()
					b:SetPoint("LEFT", "ActionButton"..(i - 1), "RIGHT", 6, 0)
				end
				b.MAParent = self
				tinsert(self.attachedChildren, b)
			end
			if not MovAny:IsModified("ActionBarUpButton") then
				tinsert(self.attachedChildren, ActionBarUpButton)
			end
			if not MovAny:IsModified("ActionBarDownButton") then
				tinsert(self.attachedChildren, ActionBarDownButton)
			end
			MovAny:LockPoint(ActionButton1)
		end,
		OnMAPostReset = function(self)
			MovAny:UnlockPoint(ActionButton1)
			local b = _G["ActionButton1"]
			b:ClearAllPoints()
			if b.MASetPoint then
				b:MASetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 4)
			else
				b:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 4)
			end
			ActionBarUpButton:ClearAllPoints()
			ActionBarUpButton:SetPoint("CENTER", "MainMenuBarArtFrame", "TOPLEFT", 522, -22)
			ActionBarDownButton:ClearAllPoints()
			ActionBarDownButton:SetPoint("CENTER", "MainMenuBarArtFrame", "TOPLEFT", 522, -42)
			for i = 2, 12, 1 do
				b = _G[ "ActionButton"..i ]
				b:ClearAllPoints()
				b:SetPoint("LEFT", "ActionButton"..(i-1), "RIGHT", 6, 0)
				b:SetScale(1)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i = 1, 12 do
				_G["ActionButton"..i]:SetScale(scale)
			end
			ActionBarDownButton:SetScale(scale)
			ActionBarUpButton:SetScale(scale)
		end
	},
	OverrideActionButtonsMover = {
		w = 340,
		h = 52,
		relPoint = {"BOTTOM", "OverrideActionBar", "BOTTOM", - 133, 17},
		protected = true,
		prefix = "OverrideActionBarButton",
		count = 6,
		--prefix1 = "ActionButton",
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if self.prefix == nil then
				if not self.lastChild then
					child:SetPoint("LEFT", self, "LEFT")
				else
					child:SetPoint("LEFT", self.lastChild, "RIGHT", 6, 0)
				end
			else
				child:SetPoint("CENTER", self.prefix..index, "CENTER")
			end
		end,
		OnMAReleaseChild = function(self, index, child, prefix)
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", "OverrideActionBar", "BOTTOMLEFT", 546, 2)
			else
				child:SetPoint("BOTTOMLEFT", prefix, "BOTTOMRIGHT", - 2, 0)
			end
		end,
		OnMAHook = function(self)
			local b, bab
			OverrideActionBarButton1:ClearAllPoints()
			if OverrideActionBarButton1.MASetPoint then
				OverrideActionBarButton1:MASetPoint("LEFT", self, "LEFT")
			else
				OverrideActionBarButton1:SetPoint("LEFT", self, "LEFT")
			end
			for i = 1, 6, 1 do
				b = _G["OverrideActionBarButton"..i]
				if i > 1 then
					b:ClearAllPoints()
					b:SetPoint("LEFT", "OverrideActionBarButton"..(i - 1), "RIGHT", 6, 0)
				end
				b.MAParent = self
			end
			MovAny:LockPoint(OverrideActionBarButton1)
		end,
		OnMAPostReset = function(self)
			MovAny:UnlockPoint(OverrideActionBarButton1)
			local b = OverrideActionBarButton1
			b:ClearAllPoints()
			if b.MASetPoint then
				b:MASetPoint("BOTTOM", "OverrideActionBar", "BOTTOM", 277, 17)
			else
				b:SetPoint("BOTTOM", "OverrideActionBar", "BOTTOM", - 277, 17)
			end
			for i = 2, 6, 1 do
				b = _G[ "OverrideActionBarButton"..i ]
				b:ClearAllPoints()
				b:SetPoint("LEFT", "OverrideActionBarButton"..(i - 1), "RIGHT", 6, 0)
			end
		end,
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	BasicActionButtonsVerticalMover = {
		w = 38,
		h = 475,
		relPoint = {"BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 4},
		protected = true,
		excludes = "BasicActionButtonsMover",
		OnMAHook = function(self)
			local b
			b = _G["ActionButton1"]
			b:ClearAllPoints()
			if b.MASetPoint then
				b:MASetPoint("TOP", self, "TOP")
			else
				b:SetPoint("TOP", self, "TOP")
			end
			for i = 1, 12, 1 do
				b = _G[ "ActionButton"..i ]
				tinsert(self.attachedChildren, _G[ "ActionButton"..i ])
				if i > 1 then
					b:ClearAllPoints()
					b:SetPoint("TOP", "ActionButton"..(i-1), "BOTTOM", 0, -2)
				end
				b.MAParent = self
			end
			tinsert(self.attachedChildren, ActionBarUpButton)
			tinsert(self.attachedChildren, ActionBarDownButton)
			ActionBarUpButton:ClearAllPoints()
			ActionBarUpButton:SetPoint("TOPLEFT", "ActionButton12", "BOTTOMLEFT", -8, 4)
			ActionBarDownButton:ClearAllPoints()
			ActionBarDownButton:SetPoint("TOPRIGHT", "ActionButton12", "BOTTOMRIGHT", 8, 4)
		end,
		OnMAPostReset = function(self)
			local b
			b = _G["ActionButton1"]
			b:ClearAllPoints()
			if b.MASetPoint then
				b:MASetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 4)
			else
				b:SetPoint("BOTTOMLEFT", "MainMenuBarArtFrame", "BOTTOMLEFT", 8, 4)
			end
			ActionBarUpButton:ClearAllPoints()
			ActionBarUpButton:SetPoint("CENTER", "MainMenuBarArtFrame", "TOPLEFT", 522, -22)
			ActionBarDownButton:ClearAllPoints()
			ActionBarDownButton:SetPoint("CENTER", "MainMenuBarArtFrame", "TOPLEFT", 522, -42)
			for i = 2, 12, 1 do
				b = _G[ "ActionButton"..i ]
				b.MAParent = BasicActionButtonsMover
				b:ClearAllPoints()
				b:SetPoint("LEFT", "ActionButton"..(i-1), "RIGHT", 6, 0)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i = 1, 12 do
				_G["ActionButton"..i]:SetScale(scale)
			end
			ActionBarDownButton:SetScale(scale)
			ActionBarUpButton:SetScale(scale)
		end
	},
	PetActionButtonsMover = {
		w = 375,
		h = 36,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		excludes = "PetActionButtonsVerticalMover",
		protected = true,
		prefix = "PetActionButton",
		count = 10,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			child.MAParent = self
			if index == 1 then
				child:SetPoint("LEFT", self, "LEFT", 0, 0)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 8, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			child.MAParent = self
			if index == 1 then
				child:SetPoint("BOTTOMLEFT", "PetActionBarFrame", "BOTTOMLEFT", 36, 2)
				child.SetParent = self
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 8, 0)
				child.SetParent = self
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			--[[for i = 1, 10 do
				_G["PetActionButton"..i]:SetScale(scale)
			end]]
			PetActionBarFrame:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			--[[for i = 1, 10 do
				_G["PetActionButton"..i]:SetScale(1)
				self:SetScale(1)
			end]]
			PetActionBarFrame:SetScale(1)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				for i = 1, 10 do
				--local frame = _G["PetActionButton"..i]
					HidenFrame.frameinfo["PetActionBarFrame"] = PetActionBarFrame:GetParent()
					PetActionBarFrame:SetParent("HidenFrame")
					PetActionBarFrame:Hide()
					PetActionBarFrame:UnregisterAllEvents()
				end
			else
				if HidenFrame.frameinfo["PetActionBarFrame"] then
					PetActionBarFrame:SetParent(HidenFrame.frameinfo["PetActionBarFrame"])
				end
				PetActionBarFrame:Show()
			end
		end
	},
	PetActionButtonsVerticalMover = {
		w = 36,
		h = 375,
		point = {"BOTTOMLEFT", "PetActionBarFrame", "BOTTOMLEFT", 36, 1},
		excludes = "PetActionButtonsMover",
		notMAParent = true,
		protected = true,
		prefix = "PetActionButton",
		count = 10,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			child.MAParent = self
			if index == 1 then
				child:SetPoint("TOP", self, "TOP", 0, 0)
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -8)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			child.MAParent = "PetActionButtonsMover"
			if index == 1 then
				child:SetPoint("BOTTOMLEFT", "PetActionBarFrame", "BOTTOMLEFT", 36, 1)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 8, 0)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i = 1, 10 do
				_G["PetActionButton"..i]:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			for i = 1, 10 do
				_G["PetActionButton"..i]:SetScale(1)
				self:SetScale(1)
			end
		end
	},
	--[[ExtraActionBarFrameMover = {
		w = 52,
		h = 52,
		point = {"BOTTOM", "MainMenuBar", 0, 160},
		protected = true,
		dontLock = true,
		prefix = "ExtraActionButton",
		count = 1,
		OnMAHook = function(self)
			local b = _G.ExtraActionBarFrame
			b:DisableDrawLayer("BACKGROUND")
			b:DisableDrawLayer("BORDER")
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", ExtraActionBarFrameMover, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAPreReset = function(self)
			local b = self.sbf
			MovAny:UnlockPoint(b)
			b:SetPoint("BOTTOM", _G.MainMenuBar, 0, 160)
			b:EnableDrawLayer("BACKGROUND")
			b:EnableDrawLayer("BORDER")
			b.ignoreFramePositionManager = nil
			b:SetUserPlaced(nil)
			b:SetMovable(nil)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end
	},]]
	MonkHarmonyBarFrameMover = {
		w = 110,
		h = 30,
		inherits = MonkHarmonyBarFrame,
		point = {"TOP", "PlayerFrame", "TOP", 49, -46 - (30 / 2)},
		OnMAHook = function(self)
			local b = MonkHarmonyBarFrame
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("CENTER", self, "CENTER", 0, 0)
			MovAny:LockPoint(b)
			--b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			MonkHarmonyBarFrame:SetScale(scale)
		end,
		OnMAPostReset = function(self)
			MovAny:UnlockPoint(MonkHarmonyBarFrame)
			local b = MonkHarmonyBarFrame
			b:ClearAllPoints()
			b:SetPoint("TOP", "PlayerFrame", "TOP", 49, -46)
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
			else
				MovAny:UnlockVisibility(self.sbf)
			end
		end
	},
	StanceButtonsMover = {
		w = 225,
		h = 37,
		point = {"BOTTOMLEFT", "MainMenuBar", "TOPLEFT", 45, 30},
		excludes = "StanceButtonsVerticalMover",
		protected = true,
		prefix = "StanceButton",
		count = 10,
		--dontLock = true,
		OnMAHook = function(self)
			local b = _G.StanceBarFrame
			b:DisableDrawLayer("BACKGROUND")
			b:DisableDrawLayer("BORDER")
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		OnMAPreReset = function(self)
			local b = self.sbf
			MovAny:UnlockPoint(b)
			b:SetPoint("BOTTOMLEFT", _G.MainMenuBar, "TOPLEFT", 45, 30)
			b:EnableDrawLayer("BACKGROUND")
			b:EnableDrawLayer("BORDER")
			b.ignoreFramePositionManager = nil
			b:SetUserPlaced(nil)
			b:SetMovable(nil)
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
				RegisterStateDriver(StanceBarFrame, "visibility", "hide")
			else
				MovAny:UnlockVisibility(self.sbf)
				RegisterStateDriver(StanceBarFrame, "visibility", "show")
			end
		end
	},
	StanceButtonsVerticalMover = {
		w = 32,
		h = 225,
		point = {"BOTTOMLEFT", "MainMenuBar", "TOPLEFT", 45, 30},
		excludes = "StanceButtonsMover",
		--notMAParent = true,
		protected = true,
		prefix = "StanceButton",
		count = 10,
		OnMAHook = function(self)
			local b = _G.StanceBarFrame
			b:DisableDrawLayer("BACKGROUND")
			b:DisableDrawLayer("BORDER")
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAPostReset = function(self)
			local b = self.sbf
			b:EnableDrawLayer("BACKGROUND")
			b:EnableDrawLayer("BORDER")
			b.ignoreFramePositionManager = nil
			if self.sbf:IsUserPlaced() then
				self.sbf:SetUserPlaced(nil)
			end
			if self.sbf:IsMovable() then
				self.sbf:SetMovable(nil)
			end
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		OnMAFoundChild = function(self, index, child)
			child.MAParent = self
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("TOP", self, "TOP", 0, -7)
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -7)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child.MAParent = "StanceButtonsMover"
			child:ClearAllPoints()
			if child == self.firstChild then
				child:SetPoint("BOTTOMLEFT", self.sbf, "BOTTOMLEFT", 11, 3)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 8, 0)
			end
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(self.sbf)
				RegisterStateDriver(StanceBarFrame, "visibility", "hide")
			else
				MovAny:UnlockVisibility(self.sbf)
				RegisterStateDriver(StanceBarFrame, "visibility", "show")
			end
		end
	},
	MultiBarRightMover = {
		w = 38,
		h = 498,
		point = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 98},
		excludes = "MultiBarRightHorizontalMover",
		--notMAParent = true,
		protected = true,
		prefix = "MultiBarRightButton",
		count = 12,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPLEFT", self)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPLEFT", 0, -42)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPRIGHT", "MultiBarRight")
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -6)
			end
			child.MAParent = nil
		end,
		OnMAHook = function(self)
			MultiBarRight:SetParent("UIParent")
		end,
		OnMAPreReset = function(self)
			MultiBarRight:SetScale(1)
			for i=1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(1)
			end
			MultiBarRight.MAHooked = nil
		end,
		OnMAPostReset = function(self)
			MultiBarRight:SetScale(1)
			for i=1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(1)
			end
			MultiBarRight.MAHooked = nil
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			--MultiBarRight:SetScale(scale)
			for i = 1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(scale)
			end
		end
	},
	MultiBarRightHorizontalMover = {
		w = 498,
		h = 38,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 250},
		excludes = "MultiBarRightMover",
		--notMAParent = true,
		protected = true,
		prefix = "MultiBarRightButton",
		count = 12,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPLEFT", self)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 6, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPRIGHT", "MultiBarRight")
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -6)
			end
			child.MAParent = nil
		end,
		OnMAPostReset = function(self)
			MultiBarRight:SetScale(1)
			for i = 1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(1)
			end
			MultiBarRight.MAHooked = nil
		end,
		OnMAPreReset = function(self)
			MultiBarRight:SetScale(1)
			for i = 1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(1)
			end
			MultiBarRight.MAHooked = nil
		end,
		OnMAHook = function(self)
			MultiBarRight:SetParent("UIParent")
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i = 1, 12 do
				_G["MultiBarRightButton"..i]:SetScale(scale)
			end
		end
	},
	MultiBarLeftMover = {
		w = 38,
		h = 498,
		point = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -38, 98},
		excludes = "MultiBarLeftHorizontalMover",
		--notMAParent = true,
		protected = true,
		prefix = "MultiBarLeftButton",
		count = 12,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPLEFT", self)
			else
				child:SetPoint("TOPLEFT", self.lastChild, "TOPLEFT", 0, -42)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPRIGHT", "MultiBarLeft")
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -6)
			end
			child.MAParent = nil
		end,
		OnMAHook = function(self)
			MultiBarLeft:SetParent("UIParent")
		end,
		OnMAPreReset = function(self)
			MultiBarLeft:SetScale(1)
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(1)
			end
			--MultiBarLeft:SetParent("MultiBarRight")
			MultiBarLeft.MAHooked = nil
		end,
		OnMAPostReset = function(self)
			MultiBarLeft:SetScale(1)
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(1)
			end
			--MultiBarLeft:SetParent("MultiBarRight")
			MultiBarLeft.MAHooked = nil
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(scale)
			end
		end
	},
	MultiBarLeftHorizontalMover = {
		w = 498,
		h = 38,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 285},
		excludes = "MultiBarLeftMover",
		--notMAParent = true,
		protected = true,
		prefix = "MultiBarLeftButton",
		count = 12,
		OnMAFoundChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPLEFT", self)
			else
				child:SetPoint("LEFT", self.lastChild, "RIGHT", 6, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			child:ClearAllPoints()
			if index == 1 then
				child:SetPoint("TOPRIGHT", "MultiBarLeft")
			else
				child:SetPoint("TOP", self.lastChild, "BOTTOM", 0, -6)
			end
			child.MAParent = nil
		end,
		OnMAPreReset = function(self)
			MultiBarLeft:SetScale(1)
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(1)
			end
			--MultiBarLeft:SetParent("MultiBarRight")
			MultiBarLeft.MAHooked = nil
		end,
		OnMAPostReset = function(self)
			MultiBarLeft:SetScale(1)
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(1)
			end
			--MultiBarLeft:SetParent("MultiBarRight")
			MultiBarLeft.MAHooked = nil
		end,
		OnMAHook = function(self)
			MultiBarLeft:SetParent("UIParent")
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			for i=1, 12 do
				_G["MultiBarLeftButton"..i]:SetScale(scale)
			end
		end
	},
	PartyMember1DebuffsMover = {
		w = 66,
		h = 15,
		point = {"TOPLEFT", "PartyMemberFrame1", "TOPLEFT", 48, -32},
		prefix = "PartyMemberFrame1Debuff",
		count = MAX_PARTY_DEBUFFS,
		dontLock = true,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self)
				MovAny:LockPoint(child)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "PartyMemberFrame1", 48, -32)
			end
		end,
		OnMAHook = function(self)
			self:SetScale(_G["PartyMemberFrame1"]:GetEffectiveScale() / UIParent:GetScale())
		end
	},
	PartyMember2DebuffsMover = {
		w = 66,
		h = 15,
		point = {"TOPLEFT", "PartyMemberFrame2", "TOPLEFT", 48, -32},
		prefix = "PartyMemberFrame2Debuff",
		count = MAX_PARTY_DEBUFFS,
		dontLock = true,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self)
				MovAny:LockPoint(child)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "PartyMemberFrame2", 48, -32)
			end
		end,
		OnMAHook = function(self)
			self:SetScale(_G["PartyMemberFrame2"]:GetEffectiveScale() / UIParent:GetScale())
		end
	},
	PartyMember3DebuffsMover = {
		w = 66,
		h = 15,
		point = {"TOPLEFT", "PartyMemberFrame3", "TOPLEFT", 48, -32},
		prefix = "PartyMemberFrame3Debuff",
		count = MAX_PARTY_DEBUFFS,
		dontLock = true,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self)
				MovAny:LockPoint(child)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "PartyMemberFrame3", 48, -32)
			end
		end,
		OnMAHook = function(self)
			self:SetScale(_G["PartyMemberFrame3"]:GetEffectiveScale() / UIParent:GetScale())
		end
	},
	PartyMember4DebuffsMover = {
		w = 66,
		h = 17,
		point = {"TOPLEFT", "PartyMemberFrame4", "TOPLEFT", 48, -32},
		prefix = "PartyMemberFrame4Debuff",
		count = MAX_PARTY_DEBUFFS,
		dontLock = true,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self)
				MovAny:LockPoint(child)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "PartyMemberFrame4", 48, -32)
			end
		end,
		OnMAHook = function(self)
			self:SetScale(_G["PartyMemberFrame4"]:GetEffectiveScale() / UIParent:GetScale())
		end
	},
	PetDebuffsMover = {
		w = 66,
		h = 17,
		point = {"TOPLEFT", "PetFrame", "TOPLEFT", 48, -42},
		prefix = "PetFrameDebuff",
		count = 4,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "PetFrame", 48, -42)
			end
		end,
		OnMAHook = function(self)
			self:SetScale(_G["PetFrame"]:GetEffectiveScale() / UIParent:GetScale())
		end
	},
	TargetBuffsMover = {
		w = 118,
		h = 21,
		point = {"TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32},
		prefix = "TargetFrameBuff",
		count = MAX_TARGET_BUFFS,
		--dontLock = true,
		OnLoad = function(self)
			if TargetFrame_UpdateAuras then
				hooksecurefunc("TargetFrame_UpdateAuras", function(frame)
					if frame == TargetFrame and self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockPoint(child)
			MovAny:UnlockScale(child)
			child:SetScale(1)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32)
			end
		end,
		--[[OnMAHook = function(self)
			MovAny:UnlockScale(self)
			self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
			MovAny:LockScale(self)
		end,]]
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	TargetDebuffsMover = {
		w = 118,
		h = 21,
		point = {"TOPLEFT", "TargetFrameBuffs", "BOTTOMLEFT", 0, - 6},
		prefix = "TargetFrameDebuff",
		count = MAX_TARGET_DEBUFFS,
		--dontLock = true,
		OnLoad = function(self)
			if TargetFrame_UpdateAuras then
				hooksecurefunc("TargetFrame_UpdateAuras", function(frame)
					if frame == TargetFrame and self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockScale(child)
			MovAny:UnlockPoint(child)
			child:SetScale(1)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "TargetFrameBuffs", "BOTTOMLEFT", 0, - 6)
			end
		end,
		--[[OnMAHook = function(self)
			MovAny:UnlockScale(self)
			self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
			MovAny:LockScale(self)
		end,]]
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	FocusBuffsMover = {
		w = 118,
		h = 21,
		point = {"TOPLEFT", "FocusFrame", "BOTTOMLEFT", 5, 32},
		prefix = "FocusFrameBuff",
		count = MAX_TARGET_BUFFS,
		--dontLock = true,
		OnLoad = function(self)
			if TargetFrame_UpdateAuras then
				hooksecurefunc("TargetFrame_UpdateAuras", function(frame)
					if frame == FocusFrame and self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockScale(child)
			MovAny:UnlockPoint(child)
			child:SetScale(1)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "FocusFrame", "BOTTOMLEFT", 5, 32)
			end
		end,
		--[[OnMAHook = function(self)
			MovAny:UnlockScale(self)
			self:SetScale(_G["FocusFrame"]:GetEffectiveScale() / UIParent:GetScale())
			MovAny:LockScale(self)
		end,]]
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	FramerateLabelMover = {
		w = 85,
		h = 18,
		point = {"BOTTOM", "UIParent", "BOTTOM", 26, 153},
		OnMAHook = function(self)
			local b = FramerateLabel
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT")
			MovAny:LockPoint(b)
		end,
		OnMAPostReset = function(self)
			local b = FramerateLabel
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 110)
		end,
		OnMAHide = function(self, hidden)
			local b = FramerateLabel
			local n = FramerateText
			if hidden then
				MovAny:LockVisibility(b)
				MovAny:LockVisibility(n)
			else
				MovAny:UnlockVisibility(b)
				MovAny:UnlockVisibility(n)
			end
		end
	},
	FocusDebuffsMover = {
		w = 118,
		h = 21,
		point = {"TOPLEFT", "FocusFrameBuffs", "BOTTOMLEFT", 0, - 6},
		prefix = "FocusFrameDebuff",
		count = MAX_TARGET_DEBUFFS,
		--dontLock = true,
		OnLoad = function(self)
			if TargetFrame_UpdateAuras then
				hooksecurefunc("TargetFrame_UpdateAuras", function(frame)
					if frame == FocusFrame and self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				self:SetScale(_G["TargetFrame"]:GetEffectiveScale() / UIParent:GetScale())
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			MovAny:UnlockScale(child)
			MovAny:UnlockPoint(child)
			child:SetScale(1)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "FocusFrameBuffs", "BOTTOMLEFT", 0, - 6)
			end
		end,
		--[[OnMAHook = function(self)
			MovAny:UnlockScale(self)
			self:SetScale(_G["FocusFrame"]:GetEffectiveScale() / UIParent:GetScale())
			MovAny:LockScale(self)
		end,]]
		OnMAScale = ScaleChildren,
		OnMAPreReset = ResetChildren
	},
	TargetFrameToTDebuffsMover = {
		w = 12,
		h = 12,
		point = {"TOPLEFT", "TargetFrameToT", "TOPRIGHT", 4, - 10},
		prefix = "TargetFrameToTDebuff",
		count = 4,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", TargetFrameToT, "TOPRIGHT", 4, - 10)
			end
			MovAny:UnlockScale(child)
			child:SetScale(_G["TargetFrameToT"]:GetEffectiveScale() / UIParent:GetScale())
		end,
		OnMAHook = function(self)
			self:SetScale(_G["TargetFrameToT"]:GetEffectiveScale() / UIParent:GetScale())
		end,
		OnMAScale = ScaleChildren,
		OnMAPostReset = ResetChildren
	},
	PlayerBuffsMover = {
		w = 30,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", - 205, - 13},
		children = {"TemporaryEnchantFrame"},
		prefix = "BuffButton",
		excludes = "PlayerBuffsMover2",
		count = 40,
		dontHide = true,
		dontLock = true,
		dontScale = true,
		OnLoad = function(vm)
			if BuffFrame_Update then
				local hBuffFrame_Update = function()
					local opt = vm.opt
					if opt and not opt.disabled and vm.MAE and vm.MAE:IsModified() then
						vm:MAScanForChildren(true, true)
						if opt.scale then
							if not opt.hidden and vm.attachedChildren then
								for i, v in pairs(vm.attachedChildren) do
									v:SetScale(opt.scale)
								end
							end
						end
						MovAny:UnlockPoint(vm.tef)
						vm.tef:ClearAllPoints()
						vm.tef:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
						MovAny:LockPoint(vm.tef)
					end
				end
				hooksecurefunc("BuffFrame_Update", function()
					xpcall(hBuffFrame_Update, hBuffFrame_ErrorHandler)
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				if TempEnchant1:IsShown() and TempEnchant2:IsShown() and TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", self, "TOPRIGHT", -101, 0)
				elseif TempEnchant1:IsShown() and TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", self, "TOPRIGHT", -69, 0)
				elseif TempEnchant1:IsShown() and not TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", self, "TOPRIGHT", -37, 0)
				else
					child:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
				end
				MovAny:LockPoint(child)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				if TempEnchant1:IsShown() and TempEnchant2:IsShown() and TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -306, -13)
				elseif TempEnchant1:IsShown() and TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -274, -13)
				elseif TempEnchant1:IsShown() and not TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -242, -13)
				else
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -205, -13)
				end
			end
		end,
		OnMAAlpha = function(self, alpha)
			BuffFrame:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		OnMAHook = function(self)
			local b = _G["BuffFrame"]
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			MovAny:LockPoint(b)
			--b = _G["TemporaryEnchantFrame"]
			--MovAny:LockPoint(b)
			self.tef = b
			if self.attachedChildren and self.opt and self.opt.scale then
				for i, v in pairs(self.attachedChildren) do
					v:SetScale(self.opt.scale)
				end
			end
		end,
		OnMAPreReset = function(self, readOnly)
			if readOnly then
				return true
			end
			MovAny:UnlockPoint(self.tef)
			local b = _G["BuffFrame"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", - 205, - 13)
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
			BuffFrame:SetAlpha(1)
			for i, v in pairs(self.attachedChildren) do
				v:SetAlpha(1)
			end
			self.tef = nil
		end,
		OnMAPostReset = function(self, readOnly)
			if readOnly then
				return true
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(_G["BuffFrame"])
				MovAny:LockVisibility(_G["TemporaryEnchantFrame"])
			else
				MovAny:UnlockVisibility(_G["BuffFrame"])
				MovAny:UnlockVisibility(_G["TemporaryEnchantFrame"])
			end
		end
	},
	PlayerBuffsMover2 = {
		w = 30,
		h = 30,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", - 205, - 13},
		children = {"TemporaryEnchantFrame"},
		prefix = "BuffButton",
		excludes = "PlayerBuffsMover",
		count = 40,
		dontHide = true,
		dontLock = true,
		dontScale = true,
		OnLoad = function(vm)
			if BuffFrame_Update then
				local hBuffFrame_Update = function()
					local opt = vm.opt
					if opt and not opt.disabled and vm.MAE and vm.MAE:IsModified() then
						vm:MAScanForChildren(true, true)
						if opt.scale then
							if not opt.hidden and vm.attachedChildren then
								for i, v in pairs(vm.attachedChildren) do
									v:SetScale(opt.scale)
								end
							end
						end
						MovAny:UnlockPoint(vm.tef)
						vm.tef:ClearAllPoints()
						vm.tef:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
						MovAny:LockPoint(vm.tef)
					end
				end
				hooksecurefunc("BuffFrame_Update", function()
					xpcall(hBuffFrame_Update, hBuffFrame_ErrorHandler)
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if self.opt and self.opt.scale then
				--MovAny:UnlockScale(child)
				child:SetScale(self.opt.scale)
			end
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				if TempEnchant1:IsShown() and TempEnchant2:IsShown() and TempEnchant3:IsShown() then
					TempEnchant1:ClearAllPoints()
					TempEnchant1:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
					TempEnchant2:ClearAllPoints()
					TempEnchant2:SetPoint("TOPLEFT", TempEnchant1, "TOPRIGHT", 5, 0)
					TempEnchant3:ClearAllPoints()
					TempEnchant3:SetPoint("TOPLEFT", TempEnchant2, "TOPRIGHT", 5, 0)
					child:SetPoint("TOPLEFT", self, "TOPLEFT", 101, 0)
				elseif TempEnchant1:IsShown() and TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					TempEnchant1:ClearAllPoints()
					TempEnchant1:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
					TempEnchant2:ClearAllPoints()
					TempEnchant2:SetPoint("TOPLEFT", TempEnchant1, "TOPRIGHT", 5, 0)
					child:SetPoint("TOPLEFT", self, "TOPLEFT", 69, 0)
				elseif TempEnchant1:IsShown() and not TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					TempEnchant1:ClearAllPoints()
					TempEnchant1:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
					child:SetPoint("TOPLEFT", self, "TOPLEFT", 37, 0)
				else
					child:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
				end
				MovAny:LockPoint(child)
			else
				if string.match(child:GetName(), "BuffButton") then
					if index == 9 or index == 17 or index == 25 or index == 33 then
						MovAny:UnlockPoint(child)
						child:ClearAllPoints()
						child:SetPoint("TOP", "BuffButton"..(index - 8), "BOTTOM", 0, -15)
					else
						MovAny:UnlockPoint(child)
						child:ClearAllPoints()
						child:SetPoint("LEFT", "BuffButton"..(index - 1), "RIGHT", 5, 0)
					end
				end
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				MovAny:UnlockPoint(child)
				child:ClearAllPoints()
				TempEnchant1:ClearAllPoints()
				TempEnchant1:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
				TempEnchant2:ClearAllPoints()
				TempEnchant2:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -5, 0)
				TempEnchant3:ClearAllPoints()
				TempEnchant3:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -5, 0)
				if TempEnchant1:IsShown() and TempEnchant2:IsShown() and TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -306, -13)
				elseif TempEnchant1:IsShown() and TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -274, -13)
				elseif TempEnchant1:IsShown() and not TempEnchant2:IsShown() and not TempEnchant3:IsShown() then
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -242, -13)
				else
					child:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -205, -13)
				end
				--MovAny:LockPoint(child)
			else
				if string.match(child:GetName(), "BuffButton") then
					if index == 9 or index == 17 or index == 25 or index == 33 then
						MovAny:UnlockPoint(child)
						child:ClearAllPoints()
						child:SetPoint("TOP", "BuffButton"..(index - 8), "BOTTOM", 0, -15)
					else
						MovAny:UnlockPoint(child)
						child:ClearAllPoints()
						child:SetPoint("RIGHT", "BuffButton"..(index - 1), "LEFT", - 5, 0)
					end
				end
			end
		end,
		OnMAAlpha = function(self, alpha)
			BuffFrame:SetAlpha(alpha)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		OnMAHook = function(self)
			local b = _G["BuffFrame"]
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			MovAny:LockPoint(b)
			--b = _G["TemporaryEnchantFrame"]
			--MovAny:LockPoint(b)
			self.tef = b
			if BuffFrame.numConsolidated == 0 then
				if not b then
					return
				end
				b:Hide()
			end
			if self.attachedChildren and self.opt and self.opt.scale then
				for i, v in pairs(self.attachedChildren) do
					v:SetScale(self.opt.scale)
				end
			end
		end,
		OnMAPreReset = function(self, readOnly)
			if readOnly then
				return true
			end
			MovAny:UnlockPoint(self.tef)
			local b = _G["BuffFrame"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", - 205, - 13)
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
			BuffFrame:SetAlpha(1)
			for i, v in pairs(self.attachedChildren) do
				v:SetAlpha(1)
			end
			self.tef = nil
		end,
		OnMAPostReset = function(self, readOnly)
			if readOnly then
				return true
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(_G["BuffFrame"])
				MovAny:LockVisibility(_G["TemporaryEnchantFrame"])
			else
				MovAny:UnlockVisibility(_G["BuffFrame"])
				MovAny:UnlockVisibility(_G["TemporaryEnchantFrame"])
			end
		end
	},
	PlayerDebuffsMover = {
		w = 30,
		h = 30,
		prefix = "DebuffButton",
		excludes = "PlayerDebuffsMover2",
		count = 40,
		point = {"TOPRIGHT", "BuffFrame", "BOTTOMRIGHT", 0, - 60},
		OnLoad = function(self)
			if BuffFrame_Update then
				hooksecurefunc("BuffFrame_Update", function()
					if self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPRIGHT", "BuffFrame", "BOTTOMRIGHT", 0, - 60)
			end
			child:SetAlpha(1)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		--[[OnMAHook = function(self)
			self:SetScale(_G["BuffFrame"]:GetEffectiveScale() / UIParent:GetScale())
		end,]]
		OnMAPreReset = function(self, readOnly)
			if readOnly then
				return true
			end
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
		end
	},
	PlayerDebuffsMover2 = {
		w = 30,
		h = 30,
		prefix = "DebuffButton",
		excludes = "PlayerDebuffsMover",
		count = 16,
		point = {"TOPRIGHT", "BuffFrame", "BOTTOMRIGHT", 0, - 60},
		OnLoad = function(self)
			if BuffFrame_Update then
				hooksecurefunc("BuffFrame_Update", function()
					if self.MAHooked then
						self:MAScanForChildren()
					end
				end)
			end
		end,
		OnMAFoundChild = function(self, index, child)
			if self.opt and self.opt.scale then
				--MovAny:UnlockScale(child)
				child:SetScale(self.opt.scale)
			end
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			else
				if string.match(child:GetName(), "DebuffButton") then
					if index == 9 or index == 17 or index == 25 or index == 33 then
						child:ClearAllPoints()
						child:SetPoint("TOP", "DebuffButton"..(index - 8), "BOTTOM", 0, - 15)
					else
						child:ClearAllPoints()
						child:SetPoint("LEFT", "DebuffButton"..(index - 1), "RIGHT", 5, 0)
					end
				end
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPRIGHT", "BuffFrame", "BOTTOMRIGHT", 0, - 60)
			else
				if string.match(child:GetName(), "DebuffButton") then
					if index == 9 or index == 17 or index == 25 or index == 33 then
						child:ClearAllPoints()
						child:SetPoint("TOP", "DebuffButton"..(index - 8), "BOTTOM", 0, - 15)
					else
						child:ClearAllPoints()
						child:SetPoint("RIGHT", "DebuffButton"..(index - 1), "LEFT", 5, 0)
					end
				end
			end
			child:SetAlpha(1)
		end,
		OnMAScale = function(self, scale)
			if type(scale) ~= "number" then
				return
			end
			if self.attachedChildren then
				for i, child in pairs(self.attachedChildren) do
					child:SetScale(scale)
				end
			end
		end,
		--[[OnMAHook = function(self)
			self:SetScale(_G["BuffFrame"]:GetEffectiveScale() / UIParent:GetScale())
		end,]]
		OnMAPreReset = function(self, readOnly)
			if readOnly then
				return true
			end
			for i, v in pairs(self.attachedChildren) do
				MovAny:UnlockScale(v)
				v:SetScale(1)
			end
		end
	},
	FocusFrameToTDebuffsMover = {
		w = 12,
		h = 12,
		point = {"TOPLEFT", "FocusFrameToT", "TOPRIGHT", 4, - 10},
		prefix = "FocusFrameToTDebuff",
		count = 4,
		OnMAFoundChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", self, 0, 0)
			end
		end,
		OnMAReleaseChild = function(self, index, child)
			if index == 1 then
				child:ClearAllPoints()
				child:SetPoint("TOPLEFT", "FocusFrameToT", "TOPRIGHT", 4, - 10)
			end
			MovAny:UnlockScale(child)
			child:SetScale(_G["FocusFrameToT"]:GetEffectiveScale() / UIParent:GetScale())
		end,
		OnMAHook = function(self)
			self:SetScale(_G["FocusFrameToT"]:GetEffectiveScale() / UIParent:GetScale())
		end,
		OnMAScale = ScaleChildren,
		OnMAPostReset = ResetChildren
	},
	RaidUnitFramesMover = {
		linkedSize = "CompactRaidFrameContainer",
		linkedPoint = "CompactRaidFrameContainer",
		children = {"CompactRaidFrameContainer"},
		dontLock = true,
		OnLoad = function(self)
			if CompactRaidFrameManager_SetSetting then
				hooksecurefunc("CompactRaidFrameManager_SetSetting", function(setting, value, skip)
					if skip ~= "MASkip" and setting == "Locked" and IsShiftKeyDown() then
						if not InCombatLockdown() then
							if value then
								MovAny:StopMoving(self:GetName())
							else
								CompactRaidFrameManager_LockContainer(CompactRaidFrameManager)
								if not MovAny:GetMoverByFrame(self:GetName()) then
									MovAny:AttachMover(self:GetName())
								end
							end
						end
					end
				end)
			end
		end,
		OnMAHook = function(self)
			local con = _G["CompactRaidFrameContainer"]
			self.con = con
			MovAny:UnlockPoint(con)
			con:ClearAllPoints()
			con:SetPoint("CENTER", self, "CENTER", 0, 0)
			MovAny:LockPoint(con)
		end,
		OnMAPreReset = function(self)
			if self.con then
				MovAny:UnlockPoint(self.con)
				self.con:SetPoint("TOPLEFT", "CompactRaidFrameManagerContainerResizeFrame", "TOPLEFT", 4, - 7)
				self.con = nil
			end
		end,
		OnMADetach = function()
			CompactRaidFrameManager_SetSetting("Locked", "lock", "MASkip")
		end,
		OnMAAttach = function()
			if CompactRaidFrameManager_GetSetting("Locked") == "lock" then
				CompactRaidFrameManager_SetSetting("Locked", "unlock", "MASkip")
				CompactRaidFrameManager_LockContainer(CompactRaidFrameManager)
			end
		end,
		OnMAAlpha = function(self, alpha)
			if self.con then
				if alpha > 0.999 then
					for i = 1, GetNumGroupMembers(), 1 do
						local bg = _G["CompactRaidFrame"..i]
						if bg then
							bg:EnableDrawLayer("BACKGROUND")
							bg:EnableDrawLayer("BORDER")
						end
					end
				else
					for i = 1, GetNumGroupMembers(), 1 do
						local bg = _G["CompactRaidFrame"..i]
						if bg then
							bg:DisableDrawLayer("BACKGROUND")
							bg:DisableDrawLayer("BORDER")
						end
					end
				end

				if self.con.groupMode == "discrete" then
					if alpha > 0.999 then
						for i = 1, 8, 1 do
							for j = 1, 5, 1 do
								local bg = _G["CompactRaidGroup"..i.."Member"..j]
								if bg then
									bg:EnableDrawLayer("BACKGROUND")
									bg:EnableDrawLayer("BORDER")
								end
							end
						end
					else
						for i = 1, 8, 1 do
							for j = 1, 5, 1 do
								local bg = _G["CompactRaidGroup"..i.."Member"..j]
								if bg then
									bg:DisableDrawLayer("BACKGROUND")
									bg:DisableDrawLayer("BORDER")
								end
							end
						end
					end
				end
			end
		end
	},
	CompactRaidFrameBuffTooltipsMover = {
		w = 100,
		h = 100,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHide = function(self, hidden)
			if hidden then
				for i = 1, 40 do
					for k = 1, 3 do
						if _G["CompactRaidFrame"..i.."Buff"..k] then
							_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", function()
								GameTooltip:Hide()
							end)
						end
						if _G["CompactRaidFrame"..i.."Debuff"..k] then
							_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", function()
								GameTooltip:Hide()
							end)
						end
					end
				end
			else
				for i = 1, 40 do
					for k = 1, 3 do
						if _G["CompactRaidFrame"..i.."Buff"..k] then
							_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", nil)
						end
						if _G["CompactRaidFrame"..i.."Debuff"..k] then
							_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", nil)
						end
					end
				end
			end
		end,
		OnMAPostReset = function(self)
			for i = 1, 40 do
				for k = 1, 3 do
					if _G["CompactRaidFrame"..i.."Buff"..k] then
						_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", nil)
					end
					if _G["CompactRaidFrame"..i.."Debuff"..k] then
						_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", nil)
					end
				end
			end
		end
	},
	CompactRaidFrameDebuffTooltipsMover = {
		w = 100,
		h = 100,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHide = function(self, hidden)
			if hidden then
				for i = 1, 40 do
					for k = 1, 3 do
						if _G["CompactRaidFrame"..i.."Buff"..k] then
							_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", function()
								GameTooltip:Hide()
							end)
						end
						if _G["CompactRaidFrame"..i.."Debuff"..k] then
							_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", function()
								GameTooltip:Hide()
							end)
						end
					end
				end
			else
				for i = 1, 40 do
					for k = 1, 3 do
						if _G["CompactRaidFrame"..i.."Buff"..k] then
							_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", nil)
						end
						if _G["CompactRaidFrame"..i.."Debuff"..k] then
							_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", nil)
						end
					end
				end
			end
		end,
		OnMAPostReset = function(self)
			for i = 1, 40 do
				for k = 1, 3 do
					if _G["CompactRaidFrame"..i.."Buff"..k] then
						_G["CompactRaidFrame"..i.."Buff"..k]:SetScript("OnEnter", nil)
					end
					if _G["CompactRaidFrame"..i.."Debuff"..k] then
						_G["CompactRaidFrame"..i.."Debuff"..k]:SetScript("OnEnter", nil)
					end
				end
			end
		end
	},
	--[[RaidUnitFramesManagerMover = {
		linkedSize = "CompactRaidFrameManager",
		point = {"TOPLEFT", "UIParent", "TOPLEFT", - 7, - 140},
		children = {"CompactRaidFrameManager"},
		dontLock = true,
		OnLoad = function(self)
			local b = CreateFrame("Button", "MACompactRaidFrameManagerToggleButton", UIParent, nil, "MADontHook")
			b:SetSize(16, 64)
			b:SetNormalTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
			if GetNumGroupMembers() < 1 then
				b:Hide()
			end
			local tex = b:GetNormalTexture()
			tex:SetDrawLayer("OVERLAY")
			tex:SetTexCoord(0, .5, 0, 1)
			tex:SetSize(self:GetSize())
			b:SetScript("OnMouseDown", function(self)
				local tex = self:GetNormalTexture()
				tex:ClearAllPoints()
				tex:SetSize(self:GetSize())
				tex:SetPoint("CENTER", 1, 0)
			end)
			b:SetScript("OnMouseUp", function(self)
				self:GetNormalTexture():SetAllPoints()
			end)
			b:SetScript("OnClick", function()
				CompactRaidFrameManager_Expand(CompactRaidFrameManager)
			end)
			local man = _G["CompactRaidFrameManager"]
			local p = {"TOPLEFT", "UIParent", "TOPLEFT", - 5, - 225}
			b:SetPoint(unpack(p))
			local e = MovAny.API:GetElement(b:GetName())
			if e:IsModified() then
				e:Sync()
			end
			self.button = b
			hooksecurefunc("CompactRaidFrameManager_Expand", function(man)
				if not self.MAHooked then
					return
				end
				if not InCombatLockdown() then
					return
				end
				MovAny:UnlockPoint(man)
				man:ClearAllPoints()
				man:SetPoint("CENTER", self, "CENTER", 0, 0)
				MovAny:LockPoint(man)
				b:Hide()
			end)
			hooksecurefunc("CompactRaidFrameManager_Collapse", function(man)
				if not self.MAHooked then
					return
				end
				if not InCombatLockdown() then
					return
				end
				MovAny:UnlockPoint(man)
				man:ClearAllPoints()
				man:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", 0, 0)
				MovAny:LockPoint(man)
				if GetNumGroupMembers() > 0 then
					b:Show()
				end
			end)
		end,
		OnMAHook = function(self)
			local man = _G["CompactRaidFrameManager"]
			self.man = man
			if not self.opt or not self.opt.hidden then
				if man.collapsed then
					MovAny:UnlockPoint(man)
					man:ClearAllPoints()
					man:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", 0, 0)
					MovAny:LockPoint(man)
					if GetNumGroupMembers() > 0 then
						self.button:Show()
					end
				else
					MovAny:UnlockPoint(man)
					man:ClearAllPoints()
					man:SetPoint("CENTER", self, "CENTER", 0, 0)
					MovAny:LockPoint(man)
					self.button:Hide()
				end
			end
		end,
		OnMAPreReset = function(self)
			local e = MovAny.API:GetElement(self:GetName())
			if InCombatLockdown() then
				return
			end
			MovAny.Position:Reset(e, self.man, true)
			self.button:Hide()
			self.man = nil
		end
	},]]
	BagsMover = {
		w = 100,
		h = 100,
		point = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 84},
		prefix = "ContainerFrame",
		count = 13,
		dontLock = true,
		dontScale = true,
		dontAlpha = true,
		OnMAFoundChild = function(self, index, child)
			if MovAny:IsModified(MovAny.lTransContainerToBag[child:GetName()]) then
				return
			end
			--child:SetParent(self)
			MovAny:UnlockScale(child)
			child:SetScale(1)
			MovAny:LockScale(child)
		end,
		OnMAReleaseChild = function(self, index, child)
			child:SetParent(UIParent)
			MovAny:UnlockScale(child)
		end,
		OnMAPosition = MovAny.hUpdateContainerFrameAnchors,
		OnMAScale = MovAny.hUpdateContainerFrameAnchors,
		OnMAPreReset = function(self, readOnly)
			if not readOnly then
				if self.attachedChildren then
					table.wipe(self.attachedChildren)
				end
				self:MAScanForChildren()
			end
		end,
		OnMAPostReset = function(self)
			--if not readOnly then
				UpdateContainerFrameAnchors()
			--end
		end
	},
	ChatEditBoxesMover = {
		w = 440,
		h = 32,
		point = {"TOPLEFT", "ChatFrame1", "BOTTOMLEFT", - 5, - 2},
		excludes = "ChatEditBoxesLengthMover",
		prefix = "ChatFrame",
		postfix = "EditBox",
		count = 10,
		dontLock = true,
		OnMAHook = function(self)
			self:SetWidth(ChatFrame1:GetWidth() + 10)
			--self:SetHeight(32)
			local b = ChatFrame1EditBox
			b:SetPoint("LEFT", self, "LEFT", 0, 0)
			--b:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		end,
		OnMAFoundChild = function(self, index, child)
			--MovAny.Position:StoreOrgPoints(child, child)
			--child.MAOrgParent = child:GetParent()
			--child:SetParent(self)
			MovAny:UnlockPoint(child)
			child:ClearAllPoints()
			child:SetPoint("LEFT", self, "LEFT", 0, 0)
			child:SetWidth(ChatFrame1:GetWidth() + 10)
			--child:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
			--MovAny:LockPoint(child)
		end,
		OnMAReleaseChild = function(self, index, child)
			--child:SetParent(child.MAOrgParent)
			--child.MAOrgParent = nil
			--MovAny:UnlockPoint(child)
			--child:ClearAllPoints()
			--child:SetPoint("TOPLEFT", "ChatFrame"..index, "BOTTOMLEFT", - 5, - 2)
			--MovAny.Position:RestoreOrgPoints(child, child, true)
		end,
		OnMAScale = function(self, scale)
			for i = 1, 10 do
				_G["ChatFrame"..i.."EditBox"]:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			for i = 1, 10 do
				MovAny:UnlockPoint(_G["ChatFrame"..i.."EditBox"])
				_G["ChatFrame"..i.."EditBox"]:ClearAllPoints()
				_G["ChatFrame"..i.."EditBox"]:SetPoint("TOPLEFT", "ChatFrame"..i, "BOTTOMLEFT", - 5, - 2)
				_G["ChatFrame"..i.."EditBox"]:SetWidth(ChatFrame1:GetWidth() + 10)
			end
		end
	},
	ChatEditBoxesLengthMover = {
		w = 440,
		h = 32,
		point = {"TOPLEFT", "ChatFrame1", "BOTTOMLEFT", - 5, - 2},
		excludes = "ChatEditBoxesMover",
		prefix = "ChatFrame",
		postfix = "EditBox",
		count = 10,
		dontLock = true,
		OnMAHook = function(self)
			self:SetWidth(ChatFrame1:GetWidth() + 10)
			--self:SetHeight(32)
			local b = ChatFrame1EditBox
			b:SetPoint("LEFT", self, "LEFT", 0, 0)
			--b:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		end,
		OnMAFoundChild = function(self, index, child)
			--MovAny.Position:StoreOrgPoints(child, child)
			--child.MAOrgParent = child:GetParent()
			--child:SetParent(self)
			MovAny:UnlockPoint(child)
			child:ClearAllPoints()
			child:SetPoint("LEFT", self, "LEFT", 0, 0)
			child:SetWidth(ChatFrame1:GetWidth() + 10)
			--child:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
			--MovAny:LockPoint(child)
		end,
		OnMAReleaseChild = function(self, index, child)
			--child:SetParent(child.MAOrgParent)
			--child.MAOrgParent = nil
			--MovAny:UnlockPoint(child)
			--child:ClearAllPoints()
			--child:SetPoint("TOPLEFT", "ChatFrame"..index, "BOTTOMLEFT", - 5, - 2)
			--MovAny.Position:RestoreOrgPoints(child, child, true)
		end,
		OnMAScale = function(self, scale)
			for i = 1, 10 do
				local b = _G["ChatFrame"..i.."EditBox"]
				local scaleS = self:GetScale()
				--local scaleH = self:GetHeight()
				local scaleW = self:GetWidth()
				if scaleW * scaleS < 64 then
					scaleW = 64
				end
				--b:SetHeight(scaleH)
				b:SetWidth(scaleW)
			end
		end,
		OnMAPostReset = function(self)
			for i = 1, 10 do
				MovAny:UnlockPoint(_G["ChatFrame"..i.."EditBox"])
				_G["ChatFrame"..i.."EditBox"]:ClearAllPoints()
				_G["ChatFrame"..i.."EditBox"]:SetPoint("TOPLEFT", "ChatFrame"..i, "BOTTOMLEFT", - 5, - 2)
				_G["ChatFrame"..i.."EditBox"]:SetWidth(ChatFrame1:GetWidth() + 10)
			end
		end
	},
	LootWonAlertMover1 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[1] then
				local b = LOOT_WON_ALERT_FRAMES[1]
				MovAny:UnlockPoint(LOOT_WON_ALERT_FRAMES[1])
				LOOT_WON_ALERT_FRAMES[1]:ClearAllPoints()
				LOOT_WON_ALERT_FRAMES[1]:SetPoint("BOTTOMLEFT", "LootWonAlertMover1", "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(LOOT_WON_ALERT_FRAMES[1])
				LOOT_WON_ALERT_FRAMES[1].ignoreFramePositionManager = true
				LOOT_WON_ALERT_FRAMES[1]:SetMovable(true)
				LOOT_WON_ALERT_FRAMES[1]:SetUserPlaced(true)
				self.sbf = LOOT_WON_ALERT_FRAMES[1]
			else
				LOOT_WON_ALERT_FRAMES[1] = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				local b = LOOT_WON_ALERT_FRAMES[1]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover1, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[1])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[1])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[1]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover2 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[2] then
				local b = LOOT_WON_ALERT_FRAMES[2]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover2, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[2] = frame
				local b = LOOT_WON_ALERT_FRAMES[2]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover2, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[2])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[2])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[2]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover3 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[3] then
				local b = LOOT_WON_ALERT_FRAMES[3]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover3, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[3] = frame
				local b = LOOT_WON_ALERT_FRAMES[3]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover3, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[3])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[3])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[3]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover4 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[4] then
				local b = LOOT_WON_ALERT_FRAMES[4]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover4, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[4] = frame
				local b = LOOT_WON_ALERT_FRAMES[4]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover4, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[4]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[4])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[4])
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover5 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[5] then
				local b = LOOT_WON_ALERT_FRAMES[5]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover5, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[5] = frame
				local b = LOOT_WON_ALERT_FRAMES[5]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover5, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[5])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[5])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[5]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover6 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[6] then
				local b = LOOT_WON_ALERT_FRAMES[6]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover6, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[6] = frame
				local b = LOOT_WON_ALERT_FRAMES[6]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover6, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[6])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[6])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[6]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover7 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[7] then
				local b = LOOT_WON_ALERT_FRAMES[7]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover7, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[7] = frame
				local b = LOOT_WON_ALERT_FRAMES[7]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover7, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[7])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[7])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[7]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover8 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[8] then
				local b = LOOT_WON_ALERT_FRAMES[8]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover8, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[8] = frame
				local b = LOOT_WON_ALERT_FRAMES[8]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover8, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[8])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[8])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[8]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover9 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[9] then
				local b = LOOT_WON_ALERT_FRAMES[9]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover9, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[9] = frame
				local b = LOOT_WON_ALERT_FRAMES[9]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover9, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[9])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[9])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[9]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	LootWonAlertMover10 = {
		w = 276,
		h = 96,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if LOOT_WON_ALERT_FRAMES[10] then
				local b = LOOT_WON_ALERT_FRAMES[10]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover10, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "LootWonAlertFrameTemplate")
				LOOT_WON_ALERT_FRAMES[10] = frame
				local b = LOOT_WON_ALERT_FRAMES[10]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", LootWonAlertMover10, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(LOOT_WON_ALERT_FRAMES[10])
			else
				MovAny:UnlockVisibility(LOOT_WON_ALERT_FRAMES[10])
			end
		end,
		OnMAScale = function(self, scale)
			local b = LOOT_WON_ALERT_FRAMES[10]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(LOOT_WON_ALERT_FRAMES)
		end
	},
	MoneyWonAlertMover1 = {
		w = 249,
		h = 71,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if MONEY_WON_ALERT_FRAMES[1] then
				local b = MONEY_WON_ALERT_FRAMES[1]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover1, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate")
				MONEY_WON_ALERT_FRAMES[1] = frame
				local b = MONEY_WON_ALERT_FRAMES[1]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover1, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MONEY_WON_ALERT_FRAMES[1])
			else
				MovAny:UnlockVisibility(MONEY_WON_ALERT_FRAMES[1])
			end
		end,
		OnMAScale = function(self, scale)
			local b = MONEY_WON_ALERT_FRAMES[1]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(MONEY_WON_ALERT_FRAMES)
		end
	},
	MoneyWonAlertMover2 = {
		w = 249,
		h = 71,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if MONEY_WON_ALERT_FRAMES[2] then
				local b = MONEY_WON_ALERT_FRAMES[2]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover2, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate")
				MONEY_WON_ALERT_FRAMES[2] = frame
				local b = MONEY_WON_ALERT_FRAMES[2]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover2, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MONEY_WON_ALERT_FRAMES[2])
			else
				MovAny:UnlockVisibility(MONEY_WON_ALERT_FRAMES[2])
			end
		end,
		OnMAScale = function(self, scale)
			local b = MONEY_WON_ALERT_FRAMES[2]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(MONEY_WON_ALERT_FRAMES)
		end
	},
	MoneyWonAlertMover3 = {
		w = 249,
		h = 71,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if MONEY_WON_ALERT_FRAMES[3] then
				local b = MONEY_WON_ALERT_FRAMES[3]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover3, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate")
				MONEY_WON_ALERT_FRAMES[3] = frame
				local b = MONEY_WON_ALERT_FRAMES[3]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover3, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MONEY_WON_ALERT_FRAMES[3])
			else
				MovAny:UnlockVisibility(MONEY_WON_ALERT_FRAMES[3])
			end
		end,
		OnMAScale = function(self, scale)
			local b = MONEY_WON_ALERT_FRAMES[3]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(MONEY_WON_ALERT_FRAMES)
		end
	},
	MoneyWonAlertMover4 = {
		w = 249,
		h = 71,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if MONEY_WON_ALERT_FRAMES[4] then
				local b = MONEY_WON_ALERT_FRAMES[4]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover4, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate")
				MONEY_WON_ALERT_FRAMES[4] = frame
				local b = MONEY_WON_ALERT_FRAMES[4]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover4, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MONEY_WON_ALERT_FRAMES[4])
			else
				MovAny:UnlockVisibility(MONEY_WON_ALERT_FRAMES[4])
			end
		end,
		OnMAScale = function(self, scale)
			local b = MONEY_WON_ALERT_FRAMES[4]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(MONEY_WON_ALERT_FRAMES)
		end
	},
	MoneyWonAlertMover5 = {
		w = 249,
		h = 71,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			if MONEY_WON_ALERT_FRAMES[5] then
				local b = MONEY_WON_ALERT_FRAMES[5]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover5, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			else
				local frame = CreateFrame("Button", nil, UIParent, "MoneyWonAlertFrameTemplate")
				MONEY_WON_ALERT_FRAMES[5] = frame
				local b = MONEY_WON_ALERT_FRAMES[5]
				MovAny:UnlockPoint(b)
				b:ClearAllPoints()
				b:SetPoint("BOTTOMLEFT", MoneyWonAlertMover5, "BOTTOMLEFT", 0, 0)
				MovAny:LockPoint(b)
				--b.ignoreFramePositionManager = true
				b:SetMovable(true)
				b:SetUserPlaced(true)
				self.sbf = b
			end
		end,
		OnMAHide = function(self, hidden)
			if hidden then
				MovAny:LockVisibility(MONEY_WON_ALERT_FRAMES[5])
			else
				MovAny:UnlockVisibility(MONEY_WON_ALERT_FRAMES[5])
			end
		end,
		OnMAScale = function(self, scale)
			local b = MONEY_WON_ALERT_FRAMES[5]
			if type(scale) ~= "number" then
				return
			end
			if b then
				b:SetScale(scale)
			end
		end,
		OnMAPostReset = function(self)
			wipe(MONEY_WON_ALERT_FRAMES)
		end
	},
	--[[GroupLootFrameMover1 = {
		w = 270,
		h = 80,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			local b = _G["GroupLootFrame1"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", GroupLootFrameMover1, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			local b = _G["GroupLootFrame1"]
			if type(scale) ~= "number" then
				return
			end
			b:SetScale(scale)
		end
	},
	GroupLootFrameMover2 = {
		w = 270,
		h = 80,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			local b = _G["GroupLootFrame2"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", GroupLootFrameMover2, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			local b = _G["GroupLootFrame2"]
			if type(scale) ~= "number" then
				return
			end
			b:SetScale(scale)
		end
	},
	GroupLootFrameMover3 = {
		w = 270,
		h = 80,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			local b = _G["GroupLootFrame3"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", GroupLootFrameMover3, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			local b = _G["GroupLootFrame3"]
			if type(scale) ~= "number" then
				return
			end
			b:SetScale(scale)
		end
	},
	GroupLootFrameMover4 = {
		w = 270,
		h = 80,
		point = {"CENTER", "UIParent", "CENTER", 0, 0},
		OnMAHook = function(self)
			local b = _G["GroupLootFrame4"]
			MovAny:UnlockPoint(b)
			b:ClearAllPoints()
			b:SetPoint("BOTTOMLEFT", GroupLootFrameMover4, "BOTTOMLEFT", 0, 0)
			MovAny:LockPoint(b)
			b.ignoreFramePositionManager = true
			b:SetMovable(true)
			b:SetUserPlaced(true)
			self.sbf = b
		end,
		OnMAScale = function(self, scale)
			local b = _G["GroupLootFrame4"]
			if type(scale) ~= "number" then
				return
			end
			b:SetScale(scale)
		end
	}]]
}
