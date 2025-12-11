local W, F, L = unpack(select(2, ...))
local KT = W:NewModule("KeystoneTooltip", "AceHook-3.0")
local KI = W:GetModule("KeystoneInfo")
local C = W.Utilities.Color

local _G = _G
local format = format

local GenerateClosure = GenerateClosure
local UnitIsPlayer = UnitIsPlayer

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local function IsWindToolsLoaded()
	if C_AddOns_IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if
			E
			and E.db
			and E.db.WT
			and E.db.WT.tooltips
			and E.db.WT.tooltips.keystone
			and E.db.WT.tooltips.keystone.enable
		then
			return true
		end
	end
end

function KT:Handler(tt)
	if tt ~= _G.GameTooltip or tt:IsForbidden() then
		return
	end

	local db = self.db

	if not db or not db.enable or IsWindToolsLoaded() then
		return
	end

	local _, unit = tt:GetUnit()
	if not unit or not UnitIsPlayer(unit) then
		return
	end

	local data = KI:UnitData(unit)
	if not data or not data.challengeMapID or not data.level then
		return
	end

	local mythicPlusMapData = W:GetMythicPlusMapData()

	local mapData = data.challengeMapID and mythicPlusMapData[data.challengeMapID]
	if not mapData then
		return
	end

	local right = C.StringWithKeystoneLevel(
		format("%s (%d)", db.useAbbreviation and mapData.abbr or mapData.name, data.level),
		data.level
	)

	if db.icon and db.iconHeight and db.iconWidth then
		right = F.GetIconString(mapData.tex, db.iconHeight, db.iconWidth, true) .. " " .. right
	end

	tt:AddDoubleLine(L["Keystone"], right)
end

function KT:ProfileUpdate()
	self.db = W.db.keystoneTooltip

	if self.db and self.db.enable and not self.initialized then
		TooltipDataProcessor_AddTooltipPostCall(Enum_TooltipDataType_Unit, GenerateClosure(self.Handler, self))
	end
end

KT.OnInitialize = KT.ProfileUpdate
