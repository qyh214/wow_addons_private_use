local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local collectgarbage = collectgarbage
local tremove, tinsert, sort, wipe, type = tremove, tinsert, sort, wipe, type
local ipairs, pairs, floor, format, strmatch = ipairs, pairs, floor, format, strmatch

local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetAvailableBandwidth = GetAvailableBandwidth
local GetBackgroundLoadingStatus = GetBackgroundLoadingStatus
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetDownloadedPercentage = GetDownloadedPercentage
local GetFileStreamingStatus = GetFileStreamingStatus
local GetFramerate = GetFramerate
local GetNetIpTypes = GetNetIpTypes
local GetNetStats = GetNetStats
local GetNumAddOns = GetNumAddOns
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local SetCVar = SetCVar
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

local UNKNOWN = UNKNOWN

local statusColors = {
	'|cff0CD809',
	'|cffE8DA0F',
	'|cffFF9000',
	'|cffD80909'
}

local enteredFrame, db = false
local bandwidthString = '%.2f Mbps'
local percentageString = '%.2f%%'
local homeLatencyString = '%d ms'
local kiloByteString = '%d kb'
local megaByteString = '%.2f mb'
local profilingString = '%s%s|r |cffffffff/|r %s%s|r'
local cpuProfiling = GetCVar('scriptProfile') == '1'

local CombineAddOns = {
	['DBM-Core'] = '^<DBM>',
	['DataStore'] = '^DataStore',
	['Altoholic'] = '^Altoholic',
	['AtlasLoot'] = '^AtlasLoot',
	['Details'] = '^Details!',
	['RaiderIO'] = '^RaiderIO',
	['BigWigs'] = '^BigWigs',
}

local function formatMem(memory)
	if memory >= 1024 then
		return format(megaByteString, memory / 1024)
	else
		return format(kiloByteString, memory)
	end
end

local infoTable = {}
DT.SystemInfo = infoTable

local function BuildAddonList()
	local addOnCount = GetNumAddOns()
	if addOnCount == #infoTable then return end

	wipe(infoTable)

	for i = 1, addOnCount do
		local name, title, _, loadable, reason = GetAddOnInfo(i)
		if loadable or reason == 'DEMAND_LOADED' then
			tinsert(infoTable, {name = name, index = i, title = title})
		end
	end
end

local function OnClick()
	local shiftDown, ctrlDown = IsShiftKeyDown(), IsControlKeyDown()
	if shiftDown and ctrlDown then
		SetCVar('scriptProfile', GetCVarBool('scriptProfile') and 0 or 1)
		ReloadUI()
	elseif shiftDown and not ctrlDown then
		collectgarbage('collect')
		ResetCPUUsage()
	end
end

local function displayData(data, totalMEM, totalCPU)
	if not data then return end

	local name, mem, cpu = data.title, data.mem, data.cpu
	if cpu then
		local memRed, cpuRed = mem / totalMEM, cpu / totalCPU
		local memGreen, cpuGreen = (1 - memRed) + .5, (1 - cpuRed) + .5
		DT.tooltip:AddDoubleLine(name, format(profilingString, E:RGBToHex(memRed, memGreen, 0), formatMem(mem), E:RGBToHex(cpuRed, cpuGreen, 0), format(homeLatencyString, cpu)), 1, 1, 1)
	else
		local red = mem / totalMEM
		local green = (1 - red) + .5
		DT.tooltip:AddDoubleLine(name, formatMem(mem), 1, 1, 1, red or 1, green or 1, 0)
	end
end

local function displaySort(a, b)
	return a.sort > b.sort
end

local infoDisplay, ipTypes = {}, {'IPv4', 'IPv6'}
local function OnEnter(_, slow)
	DT.tooltip:ClearLines()
	enteredFrame = true

	local _, _, homePing, worldPing = GetNetStats()
	DT.tooltip:AddDoubleLine(L["Home Latency:"], format(homeLatencyString, homePing), .69, .31, .31, .84, .75, .65)
	DT.tooltip:AddDoubleLine(L["World Latency:"], format(homeLatencyString, worldPing), .69, .31, .31, .84, .75, .65)

	if GetCVarBool('useIPv6') then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		DT.tooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
	end

	local Downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if Downloading then
		DT.tooltip:AddDoubleLine(L["Bandwidth"] , format(bandwidthString, GetAvailableBandwidth()), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["Download"] , format(percentageString, GetDownloadedPercentage() * 100), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddLine(' ')
	end

	if slow == 1 or not slow then
		UpdateAddOnMemoryUsage()
	end

	if cpuProfiling and not slow then
		UpdateAddOnCPUUsage()
	end

	wipe(infoDisplay)

	local count, totalMEM, totalCPU = 0, 0, 0
	local showByCPU = cpuProfiling and not IsShiftKeyDown()
	for _, data in ipairs(infoTable) do
		local i = data.index
		if IsAddOnLoaded(i) then
			local mem = GetAddOnMemoryUsage(i)
			totalMEM = totalMEM + mem

			local cpu
			if cpuProfiling then
				cpu = GetAddOnCPUUsage(i)
				totalCPU = totalCPU + cpu
			end

			data.sort = (showByCPU and cpu) or mem
			data.cpu = showByCPU and cpu
			data.mem = mem

			count = count + 1
			infoDisplay[count] = data

			if data.name == 'ElvUI' or data.name == 'ElvUI_Options' or data.name == 'ElvUI_Libraries' then
				infoTable[data.name] = data
			end
		end
	end

	DT.tooltip:AddDoubleLine(L["AddOn Memory:"], formatMem(totalMEM), .69, .31, .31, .84, .75, .65)
	if cpuProfiling then
		DT.tooltip:AddDoubleLine(L["Total CPU:"], format(homeLatencyString, totalCPU), .69, .31, .31, .84, .75, .65)
	end

	DT.tooltip:AddLine(' ')
	if not db.ShowOthers then
		displayData(infoTable.ElvUI, totalMEM, totalCPU)
		displayData(infoTable.ElvUI_Options, totalMEM, totalCPU)
		displayData(infoTable.ElvUI_Libraries, totalMEM, totalCPU)
		DT.tooltip:AddLine(' ')
	else
		for addon, searchString in pairs(CombineAddOns) do
			local addonIndex, memoryUsage, cpuUsage = 0, 0, 0
			for i, data in pairs(infoDisplay) do
				if data and data.name == addon then
					cpuUsage = data.cpu or 0
					memoryUsage = data.mem
					addonIndex = i
					break
				end
			end

			for k, data in pairs(infoDisplay) do
				if type(data) == 'table' then
					local name, mem, cpu = data.title, data.mem, data.cpu
					local stripName = E:StripString(data.title)
					if name and (strmatch(stripName, searchString) or data.name == addon) then
						if data.name ~= addon and stripName ~= addon then
							memoryUsage = memoryUsage + mem
							if showByCPU and cpuProfiling then
								cpuUsage = cpuUsage + cpu
							end

							infoDisplay[k] = false
						end
					end
				end
			end

			local data = addonIndex > 0 and infoDisplay[addonIndex]
			if data then
				local mem = memoryUsage > 0 and memoryUsage
				local cpu = cpuUsage > 0 and cpuUsage

				if mem then data.mem = mem end
				if cpu then data.cpu = cpu end
				if mem or cpu then
					data.sort = (showByCPU and cpu) or mem
				end
			end
		end

		for i = count, 1, -1 do
			local data = infoDisplay[i]
			if type(data) == 'boolean' then
				tremove(infoDisplay, i)
			end
		end

		sort(infoDisplay, displaySort)

		for i = 1, count do
			displayData(infoDisplay[i], totalMEM, totalCPU)
		end

		DT.tooltip:AddLine(' ')
		if showByCPU then
			DT.tooltip:AddLine(L["(Hold Shift) Memory Usage"])
		end
	end

	DT.tooltip:AddLine(L["(Shift Click) Collect Garbage"])
	DT.tooltip:AddLine(L["(Ctrl & Shift Click) Toggle CPU Profiling"])
	DT.tooltip:Show()
end

local function OnLeave()
	enteredFrame = false
end

local wait, count = 10, 0 -- initial delay for update (let the ui load)
local function OnUpdate(self, elapsed)
	wait = wait - elapsed

	if wait < 0 then
		wait = 1

		local framerate = floor(GetFramerate())
		local _, _, homePing, worldPing = GetNetStats()
		local latency = db.latency == 'HOME' and homePing or worldPing

		local fps = framerate >= 30 and 1 or (framerate >= 20 and framerate < 30) and 2 or (framerate >= 10 and framerate < 20) and 3 or 4
		local ping = latency < 150 and 1 or (latency >= 150 and latency < 300) and 2 or (latency >= 300 and latency < 500) and 3 or 4
		self.text:SetFormattedText(db.NoLabel and '%s%d|r | %s%d|r' or 'FPS: %s%d|r MS: %s%d|r', statusColors[fps], framerate, statusColors[ping], latency)

		if not enteredFrame then return end

		if InCombatLockdown() then
			if count > 3 then
				OnEnter(self)
				count = 0
			else
				OnEnter(self, count)
				count = count + 1
			end
		else
			OnEnter(self)
		end
	end
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

DT:RegisterDatatext('System', nil, nil, BuildAddonList, OnUpdate, OnClick, OnEnter, OnLeave, L["System"], nil, ApplySettings)
