local E = select(2, ...):unpack()
local P = E.Party

local BarFrameIconMixin = P.BarFrameIconMixin

local MIN_RESET_DURATION = ((E.isWOTLKC or E.isCata) or E.TocVersion > 90100) and 120 or 180

function BarFrameIconMixin:ResetCooldown(resetAllCharges)
	local info = P.groupInfo[self.guid]
	if not info then
		return
	end

	local spellID = self.spellID
	local active = info.active[spellID]
	if not active then
		return
	end


	if (spellID == 45438 or spellID == 414658) and E.db.icons.showForbearanceCounter then
		local duration, expTime = P:GetDebuffDuration(info.unit, 41425)
		if ( duration and duration > 0 ) then
			duration = expTime - GetTime()
			if duration > 0 then
				self:StartCooldown(duration, nil, true)
			end
			return
		end
	end


	local maxcharges = self.maxcharges
	local currCharges = active.charges
	local statusBar = self.statusBar
	if maxcharges and currCharges and currCharges + 1 < maxcharges then
		if resetAllCharges then
			active.charges = maxcharges
			self.cooldown:Clear()
			if statusBar then
				statusBar.CastingBar:OnEvent('UNIT_SPELLCAST_FAILED')
			end
			return
		end

		currCharges = currCharges + 1
		active.charges = currCharges
		self.count:SetText(currCharges)
		self.active = currCharges
		self:SetCooldownElements(currCharges, info)

		local castingBar = statusBar and not E.db.extraBars[statusBar.key].nameBar and currCharges == 1 and statusBar.castingBar
		if castingBar then
			local rechargeColor, rechargeBGColor, rechargeTextColor = castingBar:GetEffectiveStartColor(castingBar.channeling)
			castingBar:SetStatusBarColor(rechargeColor:GetRGBA())
			castingBar.BG:SetVertexColor(rechargeBGColor:GetRGBA())
			castingBar.Text:SetTextColor(rechargeTextColor:GetRGB())
		end
	else
		self.cooldown:Clear()
		if statusBar then
			statusBar.CastingBar:OnEvent('UNIT_SPELLCAST_FAILED')
		end
	end
end

function BarFrameIconMixin:UpdateCooldown(reducedTime, updateActiveTimer)
	local info = P.groupInfo[self.guid]
	if not info then
		return
	end

	local active = info.active[self.spellID]
	if not active then
		return
	end

	local startTime = active.startTime
	local duration = active.duration
	local modRate = active.modRate or 1
	local now = GetTime()






	reducedTime = reducedTime * modRate






	if updateActiveTimer then
		local elapsed = (now - startTime) * updateActiveTimer
		startTime = now - elapsed
		duration = duration * updateActiveTimer

	end

	startTime = startTime - reducedTime

	if active.charges then
		local queuedCdrOnRecharge = now - startTime - duration
		if queuedCdrOnRecharge > 0 and active.charges + 1 < self.maxcharges then
			active.queuedCdrOnRecharge = queuedCdrOnRecharge
		end
	end

	self.cooldown:SetCooldown(startTime, duration, modRate)
	active.startTime = startTime
	active.duration = duration
	local statusBar = self.statusBar
	if statusBar then
		statusBar.CastingBar:OnEvent(statusBar.CastingBar.channeling and 'UNIT_SPELLCAST_CHANNEL_UPDATE' or 'UNIT_SPELLCAST_CAST_UPDATE')
	end
end

function BarFrameIconMixin:SetCooldownElements(charges, info)
	local noSwipe = self.isHighlighted or (self.statusBar and not E.db.extraBars[self.statusBar.key].nameBar) or (charges and charges > 0)
	local noCount = noSwipe or not E.db.icons.showCounter
	self.cooldown:SetDrawEdge(not self.isHighlighted and charges and true)
	self.cooldown:SetDrawSwipe(not noSwipe)
	self.cooldown:SetHideCountdownNumbers(noCount)
	if E.OmniCC then
		E.OmniCC.Cooldown.SetNoCooldownCount(self.cooldown, noCount)
	elseif self.cooldown.timer then
		self.cooldown.timer:SetShown(not noCount)
		self.cooldown.timer.forceDisabled = noCount
	end

	if info and self.glowBorder then
		local condition = E.db.highlight.glowBorderCondition
		self.Glow:SetShown(not info.isDeadOrOffline and (condition==3 or (condition==1 and self.active~=0) or (condition==2 and self.active==0)))
	end
end

function BarFrameIconMixin:StartCooldown(cd, isRecharge, noGlow)
	local info = P.groupInfo[self.guid]
	if not info then
		return
	end

	local spellID = self.spellID



	local multiplier
	local auraMult = E.spell_cdmod_by_aura_mult[spellID]
	if auraMult then
		for i = 1, #auraMult, 2 do
			local auraString = auraMult[i + 1]
			if info.auras[auraString] then
				local mult = auraMult[i]
				if mult == 0 and not isRecharge then
					if self.active and info.auras.premonitionOfInsight then
						self:UpdateCooldown(info.talentData[440743] and 9.8 or 7)
					end
					return
				end
				multiplier = (multiplier or 1) * mult
			end
		end
	end

	local ocd = cd


	local reduceStartTimeInstead
	if not isRecharge and self.isBookType then
		if info.auras.glimpseOfClarity then
			cd = cd - 3
		end
		if spellID ~= 428933 and info.auras.premonitionOfInsight then
			reduceStartTimeInstead = true
			cd = cd - (info.talentData[440743] and 9.8 or 7)
		end
	end

	if multiplier then
		cd = cd * multiplier
	end

	local modRate = self.modRate
	cd = cd * modRate

	info.active[spellID] = info.active[spellID] or {}
	local active = info.active[spellID]
	local currCharges = active.charges or self.maxcharges
	local now = GetTime()









	if currCharges then
		if isRecharge then
			if active.queuedCdrOnRecharge then
				now = now - active.queuedCdrOnRecharge
				active.queuedCdrOnRecharge = nil
			end
			currCharges = currCharges + 1
			self.cooldown:SetCooldown(now, cd, modRate)
		elseif currCharges == self.maxcharges then
			currCharges = currCharges - 1
			if reduceStartTimeInstead then
				now = now - (ocd - cd)
				cd = ocd * modRate
			end
			self.cooldown:SetCooldown(now, cd, modRate)
		elseif currCharges == 0 then
			self.cooldown:SetCooldown(now, cd, modRate)
		else
			if reduceStartTimeInstead then
				local rt = active.duration - cd
				local remainingTime = active.startTime + active.duration - now - rt
				if remainingTime < 0 then
					now = now + remainingTime
				else
					currCharges = currCharges - 1
					now = active.startTime - rt
				end
				cd = active.duration
				self.cooldown:SetCooldown(now, cd, modRate)
			else
				currCharges = currCharges - 1
				now = active.startTime
				cd = active.duration
			end
		end
		self.count:SetText(currCharges)
		active.charges = currCharges
	else
		if reduceStartTimeInstead then
			now = now - (ocd - cd)
			cd = ocd * modRate
		end
		self.cooldown:SetCooldown(now, cd, modRate)
	end

	active.startTime = now
	active.duration = cd
	active.modRate = modRate

	if E.selfLimitedMinMaxReducer[spellID] then
		active.numHits = 0
	end

	self.active = currCharges or 0

	local frame = self:GetParent():GetParent()
	local key = frame.key
	if type(key) == "number" then
		if not P.displayInactive then
			frame:UpdateLayout()
		end
	else
		if frame.shouldRearrangeInterrupts then
			frame:UpdateLayout(true)
		end
	end

	local statusBar = self.statusBar
	if info.preactiveIcons[spellID] then
		info.preactiveIcons[spellID] = nil

		if statusBar then
			statusBar:SetColors()
		end


		if not info.isDeadOrOffline and not E.forbearanceIDs[spellID] then
			self.icon:SetVertexColor(1, 1, 1)
		end
	end

	if not statusBar or E.db.extraBars[key].useIconAlpha then
		self:SetAlpha(self.active == 0 and E.db.icons.activeAlpha or E.db.icons.inactiveAlpha)
	end
	if not self:SetHighlight() then
		if not isRecharge and not noGlow and E.db.highlight.glow then
			self:SetGlow()
		end

		self:SetCooldownElements(currCharges, info)
		if not info.isDeadOrOffline then
			self.icon:SetDesaturated(E.db.icons.desaturateActive and self.active == 0)
		end
	end
	if statusBar then
		statusBar.CastingBar:OnEvent(E.db.extraBars[key].reverseFill and 'UNIT_SPELLCAST_CHANNEL_START' or 'UNIT_SPELLCAST_START')
	end

	if E.isBFA and self.guid == E.userGUID and P.isInPvPInstance and spellID == info.talentData["essStrivedPvpID"] then
		C_Timer.After(2, function() E.Comm.SendStrivePvpTalentCD(spellID) end)
	end
end

function P:ResetAllIcons(reason, clearSession)
	local notEncounterEnd = reason ~= "encounterEnd"
	for guid, info in pairs(self.groupInfo) do
		for spellID, icon in pairs(info.spellIcons) do
			if notEncounterEnd or (not E.spell_noreset_onencounterend[spellID] and icon.baseCooldown >= MIN_RESET_DURATION) then
				local statusBar = icon.statusBar
				if icon.active then
					info.active[spellID] = nil
					icon.active = nil
					icon.cooldown:Clear()
					local maxcharges = icon.maxcharges
					if maxcharges then
						icon.count:SetText(maxcharges)
					end
					if statusBar then
						statusBar.CastingBar:OnEvent('UNIT_SPELLCAST_FAILED')
					end
				end

				if info.preactiveIcons[spellID] then
					info.preactiveIcons[spellID] = nil
					if statusBar then
						statusBar:SetColors()
					end
				end

				if not statusBar or E.db.extraBars[statusBar.key].useIconAlpha then
					icon:SetAlpha(E.db.icons.inactiveAlpha)
				end
				if not info.isDeadOrOffline then
					icon.icon:SetVertexColor(1, 1, 1)
					icon.icon:SetDesaturated(false)
				end
				if icon.isHighlighted then
					icon:RemoveHighlight()
				end
				if icon.glowBorder then
					icon.Glow:SetShown(not info.isDeadOrOffline and E.db.highlight.glowBorderCondition ~= 2)
				end

				if reason == "joinedPvP" and (spellID == 323436 or spellID == 6262) then
					info.auras.healthStoneStacks = nil
					info.auras.purifySoulStacks = nil
					icon.count:SetText("")
				end
			end
		end

		for k, timer in pairs(info.callbackTimers) do
			if type(timer) == "userdata" and (notEncounterEnd or k ~= "inCombatTicker") then
				timer:Cancel()
			end
			info.callbackTimers[k] = nil
		end

		if clearSession then
			wipe(info.sessionItemData)
			self:UpdateUnitBar(guid)
		elseif not self.displayInactive then
			info.bar:UpdateLayout()
		end
	end

	if not clearSession then
		for _, frame in pairs(self.extraBars) do
			if frame.shouldRearrangeInterrupts then
				frame:UpdateLayout(true)
			end
		end
	end
end
