local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Chronikar:Withering Sandpool - initial damage not avoidable
-- TODO: Timerip - initial damage not avoidable
-- Commenting out Embers & Sharpnel, they are dots left after avoidable damage

local mistakes = {
	-- Chronikar
	{
		-- Chronikar:Withering Sandpool
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 401794,
	},
	{
		-- Chronikar:Eon Fragments
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 405970,
	},
	{
		-- Chronikar:Eon Shatter
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413107,
	},
	-- Manifested Timeways
	{
		-- Manifested Timeways:Fragments of Time
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 404650,
	},
	-- Blight of Galakrond
	{
		-- Blight of Galakrond:Necrotic Winds
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 408008,
	},
	{
		-- Blight of Galakrond:Incinerating Blightbreath
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 408177,
	},
	{
		-- Blight of Galakrond:Blight Seep
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407147,
	},
	{
		-- Blight of Galakrond:Blight Reclamation
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407159,
		playerIsNotTank = true,
	},
	-- Iridikron
	{
		-- Iridikron:Punctured Ground
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 414376,
	},
	{
		-- Iridikron:Rending Earthspikes
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 409287,
	},
	-- Tyr, the Infinite Keeper
	{
		-- Tyr:Titanic Blow
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 417339,
		playerIsNotTank = true,
	},
	{
		-- Tyr:Consecrated Ground
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 403724,
	},
	{
		-- Tyr:Infinite Annihilation
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 400597,
	},
	-- Morchie
	{
		-- Morchie:Dragon's Breath
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 404365,
	},
	{
		-- Morchie:Sand Blast
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 404917,
		playerIsNotTank = true,
	},
	{
		-- Morchie:Anachronistic Decay
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412769,
	},
	{
		-- Morchie:Familiar Faces (Meele)
		type = AD.MISTAKE.MELEE,
		npc = 201756,
	},
	-- Time-Lost Battlefield
	{
		-- Time-Lost Battlefield:Bladestorm
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 410238,
	},
	{
		-- Time-Lost Battlefield:Shockwave
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 408228,
	},
	{
		-- Time-Lost Battlefield:Earthquake
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407906,
	},
	-- Chrono-Lord Deios
	{
		-- Chrono-Lord Deios:Temporal Breath
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 416139,
		playerIsNotTank = true,
	},
	{
		-- Chrono-Lord Deios:Temporal Scar
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 417413,
	},
	{
		-- Chrono-Lord Deios:Infinite Corruption #1
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 416266,
	},
	{
		-- Chrono-Lord Deios:Infinite Corruption #2
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 416290,
	},
	{
		-- Chrono-Lord Deios:Infinite Corruption #3
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 416265,
	},
	{
		-- Chrono-Lord Deios:Infinite Blast
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 411763,
	},
	-- Mobs:FALL
	{
		-- Blight Spew
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412810,
	},
	-- {
	--     -- Timerip
	--     type = AD.MISTAKE.SPELL_DAMAGE,
	--     spell = 412065
	-- },
	{
		-- Sand Zone
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413332,
	},
	{
		-- Errant Time
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 414032,
	},
	{
		-- Corrosive Expulsion
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407027,
	},
	-- Mobs:RISE
	{
		-- Rending Cleave
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412505,
		playerIsNotTank = true,
	},
	{
		-- Cold Fusion
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426849,
	},
	{
		-- Twisted Timeways
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 418092,
	},
	-- {
	--     -- Shrapnel
	--     type = AD.MISTAKE.SPELL_DAMAGE,
	--     spell = 407313
	-- },
	{
		-- Consecration
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 417002,
	},
	{
		-- Time Beam
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413427,
	},
	{
		-- Triple Strike
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413489,
	},
	{
		-- Bronze Exhalation
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419351,
		playerIsNotTank = true,
	},
	{
		-- Volatile Mortar
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407312,
	},
	{
		-- Electro-Juiced Gigablast
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412225,
	},
	{
		-- Timeless Curse
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413618,
	},
	{
		-- Sundering Slam
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 407125,
	},
	{
		-- Bombing Run
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412181,
	},
	{
		-- Millennium Aid
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 412029,
	},
	-- {
	--     -- Embers
	--     type = AD.MISTAKE.SPELL_DAMAGE,
	--     spell = 407315
	-- },
	{
		-- Kaboom!
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419629,
	},
	{
		-- Loose Time
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419526,
	},
	{
		-- Untwist #1
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413532,
		playerIsNotTank = true,
	},
	{
		-- Untwist #2
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 413536,
		playerIsNotTank = true,
	},
	{
		-- Chronal Eruption
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419517,
	},
	{
		-- Infinite Schizm
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 419328,
	},
}

local mapIds = { 2190, 2191, 2192, 2193, 2194, 2195, 2196, 2197, 2197 }

AD:AddData("Dawn of the Infinite", mistakes, mapIds)
