local E = select(2, ...):unpack()
local P = E.Party

local MIN_RESET_DURATION = ((E.isWOTLKC or E.isCata) or E.TocVersion > 90100) and 120 or 180

function P:ResetCooldown(icon, resetAllCharges)
	local info = self.groupInfo[icon.guid]
	if not info then
		return
	end

	local spellID = icon.spellID
	local active = info.active[spellID]
	if not active then
		return
	end


	if (spellID == 45438 or spellID == 414658) and E.db.icons.showForbearanceCounter then
		local duration, expTime = self:GetDebuffDuration(info.unit, 41425)
		if ( duration and duration > 0 ) then
			duration = expTime - GetTime()
			if duration > 0 then
				self:StartCooldown(icon, duration, nil, true)
			end
			return
		end
	end


	local maxcharges = icon.maxcharges
	local currCharges = active.charges
	local statusBar = icon.statusBar
	if maxcharges and currCharges and currCharges + 1 < maxcharges then
		if resetAllCharges then
			active.charges = maxcharges
			icon.cooldown:Clear()
			if statusBar then
				self.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_FAILED')
			end
			return
		end
		currCharges = currCharges + 1
		icon.count:SetText(currCharges)
		active.charges = currCharges
		icon.active = currCharges
		P:SetCooldownElements(info, icon, currCharges)

		local castingBar = statusBar and not E.db.extraBars[statusBar.key].nameBar and currCharges == 1 and statusBar.castingBar
		if castingBar then
			local rechargeColor, rechargeBGColor, rechargeTextColor = self.CastingBarFrame_GetEffectiveStartColor(castingBar, true)
			castingBar:SetStatusBarColor(rechargeColor:GetRGBA())
			castingBar.BG:SetVertexColor(rechargeBGColor:GetRGBA())
			castingBar.Text:SetTextColor(rechargeTextColor:GetRGB())
		end
	else
		icon.cooldown:Clear()
		if statusBar then
			self.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_FAILED')
		end
	end
end

function P:UpdateCooldown(icon, reducedTime, updateActiveTimer)
	local info = self.groupInfo[icon.guid]
	if not info then
		return
	end

	local active = info.active[icon.spellID]
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
		if queuedCdrOnRecharge > 0 and active.charges + 1 < icon.maxcharges then
			active.queuedCdrOnRecharge = queuedCdrOnRecharge
		end
	end

	icon.cooldown:SetCooldown(startTime, duration, modRate)
	active.startTime = startTime
	active.duration = duration
	local statusBar = icon.statusBar
	if statusBar then
		self.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, E.db.extraBars[statusBar.key].reverseFill and 'UNIT_SPELLCAST_CHANNEL_UPDATE' or 'UNIT_SPELLCAST_CAST_UPDATE')
	end
end

function P:SetCooldownElements(info, icon, charges)
	local noSwipe = icon.isHighlighted or (icon.statusBar and not E.db.extraBars[icon.statusBar.key].nameBar) or (charges and charges > 0)
	local noCount = noSwipe or not E.db.icons.showCounter
	icon.cooldown:SetDrawEdge(not icon.isHighlighted and charges and true)
	icon.cooldown:SetDrawSwipe(not noSwipe)
	icon.cooldown:SetHideCountdownNumbers(noCount)
	if E.OmniCC then
		E.OmniCC.Cooldown.SetNoCooldownCount(icon.cooldown, noCount)
	elseif icon.cooldown.timer then
		icon.cooldown.timer:SetShown(not noCount)
		icon.cooldown.timer.forceDisabled = noCount
	end

	if info and icon.glowBorder then
		local condition = E.db.highlight.glowBorderCondition
		icon.Glow:SetShown(not info.isDeadOrOffline and (condition==3 or (condition==1 and icon.active~=0) or (condition==2 and icon.active==0)))
	end
end

function P:StartCooldown(icon, cd, isRecharge, noGlow)
	local info = self.groupInfo[icon.guid]
	if not info then
		return
	end

	local spellID = icon.spellID
	local multiplier
	local auraMult = E.spell_cdmod_by_aura_mult[spellID]
	if auraMult then
		for i = 1, #auraMult, 2 do
			local auraString = auraMult[i + 1]
			if info.auras[auraString] then
				local mult = auraMult[i]
				if mult == 0 and not isRecharge then

					if icon.active and info.auras.premonitionOfInsight then
						self:UpdateCooldown(icon, info.talentData[440743] and 9.8 or 7)
					end
					return
				end

				multiplier = (multiplier or 1) * mult
			end
		end
	end

	local ocd = cd


	local isInsight
	if not isRecharge and icon.isBookType then
		if info.auras.glimpseOfClarity then
			cd = cd - 3
		end
		if spellID ~= 428933 and info.auras.premonitionOfInsight then
			isInsight = true
			cd = cd - (info.talentData[440743] and 9.8 or 7)
		end
	end


	if multiplier then
		cd = cd * multiplier
	end


	local modRate = icon.modRate
	cd = cd * modRate


	info.active[spellID] = info.active[spellID] or {}
	local active = info.active[spellID]
	local currCharges = active.charges or icon.maxcharges
	local now = GetTime()










	if currCharges then
		if isRecharge then
			local queuedCdr = active.queuedCdrOnRecharge
			if queuedCdr then
				now = now - queuedCdr
				active.queuedCdrOnRecharge = nil
			end
			currCharges = currCharges + 1
			icon.cooldown:SetCooldown(now, cd, modRate)
		elseif currCharges == icon.maxcharges then
			currCharges = currCharges - 1
			if isInsight then
				now = now - (ocd - cd)
				cd = ocd * modRate
			end
			icon.cooldown:SetCooldown(now, cd, modRate)
		elseif currCharges == 0 then

			icon.cooldown:SetCooldown(now, cd, modRate)
		else
			if isInsight then
				local rt = active.duration - cd
				local remainingTime = active.startTime + active.duration - now - rt
				if remainingTime < 0 then
					now = now + remainingTime
				else
					currCharges = currCharges - 1
					now = active.startTime - rt
				end
				cd = active.duration
				icon.cooldown:SetCooldown(now, cd, modRate)
			else
				currCharges = currCharges - 1
				now = active.startTime
				cd = active.duration
			end
		end
		icon.count:SetText(currCharges)
		active.charges = currCharges
	else
		if isInsight then
			now = now - (ocd - cd)
			cd = ocd * modRate
		end
		icon.cooldown:SetCooldown(now, cd, modRate)
	end

	active.startTime = now
	active.duration = cd
	active.modRate = modRate

	if E.selfLimitedMinMaxReducer[spellID] then
		active.numHits = 0
	end

	icon.active = currCharges or 0

	local frame = icon:GetParent():GetParent()
	local key = frame.key
	if type(key) == "number" then
		icon:SetAlpha(icon.active == 0 and E.db.icons.activeAlpha or E.db.icons.inactiveAlpha)
		if not self.displayInactive then
			self:SetIconLayout(frame)
		end
	else
		local statusBar = icon.statusBar
		if statusBar then
			self:SetExStatusBarColor(icon, statusBar.key)
			self.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, E.db.extraBars[key].reverseFill and 'UNIT_SPELLCAST_CHANNEL_START' or 'UNIT_SPELLCAST_START')
			if E.db.extraBars[key].useIconAlpha then
				icon:SetAlpha(icon.active == 0 and E.db.icons.activeAlpha or E.db.icons.inactiveAlpha)
			end
		else
			icon:SetAlpha(icon.active == 0 and E.db.icons.activeAlpha or E.db.icons.inactiveAlpha)
		end
		if frame.shouldRearrangeInterrupts then
			self:SetExIconLayout(key, true)
		end
	end

	if not self:HighlightIcon(icon) then
		if not isRecharge and not noGlow and E.db.highlight.glow then
			self:SetGlow(icon)
		end
		self:SetCooldownElements(info, icon, currCharges)
		if not info.isDeadOrOffline then
			icon.icon:SetDesaturated(E.db.icons.desaturateActive and (not currCharges or currCharges == 0))
		end
	end

	if E.isBFA and icon.guid == E.userGUID and self.isInPvPInstance and spellID == info.talentData["essStrivedPvpID"] then
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

					local maxcharges = icon.maxcharges
					if maxcharges then
						icon.count:SetText(maxcharges)
					end
					if not info.isDeadOrOffline then
						icon.icon:SetDesaturated(false)
					end

					icon.cooldown:Clear()
					if statusBar then
						icon:SetAlpha(E.db.extraBars[statusBar.key].useIconAlpha and E.db.icons.inactiveAlpha or 1.0)
						self.OmniCDCastingBarFrame_OnEvent(statusBar.CastingBar, 'UNIT_SPELLCAST_FAILED')
					else
						icon:SetAlpha(E.db.icons.inactiveAlpha)
					end
				elseif info.preactiveIcons[spellID] then
					info.preactiveIcons[spellID] = nil
					if statusBar then
						self:SetExStatusBarColor(icon, statusBar.key)
					end
					icon.icon:SetVertexColor(1, 1, 1)
				end

				if icon.isHighlighted then
					self:RemoveHighlight(icon)
				end

				if reason == "joinedPvP" and (spellID == 323436 or spellID == 6262) then
					info.auras.healthStoneStacks = nil
					info.auras.purifySoulStacks = nil
					icon.count:SetText("")
				end

				if icon.glowBorder then
					icon.Glow:SetShown(not info.isDeadOrOffline and E.db.highlight.glowBorderCondition ~= 2)
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
			self:SetIconLayout(info.bar)
		end
	end

	if not clearSession then
		for key, frame in pairs(self.extraBars) do
			if frame.shouldRearrangeInterrupts then
				self:SetExIconLayout(key, true)
			end
		end
	end
end
