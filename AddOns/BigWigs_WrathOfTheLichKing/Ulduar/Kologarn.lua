--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kologarn", 603, 1642)
if not mod then return end
mod:RegisterEnableMob(32930)
mod:SetEncounterID(BigWigsLoader.isWrath and 749 or 1137)
-- mod:SetRespawnTime(0) -- Respawn is based on running over the line at the room entrance

--------------------------------------------------------------------------------
-- Locals
--
local eyeBeam = mod:SpellName(40620) -- Eyebeam

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.arm = "Arm dies"
	L.arm_desc = "Warn for Left & Right Arm dies."
	L.arm_icon = "spell_nature_earthelemental_totem" -- Earth Elemental Totem / icon 136024
	L.left_dies = "Left Arm dies"
	L.right_dies = "Right Arm dies"
	L.left_wipe_bar = "Respawn Left Arm"
	L.right_wipe_bar = "Respawn Right Arm"

	L.eyebeam = "Focused Eyebeam"
	L.eyebeam_desc = "Warn who gets Focused Eyebeam."
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		64290, -- Stone Grip
		63983, -- Arm Sweep (Shockwave)
		{"eyebeam", "ICON", "FLASH", "SAY"},
		"arm",
		63355, -- Crunch Armor
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "StoneGrip", 64290, 64292) -- 10, 25
	self:Log("SPELL_AURA_APPLIED_DOSE", "CrunchArmor", 63355, 64002) -- 10, 25

	self:Death("ArmsDie", 32933, 32934) -- Left, Right

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CrunchArmor(args)
	self:StackMessageOld(63355, args.destName, args.amount, "purple", "info")
end

do
	local grip = mod:NewTargetList()
	function mod:StoneGrip(args)
		grip[#grip + 1] = args.destName
		if #grip == 1 then
			self:Bar(64290, 10)
			self:ScheduleTimer("TargetMessageOld", 0.2, 64290, grip, "yellow", "alert")
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_WHISPER(event, msg, unitName)
	-- Kologarn focuses his eyes on you!#Kologarn
	if unitName == self.displayName then
		self:Flash("eyebeam", 63976)
		self:Say("eyebeam", eyeBeam, nil, "Eyebeam")
		self:Sync("EyeBeamWarn")
	end
end

function mod:ArmsDie(args)
	if args.mobId == 32933 then -- Left
		self:MessageOld("arm", "yellow", nil, L["left_dies"], L.arm_icon)
		self:Bar("arm", 45, L["left_wipe_bar"], L.arm_icon)
		self:StopBar(63983) -- Arm Sweep
	elseif args.mobId == 32934 then -- Right
		self:MessageOld("arm", "yellow", nil, L["right_dies"], L.arm_icon)
		self:Bar("arm", 45, L["right_wipe_bar"], L.arm_icon)
	end
end

do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castId, spellId)
		if spellId == 63983 and castId ~= prev then -- Arm Sweep
			prev = castId
			self:MessageOld(63983, "orange")
			self:Bar(63983, 21)
		end
	end
end

function mod:BigWigs_BossComm(_, msg, _, sender)
	if msg == "EyeBeamWarn" then
		self:TargetMessageOld("eyebeam", sender, "red", "info", eyeBeam, 63976)
		self:TargetBar("eyebeam", 11, sender, eyeBeam, 63976)
		self:CDBar("eyebeam", 20, eyeBeam, 63976)
		self:PrimaryIcon("eyebeam", sender)
		self:ScheduleTimer("PrimaryIcon", 12, "eyebeam")
	end
end
