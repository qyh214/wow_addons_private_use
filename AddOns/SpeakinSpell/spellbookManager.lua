-- author      :Groguz    
-- create Date : 01/16/2014 12:34:00 PM

local SpeakinSpell = LibStub("AceAddon-3.0"):GetAddon("SpeakinSpell")
local L = LibStub("AceLocale-3.0"):GetLocale("SpeakinSpell", false)
SpeakinSpell:PrintLoading("spellbookManager.lua")

-------------------------------------------------------------------------------
-- player spellbook integration. 
-- (hope that this will also be usefull to remove dead data from the speakinspell DB)
-- Adds links to the splells in the spell book so that users can click that link
-- and have it comeup in the Speech editor.
-------------------------------------------------------------------------------
local SSButton ={}
local SSSpellnames={}
-- need to create an SS button to attach to each spell in the spellbook.

function SpeakinSpell:createSSButton(name,index,x,y)
	local abutton=CreateFrame("Button", name, _G["SpellButton"..index], "SecureActionButtonTemplate,OptionsButtonTemplate");

	abutton:SetWidth(20);
	abutton:SetHeight(20);
	abutton:SetAlpha(1);
	abutton:SetPoint("TOP", _G["SpellButton"..index], "TOP",x,y);
	abutton.id=index
	abutton:Hide();
	abutton:SetClampedToScreen(true);
	abutton:SetText("SS")
	abutton:RegisterForClicks("AnyDown");
	abutton:SetScript("OnClick",
		function(self, button, down)
			SpeakinSpell:SSButtonDown(self, button, down)
		end)

	return abutton;
end

function SpeakinSpell:SSButtonDown(self, button, down)
	local funcname = "SSButtonDown"
	local index = self.id 
	local spellname = SSSpellnames[index]
	SpeakinSpell:DebugMsg(funcname, "clicked Spellbook:"..tostring(spellname))

	-- Treat the Spellbook button like "/ss create" for the following reasons
	-- 1. the same spell could have multiple triggers
	--    for start casting vs. failed to cast, etc
	--    even if an existing trigger exists, 
	--    we can't tell if the user wants to create a new trigger or edit an existing one
	-- 2. if the spell has never been cast 
	--    the "/ss create" interface has language on it about this issue
	--    with instructions to cast the spell and try again
	SpeakinSpell:ShowCreateNew()
	SpeakinSpell:CreateNew_OnGetSetEventTextFilter("SET", spellname)
 end 
 
 function SpeakinSpell:updateSSLinks()
	--print("POST HOOK updateSSLinks() called")
	-- make sure each slot shown has a button in it
	for i=1,SPELLS_PER_PAGE do
		self:GetSlotInfoforButton(_G["SpellButton"..i],i)
	end -- for
 end
 
 -- test to see if a spellslot has anything in it
 -- using secure call to maintain clean fuctions 
 function SpeakinSpell:SSHasSpell(aSlot)
	local texture

	if (aSlot)  then
		texture = securecall(GetSpellBookItemTexture,aSlot, SpellBookFrame.bookType);
	end

	if ( not texture or (strlen(texture) == 0) ) then
		return false
	else
		return true
	end
 end
 
 
 -- update the links from the button to call the corect 
 --   setup for its spell
 -- using secure call to maintain clean fuctions 
 -- note need to add a check for Pet tab and handle it corectly
 function SpeakinSpell:GetSlotInfoforButton(aButton,index)
	-- update each SSButton
	local slot, slotType, slotID
	local name
	local spellString

	if ( SpellBookFrame.bookType ==BOOKTYPE_PROFESSION) then
		-- do nothing later I will add buttons here.
		-- for now I just want to get core skills and abillities 
	elseif ( SpellBookFrame.bookType==BOOKTYPE_PET) then
		-- need to manage the slots a little different
		slot, slotType, slotID = securecall(SpellBook_GetSpellBookSlot,aButton)
		name = aButton:GetName();
		spellString = _G[name.."SpellName"];

		if (self:SSHasSpell(slot)==true)  then
			SSSpellnames[index]= spellString:GetText();
			SSButton[index]:Show(); 
		else
			SSButton[index]:Hide();
		end

	elseif ( SpellBookFrame.bookType==BOOKTYPE_SPELL) then
		slot, slotType, slotID = securecall(SpellBook_GetSpellBookSlot,aButton)
		name = aButton:GetName();
		spellString = _G[name.."SpellName"];

		if (self:SSHasSpell(slot))==true  then
			SSSpellnames[index]= spellString:GetText();
			-- check for passive spells and exclude them 
			if (IsPassiveSpell(SSSpellnames[index])) then
				SSButton[index]:Hide();
			else
				SSButton[index]:Show();
			end
			--print("found Button ID:" ..SSButton[index].id ..") indexed to:"..spellString:GetText())
		else
			SSButton[index]:Hide();
			SSSpellnames[index]=nil;
		end --if

	end -- if 
 end 
 
 function SpeakinSpell:Init_Spellbook_SSLinks()  
	-- create an array of button
	for i=1,SPELLS_PER_PAGE do
		SSButton[i]=self:createSSButton("SSButton"..i,i,32,17);
	end

	-- main hook for spellbook update
	hooksecurefunc("SpellBookFrame_Update", function() self:updateSSLinks() end )
 end
