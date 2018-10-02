-- Author      : RisM
-- Create Date : 12/3/2009 2:43:45 AM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)
local ResInfo = LibStub:GetLibrary("LibResInfo-1.0");

-------------------------------------------------------------------------------
-- REZ DETECTION
-------------------------------------------------------------------------------

-- A bridge between LibResInfo-1.0 and SpeakinSpell
-- converts LibResInfo events into OnSpeechEvent

-- the problem with Rez spells is that the blizz API fails to report targets
-- for players who released their spirits

-- LibResInfo fixes that, and adds more


function SpeakinSpell:Rez_Init()
	-- setup for LibResInfo notifications
	ResInfo.RegisterCallback(self, "ResInfo_ResStart");
	ResInfo.RegisterCallback(self, "ResInfo_ResEnd");
	ResInfo.RegisterCallback(self, "ResInfo_Ressed");
	ResInfo.RegisterCallback(self, "ResInfo_CanRes");
	ResInfo.RegisterCallback(self, "ResInfo_ResExpired");
end


-- event is the name of the function, i.e. "ResInfo_ResStart"
function SpeakinSpell:ResInfo_ResStart(event, resser, endTime, target)
	--Note: Messages comming from oRA2 will not have a reliable endTime.
	local destub = {
		type = "REZ",
		--name = L["Start Casting"], -- varies by caster/target, see below
		caster = resser,
		target = target,
		--endtime = endTime, -- this is a number value, and not very useful to our purposes
	}
	-- use the player's role in this in the event name (and thus the key)
	-- TODO: what if you're both the caster and the target?
	if SpeakinSpell:NameIsMe(resser) then
		destub.name = L["Start Casting (I'm the caster)"]
	elseif SpeakinSpell:NameIsMe(target) then
		destub.name = L["Start Casting (I'm the target)"]
	else
		destub.name = L["Start Casting (I'm not involved)"]
	end
	
	self:OnSpeechEvent( destub )
end


function SpeakinSpell:ResInfo_ResEnd(event, resser, target)
	--Fired when a resurrection cast ended. This can either mean it has failed or completed. 
	--Use ResInfo_Ressed to check if someone actually ressed.
	local destub = {
		type = "REZ",
		--name = L["End Casting"], -- varies by caster/target, see below
		caster = resser,
		target = target,
	}
	-- use the player's role in this in the event name (and thus the key)
	-- TODO: what if you're both the caster and the target?
	if SpeakinSpell:NameIsMe(resser) then
		destub.name = L["End Casting (I'm the caster)"]
	elseif SpeakinSpell:NameIsMe(target) then
		destub.name = L["End Casting (I'm the target)"]
	else
		destub.name = L["End Casting (I'm not involved)"]
	end
	self:OnSpeechEvent( destub )
end


function SpeakinSpell:ResInfo_Ressed(event, name)
	--Fired when someone actually sees the accept resurrection box.
	local destub = {
		type = "REZ",
		name = L["Received by target"],
		caster = name, -- TODOLATER: knowing this caster is tricky
		target = name,
	}
	self:OnSpeechEvent( destub )
end


function SpeakinSpell:ResInfo_CanRes(event, name)
	--Fired when someone can use a soulstone or ankh.
	local destub = {
		type = "REZ",
		name = L["Someone can self-res (SS, Ankh)"],
		caster = name,
		target = name,
	}
	self:OnSpeechEvent( destub )
end


function SpeakinSpell:ResInfo_ResExpired(event, name)
	--Fired when the accept resurrection box dissapears/is declined. 
	local destub = {
		type = "REZ",
		name = L["Expired or Declined"],
		caster = name, -- TODOLATER: knowing this caster is tricky
		target = name,
	}
	self:OnSpeechEvent( destub )
end
