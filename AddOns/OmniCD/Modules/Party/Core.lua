local E = select(2, ...):unpack()
local P, CM, CD = E.Party, E.Comm, E.Cooldowns

P.spell_enabled = {}

function P:Enable()
	if self.enabled then
		return
	end

	if not E.isDF then
		self:RegisterEvent('CVAR_UPDATE')
	end
	self:RegisterEvent('UI_SCALE_CHANGED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('GROUP_ROSTER_UPDATE')
	self:RegisterEvent('GROUP_JOINED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	self.enabled = true

	self.zone = select(2, IsInInstance())
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

	if self.isInTestMode then
		self:Test()
	end
	self.disabledZone = true
	self:UnregisterAllEvents()
	self:ResetModule(true)

	self.enabled = false
end

function P:HideAllBars()
	self:HideBars()
	self:HideExBars()
end

function P:ResetModule(isModuleDisabled)
	if not isModuleDisabled then
		self:UnregisterZoneEvents()
	end

	for _, timer in pairs(self.callbackTimers) do
		timer:Cancel()
	end
	self.callbackTimers = {}

	CM:Disable()
	CD:Disable()

	wipe(self.groupInfo)
	wipe(self.userInfo.sessionItemData)

	self.disabled = true
	self:HideAllBars()

	E.Libs.CBH:Fire("OnShutdown")
end

function P:Refresh(full)
	if not self.enabled then
		return
	end

	local zone = self.isInTestMode and self.testZone or self.zone
	zone = zone == "none" and E.profile.Party.noneZoneSetting or (zone == "scenario" and E.profile.Party.scenarioZoneSetting) or zone
	E.db = E.profile.Party[zone]
	self.db = E.db
	for key, frame in pairs(self.extraBars) do
		frame.db = E.db.extraBars[key]
	end

	self:UpdateTextures()
	self:UpateTimerFormat()
	self:PLAYER_ENTERING_WORLD(nil, nil, true)
end

function P:UpdateTextures()
	local texture = E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.bar)
	self:ConfigTextures()

	for i = 1, #self.unusedStatusBars do
		local statusBar = self.unusedStatusBars[i]
		statusBar.BG:SetTexture(texture)
		statusBar.CastingBar:SetStatusBarTexture(texture)
		statusBar.CastingBar.BG:SetTexture(E.Libs.LSM:Fetch("statusbar", E.profile.General.textures.statusBar.BG))
	end
end

function P:UpateTimerFormat()
	local db = E.profile.General.cooldownText.statusBar
	self.mmss = db.mmss
	self.ss = db.ss
	self.mmssColor = db.mmssColor
	self.ssColor = db.ssColor
end

function P:UpdateEnabledSpells()
	wipe(self.spell_enabled)

	for id, v in pairs(E.hash_spelldb) do
		local sId = tostring(id)
		if self.db.spells[sId] then
			local index = self.db.spellFrame[id] or self.db.frame[v.type]
			if index and index > 0 then
				local db = E.db.extraBars["raidBar" .. index]
				if db.enabled then
					self.spell_enabled[id] = index
				elseif db.redirect then
					self.spell_enabled[id] = 0
				end
			else
				self.spell_enabled[id] = 0
			end
		end
	end
end

function P:UpdatePositionValues()
	local db = E.db.position
	local pixel = (E.db.general.showRange and not db.detached and self.effectivePixelMult or E.PixelMult) / E.db.icons.scale
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
		self.ofsY = growY * (E.baseIconHeight + db.paddingY * pixel)
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
		self.ofsX = growX * (E.baseIconHeight + db.paddingX  * pixel)
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




if AuraUtil and AuraUtil.ForEachAura then
	P.GetBuffDuration = function(_, unit, spellID)
		local remainingTime
		AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(_,_,_,_, duration, expTime, _,_,_, id)
			if id == spellID then
				if duration > 0 then
					remainingTime = expTime - GetTime()
					remainingTime = remainingTime > 0 and remainingTime
				end
				return true
			end
		end)
		return remainingTime
	end

	P.IsDebuffActive = function(_, unit, spellID)
		local isActive
		AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(_,_,_,_,_,_,_,_,_, id)
			if id == spellID then
				isActive = true
				return true
			end
		end)
		return isActive
	end

	P.GetDebuffDuration = function(_, unit, spellID)
		local remainingTime
		AuraUtil.ForEachAura(unit, "HARMFUL", nil, function(_,_,_,_, duration, expTime, _,_,_, id)
			if id == spellID then
				if duration > 0 then
					remainingTime = expTime - GetTime()
					remainingTime = remainingTime > 0 and remainingTime
				end
				return true
			end
		end)
		return remainingTime
	end
else
	local UnitBuff = UnitBuff
	local UnitDebuff = UnitDebuff

	P.GetBuffDuration = E.isClassic and function(_, unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expTime, _,_,_, id = UnitBuff(unit, i)
			if not id then return end
			id = E.spell_merged[id] or id
			if id == spellID then
				if duration > 0 then
					local remainingTime = expTime - GetTime()
					return remainingTime > 0 and remainingTime
				end
				return
			end
		end
	end or function(_, unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expTime, _,_,_, id = UnitBuff(unit, i)
			if not id then return end
			if id == spellID then
				if duration > 0 then
					local remainingTime = expTime - GetTime()
					return remainingTime > 0 and remainingTime
				end
				return
			end
		end
	end

	P.IsDebuffActive = function(_, unit, spellID)
		for i = 1, 50 do
			local _,_,_,_,_,_,_,_,_, id = UnitDebuff(unit, i)
			if not id then return end
			if id == spellID then
				return true
			end
		end
	end

	P.GetDebuffDuration = function(_, unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expTime,_,_,_, id = UnitDebuff(unit, i)
			if not id then return end
			if id == spellID then
				if duration > 0 then
					local remainingTime = expTime - GetTime()
					return remainingTime > 0 and remainingTime
				end
				return
			end
		end
	end
end

function P:GetEffectiveNumGroupMembers()
	local size = GetNumGroupMembers()
	return size == 0 and self.isInTestMode and 1 or size
end

function P:GetValueByType(v, guid, item2)
	if v then
		if type(v) == "table" then
			if item2 then
				return self.groupInfo[guid].itemData[item2] and v[item2] or v.default
			end
			local info = self.groupInfo[guid]
			return v[info.spec] or v.default
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


local specIDs = { [71]=true,[72]=true,[73]=true,[65]=true,[66]=true,[70]=true,[253]=true,[254]=true,[255]=true,[259]=true,[260]=true,[261]=true,[256]=true,[257]=true,[258]=true,[250]=true,[251]=true,[252]=true,[262]=true,[263]=true,[264]=true,[62]=true,[63]=true,[64]=true,[265]=true,[266]=true,[267]=true,[268]=true,[269]=true,[270]=true,[102]=true,[103]=true,[104]=true,[105]=true,[577]=true,[581]=true,[1467]=true,[1468]=true, }
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

function P:IsSpecOrTalentForPvpStatus(talentID, info, isLearnedLevel, talentDisabledSpec)
	if not talentID then
		return isLearnedLevel
	end
	if type(talentID) == "table" then
		for _, id in ipairs(talentID) do
			local talent = P:IsSpecOrTalentForPvpStatus(id, info, isLearnedLevel, talentDisabledSpec)
			if talent then return talent end
		end
	else
		if specIDs[talentID] then
			return isLearnedLevel and info.spec == talentID
		end
		if talentDisabledSpec and talentDisabledSpec[self.zone] then
			return
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
	self:ConfigSize()
	for key in pairs(self.extraBars) do
		self:ConfigExSize(key)
	end
end
