--Code to handle triggering alerts off of Nameplates 
-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local pairs = _G.pairs


-------------------------------------------------------------------------------
-- AddOn namespace.
-------------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local L = private.L

local Debug = private.Debug

-- Create a new Add-on object using AceAddon
private.NameplateScan = LibStub("AceAddon-3.0"):NewAddon("NPCScanNameplateScaner", "LibNameplateRegistry-1.0")


local NameplateScan = private.NameplateScan


function NameplateScan:OnEnable()
	-- Subscribe to callbacks
	self:LNR_RegisterCallback("LNR_ON_NEW_PLATE") -- registering this event will enable the library else it'll remain idle
end


function NameplateScan:OnDisable()
	-- unregister all LibNameplateRegistry callbacks, which will disable it if
	-- your add-on was the only one to use it
	self:LNR_UnregisterAllCallbacks()
end


-- Trigger when a new namplate is detected.
function NameplateScan:LNR_ON_NEW_PLATE(eventname, plateFrame, plateData)
	if not private.CharacterOptions.TrackNameplate then return end

	local  npc_id = private.NPC_NAME_TO_ID[plateData.name] or private.CUSTOM_NPC_NAME_TO_ID[plateData.name] or nil

	if private.ScanIDs[npc_id] then
		private.Debug("Mob Found Via Nameplate")

		if _G._NPCScanOptions.IgnoreList.NPCs[npc_id] then
			Debug("Ignored Mob")
			return
		end

		private.OnFound(npc_id, plateData.name)
	end
end