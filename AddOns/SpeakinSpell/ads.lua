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
		Channel = SpeakinSpell.DEFAULTS.AD_CHANNELS[ self:GetScenarioKey() ]
	end
	
	-- select a random ad that was not used last time
	local msg = self:GetRandomTableEntry( DEFAULT_ADS.ADVERTISEMENTS, self.RuntimeData.LastAd )
	
	-- remember we selected this, so we don't repeat it next time
	self.RuntimeData.LastAd = msg

	-- process substitution variables on the randomized advertisements
	local DetectedEventStub = {
		-- event descriptors
		name = "ad",
		-- event-specific data for substitutions
		target = msgtarget,
		caster = UnitName("player"),
		type = "MACRO"
	}
	local DetectedEvent = self:CreateDetectedEvent( DetectedEventStub )
	msg = self:FormatSubs(msg, DetectedEvent)
	
	-- speak in chat
   -- add a check for instance and change channel to INSTANCE_CHAT if true
   
   if self:CheckForInstance()==true then 
      Channel="INSTANCE_CHAT"
   end
   
	SendChatMessage( SpeakinSpell.URL.." for "..SpeakinSpell.WOWVERSION , Channel, nil, msgtarget)	
	SendChatMessage( msg,              Channel, nil, msgtarget)
end
