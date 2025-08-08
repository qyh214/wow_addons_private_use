local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G

local pairs = pairs

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local currentPatchMaps = {
	[30] = true,
	[37] = true,
	[38] = true,
	[111] = true,
	[113] = true,
	[115] = true,
	[119] = true,
	[123] = true,
}

-- NPC Blacklist
local npcBlacklist = {
	[220003] = true, -- Hollows Resident (Eye of Queen) City of Threads
	[555555] = true, -- Unknown NPC
}

function MH:Translate()
	if not self.db or not self.db.enable or not self.db.translate then
		return
	end

	local MDT = _G.MDT

	if not MDT or not MDT.dungeonEnemies or not MDT.L then
		return
	end

	for mapID, NPCs in pairs(MDT.dungeonEnemies) do
		if mapID and currentPatchMaps[mapID] and NPCs then
			for _, NPC in pairs(NPCs) do
				if NPC.id and NPC.name and not npcBlacklist[NPC.id] then
					F.HandleNPCNameByID(NPC.id, function(name)
						MDT.L[NPC.name] = name
					end)
				end
			end
		end
	end
end

function MH:ProfileUpdate()
	self.db = W.db.mdtHelper

	if not self.db or not self.db.enable then
		return
	end

	if C_AddOns_IsAddOnLoaded("MythicDungeonTools") then
		self:Translate()
	else
		self:RegisterEvent("ADDON_LOADED", "Translate")
	end
end

MH.OnInitialize = MH.ProfileUpdate
