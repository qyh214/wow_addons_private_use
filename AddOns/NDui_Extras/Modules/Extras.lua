local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:RegisterModule("Extras")

local EX_LIST = {}

function EX:RegisterExtra(name, func)
	if not EX_LIST[name] then
		EX_LIST[name] = func
	end
end

function EX:OnLogin()
	for name, func in pairs(EX_LIST) do
		if name and type(func) == "function" then
			func()
		end
	end

	self:ActionBarGlow()
	self:DisableCPUStats()
	self:DisableGuildFilter()
	self:InstanceAutoMarke()
	self:InstanceDifficulty()
	self:InstanceReset()
	self:MDEnhance()

	-- 不需要的功能直接注释掉
	self:AutoConfirm() -- 自动确认出售可交易物品提示
	--self:AutoHideName() -- 自动隐藏名字，防止卡屏
end

-- 自动隐藏名字，防止卡屏
function EX:AutoHideName()
	SetCVar("UnitNameEnemyMinionName", 0)
	SetCVar("UnitNameEnemyPetName", 0)
	SetCVar("UnitNameEnemyPlayerName", 0)
	SetCVar("UnitNameEnemyTotemName", 0)
	SetCVar("UnitNameFriendlyMinionName", 0)
	SetCVar("UnitNameFriendlyPetName", 0)
	SetCVar("UnitNameFriendlyPlayerName", 0)
	SetCVar("UnitNameFriendlyTotemName", 0)
end

-- 禁用插件列表CPU统计，防止卡屏
function EX:DisableCPUStats()
	C_CVar.RegisterCVar("addonProfilerEnabled", "1")
	C_CVar.SetCVar("addonProfilerEnabled", "0")
end

-- 禁用公会过滤，防止卡屏
function EX:DisableGuildFilter()
	for i=1, 9 do
		SetGuildNewsFilter(i, 0)
	end
end

-- 副本重置自动喊话
function EX.UpdateInstanceReset(_, msg)
	if not IsInInstance() then
		if string.find(msg, "难度") or string.find(msg, "重置") then
			if not IsInGroup() then
				UIErrorsFrame:AddMessage(DB.InfoColor..msg)
			else
				SendChatMessage(msg, B.GetMSGChannel())
			end
		end
	end
end

function EX:InstanceReset()
	B:RegisterEvent("CHAT_MSG_SYSTEM", self.UpdateInstanceReset)
end

-- 副本难度自动喊话
function EX.UpdateInstanceDifficulty()
	C_Timer.After(1, function()
		if IsInInstance() then
			local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()
			if instanceType == "party" then
				if difficultyID == 8 then
					difficultyName = difficultyName.."-"..C_ChallengeMode.GetActiveKeystoneInfo()
				end
				if not IsInGroup() then
					UIErrorsFrame:AddMessage(format(DB.InfoColor..L["Instance Difficulty"], difficultyName))
				else
					SendChatMessage(format(L["Instance Difficulty"], difficultyName), B.GetMSGChannel())
				end
			end
		end
	end)
end

function EX:InstanceDifficulty()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", EX.UpdateInstanceDifficulty)
end

-- 进本自动标记坦克和治疗
function EX.UpdateInstanceAutoMarke()
	if IsInInstance() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
		for i = 1, 5 do
			local unit = (i == 5 and "player") or ("party"..i)
			local role = UnitGroupRolesAssigned(unit)
			if role == "TANK" then
				SetRaidTarget(unit, 6)
			elseif role == "HEALER" then
				SetRaidTarget(unit, 5)
			end
		end
	end
end

function EX:InstanceAutoMarke()
	B:RegisterEvent("UPDATE_INSTANCE_INFO", self.UpdateInstanceAutoMarke)
end

-- 自动确认出售可交易物品提示
function EX.UpdateAutoConfirm()
	hooksecurefunc("StaticPopup_Show", function(name, ...)
		if name == "CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL" then
			StaticPopup1Button1:Click() -- 自动点击“确定”按钮
		end
	end)
end

function EX:AutoConfirm()
	B:RegisterEvent("MERCHANT_SHOW", EX.UpdateAutoConfirm)
end

-- 宏界面扩展和修复
do
	local AddSelectHeight = 100
	local AddTextHeight = 100
	local tempScrollPer = nil
	local function Init()
		hooksecurefunc(MacroFrame, "SelectMacro", function(self, index)
			if tempScrollPer then
				MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(tempScrollPer)
				tempScrollPer = nil
			end
		end)
		MacroFrame.MacroSelector:SetHeight(146 + AddSelectHeight)
		MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -210 - AddSelectHeight)
		MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -218 - AddSelectHeight)
		MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -289 - AddSelectHeight)
		local h = MacroFrame:GetHeight()
		MacroFrame:SetHeight(h + AddTextHeight + AddSelectHeight)
		MacroFrameScrollFrame:SetHeight(85 + AddTextHeight)
		MacroFrameText:SetHeight(85 + AddTextHeight)
		MacroFrameTextButton:SetHeight(85 + AddTextHeight)
		MacroFrameTextBackground:SetHeight(95 + AddTextHeight)
	end

	if MacroFrame then
		Init()
	else
		local f = CreateFrame("Frame")
		f:SetScript("OnEvent", function(self, evnet, addon)
			if evnet == "ADDON_LOADED" then
				if addon == "Blizzard_MacroUI" then
					Init()
					f:UnregisterEvent("ADDON_LOADED")
				end
			elseif MacroFrame then
				tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
			end
		end)
		f:RegisterEvent("ADDON_LOADED")
		f:RegisterEvent("UPDATE_MACROS")
	end
end
