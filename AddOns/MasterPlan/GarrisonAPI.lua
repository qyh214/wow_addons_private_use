local api, _, T = {}, ...
if T.Mark ~= 40 then return end
local EV, L = T.Evie, newproxy(true)
getmetatable(L).__call = function(_,k) if T.L then L = T.L return L(k) end return k end
local FOLLOWER_ITEM_LEVEL_CAP, MENTOR_FOLLOWER = T.FOLLOWER_ITEM_LEVEL_CAP, T.MENTOR_FOLLOWER
local unfreeStatusOrder = {[GARRISON_FOLLOWER_WORKING]=2, [GARRISON_FOLLOWER_INACTIVE]=1}

local f, data = CreateFrame("Frame"), {}
f:SetScript("OnUpdate", function(self) wipe(data) self:Hide() end)

local cacheTables = {} do
	local watching, onZone, onOpen, onClose
	function onZone()
		if not (C_Garrison.IsOnGarrisonMap() or GarrisonMissionFrame:IsVisible()) then
			EV.RaiseEvent("MP_RELEASE_CACHES")
			EV.UnregisterEvent("GARRISON_MISSION_NPC_OPENED", onOpen)
			watching = nil
			return "remove"
		end
	end
	function onClose()
		if watching then return end
		EV.RegisterEvent("ZONE_CHANGED", onZone)
		EV.RegisterEvent("GARRISON_MISSION_NPC_OPENED", onOpen)
		watching = 1
		onZone()
	end
	function onOpen()
		EV.UnregisterEvent("ZONE_CHANGED", onZone)
		watching = nil
		return "remove"
	end
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", onClose)
	EV.RegisterEvent("MP_RELEASE_CACHES", function()
		for i=1,#cacheTables do
			wipe(cacheTables[i])
		end
	end)
end

local parseTime = {} do
	local captures = {} do
		local function proc(fm, f, s)
			local t, pat = nil, fm:gsub("%%d", "\0"):gsub("[()%[%].%-+*?%%]", "%%%0")
			for chunk, inner in pat:gmatch("(|4(.-);)") do
				local it = {[0]=chunk:gsub("[()%[%].%-+*%%]", "%%%0")}
				for var in inner:gmatch("[^:]+") do
					it[#it+1] = var
				end
				t = t or {}
				t[#t+1] = it
			end
			if t then
				local nv = {}
				for i=1,#t do nv[i] = 1 end
				while 1 do
					local pat = pat
					for i=1,#nv do
						pat = pat:gsub(t[i][0], t[i][nv[i]])
					end
					captures[#captures+1], captures[#captures+2], captures[#captures+3] = "^" .. pat:gsub("%z", "(%%d+)") .. "$", f, s
					for i=#nv, 0, -1 do
						if i == 0 then return end
						nv[i] = nv[i] % #t[i] + 1
						if nv[i] > 1 then break end
					end
				end
			else
				captures[#captures+1], captures[#captures+2], captures[#captures+3] = "^" .. pat:gsub("%z", "(%%d+)") .. "$", f, s
			end
		end
		proc(GARRISON_DURATION_DAYS, 86400, 0)
		proc(GARRISON_DURATION_DAYS_HOURS, 86400, 3600)
		proc(GARRISON_DURATION_HOURS, 3600, 0)
		proc(GARRISON_DURATION_HOURS_MINUTES, 3600, 60)
		proc(GARRISON_DURATION_MINUTES, 60, 0)
		proc(GARRISON_DURATION_SECONDS, 1, 0)
	end
	setmetatable(parseTime, {__index=function(self, k)
		if k == nil then return 0 end
		local ret = math.huge
		for i=1,#captures, 3 do
			local a, b = k:match(captures[i])
			if a then
				ret = tonumber(a) * captures[i+1] + (b and tonumber(b) * captures[i+2] or 0)
				break
			end
		end
		self[k] = ret
		return ret
	end})
	cacheTables[#cacheTables+1] = parseTime
end
function api.GetSecondsFromTimeString(time)
	local t = parseTime[time]
	return t and t > 59 and (t + 60) or t
end
function api.GetTimeStringFromSeconds(sec)
	if sec < 60 then
		return GARRISON_DURATION_SECONDS:format(sec < 0 and 0 or sec)
	elseif sec < 3600 then
		return GARRISON_DURATION_MINUTES:format(sec/60)
	elseif sec < 84600 then
		return (sec % 3600 < 60 and GARRISON_DURATION_HOURS or GARRISON_DURATION_HOURS_MINUTES):format(sec/3600, (sec/60) % 60)
	else
		return (sec % 86400 < 3600 and GARRISON_DURATION_DAYS or GARRISON_DURATION_DAYS_HOURS):format(sec/84600, (sec/3600) % 24)
	end
end
local stime do
	local t = {}
	function stime()
		t.month, t.day, t.year = select(2, CalendarGetDate())
		t.sec, t.hour, t.min = time()%60, GetGameTime()
		return time(t)
	end
end

local dropFollowers, missionEndTime = {}, {} do -- Start/Available capture
	local complete, startQueue, startQueueSize, it = {}, {}, 0, 1
	function api.GetAvailableMissions()
		local t = C_Garrison.GetAvailableMissions()
		securecall(api.ObserveMissions, t)
		local i, n, nit, dropCost = 1, #t, it % 2 + 1, 0
		while i <= n do
			local mid = t[i].missionID
			if complete[mid] then
				t[i], complete[mid], n, dropCost, t[n] = i < n and t[n] or nil, nit, n - 1, dropCost + (t[i].cost or 0)
			else
				i = i + 1
			end
		end
		it = nit
		for k,v in pairs(complete) do
			if v ~= nit then
				complete[k] = nil
			end
		end
		for k,v in pairs(dropFollowers) do
			if not complete[v] then
				dropFollowers[k] = nil
			end
		end
		return t, dropCost
	end
	function api.StartMission(id)
		local mi, f1, f2, f3 = C_Garrison.GetBasicMissionInfo(id)
		if not mi then return error("Mission is not available") end
		for j=1,#mi.followers do
			local fid = mi.followers[j]
			dropFollowers[fid], f1, f2, f3 = id, fid, f1, f2
		end
		local nf = (f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0)
		if nf ~= mi.numFollowers then return error(tostring(mi.numFollowers) .. " followers expected; " .. nf .. " assigned") end
		complete[id], missionEndTime[id] = it, time()+select(2,C_Garrison.GetPartyMissionInfo(id))
		C_Garrison.StartMission(id)
		wipe(data)
		EV.RaiseEvent("MP_MISSION_START", id, f1, f2, f3)
		return f1, f2, f3
	end
	local function pushStart(id, f1, f2, f3, syncParty)
		local mi = C_Garrison.GetBasicMissionInfo(id)
		if not mi then return error("Mission is not available") end
		local mif = mi.followers
		if syncParty or not mif or mif[1] ~= f1 or mif[2] ~= f2 or mif[3] ~= f3 then
			for i=1,mif and #mif or 0 do
				C_Garrison.RemoveFollowerFromMission(id, mif[i])
			end
			for i=1, mi.numFollowers do
				C_Garrison.AddFollowerToMission(id, f1)
				f1, f2, dropFollowers[f1] = f2, f3, id
			end
		end
		complete[id], missionEndTime[id] = it, time()+select(2,C_Garrison.GetPartyMissionInfo(id))
		wipe(data)
		C_Garrison.StartMission(id)
	end
	local function startQueuePing()
		if next(startQueue) then
			C_Timer.After(0.5, startQueuePing)
		end
		for k, v in pairs(startQueue) do
			pushStart(k, v[1], v[2], v[3])
		end
	end
	function api.StartMissionQueue(id, f1, f2, f3)
		if not next(startQueue) then
			C_Timer.After(0.5, startQueuePing)
		end
		startQueue[id], startQueueSize = {f1, f2, f3}, startQueueSize + (startQueue[id] and 0 or 1)
		pushStart(id, f1, f2, f3, true)
		EV.RaiseEvent("MP_MISSION_START", id, f1, f2, f3)
	end
	function api.GetNumPendingMissionStarts()
		return startQueueSize
	end
	EV.RegisterEvent("GARRISON_MISSION_STARTED", function(_, id)
		startQueueSize, startQueue[id] = startQueueSize - (startQueue[id] and 1 or 0)
		EV.RaiseEvent("MP_MISSION_START_QUEUE", startQueueSize)
	end)
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", function()
		wipe(complete)
		wipe(dropFollowers)
		wipe(missionEndTime)
		wipe(startQueue)
		if startQueueSize > 0 then
			startQueueSize = 0
			EV.RaiseEvent("MP_MISSION_START_QUEUE", startQueueSize)
		end
	end)
end

local function AddCounterMechanic(fit, fabid)
	if fabid and fabid > 0 then
		if C_Garrison.GetFollowerAbilityIsTrait(fabid) then
			fit.traits[fabid] = fabid
		else
			local mid, _, tex = C_Garrison.GetFollowerAbilityCounterMechanicInfo(fabid)
			if tex then
				fit.counters[fabid] = mid
			end
		end
	end
end
local function followerIDcmp(a, b)
	return a.followerID < b.followerID
end
local function SetFollowerInfo(t)
	local ft, now, um = {}, time(), 0
	for i=1,#t do
		local v = t[i]
		if v.isCollected then
			local fid = v.followerID
			v.counters, v.traits, v.isCombat = {}, {}, v.isCollected and not unfreeStatusOrder[v.status] or false
			for i=1,2 do
				AddCounterMechanic(v, C_Garrison.GetFollowerAbilityAtIndex(fid, i))
				AddCounterMechanic(v, C_Garrison.GetFollowerTraitAtIndex(fid, i))
			end
			AddCounterMechanic(v, C_Garrison.GetFollowerTraitAtIndex(fid, 3))
			local tls = C_Garrison.GetFollowerMissionTimeLeftSeconds(fid)
			if v.quality >= 4 and v.level == 100 then um = um + 1 end
			ft[fid], v.missionEndTime, v.affinity = v, tls and (now + tls) or nil, T.Affinities[v.garrFollowerID or v.followerID]
		end
	end
	if um > 11 then T.config.goldRewardThreshold = 0 end
	for k,v in pairs(dropFollowers) do
		local f = ft[k]
		if not f.missionEndTime then
			f.status, f.missionEndTime = GARRISON_FOLLOWER_ON_MISSION, missionEndTime[v]
		end
	end
	data.followers = ft
	f:Show()
end
function api.GetFollowerInfo(refresh)
	if not data.followers or refresh then
		SetFollowerInfo(C_Garrison.GetFollowers())
	end
	return data.followers
end
function api.GetFollowerIdentity(includeInactive, includeStatus)
	local f = C_Garrison.GetFollowers()
	local last = #f
	for i=last, 1, -1 do
		if not f[i].isCollected then
			f[i], last, f[last] = last ~= i and f[last] or nil, last - 1
		end
	end
	table.sort(f, followerIDcmp)
	local ignore, tentativeState, sig = T.config.ignore, T.tentativeState, ""
	for i=1,#f do
		local v = f[i]
		if includeInactive or v.status ~= GARRISON_FOLLOWER_INACTIVE then
			local k, q = v.followerID, ""
			q = "#" .. k .. "-" .. v.level .. "-" .. v.iLevel
			for j=1,4 do
				q = q .. "#" .. (C_Garrison.GetFollowerAbilityAtIndex(k, j) or 0) .. "#" .. (C_Garrison.GetFollowerTraitAtIndex(k, j) or 0)
			end
			sig = sig .. q .. "#" .. (includeStatus and (dropFollowers[k] and GARRISON_FOLLOWER_ON_MISSION or v.status ~= GARRISON_FOLLOWER_IN_PARTY and v.status or ".") .. "#" .. (tentativeState[k] or "-") or "") .. (ignore[k] and "i" or "-")
		end
	end
	SetFollowerInfo(f)
	return sig
end
function api.PushFollowerPartyStatus(fid)
	if data.followers and data.followers[fid] then
		data.followers[fid].status = GARRISON_FOLLOWER_IN_PARTY
	end
end
function api.GetCounterInfo()
	if not data.counters then
		local ci = {}
		for fid, info in pairs(api.GetFollowerInfo()) do
			local u1, u2
			for _,k in pairs(info.counters) do
				if k ~= u1 and k ~= u2 then
					local t = ci[k] or {}
					ci[k], t[#t+1], u1, u2 = t, fid, k, u1
				end
			end
		end
		data.counters = ci
		f:Show()
	end
	return data.counters
end
function api.GetDoubleCounters(finfo)
	if not data.counters2 then
		local rt, aai, cai = {}, C_Garrison.GetFollowerAbilityAtIndex, C_Garrison.GetFollowerAbilityCounterMechanicInfo
		for fid, fi in pairs(finfo) do
			if not T.config.ignore[fid] then
				if fi.quality >= 4 then
					local c1, c2 = cai(aai(fid, 1)), cai(aai(fid, 2))
					local k = c1 <= c2 and (c1*100 + c2) or (c2*100 + c1)
					local tk = rt[k] or {}
					tk[#tk + 1], rt[k] = fi.followerID, tk
				end
				local sc = T.SpecCounters[fi.classSpec]
				if sc then
					local c1, s1 = aai(fid, 1) or 0, false
					c1 = c1 > 0 and cai(c1) or false
					-- actually, this is wrong. we only need c1 logic for current ability + one of spec's abilities for quality < 4. but then, we also get a difference between "Gain naturally" and "if rerolled."
					for i=#sc-1,0,-1 do
						local c1 = sc[i] or c1
						for j=i+1,#sc do
							local c2 = sc[j]
							local k = c1 <= c2 and -(c1*100 + c2) or -(c2*100 + c1)
							local tk = rt[k] or {}
							tk[#tk + 1], rt[k] = fi.followerID, tk
						end
						s1 = s1 or (sc[i] == c1)
						if i == 1 and s1 then break end
					end
				end
			end
		end
		data.counters2 = rt
		f:Show()
	end
	return data.counters2
end
function api.GetFollowerTraits()
	if not data.traits then
		local ci, et = {}, T.EquivTrait
		for fid, info in pairs(api.GetFollowerInfo()) do
			local afid = info.affinity and info.affinity > 0 and info.affinity
			if afid then
				local t = ci[afid] or {}
				ci[afid], t = t, t.affine or {}
				ci[afid].affine, t[#t+1] = t, fid
			end
			for k in pairs(info.traits) do
				repeat
					local t = ci[k] or {}
					ci[k], t[#t+1], k = t, fid, et[k]
				until not k
			end
		end
		data.traits = ci
		f:Show()
	end
	return data.traits
end
do -- api.GetMechanicInfo(mid/tex)
	local counter, desc = {}, {}
	local function populate()
		for _, fid in pairs({6, 118, 127, 131, 138, 140, 144}) do
			for _, a in pairs(C_Garrison.GetFollowerAbilities(fid)) do
				for k,t in pairs(a.counters) do
					local lc = t.icon:lower()
					counter[k], counter[lc], counter[lc:gsub("%.blp$","")], desc[k] = a.id, a.id, a.id, t.description
				end
			end
		end
	end
	function api.GetMechanicInfo(mid)
		if populate then
			populate = populate()
		end
		if counter[mid] then
			local id, name, tex = C_Garrison.GetFollowerAbilityCounterMechanicInfo(counter[mid])
			return id, name, tex, desc[id]
		end
	end
end
function api.GetMissionThreats(missionID)
	local ret, rn, en = {}, 1, select(8,C_Garrison.GetMissionInfo(missionID))
	for i=1,#en do
		for id in pairs(en[i].mechanics) do
			ret[rn], rn = id, rn + 1
		end
	end
	return ret
end
do -- sortByFollowerLevels
	local lvl
	local function cmp(a,b)
		local af, bf, ac, bc = lvl[a], lvl[b], a, b
		if (not af) ~= (not bf) then
			return not not af
		elseif af and bf then
			ac, bc = unfreeStatusOrder[af.status] or 3, unfreeStatusOrder[bf.status] or 3
			if ac == bc and (not T.config.ignore[af.followerID]) ~= (not T.config.ignore[bf.followerID]) then
				return not T.config.ignore[af.followerID]
			end
			if ac == bc then
				ac, bc = af.level or 0, bf.level or 0
				if ac == bc and ac == 100 then
					ac, bc = af.iLevel or 0, bf.iLevel or 0
				end
			end
			if ac == bc then
				ac, bc = C_Garrison.GetFollowerQuality(a), C_Garrison.GetFollowerQuality(b)
			end
		end
		if ac == bc then ac, bc = a, b end
		return ac > bc
	end
	function api.sortByFollowerLevels(counters, finfo)
		lvl = finfo
		table.sort(counters, cmp)
		lvl = nil
		return counters
	end
end
function api.GetFMLevel(fmInfo, mentor)
	return fmInfo and (mentor and mentor >= fmInfo.iLevel and mentor or fmInfo.level == 100 and fmInfo.iLevel > 600 and fmInfo.iLevel or fmInfo.level) or 0
end
function api.GetLevelEfficiency(fLevel, mLevel)
	if (mLevel or 0) <= fLevel then
		return 1
	elseif mLevel - fLevel <= (mLevel > 100 and 14 or 2) then
		return 0.5
	end
	return 0.1
end
function api.GetFollowerLevelDescription(fid, mlvl, fi, mentor, mid)
	local fi = fi or api.GetFollowerInfo()[fid]
	local tooLow, q = api.GetLevelEfficiency(api.GetFMLevel(fi, mentor), mlvl) < 0.5, fi and fi.quality or 0
	local lc, away = ITEM_QUALITY_COLORS[tooLow and 0 or q].hex, fi.missionEndTime
	if fi.status == GARRISON_FOLLOWER_INACTIVE then
		away = RED_FONT_COLOR_CODE .. " (" .. GARRISON_FOLLOWER_INACTIVE .. ")"
	elseif fi.status == GARRISON_FOLLOWER_WORKING then
		away = YELLOW_FONT_COLOR_CODE .. " (" .. GARRISON_FOLLOWER_WORKING .. ")"
	elseif away then
		away = "|cffa0a0a0 (" .. api.GetTimeStringFromSeconds(away-time()) .. ")"
	elseif mid and (MasterPlan:GetFollowerTentativeMission(fi.followerID) or mid) ~= mid then
		away = "|cffa0a0a0 (" .. L"In Tentative Party" .. ")"
	elseif T.config.ignore[fid] then
		away = RED_FONT_COLOR_CODE .. " (" .. L"Ignored" .. ")"
	else
		away = ""
	end
	if fi.level == 100 and fi.quality >= 4 and tooLow then
		away = ITEM_QUALITY_COLORS[4].hex .. L"*" .. (away ~= "" and "|r " .. away or "|r")
	end
	return ("%s[%d]|r %s%s|r%s"):format(lc, fi.level < 100 and fi.level or fi.iLevel, HIGHLIGHT_FONT_COLOR_CODE, fi.name, away)
end
function api.GetOtherCounterIcons(fi, mechanic)
	local fid, reorder, firstID, ret = fi.followerID, mechanic == nil
	for i=1,4 do
		local aid = C_Garrison.GetFollowerAbilityAtIndex(fid, i)
		if aid ~= 0 then
			local mid, _, ico = C_Garrison.GetFollowerAbilityCounterMechanicInfo(aid)
			if reorder then
				if i == 1 then
					firstID = mid
				elseif i == 2 and mid and mid < firstID then
					mechanic = mid
				end
			end
			if mid and mid == mechanic then
				ret, mechanic = (ret and ret .. " " or "") .. "|T" .. ico .. ":0:0:0:0:64:64:6:58:6:58|t"
			elseif mid then
				ret = "|T" .. ico .. ":0:0:0:0:64:64:6:58:6:58|t" .. (ret and " " .. ret or "")
			end
		end
	end
	return ret or ""
end
function api.GetNumIdleCombatFollowers(followers)
	local ret = 0
	for k,v in pairs(followers or api.GetFollowerInfo()) do
		if v.isCollected and (v.status == nil or v.status == GARRISON_FOLLOWER_IN_PARTY) then
			ret = ret + 1
		end
	end
	return ret
end

do -- CompleteMissions/AbortCompleteMissions
	local curStack, curRewards, curFollowers, curCallback
	local curSalvage, curPlayerXP = {[114120]=0, [114119]=0, [114116]=0}, {}
	local curState, curIndex, completionStep, lastAction, delayIndex, delayMID
	local function checkSalvage(addRewards)
		for k,v in pairs(curSalvage) do
			local nv = GetItemCount(k) or 0
			if addRewards and nv > v then
				local ik = "item:" .. k
				curRewards[ik] = curRewards[ik] or {itemID=k, quantity=0}
				curRewards[ik].quantity = curRewards[ik].quantity + nv - v
			end
			curSalvage[k] = nv
		end
		local nxp, nlvl = UnitXP("player"), UnitLevel("player")
		if addRewards and curPlayerXP[1] and (curPlayerXP[1] < nxp or curPlayerXP[3] < nlvl) then
			curRewards.xp = curRewards.xp or {playerXP=0}
			curRewards.xp.playerXP = curRewards.xp.playerXP + (curPlayerXP[3] < nlvl and curPlayerXP[2] or 0) + nxp - curPlayerXP[1]
		end
		curPlayerXP[1], curPlayerXP[2], curPlayerXP[3] = nxp, UnitXPMax("player"), nlvl
	end
	local delayOpen, delayRoll do
		local function delay(state, f, d)
			local function delay(minDelay)
				if curState == state and curIndex == delayIndex and curStack[delayIndex].missionID == delayMID then
					local time = GetTime()
					if not minDelay and (not lastAction or (time-lastAction >= d)) then
						lastAction = GetTime()
						f(curStack[curIndex].missionID)
						C_Timer.After(d, delay)
					else
						C_Timer.After(math.max(0.1, d + lastAction - time, minDelay or 0), delay)
					end
				end
			end
			return delay
		end
		delayOpen = delay("COMPLETE", C_Garrison.MarkMissionComplete, 0.4)
		delayRoll = delay("BONUS", C_Garrison.MissionBonusRoll, 0.4)
	end
	local function delayStep()
		completionStep("GARRISON_MISSION_NPC_OPENED")
	end
	local function delayDone()
		if curState == "ABORT" or curState == "DONE" then
			checkSalvage(true)
			securecall(curCallback, curState, curStack, curRewards, curFollowers)
			curState, curStack, curRewards, curFollowers, curIndex, curCallback, delayMID, delayIndex = nil
		end
	end
	local function isWastingCurrency(mi)
		if mi.rewards then
			mi.skipped = nil
			for k,v in pairs(mi.rewards) do
				if v.currencyID and v.currencyID > 0 then
					local rew = v.quantity * (v.currencyID == GARRISON_CURRENCY and select(8, C_Garrison.GetPartyMissionInfo(mi.missionID)) or mi.materialMultiplier or 1)
					local _, cur, _, _, _, tmax = GetCurrencyInfo(v.currencyID)
					if tmax > 0 and (cur+rew-tmax) > rew * T.config.currencyWasteThreshold then
						mi.skipped, curState, curIndex = true, "NEXT", curIndex + 1
						completionStep("GARRISON_MISSION_NPC_OPENED", "IMMEDIATE")
						return true
					end
				end
			end
		end
	end

	local function saveMultipliers(mi)
		if not (mi.materialMultiplier and mi.goldMultiplier) then
			local mm, gm = select(8, C_Garrison.GetPartyMissionInfo(mi.missionID))
			mi.materialMultiplier, mi.goldMultiplier = mi.materialMultiplier or mm, mi.goldMultiplier or gm
		end
	end
	function completionStep(ev, ...)
		if not curState then return end
		local mi = curStack[curIndex]
		while mi and (mi.succeeded or mi.failed) do
			mi, curIndex = curStack[curIndex+1], curIndex + 1
		end
		if (ev == "GARRISON_MISSION_NPC_CLOSED" and mi) or not mi then
			curState = mi and "ABORT" or "DONE"
			C_Timer.After(0.5, delayDone)
		elseif curState == "NEXT" and ev == "GARRISON_MISSION_NPC_OPENED" then
			if mi.state == -1 then
				curState, delayIndex, delayMID = "COMPLETE", curIndex, mi.missionID
				delayOpen(... ~= "IMMEDIATE" and 0.2)
			elseif isWastingCurrency(mi) then
			else
				saveMultipliers(mi)
				curState, delayIndex, delayMID = "BONUS", curIndex, mi.missionID
				delayRoll(... ~= "IMMEDIATE" and 0.2)
			end
		elseif curState == "COMPLETE" and ev == "GARRISON_MISSION_COMPLETE_RESPONSE" then
			local mid, cc, ok = ...
			if mid ~= mi.missionID and not cc then return end
			if securecall(assert, mid == mi.missionID, "Unexpected mission completion") then
				if ok then
					saveMultipliers(mi)
					mi.state, curState = 0, "BONUS"
				else
					mi.failed, curState, curIndex = cc and true or nil, "NEXT", curIndex + 1
				end
				if cc then
					securecall(curCallback, "STEP", curStack, curRewards, curFollowers, ok and "COMPLETE" or "FAIL", mi.missionID)
				end
				if ok then
					if isWastingCurrency(mi) then return end
					delayIndex, delayMID = curIndex, mi.missionID
					delayRoll(0.2)
				else
					C_Timer.After(0.45, delayStep)
				end
			end
		elseif curState == "BONUS" and ev == "GARRISON_MISSION_BONUS_ROLL_COMPLETE" then
			local mid, _ok = ...
			if securecall(assert, mid == mi.missionID, "Unexpected bonus roll completion") then
				mi.succeeded, curState, curIndex = true, "NEXT", curIndex + 1
				if mi.rewards then
					for k,r in pairs(mi.rewards) do
						if r.currencyID and r.quantity then
							local ik, q = "cur:" .. r.currencyID, r.quantity
							if r.currencyID == GARRISON_CURRENCY then
								q = floor(q*(mi.materialMultiplier or 1))
							elseif r.currencyID == 0 then
								q = floor(q*(mi.goldMultiplier or 1))
							end
							curRewards[ik] = curRewards[ik] or {quantity=0, currencyID=r.currencyID}
							curRewards[ik].quantity = curRewards[ik].quantity + q
						elseif r.itemID and r.quantity then
							local ik = "item:" .. r.itemID
							curRewards[ik] = curRewards[ik] or {itemID=r.itemID, quantity=0}
							curRewards[ik].quantity = curRewards[ik].quantity + r.quantity
						end
					end
				end
				securecall(curCallback, "STEP", curStack, curRewards, curFollowers, "LOOT", mi.missionID)
			end
		end
	end
	EV.RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED", function(_, fid, xpAward, oldXP, olvl, oqual)
		if curState then
			curFollowers[fid] = curFollowers[fid] or {olvl=olvl, oqual=oqual, xpAward=0, oxp=oldXP}
			curFollowers[fid].xpAward = curFollowers[fid].xpAward + xpAward
		end
	end)
	EV.RegisterEvent("GARRISON_MISSION_NPC_OPENED", completionStep)
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", completionStep)
	EV.RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE", completionStep)
	EV.RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE", completionStep)
	function api.CompleteMissions(stack, callback)
		curStack, curCallback, curRewards, curFollowers = stack, callback, {}, {}
		curState, curIndex = "NEXT", 1, checkSalvage(false)
		completionStep("GARRISON_MISSION_NPC_OPENED", "IMMEDIATE")
	end
	function api.AbortCompleteMissions()
		completionStep("GARRISON_MISSION_NPC_CLOSED")
	end
	function api.GetCompletionState()
		return curState, curIndex, curStack, curRewards, curFollowers
	end
end

do -- GetMissionSeen
	local lastOffer
	local expire = T.MissionExpire
	function api.ObserveMissions(missions)
		local missions, now = lastOffer and (missions or C_Garrison.GetAvailableMissions()), stime() - GetTime()
		for i=1,missions and #missions or 0 do
			local mi = missions[i]
			local ex, otr = expire[mi.missionID], mi.offerEndTime
			if otr and ex and ex > 0 and otr > 0 then
				lastOffer[mi.missionID] = now + otr - ex * 3600
			end
		end
	end
	local shortHourFormat = GARRISON_DURATION_HOURS:gsub("%%[%d$]*d", "%%s")
	function api.GetMissionSeen(mid, mi)
		local mi, lastAppeared, now = mi or C_Garrison.GetBasicMissionInfo(mid), lastOffer and lastOffer[mid], stime()
		local tl = mi and mi.offerEndTime and (mi.offerEndTime - GetTime()) or -1
		return tl, mi and mi.offerTimeRemaining or tl >= 0 and api.GetTimeStringFromSeconds(tl) or "", tl >= 0 and shortHourFormat:format(math.floor(tl/3600+0.5)) or "", lastAppeared and (now-lastAppeared)
	end
	function T._SetMissionSeenTable(seenTable)
		if type(seenTable) == "table" then
			lastOffer = {}
			for k,v in pairs(seenTable) do
				if type(k) == "number" and type(v) == "number" then
					lastOffer[k] = v
				end
			end
		end
	end
	function T._GetMissionSeenTable()
		securecall(api.ObserveMissions, C_Garrison.GetAvailableMissions())
		return lastOffer
	end
end

do -- PrepareAllMissionGroups/GetMissionGroups {sc xp gr ti p1 p2 p3 xp pb}
	local msf, msi, msd, mmi, finfo, msiMentorIndex, mentorLevel = {}, {}, {}
	local suppressFollowerEvents, releaseFollowerEvents do
		local level, frames, followers = 0
		local function failsafe()
			if level > 0 then
				level = 1
				releaseFollowerEvents()
			end
		end
		function suppressFollowerEvents()
			if level == 0 then
				frames, followers = {GetFramesRegisteredForEvent("GARRISON_FOLLOWER_LIST_UPDATE")}, {}
				for i=1,#frames do
					frames[i]:UnregisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
				end
				local mmi = C_Garrison.GetAvailableMissions()
				for i=1,#mmi do
					for k,v in pairs(mmi[i].followers) do
						C_Garrison.RemoveFollowerFromMission(mmi[i].missionID, v)
						followers[v] = mmi[i].missionID
					end
				end
				C_Timer.After(0, failsafe)
			end
			level = level + 1
		end
		function releaseFollowerEvents()
			assert(level > 0, "release not matched to suppress")
			level = level - 1
			if level == 0 then
				local mmi = C_Garrison.GetAvailableMissions()
				for i=1,#mmi do
					for k,v in pairs(mmi[i].followers) do
						C_Garrison.RemoveFollowerFromMission(mmi[i].missionID, v)
					end
				end
				for f, m in pairs(followers) do
					C_Garrison.AddFollowerToMission(m, f)
				end
				for i=1,#frames do
					frames[i]:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE")
				end
				frames, followers = nil, nil
			end
		end
	end
	local function cmp_level(a, b)
		local a, b = finfo[a], finfo[b]
		return (a.level + a.iLevel) > (b.level + b.iLevel)
	end
	function api.PrepareAllMissionGroups()
		mmi = C_Garrison.GetAvailableMissions(mmi)
		suppressFollowerEvents()
		securecall(function()
			for i=1,#mmi do
				api.GetMissionGroups(mmi[i].missionID, i > 1)
			end
		end)
		releaseFollowerEvents()
		mmi = nil
	end
	function api.GetMissionGroups(mid, trustValid)
		if not trustValid or not msi[1] then
			finfo, msiMentorIndex, mentorLevel = api.GetFollowerInfo()
			local valid, fn = true, 1
			for k,v in pairs(finfo) do
				if v.isCollected and v.status ~= GARRISON_FOLLOWER_INACTIVE then
					local key = v.level .. "#" .. v.iLevel
					for i=1,4 do
						key = key .. "#" .. (C_Garrison.GetFollowerAbilityAtIndex(k, i) or 0) .. "#" .. (C_Garrison.GetFollowerTraitAtIndex(k, i) or 0)
					end
					msi[fn], fn, msf[k], valid = k, fn+1, key, valid and msf[k] == key
				end
			end
			for i=fn,#msi do
				valid, msi[i] = false
			end
			table.sort(msi, cmp_level)
			for i=1,#msi do
				if finfo[msi[i]].garrFollowerID == MENTOR_FOLLOWER then
					msiMentorIndex, mentorLevel = i, finfo[msi[i]].iLevel
					break
				end
			end
			for k,v in pairs(msf) do
				if not (finfo[k] and finfo[k].isCollected and finfo[k].status ~= GARRISON_FOLLOWER_INACTIVE) then
					valid, msf[k] = false
				end
			end
			if not valid then wipe(msd) end
			finfo = nil
		end
		if not msd[mid] then
			local mmi, mi = mmi or C_Garrison.GetAvailableMissions()
			for i=1,#mmi do
				if mmi[i].missionID == mid then
					mi = mmi[i]
					break
				end
			end
			if not mi then return false end
			if mi.numFollowers > #msi then msd[mid] = {} return {} end
			local chestResources, chestXP, chestGold, _, baseXP  = 0, 0, 0, C_Garrison.GetMissionInfo(mid)
			for k,r in pairs(mi.rewards) do
				if r.currencyID == GARRISON_CURRENCY then
					chestResources = chestResources + r.quantity
				elseif r.currencyID == 0 then
					chestGold = chestGold + r.quantity
				elseif r.followerXP then
					chestXP = chestXP + r.followerXP
				end
			end
			
			suppressFollowerEvents()
			
			local fn, t, fm, m, mn = #msi, {}, {}, {}, 1
			fm[1] = fn
			for i=2,mi.numFollowers do
				fm[1], fm[2], fm[3] = fm[1] - 1, fm[1], fm[2]
			end
			t[1], t[2], t[3] = fm[1], fm[2], fm[3]

			local i1, i2, i3 = 1, mi.numFollowers > 1 and 2 or -1, mi.numFollowers > 2 and 3 or -1
			local af, rf, nf, getXPMul = C_Garrison.AddFollowerToMission, C_Garrison.RemoveFollowerFromMission, mi.numFollowers, api.GetBuffsXPMultiplier
			local GetPartyMissionInfo, mentorSlot = C_Garrison.GetPartyMissionInfo
			repeat
				for i=nf,1,-1 do
					rf(mid, msi[t[i]])
					t[i] = t[i] % fm[i] + 1
					if t[i] > 1 or i == 1 then
						if not af(mid, msi[t[i]]) then error("Failed to add follower " .. i .. ":" .. tostring(t[i]) .. ":" .. tostring(msi[t[i]])) end
						for j=i+1, nf do
							t[j]=t[j-1]+1
							if not af(mid, msi[t[j]]) then error("Failed to add follower " .. j .. ":" .. tostring(t[j]) .. ":" .. tostring(msi[t[j]])) end
						end
						if msiMentorIndex and (mentorSlot or i) >= i then
							mentorSlot = nil
							for j=i,nf do
								if t[j] == msiMentorIndex then
									mentorSlot = j
									break
								end
							end
						end
						break
					end
				end
				local _totalTimeString, totalTimeSeconds, _isMissionTimeImproved, successChance, partyBuffs, _isEnvMechanicCountered, xpBonus, materialMultiplier, goldMultiplier = GetPartyMissionInfo(mid)
				m[mn], mn = {successChance, baseXP+xpBonus, chestResources*materialMultiplier, totalTimeSeconds, msi[t[i1]], msi[t[i2]], msi[t[i3]], chestXP * (partyBuffs and getXPMul(partyBuffs) or 1), chestGold * (goldMultiplier or 1), mentorSlot and mentorLevel}, mn + 1
			until t[1] == fm[1] and t[2] == fm[2] and t[3] == fm[3]
			
			for i=1,nf do
				C_Garrison.RemoveFollowerFromMission(mid, msi[t[i]])
			end
			
			msd[mid] = m
			releaseFollowerEvents()
		end
		return msd[mid]
	end
	cacheTables[#cacheTables+1] = msd
	cacheTables[#cacheTables+1] = msf
	cacheTables[#cacheTables+1] = msi
end
function api.GetFilteredMissionGroups(minfo, filter, cmp, limit)
	local mg = api.GetMissionGroups(minfo.missionID)
	local best, finfo, sorted, now = {}, api.GetFollowerInfo(), false, time()
	for i=1,mg and #mg or 0 do
		local this = mg[i]
		if filter ~= nil and not filter(this, finfo, minfo) then
		elseif not limit or best[limit] == nil then
			best[#best+1] = this
			if limit and best[limit] then
				table.sort(best, function(a,b) return cmp(a, b, finfo, minfo) end)
				sorted = true
			end
		elseif cmp(this, best[limit], finfo, minfo) then
			best[limit] = this
			for i=limit-1, 1, -1 do
				if cmp(best[i], best[i+1], finfo, minfo) then
					break
				end
				best[i+1], best[i] = best[i], best[i+1]
			end
		end
	end
	if not sorted then
		table.sort(best, function(a,b) return cmp(a, b, finfo, minfo, now) end)
	end
	return best
end
local backfillGroupMatch do -- GetBackfillMissionGroups(minfo, filter, cmp, f1, f2, f3, f4)
	function backfillGroupMatch(g, nf, f1, f2, f3, f4)
		local g1, g2, g3 = g[5], g[6], g[7]
		local nm = f4 and (f4 == g1 or f4 == g2 or f4 == g3) and 1 or 0
		if f4 and nm == 0 then return end
		nm = nm + (f1 and (f1 == g1 or f1 == g2 or f1 == g3) and 1 or 0)
		        + (f2 and (f2 == g1 or f2 == g2 or f2 == g3) and 1 or 0)
		        + (f3 and (f3 == g1 or f3 == g2 or f3 == g3) and 1 or 0)
		return (nm == ((f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0)) or nm == nf)
	end
	local filter, f1, f2, f3, f4
	local function backfillFilter(res, finfo, minfo)
		return backfillGroupMatch(res, minfo.numFollowers, f1, f2, f3, f4) and filter(res, finfo, minfo)
	end
	function api.GetBackfillMissionGroups(mi, afilter, cmp, limit, af1, af2, af3, af4)
		filter, f1, f2, f3, f4 = afilter, af1, af2, af3, af4
		return api.GetFilteredMissionGroups(mi, (af1 or af2 or af3 or af4) and backfillFilter or afilter, cmp or api.GetMissionDefaultGroupRank(mi), limit)
	end
end
do -- api.GetBuffsXPMultiplier(buffs)
	local xpBuffs = {[80]=0.30, [236]=0.35}
	function api.GetBuffsXPMultiplier(buffs)
		local mul = 1
		for i=1,#buffs do
			mul = mul + (xpBuffs[buffs[i]] or 0)
		end
		return mul
	end
end
function api.GetFollowerXPGain(fi, mlvl, base, bonus, mentor)
	if fi.quality >= 4 and fi.level == 100 then
		base, bonus = 0, 0
	elseif base > 0 or bonus > 0 then
		fi = fi.traits and fi or api.GetFollowerInfo()[fi.followerID] or fi
		local flvl = mentor and 100 or fi.level
		local tmul, ld = fi.traits and fi.traits[29] and 1.50 or 1, (mlvl > 100 and 100 or mlvl) - flvl
		local emul = ld < 1 and 1 or (ld > 2 and 0.1 or 0.5)
		if base > 0 then
			base = base * tmul * emul
			if fi.xp + base > fi.levelXP and flvl < 100 then
				emul = ld < 2 and 1 or (ld > 3 and 0.1 or 0.5)
			end
		end
		bonus = bonus * tmul * emul
	end
	return base, bonus
end
local risk = {} do
	setmetatable(risk, {__index=function(self, c)
		local rew, ret = T.config.riskReward
		if c == 100 then
			ret = 1
		elseif rew == 1 then
			ret = c/100
		elseif rew < 1 then
			ret = c * rew
		else
			ret = c + (1-c) * (rew-1)
		end
		self[c] = ret
		return ret
	end})
	EV.RegisterEvent("MP_SETTINGS_CHANGED", function(_, s)
		if s == nil or s == "riskReward" then
			wipe(risk)
		end
	end)
	cacheTables[#cacheTables+1] = risk
end
local timeHorizon, computeEquivXP, computeEarliestCompletion do -- +api.GetSuggestedMissionGroups
	local max, min, inf, weakKeys = math.max, math.min, math.huge, {__mode="k"}
	local equivXP, expectedXP, edtime = setmetatable({}, weakKeys), setmetatable({}, weakKeys), setmetatable({}, weakKeys)
	function computeEquivXP(g, finfo, minfo, force)
		local ret1, ret2
		if not force then
			ret1, ret2 = equivXP[g], expectedXP[g]
		end
		if not ret1 then
			local mlvl, conf, finfo = api.GetFMLevel(minfo), T.config, finfo or api.GetFollowerInfo()
			local risk, baseXP, bonusXP, mentor = risk[g[1]], g[2], g[8], g[10]
			local ecap, decay = conf.xpCapGrace, conf.levelDecay
			
			local expected, balanced = 0, 0
			for i=1, minfo.numFollowers do
				local fi = finfo[g[4+i]]
				local flvl, base, bonus = fi.level, api.GetFollowerXPGain(fi, mlvl, baseXP, bonusXP, mentor)
				if base > 0 or bonus > 0 then
					local ld = flvl - minfo.level - (flvl < 94 and 1 or 0) - (flvl < 98 and 1 or 0)
					ld = decay^(ld < 0 and 0 or ld > 3 and 3 or ld)
					if (flvl == 99 and fi.quality == 4) or (flvl == 100 and fi.quality == 3) then
						local cap = fi.levelXP - fi.xp
						balanced = balanced + (base + risk*max(0, min(bonus, cap + ecap - base))) * ld
						expected = expected + max(0, min(base, cap)) + g[1]/100 * max(0, min(bonus, cap - base))
					else
						balanced, expected = balanced + (base + risk * bonus) * ld, expected + base + g[1]/100 * bonus
					end
				end
			end
			ret1 = balanced + risk * (conf.xpPerCopper * g[9] + conf.xpPerResource * g[3]) + (api.HasSignificantRewards(minfo) == true and conf.xpWithToken or 0)
			ret2 = floor(expected)
			equivXP[g], expectedXP[g] = ret1, ret2
		end
		return ret1, ret2
	end
	function computeEarliestCompletion(g, finfo, minfo, force, now)
		local now, depart, complete = now or time()
		if not force then
			depart = edtime[g]
		end
		if depart == nil then
			local finfo, mid = finfo or api.GetFollowerInfo(), minfo.missionID
			for i=5, g[7] and 7 or g[6] and 6 or 5 do
				local f = finfo[g[i]]
				local tl = f.status == GARRISON_FOLLOWER_ON_MISSION and f.missionEndTime
				if not tl then
					local drop = dropFollowers[f.followerID]
					tl = drop and (missionEndTime[drop] or inf)
				end
				if not tl and (MasterPlan:GetFollowerTentativeMission(f.followerID) or mid) ~= mid then
					tl = now
				end
				if tl and (depart or tl) <= tl then
					depart = tl
				end
			end
			depart = depart == inf and (now + 35999) or depart or false
			edtime[g] = depart
		end
		if (timeHorizon or 0) > 0 then
			local depart = (depart or now) <= now and now or depart
			if depart < timeHorizon and depart - T.config.timeHorizonMin - now > 0 then
				complete = timeHorizon + g[4]
			else
				complete = depart + g[4]
				complete = complete > timeHorizon and complete or timeHorizon
			end
		else
			complete = ((depart or now) <= now and now or depart) + g[4]
		end
		return complete, depart
	end
	function api.GetMissionGroupXP(g, minfo)
		return computeEquivXP(g, nil, minfo, false)
	end
	function api.GetMissionGroupDeparture(g, minfo)
		local _, edt = computeEarliestCompletion(g, nil, minfo)
		return edt
	end

	local groupCache, lastTimeHorizon = {}
	function api.GetSuggestedMissionGroups(missions, f1, f2, f3)
		api.PrepareAllMissionGroups()
		local fid, finfo = api.GetFollowerIdentity(false, true), api.GetFollowerInfo()
		fid = fid .. "#-ROAM-#" .. (f1 or "!") .. "-" .. (f2 or "!") .. "-" .. (f3 or "!")
		timeHorizon = time() + T.config.timeHorizon
		if groupCache._identity ~= fid or math.abs((lastTimeHorizon or 0) - timeHorizon) > 180 then
			wipe(groupCache)
		end
		if not next(groupCache) then
			lastTimeHorizon = timeHorizon
			groupCache._identity = fid
		end
		wipe(edtime)
		
		local rank2, now, defValid, ts = api.GroupRank.threats2, time(), not (f1 or f2 or f3), T.tentativeState
		for i=1,#missions do
			local mi, sg, a, a2, b, b2, c = missions[i]
			local mid, rank, rt = mi.missionID, api.GetMissionDefaultGroupRank(mi)
			local mig, nf = api.GetMissionGroups(mid, true), mi.numFollowers
			for i=1,#mig do
				local g = mig[i]
				local isValid, isAway = defValid or backfillGroupMatch(g, nf, f1, f2, f3), false
				for i=5,isValid and 4+nf or 0 do
					local fi = finfo[g[i]]
					local st, id = fi and fi.status, fi and fi.followerID
					if not fi or T.config.ignore[id] or not (st == nil or st == GARRISON_FOLLOWER_IN_PARTY or st == GARRISON_FOLLOWER_ON_MISSION) then
						isValid = false
						break
					elseif st == GARRISON_FOLLOWER_ON_MISSION or dropFollowers[id] or (ts[id] or mid) ~= mid then
						isAway = true
					end
				end
				if not isValid then
				elseif isAway then
					c = c and rank(c, g, finfo, mi, now) and c or g
				else
					if a == nil or rank(g, a, finfo, mi, now) then
						a, a2 = g, a
					elseif a2 == nil or rank(g, a2, finfo, mi, now) then
						a2 = g
					end
					if b == nil or rank2(g, b, finfo, mi, now) then
						b, b2 = g, b
					elseif b2 == nil or rank2(g, b2, finfo, mi, now) then
						b2 = g
					end
				end
			end
			sg = {a, rankType=rt}
			if b and b ~= a then
				sg[#sg+1] = b
			elseif b2 and b2 ~= a then
				sg[#sg+1] = b2
			elseif a2 then
				sg[#sg+1] = a2
			end
			if c and (sg[1] == nil or rank(c, sg[1], finfo, mi, now)) then
				sg[#sg+1] = c
			end
			groupCache[mi.missionID] = sg
		end
		
		timeHorizon = nil
		return groupCache
	end
	local function wipeAll()
		wipe(equivXP)
		wipe(expectedXP)
		wipe(groupCache)
	end
	local function wipeActive()
		wipe(edtime)
		wipe(groupCache)
	end
	EV.RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED", wipeAll)
	EV.RegisterEvent("GARRISON_MISSION_NPC_CLOSED", wipeAll)
	EV.RegisterEvent("MP_MISSION_START", wipeActive)
	EV.RegisterEvent("MP_TENTATIVE_PARTY_UPDATE", wipeActive)
	EV.RegisterEvent("GARRISON_MISSION_NPC_OPENED", wipeActive)
	
	cacheTables[#cacheTables+1] = edtime
	cacheTables[#cacheTables+1] = equivXP
	cacheTables[#cacheTables+1] = expectedXP
	cacheTables[#cacheTables+1] = groupCache
end
api.GroupRank, api.GroupFilter = {}, {} do
	local function computeDingScore(g, finfo)
		if not g.dingScore then
			local a, b, c = 1200, 1200, 1200
			for i=5,7 do
				local fi = finfo[g[i]]
				if fi and fi.xp and fi.levelXP and fi.levelXP > 0 then
					a, b, c = floor((fi.levelXP-fi.xp)/100), a, b
				end
			end
			b, c = b > c and c or b, b > c and b or c
			a, b = a > b and b or a, a > b and a or b
			b, c = b > c and c or b, b > c and b or c
			g.dingScore = -(a * 10000 + b * 100 + c)
		end
		return g.dingScore
	end
	local function success(a, b, finfo, minfo, now)
		local ac, bc, ah, bh = a[1], b[1]
		if ac == bc then
			ac, bc = a[3] * risk[a[1]], b[3] * risk[b[1]]
		end
		if ac == bc then
			ac, bc = a[9] * risk[a[1]], b[9] * risk[b[1]]
		end
		if ac == bc then
			bc, ah = computeEarliestCompletion(a, finfo, minfo, false, now)
			ac, bh = computeEarliestCompletion(b, finfo, minfo, false, now)
		end
		if ac == bc then
			ac, bc = computeEquivXP(a, finfo, minfo), computeEquivXP(b, finfo, minfo)
		end
		if ac == bc then
			ac, bc = computeDingScore(a, finfo), computeDingScore(b, finfo)
		end
		if (ac == bc) and (not ah) ~= (not bh) then
			ac, bc = bh and 1 or 0, 0
		end
		if ac == bc then
			ac, bc = a[4], b[4]
		end
		return ac > bc
	end
	local function res(a, b, finfo, minfo, now)
		for i=3,9,6 do
			if a[i] > 0 or b[i] > 0 then
				local ac, bc = risk[a[1]] * a[i], risk[b[1]] * b[i]
				if ac ~= bc then
					return ac > bc
				end
			end
		end
		return success(a,b, finfo, minfo, now)
	end
	local function xp(a, b, finfo, minfo, now)
		local ac, bc = computeEquivXP(a, finfo, minfo), computeEquivXP(b, finfo, minfo)
		if ac == bc and ac > 0 then
			ac = computeEarliestCompletion(b, finfo, minfo, false, now)
			bc = computeEarliestCompletion(a, finfo, minfo, false, now)
		end
		if ac == bc then
			return success(a,b, finfo, minfo, now)
		end
		return ac > bc
	end
	function api.GroupRank.threats2(a, b, ...)
		local ac, bc = a[1], b[1]
		if ac == bc then
			ac, bc = a[3] * risk[a[1]], b[3] * risk[b[1]]
		end
		if ac == bc then
			ac, bc = a[9] * risk[a[1]], b[9] * risk[b[1]]
		end
		if ac == bc then
			return xp(a, b, ...)
		end
		return ac > bc
	end
	api.GroupRank.threats, api.GroupRank.resources, api.GroupRank.xp = success, res, xp
end
function api.GetMissionDefaultGroupRank(mi)
	local rew = api.HasSignificantRewards(mi)
	local key = rew == false and "xp" or (rew == "resource" or rew == "gold") and "resources" or "threats"
	return api.GroupRank[key], key
end
function api.GroupFilter.IDLE(res, finfo, minfo)
	local mid = minfo.missionID
	for i=5,4+minfo.numFollowers do
		local fi = finfo[res[i]]
		if not (fi and (fi.status == nil or fi.status == GARRISON_FOLLOWER_IN_PARTY) and not T.config.ignore[fi.followerID] and not dropFollowers[fi.followerID] and (MasterPlan:GetFollowerTentativeMission(fi.followerID) or mid) == mid) then
			return false
		end
	end
	return true
end
function api.GroupFilter.AWAY(res, finfo, minfo)
	local r = false
	for i=5,4+minfo.numFollowers do
		local fi = finfo[res[i]]
		local st, id = fi and fi.status, fi and fi.followerID
		if not fi or T.config.ignore[id] or not (st == nil or st == GARRISON_FOLLOWER_IN_PARTY or st == GARRISON_FOLLOWER_ON_MISSION) then
			return false
		end
		r = r or st == GARRISON_FOLLOWER_ON_MISSION or dropFollowers[id]
	end
	return r
end
function api.GroupFilter.ACTIVE(res, finfo, minfo)
	for i=5,4+minfo.numFollowers do
		local fi = finfo[res[i]]
		if not (fi and fi.status ~= GARRISON_FOLLOWER_INACTIVE and not T.config.ignore[fi.followerID]) then
			return false
		end
	end
	return true
end
do -- HasSignificantRewards(minfo)
	local cache = {}
	function api.HasSignificantRewards(mi)
		local mid = mi.missionID
		local ret = cache[mid]
		if ret ~= nil then
		elseif mi.rewards then
			local allGR, allXP, over, gold = true, true, T.XPMissions[mid]
			if over then
				allGR, gold = false, over
			else
				for _, r in pairs(mi.rewards) do
					if r.currencyID == 0 then
						gold = r.quantity
					elseif not r.followerXP then
						allXP = false
					end
					if r.currencyID ~= GARRISON_CURRENCY then
						allGR = false
					end
				end
			end
			ret = allGR and not allXP and "resource" or (gold and gold > T.config.goldRewardThreshold and "gold") or not allXP
		else
			ret = false
		end
		cache[mid] = ret
		return ret
	end
	cacheTables[#cacheTables+1] = cache
end
do -- api.GetSuggestedGroups(mi, onlyBackfill, f1, f2, f3)
	local function SetGroup(_, group)
		local mi = GarrisonMissionFrame.MissionTab.MissionPage.missionInfo
		GarrisonMissionPage_ClearParty()
		for i=1,mi.numFollowers do
			GarrisonMissionPage_AddFollower(group[4+i])
		end
	end
	local function SecondsToTime(sec)
		local m, s, out = (sec % 3600) / 60, sec % 60
		if sec >= 3600 then out = HOUR_ONELETTER_ABBR:format(sec/3600) end
		if m > 0 then out = (out and out .. " " or "") .. MINUTE_ONELETTER_ABBR:format(m) end
		if s > 0 then out = (out and out .. " " or "") .. SECOND_ONELETTER_ABBR:format(s) end
		return out or ""
	end
	local function ShowGroupTip(self, g, mi)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		api.SetGroupTooltip(GameTooltip, g, mi)
		GameTooltip:Show()
	end
	local function addToMenu(mm, groups, mi)
		local primary = mi._primaryGoal or select(2, api.GetMissionDefaultGroupRank(mi))
		mi._primaryGoal = primary
		
		for i=1,#groups do
			local gi = groups[i]
			local sc, xp, res, text = gi[1] .. "%"
			if gi.expectedXP and gi.expectedXP > 0 then
				local exp = BreakUpLargeNumbers(floor(gi.expectedXP))
				xp = (L"%s XP"):format(exp)
			end
			if gi[1] and gi[1] > 0 and gi[3] and gi[3] > 0 then
				res = floor(gi[1]*gi[3]/100) .. " |TInterface\\Garrison\\GarrisonCurrencyIcons:20:20:0:-2:128:128:12:52:12:52|t"
			end
			if (primary == "xp" and xp) or (primary == "resources" and res) then
				text = (primary == "xp" and xp or res) .. "; " .. sc .. (primary == "resources" and xp and "; " .. xp or "")
			else
				text = sc .. (xp and "; " .. xp or "")
			end
			text = text .. "; " .. SecondsToTime(gi[4])
			
			mm[#mm+1] = { text = text, notCheckable=true, tooltipOnButton=ShowGroupTip, func=SetGroup, arg1=gi, arg2=mi}
		end
	end
	local function extend(g, mi, rt, f1, f2, f3)
		local best = 0
		if type(g) ~= "table" then g = {} end
		for i=1,g and #g or 0 do
			if g[i][1] and g[i][1] > best then
				best = g[i][1]
			end
		end
		if best < 100 then
			local bg = api.GetBackfillMissionGroups(mi, api.GroupFilter.IDLE, api.GroupRank[rt == "xp" and "threats2" or "threats"], 1, f1, f2, f3)
			if bg and bg[1] and bg[1][1] > best then
				g[#g + 1] = bg[1]
			end
		end
		return g
	end
	function api.GetSuggestedGroups(mi, onlyBackfill, f1, f2, f3)
		local mm, sg = {}
		local rank, rt = api.GetMissionDefaultGroupRank(mi)
		if not onlyBackfill then
			sg = api.GetFilteredMissionGroups(mi, api.GroupFilter.IDLE, rank, 3)
			sg = extend(sg, mi, rt)
		elseif (f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0) == mi.numFollowers then
			sg = api.GetBackfillMissionGroups(mi, api.GroupFilter.IDLE, rank, 1, f1, f2, f3)
		end
		if sg and #sg > 0 then
			mm[1] = {text=L"Suggested groups", isTitle=true, notCheckable=true}
			addToMenu(mm, sg, mi)
		end
		local fc = (f1 and 1 or 0) + (f2 and 1 or 0) + (f3 and 1 or 0)
		if fc < mi.numFollowers and fc > 0 then
			local g3 = api.GetBackfillMissionGroups(mi, api.GroupFilter.IDLE, rank, 3, f1, f2, f3)
			g3 = extend(g3, mi, rt, f1, f2, f3)
			if #g3 > 0 then
				mm[#mm+1] = {text = L"Complete party", isTitle=true, notCheckable=true}
				addToMenu(mm, g3, mi)
			end
		end
		return mm
	end
end

do -- api.GetUpgradeItems(ilevel, isArmor)
	local cap = FOLLOWER_ITEM_LEVEL_CAP
	local upgrades = {
		WEAPON={114128, cap, 114129, cap-3, 114131, cap-6, 114616, 615, 114081, 630, 114622, 645},
		ARMOR={114745, cap, 114808, cap-3, 114822, cap-6, 114807, 615, 114806, 630, 114746, 645}
	}
	local function walk(ilvl, t, pos)
		for i=pos,#t,2 do
			if t[i+1] > ilvl and GetItemCount(t[i]) > 0 then
				return t[i], walk(ilvl, t, i + 2)
			end
		end
	end
	function api.GetUpgradeItems(ilevel, isWeapon)
		return walk(ilevel, isWeapon and upgrades.WEAPON or upgrades.ARMOR, 1)
	end
end
function api.ExtendMissionInfoWithXPRewardData(mi, force)
	local bmul, base, extra, mentor, bonus
	if not force then
		bmul, base, extra, mentor, bonus = mi.groupXPBuff, mi.baseXP, mi.extraXP, mi.mentorLevel, mi.bonusXP
	end
	if bmul == nil or extra == nil then
		local _, _, _, sc, pb, _, exp = C_Garrison.GetPartyMissionInfo(mi.missionID)
		bmul, extra, mi.successChance = api.GetBuffsXPMultiplier(pb), exp, mi.successChance or sc
	end
	if base == nil then
		_, base = C_Garrison.GetMissionInfo(mi.missionID)
	end
	if mentor == nil then
		local _, milvl = C_Garrison.GetPartyMentorLevels(mi.missionID)
		mentor = (milvl or 0) > 0 and milvl
	end
	if bonus == nil then
		bonus = 0
		for k,v in pairs(mi.rewards) do
			if v.followerXP then bonus = bonus + v.followerXP end
		end
	end
	mi.groupXPBuff, mi.baseXP, mi.extraXP, mi.bonusXP, mi.mentorLevel = bmul, base, extra, bonus, mentor
	return bmul, base, extra, bonus, mentor
end
function api.ExtendFollowerTooltipProjectedRewardXP(mi, fi)
	local tip = GarrisonFollowerTooltip
	if mi and fi and tip:IsShown() and tip.XPBarBackground:IsShown() then
		local bmul, base, extraXP, bonus, mentor = api.ExtendMissionInfoWithXPRewardData(mi)
		if base and extraXP and bmul and fi.levelXP then
			local base, bonus = api.GetFollowerXPGain(fi, api.GetFMLevel(mi), extraXP + base, bonus * bmul, mentor)
			local toLevel, wmul = fi.levelXP - fi.xp, tip.XPBarBackground:GetWidth()/fi.levelXP
			tip.XPBarBackground:SetTexture(0.25, 0.25, 0.25)
			if tip.XPBar:IsShown() then
				tip.XPRewardBase:SetPoint("TOPLEFT", tip.XPBar, "TOPRIGHT")
				tip.XPRewardBase:SetPoint("BOTTOMLEFT", tip.XPBar, "BOTTOMRIGHT")
			else
				tip.XPRewardBase:SetPoint("TOPLEFT", tip.XPBarBackground, "TOPLEFT")
				tip.XPRewardBase:SetPoint("BOTTOMLEFT", tip.XPBarBackground, "BOTTOMLEFT")
			end
			tip.XPRewardBase:SetWidth(math.max(0.01, math.min(toLevel, base)*wmul))
			tip.XPRewardBonus:SetWidth(math.max(0.01, math.min(toLevel-base, bonus)*wmul))
			tip.XPRewardBonus:SetShown(bonus > 0 and toLevel > base)
			tip.XPRewardBase:SetShown(base > 0)
			if base > 0 then
				local xpt = "|cff99ff00" .. BreakUpLargeNumbers(floor(base)) .. "|r"
				if bonus > 0 then xpt = xpt .. "+|cff00bfff" .. BreakUpLargeNumbers(floor(bonus)) .. "|r" end
				local toDing = fi.levelXP - fi.xp
				local baseText = BreakUpLargeNumbers(toDing)
				if toDing <= floor(base) then
					baseText = "|cff99ff00" .. baseText .. "|r"
				elseif toDing <= floor(base + bonus) then
					baseText = "|cff00bfff" .. baseText .. "|r"
				end
				baseText = (fi.level == 100 and GARRISON_FOLLOWER_TOOLTIP_UPGRADE_XP or GARRISON_FOLLOWER_TOOLTIP_XP):gsub("%%[%d$]*d", "%%s"):format(baseText)
				tip.XP:SetText(baseText .. "|n" .. (L"Reward: %s XP"):format(xpt))
			end
		else
			tip.XPRewardBonus:Hide()
			tip.XPRewardBase:Hide()
		end
	end
end
function api.ExtendFollowerTooltipGainedXP(tip, awardXP, fi)
	if tip.XP:IsShown() and (awardXP or 0) > 0 then
		tip.XP:SetText(tip.XP:GetText() .. "|n|cff10ff10" .. (L"%s XP gained"):format(BreakUpLargeNumbers(awardXP)))
		if tip.XPGained and (fi and fi.levelXP or 0) > 0 then
			tip.XPGained:ClearAllPoints()
			tip.XPGained:SetPoint("TOPRIGHT", tip.XPBar)
			tip.XPGained:SetPoint("BOTTOMRIGHT", tip.XPBar)
			tip.XPGained:SetWidth(math.max(0.01, math.min(fi.xp, awardXP)*tip.XPBarBackground:GetWidth()/fi.levelXP))
			tip.XPGained:Show()
		end
	end
end

local function EvaluateGroup(mi, counters, traits, fa, fb, fc, scratch)
	local mlvl, tv, c, mc, umc = mi[1], mi[4] == 123858 and 3 or 6, mi[2] == 3, scratch or {}, false
	local nc, cap = traits[201]*2 + traits[202]*4, (#mi-5)*tv do
		local time, env = mi[3]*2^-traits[221], mi[5]
		nc = nc + (env == 13 and 1 or 2) * (traits[T.EnvironmentCounters[env]] or 0) + traits[(time >= 25200) and 76 or 77]*2 + traits[47]*6
		
		local lc, cn = mi[6], 1
		for i=7, #mi+1 do
			local c = mi[i]
			if c == lc then
				cn = cn + 1
			else
				local h = counters[lc] or 0
				if h < cn then
					mc[lc], umc = (cn - h)*tv, true
				end
				lc, cn, nc = c, 1, nc + tv * (h > cn and cn or h)
			end
		end
	end
	if nc < cap then
		local ra, rb, rc = fa.affinity or 0, fb.affinity, c and fc.affinity
		local sa, sb, sc = fa.saffinity, fb.saffinity, fc.saffinity
		if ra == rc or rb == rc then rc, sc = nil end
		if ra == rb or not rb then rb, sb, rc, sc = rc, sc end
		repeat
			local nt, nf = traits[ra] or 0, traits[-ra] or 0
			if nt == 0 or ra == 0 or nf == 0 then
			elseif nf > 1 then
				nc = nc + nt*3
			else
				nc = nc + (nt - (sa and 1 or 0))*3
			end
			ra, rb, sa, sb, rc = rb, rc, sb, sc
		until nc >= cap or not ra
	end
	if nc < cap and mc[6] then
		local h, l = 4*traits[232], mc[6]
		mc[6], nc = l > h and l - h or 0, nc + (h > l and l or h)
	end
	local amlvl, bmlvl, cmlvl = mlvl, mlvl, mlvl
	local mentorIndex = (traits[248] or 0) > 0 and (fa.garrFollowerID == MENTOR_FOLLOWER and 1 or fb.garrFollowerID == MENTOR_FOLLOWER and 2 or 3)

	if nc < cap then
		local la, lb, lc, lm, mx
		if mlvl >= 100 then
			la, lb, lc, lm, mx, mlvl = fa.iLevel, fb.iLevel, fc.iLevel, 15, FOLLOWER_ITEM_LEVEL_CAP, mlvl == 100 and 600 or mlvl
		else
			la, lb, lc, lm, mx = fa.level, fb.level, fc.level, 3, 100
		end
		local ga, gb, gc, toCap = 1, 1, 1, mx-mlvl
		for i=1,3 do
			for j=1,#fa.counters do
				local c = fa.counters[j]
				local v = mc[c] or 0
				ga = ga + (v > 2 and 2 or v) -- this can be very wrong
			end
			fa, fb, fc, ga, gb, gc = fb, fc, fa, gb, gc, ga
		end
		gc = c and gc or 0
		
		if mentorIndex then
			ga = ga + gb + gc
			ga, gb, gc = mentorIndex == 1 and ga or 0, mentorIndex == 2 and ga or 0, mentorIndex == 3 and ga or 0
		end
		
		local maxGain = (ga+gb+gc)*(toCap < lm and toCap/lm or 1)
		if cap-nc >= maxGain then
			nc, mlvl = nc + maxGain, mlvl + (toCap < lm and toCap or lm)
			amlvl, bmlvl, cmlvl = mlvl, mlvl, mlvl
		elseif maxGain > 0 then
			if toCap < lm then
				ga, gb, gc = ga * toCap, gb * toCap, gc * toCap
			else
				ga, gb, gc, mx = ga * lm, gb * lm, gc * lm, mlvl + lm
			end
			la = la < mlvl and mlvl or la > mx and mx or la
			lb = lb < mlvl and mlvl or lb > mx and mx or lb
			lc = c and (lc < mlvl and mlvl or lc > mx and mx or lc) or mx
			local cc, gap = ga*(lm+la-mx) + gb*(lm+lb-mx) + gc*(lm+lc-mx), (cap-nc)*lm*lm
			if cc < gap then
				local sa, sb, sc = 3,2,1
				if gb < gc then lb, lc, gb, gc, sb, sc = lc, lb, gc, gb, sc, sb end
				if ga < gb then la, lb, ga, gb, sa, sb = lb, la, gb, ga, sb, sa end
				if gb < gc then lb, lc, gb, gc, sb, sc = lc, lb, gc, gb, sc, sb end
				nc, gap = cap, gap - cc
				for i=1,3 do
					if ga > 0 then
						local t = ga*(mx-la)
						if gap <= t then
							gap, amlvl = 0, math.ceil(la + gap/ga)
						elseif gap > 0 then
							amlvl, gap = mx, gap - t
						end
					end
					ga, gb, gc, la, lb, lc, amlvl, bmlvl, cmlvl = gb, gc, ga, lb, lc, la, bmlvl, cmlvl, amlvl
				end
				if sb < sc then bmlvl, cmlvl, sb, sc = cmlvl, bmlvl, sc, sb end
				if sa < sb then amlvl, bmlvl, sa, sb = bmlvl, amlvl, sb, sa end
				if sb < sc then bmlvl, cmlvl, sb, sc = cmlvl, bmlvl, sc, sb end
			else
				amlvl, bmlvl, cmlvl, nc = la, lb, lc, cap
			end
		end
	end
	if mentorIndex then
		amlvl, bmlvl, cmlvl = mentorIndex == 1 and amlvl or 0, mentorIndex == 2 and bmlvl or 0, mentorIndex == 3 and cmlvl or 0
	end

	if umc and scratch then
		wipe(scratch)
	end
	
	local rp = 100
	if nc < cap then
		local ex = c and 6 or 4
		rp = (nc + ex) * 100 / (cap + ex)
		rp = rp - rp % 1
	end
	return rp, amlvl, bmlvl, cmlvl
end
function api.UpdateGroupEstimates(missions, useInactive, yield)
	local ft, nf, f, et = {}, 0, C_Garrison.GetFollowers(), T.EquivTrait
	for i=1,#f do
		local fi = f[i]
		if fi.isCollected and (useInactive or fi.status ~= GARRISON_FOLLOWER_INACTIVE) and not T.config.ignore[fi.followerID] then
			local cn, tn, fid, af = 1, 1, fi.followerID, T.Affinities[fi.garrFollowerID] or 0
			fi.counters, fi.traits, fi.affinity, nf = {}, {}, af, nf + 1
			if (af or 0) > 0 then
				fi.traits[tn], tn = -af, tn + 1
			end
			for i=1,3 do
				local a = C_Garrison.GetFollowerAbilityAtIndex(fid, i)
				a = a and a > 0 and C_Garrison.GetFollowerAbilityCounterMechanicInfo(a)
				if a then
					fi.counters[cn], cn = a, cn + 1
				end
				a = C_Garrison.GetFollowerTraitAtIndex(fid, i)
				a = et[a] or a
				if a and a > 0 then
					fi.traits[tn], tn, fi.saffinity = a, tn + 1, a == af or fi.saffinity or nil
				end
			end
			fi.cLevel = fi.level >= 100 and (fi.iLevel - 300) or ((fi.level-90)*30)
			ft[nf], fi.active, fi.working = fi, fi.status ~= GARRISON_FOLLOWER_INACTIVE and 1 or 0, fi.status == GARRISON_FOLLOWER_WORKING and 1 or 0
			if fi.quality == 5 then
				ft[nf], ft[1] = ft[1], fi
			end
		end
	end
	f = ft
	
	local ms, best = {}, {}
	for i=1,#missions do
		local mi = missions[i].s
		local sz = mi[2]
		local t = ms[sz] or {}
		t[#t+1], ms[sz], best[mi] = mi, t, {-1}
	end

	local counters, traits, m2, m3 = {[6]=0}, {[221]=0, [79]=0, [77]=0, [76]=0, [201]=0, [202]=0, [232]=0, [256]=0, [47]=0}, ms[2], ms[3]
	local n2, n3, s1, s2 = #m2, #m3, 17592186044416, 68719476736
	local totalGroups, consideredGroups, nf2, sct, ts = nf*(nf-1)*(nf+1)/6, 0, nf^2, {}, T.TraitStack
	if yield and yield(0, 0, 0) then return end

	for a=1,nf-1 do
		local fa = f[a]
		for i=1,2 do
			local s, t = fa[i == 1 and "counters" or "traits"], i == 1 and counters or traits
			for i=1,#s do
				local v = s[i]
				t[v] = (t[v] or 0) + 1
			end
		end
		local na, nw = fa.active, fa.working
					
		for b=a+1,nf do
			local fb = f[b]
			local na, nw = na + fb.active, nw + fb.working
			
			local mi, mic, c = m2, n2
			repeat
				local fc = f[c or b]
				for i=1,2 do
					local s, t = fc[i == 1 and "counters" or "traits"], i == 1 and counters or traits
					for i=1,#s do
						local v = s[i]
						t[v] = (t[v] or 0) + 1
					end
				end
				local na, nw = na + (c and fc.active or 0), 3 - nw - (c and fc.working or 0)

				for i=1, mic do
					local mi = mi[i]
					local rp, amlvl, bmlvl, cmlvl = EvaluateGroup(mi, counters, traits, fa, fb, fc, sct)
					local best, sc = best[mi], rp * s1
					if best[1] - sc < s1 then
						local la, lb, lc = fa.cLevel, fb.cLevel, fc.cLevel
						local ga, gb, gc = amlvl > 100 and (amlvl - 300) or ((amlvl-90)*30), bmlvl > 100 and (bmlvl - 300) or ((bmlvl-90)*30), c and (cmlvl > 100 and (cmlvl - 300) or ((cmlvl-90)*30)) or 0
						local gap = (ga > la and (ga - la) or 0) + (gb > lb and (gb - lb) or 0) + (gc > lc and (gc - lc) or 0)
						local hi, lo, ohi = sc + s2 * ((traits[ts[mi[4]]] or 0) * 16 + na * 4 + nw) + (32767-gap), traits[221], best[1]
						if hi >= ohi then
							if hi > ohi or lo > best[6] then
								best[1], best[2], best[3], best[4], best[5], best[6] = hi, a, b, c, amlvl + 1e3*bmlvl + (c and 1e6*cmlvl or 0), lo
							end
							if hi > ohi then
								best[7], best[8], best[9], best[10] = c and 3 or 2, a, b, c
							elseif best[7] > 0 then
								for i=8,10 do
									local fo = best[i]
									if fo and fo ~= a and fo ~= b and fo ~= c then
										best[7], best[i] = best[7] - 1
									end
								end
							end
						end
					end
				end
				
				for i=1,c and 2 or 0 do
					local s, t = fc[i == 1 and "counters" or "traits"], i == 1 and counters or traits
					for i=1,#s do
						local v = s[i]
						t[v] = t[v] - 1
					end
				end
				
				c, mi, mic, consideredGroups = (c or b) + 1, m3, n3, consideredGroups + 1
				if yield and consideredGroups % 50 == 0 and yield(1, consideredGroups, totalGroups) then return end
			until c > nf

			for i=1,2 do
				local s, t = fb[i == 1 and "counters" or "traits"], i == 1 and counters or traits
				for i=1,#s do
					local v = s[i]
					t[v] = t[v] - 1
				end
			end
		end
		
		for i=1,2 do
			local s, t = fa[i == 1 and "counters" or "traits"], i == 1 and counters or traits
			for i=1,#s do
				local v = s[i]
				t[v] = t[v] - 1
			end
		end
	end
	
	for i=1,#missions do
		local best = best[missions[i].s]
		if best and best[1] > 0 then
			wipe(counters) wipe(traits)
			local bt, mi = {nil, nil, nil, nil, floor(best[1]/s1), floor(best[5]), 0}, missions[i].s
			for i=1, mi[2] do
				local fi = f[best[1+i]]
				bt[i] = fi.followerID
				for i=1,2 do
					local s, t = fi[i == 1 and "counters" or "traits"], i == 1 and counters or traits
					for i=1,#s do
						local v = s[i]
						t[v] = (t[v] or 0) + 1
					end
				end
				if fi.garrFollowerID == MENTOR_FOLLOWER then
					bt.mentorLevel = floor(max(fi[fi.level > 99 and "iLevel" or "level"], best[5] % 1000^i / 1000^(i-1)))
				end
			end
			
			bt[4] = traits[ts[mi[4]]] or 0
			bt.used = (best[8] and 1 or 0) + (best[9] and 2 or 0) + (best[10] and 4 or 0)
			bt.ttrait, bt.dtrait = mi[3]*2^-(traits[221] or 0) >= 25200 and 76 or 77
			local lc, cn, h
			for i=6, #mi do
				local c = mi[i]
				if c == lc then
					cn = cn + 1
				else
					lc, cn, h = c, 1, counters[c] or 0
				end
				if c == 6 and traits[232] then
					local nh = h + traits[232]/2
					bt.dtrait, h = h < lc and (nh <= lc and 1 or 2) or nil, nh
				end
				bt[1+i] = (h >= cn + 1) and 2 or h >= cn or (h == cn-0.5 and (mi[4] == 123858 or 0.5) or nil)
			end
			missions[i].best = bt
		else
			missions[i].best = nil
		end
	end
	
	return true
end

local setModifierSensitiveTip do
	local func, owner, watching, a1, a2, a3, a4, a5
	local function watch()
		if watching:IsOwned(owner) then
			watching:ClearLines()
			func(watching, a1, a2, a3, a4, a5)
			watching:Show()
		else
			func, owner, watching, a1, a2, a3, a4, a5 = nil
			return "remove"
		end
	end
	function setModifierSensitiveTip(...)
		local owatching = watching
		func, watching, a1, a2, a3, a4, a5 = ...
		if watching then
			owner = watching:GetOwner()
			if not owatching then
				EV.RegisterEvent("MODIFIER_STATE_CHANGED", watch)
			end
		end
	end
end
local function addFollowerList(tip, info, finfo, mlvl, showInactive, thisMech, specDup)
	api.sortByFollowerLevels(info, finfo)
	for i=1,#info do
		if info[i] ~= specDup then
			local fi = finfo[info[i]]
			if not showInactive and fi.status == GARRISON_FOLLOWER_INACTIVE then
				tip:AddLine((L"+%d Inactive (hold ALT to view)"):format(#info-i+1), 1, 1/4, 0, 1)
				break
			end
			local p = specDup and select(4, api.CountUniqueRerolls(T.SpecCounters[fi.classSpec], info[i]))
			p = p and p .. " " or ""
			tip:AddDoubleLine(api.GetFollowerLevelDescription(info[i], mlvl, finfo[info[i]]), p .. api.GetOtherCounterIcons(finfo[info[i]], thisMech), 1,1,1)
		end
	end
end
function api.countFreeFollowers(f, finfo)
	local ret, finfo = 0, finfo or api.GetFollowerInfo()
	for i=1,f and #f or 0 do
		local st = finfo[f[i]].status
		if not (st == GARRISON_FOLLOWER_INACTIVE or st == GARRISON_FOLLOWER_WORKING or T.config.ignore[f[i]]) then
			ret = ret + 1
		end
	end
	return ret
end
function api.CountUniqueRerolls(counters, thisFollowerID)
	local finfo, c = api.GetFollowerInfo(), counters
	local dc, novel, inact = api.GetDoubleCounters(finfo), 0, 0
	
	for i=1,#c do
		for j=i+1, #c do
			local ft, ac, ic = dc[c[i]*100 + c[j]], 0, 0
			for i=1,ft and #ft or 0 do
				if ft[i] == thisFollowerID then
				elseif finfo[ft[i]].status ~= GARRISON_FOLLOWER_INACTIVE then
					ac = ac + 1
					break
				else
					ic = ic + 1
				end
			end
			if ac == 0 and ic == 0 then
				novel = novel + 1
			elseif ac == 0 then
				inact = inact + 1
			end
		end
	end
	
	local total = #c*(#c-1)/2
	local desc = inact > 0 and "|cffa8a8a8" .. (novel > 0 and "+" or "") .. inact .. "|r" or ""
	desc = (novel > 0 and "|cff20ff20" .. novel .. "|r" or "") .. desc .. "|cffffffff/" .. total
	return novel, inact, total, desc
end
function api.SetClassSpecTooltip(self, specId, specName, ab1, ab2)
	local fi
	if type(specId) == "table" then
		fi, specId, specName = specId, specId.classSpec, specId.className
	end
	
	local c = T.SpecCounters[specId]
	if not c then return end
	
	self:ClearLines()
	self:AddLine(specName or (ITEM_QUALITY_COLORS[4].hex .. L"Epic Ability"), 1,1,1)
	if not specName then
		self:AddLine(L"An additional random ability is unlocked when this follower reaches epic quality." .. "|n ", 1,1,1, 1)
	end
	self:AddLine(L"Potential counters:")
	
	local ci, finfo, dropCounter = api.GetCounterInfo(), api.GetFollowerInfo(), not ab2 and ab1 or nil
	for i=1,#c do
		if c[i] == dropCounter then
			dropCounter = nil
		else
			local _, name, ico = api.GetMechanicInfo(c[i])
			local counters = ci[c[i]]
			local freeCount, totalCount = api.countFreeFollowers(counters, finfo), counters and #counters or 0
			local counts = (freeCount > 0 and "|cff20ff20" .. freeCount or "0") .. "|r+|cffa8a8a8" .. (totalCount - freeCount)
			self:AddDoubleLine("|TInterface\\Buttons\\UI-Quickslot2:13:2:-1:0:64:64:31:32:31:32|t|T" .. ico .. ":0:0:0:0:64:64:5:59:5:59|t " .. name, counts, 1,1,1, 1,1,1)
		end
	end
	self:SetBackdropColor(0,0,0)
	
	local novel, inact, _, rerollDesc = api.CountUniqueRerolls(c, fi and fi.followerID)
	if novel > 0 or inact > 0 then
		self:AddDoubleLine(L"Unique ability rerolls:", rerollDesc)
	end
	
	if fi and fi.quality >= 4 and fi.isCollected then
		local a1, a2 = C_Garrison.GetFollowerAbilityAtIndex(fi.followerID, 1), C_Garrison.GetFollowerAbilityAtIndex(fi.followerID, 2)
		a1, a2 = C_Garrison.GetFollowerAbilityCounterMechanicInfo(a1), C_Garrison.GetFollowerAbilityCounterMechanicInfo(a2)
		local sd = api.GetDoubleCounters()[a1 < a2 and (a1 * 100 + a2) or (a2 * 100 + a1)]
		if sd and #sd > 1 then
			self:AddLine(" ")
			self:AddLine(L"Duplicate counters" .. ":")
			addFollowerList(self, sd, finfo, nil, true, nil, fi.followerID)
		end
	end
	
	return true
end
function api.SetTraitTooltip(tip, id, info, showInactive)
	if not showInactive then setModifierSensitiveTip(api.SetTraitTooltip, tip, id, info) end
	local finfo, showInactive = api.GetFollowerInfo(), showInactive or IsShiftKeyDown() or IsAltKeyDown()
	local ico = "|T" .. C_Garrison.GetFollowerAbilityIcon(id) .. ":0:0:0:0:64:64:4:60:4:60|t "
	tip:ClearLines()
	tip:AddLine(ico .. C_Garrison.GetFollowerAbilityName(id))
	tip:AddLine(C_Garrison.GetFollowerAbilityDescription(id), 1,1,1, 1)
	if info == nil then info = api.GetFollowerTraits()[id] end
	if info and #info > 0 then
		tip:AddLine("|n" .. L"Followers with this trait:", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		addFollowerList(tip, info, finfo, nil, showInactive)
	else
		tip:AddLine("|n" .. L"You have no followers with this trait.", 1,0.50,0, 1)
	end
	info = info and info.affine
	if not info then
	elseif info == true or #info == 0 then
		tip:AddLine("|n" .. L"You have no followers who activate this trait.", 1,0.50,0, 1)
	else
		tip:AddLine("|n" .. L"Followers activating this trait:", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		addFollowerList(tip, info, finfo, nil, showInactive)
	end
end
function api.SetThreatTooltip(tip, id, info, missionLevel, showInactive)
	if not showInactive then setModifierSensitiveTip(api.SetThreatTooltip, tip, id, info, missionLevel) end
	local finfo, showInactive = api.GetFollowerInfo(), showInactive or IsShiftKeyDown() or IsAltKeyDown()
	local id, name, ico, desc = api.GetMechanicInfo(id)
	tip:ClearLines()
	tip:AddLine("|T" .. ico .. ":0:0:0:0:64:64:4:60:4:60|t " .. name)
	tip:AddLine(desc or "", 1,1,1, 1)
	if info == nil then info = api.GetCounterInfo()[id] end
	if info and #info > 0 then
		tip:AddLine("|n" .. L"Can be countered by:", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		addFollowerList(tip, info, finfo, missionLevel, showInactive, id)
	else
		tip:AddLine("|n" .. L"You have no followers to counter this mechanic.", 1,0.50,0, 1)
	end
end
local prefixTip do
	local hooked = {}
	local function writePrefix(self)
		local t = hooked[self]
		GameTooltip_ClearMoney(self)
		GameTooltip_ClearInsertedFrames(self)
		if t and t[1] then
			self:AddLine(t[1],t[2],t[3],t[4])
			t[1],t[2],t[3],t[4] = nil
		end
	end
	function prefixTip(tip, text, r,g,b)
		local t = hooked[tip] or {}
		t[1],t[2],t[3],t[4] = text, r, g, b
		tip:SetText("?")
		if not hooked[tip] then
			tip:HookScript("OnTooltipCleared", writePrefix)
			hooked[tip] = t
		end
	end
end
function api.SetItemTooltip(tip, id)
	local cs = T.TokenSlots[id]
	tip:SetItemByID(id)
	if cs then
		setModifierSensitiveTip(api.SetItemTooltip, tip, id)
		local st1, st2 = tip.shoppingTooltips[1], tip.shoppingTooltips[2]
		if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
			local ofsFrame, oy = GameTooltip, -8
			if GetInventoryItemID("player", cs) then
				st1:SetOwner(tip, "ANCHOR_NONE")
				st1:SetPoint("TOPRIGHT", tip, "TOPLEFT", -2, oy)
				prefixTip(st1, CURRENTLY_EQUIPPED, 0.5, 0.5, 0.5)
				st1:SetInventoryItem("player", cs)
				st1:Show()
				ofsFrame, oy = st1, 0
			end
			if cs > 10 and GetInventoryItemID("player", cs+1) then
				st2:SetOwner(GameTooltip, "ANCHOR_NONE")
				st2:SetPoint("TOPRIGHT", ofsFrame, "TOPLEFT", -2, oy)
				prefixTip(st2, CURRENTLY_EQUIPPED, 0.5, 0.5, 0.5)
				st2:SetInventoryItem("player", cs+1)
				st2:Show()
			end
		else
			st1:Hide()
			st2:Hide()
		end
	end
end
function api.SetGroupTooltip(tip, g, mi)
	tip:SetText(g[1] .. "% |cffc0c0c0(" .. SecondsToTime(g[4]) .. ")")
	local finfo, ml = api.GetFollowerInfo(), api.GetFMLevel(mi)
	for i=1,mi.numFollowers do
		tip:AddLine(api.GetFollowerLevelDescription(g[4+i], ml, finfo[g[4+i]], g[10], mi.missionID))
	end
	local _, exp = api.GetMissionGroupXP(g, mi)
	if (exp or 0) > 0 then
		local exp = BreakUpLargeNumbers(floor(exp))
		tip:AddLine((L"+%s experience expected"):format(exp))
	end
	if g[3] > 0 or g[9] > 0 then
		local r = g[3] > 0 and g[3] .. " |TInterface\\Garrison\\GarrisonCurrencyIcons:14:14:0:0:128:128:12:52:12:52|t" or GetMoneyString(g[9])
		tip:AddLine(REWARDS .. ": |cffffffff" .. r) --TODO
	end
end
function api.SetDoubleCountersTooltip(tip, ci)
	setModifierSensitiveTip(api.SetDoubleCountersTooltip, tip, ci)
	local showInactive = IsAltKeyDown()
	tip:AddLine("|TInterface\\Icons\\Inv_Misc_Book_11:0:0:0:0:64:64:4:60:4:60|t " .. L"Duplicate counters")
	local finfo, skip, oico = api.GetFollowerInfo(), 0
	for i=1,ci and #ci or 0 do
		local ico = api.GetOtherCounterIcons(finfo[ci[i]])
		local show = showInactive or (ico == oico and finfo[ci[i]].status ~= GARRISON_FOLLOWER_INACTIVE)
		if not show and ico ~= oico and ci[i+1] then
			show = finfo[ci[i+1]].status ~= GARRISON_FOLLOWER_INACTIVE
			oico = ico
		end
		if show then
			tip:AddDoubleLine(api.GetFollowerLevelDescription(ci[i], nil, finfo[ci[i]]), ico, 1,1,1)
		else
			skip = skip + 1
		end
	end
	if skip > 0 then
		tip:AddLine((L"+%d Inactive (hold ALT to view)"):format(skip), 1, 1/4, 0, 1)
	elseif (ci and #ci or 0) == 0 then
		tip:AddLine(L"You have no followers with duplicate counter combinations.", 1,1,1, 1)
	end
end


do -- api.GetResourceCacheInfo
	local STEP_INTERVAL, STEP_SIZE, STORE_CEIL, STORE_FLOOR = 600, 1, 500, 10
	local function get()
		return MasterPlanA.data.lastCacheTime
	end
	function api.GetResourceCacheInfo()
		local lt = securecall(get) or 0
		if lt > 0 then
			local cur = min(STORE_CEIL, floor((time()-lt)/STEP_INTERVAL)*STEP_SIZE)
			return cur < STORE_FLOOR and 0 or cur, STORE_CEIL, lt, STORE_CEIL/STEP_SIZE*STEP_INTERVAL
		end
	end
end

T.Garrison = api