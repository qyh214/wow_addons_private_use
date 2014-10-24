local Revision = ("$Revision: 19 $"):sub(12, -3)

local default_settings = {
	enabled = true,}
DBM_Archaeology_Settings = {}
local settings = default_settings

local L = DBM_Archaeology_Translations

local IsInInstance = IsInInstance
local mRandom = math.random

local soundFiles = {
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper01.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper01.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper02.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper03.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper04.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper05.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper06.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper07.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_HowlingFjordWhisper08.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_Whisper01.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_Whisper02.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_Whisper03.ogg",
	"Sound\\Creature\\YoggSaron\\AK_YoggSaron_Whisper04.ogg",
	"Sound\\Creature\\CThun\\CThunDeathIsClose.ogg",
	"Sound\\Creature\\CThun\\CThunYouAreAlready.ogg",
	"Sound\\Creature\\CThun\\CThunYouWillBetray.ogg",
	"Sound\\Creature\\CThun\\CThunYouWillDIe.ogg",
	"Sound\\Creature\\CThun\\CThunYourCourage.ogg",
	"Sound\\Creature\\CThun\\CThunYourFriends.ogg",
	"Sound\\Creature\\CThun\\YourHeartWill.ogg",
	"Sound\\Creature\\CThun\\YouAreWeak.ogg"
}

local function PlayArchSound(file)
	if DBM.Options.UseMasterVolume then
		PlaySoundFile(file, "Master")
	else
		PlaySoundFile(file)
	end
end

-- functions
local addDefaultOptions
do 
	local function creategui()
		local createnewentry
		local CurCount = 0
		local panel = DBM_GUI:CreateNewPanel(L.TabCategory_Archaeology, "option")
		local generalarea = panel:CreateArea(L.AreaGeneral, nil, 100, true)
		
		do
			local area = generalarea
			local enabled = area:CreateCheckButton(L.Enable, true)
			enabled:SetScript("OnShow", function(self) self:SetChecked(settings.enabled) end)
			enabled:SetScript("OnClick", function(self) settings.enabled = not not self:GetChecked() end)

			local version = area:CreateText("r"..Revision, nil, nil, GameFontDisableSmall, "RIGHT")
			version:SetPoint("BOTTOMRIGHT", area.frame, "BOTTOMRIGHT", -5, 5)
		end
		panel:SetMyOwnHeight()
	end
	DBM:RegisterOnGuiLoadCallback(creategui, 19)
end

do
	function addDefaultOptions(t1, t2)
		for i, v in pairs(t2) do
			if t1[i] == nil then
				t1[i] = v
			elseif type(v) == "table" and type(t1[i]) == "table" then
				addDefaultOptions(t1[i], v)
			end
		end
	end

	local mainframe = CreateFrame("frame", "DBM_Archaeology", UIParent)
	local spamSound = 0
	mainframe:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" and select(1, ...) == "DBM-Archaeology" then
			self:RegisterEvent("CHAT_MSG_LOOT")
			self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
			-- Update settings of this Addon
			settings = DBM_Archaeology_Settings
			addDefaultOptions(settings, default_settings)

		elseif settings.enabled and event == "CHAT_MSG_LOOT" then
			if IsInInstance() then return end--There are no keystones in dungeons/raids so save cpu
			local lootmsg = select(1, ...)
			local player, itemID = lootmsg:match(L.DBM_LOOT_MSG)
			if player and itemID and (tonumber(itemID) == 52843 or tonumber(itemID) == 63127 or tonumber(itemID) == 63128 or tonumber(itemID) == 64392 or tonumber(itemID) == 64394 or tonumber(itemID) == 64396 or tonumber(itemID) == 64395 or tonumber(itemID) == 64397 or tonumber(itemID) == 79869 or tonumber(itemID) == 79868 or tonumber(itemID) == 95373) and GetTime() - spamSound >= 10 then
				local x = mRandom(1, #soundFiles)
				spamSound = GetTime()
				PlayArchSound(soundFiles[x])
			end

		elseif settings.enabled and event == "UNIT_SPELLCAST_SUCCEEDED" then
			local spellId = select(5, ...)
			if spellId == 91756 then--Puzzle Box of Yogg-Saron
				PlayArchSound("Sound\\Creature\\YoggSaron\\UR_YoggSaron_Slay01.ogg")
			elseif spellId == 91754 then--Blessing of the Old God
				PlayArchSound("Sound\\Creature\\YoggSaron\\UR_YoggSaron_Insanity01.ogg")
			end
		end
	end)
	mainframe:RegisterEvent("ADDON_LOADED")
end
