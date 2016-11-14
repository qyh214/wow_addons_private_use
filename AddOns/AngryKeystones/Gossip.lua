local ADDON, Addon = ...
local Mod = Addon:NewModule('Gossip')

local staticPopupNPCs = {
	-- [95676] = true, -- Odyn
	-- [103860] = true, -- Vault of the Wardens Zone Out NPC
}
local npcBlacklist = {
	[107435] = true, [112697] = true, [112699] = true, -- Suspicous Noble
	[101462] = true, -- Reaves
}
local cosRumorNPC = 107486

local function GossipNPCID()
	local guid = UnitGUID("npc")
	local npcid = guid and select(6, strsplit("-", guid))
	return tonumber(npcid)
end

local function IsStaticPopupShown()
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..index]
		if frame and frame:IsShown() then
			return true
		end
	end
	return false
end

function Mod:CoSRumor()
	local clue = GetGossipText()
	local shortClue = Addon.Locale:Rumor(clue)
	if not shortClue then
		AngryKeystones_Data.rumors[clue] = true
	end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(shortClue or clue, "INSTANCE_CHAT")
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(shortClue or clue, "PARTY")
	else
		SendChatMessage(shortClue or clue, "SAY")
	end
end

function Mod:RumorCleanup()
	local new = {}
	for clue,_ in pairs(AngryKeystones_Data.rumors) do
		if not Addon.Locale:Rumor(clue) then
			new[clue] = true
		end
	end
	AngryKeystones_Data.rumors = new
end

function Mod:GOSSIP_SHOW()
	local npcId = GossipNPCID()
	if Addon.Config.cosRumors and Addon.Locale:HasRumors() and npcId == cosRumorNPC and GetNumGossipOptions() == 0 then
		self:CoSRumor()
		CloseGossip()
	end

	local scenarioType = select(10, C_Scenario.GetInfo())
	if Addon.Config.autoGossip and scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE and not npcBlacklist[npcId] then
		local options = {GetGossipOptions()}
		for i = 1, GetNumGossipOptions() do
			if options[i*2] == "gossip" then
				local popupWasShown = IsStaticPopupShown()
				SelectGossipOption(i)
				local popupIsShown = IsStaticPopupShown()
				if popupIsShown or (npcId and staticPopupNPCs[npcId]) then
					if not popupWasShown then
						StaticPopup1Button1:Click()
						CloseGossip()
					end
				else
					CloseGossip()
				end
				break
			end
		end
	end
end

function Mod:Startup()
	if not AngryKeystones_Data then AngryKeystones_Data = {} end
	if not AngryKeystones_Data.rumors then AngryKeystones_Data.rumors = {} end
	if Addon.Config.cosRumors then self:RumorCleanup() end

	self:RegisterEvent("GOSSIP_SHOW")
end
