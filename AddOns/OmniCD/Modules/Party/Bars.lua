local E = select(2, ...):unpack()
local P, CM = E.Party, E.Comm

local pairs, type, sort, tinsert, tremove, wipe, floor, min, max = pairs, type, sort, tinsert, tremove, wipe, floor, min, max
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local GetSpellLevelLearned = C_Spell and C_Spell.GetSpellLevelLearned or GetSpellLevelLearned
if E.spell_requiredLevel then
	GetSpellLevelLearned = function(id) return not P.isInTestMode and E.spell_requiredLevel[id] or 0 end
elseif E.preMoP then
	GetSpellLevelLearned = function() return 0 end
end

local FEIGN_DEATH = 5384
local TOUCH_OF_KARMA = 125174

local activeBars = {}
local inactiveBars = {}
local inactiveUnitBars = {}
local numActiveBars = 0

local BarFrameMixin = {}

function BarFrameMixin:Release()
	self:Hide()
	inactiveBars[#inactiveBars + 1] = self
	activeBars[self] = nil
	numActiveBars = numActiveBars - 1

	self:ReleaseIcons()
	self:ReleaseUnitBars()
	self:ReleaseExtraBarIcons()
	self:UnregisterAllEvents()

	if self.guid == E.userGUID then
		P.userInfo.bar = nil
	end
end

function BarFrameMixin:ReleaseIcons(n)
	n = n or 0
	for i = #self.icons, n + 1, -1 do
		local icon = self.icons[i]
		icon:Release()
		self.icons[i] = nil
	end
	self.numIcons = n
end

function BarFrameMixin:ReleaseUnitBars(raidBarIndex)
	if raidBarIndex then
		if self.activeUnitBars[raidBarIndex] then
			tinsert(inactiveUnitBars, self.activeUnitBars[raidBarIndex])
			wipe(self.activeUnitBars[raidBarIndex].icons)
			self.activeUnitBars[raidBarIndex] = nil
		end
	else
		for i, unitBar in pairs(self.activeUnitBars) do
			tinsert(inactiveUnitBars, unitBar)
			wipe(unitBar.icons)
			self.activeUnitBars[i] = nil
		end
	end
end

function BarFrameMixin:AcquireUnitBar(raidBarIndex)
	local frame = tremove(inactiveUnitBars)
	if not frame then
		frame = CreateFrame("Frame")
		frame:SetSize(1, 1)
		frame.icons = {}
	end
	self.activeUnitBars[raidBarIndex] = frame
	return frame
end

function BarFrameMixin:ReleaseExtraBarIcons()
	local guid = self.guid
	for _, frame in pairs(P.extraBars) do
		if frame.db and frame.db.enabled then
			local icons, n, shouldUpdateLayout = frame.icons, 0
			for j = frame.numIcons, 1, -1 do
				local icon = icons[j]
				local iconGUID = icon.guid
				if guid == iconGUID then
					icon:Release()
					tremove(icons, j)
					n = n + 1
					shouldUpdateLayout = true
				end
			end
			frame.numIcons = frame.numIcons - n
			if shouldUpdateLayout then
				frame:UpdateLayout()
			end
		end
	end
end

local sorters
sorters = {
	function(a, b)
		if a.priority == b.priority then
			return a.spellID < b.spellID
		end
		return a.priority > b.priority
	end,
	function(a, b)
		local type1, type2 = E.db.priority[a.type], E.db.priority[b.type]
		if type1 == type2 then
			return sorters[1](a, b)
		end
		return type1 > type2
	end,
}

function BarFrameMixin:UpdateLayout(sortOrder)
	local icons = self.icons
	local displayInactive = P.displayInactive

	local sorter = P.sortBy
	if sortOrder then
		local sortFunc = sorters[sorter]
		sort(icons, sortFunc)
	end

	local db_prio = E.db.priority
	local count, rows, numActive, lastActiveIndex = 0, 1, 1
	for i = 1, self.numIcons do
		local icon = icons[i]
		local iconPrio = sorter == 2 and db_prio[icon.type] or icon.priority
		icon:Hide()

		if (displayInactive or icon.active) and (P.multiline or numActive <= P.maxNumIcons) then
			icon:ClearAllPoints()
			if numActive > 1 then
				count = count + 1
				if not P.multiline and count == P.columns or
					(P.multiline and (rows == 1 and iconPrio <= P.breakPoint or (P.tripleline and rows == 2 and iconPrio <= P.breakPoint2))) then
					if P.tripleline and rows == 1 and iconPrio <= P.breakPoint2 then
						rows = rows + 1
					end
					icon:SetPoint(P.point, self.container, P.ofsX * rows, P.ofsY * rows)
					count = 0
					rows = rows + 1
				else
					icon:SetPoint(P.point2, icons[lastActiveIndex], P.relativePoint2, P.ofsX2, P.ofsY2)
				end
			else
				if P.multiline and iconPrio <= P.breakPoint then
					if P.tripleline and rows == 1 and iconPrio <= P.breakPoint2 then
						rows = rows + 1
					end
					icon:SetPoint(P.point, self.container, P.ofsX * rows, P.ofsY * rows)
					rows = rows + 1
				else
					icon:SetPoint(P.point, self.container)
				end
			end

			numActive = numActive + 1
			lastActiveIndex = i

			if not P.multiline or count < P.maxNumIcons then
				icon:Show()
			end
		end
	end
end

function BarFrameMixin:SetEffectivePixelMult()
	local relFrame = P:FindRelativeFrame(self.guid)
	if relFrame then
		P.effectivePixelMult = E.uiUnitFactor / relFrame:GetEffectiveScale()
		P:UpdatePositionValues()
	end
end

function BarFrameMixin:ApplySettings()
	self:SetAnchor()
	self:SetContainerSize()

	local isDeadOrOffline = P.groupInfo[self.guid].isDeadOrOffline
	local condition = E.db.highlight.glowBorderCondition

	local numIcons = self.numIcons
	for i = 1, numIcons do
		local icon = self.icons[i]
		icon:SetBorder()
		icon:SetMarker()
		icon:SetOpacity()
		icon:SetColorSaturation()
		icon:SetSwipeCounter()
		icon:SetChargeScale()
		icon:SetTooltip()
		if icon.glowBorder then
			icon.Glow:SetShown(not isDeadOrOffline and (condition==3 or (condition==1 and icon.active~=0) or (condition==2 and icon.active==0)))
		end
	end
end

function BarFrameMixin:SetAnchor(isHiddenUser)
	local showMovableAnchor = E.db.position.detached and not E.db.position.locked
	if showMovableAnchor or (E.db.general.showAnchor and not isHiddenUser) then
		self.anchor:Show()
	else
		self.anchor:Hide()
	end
	if showMovableAnchor then
		self.anchor:EnableMouse(true)
		self.anchor.background:SetColorTexture(0, 0.8, 0, 1)
	else
		self.anchor:EnableMouse(false)
		self.anchor.background:SetColorTexture(0.756, 0, 0.012, 0.7)
	end
end

function BarFrameMixin:SetContainerSize()
	local scale = P.iconScale
	self.anchor:SetScale(min(max(0.7, scale), 1))
	self.container:SetScale(scale)
end

function BarFrameMixin:SetBarBackdrop()
	local icons = self.icons
	for i = 1, self.numIcons do
		local icon = icons[i]
		icon:SetBorder()
	end
end

function BarFrameMixin:SetContainerOffset()
	self.container:ClearAllPoints()
	self.container:SetPoint("TOPLEFT", self, P.containerOfsX, P.containerOfsY)
end

function BarFrameMixin:SetAnchorPosition()
	self.anchor:ClearAllPoints()
	self.anchor:SetPoint(P.anchorPoint, self, P.point)
end





local UNIT_TO_PET = {
	["raid1"]="raidpet1", ["raid2"]="raidpet2", ["raid3"]="raidpet3", ["raid4"]="raidpet4", ["raid5"]="raidpet5",
	["raid6"]="raidpet6", ["raid7"]="raidpet7", ["raid8"]="raidpet8", ["raid9"]="raidpet9", ["raid10"]="raidpet10",
	["raid11"]="raidpet11", ["raid12"]="raidpet12", ["raid13"]="raidpet13", ["raid14"]="raidpet14", ["raid15"]="raidpet15",
	["raid16"]="raidpet16", ["raid17"]="raidpet17", ["raid18"]="raidpet18", ["raid19"]="raidpet19", ["raid20"]="raidpet20",
	["raid21"]="raidpet21", ["raid22"]="raidpet22", ["raid23"]="raidpet23", ["raid24"]="raidpet24", ["raid25"]="raidpet25",
	["raid26"]="raidpet26", ["raid27"]="raidpet27", ["raid28"]="raidpet28", ["raid29"]="raidpet29", ["raid30"]="raidpet30",
	["raid31"]="raidpet31", ["raid32"]="raidpet32", ["raid33"]="raidpet33", ["raid34"]="raidpet34", ["raid35"]="raidpet35",
	["raid36"]="raidpet36", ["raid37"]="raidpet37", ["raid38"]="raidpet38", ["raid39"]="raidpet39", ["raid40"]="raidpet40",
	["party1"]="partypet1", ["party2"]="partypet2", ["party3"]="partypet3", ["party4"]="partypet4", ["player"]="pet"
}

function P:SetEnabledColorScheme(info)
	if info.isDisabledColor then
		info.isDisabledColor = nil
		local desaturate = E.db.icons.desaturateActive
		local condition = E.db.highlight.glowBorderCondition
		for _, icon in pairs(info.spellIcons) do
			local statusBar = icon.statusBar
			if statusBar then
				statusBar:SetColors()
			end
			icon:SetColorSaturation()

			if icon.glowBorder then
				icon.Glow:SetShown(condition==3 or (condition==1 and icon.active~=0) or (condition==2 and icon.active==0))
			end
		end
		for _, frame in pairs(P.extraBars) do
			if frame.shouldRearrangeInterrupts then
				frame:UpdateLayout(true)
			end
		end
	end
end

local wwDamageSpells = {
	[100780] = true,
	[100784] = true,
	[107428] = true,
	[113656] = true,
	[152175] = true,
	[392983] = true,
	[322109] = true,
	[117952] = true,
	[101546] = true,
	[388193] = true,
}

local function CooldownBarFrame_OnEvent(self, event, ...)
	local guid = self.guid
	local info = P.groupInfo[guid]
	if not info then
		return
	end



	if event == 'UNIT_SPELLCAST_SUCCEEDED' then
		local unit, _, spellID = ...
		if unit ~= info.unit and unit ~= UNIT_TO_PET[info.unit] then
			return
		end


		if info.spec == 269 and wwDamageSpells[spellID] then
			if info.lastComboStrikesID and info.lastComboStrikesID ~= spellID then

				local icon = info.talentData[391330] and info.spellIcons[322109]
				if icon and icon.active then
					icon:UpdateCooldown(.6)
				end

				icon = info.talentData[392986] and info.spellIcons[123904]
				if icon and icon.active then
					icon:UpdateCooldown(info.auras.isSEF and .75 or .25)
				end
			end
			info.lastComboStrikesID = spellID
		end

		if P.spell_enabled[spellID] or E.spell_modifiers[spellID] then
			E.ProcessSpell(spellID, guid)
		elseif spellID == 384255
		or spellID == 63644 or spellID == 63645 then
			if guid ~= E.userGUID and not CM.syncedGroupMembers[guid] then
				CM:EnqueueInspect(nil, guid)
			end
		end
	elseif event == 'UNIT_HEALTH' then
		local unit = ...
		if unit ~= info.unit then
			return
		end







		if not UnitIsDeadOrGhost(unit) then
			if E.preMoP then
				local icon = info.spellIcons[20608]
				if icon then
					local mult = info.talentData[16184] and 0.3 or (info.talentData[16209] and 0.4) or 0.2
					if UnitHealth(unit) == floor(UnitHealthMax(unit) * mult) then
						icon:StartCooldown(icon.duration)
					end
				end
			else
				E.Libs.CBH:Fire("OnBattleRezed")
			end

			info.isDead = nil
			info.isDeadOrOffline = not UnitIsConnected(unit)
			if info.isDeadOrOffline then
				P:SetDisabledColorScheme(info)
			else
				P:SetEnabledColorScheme(info)
			end
			self:UnregisterEvent(event)
		end
	elseif event == 'UNIT_AURA' then
		local unit = ...
		if unit ~= info.unit then
			return
		end
		if info.glowIcons[TOUCH_OF_KARMA] then
			if not P:GetBuffDuration(unit, TOUCH_OF_KARMA) then
				local icon = info.glowIcons[TOUCH_OF_KARMA]
				if icon then
					icon:RemoveHighlight()
				end
				if E.isBFA and not P.isInArena then
					self:UnregisterEvent(event)
				end
				self:UnregisterEvent(event)
			end
		elseif info.preactiveIcons[FEIGN_DEATH] then
			if not P:GetBuffDuration(unit, FEIGN_DEATH) then
				local icon = info.preactiveIcons[FEIGN_DEATH]
				if icon then
					icon:RemoveHighlight()
					icon:StartCooldown(icon.duration)
				end
				if E.isBFA and not P.isInArena then
					self:UnregisterEvent(event)
				end
				self:UnregisterEvent(event)
			end
		elseif not E.isBFA or not P.isInArena then
			self:UnregisterEvent(event)
		end
	elseif event == 'PLAYER_SPECIALIZATION_CHANGED' then
		local unit = ...
		if unit ~= info.unit then
			return
		end
		if UnitIsConnected(unit) then
			CM:EnqueueInspect(nil, guid)
		end
	elseif event == 'UNIT_CONNECTION' then


		local unit, isConnected = ...
		if unit ~= info.unit then
			return
		end
		info.isDeadOrOffline = UnitIsDeadOrGhost(unit) or not isConnected
		if info.isDeadOrOffline then
			P:SetDisabledColorScheme(info)
		else
			P:SetEnabledColorScheme(info)
		end

		if isConnected and not info.spec then
			CM:EnqueueInspect(nil, guid)
		end
	elseif event == 'UNIT_SPELLCAST_CHANNEL_STOP' then
		local unit, _, spellID = ...
		if unit ~= info.unit then
			return
		end

		if spellID == 391528 then
			self:UnregisterEvent(event)
		end
		info.auras.isChannelingConvoke = nil
	end
end

local numBars = 0
local function AcquireBarFrame()
	local frame = tremove(inactiveBars)
	if not frame then
		numBars = numBars + 1
		frame = CreateFrame("Frame", "OmniCDBar" .. numBars, UIParent, "OmniCDTemplate")
		frame.icons = {}
		frame.numIcons = 0
		frame.activeUnitBars = {}
		frame.anchor:Hide()
		frame.anchor.text:SetFontObject(E.AnchorFont)
		frame.anchor:SetScript("OnMouseUp", E.OmniCDAnchor_OnMouseUp)
		frame.anchor:SetScript("OnMouseDown", E.OmniCDAnchor_OnMouseDown)
		frame:SetScript("OnEvent", CooldownBarFrame_OnEvent)
		Mixin(frame, BarFrameMixin)
	end
	activeBars[frame] = true
	numActiveBars = numActiveBars + 1
	return frame
end

local iconTextureFix = {
	[371032] = {403631,5199622,4622450},
}

local function GetOverrideTexture(info, iconFix)
	return info.talentData[ iconFix[1] ] and iconFix[2] or iconFix[3]
end

local function FindReducedTime(info, t, specID, rank, isMult)
	local pvpMult = P.isPvP and t.pvp
	if t[1] and t[1] > 999 then
		t = P:IsTalentForPvpStatus(t[1], info) and t[2] or t[3]
	end
	if type(t) == "table" then
		t = t[specID] or t[rank] or t[1]
		if not t then return end
		if pvpMult then
			t = (isMult and 1 - (1 - t) * pvpMult) or t * pvpMult
		end
	end
	return t
end

local twwHeroTalents = {
	[436358] = true,
	[439843] = true,
	[444347] = true,
	[443328] = true,
	[442726] = true,
	[428933] = true,
	[451235] = true,
	[432472] = true,
	[443454] = true,
	[444995] = true,
}

function P:UpdateUnitBar(guid, isUpdateBarsOrGRU)
	local info = self.groupInfo[guid]
	local class = info.class
	local raceID = info.raceID
	local index = info.index
	local unit = info.unit
	local name = info.name
	local notUser = guid ~= E.userGUID

	wipe(info.spellIcons)

	if not info.bar then
		info.bar = AcquireBarFrame()
	end
	local frame = info.bar
	frame.key = index
	frame.guid = guid
	frame.class = class
	frame.raceID = raceID
	frame.unit = unit
	frame.anchor.text:SetText(index)
	for _, f in pairs(P.extraBars) do
		if f.db.enabled and f.db.unitBar then
			local raidBarIndex = f.index
			local unitBar = frame.activeUnitBars[raidBarIndex]
			if unitBar then
				wipe(unitBar.icons)
			else
				frame.activeUnitBars[raidBarIndex] = frame:AcquireUnitBar(raidBarIndex)
			end
		end
	end

	frame:UnregisterAllEvents()

	if info.isAdminObsForMDI then
		frame:ReleaseIcons()
		return
	end


	if not E.preMoP and notUser then
		frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
	end
	if info.glowIcons[TOUCH_OF_KARMA] or info.preactiveIcons[FEIGN_DEATH] then
		frame:RegisterUnitEvent('UNIT_AURA', unit)
	end
	if info.isDead then
		frame:RegisterUnitEvent('UNIT_HEALTH', unit)
	end
	frame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', unit, UNIT_TO_PET[unit])
	frame:RegisterUnitEvent('UNIT_CONNECTION', unit)

	local specID = info.spec
	local lvl = info.level

	local loginsessionData = self.loginsessionData[guid]
	if not CM.syncedGroupMembers[guid] and not info.shadowlandsData.covenantID and specID and loginsessionData then
		for k, v in pairs(loginsessionData) do
			if k == "covenantID" then
				info.shadowlandsData.covenantID = v
			else
				info.talentData[k] = v
			end
		end
	end


	if E.isDF then
		local found
		AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(_,_,_,_,_,_, source, _,_, id)

			if id == 410318 then
				found = true
				info.itemData[205146] = true
			end

			local auraStr = E.auraMultString[id]
			if auraStr then
				info.auras[auraStr] = true
			end

		end)

		if not found and info.itemData[205146] then
			info.itemData[205146] = nil
		end
	end

	local iconIndex = 0
	for spellID, spell in pairs(E.hash_spelldb) do
		local cat, spellType, spec, race, item, talent, disabledSpec = spell.class, spell.type, spell.spec, spell.race, spell.item, spell.talent, spell.disabledSpec
		if not disabledSpec or not disabledSpec[specID] or not disabledSpec[specID][self.zone] then
			local isValidSpell
			local enabledSpell = self.spell_enabled[spellID]
			local extraBarKey, extraBarFrame
			if enabledSpell and enabledSpell > 0 then
				extraBarKey = "raidBar" .. enabledSpell
				extraBarFrame = E.db.extraBars[extraBarKey].enabled and self.extraBars[extraBarKey]
			end
			if enabledSpell and (notUser or not self.isUserHidden or (extraBarFrame and not extraBarFrame.db.unitBar)) then
				if cat == "RACIAL" then
					if type(race) == "table" then
						for k = 1, #race do
							local id = race[k]
							if id == raceID then
								isValidSpell = true
							end
						end
					elseif race == raceID then
						isValidSpell = true
					end
				elseif specID then
					if cat == class then
						isValidSpell = (not E.postBFA or not E.covenant_abilities[spellID] or self.isInShadowlands)
							and self:IsSpecOrTalentForPvpStatus(spec==true and spellID or spec, info, lvl >= GetSpellLevelLearned(spellID))
							and (not talent or not self:IsSpecOrTalentForPvpStatus(talent, info, true))
					elseif cat == "COVENANT" then
						isValidSpell = self.isInShadowlands and self:IsSpecOrTalentForPvpStatus(spec==true and spellID or spec, info, true)
					elseif cat == "ESSENCE" then
						isValidSpell = info.talentData[spec]
					elseif not E.BOOKTYPE_CATEGORY[cat] then
						isValidSpell = self:IsEquipped(info, item) or (info.sessionItemData[item] and (item ~= 5512 or not info.talentData[386689]))
					end
				else
					if cat == class then
						isValidSpell = lvl >= GetSpellLevelLearned(spellID) and (not spec or (loginsessionData and loginsessionData[spec])) and not talent
					elseif cat == "COVENANT" then
						isValidSpell = self.isInShadowlands and loginsessionData and loginsessionData[spec]
					elseif cat == "TRINKET" then
						isValidSpell = not item or info.sessionItemData[item]
					end
				end
			end

			if isValidSpell then
				local cd = self:GetValueByType(spell.duration, specID)
				if cd and (not E.preMoP or not self.isInArena or cd < 900) then
					local buffID, iconTexture = spell.buff, spell.icon
					local ch = self:GetValueByType(spell.charges, specID) or 1
					local baseCooldown = cd
					if specID then
						if cat == class then
							local modData = E.spell_cdmod_talents[spellID]
							if modData then
								for k = 1, #modData, 2 do
									local rank = self:IsTalentForPvpStatus(modData[k], info)
									if rank then
										local rt = modData[k+1]
										if type(rt) == "table" then
											rt = FindReducedTime(info, rt, specID, rank)
										end
										if rt then cd = cd - rt end
									end
								end
							end

							modData = E.spell_cxmod_azerite[spellID]
							if modData and info.talentData[modData.azerite] then
								if modData.duration then
									cd = cd - modData.duration
								elseif modData.charges then
									ch = ch + modData.charges
								end
							end

							modData = E.spell_cdmod_conduits[spellID]
							if modData and self.isInShadowlands then
								local rankValue = info.talentData[modData]
								if rankValue then
									if self.isPvP and modData == 336636 then
										rankValue = rankValue / 2
									end
									cd = cd - rankValue
								end
							end

							modData = E.spell_cdmod_by_haste[spellID]
							if modData == true or modData == specID then
								if E.preMoP then
									cd = cd + (info.rangedWeaponSpeed or 0)
								else
									local spellHasteMult = info.spellHasteMult or 1/(1 + UnitSpellHaste("player")/100)
									cd = cd * spellHasteMult
								end
							end

							modData = E.spell_cdmod_talents_mult[spellID]
							if modData then
								for k = 1, #modData, 2 do
									local rank = self:IsTalentForPvpStatus(modData[k], info)
									if rank then
										local mult = modData[k+1]
										if type(mult) == "table" then
											mult = FindReducedTime(info, mult, specID, rank, true)
										end
										if mult then cd = cd * mult end
									end
								end
							end

							modData = E.spell_cdmod_conduits_mult[spellID]
							if modData and self.isInShadowlands then
								local rankValue = info.talentData[modData]
								if rankValue then
									cd = cd * rankValue
								end
							end

							modData = info.talentData["essStriveMult"]
							if modData then
								local stiveSpec = E.spell_cdmod_ess_strive_mult[spellID]
								if stiveSpec == true or stiveSpec == specID then
									local pvpCD = self.isPvP and self.loginsessionData[guid] and self.loginsessionData[guid]["strivedPvpCD"]
									cd = pvpCD or cd * modData
									info.talentData["essStrivedPvpID"] = spellID
								elseif spellID == 107574 and specID == 71 then
									cd = cd - 5
								end
							end


							if info.talentData[412713] and spellID ~= 404381 then
								cd = cd * 0.9
							end

							modData = E.spell_chmod_talents[spellID]
							if modData then
								for k = 1, #modData, 2 do
									local tal = modData[k]
									local rank = self:IsTalentForPvpStatus(tal, info)
									if rank then
										local charges = modData[k + 1]
										charges = type(charges) == "table" and (charges[rank] or charges[1]) or charges
										ch = ch + charges
									end
								end
							end
						elseif cat == "COVENANT" then
							local covData = E.covenant_cdmod_conduits[spellID]
							if covData and info.talentData[ covData[1] ] then
								cd = cd - covData[2]
							end

							covData = E.covenant_cdmod_items_mult[spellID]
							if covData and info.itemData[ covData[1] ] then
								cd = cd * covData[2]
							end

							covData = E.covenant_chmod_conduits[spellID]
							if covData and info.talentData[ covData[1] ] then
								ch = ch + covData[2]
							end
						elseif cat == "ESSENCE" then
							local essData = E.spell_cdmod_essrank23 [spellID]
							if essData then
								if E:IsEssenceRankUpgraded(info.talentData["essMajorID"]) then
									cd = cd - essData
								end
							end

							essData = E.spell_chargemod_essrank3 [spellID]
							if essData then
								if essData[1] == info.talentData["essMajorID"] then
									ch = ch + essData[2]
								end
							end
						elseif cat == "RACIAL" then
							local modData = E.spell_cdmod_talents[spellID]
							if modData then
								for k = 1, #modData, 2 do
									local tal = modData[k]
									local rank = self:IsTalentForPvpStatus(tal, info)
									if rank then
										local rt = modData[k+1]
										rt = type(rt) == "table" and (rt[rank] or rt[1]) or rt
										cd = cd - rt
									end
								end
							end


							if info.talentData[412713] then
								cd = cd * 0.9
							end
						end
					end
					ch = ch > 1 and ch

					local icon
					if extraBarFrame then


						extraBarFrame.numIcons = extraBarFrame.numIcons + 1
						if ( extraBarFrame.db.unitBar ) then
							local unitBar = frame.activeUnitBars[enabledSpell]
							icon = self:AcquireIcon(extraBarFrame, extraBarFrame.numIcons, unitBar)
							unitBar.icons[#unitBar.icons + 1] = icon
						else
							icon = self:AcquireIcon(extraBarFrame, extraBarFrame.numIcons)
						end
					else
						iconIndex = iconIndex + 1
						icon = frame.icons[iconIndex] or self:AcquireIcon(frame, iconIndex)
					end
					icon.name:Hide()
					icon.guid = guid
					icon.spellID = spellID
					icon.class = class
					icon.unit = unit
					icon.unitName = name
					icon.type = spellType
					icon.priority = E.db.spellPriority[spellID] or E.db.priority[spellType]
					icon.category = cat

					icon.isBookType = (E.BOOKTYPE_CATEGORY[cat] or cat == "COVENANT") and not twwHeroTalents[spellID]
					icon.buff = buffID
					icon.duration = cd and cd < 1 and 1 or cd
					icon.baseCooldown = baseCooldown
					icon.maxcharges = ch
					icon.count:SetText(ch or (spellID == 323436 and info.auras.purifySoulStacks) or (spellID == 6262 and info.auras.healthStoneStacks) or "")

					local iconFix = iconTextureFix[spellID]
					if iconFix then
						iconTexture = GetOverrideTexture(info, iconFix)
					end
					icon.icon:SetTexture(iconTexture)
					icon.iconTexture = iconTexture

					icon.active = nil
					icon.tooltipID = nil
					icon.modRate = info.spellModRates[spellID] or 1
					icon.glowBorder = not extraBarFrame and E.db.highlight.glowBorder and E.db.spellGlow[spellID]
					icon.Glow:Hide()
					icon:HideOverlayGlow()

					local active = info.active[spellID]
					--[==[@debug@
					if active then
						assert(active.startTime, spellID)
					end
					--@end-debug@]==]
					if active and active.startTime then
						if icon.maxcharges then
							active.charges = active.charges or (icon.maxcharges - 1)
							icon.count:SetText(active.charges)
						else
							active.charges = nil
						end
						icon.cooldown:SetCooldown(active.startTime, active.duration, active.modRate)
						icon.active = active.charges or 0

						icon:SetHighlight(true)
					else
						icon.cooldown:Clear()
					end

					if extraBarFrame then
						local statusBar = icon.statusBar
						if statusBar then
							if not extraBarFrame.shouldShowProgressBar then
								statusBar:Release()
								icon.statusBar = nil
							end
						else
							if extraBarFrame.shouldShowProgressBar then
								self:AcquireStatusBar(icon, extraBarKey, info.nameWithoutRealm)
							end
						end
					end


					if info.preactiveIcons[spellID] then
						info.preactiveIcons[spellID] = icon
						icon:SetHighlight(true)
					end
					info.spellIcons[spellID] = icon
				end
			end
		end
	end
	frame:ReleaseIcons(iconIndex)


	if not self.effectivePixelMult then
		frame:SetEffectivePixelMult()
	end

	if notUser or not self.isUserHidden then
		frame:ApplySettings()
		frame:UpdateLayout(true)
	else
		frame:SetAnchor(true)
	end

	if not isUpdateBarsOrGRU then
		self:UpdateExBars()
	end
end

function P:UpdateBars()
	for guid in pairs(self.groupInfo) do
		self:UpdateUnitBar(guid, true)
	end
end

function P:UpdateAllBars()
	self:ReleaseExBars()
	self:UpdateBars()
	self:UpdateExBars()
end

function P:ReleaseBars()
	for frame in pairs(activeBars) do
		frame:Release()
	end
end

function P:HideBars()
	for frame in pairs(activeBars) do
		frame:Hide()
	end
end

P.sorters = sorters
E.UNIT_TO_PET = UNIT_TO_PET
