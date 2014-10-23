-- Setup Display Fonts
-- Hunter
hunterFont = CreateFont("hunterFont")
hunterFont:SetFont(GameTooltipText:GetFont(), 10)
hunterFont:SetTextColor(RAID_CLASS_COLORS["HUNTER"].r,RAID_CLASS_COLORS["HUNTER"].g,RAID_CLASS_COLORS["HUNTER"].b)
 
-- Warlock
warlockFont = CreateFont("warlockFont")
warlockFont:SetFont(GameTooltipText:GetFont(), 10)
warlockFont:SetTextColor(RAID_CLASS_COLORS["WARLOCK"].r,RAID_CLASS_COLORS["WARLOCK"].g,RAID_CLASS_COLORS["WARLOCK"].b)
 
-- Priest
priestFont = CreateFont("priestFont")
priestFont:SetFont(GameTooltipText:GetFont(), 10)
priestFont:SetTextColor(RAID_CLASS_COLORS["PRIEST"].r,RAID_CLASS_COLORS["PRIEST"].g,RAID_CLASS_COLORS["PRIEST"].b)
 
-- Mage
mageFont = CreateFont("mageFont")
mageFont:SetFont(GameTooltipText:GetFont(), 10)
mageFont:SetTextColor(RAID_CLASS_COLORS["MAGE"].r,RAID_CLASS_COLORS["MAGE"].g,RAID_CLASS_COLORS["MAGE"].b)
 
-- Paladin
paladinFont = CreateFont("paladinFont")
paladinFont:SetFont(GameTooltipText:GetFont(), 10)
paladinFont:SetTextColor(RAID_CLASS_COLORS["PALADIN"].r,RAID_CLASS_COLORS["PALADIN"].g,RAID_CLASS_COLORS["PALADIN"].b)
 
-- Shaman
shamanFont = CreateFont("shamanFont")
shamanFont:SetFont(GameTooltipText:GetFont(), 10)
shamanFont:SetTextColor(RAID_CLASS_COLORS["SHAMAN"].r,RAID_CLASS_COLORS["SHAMAN"].g,RAID_CLASS_COLORS["SHAMAN"].b)
 
-- Druid
druidFont = CreateFont("druidFont")
druidFont:SetFont(GameTooltipText:GetFont(), 10)
druidFont:SetTextColor(RAID_CLASS_COLORS["DRUID"].r,RAID_CLASS_COLORS["DRUID"].g,RAID_CLASS_COLORS["DRUID"].b)
 
-- Death Knight
deathknightFont = CreateFont("deathknightFont") 
deathknightFont:SetFont(GameTooltipText:GetFont(), 10)
deathknightFont:SetTextColor(RAID_CLASS_COLORS["DEATHKNIGHT"].r,RAID_CLASS_COLORS["DEATHKNIGHT"].g,RAID_CLASS_COLORS["DEATHKNIGHT"].b)
 
-- Rogue
rogueFont = CreateFont("rogueFont")
rogueFont:SetFont(GameTooltipText:GetFont(), 10)
rogueFont:SetTextColor(RAID_CLASS_COLORS["ROGUE"].r,RAID_CLASS_COLORS["ROGUE"].g,RAID_CLASS_COLORS["ROGUE"].b)
 
-- Warrior
warriorFont = CreateFont("warriorFont")
warriorFont:SetFont(GameTooltipText:GetFont(), 10)
warriorFont:SetTextColor(RAID_CLASS_COLORS["WARRIOR"].r,RAID_CLASS_COLORS["WARRIOR"].g,RAID_CLASS_COLORS["WARRIOR"].b)

-- Monk
monkFont = CreateFont("monkFont")
monkFont:SetFont(GameTooltipText:GetFont(), 10)
monkFont:SetTextColor(RAID_CLASS_COLORS["MONK"].r,RAID_CLASS_COLORS["MONK"].g,RAID_CLASS_COLORS["MONK"].b)
 
CLASS_FONTS = {
	["HUNTER"] = hunterFont,
	["WARLOCK"] = warlockFont,
	["PRIEST"] = priestFont,
	["PALADIN"] = paladinFont,
	["MAGE"] = mageFont,
	["ROGUE"] = rogueFont,
	["DRUID"] = druidFont,
	["SHAMAN"] = shamanFont,
	["WARRIOR"] = warriorFont,
	["DEATHKNIGHT"] = deathknightFont,
	["MONK"] = monkFont,
};
