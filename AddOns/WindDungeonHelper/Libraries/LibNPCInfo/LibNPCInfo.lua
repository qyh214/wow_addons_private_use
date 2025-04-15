local _G = _G
local major = "LibNPCInfo"
local minor = 4

local lib = _G.LibStub:NewLibrary(major, minor)
if not lib then
	return
end

local format = format
local ipairs = ipairs
local tinsert = tinsert
local type = type

local CreateFrame = CreateFrame
local GetTime = GetTime

local C_Timer_After = C_Timer.After
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local SCAN_TIMEOUT = 0.34
local cache = {}
local scanQueue = {}
local scanTooltipsPool = {}

local function DataHandler(self, data)
	if not self.__LIBNPCINFO or not data or not data.guid then
		return
	end

	local npcID = select(6, strsplit("-", data.guid))

	if not npcID or npcID == "" then
		return
	end

	if data.lines and #data.lines >= 2 then
		local name = data.lines[1].leftText
		local desc = data.lines[2].leftText

		if name and desc and name ~= "" then
			cache[npcID] = {
				id = tonumber(npcID),
				name = name,
				desc = desc,
			}

			if self.callback then
				self.callback(cache[npcID])
			end
		end
	end

	scanQueue[self.npcID] = nil
	self.__LIBNPCINFO = nil
	self.callback = nil
	self.npcID = nil
end

local function FindTimeoutTooltip()
	local now = GetTime()
	for _, tt in ipairs(scanTooltipsPool) do
		if not tt.npcID or not tt.lastUpdate or now - tt.lastUpdate > SCAN_TIMEOUT + 1 then
			return tt
		end
	end
end

local function GetNewTooltip()
	local tt = CreateFrame(
		"GameTooltip",
		"LibNPCInfoScanTooltip" .. (#scanTooltipsPool + 1),
		_G.UIParent,
		"GameTooltipTemplate"
	)

	tt:Show()
	tt:SetHyperlink("unit:")

	TooltipDataProcessor_AddTooltipPostCall(Enum_TooltipDataType_Unit, DataHandler)

	tinsert(scanTooltipsPool, tt)
	return tt
end

---GetNPCInfoByID
---@param npcID number
---@param callback? fun(npcInfo: table{id:number, name:string, desc:string})
---@param failedCallback? fun(npcID: number)
---@param printFunction? fun(msg: string)
---@return "start"|"scanning"|table{id:number, name:string, desc:string}|nil
function lib.GetNPCInfoByID(npcID, callback, failedCallback, printFunction)
	if not npcID then
		if printFunction then
			printFunction("LibNPCInfo: npcID is nil.")
		end
		return
	end

	if type(npcID) ~= "number" or callback and type(callback) ~= "function" then
		if printFunction then
			printFunction('LibNPCInfo: "npcID" must be a number and "callback" must be a function or nil.')
		end
		return
	end

	if cache[npcID] then
		return callback and callback(cache[npcID]) or cache[npcID]
	end

	if scanQueue[npcID] then
		return "scanning"
	end

	local tt = FindTimeoutTooltip() or GetNewTooltip()
	tt.lastUpdate = GetTime()
	tt.callback = callback
	tt.npcID = npcID
	scanQueue[npcID] = tt

	tt:SetOwner(_G.UIParent, "ANCHOR_NONE")
	tt.__LIBNPCINFO = true

	-- once
	tt:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", npcID))

	-- twice
	C_Timer_After(SCAN_TIMEOUT, function()
		if tt.npcID == npcID then
			tt:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", npcID))
			tt.lastUpdate = GetTime()
		end
	end)

	-- failed
	C_Timer_After(SCAN_TIMEOUT * 2, function()
		if tt.npcID == npcID then
			scanQueue[npcID] = nil
			tt.__LIBNPCINFO = nil

			C_Timer_After(0.01, function()
				if cache[npcID] then
					return callback and callback(cache[npcID]) or cache[npcID]
				end

				if failedCallback then
					failedCallback(npcID)
				else
					if printFunction then
						printFunction("LibNPCInfo: failed to fetch data for npcID " .. npcID)
					end
				end
			end)

			tt.callback = nil
			tt.npcID = nil
			tt.lastUpdate = nil
		end
	end)

	return "start"
end

---GetNPCInfoWithIDTable
---@param npcIDs table<number>
---@param callback? fun(npcInfo: table{id:number, name:string, desc:string})
---@param printFunction? fun(msg: string)
function lib.GetNPCInfoWithIDTable(npcIDs, callback, printFunction)
	if not npcIDs then
		if printFunction then
			printFunction("LibNPCInfo: npcIDs is nil.")
		end
		return
	end

	if type(npcIDs) ~= "table" or callback and type(callback) ~= "function" then
		if printFunction then
			printFunction('LibNPCInfo: "npcIDs" must be a table and "callback" must be a function or nil.')
		end
		return
	end

	local numDone = 0
	local numTotal = #npcIDs

	local function findNextAndStartScan()
		numDone = numDone + 1
		if numDone > numTotal then
			return
		end

		lib.GetNPCInfoByID(npcIDs[numDone], function(...)
			callback(...)
			findNextAndStartScan()
		end, function()
			findNextAndStartScan()
		end, printFunction)
	end

	findNextAndStartScan()
end
