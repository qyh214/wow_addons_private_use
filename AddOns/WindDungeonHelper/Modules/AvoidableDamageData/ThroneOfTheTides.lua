local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- Commenting out Meele hits by adds on bosses, since it's debatable

local mistakes = {
	-- Lady Naz'jar
	{
		-- Lady Naz'jar:Trident Flurry
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428294,
	},
	{
		-- Lady Naz'jar:Shock Orb
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428048,
	},
	{
		-- Lady Naz'jar:Geyser
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427769,
	},
	-- {
	--     -- Lady Naz'jar:Naz'jar Honor Guard (Meele)
	--     type = AD.MISTAKE.MELEE,
	--     npc = 40633,
	--     playerIsNotTank = true
	-- },
	-- {
	--     -- Lady Naz'jar:Naz'jar Frost Witch (Meele)
	--     type = AD.MISTAKE.MELEE,
	--     npc = 44404,
	--     playerIsNotTank = true
	-- },
	-- Commander Ulthok
	{
		-- Commander Ulthok:Bubbling Ooze
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427559,
	},
	-- Mindbender Ghur'sha
	{
		-- Mindbender Ghur'sha:Terrifying Vision
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 429172,
	},
	{
		-- Mindbender Ghur'sha:Earthfury
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 429057,
	},
	-- Ozumat
	{
		-- Ozumat:Blotting Darkness
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428404,
	},
	{
		-- Ozumat:Murk Spew
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428530,
		playerIsNotTank = true,
	},
	{
		-- Ozumat:Deluge of Filth
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428618,
	},
	{
		-- Ozumat:Gushing Ink
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428809,
	},
	-- {
	--     -- Ozumat:Sludge (Meele)
	--     type = AD.MISTAKE.MELEE,
	--     npc = 213942,
	--     playerIsNotTank = true
	-- },
	-- {
	--     -- Ozumat:Splotch (Meele)
	--     type = AD.MISTAKE.MELEE,
	--     npc = 213806,
	--     playerIsNotTank = true
	-- },
	-- Mobs
	{
		-- Shadow Smash
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 76590,
	},
	{
		-- Null Blast
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426808,
	},
	{
		-- Electric Jaws
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426681,
	},
	{
		-- Volatile Acid
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426688,
	},
	{
		-- Volatile Bolt
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 426685,
	},
}

local mapIds = { 322, 323 }

AD:AddData("Throne of the Tides", mistakes, mapIds)
