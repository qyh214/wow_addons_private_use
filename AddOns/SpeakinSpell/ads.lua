-- Author      : RisM
-- Create Date : 9/25/2009 6:27:48 AM


local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local DEFAULT_ADS = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell_DEFAULT_ADS", false)

SpeakinSpell:PrintLoading("ads.lua")

-------------------------------------------------------------------------------
-- Advertisement System
-------------------------------------------------------------------------------


function SpeakinSpell:Advertise(Channel, msgtarget)
	-- advertise into a channel for the kind of group you are in
	-- unless a channel has been specified
	if Channel == "" or Channel == nil then
		-- check for instance and change channel to INSTANCE_CHAT if true
		if self:CheckForInstance() then 
			Channel = "INSTANCE_CHAT"
		else
			Channel = SpeakinSpell.DEFAULTS.AD_CHANNELS[ self:GetScenarioKey() ]
		end
	end
	
	-- select a random ad that was not used last time
	local msg = self:GetRandomTableEntry( DEFAULT_ADS.ADVERTISEMENTS, self.RuntimeData.LastAd )
	
	-- remember we selected this, so we don't repeat it next time
	self.RuntimeData.LastAd = msg

	-- process substitution variables on the randomized advertisements
	--NOTE: myrealm result from UnitName("player") is always nil
	local myname, myrealm = UnitName("player")
	local DetectedEventStub = {
		-- event descriptors
		name = "ad",
		-- event-specific data for substitutions
		target = msgtarget,
		caster = myname,
		type = "MACRO"
	}
	local DetectedEvent = self:CreateDetectedEvent( DetectedEventStub )
	msg = self:FormatSubs(msg, DetectedEvent)
	
	-- speak in chat

	-- Search curse.com for "SpeakinSpell"
	SendChatMessage( SpeakinSpell.URL, Channel, nil, msgtarget)
	-- "Version 6.0.3.03 for WoW 6.0.3" taking version info from the TOC file
	-- TODO: this should be localized, using substitutions to support flexible word order
	SendChatMessage( GAME_VERSION_LABEL.." "..SpeakinSpell.CURRENT_VERSION.." for WoW "..SpeakinSpell.WOWVERSION , Channel, nil, msgtarget)	
	-- Random witty phrase from Locales\Ads-xxXX.lua
	-- "SpeakinSpell: the cure for the boring pug where nobody ever says anything!"
	SendChatMessage( msg, Channel, nil, msgtarget)
end
