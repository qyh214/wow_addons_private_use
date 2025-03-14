local E = select(2, ...):unpack()
local P, CM, CD = E.Party, E.Comm, E.Cooldowns

local AuraUtil_ForEachAura = E.isDF and AuraUtil and AuraUtil.ForEachAura

local spell_enabled = {}

function P:Enable()
	if self.enabled then
		return
	end
	self.enabled = true

	if not E.isDF then
		self:RegisterEvent('CVAR_UPDATE')
	end
	self:RegisterEvent('UI_SCALE_CHANGED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	self:RegisterEvent('GROUP_ROSTER_UPDATE')
	self:RegisterEvent('GROUP_JOINED')
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	if InCombatLockdown() then
		self:PLAYER_REGEN_DISABLED()
	end
	CM:InspectUser()
	self:SetHooks()
	self:CreateExtraBarFrames()

	self:Refresh()
end

function P:Disable()
	if not self.enabled then
		return
	end
	self.enabled = false
	self.disabledZone = true

	if self.isInTestMode then
		self:Test()
	end
	self:UnregisterAllEvents()
	self:UnhookAll()
	self:ResetModule(true)
end

function P:ResetModule(isModuleDisabled)
	self.disabled = true
	self.joinedNewGroup = false

	if not isModuleDisabled then
		self:UnregisterZoneEvents()
		self:UpdateZoneHooks(true)
	end

	for _, timer in pairs(self.callbackTimers) do
		timer:Cancel()
	end
	self.callbackTimers = {}

	CM:Disable()
	CD:Disable()

	for guid, info in pairs(self.groupInfo) do
		for _, timer in pairs(info.callbackTimers) do
			if type(timer) == "userdata" then
				timer:Cancel()
			end
		end
		self.groupInfo[guid] = nil
	end
	wipe(self.userInfo.sessionItemData)

	self:ReleaseAll()

	E.Libs.CBH:Fire("OnShutdown")
end

function P:ReleaseAll()
	self:ReleaseBars()
	self:ReleaseExBars()
end

function P:HideAll()
	self:HideBars()
	self:HideExBars()
end

function P:Refresh()
	if not self.enabled then
		return
	end
	self:UpdateStatusBarTextures()
	self:UpateStatusBarTimerFormat()
	self:PLAYER_ENTERING_WORLD(nil, nil, true)
end

function P:UpdateEnabledSpells()
	wipe(spell_enabled)

	for id, v in pairs(E.hash_spelldb) do
		local sId = tostring(id)
		if E.db.spells[sId] then
			local index = E.db.spellFrame[id] or E.db.frame[v.type]
			if index and index > 0 then
				local db = E.db.extraBars["raidBar" .. index]
				if db.enabled then
					spell_enabled[id] = index
				elseif db.redirect then
					spell_enabled[id] = 0
				end
			else
				spell_enabled[id] = 0
			end
		end
	end
end

local BASE_ICON_HEIGHT = 36

function P:UpdatePositionValues()

	local db = E.db.position
	local pixelMult = E.db.general.showRange and not db.detached and self.effectivePixelMult or E.PixelMult

	local size = BASE_ICON_HEIGHT * E.db.icons.scale
	self.iconScale = (size - size % pixelMult) / BASE_ICON_HEIGHT

	local pixel = pixelMult / self.iconScale
	self.pixel = pixel

	local growLeft = strfind(db.anchor, "RIGHT")
	local growX = growLeft and -1 or 1
	local growRowsUpward = db.growUpward
	local growY = growRowsUpward and 1 or -1

	self.point = db.anchor
	self.relativePoint = db.attach
	self.anchorPoint = growLeft and "BOTTOMLEFT" or "BOTTOMRIGHT"
	self.containerOfsX = db.offsetX * growX * pixel
	self.containerOfsY = -(db.offsetY * pixel)
	self.columns = db.columns
	self.multiline = db.layout ~= "vertical" and db.layout ~= "horizontal"
	self.tripleline = db.layout == "tripleRow" or db.layout == "tripleColumn"
	self.sortBy = db.sortBy
	self.breakPoint = self.sortBy == 2 and E.db.priority[db.breakPoint] or db.breakPoint3
	self.breakPoint2 = self.sortBy == 2 and E.db.priority[db.breakPoint2] or db.breakPoint4
	self.displayInactive = db.displayInactive
	self.maxNumIcons = db.maxNumIcons == 0 and 100 or db.maxNumIcons

	if db.layout == "horizontal" or db.layout == "doubleRow" or db.layout == "tripleRow" then
		self.ofsX = 0
		self.ofsY = growY * (BASE_ICON_HEIGHT + db.paddingY * pixel)
		self.ofsY2 = 0
		if growLeft then
			self.point2 = "TOPRIGHT"
			self.relativePoint2 = "TOPLEFT"
			self.ofsX2 = -(db.paddingX * pixel)
		else
			self.point2 = "TOPLEFT"
			self.relativePoint2 = "TOPRIGHT"
			self.ofsX2 = db.paddingX * pixel
		end
	else
		self.ofsX = growX * (BASE_ICON_HEIGHT + db.paddingX * pixel)
		self.ofsY = 0
		self.ofsX2 = 0
		if growRowsUpward then
			self.point2 = "BOTTOMRIGHT"
			self.relativePoint2 = "TOPRIGHT"
			self.ofsY2 = db.paddingY * pixel
		else
			self.point2 = "TOPRIGHT"
			self.relativePoint2 = "BOTTOMRIGHT"
			self.ofsY2 = -(db.paddingY * pixel)
		end
	end
end

if AuraUtil_ForEachAura then
	function P:GetBuffDuration(unit, spellID)
		local dur, expTime
		AuraUtil_ForEachAura(unit, "HELPFUL", nil, function(_,_,_,_, duration, expirationTime, _,_,_, id)
			if id == spellID then
				dur, expTime = duration, expirationTime
				return true
			end
		end)
		return dur, expTime
	end

	function P:GetDebuffDuration(unit, spellID)
		local dur, expTime
		AuraUtil_ForEachAura(unit, "HARMFUL", nil, function(_,_,_,_, duration, expirationTime, _,_,_, id)
			if id == spellID then
				dur, expTime = duration, expirationTime
				return true
			end
		end)
		return dur, expTime
	end
else

	function P:GetBuffDuration(unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expirationTime, _,_,_, id = UnitBuff(unit, i)
			if not id then return end

			if id == spellID then
				return duration, expirationTime
			end
		end
	end

	function P:GetDebuffDuration(unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expirationTime,_,_,_, id = UnitDebuff(unit, i)
			if not id then return end
			if id == spellID then
				return duration, expirationTime
			end
		end
	end
end

function P:GetEffectiveNumGroupMembers()
	local size = GetNumGroupMembers()
	return size == 0 and self.isInTestMode and 1 or size
end

function P:GetValueByType(v, spec)
	if v then
		if type(v) == "table" then
			return v[spec] or v.default
		else
			return v
		end
	end
end

function P:IsTalentForPvpStatus(talentID, info)
	if not talentID then
		return true
	end
	local talent = info.talentData[talentID]
	if talent == "PVP" then
		return self.isPvP and 1
	end
	return talent
end


local specIDs = { [71]=true,[72]=true,[73]=true,[65]=true,[66]=true,[70]=true,[253]=true,[254]=true,[255]=true,[259]=true,[260]=true,[261]=true,[256]=true,[257]=true,[258]=true,[250]=true,[251]=true,[252]=true,[262]=true,[263]=true,[264]=true,[62]=true,[63]=true,[64]=true,[265]=true,[266]=true,[267]=true,[268]=true,[269]=true,[270]=true,[102]=true,[103]=true,[104]=true,[105]=true,[577]=true,[581]=true,[1467]=true,[1468]=true,[1473]=true }
local covenantIDs = { [321076]=true,[321079]=true,[321077]=true,[321078]=true, }


function P:IsSpecAndTalentForPvpStatus(talentID, info)
	if not talentID then
		return true
	end

	if type(talentID) == "table" then
		local talentRank
		for _, id in ipairs(talentID) do
			local talent = P:IsSpecAndTalentForPvpStatus(id, info)
			if not talent then return end
			talentRank = talent
		end
		return talentRank
	else
		if specIDs[talentID] then
			return info.spec == talentID
		end
		if covenantIDs[talentID] and not self.isInShadowlands then
			return
		end
		local talent = info.talentData[talentID]
		if talent == "PVP" then
			return self.isPvP and 1
		end
		return talent
	end
end

function P:IsSpecOrTalentForPvpStatus(talentID, info, isLearnedLevel)
	if not talentID then
		return isLearnedLevel
	end
	if type(talentID) == "table" then
		for _, id in ipairs(talentID) do
			local talent = P:IsSpecOrTalentForPvpStatus(id, info, isLearnedLevel)
			if talent then return talent end
		end
	else
		if specIDs[talentID] then
			return isLearnedLevel and info.spec == talentID
		end
		if covenantIDs[talentID] and not self.isInShadowlands then
			return
		end
		local talent = info.talentData[talentID]
		if talent == "PVP" then
			return self.isPvP and 1
		end
		return talent
	end
end

function P:IsEquipped(info, item, item2)
	if not item then
		return true
	end
	return info.itemData[item] or info.itemData[item2]
end


function P:UI_SCALE_CHANGED()
	E:SetPixelMult()
	if self.disabled then
		return
	end
	self:ConfigSize()
	for key in pairs(self.extraBars) do
		self:ConfigExSize(key)
	end
end

function P:PLAYER_REGEN_ENABLED()
	self.inLockdown = false
	self:UpdatePassThroughButtons()
end

function P:PLAYER_REGEN_DISABLED()
	self.inLockdown = true
	if self.callbackTimers.arenaTicker then
		self.callbackTimers.arenaTicker:Cancel()
		self.callbackTimers.arenaTicker = nil
	end
end

P.spell_enabled = spell_enabled
E.BASE_ICON_HEIGHT = BASE_ICON_HEIGHT
