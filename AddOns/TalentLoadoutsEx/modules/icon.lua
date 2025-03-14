local _, Addon = ...;

Addon.DEFAULT_ICON = 134400;
Addon.MYTHICPLUS_ICON = 4352494;
Addon.HERO_TALENTS_ICON = 5740021;

local heroTalentIcons = {
	WARRIOR = {
		{Addon.HERO_TALENTS_ICON, "Mountain Thane", "talents-heroclass-warrior-mountainthane"},
		{Addon.HERO_TALENTS_ICON, "Colossus", "talents-heroclass-warrior-colossus"},
		{Addon.HERO_TALENTS_ICON, "Slayer", "talents-heroclass-warrior-slayer"},
		{252174,  "Mountain Thane", ""},
		{5927618, "Colossus", ""},
		{5927649, "Slayer", ""},
	},
	PALADIN = {
		{Addon.HERO_TALENTS_ICON, "Templar", "talents-heroclass-paladin-templar"},
		{Addon.HERO_TALENTS_ICON, "Herald of the Sun", "talents-heroclass-paladin-heraldofthesun"},
		{Addon.HERO_TALENTS_ICON, "Lightsmith", "talents-heroclass-paladin-lightsmith"},
		{571556,  "Templar", ""},
		{5927633, "Herald of the Sun", ""},
		{5927636, "Lightsmith", ""},
	},
	HUNTER = {
		{Addon.HERO_TALENTS_ICON, "Sentinel", "talents-heroclass-hunter-sentinel"},
		{Addon.HERO_TALENTS_ICON, "Dark Ranger", "talents-heroclass-hunter-darkranger"},
		{Addon.HERO_TALENTS_ICON, "Pack Leader", "talents-heroclass-hunter-packleader"},
		{4067367, "Sentinel", ""},
		{5927620, "Dark Ranger", ""},
		{5927643, "Pack Leader", ""},
	},
	ROGUE = {
		{Addon.HERO_TALENTS_ICON, "Trickster", "talents-heroclass-rogue-trickster"},
		{Addon.HERO_TALENTS_ICON, "Deathstalker", "talents-heroclass-rogue-deathstalker"},
		{Addon.HERO_TALENTS_ICON, "Fatebound", "talents-heroclass-rogue-fatebound"},
		{135690,  "Trickster", ""},
		{5927622, "Deathstalker", ""},
		{5927626, "Fatebound", ""},
	},
	PRIEST = {
		{Addon.HERO_TALENTS_ICON, "Archon", "talents-heroclass-priest-archon"},
		{Addon.HERO_TALENTS_ICON, "Oracle", "talents-heroclass-priest-oracle"},
		{Addon.HERO_TALENTS_ICON, "Voidweaver", "talents-heroclass-priest-voidweaver"},
		{5764905, "Archon", ""},
		{5927640, "Oracle", ""},
		{5927657, "Voidweaver", ""},
	},
	DEATHKNIGHT = {
		{Addon.HERO_TALENTS_ICON, "Rider of the Apocalypse", "talents-heroclass-deathknight-rideroftheapocalypse"},
		{Addon.HERO_TALENTS_ICON, "Deathbringer", "talents-heroclass-deathknight-deathbringer"},
		{Addon.HERO_TALENTS_ICON, "San'layn", "talents-heroclass-deathknight-sanlayn"},
		{236793,  "Rider of the Apocalypse", ""},
		{5927621, "Deathbringer", ""},
		{5927645, "San'layn", ""},
	},
	SHAMAN = {
		{Addon.HERO_TALENTS_ICON, "Farseer", "talents-heroclass-shaman-farseer"},
		{Addon.HERO_TALENTS_ICON, "Stormbringer", "talents-heroclass-shaman-stormbringer"},
		{Addon.HERO_TALENTS_ICON, "Totemic", "talents-heroclass-shaman-totemic"},
		{2021574, "Farseer", ""},
		{5927653, "Stormbringer", ""},
		{5927655, "Totemic", ""},
	},
	MAGE = {
		{Addon.HERO_TALENTS_ICON, "Frostfire", "talents-heroclass-mage-frostfire"},
		{Addon.HERO_TALENTS_ICON, "Spellslinger", "talents-heroclass-mage-spellslinger"},
		{Addon.HERO_TALENTS_ICON, "Sunfury", "talents-heroclass-mage-sunfury"},
		{135866,  "Frostfire", ""},
		{4578411, "Spellslinger", ""},
		{5927654, "Sunfury", ""},
	},
	WARLOCK = {
		{Addon.HERO_TALENTS_ICON, "Diabolist", "talents-heroclass-warlock-diabolist"},
		{Addon.HERO_TALENTS_ICON, "Hellcaller", "talents-heroclass-warlock-hellcaller"},
		{Addon.HERO_TALENTS_ICON, "Soul Harvester", "talents-heroclass-warlock-soulharvester"},
		{1121021, "Diabolist", ""},
		{5927632, "Hellcaller", ""},
		{5927650, "Soul Harvester", ""},
	},
	MONK = {
		{Addon.HERO_TALENTS_ICON, "Conduit of the Celestials", "talents-heroclass-monk-conduitofthecelestials"},
		{Addon.HERO_TALENTS_ICON, "Master of Harmony", "talents-heroclass-monk-masterofharmony"},
		{Addon.HERO_TALENTS_ICON, "Shado-Pan", "talents-heroclass-monk-shadopan"},
		{5927619, "Conduit of the Celestials", ""},
		{5927638, "Master of Harmony", ""},
		{5927648, "Shado-Pan", ""},
	},
	DRUID = {
		{Addon.HERO_TALENTS_ICON, "Druid of the Claw", "talents-heroclass-druid-druidoftheclaw"},
		{Addon.HERO_TALENTS_ICON, "Elune's Chosen", "talents-heroclass-druid-eluneschosen"},
		{Addon.HERO_TALENTS_ICON, "Keeper of the Grove", "talents-heroclass-druid-keeperofthegrove"},
		{Addon.HERO_TALENTS_ICON, "Wildstalker", "talents-heroclass-druid-wildstalker"},
		{5927623, "Druid of the Claw", ""},
		{5927624, "Elune's Chosen", ""},
		{5927634, "Keeper of the Grove", ""},
		{5927658, "Wildstalker", ""},
	},
	DEMONHUNTER = {
		{Addon.HERO_TALENTS_ICON, "Aldrachi Reaver", "talents-heroclass-demonhunter-aldrachireaver"},
		{Addon.HERO_TALENTS_ICON, "Fel-Scarred", "talents-heroclass-demonhunter-felscarred"},
		{5927616, "Aldrachi Reaver", ""},
		{5927628, "Fel-Scarred", ""},
	},
	EVOKER = {
		{Addon.HERO_TALENTS_ICON, "Scalecommander", "talents-heroclass-evoker-scalecommander"},
		{Addon.HERO_TALENTS_ICON, "Chronowarden", "talents-heroclass-evoker-chronowarden"},
		{Addon.HERO_TALENTS_ICON, "Flameshaper", "talents-heroclass-evoker-flameshaper"},
		{4622451, "Scalecommander", ""},
		{5927617, "Chronowarden", ""},
		{5927629, "Flameshaper", ""},
	},
};

local classFilename = UnitClassBase("player");
Addon.icons = {
	heroTalentIcons[classFilename],
	{
		-- Delve
		{1786405, "Ability_racial_dungeondelver", "Delve"},
		{1064187, "Icon_treasuremap", "Delve"},
		{5453546, "Inv_helm_armor_bronzebeard_b_01", "Delve"},
	},
	--[[
	{
		-- M+: TWW Season 1
		{Addon.MYTHICPLUS_ICON,  "Mythic Keystone", "M+"},
		{5912507, "Ara-Kara, City of Echoes", "ARAK"},
		{5912509, "City of Threads", "COT"},
		{5912513, "The Dawnbreaker", "DAWN"},
		{460863,  "Grim Batol", "GB"},
		{3759929, "Mists of Tirna Scithe", "MISTS"},
		{3759930, "The Necrotic Wake", "NW"},
		{2178733, "Siege of Boralus", "SIEGE"},
		{5912515, "The Stonevault", "SV"},
	},
	--]]
	{
		-- M+: TWW Season 2
		{Addon.MYTHICPLUS_ICON,  "Mythic Keystone", "M+"},
		{3759934, "Theater of Pain", "TOP"},
		{5912514, "The Rookery", "ROOK"},
		{2178735, "The MOTHERLODE!!", "ML"},
		{5912512, "Priory of the Sacred Flame", "PSF"},
		{3025336, "Operation: Mechagon - Workshop", "WORK"},
		{6422372, "Operation: Floodgate", "FLOOD"},
		{5912510, "Darkflame Cleft", "DFC"},
		{5912508, "Cinderbrew Meadery", "BREW"},
	},
	--[[
	{
		-- Raid: Nerub-ar Palace
		{5779391, "Nerub-ar Palace"},
		{5779390, "Ulgrax the Devourer"},
		{5779386, "The Bloodbound Horror"},
		{5779389, "Sikran, Captain of the Sureki"},
		{5661707, "Rasha'nan"},
		{5688871, "Broodtwister Ovi'nax"},
		{5779388, "Nexus-Princess Ky'veza"},
		{5779387, "The Silken Court"},
		{5779391, "Queen Ansurek"},
	},
	--]]
	{
		-- Raid: Liberation of Undermine
		{6392621, "Liberation of Undermine"},
		{6392628, "Vexie and the Geargrinders"},
		{6253176, "Cauldron of Carnage"},
		{6392625, "Rik Reverb"},
		{6392627, "Stix Bunkjunker"},
		{6392626, "Sprocketmonger Lockenstock"},
		{6392624, "The One-Armed Bandit"},
		{6392623, "Mug'Zee, Heads of Security"},
		{6392621, "Chrome King Gallywix"},
	},
};

function Addon:AddIconSelectionData()
	local LargerMacroIconSelectionData = _G["LargerMacroIconSelectionData"];
	local fileData = LargerMacroIconSelectionData:GetFileData();

	-- Add icons if there are not registered in the LargerMacroIconSelectionData.
	local additionalData = {
		-- [0000] = "inv_xxxx",
	};

	local hasAddedIcons = false;
	for key, value in pairs(additionalData) do
		hasAddedIcons = true;
		fileData[key] = value;
	end

	if hasAddedIcons then
		LargerMacroIconSelectionData.GetFileData = function()
			return fileData;
		end
	end
end

local function OnClickedIconSelectButton(button)
	local popup = Addon.frame.EditPopupFrame;
	popup.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(button.icon);

	local atlas = button.texture:GetAtlas();
	if atlas then
		popup.BorderBox.SelectedIconArea.SelectedIconButton.Icon:SetAtlas(atlas);
	end

	if popup.SearchBox then
		popup.SearchBox:SetText(tostring(button.icon));
	end
end

function Addon:InitIconSearcher()
	_G["LargerMacroIconSelection"]:Initialize(Addon.frame.EditPopupFrame);
end

function Addon:InitIconSelector()
	local gridOffset = 46;
	local parent = Addon.frame.EditPopupFrame.IconListFrame;
	for groupIndex, group in ipairs(Addon.icons) do
		for iconIndex, iconInfo in ipairs(group) do
			--- @type table
			local iconButton = CreateFrame("Button", nil, parent, "TalentLoadoutExIconButtonTemplate");
			local iconID = iconInfo[1];
			local iconName = iconInfo[2];
			iconButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 22 + gridOffset * (iconIndex - 1), -18 - gridOffset * (groupIndex - 1));
			iconButton.texture:SetTexture(iconID);
			iconButton.name = iconName;
			iconButton:SetScript("OnClick", OnClickedIconSelectButton);

			if iconID == Addon.HERO_TALENTS_ICON then
				local atlas = iconInfo[3];
				iconButton.icon = atlas;
				iconButton.texture:SetAtlas(atlas);
			else
				iconButton.icon = iconID;
				iconButton.text:SetText(iconInfo[3] or tostring(iconIndex - 1));
			end
		end
	end

	parent:SetHeight(gridOffset * #Addon.icons + parent:GetHeight());
end
