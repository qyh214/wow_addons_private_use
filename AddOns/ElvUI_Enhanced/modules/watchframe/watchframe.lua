local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local WF = E:NewModule('WatchFrame', 'AceEvent-3.0')

-- Based on WatchFrameHider by Sortokk

local watchFrame

local statedriver = {
	['NONE'] = function(frame) 
		ObjectiveTrackerFrame.userCollapsed = false
		ObjectiveTracker_Expand(watchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	['COLLAPSED'] = function(frame)
		ObjectiveTrackerFrame.userCollapsed = true
		ObjectiveTracker_Collapse(watchFrame)
		ObjectiveTrackerFrame:Show()
	end,
	['HIDDEN'] = function(frame)
		ObjectiveTrackerFrame:Hide()
	end,
}

function WF:ChangeState(event)
	if UnitAffectingCombat("player") then self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState") return end
	
	if IsResting() then
		statedriver[E.db.watchframe.city](watchFrame)
	else
		local instance, instanceType = IsInInstance()
		if instanceType == 'pvp' then
			statedriver[E.db.watchframe.pvp](watchFrame)
		elseif instanceType == 'arena' then
			statedriver[E.db.watchframe.arena](watchFrame)
		elseif instanceType == 'party' then
			statedriver[E.db.watchframe.party](watchFrame)
		elseif instanceType == 'raid' then
			statedriver[E.db.watchframe.raid](watchFrame)
		else
			statedriver['NONE'](watchFrame)
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function WF:UpdateSettings()
	if E.private.watchframe.enable then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "ChangeState")
		self:RegisterEvent("PLAYER_UPDATE_RESTING", "ChangeState")
	else
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_UPDATE_RESTING")
	end
end

function WF:Initialize()
	watchFrame = _G["WatchFrame"]
	WF:UpdateSettings()
end

E:RegisterModule(WF:GetName())

