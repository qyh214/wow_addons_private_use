-- By D4KiR
local _, SpecBisTooltip = ...
local s = {}
if SpecBisTooltip:GetWoWBuild() == "CATA" then
    function SpecBisTooltip:GetTranslationMap()
        return s
    end
end

-- SOURCE FROM: 10.03.2025
if SpecBisTooltip:GetWoWBuild() == "CATA" then
    function SpecBisTooltip:TranslationenUS()
        s["npc;sold=44245"] = {"Faldren Tillsdale <Valor Quartermaster>", "Stormwind City"}
        s["npc;drop=41376"] = {"Nefarian", "Blackwing Descent"}
        s["npc;drop=9056"] = {"Fineous Darkvire <Chief Architect>", "Blackrock Depths"}
        s["npc;drop=42178"] = {"Magmatron", "Blackwing Descent"}
        s["npc;drop=43296"] = {"Chimaeron", "Blackwing Descent"}
        s["npc;drop=44600"] = {"Halfus Wyrmbreaker", "The Bastion of Twilight"}
        s["npc;drop=45992"] = {"Valiona", "The Bastion of Twilight"}
        s["npc;sold=47328"] = {"Quartermaster Brazie <Baradin's Wardens Quartermaster>", "Tol Barad Peninsula"}
        s["npc;drop=41570"] = {"Magmaw", "Blackwing Descent"}
        s["npc;drop=43735"] = {"Elementium Monstrosity", "The Bastion of Twilight"}
        s["quest;reward=24919"] = {"The Lightbringer's Redemption", "Icecrown Citadel"}
        s["npc;drop=45213"] = {"Sinestra <Consort of Deathwing>", "The Bastion of Twilight"}
        s["npc;drop=45871"] = {"Nezir <Lord of the North Wind>", "Throne of the Four Winds"}
        s["npc;drop=46753"] = {"Al'Akir", "Throne of the Four Winds"}
        s["npc;drop=41378"] = {"Maloriak", "Blackwing Descent"}
        s["npc;drop=43324"] = {"Cho'gall", "The Bastion of Twilight"}
        s["npc;drop=41442"] = {"Atramedes", "Blackwing Descent"}
        s["npc;sold=48531"] = {"Pogg <Hellscream's Reach Quartermaster>", "Tol Barad Peninsula"}
        s["npc;drop=36853"] = {"Sindragosa <Queen of the Frostbrood>", "Icecrown Citadel"}
        s["spell;created=80508"] = {"Lifebound Alchemist Stone", "CRAFTING"}
        s["npc;drop=44577"] = {"General Husam", "Lost City of the Tol'vir"}
        s["spell;created=81714"] = {"Reinforced Bio-Optic Killshades", "CRAFTING"}
        s["npc;drop=39705"] = {"Ascendant Lord Obsidius", "Blackrock Caverns"}
        s["spell;created=76443"] = {"Hardened Elementium Hauberk", "CRAFTING"}
        s["spell;created=76444"] = {"Hardened Elementium Girdle", "CRAFTING"}
        s["npc;drop=47120"] = {"Argaloth", "Baradin Hold"}
        s["npc;sold=49386"] = {"Craw MacGraw <Wildhammer Clan Quartermaster>", "Twilight Highlands"}
        s["npc;drop=39788"] = {"Anraphet", "Halls of Origination"}
        s["npc;drop=39378"] = {"Rajh <Construct of the Sun>", "Halls of Origination"}
        s["npc;sold=48617"] = {"Blacksmith Abasi <Ramkahen Quartermaster>", "Uldum"}
        s["npc;sold=50314"] = {"Provisioner Whitecloud <Guardians of Hyjal Quartermaster>", "Mount Hyjal"}
        s["npc;drop=42188"] = {"Ozruk", "The Stonecore"}
        s["spell;created=86650"] = {"Notched Jawbone", "CRAFTING"}
        s["npc;drop=45261"] = {"Twilight Shadow Knight", "The Bastion of Twilight"}
        s["npc;drop=39801"] = {"Earth Warden", "Halls of Origination"}
        s["npc;drop=37217"] = {"Precious", "Icecrown Citadel"}
        s["npc;drop=50061"] = {"Xariona", "Deepholm"}
        s["npc;drop=50060"] = {"Terborus", "Deepholm"}
        s["npc;drop=50063"] = {"Akma'hat <Dirge of the Eternal Sands>", "Uldum"}
        s["spell;created=73503"] = {"Elementium Moebius Band", "CRAFTING"}
        s["npc;drop=39732"] = {"Setesh <Construct of Destruction>", "Halls of Origination"}
        s["npc;sold=44246"] = {"Magatha Silverton <Justice Quartermaster>", "Stormwind City"}
        s["npc;drop=46964"] = {"Lord Godfrey", "Shadowfang Keep"}
        s["npc;drop=49045"] = {"Augh", "Lost City of the Tol'vir"}
        s["npc;drop=44566"] = {"Ozumat <Fiend of the Dark Below>", "Throne of the Tides"}
        s["npc;sold=49387"] = {"Grot Deathblow <Dragonmaw Clan Quartermaster>", "Twilight Highlands"}
        s["spell;created=73506"] = {"Elementium Guardian", "CRAFTING"}
        s["npc;sold=45408"] = {"D'lom the Collector <Therazane Quartermaster>", "Deepholm"}
        s["npc;drop=42333"] = {"High Priestess Azil", "The Stonecore"}
        s["spell;created=73641"] = {"Figurine - Earthen Guardian", "CRAFTING"}
        s["npc;drop=40484"] = {"Erudax <The Duke of Below>", "Grim Batol"}
        s["spell;created=94732"] = {"Forged Elementium Mindcrusher", "CRAFTING"}
        s["npc;drop=43214"] = {"Slabhide", "The Stonecore"}
        s["spell;created=76445"] = {"Elementium Deathplate", "CRAFTING"}
        s["spell;created=76446"] = {"Elementium Girdle of Pain", "CRAFTING"}
        s["npc;drop=49813"] = {"Evolved Drakonaar", "The Bastion of Twilight"}
        s["npc;drop=40788"] = {"Mindbender Ghur'sha", "Throne of the Tides"}
        s["npc;drop=47296"] = {"Helix Gearbreaker", "The Deadmines"}
        s["npc;drop=49541"] = {"Vanessa VanCleef", "The Deadmines"}
        s["npc;drop=47162"] = {"Glubtok <The Foreman>", "The Deadmines"}
        s["npc;drop=40765"] = {"Commander Ulthok <The Festering Prince>", "Throne of the Tides"}
        s["npc;drop=39698"] = {"Karsh Steelbender <Twilight Armorer>", "Blackrock Caverns"}
        s["npc;drop=50056"] = {"Garr", "Mount Hyjal"}
        s["npc;drop=40177"] = {"Forgemaster Throngus", "Grim Batol"}
        s["npc;drop=39731"] = {"Ammunae <Construct of Life>", "Halls of Origination"}
        s["npc;drop=3887"] = {"Baron Silverlaine", "Shadowfang Keep"}
        s["npc;drop=39679"] = {"Corla, Herald of Twilight", "Blackrock Caverns"}
        s["npc;drop=39587"] = {"Isiset <Construct of Magic>", "Halls of Origination"}
        s["npc;drop=47739"] = {"'Captain' Cookie <Defias Kingpin?>", "The Deadmines"}
        s["npc;drop=43612"] = {"High Prophet Barim", "Lost City of the Tol'vir"}
        s["npc;drop=45993"] = {"Theralion", "The Bastion of Twilight"}
        s["quest;reward=27664"] = {"Darkmoon Volcanic Deck", "Elwynn Forest"}
        s["npc;drop=42180"] = {"Toxitron", "Blackwing Descent"}
        s["spell;created=81722"] = {"Agile Bio-Optic Killshades", "CRAFTING"}
        s["npc;drop=23863"] = {"Daakara <The Invincible>", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Dragonhawk Avatar>", "Zul'Aman"}
        s["spell;created=78461"] = {"Belt of Nefarious Whispers", "CRAFTING"}
        s["npc;drop=42767"] = {"Ivoroc", "Blackwing Descent"}
        s["npc;drop=52151"] = {"Bloodlord Mandokir", "Zul'Gurub"}
        s["npc;sold=50324"] = {"Provisioner Arok <Earthen Ring Quartermaster>", "Shimmering Expanse"}
        s["npc;drop=43438"] = {"Corborus", "The Stonecore"}
        s["npc;drop=50009"] = {"Mobus <The Crushing Tide>", "Abyssal Depths"}
        s["npc;sold=46594"] = {"Sergeant Thunderhorn <Conquest Quartermaster>", "Orgrimmar"}
        s["npc;drop=52148"] = {"Jin'do the Godbreaker", "Zul'Gurub"}
        s["spell;created=86653"] = {"Silver Inlaid Leaf", "CRAFTING"}
        s["npc;drop=23577"] = {"Halazzi <Lynx Avatar>", "Zul'Aman"}
        s["object;contained=186648"] = {"Hazlek's Trunk", "Zul'Aman"}
        s["spell;created=78488"] = {"Assassin's Chestplate", "CRAFTING"}
        s["npc;drop=24239"] = {"Hex Lord Malacrass", "Zul'Aman"}
        s["npc;drop=46963"] = {"Lord Walden", "Shadowfang Keep"}
        s["npc;drop=39425"] = {"Temple Guardian Anhuur", "Halls of Origination"}
        s["npc;drop=23586"] = {"Amani'shi Scout", "Zul'Aman"}
        s["npc;drop=43875"] = {"Asaad <Caliph of Zephyrs>", "The Vortex Pinnacle"}
        s["object;contained=186667"] = {"Norkani's Package", "Zul'Aman"}
        s["npc;drop=39700"] = {"Beauty", "Blackrock Caverns"}
        s["npc;drop=52258"] = {"Gri'lek", "Zul'Gurub"}
        s["npc;drop=46962"] = {"Baron Ashbury", "Shadowfang Keep"}
        s["spell;created=73521"] = {"Brazen Elementium Medallion", "CRAFTING"}
        s["npc;drop=39428"] = {"Earthrager Ptah", "Halls of Origination"}
        s["spell;created=73498"] = {"Band of Blades", "CRAFTING"}
        s["npc;drop=44819"] = {"Siamat <Lord of the South Wind>", "Lost City of the Tol'vir"}
        s["spell;created=76451"] = {"Elementium Poleaxe", "CRAFTING"}
        s["npc;drop=4278"] = {"Commander Springvale", "Shadowfang Keep"}
        s["spell;created=81724"] = {"Camouflage Bio-Optic Killshades", "CRAFTING"}
        s["npc;drop=42803"] = {"Drakeadon Mongrel", "Blackwing Descent"}
        s["npc;drop=43125"] = {"Spirit of Moltenfist", "Blackwing Descent"}
        s["spell;created=78487"] = {"Chestguard of Nature's Fury", "CRAFTING"}
        s["spell;created=78460"] = {"Lightning Lash", "CRAFTING"}
        s["quest;reward=27666"] = {"Darkmoon Tsunami Deck", "Elwynn Forest"}
        s["spell;created=96254"] = {"Vibrant Alchemist Stone", "CRAFTING"}
        s["npc;drop=43122"] = {"Spirit of Corehammer", "Blackwing Descent"}
        s["spell;created=86652"] = {"Tattooed Eyeball", "CRAFTING"}
        s["npc;drop=43873"] = {"Altairus", "The Vortex Pinnacle"}
        s["npc;drop=40586"] = {"Lady Naz'jar", "Throne of the Tides"}
        s["npc;drop=40319"] = {"Drahga Shadowburner <Twilight's Hammer Courier>", "Grim Batol"}
        s["npc;drop=39625"] = {"General Umbriss <Servant of Deathwing>", "Grim Batol"}
        s["npc;drop=50057"] = {"Blazewing", "Mount Hyjal"}
        s["npc;drop=50086"] = {"Tarvus the Vile", "Twilight Highlands"}
        s["spell;created=73505"] = {"Eye of Many Deaths", "CRAFTING"}
        s["spell;created=73502"] = {"Ring of Warring Elements", "CRAFTING"}
        s["quest;reward=28267"] = {"Firing Squad", "Uldum"}
        s["npc;drop=43778"] = {"Foe Reaper 5000", "The Deadmines"}
        s["spell;created=76450"] = {"Elementium Hammer", "CRAFTING"}
        s["npc;drop=39665"] = {"Rom'ogg Bonecrusher", "Blackrock Caverns"}
        s["npc;drop=43878"] = {"Grand Vizier Ertan", "The Vortex Pinnacle"}
        s["spell;created=86642"] = {"Divine Companion", "CRAFTING"}
        s["spell;created=81716"] = {"Deadly Bio-Optic Killshades", "CRAFTING"}
        s["spell;created=78435"] = {"Razorshell Chest", "CRAFTING"}
        s["quest;reward=28854"] = {"Closing a Dark Chapter", "Grim Batol"}
        s["spell;created=78463"] = {"Corded Viper Belt", "CRAFTING"}
        s["spell;created=73520"] = {"Elementium Destroyer's Ring", "CRAFTING"}
        s["quest;reward=27665"] = {"Darkmoon Hurricane Deck", "Elwynn Forest"}
        s["npc;drop=47626"] = {"Admiral Ripsnarl", "The Deadmines"}
        s["spell;created=84432"] = {"Kickback 5000", "CRAFTING"}
        s["spell;created=84431"] = {"Overpowered Chicken Splitter", "CRAFTING"}
        s["npc;sold=46595"] = {"Blood Guard Zar'shi <Honor Quartermaster>", "Orgrimmar"}
        s["spell;created=78490"] = {"Dragonkiller Tunic", "CRAFTING"}
        s["npc;drop=42800"] = {"Golem Sentry", "Blackwing Descent"}
        s["spell;created=81725"] = {"Lightweight Bio-Optic Killshades", "CRAFTING"}
        s["spell;created=75299"] = {"Dreamless Belt", "CRAFTING"}
        s["npc;drop=39415"] = {"Ascended Flameseeker", "Grim Batol"}
        s["npc;drop=52269"] = {"Renataki", "Zul'Gurub"}
        s["npc;drop=50089"] = {"Julak-Doom <The Eye of Zor>", "Twilight Highlands"}
        s["spell;created=75300"] = {"Breeches of Mended Nightmares", "CRAFTING"}
        s["spell;created=76449"] = {"Elementium Spellblade", "CRAFTING"}
        s["spell;created=86641"] = {"Dungeoneering Guide", "CRAFTING"}
        s["quest;reward=28753"] = {"Doing it the Hard Way", "Halls of Origination"}
        s["spell;created=81715"] = {"Specialized Bio-Optic Killshades", "CRAFTING"}
        s["spell;created=76447"] = {"Light Elementium Chestguard", "CRAFTING"}
        s["spell;created=76448"] = {"Light Elementium Belt", "CRAFTING"}
        s["spell;created=76455"] = {"Elementium Stormshield", "CRAFTING"}
        s["npc;drop=50050"] = {"Shok'sharak", "Abyssal Depths"}
        s["spell;created=76454"] = {"Elementium Earthguard", "CRAFTING"}
        s["npc;drop=52053"] = {"Zanzil", "Zul'Gurub"}
        s["npc;drop=23576"] = {"Nalorakk <Bear Avatar>", "Zul'Aman"}
        s["npc;drop=42802"] = {"Drakonid Slayer", "Blackwing Descent"}
        s["npc;sold=228668"] = {"Glorious Conquest Vendor", "Orgrimmar"}
        s["spell;created=98921"] = {"Punisher's Band", "CRAFTING"}
        s["spell;created=73639"] = {"Figurine - King of Boars", "CRAFTING"}
        s["spell;created=96252"] = {"Volatile Alchemist Stone", "CRAFTING"}
        s["npc;drop=46083"] = {"Drakeadon Mongrel", "Blackwing Descent"}
        s["spell;created=75298"] = {"Belt of the Depths", "CRAFTING"}
        s["spell;created=75301"] = {"Flame-Ascended Pantaloons", "CRAFTING"}
        s["npc;drop=48450"] = {"Sunwing Squawker", "The Deadmines"}
        s["spell;created=75266"] = {"Spiritmend Cowl", "CRAFTING"}
        s["quest;reward=28783"] = {"The Source of Their Power", "Lost City of the Tol'vir"}
        s["spell;created=75260"] = {"Spiritmend Shoulders", "CRAFTING"}
        s["npc;drop=52345"] = {"Pride of Bethekk", "Zul'Gurub"}
        s["quest;reward=27788"] = {"Skullcrusher the Mountain", "Twilight Highlands"}
        s["spell;created=75267"] = {"Spiritmend Robe", "CRAFTING"}
        s["spell;created=75259"] = {"Spiritmend Bracers", "CRAFTING"}
        s["npc;drop=24138"] = {"Tamed Amani Crocolisk", "Zul'Aman"}
        s["spell;created=75262"] = {"Spiritmend Gloves", "CRAFTING"}
        s["spell;created=75258"] = {"Spiritmend Belt", "CRAFTING"}
        s["npc;drop=23574"] = {"Akil'zon <Eagle Avatar>", "Zul'Aman"}
        s["npc;drop=40167"] = {"Twilight Beguiler <The Twilight's Hammer>", "Grim Batol"}
        s["spell;created=75263"] = {"Spiritmend Leggings", "CRAFTING"}
        s["spell;created=75261"] = {"Spiritmend Boots", "CRAFTING"}
        s["npc;drop=42764"] = {"Pyrecraw", "Blackwing Descent"}
        s["spell;created=73643"] = {"Figurine - Dream Owl", "CRAFTING"}
        s["quest;reward=28170"] = {"Night Terrors", "Twilight Highlands"}
        s["quest;reward=27868"] = {"The Crucible of Carnage: The Twilight Terror!", "Twilight Highlands"}
        s["quest;reward=28595"] = {"Krazz Works!", "Twilight Highlands"}
        s["spell;created=73642"] = {"Figurine - Jeweled Serpent", "CRAFTING"}
        s["npc;drop=43614"] = {"Lockmaw", "Lost City of the Tol'vir"}
        s["npc;drop=39803"] = {"Air Warden", "Halls of Origination"}
        s["spell;created=96253"] = {"Quicksilver Alchemist Stone", "CRAFTING"}
        s["spell;created=76453"] = {"Elementium Shank", "CRAFTING"}
        s["spell;created=73640"] = {"Figurine - Demon Panther", "CRAFTING"}
        s["quest;reward=11196"] = {"Warlord of the Amani", "Zul'Aman"}
        s["npc;drop=42362"] = {"Drakonid Drudge", "Blackwing Descent"}
        s["spell;created=94718"] = {"Elementium Gutslicer", "CRAFTING"}
        s["npc;drop=52271"] = {"Hazza'rah", "Zul'Gurub"}
        s["spell;created=81720"] = {"Energized Bio-Optic Killshades", "CRAFTING"}
        s["spell;created=78489"] = {"Twilight Scale Chestguard", "CRAFTING"}
        s["spell;created=78462"] = {"Stormleather Sash", "CRAFTING"}
        s["npc;drop=45687"] = {"Twilight-Shifter <The Twilight's Hammer>", "The Bastion of Twilight"}
        s["quest;reward=28853"] = {"Kill the Courier", "Grim Batol"}
        s["npc;drop=39440"] = {"Venomous Skitterer", "Halls of Origination"}
        s["npc;drop=47720"] = {"Camel", "Lost City of the Tol'vir"}
        s["npc;drop=42789"] = {"Stonecore Magmalord", "The Stonecore"}
        s["quest;reward=27659"] = {"Portal Overload", "Twilight Highlands"}
        s["quest;reward=27748"] = {"Fortune and Glory", "Uldum"}
        s["npc;drop=45007"] = {"Enslaved Bandit", "Lost City of the Tol'vir"}
        s["quest;reward=26876"] = {"The World Pillar Fragment", "Deepholm"}
        s["npc;drop=39855"] = {"Azureborne Seer <Servant of Deathwing>", "Grim Batol"}
        s["spell;created=75257"] = {"Deathsilk Robe", "CRAFTING"}
        s["quest;reward=26830"] = {"Traitor's Bait", "Orgrimmar"}
        s["quest;reward=27106"] = {"A Villain Unmasked", "Stormwind City"}
        s["quest;reward=28133"] = {"Fury Unbound", "Twilight Highlands"}
        s["quest;reward=28282"] = {"Narkrall, The Drake-Tamer", "Twilight Highlands"}
        s["quest;reward=27745"] = {"A Fiery Reunion", "Twilight Highlands"}
        s["quest;reward=28758"] = {"Battle of Life and Death", "Twilight Highlands"}
        s["quest;reward=26971"] = {"The Binding", "Deepholm"}
        s["quest;reward=27651"] = {"Doing It Like a Dunwald", "Twilight Highlands"}
        s["npc;drop=52418"] = {"Lost Offspring of Gahz'ranka", "Zul'Gurub"}
        s["quest;reward=29186"] = {"The Hex Lord's Fetish", "Zul'Aman"}
        s["quest;reward=28480"] = {"Lieutenants of Darkness", "Uldum"}
        s["spell;created=99439"] = {"Fists of Fury", "CRAFTING"}
        s["object;contained=188192"] = {"Ice Chest", "The Slave Pens"}
        s["spell;created=78476"] = {"Twilight Dragonscale Cloak", "CRAFTING"}
        s["quest;reward=28612"] = {"Harrison Jones and the Temple of Uldum", "Uldum"}
        s["npc;drop=52322"] = {"Witch Doctor Qu'in <Medicine Woman>", "Zul'Gurub"}
        s["npc;drop=23584"] = {"Amani Bear", "Zul'Aman"}
        s["quest;reward=27667"] = {"Darkmoon Earthquake Deck", "Elwynn Forest"}
        s["quest;reward=27652"] = {"Dark Assassins", "Twilight Highlands"}
        s["quest;reward=27653"] = {"Dark Assassins", "Twilight Highlands"}
        s["npc;drop=52363"] = {"Occu'thar", "Baradin Hold"}
        s["spell;created=99452"] = {"Warboots of Mighty Lords", "CRAFTING"}
        s["spell;created=54982"] = {"Create Purple Trophy Tabard of the Illidari", "CRAFTING"}
        s["npc;sold=54401"] = {"Naresir Stormfury <Avengers of Hyjal Quartermaster>", "Mount Hyjal"}
        s["npc;sold=53882"] = {"Varlan Highbough <Provisions of the Grove>", "Molten Front"}
        s["spell;created=99654"] = {"Lightforged Elementium Hammer", "CRAFTING"}
        s["npc;sold=53881"] = {"Ayla Shadowstorm <Treasures of Elune>", "Molten Front"}
        s["spell;created=99457"] = {"Treads of the Craft", "CRAFTING"}
        s["spell;created=99446"] = {"Clutches of Evil", "CRAFTING"}
        s["spell;created=99660"] = {"Witch-Hunter's Harvester", "CRAFTING"}
        s["spell;created=99458"] = {"Ethereal Footfalls", "CRAFTING"}
        s["npc;sold=52822"] = {"Zen'Vorka <Favors of the World Tree>", "Molten Front"}
        s["spell;created=100687"] = {"Extreme-Impact Hole Puncher", "CRAFTING"}
        s["spell;created=99460"] = {"Boots of the Black Flame", "CRAFTING"}
        s["spell;created=99653"] = {"Masterwork Elementium Spellblade", "CRAFTING"}
        s["npc;sold=53214"] = {"Damek Bloombeard <Exceptional Equipment>", "Molten Front"}
        s["spell;created=99459"] = {"Endless Dream Walkers", "CRAFTING"}
        s["spell;created=99455"] = {"Earthen Scale Sabatons", "CRAFTING"}
        s["spell;created=99449"] = {"Don Tayo's Inferno Mittens", "CRAFTING"}
        s["spell;created=99657"] = {"Unbreakable Guardian", "CRAFTING"}
        s["npc;sold=54402"] = {"Lurah Wrathvine <Crystallized Firestone Collector>", "Mount Hyjal"}
        s["npc;drop=52409"] = {"Ragnaros", "Firelands"}
        s["npc;drop=52571"] = {"Majordomo Staghelm <Archdruid of the Flame>", "Firelands"}
        s["npc;drop=53691"] = {"Shannox", "Firelands"}
        s["npc;drop=52498"] = {"Beth'tilac <The Red Widow>", "Firelands"}
        s["npc;drop=52558"] = {"Lord Rhyolith", "Firelands"}
        s["npc;drop=52530"] = {"Alysrazor", "Firelands"}
        s["npc;drop=53494"] = {"Baleroc <The Gatekeeper>", "Firelands"}
        s["quest;reward=29331"] = {"Elemental Bonds: The Vow", "Mount Hyjal"}
        s["npc;drop=53616"] = {"Kar the Everburning <Firelord>", "Firelands"}
        s["npc;drop=54161"] = {"Flame Archon", "Firelands"}
        s["npc;sold=52549"] = {"Sergeant Thunderhorn <Conquest Quartermaster>", "Orgrimmar"}
        s["quest;reward=29312"] = {"The Stuff of Legends", "Stormwind City"}
        s["npc;drop=55689"] = {"Hagara the Stormbinder", "Dragon Soul"}
        s["npc;drop=55308"] = {"Warlord Zon'ozz", "Dragon Soul"}
        s["npc;drop=55265"] = {"Morchok", "Dragon Soul"}
        s["npc;drop=55294"] = {"Ultraxion", "Dragon Soul"}
        s["npc;drop=55312"] = {"Yor'sahj the Unsleeping", "Dragon Soul"}
        s["npc;drop=56173"] = {"Deathwing <The Destroyer>", "Dragon Soul"}
        s["npc;drop=57821"] = {"Lieutenant Shara <The Twilight's Hammer>", "Dragon Soul"}
        s["spell;created=101932"] = {"Titanguard Wristplates", "CRAFTING"}
        s["npc;sold=241467"] = {"Sylstrasza <Obsidian Fragment Exchange>", "Orgrimmar"}
        s["npc;drop=54938"] = {"Archbishop Benedictus", "Hour of Twilight"}
        s["npc;drop=53879"] = {"Deathwing <The Destroyer>", "Dragon Soul"}
        s["spell;created=101925"] = {"Unstoppable Destroyer's Legplates", "CRAFTING"}
        s["spell;created=101931"] = {"Bracers of Destructive Strength", "CRAFTING"}
        s["spell;created=101933"] = {"Leggings of Nature's Champion", "CRAFTING"}
        s["spell;created=101937"] = {"Bracers of Flowing Serenity", "CRAFTING"}
        s["npc;drop=56427"] = {"Warmaster Blackhorn", "Dragon Soul"}
        s["spell;created=101940"] = {"Bladeshadow Wristguards", "CRAFTING"}
        s["spell;created=101941"] = {"Bracers of the Hunter-Killer", "CRAFTING"}
        s["spell;created=101921"] = {"Lavaquake Legwraps", "CRAFTING"}
        s["spell;created=101923"] = {"Bracers of Unconquered Power", "CRAFTING"}
        s["spell;created=101929"] = {"Soul Redeemer Bracers", "CRAFTING"}
        s["npc;drop=55869"] = {"Alizabal <Mistress of Hate>", "Baradin Hold"}
        s["spell;created=101922"] = {"Dreamwraps of the Light", "CRAFTING"}
        s["spell;created=101934"] = {"Deathscale Leggings", "CRAFTING"}
        s["spell;created=101939"] = {"Thundering Deathscale Wristguards", "CRAFTING"}
        s["npc;drop=55085"] = {"Peroth'arn", "Well of Eternity"}
        s["quest;reward=30118"] = {"Patricide", "Dragon Soul"}
        s["spell;created=101935"] = {"Bladeshadow Leggings", "CRAFTING"}
        s["npc;sold=54658"] = {"Sergeant Thunderhorn <Conquest Quartermaster>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationdeDE()
        s["npc;sold=44245"] = {"Faldren Tillsdale <Rüstmeister für Tapferkeitspunkte>", "Sturmwind"}
        s["npc;drop=9056"] = {"Fineous Dunkelader <Chefarchitekt>", "Schwarzfelstiefen"}
        s["npc;drop=43296"] = {"Schimaeron", "Pechschwingenabstieg"}
        s["npc;drop=44600"] = {"Halfus Wyrmbrecher", "Die Bastion des Zwielichts"}
        s["npc;sold=47328"] = {"Rüstmeister Brazie <Rüstmeister der Wächter von Baradin>", "Halbinsel von Tol Barad"}
        s["npc;drop=41570"] = {"Magmaul", "Pechschwingenabstieg"}
        s["npc;drop=43735"] = {"Elementiumungeheuer", "Die Bastion des Zwielichts"}
        s["quest;reward=24919"] = {"Die Erlösung des Lichtbringers", "Eiskronenzitadelle"}
        s["npc;drop=45213"] = {"Sinestra <Gefährtin von Todesschwinge>", "Die Bastion des Zwielichts"}
        s["npc;drop=45871"] = {"Nezir <Herrscher des Nordwinds>", "Thron der Vier Winde"}
        s["npc;sold=48531"] = {"Pogg <Rüstmeister von Höllschreis Hand>", "Halbinsel von Tol Barad"}
        s["npc;drop=36853"] = {"Sindragosa <Königin der Frostbrut>", "Eiskronenzitadelle"}
        s["spell;created=80508"] = {"Lebensgebundener Alchemistenstein", "CRAFTING"}
        s["spell;created=81714"] = {"Verstärkte bio-optische Umnietbrille", "CRAFTING"}
        s["npc;drop=39705"] = {"Aszendentenfürst Obsidius", "Schwarzfelshöhlen"}
        s["spell;created=76443"] = {"Gehärtete Elementiumhalsberge", "CRAFTING"}
        s["spell;created=76444"] = {"Gehärteter Elementiumgurt", "CRAFTING"}
        s["npc;sold=49386"] = {"Craw MacGraw <Rüstmeister des Wildhammerklans>", "Schattenhochland"}
        s["npc;drop=39378"] = {"Rajh <Konstrukt der Sonne>", "Hallen des Ursprungs"}
        s["npc;sold=48617"] = {"Schmied Abasi <Rüstmeister von Ramkahen>", "Uldum"}
        s["npc;sold=50314"] = {"Versorgerin Wolkenweiß <Rüstmeister der Wächter des Hyjal>", "Hyjal"}
        s["spell;created=86650"] = {"Eingekerbter Kieferknochen", "CRAFTING"}
        s["npc;drop=45261"] = {"Zwielichtschattenkrieger", "Die Bastion des Zwielichts"}
        s["npc;drop=39801"] = {"Erdwächter", "Hallen des Ursprungs"}
        s["npc;drop=37217"] = {"Schatz", "Eiskronenzitadelle"}
        s["npc;drop=50063"] = {"Akma'hat <Klagelied der Ewigen Sande>", "Uldum"}
        s["spell;created=73503"] = {"Elementiummöbiusband", "CRAFTING"}
        s["npc;drop=39732"] = {"Setesh <Konstrukt der Dekonstruktion>", "Hallen des Ursprungs"}
        s["npc;sold=44246"] = {"Magatha Silverton <Rüstmeisterin für Gerechtigkeitspunkte>", "Sturmwind"}
        s["npc;drop=44566"] = {"Ozumat <Scheusal der Finsteren Tiefen>", "Thron der Gezeiten"}
        s["npc;sold=49387"] = {"Grot Todesstoß <Rüstmeister des Drachenmalklans>", "Schattenhochland"}
        s["spell;created=73506"] = {"Elementiumwächter", "CRAFTING"}
        s["npc;sold=45408"] = {"D'lom der Sammler <Rüstmeister von Therazane>", "Tiefenheim"}
        s["npc;drop=42333"] = {"Hohepriesterin Azil", "Der Steinerne Kern"}
        s["spell;created=73641"] = {"Figur - Irdener Wächter", "CRAFTING"}
        s["npc;drop=40484"] = {"Erudax <Der Herzog der Tiefe>", "Grim Batol"}
        s["spell;created=94732"] = {"Geschmiedeter Elementiumwillensbrecher", "CRAFTING"}
        s["npc;drop=43214"] = {"Plattenhaut", "Der Steinerne Kern"}
        s["spell;created=76445"] = {"Elementiumtodesplatte", "CRAFTING"}
        s["spell;created=76446"] = {"Elementiumgurt des Schmerzes", "CRAFTING"}
        s["npc;drop=49813"] = {"Evolvierter Drakonaar", "Die Bastion des Zwielichts"}
        s["npc;drop=40788"] = {"Geistbeuger Ghur'sha", "Thron der Gezeiten"}
        s["npc;drop=47296"] = {"Helix Ritzelbrecher", "Die Todesminen"}
        s["npc;drop=49541"] = {"Vanessa van Cleef", "Die Todesminen"}
        s["npc;drop=47162"] = {"Glubtok <Der Vorarbeiter>", "Die Todesminen"}
        s["npc;drop=40765"] = {"Kommandant Ulthok <Der verfaulende Prinz>", "Thron der Gezeiten"}
        s["npc;drop=39698"] = {"Karsh Stahlbieger <Zwielichtschmied>", "Schwarzfelshöhlen"}
        s["npc;drop=40177"] = {"Schmiedemeister Throngus", "Grim Batol"}
        s["npc;drop=39731"] = {"Ammunae <Konstrukt des Lebens>", "Hallen des Ursprungs"}
        s["npc;drop=3887"] = {"Baron Silberlein", "Burg Schattenfang"}
        s["npc;drop=39679"] = {"Corla, Botin des Zwielichts", "Schwarzfelshöhlen"}
        s["npc;drop=39587"] = {"Isiset <Konstrukt der Magie>", "Hallen des Ursprungs"}
        s["npc;drop=47739"] = {"'Kapitän' Krümel <Hohes Tier der Defias?>", "Die Todesminen"}
        s["npc;drop=43612"] = {"Hochprophet Barim", "Die Verlorene Stadt der Tol'vir"}
        s["quest;reward=27664"] = {"Vulkankartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["spell;created=81722"] = {"Agile bio-optische Umnietbrille", "CRAFTING"}
        s["npc;drop=23863"] = {"Daakara <Der Unbesiegbare>", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Avatar des Drachenfalken>", "Zul'Aman"}
        s["spell;created=78461"] = {"Gürtel des schändlichen Geflüsters", "CRAFTING"}
        s["npc;drop=52151"] = {"Blutfürst Mandokir", "Zul'Gurub"}
        s["npc;sold=50324"] = {"Versorger Arok <Rüstmeister des Irdenen Rings>", "Schimmernde Weiten"}
        s["npc;drop=50009"] = {"Mobus <Der Wellenbrecher>", "Abyssische Tiefen"}
        s["npc;sold=46594"] = {"Unteroffizier Donnerhorn <Rüstmeister für Eroberungspunkte>", "Orgrimmar"}
        s["npc;drop=52148"] = {"Jin'do der Götterbrecher", "Zul'Gurub"}
        s["spell;created=86653"] = {"Blatt mit Silberintarsien", "CRAFTING"}
        s["npc;drop=23577"] = {"Halazzi <Avatar des Luchses>", "Zul'Aman"}
        s["object;contained=186648"] = {"Hazleks Koffer", "Zul'Aman"}
        s["spell;created=78488"] = {"Brustplatte des Assassinen", "CRAFTING"}
        s["npc;drop=24239"] = {"Hexlord Malacrass", "Zul'Aman"}
        s["npc;drop=39425"] = {"Tempelwächter Anhuur", "Hallen des Ursprungs"}
        s["npc;drop=23586"] = {"Späher der Amani'shi", "Zul'Aman"}
        s["npc;drop=43875"] = {"Asaad <Kalif der Zephyre>", "Der Vortexgipfel"}
        s["object;contained=186667"] = {"Norkanis Päckchen", "Zul'Aman"}
        s["npc;drop=39700"] = {"Bella", "Schwarzfelshöhlen"}
        s["spell;created=73521"] = {"Mutiges Elementiummedaillon", "CRAFTING"}
        s["npc;drop=39428"] = {"Erdwüter Ptah", "Hallen des Ursprungs"}
        s["spell;created=73498"] = {"Band der Klingen", "CRAFTING"}
        s["npc;drop=44819"] = {"Siamat <Herrscher des Südwinds>", "Die Verlorene Stadt der Tol'vir"}
        s["spell;created=76451"] = {"Elementiumstangenaxt", "CRAFTING"}
        s["npc;drop=4278"] = {"Kommandant Grüntal", "Burg Schattenfang"}
        s["spell;created=81724"] = {"Tarnende bio-optische Umnietbrille", "CRAFTING"}
        s["npc;drop=42803"] = {"Bastard von Drakeadon", "Pechschwingenabstieg"}
        s["npc;drop=43125"] = {"Geist von Glutfaust", "Pechschwingenabstieg"}
        s["spell;created=78487"] = {"Brustschutz des Naturzorns", "CRAFTING"}
        s["spell;created=78460"] = {"Blitzpeitsche", "CRAFTING"}
        s["quest;reward=27666"] = {"Tsunamikartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["spell;created=96254"] = {"Leuchtender Alchemistenstein", "CRAFTING"}
        s["npc;drop=43122"] = {"Geist von Kernhammer", "Pechschwingenabstieg"}
        s["spell;created=86652"] = {"Tätowierter Augapfel", "CRAFTING"}
        s["npc;drop=40319"] = {"Drahga Schattenbrenner <Kurier des Schattenhammers>", "Grim Batol"}
        s["npc;drop=39625"] = {"General Umbriss <Diener von Todesschwinge>", "Grim Batol"}
        s["npc;drop=50057"] = {"Flammenschwinge", "Hyjal"}
        s["npc;drop=50086"] = {"Tarvus der Üble", "Schattenhochland"}
        s["spell;created=73505"] = {"Auge der vielen Tode", "CRAFTING"}
        s["spell;created=73502"] = {"Ring der streitenden Elemente", "CRAFTING"}
        s["quest;reward=28267"] = {"Erschießungskommando", "Uldum"}
        s["npc;drop=43778"] = {"Feindschnitter 5000", "Die Todesminen"}
        s["spell;created=76450"] = {"Elementiumhammer", "CRAFTING"}
        s["npc;drop=39665"] = {"Rom'ogg Knochenbrecher", "Schwarzfelshöhlen"}
        s["npc;drop=43878"] = {"Großwesir Ertan", "Der Vortexgipfel"}
        s["spell;created=86642"] = {"Göttlicher Begleiter", "CRAFTING"}
        s["spell;created=81716"] = {"Tödliche bio-optische Umnietbrille", "CRAFTING"}
        s["spell;created=78435"] = {"Rasiermessermuschelbrustrüstung", "CRAFTING"}
        s["quest;reward=28854"] = {"Der Abschluss eines finsteren Kapitels", "Grim Batol"}
        s["spell;created=78463"] = {"Gerippter Viperngürtel", "CRAFTING"}
        s["spell;created=73520"] = {"Ring des Elementiumzerstörers", "CRAFTING"}
        s["quest;reward=27665"] = {"Hurrikankartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["npc;drop=47626"] = {"Admiral Knurrreißer", "Die Todesminen"}
        s["spell;created=84432"] = {"Rückstoß 5000", "CRAFTING"}
        s["spell;created=84431"] = {"Übermotorisierter Hühnerspalter", "CRAFTING"}
        s["npc;sold=46595"] = {"Blutwache Zar'shi <Rüstmeister für Ehrenpunkte>", "Orgrimmar"}
        s["spell;created=78490"] = {"Drachentötertunika", "CRAFTING"}
        s["npc;drop=42800"] = {"Golemwachposten", "Pechschwingenabstieg"}
        s["spell;created=81725"] = {"Leichte bio-optische Umnietbrille", "CRAFTING"}
        s["spell;created=75299"] = {"Traumloser Gürtel", "CRAFTING"}
        s["npc;drop=39415"] = {"Aufgestiegener Flammensucher", "Grim Batol"}
        s["npc;drop=50089"] = {"Julak-Doom <Das Auge von Zor>", "Schattenhochland"}
        s["spell;created=75300"] = {"Bundhose der besänftigten Alpträume", "CRAFTING"}
        s["spell;created=76449"] = {"Elementiumzauberklinge", "CRAFTING"}
        s["spell;created=86641"] = {"Handbuch der Dungeonerkundung", "CRAFTING"}
        s["quest;reward=28753"] = {"Auf die harte Tour", "Hallen des Ursprungs"}
        s["spell;created=81715"] = {"Spezialisierte bio-optische Umnietbrille", "CRAFTING"}
        s["spell;created=76447"] = {"Leichter Elementiumbrustschutz", "CRAFTING"}
        s["spell;created=76448"] = {"Leichter Elementiumgürtel", "CRAFTING"}
        s["spell;created=76455"] = {"Elementiumsturmschild", "CRAFTING"}
        s["spell;created=76454"] = {"Elementiumerdwächter", "CRAFTING"}
        s["npc;drop=23576"] = {"Nalorakk <Avatar des Bären>", "Zul'Aman"}
        s["npc;drop=42802"] = {"Schlächter der Drakoniden", "Pechschwingenabstieg"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Orgrimmar"}
        s["spell;created=98921"] = {"Band des Bestrafers", "CRAFTING"}
        s["spell;created=73639"] = {"Figur - König der Eber", "CRAFTING"}
        s["spell;created=96252"] = {"Flüchtiger Alchemistenstein", "CRAFTING"}
        s["npc;drop=46083"] = {"Bastard von Drakeadon", "Pechschwingenabstieg"}
        s["spell;created=75298"] = {"Gürtel der Tiefen", "CRAFTING"}
        s["spell;created=75301"] = {"Flammenentstiegene Pantalons", "CRAFTING"}
        s["npc;drop=48450"] = {"Sonnenschwingenkrächzer", "Die Todesminen"}
        s["spell;created=75266"] = {"Geistheilergugel", "CRAFTING"}
        s["quest;reward=28783"] = {"Die Quelle ihrer Macht", "Die Verlorene Stadt der Tol'vir"}
        s["spell;created=75260"] = {"Geistheilerschultern", "CRAFTING"}
        s["npc;drop=52345"] = {"Bethekks Rudeltier", "Zul'Gurub"}
        s["quest;reward=27788"] = {"Schädelberster der Berg", "Schattenhochland"}
        s["spell;created=75267"] = {"Geistheilerrobe", "CRAFTING"}
        s["spell;created=75259"] = {"Geistheilerarmschienen", "CRAFTING"}
        s["npc;drop=24138"] = {"Gezähmter Krokilisk der Amani", "Zul'Aman"}
        s["spell;created=75262"] = {"Geistheilerhandschuhe", "CRAFTING"}
        s["spell;created=75258"] = {"Geistheilergürtel", "CRAFTING"}
        s["npc;drop=23574"] = {"Akil'zon <Avatar des Adlers>", "Zul'Aman"}
        s["npc;drop=40167"] = {"Zwielichtbetörer <Schattenhammer>", "Grim Batol"}
        s["spell;created=75263"] = {"Geistheilergamaschen", "CRAFTING"}
        s["spell;created=75261"] = {"Geistheilerstiefel", "CRAFTING"}
        s["npc;drop=42764"] = {"Pyromagen", "Pechschwingenabstieg"}
        s["spell;created=73643"] = {"Figur - Traumeule", "CRAFTING"}
        s["quest;reward=28170"] = {"Schrecken der Nacht", "Schattenhochland"}
        s["quest;reward=27868"] = {"Der Schmelztiegel des Gemetzels: Der Schattenterror!", "Schattenhochland"}
        s["quest;reward=28595"] = {"Krazz werkelt!", "Schattenhochland"}
        s["spell;created=73642"] = {"Figur - Juwelenbesetzte Schlange", "CRAFTING"}
        s["npc;drop=43614"] = {"Schnappschlund", "Die Verlorene Stadt der Tol'vir"}
        s["npc;drop=39803"] = {"Luftwächter", "Hallen des Ursprungs"}
        s["spell;created=96253"] = {"Lebhafter Alchemistenstein", "CRAFTING"}
        s["spell;created=76453"] = {"Elementiumklinge", "CRAFTING"}
        s["spell;created=73640"] = {"Figur - Dämonenpanther", "CRAFTING"}
        s["quest;reward=11196"] = {"Der Kriegsherr der Amani", "Zul'Aman"}
        s["npc;drop=42362"] = {"Zwangsarbeiter der Drakoniden", "Pechschwingenabstieg"}
        s["spell;created=94718"] = {"Elementiumbauchschlitzer", "CRAFTING"}
        s["spell;created=81720"] = {"Energiegeladene bio-optische Umnietbrille", "CRAFTING"}
        s["spell;created=78489"] = {"Zwielichtschuppenbrustschutz", "CRAFTING"}
        s["spell;created=78462"] = {"Sturmlederschärpe", "CRAFTING"}
        s["npc;drop=45687"] = {"Zwielichtwandler <Schattenhammer>", "Die Bastion des Zwielichts"}
        s["quest;reward=28853"] = {"Tötet den Kurier", "Grim Batol"}
        s["npc;drop=39440"] = {"Giftiger Huscher", "Hallen des Ursprungs"}
        s["npc;drop=47720"] = {"Kamel", "Die Verlorene Stadt der Tol'vir"}
        s["npc;drop=42789"] = {"Magmalord des Steinernen Kerns", "Der Steinerne Kern"}
        s["quest;reward=27659"] = {"Überlastung der Portale", "Schattenhochland"}
        s["quest;reward=27748"] = {"Glück und Ruhm", "Uldum"}
        s["npc;drop=45007"] = {"Versklavter Bandit", "Die Verlorene Stadt der Tol'vir"}
        s["quest;reward=26876"] = {"Das Weltensäulenfragment", "Tiefenheim"}
        s["npc;drop=39855"] = {"Azurgeborener Seher <Diener von Todesschwinge>", "Grim Batol"}
        s["spell;created=75257"] = {"Todesseidenrobe", "CRAFTING"}
        s["quest;reward=26830"] = {"Köder für den Verräter", "Orgrimmar"}
        s["quest;reward=27106"] = {"Entlarvung eines Schurken", "Sturmwind"}
        s["quest;reward=28133"] = {"Unbändige Wut", "Schattenhochland"}
        s["quest;reward=28282"] = {"Narkrall, der Drachenzähmer", "Schattenhochland"}
        s["quest;reward=27745"] = {"Ein feuriges Wiedersehen", "Schattenhochland"}
        s["quest;reward=28758"] = {"Der Kampf um Leben und Tod", "Schattenhochland"}
        s["quest;reward=26971"] = {"Die Bindung", "Tiefenheim"}
        s["quest;reward=27651"] = {"Nach Dunwälder Art", "Schattenhochland"}
        s["npc;drop=52418"] = {"Gahz'rankas verlorener Nachwuchs", "Zul'Gurub"}
        s["quest;reward=29186"] = {"Der Fetisch des Hexlords", "Zul'Aman"}
        s["quest;reward=28480"] = {"Offiziere der Dunkelheit", "Uldum"}
        s["spell;created=99439"] = {"Fäuste des Rächers", "CRAFTING"}
        s["object;contained=188192"] = {"Eiskiste", "Die Sklavenunterkünfte"}
        s["spell;created=78476"] = {"Zwielichtdrachenschuppenumhang", "CRAFTING"}
        s["quest;reward=28612"] = {"Harrison Jones und der Tempel von Uldum", "Uldum"}
        s["npc;drop=52322"] = {"Hexendoktorin Qu'in <Medizinfrau>", "Zul'Gurub"}
        s["npc;drop=23584"] = {"Bär der Amani", "Zul'Aman"}
        s["quest;reward=27667"] = {"Erdbebenkartenset des Dunkelmond-Jahrmarkts", "Wald von Elwynn"}
        s["quest;reward=27652"] = {"Dunkle Auftragsmörder", "Schattenhochland"}
        s["quest;reward=27653"] = {"Dunkle Auftragsmörder", "Schattenhochland"}
        s["npc;drop=52363"] = {"[Occu'thar]", "Baradinfestung"}
        s["spell;created=99452"] = {"Kriegsstiefel der mächtigen Fürsten", "CRAFTING"}
        s["spell;created=54982"] = {"Lila Trophäenwappenrock der Illidari erschaffen", "CRAFTING"}
        s["npc;sold=54401"] = {"Naresir Sturmwut <Rüstmeister der Rächer des Hyjal>", "Hyjal"}
        s["npc;sold=53882"] = {"Varlan Hochblatt <Versorgungsgüter des Hains>", "Geschmolzene Front"}
        s["spell;created=99654"] = {"Lichtgeschmiedeter Elementiumhammer", "CRAFTING"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "Geschmolzene Front"}
        s["spell;created=99457"] = {"Treter des Kunsthandwerks", "CRAFTING"}
        s["spell;created=99446"] = {"Klauen des Bösen", "CRAFTING"}
        s["spell;created=99660"] = {"Ernter des Hexenjägers", "CRAFTING"}
        s["spell;created=99458"] = {"Ätherische Pfadgänger", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "Geschmolzene Front"}
        s["spell;created=100687"] = {"Atombetriebener Lochstanzer", "CRAFTING"}
        s["spell;created=99460"] = {"Stiefel der schwarzen Flamme", "CRAFTING"}
        s["spell;created=99653"] = {"Meisterhafte Elementiumzauberklinge", "CRAFTING"}
        s["npc;sold=53214"] = {"Damek Blühbart <Außergewöhnliche Ausrüstung>", "Geschmolzene Front"}
        s["spell;created=99459"] = {"Endlose Traumwandler", "CRAFTING"}
        s["spell;created=99455"] = {"Irdene Schuppensabatons", "CRAFTING"}
        s["spell;created=99449"] = {"Don Tayos Infernofäustlinge", "CRAFTING"}
        s["spell;created=99657"] = {"Unzerstörbarer Wächter", "CRAFTING"}
        s["npc;sold=54402"] = {"Lurah Zornranke <Sammlerin kristallisierten Feuersteins>", "Hyjal"}
        s["npc;drop=52571"] = {"Majordomus Hirschhaupt <Erzdruide der Flamme>", "Feuerlande"}
        s["npc;drop=52498"] = {"Beth'tilac <Die rote Witwe>", "Feuerlande"}
        s["npc;drop=52530"] = {"Alysrazar", "Feuerlande"}
        s["npc;drop=53494"] = {"Baloroc <Der Torwächter>", "Feuerlande"}
        s["quest;reward=29331"] = {"Elementare Bande: Das Gelübde", "Hyjal"}
        s["npc;drop=53616"] = {"Kar der Ewigbrennende <Feuerfürst>", "Feuerlande"}
        s["npc;drop=54161"] = {"Flammenarchon", "Feuerlande"}
        s["npc;sold=52549"] = {"Unteroffizier Donnerhorn <Rüstmeister für Eroberungspunkte>", "Orgrimmar"}
        s["quest;reward=29312"] = {"Der Stoff, aus dem Legenden sind", "Sturmwind"}
        s["npc;drop=55689"] = {"Hagara die Sturmbinderin", "Drachenseele"}
        s["npc;drop=55308"] = {"Kriegsherr Zon'ozz", "Drachenseele"}
        s["npc;drop=55312"] = {"Yor'sahj der Unermüdliche", "Drachenseele"}
        s["npc;drop=56173"] = {"Todesschwinge <Der Zerstörer>", "Drachenseele"}
        s["npc;drop=57821"] = {"Leutnant Shara <Schattenhammer>", "Drachenseele"}
        s["spell;created=101932"] = {"Handgelenkplatten der Titanenwache", "CRAFTING"}
        s["npc;sold=241467"] = {"Sylstrasza <Obsidianfragmenthändlerin>", "Orgrimmar"}
        s["npc;drop=54938"] = {"Erzbischof Benedictus", "Stunde des Zwielichts"}
        s["npc;drop=53879"] = {"Todesschwinge <Der Zerstörer>", "Drachenseele"}
        s["spell;created=101925"] = {"Beinplatten des unaufhaltsamen Zerstörers", "CRAFTING"}
        s["spell;created=101931"] = {"Armschienen der zerstörerischen Stärke", "CRAFTING"}
        s["spell;created=101933"] = {"Gamaschen des Champions der Natur", "CRAFTING"}
        s["spell;created=101937"] = {"Armschienen der fließenden Ruhe", "CRAFTING"}
        s["npc;drop=56427"] = {"Kriegsmeister Schwarzhorn", "Drachenseele"}
        s["spell;created=101940"] = {"Klingenschattenhandgelenksschützer", "CRAFTING"}
        s["spell;created=101941"] = {"Armschienen des Zielsuchers", "CRAFTING"}
        s["spell;created=101921"] = {"Beinwickel des Lavabebens", "CRAFTING"}
        s["spell;created=101923"] = {"Armschienen der uneroberten Macht", "CRAFTING"}
        s["spell;created=101929"] = {"Armschienen des Seelenretters", "CRAFTING"}
        s["npc;drop=55869"] = {"Alizabal <Herrin des Hasses>", "Baradinfestung"}
        s["spell;created=101922"] = {"Traumwickel des Lichts", "CRAFTING"}
        s["spell;created=101934"] = {"Todesschuppengamaschen", "CRAFTING"}
        s["spell;created=101939"] = {"Donnernde Todesschuppenhandgelenksschützer", "CRAFTING"}
        s["quest;reward=30118"] = {"[Patricide]", "Drachenseele"}
        s["spell;created=101935"] = {"Klingenschattengamaschen", "CRAFTING"}
        s["npc;sold=54658"] = {"Unteroffizier Donnerhorn <Rüstmeister für Eroberungspunkte>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationesES()
        s["npc;sold=44245"] = {"Faldren Labravalle <Intendente de valor>", "Ciudad de Ventormenta"}
        s["npc;drop=9056"] = {"Finoso Virunegro <Arquitecto jefe>", "Profundidades de Roca Negra"}
        s["npc;drop=44600"] = {"Halfus Rompevermis", "El Bastión del Crepúsculo"}
        s["npc;sold=47328"] = {"Intendente Brazie <Intendente de los Celadores de Baradin>", "Península de Tol Barad"}
        s["npc;drop=41570"] = {"Faucemagma", "Descenso de Alanegra"}
        s["npc;drop=43735"] = {"[Elementium Monstrosity]", "El Bastión del Crepúsculo"}
        s["quest;reward=24919"] = {"[The Lightbringer's Redemption]", "Ciudadela de la Corona de Hielo"}
        s["npc;drop=45213"] = {"[Sinestra] <[Consort of Deathwing]>", "El Bastión del Crepúsculo"}
        s["npc;drop=45871"] = {"Nezir <Señor del viento del Norte>", "Trono de los Cuatro Vientos"}
        s["npc;sold=48531"] = {"Pogg <Intendente del Mando Grito Infernal>", "Península de Tol Barad"}
        s["npc;drop=36853"] = {"Sindragosa <Reina de los Razaescarcha>", "Ciudadela de la Corona de Hielo"}
        s["spell;created=80508"] = {"Piedra de alquimista vinculavida", "CRAFTING"}
        s["spell;created=81714"] = {"Matasombras bio-óptico reforzado", "CRAFTING"}
        s["npc;drop=39705"] = {"Señor ascendiente Obsidius", "Cavernas Roca Negra"}
        s["spell;created=76443"] = {"Camisote de elementium endurecido", "CRAFTING"}
        s["spell;created=76444"] = {"Faja de elementium endurecido", "CRAFTING"}
        s["npc;sold=49386"] = {"Craw MacGraw <Intendente del clan Martillo Salvaje>", "Tierras Altas Crepusculares"}
        s["npc;drop=39378"] = {"Rajh <Ensamblaje del sol>", "Cámaras de los Orígenes"}
        s["npc;sold=48617"] = {"Herrero Abasi <Intendente de Ramkahen>", "Uldum"}
        s["npc;sold=50314"] = {"Proveedora Nubeblanca <Intendente de los Guardianes de Hyjal>", "Monte Hyjal"}
        s["spell;created=86650"] = {"Mandíbula dentada", "CRAFTING"}
        s["npc;drop=45261"] = {"Caballero de las Sombras Crepuscular", "El Bastión del Crepúsculo"}
        s["npc;drop=39801"] = {"Celador de tierra", "Cámaras de los Orígenes"}
        s["npc;drop=37217"] = {"Precioso", "Ciudadela de la Corona de Hielo"}
        s["npc;drop=50063"] = {"Akma'hat <Lamento de las Arenas Eternas>", "Uldum"}
        s["spell;created=73503"] = {"Cinta de Moebius de elementium", "CRAFTING"}
        s["npc;drop=39732"] = {"Setesh <Ensamblaje de destrucción>", "Cámaras de los Orígenes"}
        s["npc;sold=44246"] = {"Magatha Toneplata <Intendente de justicia>", "Ciudad de Ventormenta"}
        s["npc;drop=44566"] = {"Ozumat <Maligno de las oscuras profundidades>", "Trono de las Mareas"}
        s["npc;sold=49387"] = {"[Grot Deathblow] <[Dragonmaw Clan Quartermaster]>", "Tierras Altas Crepusculares"}
        s["spell;created=73506"] = {"Guardián de elementium", "CRAFTING"}
        s["npc;sold=45408"] = {"D'lom el Coleccionista <Intendente de Therazane>", "Infralar"}
        s["npc;drop=42333"] = {"Suma sacerdotisa Azil", "El Núcleo Pétreo"}
        s["spell;created=73641"] = {"Figurilla: guardián terráneo", "CRAFTING"}
        s["npc;drop=40484"] = {"Erudax <El Duque de las profundidades>", "Grim Batol"}
        s["spell;created=94732"] = {"Aplastamentes de elementium forjado", "CRAFTING"}
        s["npc;drop=43214"] = {"Pielpétrea", "El Núcleo Pétreo"}
        s["spell;created=76445"] = {"Placamuerte de elementium", "CRAFTING"}
        s["spell;created=76446"] = {"Faja de dolor de elementium", "CRAFTING"}
        s["npc;drop=49813"] = {"Drakonaar evolucionado", "El Bastión del Crepúsculo"}
        s["npc;drop=40788"] = {"Dominamentes Ghur'sha", "Trono de las Mareas"}
        s["npc;drop=47296"] = {"Helix Rompengranajes", "Las Minas de la Muerte"}
        s["npc;drop=47162"] = {"Glubtok <El Supervisor>", "Las Minas de la Muerte"}
        s["npc;drop=40765"] = {"Comandante Ulthok <El Príncipe Purulento>", "Trono de las Mareas"}
        s["npc;drop=39698"] = {"Karsh Doblacero <Armero Crepuscular>", "Cavernas Roca Negra"}
        s["npc;drop=40177"] = {"Maestro de forja Throngus", "Grim Batol"}
        s["npc;drop=39731"] = {"Ammunae <Ensamblaje de vida>", "Cámaras de los Orígenes"}
        s["npc;drop=3887"] = {"Barón Filargenta", "Castillo de Colmillo Oscuro"}
        s["npc;drop=39679"] = {"Corla, Heraldo del Crepúsculo", "Cavernas Roca Negra"}
        s["npc;drop=39587"] = {"Isiset <Ensamblaje de magia>", "Cámaras de los Orígenes"}
        s["npc;drop=47739"] = {"'Capitán' Cocinitas <¿Principal de los Defias?>", "Las Minas de la Muerte"}
        s["npc;drop=43612"] = {"Sumo profeta Barim", "Ciudad Perdida de los Tol'vir"}
        s["quest;reward=27664"] = {"La baraja de Volcanes de la Luna Negra", "Bosque de Elwynn"}
        s["spell;created=81722"] = {"Matasombras bio-óptico ágil", "CRAFTING"}
        s["npc;drop=23863"] = {"Daakara <El Invencible>", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Avatar de dracohalcón>", "Zul'Aman"}
        s["spell;created=78461"] = {"Cinturón de susurros nefarios", "CRAFTING"}
        s["npc;drop=52151"] = {"Señor sangriento Mandokir", "Zul'Gurub"}
        s["npc;sold=50324"] = {"Proveedor Arok <Intendente del Anillo de la Tierra>", "Extensión Bruñida"}
        s["npc;drop=50009"] = {"Mobus <La Ola Aplastante>", "Profundidades Abisales"}
        s["npc;sold=46594"] = {"Sargento Tronacuerno <Intendente de conquista>", "Orgrimmar"}
        s["npc;drop=52148"] = {"Jin'do el Sojuzgadioses", "Zul'Gurub"}
        s["spell;created=86653"] = {"Hoja con incrustaciones de plata", "CRAFTING"}
        s["npc;drop=23577"] = {"Halazzi <Avatar de lince>", "Zul'Aman"}
        s["object;contained=186648"] = {"Baúl de Hazlek", "Zul'Aman"}
        s["spell;created=78488"] = {"Peto de asesino", "CRAFTING"}
        s["npc;drop=24239"] = {"Señor aojador Malacrass", "Zul'Aman"}
        s["npc;drop=39425"] = {"Guardián del templo Anhuur", "Cámaras de los Orígenes"}
        s["npc;drop=23586"] = {"Explorador Amani'shi", "Zul'Aman"}
        s["npc;drop=43875"] = {"Asaad <Califa de los Céfiros>", "La Cumbre del Vórtice"}
        s["object;contained=186667"] = {"Paquete de Norkani", "Zul'Aman"}
        s["npc;drop=39700"] = {"Bella", "Cavernas Roca Negra"}
        s["npc;drop=46962"] = {"Barón Ashbury", "Castillo de Colmillo Oscuro"}
        s["spell;created=73521"] = {"Medallón de elementium broncíneo", "CRAFTING"}
        s["npc;drop=39428"] = {"Terracundo Ptah", "Cámaras de los Orígenes"}
        s["spell;created=73498"] = {"Sortija de espadas", "CRAFTING"}
        s["npc;drop=44819"] = {"Siamat <Señor del viento del Sur>", "Ciudad Perdida de los Tol'vir"}
        s["spell;created=76451"] = {"Arma de asta de elementium", "CRAFTING"}
        s["npc;drop=4278"] = {"Comandante Vallefont", "Castillo de Colmillo Oscuro"}
        s["spell;created=81724"] = {"Matasombras bio-óptico de camuflaje", "CRAFTING"}
        s["npc;drop=42803"] = {"Bastardo drakeadon", "Descenso de Alanegra"}
        s["npc;drop=43125"] = {"Espíritu de Puñofundido", "Descenso de Alanegra"}
        s["spell;created=78487"] = {"Coselete de furia de la Naturaleza", "CRAFTING"}
        s["spell;created=78460"] = {"Latigazo de relámpagos", "CRAFTING"}
        s["quest;reward=27666"] = {"La baraja de Tsunamis de la Luna Negra", "Bosque de Elwynn"}
        s["spell;created=96254"] = {"Piedra de alquimista vibrante", "CRAFTING"}
        s["npc;drop=43122"] = {"Espíritu de Coramartillo", "Descenso de Alanegra"}
        s["spell;created=86652"] = {"Globo ocular tatuado", "CRAFTING"}
        s["npc;drop=40319"] = {"Drahga Quemasombras <Mensajero del Martillo Crepuscular>", "Grim Batol"}
        s["npc;drop=39625"] = {"General Umbriss <Siervo de Alamuerte>", "Grim Batol"}
        s["npc;drop=50057"] = {"Alardiente", "Monte Hyjal"}
        s["npc;drop=50086"] = {"Tarvus el Vil", "Tierras Altas Crepusculares"}
        s["spell;created=73505"] = {"Ojo de muchas muertes", "CRAFTING"}
        s["spell;created=73502"] = {"Anillo de elementos enfrentados", "CRAFTING"}
        s["quest;reward=28267"] = {"Pelotón de ejecución", "Uldum"}
        s["npc;drop=43778"] = {"Siegaenemigos 5000", "Las Minas de la Muerte"}
        s["spell;created=76450"] = {"Martillo de elementium", "CRAFTING"}
        s["npc;drop=39665"] = {"Machacahuesos Rom'ogg", "Cavernas Roca Negra"}
        s["npc;drop=43878"] = {"Gran visir Ertan", "La Cumbre del Vórtice"}
        s["spell;created=86642"] = {"Compañero divino", "CRAFTING"}
        s["spell;created=81716"] = {"Matasombras bio-óptico mortal", "CRAFTING"}
        s["spell;created=78435"] = {"Pechera Conchafilada", "CRAFTING"}
        s["quest;reward=28854"] = {"Cerrando un oscuro capítulo", "Grim Batol"}
        s["spell;created=78463"] = {"Cinturón de víbora atado", "CRAFTING"}
        s["spell;created=73520"] = {"Anillo de destructor de elementium", "CRAFTING"}
        s["quest;reward=27665"] = {"La baraja de Huracanes de la Luna Negra", "Bosque de Elwynn"}
        s["npc;drop=47626"] = {"Almirante Rasgagruñido", "Las Minas de la Muerte"}
        s["spell;created=84432"] = {"Culatazo 5000", "CRAFTING"}
        s["spell;created=84431"] = {"Machacapollos derrotado", "CRAFTING"}
        s["npc;sold=46595"] = {"Guardia de sangre Zar'shi <Intendente de honor>", "Orgrimmar"}
        s["spell;created=78490"] = {"Túnica de asesino de dragones", "CRAFTING"}
        s["npc;drop=42800"] = {"Avizor gólem", "Descenso de Alanegra"}
        s["spell;created=81725"] = {"Matasombras bio-óptico de peso ligero", "CRAFTING"}
        s["spell;created=75299"] = {"Cinturón sin sueños", "CRAFTING"}
        s["npc;drop=39415"] = {"Buscallamas ascendido", "Grim Batol"}
        s["npc;drop=52269"] = {"[Renataki]", "Zul'Gurub"}
        s["npc;drop=50089"] = {"Julak Fatalidad <El Ojo de Zor>", "Tierras Altas Crepusculares"}
        s["spell;created=75300"] = {"Calzones de pesadillas recompuestas", "CRAFTING"}
        s["spell;created=76449"] = {"Hoja de hechizo de elementium", "CRAFTING"}
        s["spell;created=86641"] = {"Guía de ingeniería de mazmorras", "CRAFTING"}
        s["quest;reward=28753"] = {"A lo bestia", "Cámaras de los Orígenes"}
        s["spell;created=81715"] = {"Matasombras bio-óptico especializado", "CRAFTING"}
        s["spell;created=76447"] = {"Coselete de elementium ligero", "CRAFTING"}
        s["spell;created=76448"] = {"Cinturón de elementium ligero", "CRAFTING"}
        s["spell;created=76455"] = {"Escudo de tormenta de elementium", "CRAFTING"}
        s["spell;created=76454"] = {"Guardatierra de elementium", "CRAFTING"}
        s["npc;drop=23576"] = {"Nalorakk <Avatar de oso>", "Zul'Aman"}
        s["npc;drop=42802"] = {"Destripador dracónido", "Descenso de Alanegra"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Ciudad de Ventormenta"}
        s["spell;created=98921"] = {"Anillo de castigador", "CRAFTING"}
        s["spell;created=73639"] = {"Figurilla: rey de los jabalíes", "CRAFTING"}
        s["spell;created=96252"] = {"Piedra de alquimista volátil", "CRAFTING"}
        s["npc;drop=46083"] = {"Bastardo drakeadon", "Descenso de Alanegra"}
        s["spell;created=75298"] = {"Cinturón de las profundidades", "CRAFTING"}
        s["spell;created=75301"] = {"Bombachos soplallamas", "CRAFTING"}
        s["npc;drop=48450"] = {"Graznador Aladía", "Las Minas de la Muerte"}
        s["spell;created=75266"] = {"Capucha de remiendos espirituales", "CRAFTING"}
        s["quest;reward=28783"] = {"La fuente de su poder", "Ciudad Perdida de los Tol'vir"}
        s["spell;created=75260"] = {"Sobrehombros de remiendos espirituales", "CRAFTING"}
        s["npc;drop=52345"] = {"Criatura de Bethekk", "Zul'Gurub"}
        s["quest;reward=27788"] = {"[Skullcrusher the Mountain]", "Tierras Altas Crepusculares"}
        s["spell;created=75267"] = {"Toga de remiendos espirituales", "CRAFTING"}
        s["spell;created=75259"] = {"Brazales de remiendos espirituales", "CRAFTING"}
        s["npc;drop=24138"] = {"Crocolisco Amani domesticado", "Zul'Aman"}
        s["spell;created=75262"] = {"Guantes de remiendos espirituales", "CRAFTING"}
        s["spell;created=75258"] = {"Cinturón de remiendos espirituales", "CRAFTING"}
        s["npc;drop=23574"] = {"Akil'zon <Avatar de águila>", "Zul'Aman"}
        s["npc;drop=40167"] = {"Cautivador Crepuscular <El Martillo Crepuscular>", "Grim Batol"}
        s["spell;created=75263"] = {"Leotardos de remiendos espirituales", "CRAFTING"}
        s["spell;created=75261"] = {"Botas de remiendos espirituales", "CRAFTING"}
        s["npc;drop=42764"] = {"Pirodiente", "Descenso de Alanegra"}
        s["spell;created=73643"] = {"Figurilla: búho onírico", "CRAFTING"}
        s["quest;reward=28170"] = {"Terrores nocturnos", "Tierras Altas Crepusculares"}
        s["quest;reward=27868"] = {"El Crisol de Matanza: ¡el terror Crepuscular!", "Tierras Altas Crepusculares"}
        s["quest;reward=28595"] = {"[Krazz Works!]", "Tierras Altas Crepusculares"}
        s["spell;created=73642"] = {"Figurilla: serpiente con joyas", "CRAFTING"}
        s["npc;drop=43614"] = {"Cierrafauce", "Ciudad Perdida de los Tol'vir"}
        s["npc;drop=39803"] = {"Celador de aire", "Cámaras de los Orígenes"}
        s["spell;created=96253"] = {"Piedra de alquimista de mercurio", "CRAFTING"}
        s["spell;created=76453"] = {"Faca de elementium", "CRAFTING"}
        s["spell;created=73640"] = {"Figurilla: pantera demoníaca", "CRAFTING"}
        s["quest;reward=11196"] = {"Señor de la guerra de los Amani", "Zul'Aman"}
        s["npc;drop=42362"] = {"Bracero dracónido", "Descenso de Alanegra"}
        s["spell;created=94718"] = {"Rebanatripas de elementium", "CRAFTING"}
        s["spell;created=81720"] = {"Matasombras bio-ópticos energizado", "CRAFTING"}
        s["spell;created=78489"] = {"Coselete de escamas Crepuscular", "CRAFTING"}
        s["spell;created=78462"] = {"Fajín Cuerotormenta", "CRAFTING"}
        s["npc;drop=45687"] = {"Transfigurador Crepuscular <El Martillo Crepuscular>", "El Bastión del Crepúsculo"}
        s["quest;reward=28853"] = {"Mata al mensajero", "Grim Batol"}
        s["npc;drop=39440"] = {"Arácnido venenoso", "Cámaras de los Orígenes"}
        s["npc;drop=47720"] = {"Camello", "Ciudad Perdida de los Tol'vir"}
        s["npc;drop=42789"] = {"Señor del Magma del Núcleo Pétreo", "El Núcleo Pétreo"}
        s["quest;reward=27659"] = {"Sobrecargar el portal", "Tierras Altas Crepusculares"}
        s["quest;reward=27748"] = {"Fortuna y gloria", "Uldum"}
        s["npc;drop=45007"] = {"Bandido esclavizado", "Ciudad Perdida de los Tol'vir"}
        s["quest;reward=26876"] = {"El fragmento del Pilar del Mundo", "Infralar"}
        s["npc;drop=39855"] = {"Vidente de la prole azur <Siervo de Alamuerte>", "Grim Batol"}
        s["spell;created=75257"] = {"Toga sedamuerte", "CRAFTING"}
        s["quest;reward=26830"] = {"Cebo para traidores", "Orgrimmar"}
        s["quest;reward=27106"] = {"Un villano desenmascarado", "Ciudad de Ventormenta"}
        s["quest;reward=28133"] = {"Furia desatada", "Tierras Altas Crepusculares"}
        s["quest;reward=28282"] = {"[Narkrall, The Drake-Tamer]", "Tierras Altas Crepusculares"}
        s["quest;reward=27745"] = {"Un encuentro fogoso", "Tierras Altas Crepusculares"}
        s["quest;reward=28758"] = {"Una batalla a vida o muerte", "Tierras Altas Crepusculares"}
        s["quest;reward=26971"] = {"El vínculo", "Infralar"}
        s["quest;reward=27651"] = {"Hacerlo como un Montocre", "Tierras Altas Crepusculares"}
        s["npc;drop=52418"] = {"Descendiente perdido de Gahz'ranka", "Zul'Gurub"}
        s["quest;reward=29186"] = {"El fetiche del señor aojador", "Zul'Aman"}
        s["quest;reward=28480"] = {"Tenientes de la oscuridad", "Uldum"}
        s["spell;created=99439"] = {"Puños de furia", "CRAFTING"}
        s["object;contained=188192"] = {"Cofre de hielo", "Recinto de los Esclavos"}
        s["spell;created=78476"] = {"Capa de dragontina Crepuscular", "CRAFTING"}
        s["quest;reward=28612"] = {"Harrison Jones y el Templo de Uldum", "Uldum"}
        s["npc;drop=52322"] = {"Médica bruja Qu'in <Médica bruja>", "Zul'Gurub"}
        s["npc;drop=23584"] = {"Oso Amani", "Zul'Aman"}
        s["quest;reward=27667"] = {"La baraja de Terremotos de la Luna Negra", "Bosque de Elwynn"}
        s["quest;reward=27652"] = {"Asesinos oscuros", "Tierras Altas Crepusculares"}
        s["quest;reward=27653"] = {"Asesinos oscuros", "Tierras Altas Crepusculares"}
        s["npc;drop=52363"] = {"[Occu'thar]", "Bastión de Baradin"}
        s["spell;created=99452"] = {"Botas de guerra de señores poderosos", "CRAFTING"}
        s["spell;created=54982"] = {"Crear tabardo trofeo morado Illidari", "CRAFTING"}
        s["npc;sold=54401"] = {"Naresir Furiatormenta <Intendente de los Vengadores de Hyjal>", "Monte Hyjal"}
        s["npc;sold=53882"] = {"[Varlan Highbough] <[Provisions of the Grove]>", "Frente de Magma"}
        s["spell;created=99654"] = {"Martillo de elementium forjado con luz", "CRAFTING"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "Frente de Magma"}
        s["spell;created=99457"] = {"Botines del oficio", "CRAFTING"}
        s["spell;created=99446"] = {"Garras del mal", "CRAFTING"}
        s["spell;created=99660"] = {"Cosechador del cazador de brujas", "CRAFTING"}
        s["spell;created=99458"] = {"Pisadas etéreas", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "Frente de Magma"}
        s["spell;created=100687"] = {"Perforadora de impacto extremo", "CRAFTING"}
        s["spell;created=99460"] = {"Botas de la llama negra", "CRAFTING"}
        s["spell;created=99653"] = {"Hoja de hechizo de elementium magistral", "CRAFTING"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "Frente de Magma"}
        s["spell;created=99459"] = {"Botos del sueño sin fin", "CRAFTING"}
        s["spell;created=99455"] = {"Escarpes de escamas terráneos", "CRAFTING"}
        s["spell;created=99449"] = {"Mitones infernales de Don Tayo", "CRAFTING"}
        s["spell;created=99657"] = {"Guardiana irrompible", "CRAFTING"}
        s["npc;sold=54402"] = {"Lurah Vid de la Ira <Coleccionista de piedras de fuego cristalizadas>", "Monte Hyjal"}
        s["npc;drop=52409"] = {"[Ragnaros]", "Tierras de Fuego"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "Tierras de Fuego"}
        s["npc;drop=52498"] = {"Beth'tilac <La Viuda Roja>", "Tierras de Fuego"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "Tierras de Fuego"}
        s["npc;drop=52530"] = {"[Alysrazor]", "Tierras de Fuego"}
        s["npc;drop=53494"] = {"Baleroc <El Guardián de la Puerta>", "Tierras de Fuego"}
        s["quest;reward=29331"] = {"[Elemental Bonds: The Vow]", "Monte Hyjal"}
        s["npc;drop=53616"] = {"Kar el Abrasador <Señor del Fuego>", "Tierras de Fuego"}
        s["npc;drop=54161"] = {"Arconte de fuego", "Tierras de Fuego"}
        s["npc;sold=52549"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "Orgrimmar"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "Ciudad de Ventormenta"}
        s["npc;drop=55689"] = {"Hagara la Vinculatormentas", "Alma de Dragón"}
        s["npc;drop=55308"] = {"Señor de la guerra Zon'ozz", "Alma de Dragón"}
        s["npc;drop=55312"] = {"Yor'sahj el Velador", "Alma de Dragón"}
        s["npc;drop=56173"] = {"Alamuerte <El Destructor>", "Alma de Dragón"}
        s["npc;drop=57821"] = {"Teniente Shara <El Martillo Crepuscular>", "Alma de Dragón"}
        s["spell;created=101932"] = {"Muñequeras con protección de titanes", "CRAFTING"}
        s["npc;sold=241467"] = {"Sylstrasza <Intercambio de fragmentos de obsidiana>", "Orgrimmar"}
        s["npc;drop=54938"] = {"[Archbishop Benedictus]", "Hora del Crepúsculo"}
        s["npc;drop=53879"] = {"Alamuerte <El Destructor>", "Alma de Dragón"}
        s["spell;created=101925"] = {"Ataduras de destructor imparable", "CRAFTING"}
        s["spell;created=101931"] = {"Brazales de fuerza destructiva", "CRAFTING"}
        s["spell;created=101933"] = {"Leotardos de campeón de la naturaleza", "CRAFTING"}
        s["spell;created=101937"] = {"Brazales de serenidad fluida", "CRAFTING"}
        s["npc;drop=56427"] = {"Maestro de guerra Cuerno Negro", "Alma de Dragón"}
        s["spell;created=101940"] = {"Guardamuñecas Filosombra", "CRAFTING"}
        s["spell;created=101941"] = {"Brazales del matacazadores", "CRAFTING"}
        s["spell;created=101921"] = {"Ataduras de temblor de lava", "CRAFTING"}
        s["spell;created=101923"] = {"Brazales de poder invicto", "CRAFTING"}
        s["spell;created=101929"] = {"Brazales de redentor de almas", "CRAFTING"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "Bastión de Baradin"}
        s["spell;created=101922"] = {"Envoltura onírica de la Luz", "CRAFTING"}
        s["spell;created=101934"] = {"Leotardos Muertescama", "CRAFTING"}
        s["spell;created=101939"] = {"Guardamuñecas Muertescama del trueno", "CRAFTING"}
        s["npc;drop=55085"] = {"[Peroth'arn]", "Pozo de la Eternidad"}
        s["quest;reward=30118"] = {"[Patricide]", "Alma de Dragón"}
        s["spell;created=101935"] = {"Leotardos Filosombra", "CRAFTING"}
        s["npc;sold=54658"] = {"Sargento Tronacuerno <Intendente de conquista>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationfrFR()
        s["npc;sold=44245"] = {"Faldren Tillsdale <Intendant de vaillance>", "Hurlevent"}
        s["npc;drop=9056"] = {"Fineous Sombrevire <Chef architecte>", "Profondeurs de Rochenoire"}
        s["npc;drop=44600"] = {"Halfus Brise-Wyrm", "Le bastion du Crépuscule"}
        s["npc;sold=47328"] = {"Intendant Brazie <Intendant des Gardiens de Baradin>", "Péninsule de Tol Barad"}
        s["npc;drop=41570"] = {"Magmagueule", "Descente de l'Aile noire"}
        s["npc;drop=43735"] = {"Monstruosité en élémentium", "Le bastion du Crépuscule"}
        s["quest;reward=24919"] = {"La rédemption du porteur de Lumière", "Citadelle de la Couronne de glace"}
        s["npc;drop=45213"] = {"Sinestra <Compagne d'Aile de mort>", "Le bastion du Crépuscule"}
        s["npc;drop=45871"] = {"Nezir <Seigneur du vent du Nord>", "Trône des quatre vents"}
        s["npc;drop=41442"] = {"Atramédès", "Descente de l'Aile noire"}
        s["npc;sold=48531"] = {"Pogg <Intendant du Poing de Hurlenfer>", "Péninsule de Tol Barad"}
        s["npc;drop=36853"] = {"Sindragosa <Reine des Couvegivres>", "Citadelle de la Couronne de glace"}
        s["spell;created=80508"] = {"Pierre d'alchimiste liée par la vie", "CRAFTING"}
        s["npc;drop=44577"] = {"Général Husam", "Cité perdue des Tol'vir"}
        s["spell;created=81714"] = {"Lunettes de soleil tueuses bio-optiques renforcées", "CRAFTING"}
        s["npc;drop=39705"] = {"Seigneur ascendant Obsidius", "Cavernes de Rochenoire"}
        s["spell;created=76443"] = {"Haubert d'élémentium durci", "CRAFTING"}
        s["spell;created=76444"] = {"Ceinturon d'élémentium durci", "CRAFTING"}
        s["npc;sold=49386"] = {"Trip MacGraw <Intendant du clan des Marteaux-hardis>", "Hautes-terres du Crépuscule"}
        s["npc;drop=39378"] = {"Rajh <Assemblage du soleil>", "Salles de l'Origine"}
        s["npc;sold=48617"] = {"Forgeron Abasi <Intendant ramkahen>", "Uldum"}
        s["npc;sold=50314"] = {"Approvisionneuse Nuage-Blanc <Intendante des Gardiens d'Hyjal>", "Mont Hyjal"}
        s["spell;created=86650"] = {"Mâchoire ébréchée", "CRAFTING"}
        s["npc;drop=45261"] = {"Chevalier d'ombre du Crépuscule", "Le bastion du Crépuscule"}
        s["npc;drop=39801"] = {"Gardien de terre", "Salles de l'Origine"}
        s["npc;drop=37217"] = {"Bijou", "Citadelle de la Couronne de glace"}
        s["npc;drop=50063"] = {"Akma'hat <Complainte des sables éternels>", "Uldum"}
        s["spell;created=73503"] = {"Bague de Moebius en élémentium", "CRAFTING"}
        s["npc;drop=39732"] = {"Setesh <Assemblage du chaos>", "Salles de l'Origine"}
        s["npc;sold=44246"] = {"Magatha Argentel <Intendante de justice>", "Hurlevent"}
        s["npc;drop=46964"] = {"Seigneur Godfrey", "Donjon d'Ombrecroc"}
        s["npc;drop=44566"] = {"Ozumat <Démon du sombre abîme>", "Trône des marées"}
        s["npc;sold=49387"] = {"Grot Coup-de-grâce <Intendant du clan Gueule-de-dragon>", "Hautes-terres du Crépuscule"}
        s["spell;created=73506"] = {"Gardien en élémentium", "CRAFTING"}
        s["npc;sold=45408"] = {"D'lom le Collecteur <Intendant de Therazane>", "Le Tréfonds"}
        s["npc;drop=42333"] = {"Grande prêtresse Azil", "Le Cœur-de-Pierre"}
        s["spell;created=73641"] = {"Figurine de gardien terrestre", "CRAFTING"}
        s["npc;drop=40484"] = {"Erudax <Le duc d'En bas>", "Grim Batol"}
        s["spell;created=94732"] = {"Ecrase-cervelle en élémentium forgé", "CRAFTING"}
        s["npc;drop=43214"] = {"Peau-de-Pierre", "Le Cœur-de-Pierre"}
        s["spell;created=76445"] = {"Armure de plates mortelle en élémentium", "CRAFTING"}
        s["spell;created=76446"] = {"Ceinturon de souffrance en élémentium", "CRAFTING"}
        s["npc;drop=49813"] = {"Drakonyâr évolué", "Le bastion du Crépuscule"}
        s["npc;drop=40788"] = {"Torve-esprit Ghur'sha", "Trône des marées"}
        s["npc;drop=47296"] = {"Hélix Engrecasse", "Les Mortemines"}
        s["npc;drop=47162"] = {"Glubtok <Le contremaître>", "Les Mortemines"}
        s["npc;drop=40765"] = {"Commandant Ulthok <Le prince purulent>", "Trône des marées"}
        s["npc;drop=39698"] = {"Karsh Plielacier <Armurier du Crépuscule>", "Cavernes de Rochenoire"}
        s["npc;drop=40177"] = {"Maître-forge Throngus", "Grim Batol"}
        s["npc;drop=39731"] = {"Ammunae <Assemblage de vie>", "Salles de l'Origine"}
        s["npc;drop=3887"] = {"Baron d'Argelaine", "Donjon d'Ombrecroc"}
        s["npc;drop=39679"] = {"Corla, héraut du Crépuscule", "Cavernes de Rochenoire"}
        s["npc;drop=39587"] = {"Isiset <Assemblage de magie>", "Salles de l'Origine"}
        s["npc;drop=47739"] = {"« Capitaine » Macaron <Caïd défias ?>", "Les Mortemines"}
        s["npc;drop=43612"] = {"Grand prophète Barim", "Cité perdue des Tol'vir"}
        s["quest;reward=27664"] = {"Suite de Volcans de Sombrelune", "Forêt d'Elwynn"}
        s["spell;created=81722"] = {"Lunettes de soleil tueuses bio-optiques agiles", "CRAFTING"}
        s["npc;drop=23863"] = {"Daakara <L’Invincible>", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Avatar de faucon-dragon>", "Zul'Aman"}
        s["spell;created=78461"] = {"Ceinture des murmures néfastes", "CRAFTING"}
        s["npc;drop=52151"] = {"Seigneur sanglant Mandokir", "Zul'Gurub"}
        s["npc;sold=50324"] = {"Approvisionneur Arok <Intendant du Cercle terrestre>", "Étendues Chatoyantes"}
        s["npc;drop=50009"] = {"Mobus <La Marée écrasante>", "Profondeurs Abyssales"}
        s["npc;sold=46594"] = {"Sergent Corne-Tonnerre <Intendant de conquête>", "Orgrimmar"}
        s["npc;drop=52148"] = {"Jin'do le Briseur de dieux", "Zul'Gurub"}
        s["spell;created=86653"] = {"Feuille damasquinée en argent", "CRAFTING"}
        s["npc;drop=23577"] = {"Halazzi <Avatar de Lynx>", "Zul'Aman"}
        s["object;contained=186648"] = {"Malle d'Hazlek", "Zul'Aman"}
        s["spell;created=78488"] = {"Pansière d'assassin", "CRAFTING"}
        s["npc;drop=24239"] = {"Seigneur des maléfices Malacrass", "Zul'Aman"}
        s["npc;drop=46963"] = {"Seigneur Walden", "Donjon d'Ombrecroc"}
        s["npc;drop=39425"] = {"Gardien du temple Anhuur", "Salles de l'Origine"}
        s["npc;drop=23586"] = {"Eclaireur amani'shi", "Zul'Aman"}
        s["npc;drop=43875"] = {"Asaad <Calife des zéphirs>", "La cime du Vortex"}
        s["object;contained=186667"] = {"Paquet de Norkani", "Zul'Aman"}
        s["npc;drop=39700"] = {"La Belle", "Cavernes de Rochenoire"}
        s["spell;created=73521"] = {"Médaillon effronté en élémentium", "CRAFTING"}
        s["npc;drop=39428"] = {"Enrageterre Ptah", "Salles de l'Origine"}
        s["spell;created=73498"] = {"Bague des lames", "CRAFTING"}
        s["npc;drop=44819"] = {"Siamat <Seigneur du vent du Sud>", "Cité perdue des Tol'vir"}
        s["spell;created=76451"] = {"Hache d'hast en élémentium", "CRAFTING"}
        s["npc;drop=4278"] = {"Commandant Printeval", "Donjon d'Ombrecroc"}
        s["spell;created=81724"] = {"Lunettes de soleil tueuses bio-optiques de camouflage", "CRAFTING"}
        s["npc;drop=42803"] = {"Bâtard drakodon", "Descente de l'Aile noire"}
        s["npc;drop=43125"] = {"Esprit de Fontepoing", "Descente de l'Aile noire"}
        s["spell;created=78487"] = {"Corselet de la fureur naturelle", "CRAFTING"}
        s["spell;created=78460"] = {"Fouet éclair", "CRAFTING"}
        s["quest;reward=27666"] = {"Suite de Tsunamis de Sombrelune", "Forêt d'Elwynn"}
        s["spell;created=96254"] = {"Pierre d'alchimiste vibrante", "CRAFTING"}
        s["npc;drop=43122"] = {"Esprit de Martel-Cœur", "Descente de l'Aile noire"}
        s["spell;created=86652"] = {"Globe oculaire tatoué", "CRAFTING"}
        s["npc;drop=40586"] = {"Dame Naz'jar", "Trône des marées"}
        s["npc;drop=40319"] = {"Drahga Brûle-Ombre <Messager du Marteau du crépuscule>", "Grim Batol"}
        s["npc;drop=39625"] = {"Général Umbriss <Serviteur d'Aile de mort>", "Grim Batol"}
        s["npc;drop=50057"] = {"Ailembrase", "Mont Hyjal"}
        s["npc;drop=50086"] = {"Tarvus le Vil", "Hautes-terres du Crépuscule"}
        s["spell;created=73505"] = {"Oeil des nombreuses morts", "CRAFTING"}
        s["spell;created=73502"] = {"Anneau des éléments guerroyants", "CRAFTING"}
        s["quest;reward=28267"] = {"Le peloton d'exécution", "Uldum"}
        s["npc;drop=43778"] = {"Faucheur 5000", "Les Mortemines"}
        s["spell;created=76450"] = {"Marteau en élémentium", "CRAFTING"}
        s["npc;drop=39665"] = {"Rom'ogg Broie-les-Os", "Cavernes de Rochenoire"}
        s["npc;drop=43878"] = {"Grand vizir Ertan", "La cime du Vortex"}
        s["spell;created=86642"] = {"Compagnon divin", "CRAFTING"}
        s["spell;created=81716"] = {"Lunettes de soleil tueuses bio-optiques mortelles", "CRAFTING"}
        s["spell;created=78435"] = {"Pansière coque-rasoir", "CRAFTING"}
        s["quest;reward=28854"] = {"Un sombre chapitre est refermé", "Grim Batol"}
        s["spell;created=78463"] = {"Ceinture de vipère côtelée", "CRAFTING"}
        s["spell;created=73520"] = {"Anneau de destructeur en élémentium", "CRAFTING"}
        s["quest;reward=27665"] = {"Suite d'Ouragans de Sombrelune", "Forêt d'Elwynn"}
        s["npc;drop=47626"] = {"Amiral Grondéventre", "Les Mortemines"}
        s["spell;created=84432"] = {"Décompresseur 5000", "CRAFTING"}
        s["spell;created=84431"] = {"Découpe-poulet surpuissant", "CRAFTING"}
        s["npc;sold=46595"] = {"Garde de sang Zar'shi <Intendant de l'honneur>", "Orgrimmar"}
        s["spell;created=78490"] = {"Tunique tue-dragon", "CRAFTING"}
        s["npc;drop=42800"] = {"Golem factionnaire", "Descente de l'Aile noire"}
        s["spell;created=81725"] = {"Lunettes de soleil tueuses bio-optiques légères", "CRAFTING"}
        s["spell;created=75299"] = {"Ceinture sans rêve", "CRAFTING"}
        s["npc;drop=39415"] = {"Chercheflamme réhaussé", "Grim Batol"}
        s["npc;drop=50089"] = {"Julak-Dram <L'Œil de Zor>", "Hautes-terres du Crépuscule"}
        s["spell;created=75300"] = {"Braies des cauchemars guéris", "CRAFTING"}
        s["spell;created=76449"] = {"Sorcelame en élémentium", "CRAFTING"}
        s["spell;created=86641"] = {"Guide de donjonage", "CRAFTING"}
        s["quest;reward=28753"] = {"Méthode à la dure", "Salles de l'Origine"}
        s["spell;created=81715"] = {"Lunettes de soleil tueuses bio-optiques spécialisées", "CRAFTING"}
        s["spell;created=76447"] = {"Corselet léger en élémentium", "CRAFTING"}
        s["spell;created=76448"] = {"Ceinture légère en élémentium", "CRAFTING"}
        s["spell;created=76455"] = {"Pare-tempête en élémentium", "CRAFTING"}
        s["spell;created=76454"] = {"Garde-terre en élémentium", "CRAFTING"}
        s["npc;drop=23576"] = {"Nalorakk <Avatar d'Ours>", "Zul'Aman"}
        s["npc;drop=42802"] = {"Pourfendeur drakônide", "Descente de l'Aile noire"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Hurlevent"}
        s["spell;created=98921"] = {"Bague de punisseur", "CRAFTING"}
        s["spell;created=73639"] = {"Figurine du roi des sangliers", "CRAFTING"}
        s["spell;created=96252"] = {"Pierre d'alchimiste volatile", "CRAFTING"}
        s["npc;drop=46083"] = {"Bâtard drakodon", "Descente de l'Aile noire"}
        s["spell;created=75298"] = {"Ceinture des profondeurs", "CRAFTING"}
        s["spell;created=75301"] = {"Culotte léchée par les flammes", "CRAFTING"}
        s["npc;drop=48450"] = {"Jacasseur vol-solaire", "Les Mortemines"}
        s["spell;created=75266"] = {"Capuche soignesprit", "CRAFTING"}
        s["quest;reward=28783"] = {"La source de leur puissance", "Cité perdue des Tol'vir"}
        s["spell;created=75260"] = {"Epaulières soignesprit", "CRAFTING"}
        s["npc;drop=52345"] = {"Fierté de Bethekk", "Zul'Gurub"}
        s["quest;reward=27788"] = {"Brise-tête la Montagne", "Hautes-terres du Crépuscule"}
        s["spell;created=75267"] = {"Robe soignesprit", "CRAFTING"}
        s["spell;created=75259"] = {"Brassards soignesprit", "CRAFTING"}
        s["npc;drop=24138"] = {"Crocilisque amani apprivoisé", "Zul'Aman"}
        s["spell;created=75262"] = {"Gants soignesprit", "CRAFTING"}
        s["spell;created=75258"] = {"Ceinture soignesprit", "CRAFTING"}
        s["npc;drop=23574"] = {"Akil'zon <Avatar d'Aigle>", "Zul'Aman"}
        s["npc;drop=40167"] = {"Imposteur du Crépuscule <Marteau du crépuscule>", "Grim Batol"}
        s["spell;created=75263"] = {"Jambières soignesprit", "CRAFTING"}
        s["spell;created=75261"] = {"Bottes soignesprit", "CRAFTING"}
        s["npc;drop=42764"] = {"Brûle-pourpoint", "Descente de l'Aile noire"}
        s["spell;created=73643"] = {"Figurine de hibou onirique", "CRAFTING"}
        s["quest;reward=28170"] = {"Terreurs nocturnes", "Hautes-terres du Crépuscule"}
        s["quest;reward=27868"] = {"Le Creuset du carnage : la Terreur du Crépuscule !", "Hautes-terres du Crépuscule"}
        s["quest;reward=28595"] = {"Krazz en extase !", "Hautes-terres du Crépuscule"}
        s["spell;created=73642"] = {"Figurine de serpent ornée de joyaux", "CRAFTING"}
        s["npc;drop=43614"] = {"Claque-mâchoire", "Cité perdue des Tol'vir"}
        s["npc;drop=39803"] = {"Gardien d'air", "Salles de l'Origine"}
        s["spell;created=96253"] = {"Pierre d'alchimiste de vif-argent", "CRAFTING"}
        s["spell;created=76453"] = {"Surin en élémentium", "CRAFTING"}
        s["spell;created=73640"] = {"Figurine de panthère démoniaque", "CRAFTING"}
        s["quest;reward=11196"] = {"Le seigneur de guerre des Amani", "Zul'Aman"}
        s["npc;drop=42362"] = {"Manœuvre drakônide", "Descente de l'Aile noire"}
        s["spell;created=94718"] = {"Tranche-gorge en élémentium", "CRAFTING"}
        s["spell;created=81720"] = {"Lunettes de soleil tueuses bio-optiques énergisées", "CRAFTING"}
        s["spell;created=78489"] = {"Corselet crépusculaire en écailles", "CRAFTING"}
        s["spell;created=78462"] = {"Echarpe foudrecuir", "CRAFTING"}
        s["npc;drop=45687"] = {"Déphaseur du Crépuscule <Marteau du crépuscule>", "Le bastion du Crépuscule"}
        s["quest;reward=28853"] = {"La mort du courrier", "Grim Batol"}
        s["npc;drop=39440"] = {"Glisseur venimeux", "Salles de l'Origine"}
        s["npc;drop=47720"] = {"Dromadaire", "Cité perdue des Tol'vir"}
        s["npc;drop=42789"] = {"Seigneur-magma du Cœur-de-Pierre", "Le Cœur-de-Pierre"}
        s["quest;reward=27659"] = {"Surcharge du portail", "Hautes-terres du Crépuscule"}
        s["quest;reward=27748"] = {"Gloire et fortune", "Uldum"}
        s["npc;drop=45007"] = {"Bandit asservi", "Cité perdue des Tol'vir"}
        s["quest;reward=26876"] = {"Le fragment du pilier du monde", "Le Tréfonds"}
        s["npc;drop=39855"] = {"Prophète de la nuée azur <Serviteur d'Aile de mort>", "Grim Batol"}
        s["spell;created=75257"] = {"Robe en morte-soie", "CRAFTING"}
        s["quest;reward=26830"] = {"Un appât à traîtres", "Orgrimmar"}
        s["quest;reward=27106"] = {"Le malfaisant démasqué", "Hurlevent"}
        s["quest;reward=28133"] = {"La fureur du drake", "Hautes-terres du Crépuscule"}
        s["quest;reward=28282"] = {"Narkrall le dompteur de drakes", "Hautes-terres du Crépuscule"}
        s["quest;reward=27745"] = {"Une chaleureuse réunion", "Hautes-terres du Crépuscule"}
        s["quest;reward=28758"] = {"Une bataille cruciale", "Hautes-terres du Crépuscule"}
        s["quest;reward=26971"] = {"Le lien", "Le Tréfonds"}
        s["quest;reward=27651"] = {"Dunwald et ses frères", "Hautes-terres du Crépuscule"}
        s["npc;drop=52418"] = {"Progéniture perdue de Gahz'ranka", "Zul'Gurub"}
        s["quest;reward=29186"] = {"Le fétiche du seigneur des maléfices", "Zul'Aman"}
        s["quest;reward=28480"] = {"Les lieutenants des ténèbres", "Uldum"}
        s["spell;created=99439"] = {"Poings de fureur", "CRAFTING"}
        s["object;contained=188192"] = {"Coffre de glace", "Les enclos aux esclaves"}
        s["spell;created=78476"] = {"Cape crépusculaire en écailles de dragon", "CRAFTING"}
        s["quest;reward=28612"] = {"Harrison Jones et le temple d'Uldum", "Uldum"}
        s["npc;drop=52322"] = {"Féticheuse Qu'in <Femme-médecin>", "Zul'Gurub"}
        s["npc;drop=23584"] = {"Ours amani", "Zul'Aman"}
        s["quest;reward=27667"] = {"Suite de Séisme de Sombrelune", "Forêt d'Elwynn"}
        s["quest;reward=27652"] = {"Assassins noirs", "Hautes-terres du Crépuscule"}
        s["quest;reward=27653"] = {"Assassins noirs", "Hautes-terres du Crépuscule"}
        s["npc;drop=52363"] = {"[Occu'thar]", "Bastion de Baradin"}
        s["spell;created=99452"] = {"Bottes de guerre de seigneurs puissants", "CRAFTING"}
        s["spell;created=54982"] = {"Création du tabard trophée des Illidari violet", "CRAFTING"}
        s["npc;sold=54401"] = {"Naresir Furie-des-Tempêtes <Intendant des Vengeurs d’Hyjal>", "Mont Hyjal"}
        s["npc;sold=53882"] = {"Varlan Hautebranche <Provisions du Bosquet>", "Front du Magma"}
        s["spell;created=99654"] = {"Marteau en élémentium de Sancteforge", "CRAFTING"}
        s["npc;sold=53881"] = {"Ayla Ombretempête <Trésors d’Elune>", "Front du Magma"}
        s["spell;created=99457"] = {"Bottines de l’art", "CRAFTING"}
        s["spell;created=99446"] = {"Etreintes du mal", "CRAFTING"}
        s["spell;created=99660"] = {"Moissonneur du chasseur de sorcières", "CRAFTING"}
        s["spell;created=99458"] = {"Grolles éthériennes", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "Front du Magma"}
        s["spell;created=100687"] = {"Perforeuse à impact extrême", "CRAFTING"}
        s["spell;created=99460"] = {"Bottes de la flamme noire", "CRAFTING"}
        s["spell;created=99653"] = {"Sorcelame en élémentium ouvragé", "CRAFTING"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "Front du Magma"}
        s["spell;created=99459"] = {"Brodequins de rêves infinis", "CRAFTING"}
        s["spell;created=99455"] = {"Solerets terrestres en écailles", "CRAFTING"}
        s["spell;created=99449"] = {"Mitaines infernales de don Tayo", "CRAFTING"}
        s["spell;created=99657"] = {"Gardien incassable", "CRAFTING"}
        s["npc;sold=54402"] = {"Lurah Irevigne <Collectionneuse de pierres de feu cristallisées>", "Mont Hyjal"}
        s["npc;drop=52409"] = {"[Ragnaros]", "Terres de Feu"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "Terres de Feu"}
        s["npc;drop=53691"] = {"[Shannox]", "Terres de Feu"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "Terres de Feu"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "Terres de Feu"}
        s["npc;drop=52530"] = {"[Alysrazor]", "Terres de Feu"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "Terres de Feu"}
        s["quest;reward=29331"] = {"Liens élémentaires : Le serment", "Mont Hyjal"}
        s["npc;drop=53616"] = {"Kar le Semperardent <Seigneur du Feu>", "Terres de Feu"}
        s["npc;drop=54161"] = {"Archonte des flammes", "Terres de Feu"}
        s["npc;sold=52549"] = {"Sergent Corne-Tonnerre <Intendant de conquête>", "Orgrimmar"}
        s["quest;reward=29312"] = {"L’étoffe des légendes", "Hurlevent"}
        s["npc;drop=55689"] = {"Hagara la Lieuse des tempêtes", "L’Âme des dragons"}
        s["npc;drop=55308"] = {"Seigneur de guerre Zon’ozz", "L’Âme des dragons"}
        s["npc;drop=55312"] = {"Yor'sahj l’Insomniaque", "L’Âme des dragons"}
        s["npc;drop=56173"] = {"Aile de mort <Le Destructeur>", "L’Âme des dragons"}
        s["npc;drop=57821"] = {"Lieutenant Shara <Marteau du crépuscule>", "L’Âme des dragons"}
        s["spell;created=101932"] = {"Plates de poignets de garde des titans", "CRAFTING"}
        s["npc;sold=241467"] = {"Sylstrasza <Echange de fragments d'obsidienne>", "Orgrimmar"}
        s["npc;drop=54938"] = {"Archevêque Benedictus", "L’Heure du Crépuscule"}
        s["npc;drop=53879"] = {"Aile de mort <Le Destructeur>", "L’Âme des dragons"}
        s["spell;created=101925"] = {"Cuissards de destructeur irrésistible", "CRAFTING"}
        s["spell;created=101931"] = {"Brassards de force destructrice", "CRAFTING"}
        s["spell;created=101933"] = {"Jambières de champion de la Nature", "CRAFTING"}
        s["spell;created=101937"] = {"Brassards de sérénité fluide", "CRAFTING"}
        s["npc;drop=56427"] = {"Maître de guerre Corne-Noire", "L’Âme des dragons"}
        s["spell;created=101940"] = {"Garde-poignets ombrelames", "CRAFTING"}
        s["spell;created=101941"] = {"Brassards du chasseur-tueur", "CRAFTING"}
        s["spell;created=101921"] = {"Jambards de tremblement de lave", "CRAFTING"}
        s["spell;created=101923"] = {"Brassards de puissance insoumise", "CRAFTING"}
        s["spell;created=101929"] = {"Brassards de rédempteur d’âme", "CRAFTING"}
        s["npc;drop=55869"] = {"Alizabal <Maîtresse de la haine>", "Bastion de Baradin"}
        s["spell;created=101922"] = {"Protège-rêves de la Lumière", "CRAFTING"}
        s["spell;created=101934"] = {"Jambières en mortécailles", "CRAFTING"}
        s["spell;created=101939"] = {"Garde-poignets en mortécailles de tonnerre", "CRAFTING"}
        s["npc;drop=55085"] = {"Peroth’arn", "Puits d’éternité"}
        s["quest;reward=30118"] = {"[Patricide]", "L’Âme des dragons"}
        s["spell;created=101935"] = {"Jambières ombrelames", "CRAFTING"}
        s["npc;sold=54658"] = {"Sergent Corne-Tonnerre <Intendant de conquête>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationitIT()
        s["npc;sold=44245"] = {"[Faldren Tillsdale] <[Valor Quartermaster]>", "Stormwind City"}
        s["npc;drop=41376"] = {"[Nefarian]", "Blackwing Descent"}
        s["npc;drop=9056"] = {"Fineous Darkvire <Chief Architect>", "Blackrock Depths"}
        s["npc;drop=42178"] = {"[Magmatron]", "Blackwing Descent"}
        s["npc;drop=43296"] = {"[Chimaeron]", "Blackwing Descent"}
        s["npc;drop=44600"] = {"[Halfus Wyrmbreaker]", "The Bastion of Twilight"}
        s["npc;drop=45992"] = {"[Valiona]", "The Bastion of Twilight"}
        s["npc;sold=47328"] = {"[Quartermaster Brazie] <[Baradin's Wardens Quartermaster]>", "Tol Barad Peninsula"}
        s["npc;drop=41570"] = {"[Magmaw]", "Blackwing Descent"}
        s["npc;drop=43735"] = {"[Elementium Monstrosity]", "The Bastion of Twilight"}
        s["quest;reward=24919"] = {"The Lightbringer's Redemption", "Icecrown Citadel"}
        s["npc;drop=45213"] = {"[Sinestra] <[Consort of Deathwing]>", "The Bastion of Twilight"}
        s["npc;drop=45871"] = {"[Nezir] <[Lord of the North Wind]>", "Throne of the Four Winds"}
        s["npc;drop=46753"] = {"[Al'Akir]", "Throne of the Four Winds"}
        s["npc;drop=41378"] = {"[Maloriak]", "Blackwing Descent"}
        s["npc;drop=43324"] = {"[Cho'gall]", "The Bastion of Twilight"}
        s["npc;drop=41442"] = {"[Atramedes]", "Blackwing Descent"}
        s["npc;sold=48531"] = {"[Pogg] <[Hellscream's Reach Quartermaster]>", "Tol Barad Peninsula"}
        s["npc;drop=36853"] = {"Sindragosa <Queen of the Frostbrood>", "Icecrown Citadel"}
        s["npc;drop=44577"] = {"[General Husam]", "Lost City of the Tol'vir"}
        s["npc;drop=39705"] = {"[Ascendant Lord Obsidius]", "Blackrock Caverns"}
        s["npc;drop=47120"] = {"[Argaloth]", "Baradin Hold"}
        s["npc;sold=49386"] = {"[Craw MacGraw] <[Wildhammer Clan Quartermaster]>", "Twilight Highlands"}
        s["npc;drop=39788"] = {"[Anraphet]", "Halls of Origination"}
        s["npc;drop=39378"] = {"[Rajh] <[Construct of the Sun]>", "Halls of Origination"}
        s["npc;sold=48617"] = {"[Blacksmith Abasi] <[Ramkahen Quartermaster]>", "Uldum"}
        s["npc;sold=50314"] = {"[Provisioner Whitecloud] <[Guardians of Hyjal Quartermaster]>", "Mount Hyjal"}
        s["npc;drop=42188"] = {"[Ozruk]", "The Stonecore"}
        s["npc;drop=45261"] = {"[Twilight Shadow Knight]", "The Bastion of Twilight"}
        s["npc;drop=39801"] = {"[Earth Warden]", "Halls of Origination"}
        s["npc;drop=50061"] = {"[Xariona]", "Deepholm"}
        s["npc;drop=50060"] = {"[Terborus]", "Deepholm"}
        s["npc;drop=50063"] = {"[Akma'hat] <[Dirge of the Eternal Sands]>", "Uldum"}
        s["npc;drop=39732"] = {"[Setesh] <[Construct of Destruction]>", "Halls of Origination"}
        s["npc;sold=44246"] = {"[Magatha Silverton] <[Justice Quartermaster]>", "Stormwind City"}
        s["npc;drop=46964"] = {"[Lord Godfrey]", "Shadowfang Keep"}
        s["npc;drop=49045"] = {"[Augh]", "Lost City of the Tol'vir"}
        s["npc;drop=44566"] = {"[Ozumat] <[Fiend of the Dark Below]>", "Throne of the Tides"}
        s["npc;sold=49387"] = {"[Grot Deathblow] <[Dragonmaw Clan Quartermaster]>", "Twilight Highlands"}
        s["npc;sold=45408"] = {"[D'lom the Collector] <[Therazane Quartermaster]>", "Deepholm"}
        s["npc;drop=42333"] = {"[High Priestess Azil]", "The Stonecore"}
        s["npc;drop=40484"] = {"[Erudax] <[The Duke of Below]>", "Grim Batol"}
        s["npc;drop=43214"] = {"[Slabhide]", "The Stonecore"}
        s["npc;drop=49813"] = {"[Evolved Drakonaar]", "The Bastion of Twilight"}
        s["npc;drop=40788"] = {"[Mindbender Ghur'sha]", "Throne of the Tides"}
        s["npc;drop=47296"] = {"[Helix Gearbreaker]", "The Deadmines"}
        s["npc;drop=49541"] = {"[Vanessa VanCleef]", "The Deadmines"}
        s["npc;drop=47162"] = {"[Glubtok] <[The Foreman]>", "The Deadmines"}
        s["npc;drop=40765"] = {"[Commander Ulthok] <[The Festering Prince]>", "Throne of the Tides"}
        s["npc;drop=39698"] = {"[Karsh Steelbender] <[Twilight Armorer]>", "Blackrock Caverns"}
        s["npc;drop=50056"] = {"[Garr]", "Mount Hyjal"}
        s["npc;drop=40177"] = {"[Forgemaster Throngus]", "Grim Batol"}
        s["npc;drop=39731"] = {"[Ammunae] <[Construct of Life]>", "Halls of Origination"}
        s["npc;drop=39679"] = {"[Corla, Herald of Twilight]", "Blackrock Caverns"}
        s["npc;drop=39587"] = {"[Isiset] <[Construct of Magic]>", "Halls of Origination"}
        s["npc;drop=47739"] = {"['Captain' Cookie] <[Defias Kingpin?]>", "The Deadmines"}
        s["npc;drop=43612"] = {"[High Prophet Barim]", "Lost City of the Tol'vir"}
        s["npc;drop=45993"] = {"[Theralion]", "The Bastion of Twilight"}
        s["quest;reward=27664"] = {"[Darkmoon Volcanic Deck]", "Elwynn Forest"}
        s["npc;drop=42180"] = {"[Toxitron]", "Blackwing Descent"}
        s["npc;drop=23863"] = {"Zul'jin", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Dragonhawk Avatar>", "Zul'Aman"}
        s["npc;drop=42767"] = {"[Ivoroc]", "Blackwing Descent"}
        s["npc;drop=52151"] = {"[Bloodlord Mandokir]", "Zul'Gurub"}
        s["npc;sold=50324"] = {"[Provisioner Arok] <[Earthen Ring Quartermaster]>", "Shimmering Expanse"}
        s["npc;drop=43438"] = {"[Corborus]", "The Stonecore"}
        s["npc;drop=50009"] = {"[Mobus] <[The Crushing Tide]>", "Abyssal Depths"}
        s["npc;sold=46594"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "Orgrimmar"}
        s["npc;drop=52148"] = {"[Jin'do the Godbreaker]", "Zul'Gurub"}
        s["npc;drop=23577"] = {"Halazzi <Lynx Avatar>", "Zul'Aman"}
        s["object;contained=186648"] = {"Tanzar's Trunk", "Zul'Aman"}
        s["npc;drop=46963"] = {"[Lord Walden]", "Shadowfang Keep"}
        s["npc;drop=39425"] = {"[Temple Guardian Anhuur]", "Halls of Origination"}
        s["npc;drop=43875"] = {"[Asaad] <[Caliph of Zephyrs]>", "The Vortex Pinnacle"}
        s["object;contained=186667"] = {"Kraz's Package", "Zul'Aman"}
        s["npc;drop=39700"] = {"[Beauty]", "Blackrock Caverns"}
        s["npc;drop=52258"] = {"[Gri'lek]", "Zul'Gurub"}
        s["npc;drop=46962"] = {"[Baron Ashbury]", "Shadowfang Keep"}
        s["npc;drop=39428"] = {"[Earthrager Ptah]", "Halls of Origination"}
        s["npc;drop=44819"] = {"[Siamat] <[Lord of the South Wind]>", "Lost City of the Tol'vir"}
        s["npc;drop=42803"] = {"[Drakeadon Mongrel]", "Blackwing Descent"}
        s["npc;drop=43125"] = {"[Spirit of Moltenfist]", "Blackwing Descent"}
        s["quest;reward=27666"] = {"[Darkmoon Tsunami Deck]", "Elwynn Forest"}
        s["npc;drop=43122"] = {"[Spirit of Corehammer]", "Blackwing Descent"}
        s["npc;drop=43873"] = {"[Altairus]", "The Vortex Pinnacle"}
        s["npc;drop=40586"] = {"[Lady Naz'jar]", "Throne of the Tides"}
        s["npc;drop=40319"] = {"[Drahga Shadowburner] <[Twilight's Hammer Courier]>", "Grim Batol"}
        s["npc;drop=39625"] = {"[General Umbriss] <[Servant of Deathwing]>", "Grim Batol"}
        s["npc;drop=50057"] = {"[Blazewing]", "Mount Hyjal"}
        s["npc;drop=50086"] = {"[Tarvus the Vile]", "Twilight Highlands"}
        s["quest;reward=28267"] = {"[Firing Squad]", "Uldum"}
        s["npc;drop=43778"] = {"[Foe Reaper 5000]", "The Deadmines"}
        s["npc;drop=39665"] = {"[Rom'ogg Bonecrusher]", "Blackrock Caverns"}
        s["npc;drop=43878"] = {"[Grand Vizier Ertan]", "The Vortex Pinnacle"}
        s["quest;reward=28854"] = {"[Closing a Dark Chapter]", "Grim Batol"}
        s["quest;reward=27665"] = {"[Darkmoon Hurricane Deck]", "Elwynn Forest"}
        s["npc;drop=47626"] = {"[Admiral Ripsnarl]", "The Deadmines"}
        s["npc;sold=46595"] = {"[Blood Guard Zar'shi] <[Honor Quartermaster]>", "Orgrimmar"}
        s["npc;drop=42800"] = {"[Golem Sentry]", "Blackwing Descent"}
        s["npc;drop=39415"] = {"[Ascended Flameseeker]", "Grim Batol"}
        s["npc;drop=52269"] = {"[Renataki]", "Zul'Gurub"}
        s["npc;drop=50089"] = {"[Julak-Doom] <[The Eye of Zor]>", "Twilight Highlands"}
        s["quest;reward=28753"] = {"[Doing it the Hard Way]", "Halls of Origination"}
        s["npc;drop=50050"] = {"[Shok'sharak]", "Abyssal Depths"}
        s["npc;drop=52053"] = {"[Zanzil]", "Zul'Gurub"}
        s["npc;drop=23576"] = {"Nalorakk <Bear Avatar>", "Zul'Aman"}
        s["npc;drop=42802"] = {"[Drakonid Slayer]", "Blackwing Descent"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Orgrimmar"}
        s["npc;drop=46083"] = {"[Drakeadon Mongrel]", "Blackwing Descent"}
        s["npc;drop=48450"] = {"[Sunwing Squawker]", "The Deadmines"}
        s["quest;reward=28783"] = {"[The Source of Their Power]", "Lost City of the Tol'vir"}
        s["npc;drop=52345"] = {"[Pride of Bethekk]", "Zul'Gurub"}
        s["quest;reward=27788"] = {"[Skullcrusher the Mountain]", "Twilight Highlands"}
        s["npc;drop=23574"] = {"Akil'zon <Eagle Avatar>", "Zul'Aman"}
        s["npc;drop=40167"] = {"[Twilight Beguiler] <[The Twilight's Hammer]>", "Grim Batol"}
        s["npc;drop=42764"] = {"[Pyrecraw]", "Blackwing Descent"}
        s["quest;reward=28170"] = {"[Night Terrors]", "Twilight Highlands"}
        s["quest;reward=27868"] = {"[The Crucible of Carnage: The Twilight Terror!]", "Twilight Highlands"}
        s["quest;reward=28595"] = {"[Krazz Works!]", "Twilight Highlands"}
        s["npc;drop=43614"] = {"[Lockmaw]", "Lost City of the Tol'vir"}
        s["npc;drop=39803"] = {"[Air Warden]", "Halls of Origination"}
        s["quest;reward=11196"] = {"TEMP X", "Zul'Aman"}
        s["npc;drop=42362"] = {"[Drakonid Drudge]", "Blackwing Descent"}
        s["npc;drop=52271"] = {"[Hazza'rah]", "Zul'Gurub"}
        s["npc;drop=45687"] = {"[Twilight-Shifter] <[The Twilight's Hammer]>", "The Bastion of Twilight"}
        s["quest;reward=28853"] = {"[Kill the Courier]", "Grim Batol"}
        s["npc;drop=39440"] = {"[Venomous Skitterer]", "Halls of Origination"}
        s["npc;drop=47720"] = {"[Camel]", "Lost City of the Tol'vir"}
        s["npc;drop=42789"] = {"[Stonecore Magmalord]", "The Stonecore"}
        s["quest;reward=27659"] = {"[Portal Overload]", "Twilight Highlands"}
        s["quest;reward=27748"] = {"[Fortune and Glory]", "Uldum"}
        s["npc;drop=45007"] = {"[Enslaved Bandit]", "Lost City of the Tol'vir"}
        s["quest;reward=26876"] = {"[The World Pillar Fragment]", "Deepholm"}
        s["npc;drop=39855"] = {"[Azureborne Seer] <[Servant of Deathwing]>", "Grim Batol"}
        s["quest;reward=26830"] = {"[Traitor's Bait]", "Orgrimmar"}
        s["quest;reward=27106"] = {"[A Villain Unmasked]", "Stormwind City"}
        s["quest;reward=28133"] = {"[Fury Unbound]", "Twilight Highlands"}
        s["quest;reward=28282"] = {"[Narkrall, The Drake-Tamer]", "Twilight Highlands"}
        s["quest;reward=27745"] = {"[A Fiery Reunion]", "Twilight Highlands"}
        s["quest;reward=28758"] = {"[Battle of Life and Death]", "Twilight Highlands"}
        s["quest;reward=26971"] = {"[The Binding]", "Deepholm"}
        s["quest;reward=27651"] = {"[Doing It Like a Dunwald]", "Twilight Highlands"}
        s["npc;drop=52418"] = {"[Lost Offspring of Gahz'ranka]", "Zul'Gurub"}
        s["quest;reward=29186"] = {"[The Hex Lord's Fetish]", "Zul'Aman"}
        s["quest;reward=28480"] = {"[Lieutenants of Darkness]", "Uldum"}
        s["quest;reward=28612"] = {"[Harrison Jones and the Temple of Uldum]", "Uldum"}
        s["npc;drop=52322"] = {"[Witch Doctor Qu'in] <[Medicine Woman]>", "Zul'Gurub"}
        s["quest;reward=27667"] = {"[Darkmoon Earthquake Deck]", "Elwynn Forest"}
        s["quest;reward=27652"] = {"[Dark Assassins]", "Twilight Highlands"}
        s["quest;reward=27653"] = {"[Dark Assassins]", "Twilight Highlands"}
        s["npc;drop=52363"] = {"[Occu'thar]", "Baradin Hold"}
        s["npc;sold=54401"] = {"[Naresir Stormfury] <[Avengers of Hyjal Quartermaster]>", "Mount Hyjal"}
        s["npc;sold=53882"] = {"[Varlan Highbough] <[Provisions of the Grove]>", "Molten Front"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "Molten Front"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "Molten Front"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "Molten Front"}
        s["npc;sold=54402"] = {"[Lurah Wrathvine] <[Crystallized Firestone Collector]>", "Mount Hyjal"}
        s["npc;drop=52409"] = {"[Ragnaros]", "Firelands"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "Firelands"}
        s["npc;drop=53691"] = {"[Shannox]", "Firelands"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "Firelands"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "Firelands"}
        s["npc;drop=52530"] = {"[Alysrazor]", "Firelands"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "Firelands"}
        s["quest;reward=29331"] = {"[Elemental Bonds: The Vow]", "Mount Hyjal"}
        s["npc;drop=53616"] = {"[Kar the Everburning] <[Firelord]>", "Firelands"}
        s["npc;drop=54161"] = {"[Flame Archon]", "Firelands"}
        s["npc;sold=52549"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "Orgrimmar"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "Stormwind City"}
        s["npc;drop=55689"] = {"[Hagara the Stormbinder]", "Dragon Soul"}
        s["npc;drop=55308"] = {"[Warlord Zon'ozz]", "Dragon Soul"}
        s["npc;drop=55265"] = {"[Morchok]", "Dragon Soul"}
        s["npc;drop=55294"] = {"[Ultraxion]", "Dragon Soul"}
        s["npc;drop=55312"] = {"[Yor'sahj the Unsleeping]", "Dragon Soul"}
        s["npc;drop=56173"] = {"[Deathwing] <[The Destroyer]>", "Dragon Soul"}
        s["npc;drop=57821"] = {"[Lieutenant Shara] <[The Twilight's Hammer]>", "Dragon Soul"}
        s["npc;sold=241467"] = {"[Sylstrasza] <[Obsidian Fragment Exchange]>", "Orgrimmar"}
        s["npc;drop=54938"] = {"[Archbishop Benedictus]", "Hour of Twilight"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "Dragon Soul"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "Dragon Soul"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "Baradin Hold"}
        s["npc;drop=55085"] = {"[Peroth'arn]", "Well of Eternity"}
        s["quest;reward=30118"] = {"[Patricide]", "Dragon Soul"}
        s["npc;sold=54658"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationkoKR()
        s["npc;sold=44245"] = {"폴드런 틸스데일 <용맹 병참장교>", "스톰윈드"}
        s["npc;drop=41376"] = {"네파리안", "검은날개 강림지"}
        s["npc;drop=9056"] = {"파이너스 다크바이어 <선임건축가>", "검은바위 나락"}
        s["npc;drop=42178"] = {"용암골렘", "검은날개 강림지"}
        s["npc;drop=43296"] = {"키마이론", "검은날개 강림지"}
        s["npc;drop=44600"] = {"할푸스 웜브레이커", "황혼의 요새"}
        s["npc;drop=45992"] = {"발리오나", "황혼의 요새"}
        s["npc;sold=47328"] = {"병참장교 브레이지 <바라딘 집행단 병참장교>", "톨 바라드 반도"}
        s["npc;drop=41570"] = {"용암아귀", "검은날개 강림지"}
        s["npc;drop=43735"] = {"엘레멘티움 괴물", "황혼의 요새"}
        s["quest;reward=24919"] = {"", "얼음왕관 성채"}
        s["npc;drop=45213"] = {"시네스트라 <데스윙의 배우자>", "황혼의 요새"}
        s["npc;drop=45871"] = {"네지르 <북풍 군주>", "네 바람의 왕좌"}
        s["npc;drop=46753"] = {"알아키르", "네 바람의 왕좌"}
        s["npc;drop=41378"] = {"말로리악", "검은날개 강림지"}
        s["npc;drop=43324"] = {"초갈", "황혼의 요새"}
        s["npc;drop=41442"] = {"아트라메데스", "검은날개 강림지"}
        s["npc;sold=48531"] = {"포그 <헬스크림 세력단 병참장교>", "톨 바라드 반도"}
        s["npc;drop=36853"] = {"신드라고사 <서리고룡족 여왕>", "얼음왕관 성채"}
        s["spell;created=80508"] = {"생명결속 연금술사 돌", "CRAFTING"}
        s["npc;drop=44577"] = {"장군 후삼", "톨비르의 잃어버린 도시"}
        s["spell;created=81714"] = {"강화된 생체광학 처치용 가리개", "CRAFTING"}
        s["npc;drop=39705"] = {"승천 군주 옵시디우스", "검은바위 동굴"}
        s["spell;created=76443"] = {"강화 엘레멘티움 갑옷", "CRAFTING"}
        s["spell;created=76444"] = {"강화 엘레멘티움 요대", "CRAFTING"}
        s["npc;drop=47120"] = {"아르갈로스", "바라딘 요새"}
        s["npc;sold=49386"] = {"크로 맥그로 <와일드해머 드워프 병참장교>", "황혼의 고원"}
        s["npc;drop=39788"] = {"안라펫", "시초의 전당"}
        s["npc;drop=39378"] = {"라지 <태양의 지배신>", "시초의 전당"}
        s["npc;sold=48617"] = {"대장장이 아바시 <람카헨 병참장교>", "울둠"}
        s["npc;sold=50314"] = {"배급원 화이트클라우드 <하이잘의 수호자 병참장교>", "하이잘 산"}
        s["npc;drop=42188"] = {"오즈룩", "바위심장부"}
        s["spell;created=86650"] = {"톱니모양 턱뼈", "CRAFTING"}
        s["npc;drop=45261"] = {"황혼의 암흑 기사", "황혼의 요새"}
        s["npc;drop=39801"] = {"대지의 감독관", "시초의 전당"}
        s["npc;drop=37217"] = {"예삐", "얼음왕관 성채"}
        s["npc;drop=50061"] = {"자리오나", "심원의 영지"}
        s["npc;drop=50060"] = {"터보러스", "심원의 영지"}
        s["npc;drop=50063"] = {"아크마하트 <영원한 모래의 진혼곡>", "울둠"}
        s["spell;created=73503"] = {"엘레멘티움 뫼비우스 고리", "CRAFTING"}
        s["npc;drop=39732"] = {"세테쉬 <파괴의 지배신>", "시초의 전당"}
        s["npc;sold=44246"] = {"마가타 실버턴 <정의 병참장교>", "스톰윈드"}
        s["npc;drop=46964"] = {"고드프리 경", "그림자송곳니 성채"}
        s["npc;drop=49045"] = {"오우", "톨비르의 잃어버린 도시"}
        s["npc;drop=44566"] = {"오주마트 <검은 심해의 악마>", "파도의 왕좌"}
        s["npc;sold=49387"] = {"그로트 데스블로 <용아귀 부족 병참장교>", "황혼의 고원"}
        s["spell;created=73506"] = {"엘레멘티움 수호목걸이", "CRAFTING"}
        s["npc;sold=45408"] = {"수집가 드롬 <테라제인 병참장교>", "심원의 영지"}
        s["npc;drop=42333"] = {"대여사제 아질", "바위심장부"}
        s["spell;created=73641"] = {"조각상 - 대지 수호자", "CRAFTING"}
        s["npc;drop=40484"] = {"에루닥스 <지하 군주>", "그림 바톨"}
        s["spell;created=94732"] = {"벼려낸 엘레멘티움 정신분쇄기", "CRAFTING"}
        s["npc;drop=43214"] = {"돌거죽", "바위심장부"}
        s["spell;created=76445"] = {"엘레멘티움 죽음판금 갑옷", "CRAFTING"}
        s["spell;created=76446"] = {"고통의 엘레멘티움 요대", "CRAFTING"}
        s["npc;drop=49813"] = {"진화한 드라코나르", "황혼의 요새"}
        s["npc;drop=40788"] = {"환각술사 구르샤", "파도의 왕좌"}
        s["npc;drop=47296"] = {"헬릭스 기어브레이커", "죽음의 폐광"}
        s["npc;drop=49541"] = {"바네사 밴클리프", "죽음의 폐광"}
        s["npc;drop=47162"] = {"글럽톡 <현장감독>", "죽음의 폐광"}
        s["npc;drop=40765"] = {"사령관 울톡 <부패한 왕자>", "파도의 왕좌"}
        s["npc;drop=39698"] = {"카쉬 스틸벤더 <황혼의 방어구 제작자>", "검은바위 동굴"}
        s["npc;drop=50056"] = {"가르", "하이잘 산"}
        s["npc;drop=40177"] = {"제련장인 트롱구스", "그림 바톨"}
        s["npc;drop=39731"] = {"아뮤내 <생명의 지배신>", "시초의 전당"}
        s["npc;drop=3887"] = {"남작 실버레인", "그림자송곳니 성채"}
        s["npc;drop=39679"] = {"황혼의 전령 코를라", "검은바위 동굴"}
        s["npc;drop=39587"] = {"이시세트 <마법의 지배신>", "시초의 전당"}
        s["npc;drop=47739"] = {"'선장' 쿠키 <데피아즈단 두목?>", "죽음의 폐광"}
        s["npc;drop=43612"] = {"고위 사제 바림", "톨비르의 잃어버린 도시"}
        s["npc;drop=45993"] = {"테랄리온", "황혼의 요새"}
        s["quest;reward=27664"] = {"", "엘윈 숲"}
        s["npc;drop=42180"] = {"맹독골렘", "검은날개 강림지"}
        s["spell;created=81722"] = {"기민함의 생체광학 처치용 가리개", "CRAFTING"}
        s["npc;drop=23863"] = {"다카라 <천하무적>", "줄아만"}
        s["npc;drop=23578"] = {"잔알라이 <용매의 화신>", "줄아만"}
        s["spell;created=78461"] = {"사악한 속삭임의 허리띠", "CRAFTING"}
        s["npc;drop=42767"] = {"이보로크", "검은날개 강림지"}
        s["npc;drop=52151"] = {"혈군주 만도키르", "줄구룹"}
        s["npc;sold=50324"] = {"배급원 아록 <대지 고리회 병참장교>", "흐린빛 벌판"}
        s["npc;drop=43438"] = {"코보루스", "바위심장부"}
        s["npc;drop=50009"] = {"모부스 <파멸의 파도>", "심연의 나락"}
        s["npc;sold=46594"] = {"하사관 썬더혼 <정복 병참장교>", "오그리마"}
        s["npc;drop=52148"] = {"신파괴자 진도", "줄구룹"}
        s["spell;created=86653"] = {"은세공 나뭇잎", "CRAFTING"}
        s["npc;drop=23577"] = {"할라지 <스라소니의 화신>", "줄아만"}
        s["object;contained=186648"] = {"하즐렉의 상자", "줄아만"}
        s["spell;created=78488"] = {"암살자의 가슴갑옷", "CRAFTING"}
        s["npc;drop=24239"] = {"사술 군주 말라크라스", "줄아만"}
        s["npc;drop=46963"] = {"월든 경", "그림자송곳니 성채"}
        s["npc;drop=39425"] = {"사원 수호자 안후르", "시초의 전당"}
        s["npc;drop=23586"] = {"아마니쉬 정찰병", "줄아만"}
        s["npc;drop=43875"] = {"아사드 <서풍의 통치자>", "소용돌이 누각"}
        s["object;contained=186667"] = {"노르카니의 짐꾸러미", "줄아만"}
        s["npc;drop=39700"] = {"아름이", "검은바위 동굴"}
        s["npc;drop=52258"] = {"그리렉", "줄구룹"}
        s["npc;drop=46962"] = {"남작 애쉬버리", "그림자송곳니 성채"}
        s["spell;created=73521"] = {"놋쇠빛 엘레멘티움 메달", "CRAFTING"}
        s["npc;drop=39428"] = {"대지전복자 프타", "시초의 전당"}
        s["spell;created=73498"] = {"칼날 고리", "CRAFTING"}
        s["npc;drop=44819"] = {"시아마트 <남풍 군주>", "톨비르의 잃어버린 도시"}
        s["spell;created=76451"] = {"엘레멘티움 도끼장창", "CRAFTING"}
        s["npc;drop=4278"] = {"사령관 스프링베일", "그림자송곳니 성채"}
        s["spell;created=81724"] = {"위장의 생체광학 처치용 가리개", "CRAFTING"}
        s["npc;drop=42803"] = {"드라케돈 투견", "검은날개 강림지"}
        s["npc;drop=43125"] = {"몰튼피스트의 영혼", "검은날개 강림지"}
        s["spell;created=78487"] = {"자연 분노의 가슴보호대", "CRAFTING"}
        s["spell;created=78460"] = {"번개 채찍", "CRAFTING"}
        s["quest;reward=27666"] = {"", "엘윈 숲"}
        s["spell;created=96254"] = {"고동치는 연금술사 돌", "CRAFTING"}
        s["npc;drop=43122"] = {"코어해머의 영혼", "검은날개 강림지"}
        s["spell;created=86652"] = {"문신 새긴 눈알", "CRAFTING"}
        s["npc;drop=43873"] = {"알타이루스", "소용돌이 누각"}
        s["npc;drop=40586"] = {"여군주 나즈자르", "파도의 왕좌"}
        s["npc;drop=40319"] = {"드라가 섀도버너 <황혼의 망치단 급사>", "그림 바톨"}
        s["npc;drop=39625"] = {"장군 움브리스 <데스윙의 하수인>", "그림 바톨"}
        s["npc;drop=50057"] = {"화염날개", "하이잘 산"}
        s["npc;drop=50086"] = {"비열한 타르부스", "황혼의 고원"}
        s["spell;created=73505"] = {"수많은 죽음의 눈", "CRAFTING"}
        s["spell;created=73502"] = {"대립하는 정령의 반지", "CRAFTING"}
        s["quest;reward=28267"] = {"", "울둠"}
        s["npc;drop=43778"] = {"전투 절단기 5000", "죽음의 폐광"}
        s["spell;created=76450"] = {"엘레멘티움 망치", "CRAFTING"}
        s["npc;drop=39665"] = {"해골분쇄자 롬오그", "검은바위 동굴"}
        s["npc;drop=43878"] = {"대장로 에르탄", "소용돌이 누각"}
        s["spell;created=86642"] = {"성스러운 지침서", "CRAFTING"}
        s["spell;created=81716"] = {"치명적인 생체광학 처치용 가리개", "CRAFTING"}
        s["spell;created=78435"] = {"서슬껍질 가슴보호구", "CRAFTING"}
        s["quest;reward=28854"] = {"", "그림 바톨"}
        s["spell;created=78463"] = {"똬리 튼 독사 장식끈", "CRAFTING"}
        s["spell;created=73520"] = {"엘레멘티움 파괴자의 반지", "CRAFTING"}
        s["quest;reward=27665"] = {"", "엘윈 숲"}
        s["npc;drop=47626"] = {"제독 으르렁니", "죽음의 폐광"}
        s["spell;created=84432"] = {"반동 5000", "CRAFTING"}
        s["spell;created=84431"] = {"지나치게 강력한 닭 분쇄기", "CRAFTING"}
        s["npc;sold=46595"] = {"혈투사 자르쉬 <명예 병참장교>", "오그리마"}
        s["spell;created=78490"] = {"용 학살자 튜닉", "CRAFTING"}
        s["npc;drop=42800"] = {"골렘 파수병", "검은날개 강림지"}
        s["spell;created=81725"] = {"가벼운 생체광학 처치용 가리개", "CRAFTING"}
        s["spell;created=75299"] = {"꿈꾸지 않는 허리띠", "CRAFTING"}
        s["npc;drop=39415"] = {"상급 화염추적자", "그림 바톨"}
        s["npc;drop=52269"] = {"레나타키", "줄구룹"}
        s["npc;drop=50089"] = {"줄락둠 <조르의 눈>", "황혼의 고원"}
        s["spell;created=75300"] = {"치유된 악몽의 짧은바지", "CRAFTING"}
        s["spell;created=76449"] = {"엘레멘티움 마법검", "CRAFTING"}
        s["spell;created=86641"] = {"던전공학 안내서", "CRAFTING"}
        s["quest;reward=28753"] = {"", "시초의 전당"}
        s["spell;created=81715"] = {"특화된 생체광학 처치용 가리개", "CRAFTING"}
        s["spell;created=76447"] = {"가벼운 엘레멘티움 가슴보호대", "CRAFTING"}
        s["spell;created=76448"] = {"가벼운 엘레멘티움 허리띠", "CRAFTING"}
        s["spell;created=76455"] = {"엘레멘티움 폭풍 방패", "CRAFTING"}
        s["npc;drop=50050"] = {"쇼크샤라크", "심연의 나락"}
        s["spell;created=76454"] = {"엘레멘티움 대지수호 방패", "CRAFTING"}
        s["npc;drop=52053"] = {"잔질", "줄구룹"}
        s["npc;drop=23576"] = {"날로라크 <곰의 화신>", "줄아만"}
        s["npc;drop=42802"] = {"용혈족 학살자", "검은날개 강림지"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "스톰윈드"}
        s["spell;created=98921"] = {"응징자의 고리", "CRAFTING"}
        s["spell;created=73639"] = {"조각상 - 멧돼지 왕", "CRAFTING"}
        s["spell;created=96252"] = {"휘발성 연금술사 돌", "CRAFTING"}
        s["npc;drop=46083"] = {"드라케돈 투견", "검은날개 강림지"}
        s["spell;created=75298"] = {"나락의 허리띠", "CRAFTING"}
        s["spell;created=75301"] = {"솟아오른 불꽃의 통바지", "CRAFTING"}
        s["npc;drop=48450"] = {"태양날개앵무", "죽음의 폐광"}
        s["spell;created=75266"] = {"정신치유 수도두건", "CRAFTING"}
        s["quest;reward=28783"] = {"", "톨비르의 잃어버린 도시"}
        s["spell;created=75260"] = {"정신치유 어깨보호구", "CRAFTING"}
        s["npc;drop=52345"] = {"베데크의 긍지", "줄구룹"}
        s["quest;reward=27788"] = {"", "황혼의 고원"}
        s["spell;created=75267"] = {"정신치유 로브", "CRAFTING"}
        s["spell;created=75259"] = {"정신치유 팔보호구", "CRAFTING"}
        s["npc;drop=24138"] = {"길들인 아마니 악어", "줄아만"}
        s["spell;created=75262"] = {"정신치유 장갑", "CRAFTING"}
        s["spell;created=75258"] = {"정신치유 허리띠", "CRAFTING"}
        s["npc;drop=23574"] = {"아킬존 <독수리의 화신>", "줄아만"}
        s["npc;drop=40167"] = {"황혼의 현혹술사 <황혼의 망치단>", "그림 바톨"}
        s["spell;created=75263"] = {"정신치유 다리보호구", "CRAFTING"}
        s["spell;created=75261"] = {"정신치유 장화", "CRAFTING"}
        s["npc;drop=42764"] = {"불길구렁", "검은날개 강림지"}
        s["spell;created=73643"] = {"조각상 - 꿈의 올빼미", "CRAFTING"}
        s["quest;reward=28170"] = {"", "황혼의 고원"}
        s["quest;reward=27868"] = {"", "황혼의 고원"}
        s["quest;reward=28595"] = {"", "황혼의 고원"}
        s["spell;created=73642"] = {"조각상 - 보석 박힌 뱀", "CRAFTING"}
        s["npc;drop=43614"] = {"톱니아귀", "톨비르의 잃어버린 도시"}
        s["npc;drop=39803"] = {"바람의 감독관", "시초의 전당"}
        s["spell;created=96253"] = {"쾌활의 연금술사 돌", "CRAFTING"}
        s["spell;created=76453"] = {"엘레멘티움 단도", "CRAFTING"}
        s["spell;created=73640"] = {"조각상 - 악마 표범", "CRAFTING"}
        s["quest;reward=11196"] = {"아마니의 장군", "줄아만"}
        s["npc;drop=42362"] = {"용혈족 노역꾼", "검은날개 강림지"}
        s["spell;created=94718"] = {"엘레멘티움 내장절단기", "CRAFTING"}
        s["npc;drop=52271"] = {"하자라", "줄구룹"}
        s["spell;created=81720"] = {"활력의 생체광학 처치용 가리개", "CRAFTING"}
        s["spell;created=78489"] = {"황혼의 비늘 가슴보호대", "CRAFTING"}
        s["spell;created=78462"] = {"폭풍가죽 장식띠", "CRAFTING"}
        s["npc;drop=45687"] = {"황혼의 위상 변화사 <황혼의 망치단>", "황혼의 요새"}
        s["quest;reward=28853"] = {"", "그림 바톨"}
        s["npc;drop=39440"] = {"맹독딱정벌레", "시초의 전당"}
        s["npc;drop=47720"] = {"낙타", "톨비르의 잃어버린 도시"}
        s["npc;drop=42789"] = {"바위심장부 용암군주", "바위심장부"}
        s["quest;reward=27659"] = {"", "황혼의 고원"}
        s["quest;reward=27748"] = {"", "울둠"}
        s["npc;drop=45007"] = {"사로잡힌 무법자", "톨비르의 잃어버린 도시"}
        s["quest;reward=26876"] = {"", "심원의 영지"}
        s["npc;drop=39855"] = {"하늘살이 예언자 <데스윙의 하수인>", "그림 바톨"}
        s["spell;created=75257"] = {"죽음비단 로브", "CRAFTING"}
        s["quest;reward=26830"] = {"", "오그리마"}
        s["quest;reward=27106"] = {"", "스톰윈드"}
        s["quest;reward=28133"] = {"", "황혼의 고원"}
        s["quest;reward=28282"] = {"", "황혼의 고원"}
        s["quest;reward=27745"] = {"", "황혼의 고원"}
        s["quest;reward=28758"] = {"", "황혼의 고원"}
        s["quest;reward=26971"] = {"", "심원의 영지"}
        s["quest;reward=27651"] = {"", "황혼의 고원"}
        s["npc;drop=52418"] = {"가즈란카의 잃어버린 자손", "줄구룹"}
        s["quest;reward=29186"] = {"", "줄아만"}
        s["quest;reward=28480"] = {"", "울둠"}
        s["spell;created=99439"] = {"격노의 철권", "CRAFTING"}
        s["object;contained=188192"] = {"[Ice Chest]", "강제 노역소"}
        s["spell;created=78476"] = {"황혼의 용비늘 망토", "CRAFTING"}
        s["quest;reward=28612"] = {"", "울둠"}
        s["npc;drop=52322"] = {"의술사 쿠인 <여약사>", "줄구룹"}
        s["npc;drop=23584"] = {"아마니 곰", "줄아만"}
        s["quest;reward=27667"] = {"", "엘윈 숲"}
        s["quest;reward=27652"] = {"", "황혼의 고원"}
        s["quest;reward=27653"] = {"", "황혼의 고원"}
        s["npc;drop=52363"] = {"[Occu'thar]", "바라딘 요새"}
        s["spell;created=99452"] = {"강력한 군주의 전쟁장화", "CRAFTING"}
        s["spell;created=54982"] = {"보라색 일리다리 기념 휘장 생성", "CRAFTING"}
        s["npc;sold=54401"] = {"[Naresir Stormfury] <[Avengers of Hyjal Quartermaster]>", "하이잘 산"}
        s["npc;sold=53882"] = {"[Varlan Highbough] <[Provisions of the Grove]>", "녹아내린 전초지"}
        s["spell;created=99654"] = {"빛으로 벼려낸 엘레멘티움 망치", "CRAFTING"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "녹아내린 전초지"}
        s["spell;created=99457"] = {"술책의 발보호대", "CRAFTING"}
        s["spell;created=99446"] = {"악의 손아귀", "CRAFTING"}
        s["spell;created=99660"] = {"마녀 사냥꾼의 수확기", "CRAFTING"}
        s["spell;created=99458"] = {"에테리얼 발소리", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "녹아내린 전초지"}
        s["spell;created=100687"] = {"굉장한 위력의 타공기", "CRAFTING"}
        s["spell;created=99460"] = {"검은 불길의 장화", "CRAFTING"}
        s["spell;created=99653"] = {"명인 엘레멘티움 마법검", "CRAFTING"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "녹아내린 전초지"}
        s["spell;created=99459"] = {"끝없는 꿈의 걸음장화", "CRAFTING"}
        s["spell;created=99455"] = {"대지의 미늘 발덮개", "CRAFTING"}
        s["spell;created=99449"] = {"돈 타요의 지옥불 벙어리장갑", "CRAFTING"}
        s["spell;created=99657"] = {"깨지지 않는 수호자", "CRAFTING"}
        s["npc;sold=54402"] = {"[Lurah Wrathvine] <[Crystallized Firestone Collector]>", "하이잘 산"}
        s["npc;drop=52409"] = {"[Ragnaros]", "불의 땅"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "불의 땅"}
        s["npc;drop=53691"] = {"[Shannox]", "불의 땅"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "불의 땅"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "불의 땅"}
        s["npc;drop=52530"] = {"[Alysrazor]", "불의 땅"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "불의 땅"}
        s["quest;reward=29331"] = {"[Elemental Bonds: The Vow]", "하이잘 산"}
        s["npc;drop=53616"] = {"[Kar the Everburning] <[Firelord]>", "불의 땅"}
        s["npc;drop=54161"] = {"[Flame Archon]", "불의 땅"}
        s["npc;sold=52549"] = {"하사관 썬더혼 <정복 병참장교>", "오그리마"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "스톰윈드"}
        s["npc;drop=55689"] = {"[Hagara the Stormbinder]", "용의 영혼"}
        s["npc;drop=55308"] = {"[Warlord Zon'ozz]", "용의 영혼"}
        s["npc;drop=55265"] = {"[Morchok]", "용의 영혼"}
        s["npc;drop=55294"] = {"[Ultraxion]", "용의 영혼"}
        s["npc;drop=55312"] = {"[Yor'sahj the Unsleeping]", "용의 영혼"}
        s["npc;drop=56173"] = {"[Deathwing] <[The Destroyer]>", "용의 영혼"}
        s["npc;drop=57821"] = {"[Lieutenant Shara] <[The Twilight's Hammer]>", "용의 영혼"}
        s["spell;created=101932"] = {"티탄의 수호 판금손목", "CRAFTING"}
        s["npc;sold=241467"] = {"실스트라자 <흑요석 파편 교환>", "오그리마"}
        s["npc;drop=54938"] = {"[Archbishop Benedictus]", "황혼의 시간"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "용의 영혼"}
        s["spell;created=101925"] = {"막을 수 없는 파괴자의 다리갑옷", "CRAFTING"}
        s["spell;created=101931"] = {"파괴적인 힘의 팔보호구", "CRAFTING"}
        s["spell;created=101933"] = {"자연의 용사 다리보호구", "CRAFTING"}
        s["spell;created=101937"] = {"샘솟는 평온의 팔보호구", "CRAFTING"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "용의 영혼"}
        s["spell;created=101940"] = {"칼날그림자 손목보호구", "CRAFTING"}
        s["spell;created=101941"] = {"사냥꾼 암살자의 팔보호구", "CRAFTING"}
        s["spell;created=101921"] = {"용암지진 바지", "CRAFTING"}
        s["spell;created=101923"] = {"정복되지 않은 힘의 팔보호구", "CRAFTING"}
        s["spell;created=101929"] = {"영혼 복원자 팔보호구", "CRAFTING"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "바라딘 요새"}
        s["spell;created=101922"] = {"빛의 꿈결두름", "CRAFTING"}
        s["spell;created=101934"] = {"죽음비늘 다리보호구", "CRAFTING"}
        s["spell;created=101939"] = {"천둥치는 죽음비늘 손목보호구", "CRAFTING"}
        s["npc;drop=55085"] = {"페로스안", "영원의 샘"}
        s["quest;reward=30118"] = {"[Patricide]", "용의 영혼"}
        s["spell;created=101935"] = {"칼날그림자 다리보호구", "CRAFTING"}
        s["npc;sold=54658"] = {"하사관 썬더혼 <정복 병참장교>", "오그리마"}
    end

    function SpecBisTooltip:TranslationptBR()
        s["npc;sold=44245"] = {"Fernão Thadeo <Intendente de Bravura>", "Ventobravo"}
        s["npc;drop=9056"] = {"Fineous Forçanegra <Arquiteto-chefe>", "Abismo Rocha Negra"}
        s["npc;drop=43296"] = {"Khímaron", "Descenso do Asa Negra"}
        s["npc;drop=44600"] = {"Halfus Quebra-serpe", "Bastião do Crepúsculo"}
        s["npc;sold=47328"] = {"Intendente Brazie <Intendente dos Protetores de Baradin>", "Península de Tol Barad"}
        s["npc;drop=41570"] = {"Magorja", "Descenso do Asa Negra"}
        s["npc;drop=43735"] = {"Monstruosidade de Elemêntio", "Bastião do Crepúsculo"}
        s["quest;reward=24919"] = {"[The Lightbringer's Redemption]", "Cidadela da Coroa de Gelo"}
        s["npc;drop=45213"] = {"[Sinestra] <[Consort of Deathwing]>", "Bastião do Crepúsculo"}
        s["npc;drop=45871"] = {"Nezir <Senhor do Vento Norte>", "Trono dos Quatro Ventos"}
        s["npc;drop=46753"] = {"[Al'Akir]", "Trono dos Quatro Ventos"}
        s["npc;sold=48531"] = {"Pogg <Intendente do Punho de Grito Infernal>", "Península de Tol Barad"}
        s["npc;drop=36853"] = {"Sindragosa <Rainha da Ninhálgida>", "Cidadela da Coroa de Gelo"}
        s["spell;created=80508"] = {"Pedra da Vida do Alquimista", "CRAFTING"}
        s["spell;created=81714"] = {"Óculos Escuros Matadores Bio-ópticos Reforçados", "CRAFTING"}
        s["npc;drop=39705"] = {"Lorde Ascendente Obsidius", "Caverna Rocha Negra"}
        s["spell;created=76443"] = {"Cota de Elemêntio Temperado", "CRAFTING"}
        s["spell;created=76444"] = {"Cinturão de Elemêntio Temperado", "CRAFTING"}
        s["npc;drop=47120"] = {"[Argaloth]", "Guarnição Baradin"}
        s["npc;sold=49386"] = {"Craw Magaw <Intendente do Clã Martelo Feroz>", "Planalto do Crepúsculo"}
        s["npc;drop=39378"] = {"Rajh <Constructo Solar>", "Salões Primordiais"}
        s["npc;sold=48617"] = {"[Blacksmith Abasi] <[Ramkahen Quartermaster]>", "Uldum"}
        s["npc;sold=50314"] = {"Provedora Nuvem Branca <Intendente dos Guardiões de Hyjal>", "Monte Hyjal"}
        s["spell;created=86650"] = {"Maxilar Carcomido", "CRAFTING"}
        s["npc;drop=45261"] = {"Cavaleiro Sombrio do Crepúsculo", "Bastião do Crepúsculo"}
        s["npc;drop=39801"] = {"Guardião da Terra", "Salões Primordiais"}
        s["npc;drop=37217"] = {"[Precious]", "Cidadela da Coroa de Gelo"}
        s["npc;drop=50063"] = {"Akma'hat <Réquiem das Areias Eternas>", "Uldum"}
        s["spell;created=73503"] = {"Anel de Moebius de Elemêntio", "CRAFTING"}
        s["npc;drop=39732"] = {"Setesh <Constructo Destrutivo>", "Salões Primordiais"}
        s["npc;sold=44246"] = {"Ágata Silva <Intendente da Justiça>", "Ventobravo"}
        s["npc;drop=46964"] = {"Lorde Godfrey", "Bastilha da Presa Negra"}
        s["npc;drop=44566"] = {"Ozumat <Demônio das Profundezas>", "Trono das Marés"}
        s["npc;sold=49387"] = {"Grot Bordoada <Intendente do Clã Presa do Dragão>", "Planalto do Crepúsculo"}
        s["spell;created=73506"] = {"Guardião de Elemêntio", "CRAFTING"}
        s["npc;sold=45408"] = {"D'lom, o Coletor <Intendente de Therazane>", "Geodomo"}
        s["npc;drop=42333"] = {"Alta-sacerdotisa Azil", "Litocerne"}
        s["spell;created=73641"] = {"Estatueta – Guardião Terreno", "CRAFTING"}
        s["npc;drop=40484"] = {"Erúdax <O Duque do Abismo>", "Grim Batol"}
        s["spell;created=94732"] = {"Esmaga-mentes de Elemêntio Forjado", "CRAFTING"}
        s["npc;drop=43214"] = {"Couro-pétreo", "Litocerne"}
        s["spell;created=76445"] = {"Necroplacas de Elemêntio", "CRAFTING"}
        s["spell;created=76446"] = {"Cinturão da Dor de Elemêntio", "CRAFTING"}
        s["npc;drop=49813"] = {"Drakonaar Evoluído", "Bastião do Crepúsculo"}
        s["npc;drop=40788"] = {"Dobramentes Ghur'sha", "Trono das Marés"}
        s["npc;drop=47296"] = {"Helix Quebracâmbio", "Minas Mortas"}
        s["npc;drop=47162"] = {"Falagrum <O Capataz>", "Minas Mortas"}
        s["npc;drop=40765"] = {"Comandante Ulthok <O Príncipe Infectado>", "Trono das Marés"}
        s["npc;drop=39698"] = {"Karsh Dobraferro <Armoreiro do Crepúsculo>", "Caverna Rocha Negra"}
        s["npc;drop=40177"] = {"Mestre Forjador Throngus", "Grim Batol"}
        s["npc;drop=39731"] = {"Ammunae <Constructo Vital>", "Salões Primordiais"}
        s["npc;drop=3887"] = {"Barão Silverlaine", "Bastilha da Presa Negra"}
        s["npc;drop=39679"] = {"Corla, a Arauto do Crepúsculo", "Caverna Rocha Negra"}
        s["npc;drop=39587"] = {"Isiset <Constructo Mágico>", "Salões Primordiais"}
        s["npc;drop=47739"] = {"'Capitão' Biscoito <Chefão Défias?>", "Minas Mortas"}
        s["npc;drop=43612"] = {"Sumo Profeta Barim", "Cidade Perdida dos Tol'vir"}
        s["quest;reward=27664"] = {"Baralho Vulcânico de Negraluna", "Floresta de Elwynn"}
        s["spell;created=81722"] = {"Óculos Escuros Matadores Bio-ópticos Ágeis", "CRAFTING"}
        s["npc;drop=23863"] = {"Daakara <O Invencível>", "Zul'Aman"}
        s["npc;drop=23578"] = {"Jan'alai <Avatar de Falcodrago>", "Zul'Aman"}
        s["spell;created=78461"] = {"Cinto dos Sussurros Nefastos", "CRAFTING"}
        s["npc;drop=52151"] = {"Sangrelorde Mandokir", "Zul'Gurub"}
        s["npc;sold=50324"] = {"[Provisioner Arok] <[Earthen Ring Quartermaster]>", "Vastidão Cintilante"}
        s["npc;drop=50009"] = {"Mobus <O Vagalhão>", "Profundezas Abissais"}
        s["npc;sold=46594"] = {"Sargento Chifre Troante <Intendente de Dominação>", "Orgrimmar"}
        s["npc;drop=52148"] = {"Jin'do, o Doma-deus", "Zul'Gurub"}
        s["spell;created=86653"] = {"Folha de Prata Incrustada", "CRAFTING"}
        s["npc;drop=23577"] = {"Halazzi <Avatar de Lince>", "Zul'Aman"}
        s["object;contained=186648"] = {"Baú do Hazlek", "Zul'Aman"}
        s["spell;created=78488"] = {"Guarda-peito do Assassino", "CRAFTING"}
        s["npc;drop=24239"] = {"Grão-bagateiro Malacrass", "Zul'Aman"}
        s["npc;drop=46963"] = {"Lorde Walden", "Bastilha da Presa Negra"}
        s["npc;drop=39425"] = {"Guardião do Templo Anhuur", "Salões Primordiais"}
        s["npc;drop=23586"] = {"Batedor Amani'shi", "Zul'Aman"}
        s["npc;drop=43875"] = {"Asaad <Califa dos Zéfiros>", "Pináculo do Vórtice"}
        s["object;contained=186667"] = {"Pacote da Norkani", "Zul'Aman"}
        s["npc;drop=39700"] = {"Bela", "Caverna Rocha Negra"}
        s["npc;drop=52258"] = {"[Gri'lek]", "Zul'Gurub"}
        s["npc;drop=46962"] = {"Barão Ashbury", "Bastilha da Presa Negra"}
        s["spell;created=73521"] = {"Medalhão de Elemêntio Brônzeo", "CRAFTING"}
        s["npc;drop=39428"] = {"Ptah Furitérreo", "Salões Primordiais"}
        s["spell;created=73498"] = {"Anel de Lâminas", "CRAFTING"}
        s["npc;drop=44819"] = {"Siamat <Senhor do Vento Sul>", "Cidade Perdida dos Tol'vir"}
        s["spell;created=76451"] = {"Foice de Elemêntio", "CRAFTING"}
        s["npc;drop=4278"] = {"Comandante Floraval", "Bastilha da Presa Negra"}
        s["spell;created=81724"] = {"Matassombras Bio-óptico Camuflado", "CRAFTING"}
        s["npc;drop=42803"] = {"Dracodonte Mestiço", "Descenso do Asa Negra"}
        s["npc;drop=43125"] = {"[Spirit of Moltenfist]", "Descenso do Asa Negra"}
        s["spell;created=78487"] = {"Couraça da Fúria da Natureza", "CRAFTING"}
        s["spell;created=78460"] = {"Açoite de Raio", "CRAFTING"}
        s["quest;reward=27666"] = {"Baralho de Maremotos de Negraluna", "Floresta de Elwynn"}
        s["spell;created=96254"] = {"Pedra Vibrante do Alquimista", "CRAFTING"}
        s["npc;drop=43122"] = {"[Spirit of Corehammer]", "Descenso do Asa Negra"}
        s["spell;created=86652"] = {"Globo Ocular Tatuado", "CRAFTING"}
        s["npc;drop=40319"] = {"Drahga Queimassombra <Mensageiro do Martelo do Crepúsculo>", "Grim Batol"}
        s["npc;drop=39625"] = {"General Umbriss <Servo do Asa da Morte>", "Grim Batol"}
        s["npc;drop=50057"] = {"Chaminasa", "Monte Hyjal"}
        s["npc;drop=50086"] = {"Tarvus, o Torpe", "Planalto do Crepúsculo"}
        s["spell;created=73505"] = {"Olho-das-muitas-mortes", "CRAFTING"}
        s["spell;created=73502"] = {"Anel dos Elementos Antagônicos", "CRAFTING"}
        s["quest;reward=28267"] = {"[Firing Squad]", "Uldum"}
        s["npc;drop=43778"] = {"Ceifador de Inimigos 5000", "Minas Mortas"}
        s["spell;created=76450"] = {"Martelo de Elemêntio", "CRAFTING"}
        s["npc;drop=39665"] = {"Rom'ogg Esmaga-ossos", "Caverna Rocha Negra"}
        s["npc;drop=43878"] = {"Grã-vizir Ertan", "Pináculo do Vórtice"}
        s["spell;created=86642"] = {"Mascote Divina", "CRAFTING"}
        s["spell;created=81716"] = {"Matassombras Bio-óptico Mortal", "CRAFTING"}
        s["spell;created=78435"] = {"Torso Conchavalha", "CRAFTING"}
        s["quest;reward=28854"] = {"Encerrando um capítulo sombrio", "Grim Batol"}
        s["spell;created=78463"] = {"Cinturão de Cordas Viperinas", "CRAFTING"}
        s["spell;created=73520"] = {"Anel de Elemêntio do Destruidor", "CRAFTING"}
        s["quest;reward=27665"] = {"Baralho de Furacões de Negraluna", "Floresta de Elwynn"}
        s["npc;drop=47626"] = {"Almirante Rosnarrasga", "Minas Mortas"}
        s["spell;created=84432"] = {"Coice 5.000", "CRAFTING"}
        s["spell;created=84431"] = {"Aniquilador de Galinhas Superpoderoso", "CRAFTING"}
        s["npc;sold=46595"] = {"Guarda-de-sangue Zar'shi <Intendente de Honra>", "Orgrimmar"}
        s["spell;created=78490"] = {"Túnica do Matador de Dragões", "CRAFTING"}
        s["npc;drop=42800"] = {"Sentinela Golem", "Descenso do Asa Negra"}
        s["spell;created=81725"] = {"Matassombras Bio-óptico Leve", "CRAFTING"}
        s["spell;created=75299"] = {"Cinto sem Sonhos", "CRAFTING"}
        s["npc;drop=39415"] = {"Caçaflama Elevado", "Grim Batol"}
        s["npc;drop=52269"] = {"[Renataki]", "Zul'Gurub"}
        s["npc;drop=50089"] = {"Julak-Ruína <O Olho de Zor>", "Planalto do Crepúsculo"}
        s["spell;created=75300"] = {"Culotes dos Pesadelos Reparados", "CRAFTING"}
        s["spell;created=76449"] = {"Lâmina Enfeitiçada de Elemêntio", "CRAFTING"}
        s["spell;created=86641"] = {"Guia das Incursões", "CRAFTING"}
        s["quest;reward=28753"] = {"Fazendo do jeito mais difícil", "Salões Primordiais"}
        s["spell;created=81715"] = {"Óculos Escuros Matadores Bio-ópticos Especializados", "CRAFTING"}
        s["spell;created=76447"] = {"Couraça Leve de Elemêntio", "CRAFTING"}
        s["spell;created=76448"] = {"Cinto Leve de Elemêntio", "CRAFTING"}
        s["spell;created=76455"] = {"Escudo Tonante de Elemêntio", "CRAFTING"}
        s["spell;created=76454"] = {"Terraguarda de Elemêntio", "CRAFTING"}
        s["npc;drop=23576"] = {"Nalorakk <Avatar de Urso>", "Zul'Aman"}
        s["npc;drop=42802"] = {"Draconídeo Matador", "Descenso do Asa Negra"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Orgrimmar"}
        s["spell;created=98921"] = {"Anel do Castigador", "CRAFTING"}
        s["spell;created=73639"] = {"Estatueta – Rei dos Javalis", "CRAFTING"}
        s["spell;created=96252"] = {"Pedra Volátil do Alquimista", "CRAFTING"}
        s["npc;drop=46083"] = {"Dracodonte Mestiço", "Descenso do Asa Negra"}
        s["spell;created=75298"] = {"Cinto das Profundezas", "CRAFTING"}
        s["spell;created=75301"] = {"Pantalonas do Ascendido pelas Chamas", "CRAFTING"}
        s["npc;drop=48450"] = {"Bicante Asassol", "Minas Mortas"}
        s["spell;created=75266"] = {"Capucho Cura-espírito", "CRAFTING"}
        s["quest;reward=28783"] = {"A fonte do poder deles", "Cidade Perdida dos Tol'vir"}
        s["spell;created=75260"] = {"Omoplatas Cura-espírito", "CRAFTING"}
        s["npc;drop=52345"] = {"Orgulho de Bethekk", "Zul'Gurub"}
        s["quest;reward=27788"] = {"Britacrânios, o Montanha", "Planalto do Crepúsculo"}
        s["spell;created=75267"] = {"Veste Cura-espírito", "CRAFTING"}
        s["spell;created=75259"] = {"Braçadeiras Cura-espírito", "CRAFTING"}
        s["npc;drop=24138"] = {"Crocolisco Amani Domado", "Zul'Aman"}
        s["spell;created=75262"] = {"Luvas Cura-Espírito", "CRAFTING"}
        s["spell;created=75258"] = {"Cinto Cura-espírito", "CRAFTING"}
        s["npc;drop=23574"] = {"Akil'zon <Avatar de Águia>", "Zul'Aman"}
        s["npc;drop=40167"] = {"Encantador do Crepúsculo <O Martelo do Crepúsculo>", "Grim Batol"}
        s["spell;created=75263"] = {"Perneiras Cura-espírito", "CRAFTING"}
        s["spell;created=75261"] = {"Botas Cura-espírito", "CRAFTING"}
        s["npc;drop=42764"] = {"Brasamora", "Descenso do Asa Negra"}
        s["spell;created=73643"] = {"Estatueta – Coruja Onírica", "CRAFTING"}
        s["quest;reward=28170"] = {"[Night Terrors]", "Planalto do Crepúsculo"}
        s["quest;reward=27868"] = {"O Caldeirão da Carnificina: o terror do Crepúsculo!", "Planalto do Crepúsculo"}
        s["quest;reward=28595"] = {"[Krazz Works!]", "Planalto do Crepúsculo"}
        s["spell;created=73642"] = {"Estatueta – Serpente Cravejada", "CRAFTING"}
        s["npc;drop=43614"] = {"Trancabucho", "Cidade Perdida dos Tol'vir"}
        s["npc;drop=39803"] = {"Guardião do Ar", "Salões Primordiais"}
        s["spell;created=96253"] = {"Pedra de Azougue do Alquimista", "CRAFTING"}
        s["spell;created=76453"] = {"Estoque de Elemêntio", "CRAFTING"}
        s["spell;created=73640"] = {"Estatueta – Pantera Demoníaca", "CRAFTING"}
        s["quest;reward=11196"] = {"Senhor da Guerra dos Amani", "Zul'Aman"}
        s["npc;drop=42362"] = {"[Drakonid Drudge]", "Descenso do Asa Negra"}
        s["spell;created=94718"] = {"Rasgatripa de Elemêntio", "CRAFTING"}
        s["npc;drop=52271"] = {"[Hazza'rah]", "Zul'Gurub"}
        s["spell;created=81720"] = {"Óculos Escuros Matadores Bio-ópticos Energizados", "CRAFTING"}
        s["spell;created=78489"] = {"Couraça de Escama Crepuscular", "CRAFTING"}
        s["spell;created=78462"] = {"Açoite de Coriscouro", "CRAFTING"}
        s["npc;drop=45687"] = {"Deslocador do Crepúsculo <O Martelo do Crepúsculo>", "Bastião do Crepúsculo"}
        s["quest;reward=28853"] = {"Mate o mensageiro", "Grim Batol"}
        s["npc;drop=39440"] = {"Pateante Venenosa", "Salões Primordiais"}
        s["npc;drop=47720"] = {"[Camel]", "Cidade Perdida dos Tol'vir"}
        s["npc;drop=42789"] = {"Lordemagma Litocerne", "Litocerne"}
        s["quest;reward=27659"] = {"Sobrecarga nos portais", "Planalto do Crepúsculo"}
        s["quest;reward=27748"] = {"[Fortune and Glory]", "Uldum"}
        s["npc;drop=45007"] = {"Bandido Escravizado", "Cidade Perdida dos Tol'vir"}
        s["quest;reward=26876"] = {"[The World Pillar Fragment]", "Geodomo"}
        s["npc;drop=39855"] = {"Vidente Natizúli <Servo do Asa da Morte>", "Grim Batol"}
        s["spell;created=75257"] = {"Veste de Necrosseda", "CRAFTING"}
        s["quest;reward=26830"] = {"A isca do traidor", "Orgrimmar"}
        s["quest;reward=27106"] = {"[A Villain Unmasked]", "Ventobravo"}
        s["quest;reward=28133"] = {"Vingança adormecida", "Planalto do Crepúsculo"}
        s["quest;reward=28282"] = {"[Narkrall, The Drake-Tamer]", "Planalto do Crepúsculo"}
        s["quest;reward=27745"] = {"[A Fiery Reunion]", "Planalto do Crepúsculo"}
        s["quest;reward=28758"] = {"À sombra do destino", "Planalto do Crepúsculo"}
        s["quest;reward=26971"] = {"[The Binding]", "Geodomo"}
        s["quest;reward=27651"] = {"[Doing It Like a Dunwald]", "Planalto do Crepúsculo"}
        s["npc;drop=52418"] = {"Cria Perdida de Gahz'ranka", "Zul'Gurub"}
        s["quest;reward=29186"] = {"O fetiche do Grão-bagateiro", "Zul'Aman"}
        s["quest;reward=28480"] = {"[Lieutenants of Darkness]", "Uldum"}
        s["spell;created=99439"] = {"Punhos da Fúria", "CRAFTING"}
        s["object;contained=188192"] = {"[Ice Chest]", "Pátio dos Escravos"}
        s["spell;created=78476"] = {"Manto Crepuscular de Escama de Dragão", "CRAFTING"}
        s["quest;reward=28612"] = {"[Harrison Jones and the Temple of Uldum]", "Uldum"}
        s["npc;drop=52322"] = {"Mandingueira Qu'in <Curandeira>", "Zul'Gurub"}
        s["npc;drop=23584"] = {"Urso Amani", "Zul'Aman"}
        s["quest;reward=27667"] = {"Baralho de Terremotos de Negraluna", "Floresta de Elwynn"}
        s["quest;reward=27652"] = {"[Dark Assassins]", "Planalto do Crepúsculo"}
        s["quest;reward=27653"] = {"Assassinos sombrios", "Planalto do Crepúsculo"}
        s["npc;drop=52363"] = {"[Occu'thar]", "Guarnição Baradin"}
        s["spell;created=99452"] = {"Coturnos dos Senhores Poderosos", "CRAFTING"}
        s["spell;created=54982"] = {"Criar Tabardo Roxo Comemorativo dos Illidari", "CRAFTING"}
        s["npc;sold=54401"] = {"[Naresir Stormfury] <[Avengers of Hyjal Quartermaster]>", "Monte Hyjal"}
        s["npc;sold=53882"] = {"Varlan Galhalto <Provisões do Bosque>", "Front Ígneo"}
        s["spell;created=99654"] = {"Martelo de Elemêntio Forjado a Luz", "CRAFTING"}
        s["npc;sold=53881"] = {"Ayla Tempessombra <Tesouros de Eluna>", "Front Ígneo"}
        s["spell;created=99457"] = {"Botinas do Ofício", "CRAFTING"}
        s["spell;created=99446"] = {"Garras do Mal", "CRAFTING"}
        s["spell;created=99660"] = {"Ceifador do Caçador de Bruxas", "CRAFTING"}
        s["spell;created=99458"] = {"Ladrinas Etéreas", "CRAFTING"}
        s["npc;sold=52822"] = {"Zen'Vorka <Favores da Árvore do Mundo>", "Front Ígneo"}
        s["spell;created=100687"] = {"Esburacadora de Alto Impacto", "CRAFTING"}
        s["spell;created=99460"] = {"Botas da Chama Negra", "CRAFTING"}
        s["spell;created=99653"] = {"Lâmina Enfeitiçada de Elemêntio Magistral", "CRAFTING"}
        s["npc;sold=53214"] = {"Damek Barbabroto <Equipamentos Excepcionais>", "Front Ígneo"}
        s["spell;created=99459"] = {"Botas do Sonho Eterno", "CRAFTING"}
        s["spell;created=99455"] = {"Escarpes de Escama Terrana", "CRAFTING"}
        s["spell;created=99449"] = {"Mitenes Infernais de Dom Tayo", "CRAFTING"}
        s["spell;created=99657"] = {"Guardião Inquebrantável", "CRAFTING"}
        s["npc;sold=54402"] = {"[Lurah Wrathvine] <[Crystallized Firestone Collector]>", "Monte Hyjal"}
        s["npc;drop=52409"] = {"[Ragnaros]", "Terras do Fogo"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "Terras do Fogo"}
        s["npc;drop=53691"] = {"[Shannox]", "Terras do Fogo"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "Terras do Fogo"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "Terras do Fogo"}
        s["npc;drop=52530"] = {"[Alysrazor]", "Terras do Fogo"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "Terras do Fogo"}
        s["quest;reward=29331"] = {"Prisão elemental: Juramento", "Monte Hyjal"}
        s["npc;drop=53616"] = {"[Kar the Everburning] <[Firelord]>", "Terras do Fogo"}
        s["npc;drop=54161"] = {"[Flame Archon]", "Terras do Fogo"}
        s["npc;sold=52549"] = {"Sargento Chifre Troante <Intendente de Dominação>", "Orgrimmar"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "Ventobravo"}
        s["npc;drop=55689"] = {"[Hagara the Stormbinder]", "Alma Dragônica"}
        s["npc;drop=55308"] = {"[Warlord Zon'ozz]", "Alma Dragônica"}
        s["npc;drop=55265"] = {"[Morchok]", "Alma Dragônica"}
        s["npc;drop=55294"] = {"[Ultraxion]", "Alma Dragônica"}
        s["npc;drop=55312"] = {"[Yor'sahj the Unsleeping]", "Alma Dragônica"}
        s["npc;drop=56173"] = {"[Deathwing] <[The Destroyer]>", "Alma Dragônica"}
        s["npc;drop=57821"] = {"[Lieutenant Shara] <[The Twilight's Hammer]>", "Alma Dragônica"}
        s["spell;created=101932"] = {"Braceletes da Guarda Titânica", "CRAFTING"}
        s["npc;sold=241467"] = {"Sylstrasza <Troca de Fragmentos Obsidianos>", "Orgrimmar"}
        s["npc;drop=54938"] = {"Arcebispo Benedictus", "Hora do Crepúsculo"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "Alma Dragônica"}
        s["spell;created=101925"] = {"Coxotes do Destruidor Implacável", "CRAFTING"}
        s["spell;created=101931"] = {"Braçadeiras da Força Destrutiva", "CRAFTING"}
        s["spell;created=101933"] = {"Perneiras do Campeão da Natureza", "CRAFTING"}
        s["spell;created=101937"] = {"Braçadeiras da Serenidade Fluida", "CRAFTING"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "Alma Dragônica"}
        s["spell;created=101940"] = {"Munhequeiras Laminumbra", "CRAFTING"}
        s["spell;created=101941"] = {"Braçadeiras do Caçador-assassino", "CRAFTING"}
        s["spell;created=101921"] = {"Culotes da Magmoto", "CRAFTING"}
        s["spell;created=101923"] = {"Braçadeiras do Poder Insubjugável", "CRAFTING"}
        s["spell;created=101929"] = {"Braçadeiras do Redentor de Almas", "CRAFTING"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "Guarnição Baradin"}
        s["spell;created=101922"] = {"Braça-sonhos da Luz", "CRAFTING"}
        s["spell;created=101934"] = {"Perneiras de Mortescama", "CRAFTING"}
        s["spell;created=101939"] = {"Munhequeiras de Mortescama Trovejantes", "CRAFTING"}
        s["quest;reward=30118"] = {"[Patricide]", "Alma Dragônica"}
        s["spell;created=101935"] = {"Perneiras Laminumbra", "CRAFTING"}
        s["npc;sold=54658"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "Orgrimmar"}
    end

    function SpecBisTooltip:TranslationruRU()
        s["npc;sold=44245"] = {"Фалдрен Тиллсдейл <Награды за очки доблести>", "Штормград"}
        s["npc;drop=41376"] = {"Нефариан", "Твердыня Крыла Тьмы"}
        s["npc;drop=9056"] = {"Финий Темнострой <Главный архитектор>", "Глубины Черной горы"}
        s["npc;drop=42178"] = {"Магматрон", "Твердыня Крыла Тьмы"}
        s["npc;drop=43296"] = {"Химерон", "Твердыня Крыла Тьмы"}
        s["npc;drop=44600"] = {"Халфий Змеерез", "Сумеречный бастион"}
        s["npc;drop=45992"] = {"Валиона", "Сумеречный бастион"}
        s["npc;sold=47328"] = {"Интендант Брейзи <Интендант защитников Тол Барада>", "Полуостров Тол Барад"}
        s["npc;drop=41570"] = {"Магмарь", "Твердыня Крыла Тьмы"}
        s["npc;drop=43735"] = {"Элементиевое чудовище", "Сумеречный бастион"}
        s["quest;reward=24919"] = {"", "Цитадель Ледяной Короны"}
        s["npc;drop=45213"] = {"Синестра <Супруга Смертокрыла>", "Сумеречный бастион"}
        s["npc;drop=45871"] = {"Незир <Повелитель северного ветра>", "Трон Четырех Ветров"}
        s["npc;drop=46753"] = {"Ал'акир", "Трон Четырех Ветров"}
        s["npc;drop=41378"] = {"Малориак", "Твердыня Крыла Тьмы"}
        s["npc;drop=43324"] = {"Чо'Галл", "Сумеречный бастион"}
        s["npc;drop=41442"] = {"Атрамед", "Твердыня Крыла Тьмы"}
        s["npc;sold=48531"] = {"Погг <Интендант батальона Адского Крика>", "Полуостров Тол Барад"}
        s["npc;drop=36853"] = {"Синдрагоса <Королева ледяных драконов>", "Цитадель Ледяной Короны"}
        s["spell;created=80508"] = {"Алхимический камень жизни", "CRAFTING"}
        s["npc;drop=44577"] = {"Генерал Хусам", "Затерянный город Тол'вир"}
        s["spell;created=81714"] = {"Армированные биооптические защитные очки", "CRAFTING"}
        s["npc;drop=39705"] = {"Повелитель Перерожденных Обсидий", "Пещеры Черной горы"}
        s["spell;created=76443"] = {"Хауберк из закаленного элементия", "CRAFTING"}
        s["spell;created=76444"] = {"Ремень из закаленного элементия", "CRAFTING"}
        s["npc;drop=47120"] = {"Аргалот", "Крепость Барадин"}
        s["npc;sold=49386"] = {"Кро Макгро <Интендант Громового Молота>", "Сумеречное нагорье"}
        s["npc;drop=39788"] = {"Анрафет", "Чертоги Созидания"}
        s["npc;drop=39378"] = {"Радж <Творение Солнца>", "Чертоги Созидания"}
        s["npc;sold=48617"] = {"Кузнец Абаси <Интендант рамкахенов>", "Ульдум"}
        s["npc;sold=50314"] = {"Поставщица Белое Облако <Интендант Стражей Хиджала>", "Хиджал"}
        s["npc;drop=42188"] = {"Озрук", "Каменные Недра"}
        s["spell;created=86650"] = {"Зазубренная челюстная кость", "CRAFTING"}
        s["npc;drop=45261"] = {"Сумеречный рыцарь тени", "Сумеречный бастион"}
        s["npc;drop=39801"] = {"Стражник Земли", "Чертоги Созидания"}
        s["npc;drop=37217"] = {"Прелесть", "Цитадель Ледяной Короны"}
        s["npc;drop=50061"] = {"Зариона", "Подземье"}
        s["npc;drop=50060"] = {"Тербурий", "Подземье"}
        s["npc;drop=50063"] = {"Акма'хат <Погребальная песнь вечных песков>", "Ульдум"}
        s["spell;created=73503"] = {"Элементиевое кольцо Мебиуса", "CRAFTING"}
        s["npc;drop=39732"] = {"Сетеш <Творение Разрушения>", "Чертоги Созидания"}
        s["npc;sold=44246"] = {"Магата Силвертон <Награды за очки справедливости>", "Штормград"}
        s["npc;drop=46964"] = {"Лорд Годфри", "Крепость Темного Клыка"}
        s["npc;drop=49045"] = {"Ауг", "Затерянный город Тол'вир"}
        s["npc;drop=44566"] = {"Озумат <Демон темных глубин>", "Трон Приливов"}
        s["npc;sold=49387"] = {"Грот Смертельный Выпад <Интендант Драконьей Пасти>", "Сумеречное нагорье"}
        s["spell;created=73506"] = {"Элементиевый страж", "CRAFTING"}
        s["npc;sold=45408"] = {"Д'лом Собиратель <Интендант Теразан>", "Подземье"}
        s["npc;drop=42333"] = {"Верховная жрица Азил", "Каменные Недра"}
        s["spell;created=73641"] = {"Статуэтка земельника-стража", "CRAFTING"}
        s["npc;drop=40484"] = {"Эрудакс <Повелитель Глубин>", "Грим Батол"}
        s["spell;created=94732"] = {"Закаленный элементиевый мозголом", "CRAFTING"}
        s["npc;drop=43214"] = {"Камнешкур", "Каменные Недра"}
        s["spell;created=76445"] = {"Элементиевые латы смерти", "CRAFTING"}
        s["spell;created=76446"] = {"Элементиевый ремень боли", "CRAFTING"}
        s["npc;drop=49813"] = {"Преобразившийся драконаар", "Сумеречный бастион"}
        s["npc;drop=40788"] = {"Подчиняющий разум Гур'ша", "Трон Приливов"}
        s["npc;drop=47296"] = {"Хеликс Отломчикс", "Мертвые копи"}
        s["npc;drop=49541"] = {"Ванесса ван Клиф", "Мертвые копи"}
        s["npc;drop=47162"] = {"Глубток <Штейгер>", "Мертвые копи"}
        s["npc;drop=40765"] = {"Командир Улток <Разлагающийся принц>", "Трон Приливов"}
        s["npc;drop=39698"] = {"Карш Гнущий Сталь <Бронник Сумеречного Молота>", "Пещеры Черной горы"}
        s["npc;drop=50056"] = {"Гарр", "Хиджал"}
        s["npc;drop=40177"] = {"Начальник кузни Тронг", "Грим Батол"}
        s["npc;drop=39731"] = {"Аммунаэ <Творение Жизни>", "Чертоги Созидания"}
        s["npc;drop=3887"] = {"Барон Сильверлейн", "Крепость Темного Клыка"}
        s["npc;drop=39679"] = {"Глашатай сумрака Корла", "Пещеры Черной горы"}
        s["npc;drop=39587"] = {"Изисет <Творение Магии>", "Чертоги Созидания"}
        s["npc;drop=47739"] = {"'Капитан' Пирожок <Главарь Братства Справедливости?>", "Мертвые копи"}
        s["npc;drop=43612"] = {"Верховный пророк Барим", "Затерянный город Тол'вир"}
        s["npc;drop=45993"] = {"Тералион", "Сумеречный бастион"}
        s["quest;reward=27664"] = {"", "Элвиннский лес"}
        s["npc;drop=42180"] = {"Токситрон", "Твердыня Крыла Тьмы"}
        s["spell;created=81722"] = {"Повышающие проворство биооптические защитные очки", "CRAFTING"}
        s["npc;drop=23863"] = {"Даакара <Непобедимый>", "Зул'Аман"}
        s["npc;drop=23578"] = {"Джан'алай <Аватара дракондора>", "Зул'Аман"}
        s["spell;created=78461"] = {"Пояс гнусного шепота", "CRAFTING"}
        s["npc;drop=42767"] = {"Иворок", "Твердыня Крыла Тьмы"}
        s["npc;drop=52151"] = {"Мандокир Повелитель Крови", "Зул'Гуруб"}
        s["npc;sold=50324"] = {"Поставщик Аарок <Интендант Служителей Земли>", "Мерцающий простор"}
        s["npc;drop=43438"] = {"Корбор", "Каменные Недра"}
        s["npc;drop=50009"] = {"Мобус <Крушащая волна>", "Бездонные глубины"}
        s["npc;sold=46594"] = {"Сержант Громовой Рог <Награды за очки завоевания>", "Оргриммар"}
        s["npc;drop=52148"] = {"Джин'до Низвергатель Богов", "Зул'Гуруб"}
        s["spell;created=86653"] = {"Инкрустированный серебром лист", "CRAFTING"}
        s["npc;drop=23577"] = {"Халаззи <Аватара рыси>", "Зул'Аман"}
        s["object;contained=186648"] = {"Сундучок Хазлека", "Зул'Аман"}
        s["spell;created=78488"] = {"Бригантина убийцы", "CRAFTING"}
        s["npc;drop=24239"] = {"Повелитель проклятий Малакрасс", "Зул'Аман"}
        s["npc;drop=46963"] = {"Лорд Вальден", "Крепость Темного Клыка"}
        s["npc;drop=39425"] = {"Храмовый страж Ануур", "Чертоги Созидания"}
        s["npc;drop=23586"] = {"Разведчик из племени Амани", "Зул'Аман"}
        s["npc;drop=43875"] = {"Асаад <Калиф ветров>", "Вершина Смерча"}
        s["object;contained=186667"] = {"Тюк Норкани", "Зул'Аман"}
        s["npc;drop=39700"] = {"Красавица", "Пещеры Черной горы"}
        s["npc;drop=52258"] = {"Гри'лек", "Зул'Гуруб"}
        s["npc;drop=46962"] = {"Барон Эшбери", "Крепость Темного Клыка"}
        s["spell;created=73521"] = {"Покрытый бронзой элементиевый медальон", "CRAFTING"}
        s["npc;drop=39428"] = {"Пта Ярость Земли", "Чертоги Созидания"}
        s["spell;created=73498"] = {"Перстень клинков", "CRAFTING"}
        s["npc;drop=44819"] = {"Сиамат <Повелитель южного ветра>", "Затерянный город Тол'вир"}
        s["spell;created=76451"] = {"Элементиевый боевой топор", "CRAFTING"}
        s["npc;drop=4278"] = {"Командир Спрингвейл", "Крепость Темного Клыка"}
        s["spell;created=81724"] = {"Маскировочные биооптические защитные очки", "CRAFTING"}
        s["npc;drop=42803"] = {"Дракобель-полукровка", "Твердыня Крыла Тьмы"}
        s["npc;drop=43125"] = {"Дух Литого Кулака", "Твердыня Крыла Тьмы"}
        s["spell;created=78487"] = {"Нагрудный доспех ярости природы", "CRAFTING"}
        s["spell;created=78460"] = {"Грозовой ремешок", "CRAFTING"}
        s["quest;reward=27666"] = {"", "Элвиннский лес"}
        s["spell;created=96254"] = {"Резонирующий алхимический камень", "CRAFTING"}
        s["npc;drop=43122"] = {"Дух Молота Глубин", "Твердыня Крыла Тьмы"}
        s["spell;created=86652"] = {"Татуированное глазное яблоко", "CRAFTING"}
        s["npc;drop=43873"] = {"Альтаирий", "Вершина Смерча"}
        s["npc;drop=40586"] = {"Леди Наз'жар", "Трон Приливов"}
        s["npc;drop=40319"] = {"Драгх Горячий Мрак <Курьер Сумеречного Молота>", "Грим Батол"}
        s["npc;drop=39625"] = {"Генерал Умбрисс <Служитель Смертокрыла>", "Грим Батол"}
        s["npc;drop=50057"] = {"Жарокрыл", "Хиджал"}
        s["npc;drop=50086"] = {"Тарвий Злобный", "Сумеречное нагорье"}
        s["spell;created=73505"] = {"Око тысячи смертей", "CRAFTING"}
        s["spell;created=73502"] = {"Кольцо противоборствующих стихий", "CRAFTING"}
        s["quest;reward=28267"] = {"", "Ульдум"}
        s["npc;drop=43778"] = {"Врагорез-5000", "Мертвые копи"}
        s["spell;created=76450"] = {"Элементиевый молот", "CRAFTING"}
        s["npc;drop=39665"] = {"Ром'огг Костекрушитель", "Пещеры Черной горы"}
        s["npc;drop=43878"] = {"Великий визирь Эртан", "Вершина Смерча"}
        s["spell;created=86642"] = {"Божественный спутник", "CRAFTING"}
        s["spell;created=81716"] = {"Смертоносные биооптические защитные очки", "CRAFTING"}
        s["spell;created=78435"] = {"Латы из морских черенков", "CRAFTING"}
        s["quest;reward=28854"] = {"", "Грим Батол"}
        s["spell;created=78463"] = {"Пояс из усмиренной гадюки", "CRAFTING"}
        s["spell;created=73520"] = {"Элементиевый перстень разрушителя", "CRAFTING"}
        s["quest;reward=27665"] = {"", "Элвиннский лес"}
        s["npc;drop=47626"] = {"Адмирал Терзающий Рев", "Мертвые копи"}
        s["spell;created=84432"] = {"Откат 5000", "CRAFTING"}
        s["spell;created=84431"] = {"Куробойка повышенной мощности", "CRAFTING"}
        s["npc;sold=46595"] = {"Кровавый страж Зар'ши <Награды за очки чести>", "Оргриммар"}
        s["spell;created=78490"] = {"Мундир драконобоя", "CRAFTING"}
        s["npc;drop=42800"] = {"Караульный голем", "Твердыня Крыла Тьмы"}
        s["spell;created=81725"] = {"Облегченные биооптические защитные очки", "CRAFTING"}
        s["spell;created=75299"] = {"Пояс сна без сновидений", "CRAFTING"}
        s["npc;drop=39415"] = {"Перерожденный поджигатель", "Грим Батол"}
        s["npc;drop=52269"] = {"Ренатаки", "Зул'Гуруб"}
        s["npc;drop=50089"] = {"Джулак-Рок <Око Зора>", "Сумеречное нагорье"}
        s["spell;created=75300"] = {"Брюки избавления от кошмаров", "CRAFTING"}
        s["spell;created=76449"] = {"Элементиевый чародейский клинок", "CRAFTING"}
        s["spell;created=86641"] = {"Руководство по исследованию подземелий", "CRAFTING"}
        s["quest;reward=28753"] = {"", "Чертоги Созидания"}
        s["spell;created=81715"] = {"Специализированные биооптические защитные очки", "CRAFTING"}
        s["spell;created=76447"] = {"Легкий элементиевый нагрудный доспех", "CRAFTING"}
        s["spell;created=76448"] = {"Легкий элементиевый пояс", "CRAFTING"}
        s["spell;created=76455"] = {"Элементиевый щит бури", "CRAFTING"}
        s["npc;drop=50050"] = {"Шок'шарак", "Бездонные глубины"}
        s["spell;created=76454"] = {"Элементиевый страж земли", "CRAFTING"}
        s["npc;drop=52053"] = {"Занзил", "Зул'Гуруб"}
        s["npc;drop=23576"] = {"Налоракк <Аватара медведя>", "Зул'Аман"}
        s["npc;drop=42802"] = {"Драконид-истребитель", "Твердыня Крыла Тьмы"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "Оргриммар"}
        s["spell;created=98921"] = {"Кольцо палача", "CRAFTING"}
        s["spell;created=73639"] = {"Статуэтка - король вепрей", "CRAFTING"}
        s["spell;created=96252"] = {"Неустойчивый алхимический камень", "CRAFTING"}
        s["npc;drop=46083"] = {"Дракобель-полукровка", "Твердыня Крыла Тьмы"}
        s["spell;created=75298"] = {"Пояс глубин", "CRAFTING"}
        s["spell;created=75301"] = {"Подпаленные кюлоты", "CRAFTING"}
        s["npc;drop=48450"] = {"Яснокрылый визгун", "Мертвые копи"}
        s["spell;created=75266"] = {"Клобук духовного выздоровления", "CRAFTING"}
        s["quest;reward=28783"] = {"", "Затерянный город Тол'вир"}
        s["spell;created=75260"] = {"Наплечники духовного выздоровления", "CRAFTING"}
        s["npc;drop=52345"] = {"Пантера Бетекк", "Зул'Гуруб"}
        s["quest;reward=27788"] = {"", "Сумеречное нагорье"}
        s["spell;created=75267"] = {"Одеяние духовного выздоровления", "CRAFTING"}
        s["spell;created=75259"] = {"Наручи духовного выздоровления", "CRAFTING"}
        s["npc;drop=24138"] = {"Прирученный аманийский кроколиск", "Зул'Аман"}
        s["spell;created=75262"] = {"Перчатки духовного выздоровления", "CRAFTING"}
        s["spell;created=75258"] = {"Пояс духовного выздоровления", "CRAFTING"}
        s["npc;drop=23574"] = {"Акил'зон <Аватара орла>", "Зул'Аман"}
        s["npc;drop=40167"] = {"Сумеречный обманщик <Сумеречный Молот>", "Грим Батол"}
        s["spell;created=75263"] = {"Поножи духовного выздоровления", "CRAFTING"}
        s["spell;created=75261"] = {"Сапоги духовного выздоровления", "CRAFTING"}
        s["npc;drop=42764"] = {"Пылающий Зоб", "Твердыня Крыла Тьмы"}
        s["spell;created=73643"] = {"Статуэтка - спящая сова", "CRAFTING"}
        s["quest;reward=28170"] = {"", "Сумеречное нагорье"}
        s["quest;reward=27868"] = {"", "Сумеречное нагорье"}
        s["quest;reward=28595"] = {"", "Сумеречное нагорье"}
        s["spell;created=73642"] = {"Статуэтка - украшенная камнями змея", "CRAFTING"}
        s["npc;drop=43614"] = {"Зубохлоп", "Затерянный город Тол'вир"}
        s["npc;drop=39803"] = {"Стражник Воздуха", "Чертоги Созидания"}
        s["spell;created=96253"] = {"Переменчивый алхимический камень", "CRAFTING"}
        s["spell;created=76453"] = {"Элементиевая заточка", "CRAFTING"}
        s["spell;created=73640"] = {"Статуэтка демонической пантеры", "CRAFTING"}
        s["quest;reward=11196"] = {"Вождь Амани", "Зул'Аман"}
        s["npc;drop=42362"] = {"Драконид-рабочий", "Твердыня Крыла Тьмы"}
        s["spell;created=94718"] = {"Элементиевый брюхорез", "CRAFTING"}
        s["npc;drop=52271"] = {"Хазза'рах", "Зул'Гуруб"}
        s["spell;created=81720"] = {"Заряженные биооптические защитные очки", "CRAFTING"}
        s["spell;created=78489"] = {"Нагрудный доспех из сумеречной чешуи", "CRAFTING"}
        s["spell;created=78462"] = {"Кушак порфиры бурь", "CRAFTING"}
        s["npc;drop=45687"] = {"Сумеречный косторез <Сумеречный Молот>", "Сумеречный бастион"}
        s["quest;reward=28853"] = {"", "Грим Батол"}
        s["npc;drop=39440"] = {"Ядовитый быстролап", "Чертоги Созидания"}
        s["npc;drop=47720"] = {"Верблюд", "Затерянный город Тол'вир"}
        s["npc;drop=42789"] = {"Повелитель магмы Каменных Недр", "Каменные Недра"}
        s["quest;reward=27659"] = {"", "Сумеречное нагорье"}
        s["quest;reward=27748"] = {"", "Ульдум"}
        s["npc;drop=45007"] = {"Порабощенный бандит", "Затерянный город Тол'вир"}
        s["quest;reward=26876"] = {"", "Подземье"}
        s["npc;drop=39855"] = {"Рожденный в лазури провидец <Служитель Смертокрыла>", "Грим Батол"}
        s["spell;created=75257"] = {"Смертошелковое одеяние", "CRAFTING"}
        s["quest;reward=26830"] = {"", "Оргриммар"}
        s["quest;reward=27106"] = {"", "Штормград"}
        s["quest;reward=28133"] = {"", "Сумеречное нагорье"}
        s["quest;reward=28282"] = {"", "Сумеречное нагорье"}
        s["quest;reward=27745"] = {"", "Сумеречное нагорье"}
        s["quest;reward=28758"] = {"", "Сумеречное нагорье"}
        s["quest;reward=26971"] = {"", "Подземье"}
        s["quest;reward=27651"] = {"", "Сумеречное нагорье"}
        s["npc;drop=52418"] = {"Потерявшийся отпрыск Газ'ранки", "Зул'Гуруб"}
        s["quest;reward=29186"] = {"", "Зул'Аман"}
        s["quest;reward=28480"] = {"", "Ульдум"}
        s["spell;created=99439"] = {"Кулаки неистовства", "CRAFTING"}
        s["object;contained=188192"] = {"Ледник", "Узилище"}
        s["spell;created=78476"] = {"Плащ из чешуи сумеречного дракона", "CRAFTING"}
        s["quest;reward=28612"] = {"", "Ульдум"}
        s["npc;drop=52322"] = {"Доктор Ку'ин <Тролль-знахарка>", "Зул'Гуруб"}
        s["npc;drop=23584"] = {"Аманийский медведь", "Зул'Аман"}
        s["quest;reward=27667"] = {"", "Элвиннский лес"}
        s["quest;reward=27652"] = {"", "Сумеречное нагорье"}
        s["quest;reward=27653"] = {"", "Сумеречное нагорье"}
        s["npc;drop=52363"] = {"Оку'тар", "Крепость Барадин"}
        s["spell;created=99452"] = {"Боевые сапоги могучих повелителей", "CRAFTING"}
        s["spell;created=54982"] = {"Создание фиолетовой трофейной гербовой накидки Иллидари", "CRAFTING"}
        s["npc;sold=54401"] = {"Наресир Штормовая Ярость <Интендант Хиджальских мстителей>", "Хиджал"}
        s["npc;sold=53882"] = {"Варлан Высокая Ветвь <Поставщик>", "Огненная передовая"}
        s["spell;created=99654"] = {"Элементиевый молот из светостали", "CRAFTING"}
        s["npc;sold=53881"] = {"Айла Темная Буря <Сокровища Элуны>", "Огненная передовая"}
        s["spell;created=99457"] = {"Ботфорты темного ремесла", "CRAFTING"}
        s["spell;created=99446"] = {"Хватка зла", "CRAFTING"}
        s["spell;created=99660"] = {"Коса охотника на ведьм", "CRAFTING"}
        s["spell;created=99458"] = {"Астральные шаги", "CRAFTING"}
        s["npc;sold=52822"] = {"Зен'Ворка <Защитники Древа Жизни>", "Огненная передовая"}
        s["spell;created=100687"] = {"Прицельный перфоратор", "CRAFTING"}
        s["spell;created=99460"] = {"Сапоги черного пламени", "CRAFTING"}
        s["spell;created=99653"] = {"Обсидиановый чародейский клинок искусной работы", "CRAFTING"}
        s["npc;sold=53214"] = {"Дамек Цветобород <Эксклюзивное снаряжение>", "Огненная передовая"}
        s["spell;created=99459"] = {"Сапоги бесконечного сна", "CRAFTING"}
        s["spell;created=99455"] = {"Башмаки из земляных чешуек", "CRAFTING"}
        s["spell;created=99449"] = {"Инфернальные полуперчатки дона Тайо", "CRAFTING"}
        s["spell;created=99657"] = {"Непреклонный страж", "CRAFTING"}
        s["npc;sold=54402"] = {"Лура Гневная Лоза <Собиратель кристаллизованного кремня>", "Хиджал"}
        s["npc;drop=52409"] = {"Рагнарос", "Огненные Просторы"}
        s["npc;drop=52571"] = {"Мажордом Фэндрал Олений Шлем <Верховный друид пламени>", "Огненные Просторы"}
        s["npc;drop=53691"] = {"Шэннокс", "Огненные Просторы"}
        s["npc;drop=52498"] = {"Бет'тилак <Красная Вдова>", "Огненные Просторы"}
        s["npc;drop=52558"] = {"Повелитель Риолит", "Огненные Просторы"}
        s["npc;drop=52530"] = {"Алисразор", "Огненные Просторы"}
        s["npc;drop=53494"] = {"Бейлрок <Привратник>", "Огненные Просторы"}
        s["quest;reward=29331"] = {"Власть стихий: обет", "Хиджал"}
        s["npc;drop=53616"] = {"Кар Вечнопылающий <Повелитель огня>", "Огненные Просторы"}
        s["npc;drop=54161"] = {"Полыхающий архонт", "Огненные Просторы"}
        s["npc;sold=52549"] = {"Сержант Громовой Рог <Награды за очки завоевания>", "Оргриммар"}
        s["quest;reward=29312"] = {"Посох легенд", "Штормград"}
        s["npc;drop=55689"] = {"Хагара Владычица Штормов", "Душа Дракона"}
        s["npc;drop=55308"] = {"Полководец Зон'озз", "Душа Дракона"}
        s["npc;drop=55265"] = {"Морхок", "Душа Дракона"}
        s["npc;drop=55294"] = {"Ультраксион", "Душа Дракона"}
        s["npc;drop=55312"] = {"Йор'садж Неспящий", "Душа Дракона"}
        s["npc;drop=56173"] = {"Смертокрыл <Разрушитель>", "Душа Дракона"}
        s["npc;drop=57821"] = {"Лейтенант Шара <Сумеречный молот>", "Душа Дракона"}
        s["spell;created=101932"] = {"Наручи титанового стража", "CRAFTING"}
        s["npc;sold=241467"] = {"Сильстраза <Обмен обсидиановых фрагментов>", "Оргриммар"}
        s["npc;drop=54938"] = {"Архиепископ Бенедикт", "Время Сумерек"}
        s["npc;drop=53879"] = {"Смертокрыл <Разрушитель>", "Душа Дракона"}
        s["spell;created=101925"] = {"Ножные латы неудержимого разрушителя", "CRAFTING"}
        s["spell;created=101931"] = {"Наручи разрушительной силы", "CRAFTING"}
        s["spell;created=101933"] = {"Поножи защитника природы", "CRAFTING"}
        s["spell;created=101937"] = {"Наручи вечной безмятежности", "CRAFTING"}
        s["npc;drop=56427"] = {"Воевода Черный Рог", "Душа Дракона"}
        s["spell;created=101940"] = {"Накулачники Тени Клинка", "CRAFTING"}
        s["spell;created=101941"] = {"Наручи охотника-убийцы", "CRAFTING"}
        s["spell;created=101921"] = {"Бриджи лавового землетрясения", "CRAFTING"}
        s["spell;created=101923"] = {"Наручи непобедимой силы", "CRAFTING"}
        s["spell;created=101929"] = {"Наручи спасителя душ", "CRAFTING"}
        s["npc;drop=55869"] = {"Ализабаль <Госпожа Ненависти>", "Крепость Барадин"}
        s["spell;created=101922"] = {"Мечтательные повязки света", "CRAFTING"}
        s["spell;created=101934"] = {"Поножи из смертоносной чешуи", "CRAFTING"}
        s["spell;created=101939"] = {"Грозовые накулачники из смертоносной чешуи", "CRAFTING"}
        s["npc;drop=55085"] = {"Перот'арн", "Источник Вечности"}
        s["quest;reward=30118"] = {"[Patricide]", "Душа Дракона"}
        s["spell;created=101935"] = {"Поножи Тени Клинка", "CRAFTING"}
        s["npc;sold=54658"] = {"Сержант Громовой Рог <Награды за очки завоевания>", "Оргриммар"}
    end

    function SpecBisTooltip:TranslationzhCN()
        s["npc;sold=44245"] = {"[Faldren Tillsdale] <[Valor Quartermaster]>", "暴风城"}
        s["npc;drop=41376"] = {"[Nefarian]", "黑翼血环"}
        s["npc;drop=9056"] = {"弗诺斯·达克维尔 <首席建筑师>", "黑石深渊"}
        s["npc;drop=42178"] = {"[Magmatron]", "黑翼血环"}
        s["npc;drop=43296"] = {"[Chimaeron]", "黑翼血环"}
        s["npc;drop=44600"] = {"[Halfus Wyrmbreaker]", "暮光堡垒"}
        s["npc;drop=45992"] = {"[Valiona]", "暮光堡垒"}
        s["npc;sold=47328"] = {"[Quartermaster Brazie] <[Baradin's Wardens Quartermaster]>", "托尔巴拉德半岛"}
        s["npc;drop=41570"] = {"[Magmaw]", "黑翼血环"}
        s["npc;drop=43735"] = {"[Elementium Monstrosity]", "暮光堡垒"}
        s["quest;reward=24919"] = {"光明使者的救赎", "冰冠堡垒"}
        s["npc;drop=45213"] = {"[Sinestra] <[Consort of Deathwing]>", "暮光堡垒"}
        s["npc;drop=45871"] = {"[Nezir] <[Lord of the North Wind]>", "风神王座"}
        s["npc;drop=46753"] = {"[Al'Akir]", "风神王座"}
        s["npc;drop=41378"] = {"[Maloriak]", "黑翼血环"}
        s["npc;drop=43324"] = {"[Cho'gall]", "暮光堡垒"}
        s["npc;drop=41442"] = {"[Atramedes]", "黑翼血环"}
        s["npc;sold=48531"] = {"[Pogg] <[Hellscream's Reach Quartermaster]>", "托尔巴拉德半岛"}
        s["npc;drop=36853"] = {"[Sindragosa] <[Queen of the Frostbrood]>", "冰冠堡垒"}
        s["spell;created=80508"] = {"生命炼金石", "CRAFTING"}
        s["npc;drop=44577"] = {"[General Husam]", "托维尔失落之城"}
        s["spell;created=81714"] = {"强化生物光学远望镜", "CRAFTING"}
        s["npc;drop=39705"] = {"[Ascendant Lord Obsidius]", "黑石岩窟"}
        s["spell;created=76443"] = {"硬化源质胸铠", "CRAFTING"}
        s["spell;created=76444"] = {"硬化源质束带", "CRAFTING"}
        s["npc;sold=49386"] = {"[Craw MacGraw] <[Wildhammer Clan Quartermaster]>", "暮光高地"}
        s["npc;drop=39788"] = {"[Anraphet]", "起源大厅"}
        s["npc;drop=39378"] = {"[Rajh] <[Construct of the Sun]>", "起源大厅"}
        s["npc;sold=48617"] = {"[Blacksmith Abasi] <[Ramkahen Quartermaster]>", "奥丹姆"}
        s["npc;sold=50314"] = {"[Provisioner Whitecloud] <[Guardians of Hyjal Quartermaster]>", "海加尔山"}
        s["npc;drop=42188"] = {"[Ozruk]", "巨石之核"}
        s["spell;created=86650"] = {"锯齿颌骨", "CRAFTING"}
        s["npc;drop=45261"] = {"[Twilight Shadow Knight]", "暮光堡垒"}
        s["npc;drop=39801"] = {"[Earth Warden]", "起源大厅"}
        s["npc;drop=37217"] = {"[Precious]", "冰冠堡垒"}
        s["npc;drop=50061"] = {"[Xariona]", "深岩之洲"}
        s["npc;drop=50060"] = {"[Terborus]", "深岩之洲"}
        s["npc;drop=50063"] = {"[Akma'hat] <[Dirge of the Eternal Sands]>", "奥丹姆"}
        s["spell;created=73503"] = {"源质莫比斯之戒", "CRAFTING"}
        s["npc;drop=39732"] = {"[Setesh] <[Construct of Destruction]>", "起源大厅"}
        s["npc;sold=44246"] = {"[Magatha Silverton] <[Justice Quartermaster]>", "暴风城"}
        s["npc;drop=46964"] = {"[Lord Godfrey]", "影牙城堡"}
        s["npc;drop=49045"] = {"[Augh]", "托维尔失落之城"}
        s["npc;drop=44566"] = {"[Ozumat] <[Fiend of the Dark Below]>", "潮汐王座"}
        s["npc;sold=49387"] = {"[Grot Deathblow] <[Dragonmaw Clan Quartermaster]>", "暮光高地"}
        s["spell;created=73506"] = {"源质守护者", "CRAFTING"}
        s["npc;sold=45408"] = {"[D'lom the Collector] <[Therazane Quartermaster]>", "深岩之洲"}
        s["npc;drop=42333"] = {"[High Priestess Azil]", "巨石之核"}
        s["spell;created=73641"] = {"雕像 - 土灵守护者", "CRAFTING"}
        s["npc;drop=40484"] = {"[Erudax] <[The Duke of Below]>", "格瑞姆巴托"}
        s["spell;created=94732"] = {"锻铸源质碎灵锤", "CRAFTING"}
        s["npc;drop=43214"] = {"[Slabhide]", "巨石之核"}
        s["spell;created=76445"] = {"源质毁灭胸铠", "CRAFTING"}
        s["spell;created=76446"] = {"源质苦痛腰铠", "CRAFTING"}
        s["npc;drop=49813"] = {"[Evolved Drakonaar]", "暮光堡垒"}
        s["npc;drop=40788"] = {"[Mindbender Ghur'sha]", "潮汐王座"}
        s["npc;drop=47296"] = {"[Helix Gearbreaker]", "死亡矿井"}
        s["npc;drop=49541"] = {"[Vanessa VanCleef]", "死亡矿井"}
        s["npc;drop=47162"] = {"[Glubtok] <[The Foreman]>", "死亡矿井"}
        s["npc;drop=40765"] = {"[Commander Ulthok] <[The Festering Prince]>", "潮汐王座"}
        s["npc;drop=39698"] = {"[Karsh Steelbender] <[Twilight Armorer]>", "黑石岩窟"}
        s["npc;drop=50056"] = {"[Garr]", "海加尔山"}
        s["npc;drop=40177"] = {"[Forgemaster Throngus]", "格瑞姆巴托"}
        s["npc;drop=39731"] = {"[Ammunae] <[Construct of Life]>", "起源大厅"}
        s["npc;drop=3887"] = {"席瓦莱恩男爵", "影牙城堡"}
        s["npc;drop=39679"] = {"[Corla, Herald of Twilight]", "黑石岩窟"}
        s["npc;drop=39587"] = {"[Isiset] <[Construct of Magic]>", "起源大厅"}
        s["npc;drop=47739"] = {"['Captain' Cookie] <[Defias Kingpin?]>", "死亡矿井"}
        s["npc;drop=43612"] = {"[High Prophet Barim]", "托维尔失落之城"}
        s["npc;drop=45993"] = {"[Theralion]", "暮光堡垒"}
        s["quest;reward=27664"] = {"[Darkmoon Volcanic Deck]", "艾尔文森林"}
        s["npc;drop=42180"] = {"[Toxitron]", "黑翼血环"}
        s["spell;created=81722"] = {"敏捷生物光学远望镜", "CRAFTING"}
        s["npc;drop=23863"] = {"达卡拉 <战无不胜>", "祖阿曼"}
        s["npc;drop=23578"] = {"加亚莱 <龙鹰的化身>", "祖阿曼"}
        s["spell;created=78461"] = {"邪语腰带", "CRAFTING"}
        s["npc;drop=42767"] = {"[Ivoroc]", "黑翼血环"}
        s["npc;drop=52151"] = {"[Bloodlord Mandokir]", "祖尔格拉布"}
        s["npc;sold=50324"] = {"[Provisioner Arok] <[Earthen Ring Quartermaster]>", "烁光海床"}
        s["npc;drop=43438"] = {"[Corborus]", "巨石之核"}
        s["npc;drop=50009"] = {"[Mobus] <[The Crushing Tide]>", "无底海渊"}
        s["npc;sold=46594"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
        s["npc;drop=52148"] = {"[Jin'do the Godbreaker]", "祖尔格拉布"}
        s["spell;created=86653"] = {"嵌银之叶", "CRAFTING"}
        s["npc;drop=23577"] = {"哈尔拉兹 <山猫的化身>", "祖阿曼"}
        s["object;contained=186648"] = {"[Hazlek's Trunk]", "祖阿曼"}
        s["spell;created=78488"] = {"杀手胸铠", "CRAFTING"}
        s["npc;drop=24239"] = {"妖术领主玛拉卡斯", "祖阿曼"}
        s["npc;drop=46963"] = {"[Lord Walden]", "影牙城堡"}
        s["npc;drop=39425"] = {"[Temple Guardian Anhuur]", "起源大厅"}
        s["npc;drop=23586"] = {"阿曼尼斥候", "祖阿曼"}
        s["npc;drop=43875"] = {"[Asaad] <[Caliph of Zephyrs]>", "旋云之巅"}
        s["object;contained=186667"] = {"[Norkani's Package]", "祖阿曼"}
        s["npc;drop=39700"] = {"[Beauty]", "黑石岩窟"}
        s["npc;drop=52258"] = {"[Gri'lek]", "祖尔格拉布"}
        s["npc;drop=46962"] = {"[Baron Ashbury]", "影牙城堡"}
        s["spell;created=73521"] = {"黄铜源质勋章", "CRAFTING"}
        s["npc;drop=39428"] = {"[Earthrager Ptah]", "起源大厅"}
        s["spell;created=73498"] = {"利刃指环", "CRAFTING"}
        s["npc;drop=44819"] = {"[Siamat] <[Lord of the South Wind]>", "托维尔失落之城"}
        s["spell;created=76451"] = {"源质战斧", "CRAFTING"}
        s["npc;drop=4278"] = {"指挥官斯普林瓦尔", "影牙城堡"}
        s["spell;created=81724"] = {"迷彩生物光学远望镜", "CRAFTING"}
        s["npc;drop=42803"] = {"[Drakeadon Mongrel]", "黑翼血环"}
        s["npc;drop=43125"] = {"[Spirit of Moltenfist]", "黑翼血环"}
        s["spell;created=78487"] = {"自然愤怒胸甲", "CRAFTING"}
        s["spell;created=78460"] = {"闪电皮带", "CRAFTING"}
        s["quest;reward=27666"] = {"[Darkmoon Tsunami Deck]", "艾尔文森林"}
        s["spell;created=96254"] = {"活力炼金石", "CRAFTING"}
        s["npc;drop=43122"] = {"[Spirit of Corehammer]", "黑翼血环"}
        s["spell;created=86652"] = {"纹饰徽记", "CRAFTING"}
        s["npc;drop=43873"] = {"[Altairus]", "旋云之巅"}
        s["npc;drop=40586"] = {"[Lady Naz'jar]", "潮汐王座"}
        s["npc;drop=40319"] = {"[Drahga Shadowburner] <[Twilight's Hammer Courier]>", "格瑞姆巴托"}
        s["npc;drop=39625"] = {"[General Umbriss] <[Servant of Deathwing]>", "格瑞姆巴托"}
        s["npc;drop=50057"] = {"[Blazewing]", "海加尔山"}
        s["npc;drop=50086"] = {"[Tarvus the Vile]", "暮光高地"}
        s["spell;created=73505"] = {"覆亡之眼", "CRAFTING"}
        s["spell;created=73502"] = {"激战元素指环", "CRAFTING"}
        s["quest;reward=28267"] = {"[Firing Squad]", "奥丹姆"}
        s["npc;drop=43778"] = {"[Foe Reaper 5000]", "死亡矿井"}
        s["spell;created=76450"] = {"源质之锤", "CRAFTING"}
        s["npc;drop=39665"] = {"[Rom'ogg Bonecrusher]", "黑石岩窟"}
        s["npc;drop=43878"] = {"[Grand Vizier Ertan]", "旋云之巅"}
        s["spell;created=86642"] = {"神圣书典", "CRAFTING"}
        s["spell;created=81716"] = {"致命生物光学远望镜", "CRAFTING"}
        s["spell;created=78435"] = {"锐壳胸甲", "CRAFTING"}
        s["quest;reward=28854"] = {"[Closing a Dark Chapter]", "格瑞姆巴托"}
        s["spell;created=78463"] = {"束蛇链甲腰带", "CRAFTING"}
        s["spell;created=73520"] = {"源质毁灭者指环", "CRAFTING"}
        s["quest;reward=27665"] = {"[Darkmoon Hurricane Deck]", "艾尔文森林"}
        s["npc;drop=47626"] = {"[Admiral Ripsnarl]", "死亡矿井"}
        s["spell;created=84432"] = {"反冲器5000型", "CRAFTING"}
        s["spell;created=84431"] = {"超强懦夫粉碎弓", "CRAFTING"}
        s["npc;sold=46595"] = {"[Blood Guard Zar'shi] <[Honor Quartermaster]>", "奥格瑞玛"}
        s["spell;created=78490"] = {"屠龙者胸甲", "CRAFTING"}
        s["npc;drop=42800"] = {"[Golem Sentry]", "黑翼血环"}
        s["spell;created=81725"] = {"轻便生物光学远望镜", "CRAFTING"}
        s["spell;created=75299"] = {"无梦束带", "CRAFTING"}
        s["npc;drop=39415"] = {"[Ascended Flameseeker]", "格瑞姆巴托"}
        s["npc;drop=52269"] = {"[Renataki]", "祖尔格拉布"}
        s["npc;drop=50089"] = {"[Julak-Doom] <[The Eye of Zor]>", "暮光高地"}
        s["spell;created=75300"] = {"噩梦扭转束裤", "CRAFTING"}
        s["spell;created=76449"] = {"源质法术之刃", "CRAFTING"}
        s["spell;created=86641"] = {"地下城探索指南", "CRAFTING"}
        s["quest;reward=28753"] = {"[Doing it the Hard Way]", "起源大厅"}
        s["spell;created=81715"] = {"特制生物光学远望镜", "CRAFTING"}
        s["spell;created=76447"] = {"光之源质胸铠", "CRAFTING"}
        s["spell;created=76448"] = {"光之源质腰铠", "CRAFTING"}
        s["spell;created=76455"] = {"源质风暴盾牌", "CRAFTING"}
        s["npc;drop=50050"] = {"索克沙拉克", "无底海渊"}
        s["spell;created=76454"] = {"源质地卫之盾", "CRAFTING"}
        s["npc;drop=52053"] = {"[Zanzil]", "祖尔格拉布"}
        s["npc;drop=23576"] = {"纳洛拉克 <野熊的化身>", "祖阿曼"}
        s["npc;drop=42802"] = {"[Drakonid Slayer]", "黑翼血环"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "奥格瑞玛"}
        s["spell;created=98921"] = {"惩戒者指环", "CRAFTING"}
        s["spell;created=73639"] = {"雕像 - 野猪之王", "CRAFTING"}
        s["spell;created=96252"] = {"烈性炼金石", "CRAFTING"}
        s["npc;drop=46083"] = {"[Drakeadon Mongrel]", "黑翼血环"}
        s["spell;created=75298"] = {"深渊腰带", "CRAFTING"}
        s["spell;created=75301"] = {"升腾之焰束裤", "CRAFTING"}
        s["npc;drop=48450"] = {"[Sunwing Squawker]", "死亡矿井"}
        s["npc;drop=47120"] = {"阿尔加洛斯", "巴拉丁监狱"}
        s["spell;created=75266"] = {"愈心兜帽", "CRAFTING"}
        s["quest;reward=28783"] = {"[The Source of Their Power]", "托维尔失落之城"}
        s["spell;created=75260"] = {"愈心衬肩", "CRAFTING"}
        s["npc;drop=52345"] = {"[Pride of Bethekk]", "祖尔格拉布"}
        s["quest;reward=27788"] = {"[Skullcrusher the Mountain]", "暮光高地"}
        s["spell;created=75267"] = {"愈心长袍", "CRAFTING"}
        s["spell;created=75259"] = {"愈心裹腕", "CRAFTING"}
        s["npc;drop=24138"] = {"被驯服的阿曼尼鳄鱼", "祖阿曼"}
        s["spell;created=75262"] = {"愈心护手", "CRAFTING"}
        s["spell;created=75258"] = {"愈心束带", "CRAFTING"}
        s["npc;drop=23574"] = {"埃基尔松 <雄鹰的化身>", "祖阿曼"}
        s["npc;drop=40167"] = {"[Twilight Beguiler] <[The Twilight's Hammer]>", "格瑞姆巴托"}
        s["spell;created=75263"] = {"愈心长裤", "CRAFTING"}
        s["spell;created=75261"] = {"愈心之靴", "CRAFTING"}
        s["npc;drop=42764"] = {"[Pyrecraw]", "黑翼血环"}
        s["spell;created=73643"] = {"雕像 - 梦枭", "CRAFTING"}
        s["quest;reward=28170"] = {"[Night Terrors]", "暮光高地"}
        s["quest;reward=27868"] = {"[The Crucible of Carnage: The Twilight Terror!]", "暮光高地"}
        s["quest;reward=28595"] = {"[Krazz Works!]", "暮光高地"}
        s["spell;created=73642"] = {"雕像 - 宝石毒蛇", "CRAFTING"}
        s["npc;drop=43614"] = {"[Lockmaw]", "托维尔失落之城"}
        s["npc;drop=39803"] = {"[Air Warden]", "起源大厅"}
        s["spell;created=96253"] = {"活泼炼金石", "CRAFTING"}
        s["spell;created=76453"] = {"源质战匕", "CRAFTING"}
        s["spell;created=73640"] = {"雕像 - 恶魔豹", "CRAFTING"}
        s["quest;reward=11196"] = {"[Warlord of the Amani]", "祖阿曼"}
        s["npc;drop=42362"] = {"[Drakonid Drudge]", "黑翼血环"}
        s["spell;created=94718"] = {"源质割肠刀", "CRAFTING"}
        s["npc;drop=52271"] = {"[Hazza'rah]", "祖尔格拉布"}
        s["spell;created=81720"] = {"充能生物光学远望镜", "CRAFTING"}
        s["spell;created=78489"] = {"暮光之鳞胸甲", "CRAFTING"}
        s["spell;created=78462"] = {"风暴皮革束带", "CRAFTING"}
        s["npc;drop=45687"] = {"[Twilight-Shifter] <[The Twilight's Hammer]>", "暮光堡垒"}
        s["quest;reward=28853"] = {"杀死信使", "格瑞姆巴托"}
        s["npc;drop=39440"] = {"[Venomous Skitterer]", "起源大厅"}
        s["npc;drop=47720"] = {"[Camel]", "托维尔失落之城"}
        s["npc;drop=42789"] = {"[Stonecore Magmalord]", "巨石之核"}
        s["quest;reward=27659"] = {"[Portal Overload]", "暮光高地"}
        s["quest;reward=27748"] = {"[Fortune and Glory]", "奥丹姆"}
        s["npc;drop=45007"] = {"[Enslaved Bandit]", "托维尔失落之城"}
        s["quest;reward=26876"] = {"[The World Pillar Fragment]", "深岩之洲"}
        s["npc;drop=39855"] = {"[Azureborne Seer] <[Servant of Deathwing]>", "格瑞姆巴托"}
        s["spell;created=75257"] = {"逝亡之丝长袍", "CRAFTING"}
        s["quest;reward=26830"] = {"[Traitor's Bait]", "奥格瑞玛"}
        s["quest;reward=27106"] = {"[A Villain Unmasked]", "暴风城"}
        s["quest;reward=28133"] = {"[Fury Unbound]", "暮光高地"}
        s["quest;reward=28282"] = {"[Narkrall, The Drake-Tamer]", "暮光高地"}
        s["quest;reward=27745"] = {"[A Fiery Reunion]", "暮光高地"}
        s["quest;reward=28758"] = {"[Battle of Life and Death]", "暮光高地"}
        s["quest;reward=26971"] = {"[The Binding]", "深岩之洲"}
        s["quest;reward=27651"] = {"[Doing It Like a Dunwald]", "暮光高地"}
        s["npc;drop=52418"] = {"[Lost Offspring of Gahz'ranka]", "祖尔格拉布"}
        s["quest;reward=29186"] = {"[The Hex Lord's Fetish]", "祖阿曼"}
        s["quest;reward=28480"] = {"[Lieutenants of Darkness]", "奥丹姆"}
        s["spell;created=99439"] = {"怒拳手甲", "CRAFTING"}
        s["object;contained=188192"] = {"[Ice Chest]", "奴隶围栏"}
        s["spell;created=78476"] = {"暮光龙鳞斗篷", "CRAFTING"}
        s["quest;reward=28612"] = {"[Harrison Jones and the Temple of Uldum]", "奥丹姆"}
        s["npc;drop=52322"] = {"[Witch Doctor Qu'in] <[Medicine Woman]>", "祖尔格拉布"}
        s["npc;drop=23584"] = {"阿曼尼野熊", "祖阿曼"}
        s["quest;reward=27667"] = {"[Darkmoon Earthquake Deck]", "艾尔文森林"}
        s["quest;reward=27652"] = {"[Dark Assassins]", "暮光高地"}
        s["quest;reward=27653"] = {"[Dark Assassins]", "暮光高地"}
        s["npc;drop=52363"] = {"[Occu'thar]", "巴拉丁监狱"}
        s["spell;created=99452"] = {"无畏领主的战靴", "CRAFTING"}
        s["npc;sold=54401"] = {"[Naresir Stormfury] <[Avengers of Hyjal Quartermaster]>", "海加尔山"}
        s["npc;sold=53882"] = {"[Varlan Highbough] <[Provisions of the Grove]>", "熔火前线"}
        s["spell;created=99654"] = {"光铸源质锤", "CRAFTING"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "熔火前线"}
        s["spell;created=99457"] = {"精制的皮靴", "CRAFTING"}
        s["spell;created=99446"] = {"恶魔手甲", "CRAFTING"}
        s["spell;created=99660"] = {"猎巫收割者", "CRAFTING"}
        s["spell;created=99458"] = {"虚灵之靴", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "熔火前线"}
        s["spell;created=100687"] = {"强力打孔机", "CRAFTING"}
        s["spell;created=99460"] = {"黑焰长靴", "CRAFTING"}
        s["spell;created=99653"] = {"精工源质法刃", "CRAFTING"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "熔火前线"}
        s["spell;created=99459"] = {"无尽梦行之靴", "CRAFTING"}
        s["spell;created=99455"] = {"土灵鳞甲马靴", "CRAFTING"}
        s["spell;created=99449"] = {"唐塔约的地狱火手套", "CRAFTING"}
        s["spell;created=99657"] = {"铁卫", "CRAFTING"}
        s["npc;sold=54402"] = {"[Lurah Wrathvine] <[Crystallized Firestone Collector]>", "海加尔山"}
        s["npc;drop=52409"] = {"[Ragnaros]", "火焰之地"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "火焰之地"}
        s["npc;drop=53691"] = {"[Shannox]", "火焰之地"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "火焰之地"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "火焰之地"}
        s["npc;drop=52530"] = {"[Alysrazor]", "火焰之地"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "火焰之地"}
        s["quest;reward=29331"] = {"[Elemental Bonds: The Vow]", "海加尔山"}
        s["npc;drop=53616"] = {"[Kar the Everburning] <[Firelord]>", "火焰之地"}
        s["npc;drop=54161"] = {"[Flame Archon]", "火焰之地"}
        s["npc;sold=52549"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "暴风城"}
        s["npc;drop=55689"] = {"[Hagara the Stormbinder]", "巨龙之魂"}
        s["npc;drop=55308"] = {"[Warlord Zon'ozz]", "巨龙之魂"}
        s["npc;drop=55265"] = {"[Morchok]", "巨龙之魂"}
        s["npc;drop=55294"] = {"[Ultraxion]", "巨龙之魂"}
        s["npc;drop=55312"] = {"[Yor'sahj the Unsleeping]", "巨龙之魂"}
        s["npc;drop=56173"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["npc;drop=57821"] = {"[Lieutenant Shara] <[The Twilight's Hammer]>", "巨龙之魂"}
        s["spell;created=101932"] = {"守护泰坦腕甲", "CRAFTING"}
        s["npc;sold=241467"] = {"[Sylstrasza] <[Obsidian Fragment Exchange]>", "奥格瑞玛"}
        s["npc;drop=54938"] = {"[Archbishop Benedictus]", "暮光审判"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["spell;created=101925"] = {"无敌毁灭者腿铠", "CRAFTING"}
        s["spell;created=101931"] = {"毁灭之力护腕", "CRAFTING"}
        s["spell;created=101933"] = {"自然勇士护腿", "CRAFTING"}
        s["spell;created=101937"] = {"流静束腕", "CRAFTING"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "巨龙之魂"}
        s["spell;created=101940"] = {"刃影护腕", "CRAFTING"}
        s["spell;created=101941"] = {"猎人杀手束腕", "CRAFTING"}
        s["spell;created=101921"] = {"熔岩地震护腿", "CRAFTING"}
        s["spell;created=101923"] = {"不羁之力束腕", "CRAFTING"}
        s["spell;created=101929"] = {"灵魂救赎腕甲", "CRAFTING"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "巴拉丁监狱"}
        s["spell;created=101922"] = {"光芒梦境之束", "CRAFTING"}
        s["spell;created=101934"] = {"死鳞腿铠", "CRAFTING"}
        s["spell;created=101939"] = {"雷霆死鳞护腕", "CRAFTING"}
        s["npc;drop=55085"] = {"[Peroth'arn]", "永恒之井"}
        s["quest;reward=30118"] = {"[Patricide]", "巨龙之魂"}
        s["spell;created=101935"] = {"刃影护腿", "CRAFTING"}
        s["npc;sold=54658"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
    end

    function SpecBisTooltip:TranslationzhTW()
        s["npc;sold=44245"] = {"[Faldren Tillsdale] <[Valor Quartermaster]>", "暴风城"}
        s["npc;drop=41376"] = {"[Nefarian]", "黑翼血环"}
        s["npc;drop=9056"] = {"弗诺斯·达克维尔 <首席建筑师>", "黑石深渊"}
        s["npc;drop=42178"] = {"[Magmatron]", "黑翼血环"}
        s["npc;drop=43296"] = {"[Chimaeron]", "黑翼血环"}
        s["npc;drop=44600"] = {"[Halfus Wyrmbreaker]", "暮光堡垒"}
        s["npc;drop=45992"] = {"[Valiona]", "暮光堡垒"}
        s["npc;sold=47328"] = {"[Quartermaster Brazie] <[Baradin's Wardens Quartermaster]>", "托尔巴拉德半岛"}
        s["npc;drop=41570"] = {"[Magmaw]", "黑翼血环"}
        s["npc;drop=43735"] = {"[Elementium Monstrosity]", "暮光堡垒"}
        s["quest;reward=24919"] = {"光明使者的救赎", "冰冠堡垒"}
        s["npc;drop=45213"] = {"[Sinestra] <[Consort of Deathwing]>", "暮光堡垒"}
        s["npc;drop=45871"] = {"[Nezir] <[Lord of the North Wind]>", "风神王座"}
        s["npc;drop=46753"] = {"[Al'Akir]", "风神王座"}
        s["npc;drop=41378"] = {"[Maloriak]", "黑翼血环"}
        s["npc;drop=43324"] = {"[Cho'gall]", "暮光堡垒"}
        s["npc;drop=41442"] = {"[Atramedes]", "黑翼血环"}
        s["npc;sold=48531"] = {"[Pogg] <[Hellscream's Reach Quartermaster]>", "托尔巴拉德半岛"}
        s["npc;drop=36853"] = {"[Sindragosa] <[Queen of the Frostbrood]>", "冰冠堡垒"}
        s["spell;created=80508"] = {"生命炼金石", "CRAFTING"}
        s["npc;drop=44577"] = {"[General Husam]", "托维尔失落之城"}
        s["spell;created=81714"] = {"强化生物光学远望镜", "CRAFTING"}
        s["npc;drop=39705"] = {"[Ascendant Lord Obsidius]", "黑石岩窟"}
        s["spell;created=76443"] = {"硬化源质胸铠", "CRAFTING"}
        s["spell;created=76444"] = {"硬化源质束带", "CRAFTING"}
        s["npc;sold=49386"] = {"[Craw MacGraw] <[Wildhammer Clan Quartermaster]>", "暮光高地"}
        s["npc;drop=39788"] = {"[Anraphet]", "起源大厅"}
        s["npc;drop=39378"] = {"[Rajh] <[Construct of the Sun]>", "起源大厅"}
        s["npc;sold=48617"] = {"[Blacksmith Abasi] <[Ramkahen Quartermaster]>", "奥丹姆"}
        s["npc;sold=50314"] = {"[Provisioner Whitecloud] <[Guardians of Hyjal Quartermaster]>", "海加尔山"}
        s["npc;drop=42188"] = {"[Ozruk]", "巨石之核"}
        s["spell;created=86650"] = {"锯齿颌骨", "CRAFTING"}
        s["npc;drop=45261"] = {"[Twilight Shadow Knight]", "暮光堡垒"}
        s["npc;drop=39801"] = {"[Earth Warden]", "起源大厅"}
        s["npc;drop=37217"] = {"[Precious]", "冰冠堡垒"}
        s["npc;drop=50061"] = {"[Xariona]", "深岩之洲"}
        s["npc;drop=50060"] = {"[Terborus]", "深岩之洲"}
        s["npc;drop=50063"] = {"[Akma'hat] <[Dirge of the Eternal Sands]>", "奥丹姆"}
        s["spell;created=73503"] = {"源质莫比斯之戒", "CRAFTING"}
        s["npc;drop=39732"] = {"[Setesh] <[Construct of Destruction]>", "起源大厅"}
        s["npc;sold=44246"] = {"[Magatha Silverton] <[Justice Quartermaster]>", "暴风城"}
        s["npc;drop=46964"] = {"[Lord Godfrey]", "影牙城堡"}
        s["npc;drop=49045"] = {"[Augh]", "托维尔失落之城"}
        s["npc;drop=44566"] = {"[Ozumat] <[Fiend of the Dark Below]>", "潮汐王座"}
        s["npc;sold=49387"] = {"[Grot Deathblow] <[Dragonmaw Clan Quartermaster]>", "暮光高地"}
        s["spell;created=73506"] = {"源质守护者", "CRAFTING"}
        s["npc;sold=45408"] = {"[D'lom the Collector] <[Therazane Quartermaster]>", "深岩之洲"}
        s["npc;drop=42333"] = {"[High Priestess Azil]", "巨石之核"}
        s["spell;created=73641"] = {"雕像 - 土灵守护者", "CRAFTING"}
        s["npc;drop=40484"] = {"[Erudax] <[The Duke of Below]>", "格瑞姆巴托"}
        s["spell;created=94732"] = {"锻铸源质碎灵锤", "CRAFTING"}
        s["npc;drop=43214"] = {"[Slabhide]", "巨石之核"}
        s["spell;created=76445"] = {"源质毁灭胸铠", "CRAFTING"}
        s["spell;created=76446"] = {"源质苦痛腰铠", "CRAFTING"}
        s["npc;drop=49813"] = {"[Evolved Drakonaar]", "暮光堡垒"}
        s["npc;drop=40788"] = {"[Mindbender Ghur'sha]", "潮汐王座"}
        s["npc;drop=47296"] = {"[Helix Gearbreaker]", "死亡矿井"}
        s["npc;drop=49541"] = {"[Vanessa VanCleef]", "死亡矿井"}
        s["npc;drop=47162"] = {"[Glubtok] <[The Foreman]>", "死亡矿井"}
        s["npc;drop=40765"] = {"[Commander Ulthok] <[The Festering Prince]>", "潮汐王座"}
        s["npc;drop=39698"] = {"[Karsh Steelbender] <[Twilight Armorer]>", "黑石岩窟"}
        s["npc;drop=50056"] = {"[Garr]", "海加尔山"}
        s["npc;drop=40177"] = {"[Forgemaster Throngus]", "格瑞姆巴托"}
        s["npc;drop=39731"] = {"[Ammunae] <[Construct of Life]>", "起源大厅"}
        s["npc;drop=3887"] = {"席瓦莱恩男爵", "影牙城堡"}
        s["npc;drop=39679"] = {"[Corla, Herald of Twilight]", "黑石岩窟"}
        s["npc;drop=39587"] = {"[Isiset] <[Construct of Magic]>", "起源大厅"}
        s["npc;drop=47739"] = {"['Captain' Cookie] <[Defias Kingpin?]>", "死亡矿井"}
        s["npc;drop=43612"] = {"[High Prophet Barim]", "托维尔失落之城"}
        s["npc;drop=45993"] = {"[Theralion]", "暮光堡垒"}
        s["quest;reward=27664"] = {"[Darkmoon Volcanic Deck]", "艾尔文森林"}
        s["npc;drop=42180"] = {"[Toxitron]", "黑翼血环"}
        s["spell;created=81722"] = {"敏捷生物光学远望镜", "CRAFTING"}
        s["npc;drop=23863"] = {"达卡拉 <战无不胜>", "祖阿曼"}
        s["npc;drop=23578"] = {"加亚莱 <龙鹰的化身>", "祖阿曼"}
        s["spell;created=78461"] = {"邪语腰带", "CRAFTING"}
        s["npc;drop=42767"] = {"[Ivoroc]", "黑翼血环"}
        s["npc;drop=52151"] = {"[Bloodlord Mandokir]", "祖尔格拉布"}
        s["npc;sold=50324"] = {"[Provisioner Arok] <[Earthen Ring Quartermaster]>", "烁光海床"}
        s["npc;drop=43438"] = {"[Corborus]", "巨石之核"}
        s["npc;drop=50009"] = {"[Mobus] <[The Crushing Tide]>", "无底海渊"}
        s["npc;sold=46594"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
        s["npc;drop=52148"] = {"[Jin'do the Godbreaker]", "祖尔格拉布"}
        s["spell;created=86653"] = {"嵌银之叶", "CRAFTING"}
        s["npc;drop=23577"] = {"哈尔拉兹 <山猫的化身>", "祖阿曼"}
        s["object;contained=186648"] = {"[Hazlek's Trunk]", "祖阿曼"}
        s["spell;created=78488"] = {"杀手胸铠", "CRAFTING"}
        s["npc;drop=24239"] = {"妖术领主玛拉卡斯", "祖阿曼"}
        s["npc;drop=46963"] = {"[Lord Walden]", "影牙城堡"}
        s["npc;drop=39425"] = {"[Temple Guardian Anhuur]", "起源大厅"}
        s["npc;drop=23586"] = {"阿曼尼斥候", "祖阿曼"}
        s["npc;drop=43875"] = {"[Asaad] <[Caliph of Zephyrs]>", "旋云之巅"}
        s["object;contained=186667"] = {"[Norkani's Package]", "祖阿曼"}
        s["npc;drop=39700"] = {"[Beauty]", "黑石岩窟"}
        s["npc;drop=52258"] = {"[Gri'lek]", "祖尔格拉布"}
        s["npc;drop=46962"] = {"[Baron Ashbury]", "影牙城堡"}
        s["spell;created=73521"] = {"黄铜源质勋章", "CRAFTING"}
        s["npc;drop=39428"] = {"[Earthrager Ptah]", "起源大厅"}
        s["spell;created=73498"] = {"利刃指环", "CRAFTING"}
        s["npc;drop=44819"] = {"[Siamat] <[Lord of the South Wind]>", "托维尔失落之城"}
        s["spell;created=76451"] = {"源质战斧", "CRAFTING"}
        s["npc;drop=4278"] = {"指挥官斯普林瓦尔", "影牙城堡"}
        s["spell;created=81724"] = {"迷彩生物光学远望镜", "CRAFTING"}
        s["npc;drop=42803"] = {"[Drakeadon Mongrel]", "黑翼血环"}
        s["npc;drop=43125"] = {"[Spirit of Moltenfist]", "黑翼血环"}
        s["spell;created=78487"] = {"自然愤怒胸甲", "CRAFTING"}
        s["spell;created=78460"] = {"闪电皮带", "CRAFTING"}
        s["quest;reward=27666"] = {"[Darkmoon Tsunami Deck]", "艾尔文森林"}
        s["spell;created=96254"] = {"活力炼金石", "CRAFTING"}
        s["npc;drop=43122"] = {"[Spirit of Corehammer]", "黑翼血环"}
        s["spell;created=86652"] = {"纹饰徽记", "CRAFTING"}
        s["npc;drop=43873"] = {"[Altairus]", "旋云之巅"}
        s["npc;drop=40586"] = {"[Lady Naz'jar]", "潮汐王座"}
        s["npc;drop=40319"] = {"[Drahga Shadowburner] <[Twilight's Hammer Courier]>", "格瑞姆巴托"}
        s["npc;drop=39625"] = {"[General Umbriss] <[Servant of Deathwing]>", "格瑞姆巴托"}
        s["npc;drop=50057"] = {"[Blazewing]", "海加尔山"}
        s["npc;drop=50086"] = {"[Tarvus the Vile]", "暮光高地"}
        s["spell;created=73505"] = {"覆亡之眼", "CRAFTING"}
        s["spell;created=73502"] = {"激战元素指环", "CRAFTING"}
        s["quest;reward=28267"] = {"[Firing Squad]", "奥丹姆"}
        s["npc;drop=43778"] = {"[Foe Reaper 5000]", "死亡矿井"}
        s["spell;created=76450"] = {"源质之锤", "CRAFTING"}
        s["npc;drop=39665"] = {"[Rom'ogg Bonecrusher]", "黑石岩窟"}
        s["npc;drop=43878"] = {"[Grand Vizier Ertan]", "旋云之巅"}
        s["spell;created=86642"] = {"神圣书典", "CRAFTING"}
        s["spell;created=81716"] = {"致命生物光学远望镜", "CRAFTING"}
        s["spell;created=78435"] = {"锐壳胸甲", "CRAFTING"}
        s["quest;reward=28854"] = {"[Closing a Dark Chapter]", "格瑞姆巴托"}
        s["spell;created=78463"] = {"束蛇链甲腰带", "CRAFTING"}
        s["spell;created=73520"] = {"源质毁灭者指环", "CRAFTING"}
        s["quest;reward=27665"] = {"[Darkmoon Hurricane Deck]", "艾尔文森林"}
        s["npc;drop=47626"] = {"[Admiral Ripsnarl]", "死亡矿井"}
        s["spell;created=84432"] = {"反冲器5000型", "CRAFTING"}
        s["spell;created=84431"] = {"超强懦夫粉碎弓", "CRAFTING"}
        s["npc;sold=46595"] = {"[Blood Guard Zar'shi] <[Honor Quartermaster]>", "奥格瑞玛"}
        s["spell;created=78490"] = {"屠龙者胸甲", "CRAFTING"}
        s["npc;drop=42800"] = {"[Golem Sentry]", "黑翼血环"}
        s["spell;created=81725"] = {"轻便生物光学远望镜", "CRAFTING"}
        s["spell;created=75299"] = {"无梦束带", "CRAFTING"}
        s["npc;drop=39415"] = {"[Ascended Flameseeker]", "格瑞姆巴托"}
        s["npc;drop=52269"] = {"[Renataki]", "祖尔格拉布"}
        s["npc;drop=50089"] = {"[Julak-Doom] <[The Eye of Zor]>", "暮光高地"}
        s["spell;created=75300"] = {"噩梦扭转束裤", "CRAFTING"}
        s["spell;created=76449"] = {"源质法术之刃", "CRAFTING"}
        s["spell;created=86641"] = {"地下城探索指南", "CRAFTING"}
        s["quest;reward=28753"] = {"[Doing it the Hard Way]", "起源大厅"}
        s["spell;created=81715"] = {"特制生物光学远望镜", "CRAFTING"}
        s["spell;created=76447"] = {"光之源质胸铠", "CRAFTING"}
        s["spell;created=76448"] = {"光之源质腰铠", "CRAFTING"}
        s["spell;created=76455"] = {"源质风暴盾牌", "CRAFTING"}
        s["npc;drop=50050"] = {"索克沙拉克", "无底海渊"}
        s["spell;created=76454"] = {"源质地卫之盾", "CRAFTING"}
        s["npc;drop=52053"] = {"[Zanzil]", "祖尔格拉布"}
        s["npc;drop=23576"] = {"纳洛拉克 <野熊的化身>", "祖阿曼"}
        s["npc;drop=42802"] = {"[Drakonid Slayer]", "黑翼血环"}
        s["npc;sold=228668"] = {"[Glorious Conquest Vendor]", "奥格瑞玛"}
        s["spell;created=98921"] = {"惩戒者指环", "CRAFTING"}
        s["spell;created=73639"] = {"雕像 - 野猪之王", "CRAFTING"}
        s["spell;created=96252"] = {"烈性炼金石", "CRAFTING"}
        s["npc;drop=46083"] = {"[Drakeadon Mongrel]", "黑翼血环"}
        s["spell;created=75298"] = {"深渊腰带", "CRAFTING"}
        s["spell;created=75301"] = {"升腾之焰束裤", "CRAFTING"}
        s["npc;drop=48450"] = {"[Sunwing Squawker]", "死亡矿井"}
        s["npc;drop=47120"] = {"阿尔加洛斯", "巴拉丁监狱"}
        s["spell;created=75266"] = {"愈心兜帽", "CRAFTING"}
        s["quest;reward=28783"] = {"[The Source of Their Power]", "托维尔失落之城"}
        s["spell;created=75260"] = {"愈心衬肩", "CRAFTING"}
        s["npc;drop=52345"] = {"[Pride of Bethekk]", "祖尔格拉布"}
        s["quest;reward=27788"] = {"[Skullcrusher the Mountain]", "暮光高地"}
        s["spell;created=75267"] = {"愈心长袍", "CRAFTING"}
        s["spell;created=75259"] = {"愈心裹腕", "CRAFTING"}
        s["npc;drop=24138"] = {"被驯服的阿曼尼鳄鱼", "祖阿曼"}
        s["spell;created=75262"] = {"愈心护手", "CRAFTING"}
        s["spell;created=75258"] = {"愈心束带", "CRAFTING"}
        s["npc;drop=23574"] = {"埃基尔松 <雄鹰的化身>", "祖阿曼"}
        s["npc;drop=40167"] = {"[Twilight Beguiler] <[The Twilight's Hammer]>", "格瑞姆巴托"}
        s["spell;created=75263"] = {"愈心长裤", "CRAFTING"}
        s["spell;created=75261"] = {"愈心之靴", "CRAFTING"}
        s["npc;drop=42764"] = {"[Pyrecraw]", "黑翼血环"}
        s["spell;created=73643"] = {"雕像 - 梦枭", "CRAFTING"}
        s["quest;reward=28170"] = {"[Night Terrors]", "暮光高地"}
        s["quest;reward=27868"] = {"[The Crucible of Carnage: The Twilight Terror!]", "暮光高地"}
        s["quest;reward=28595"] = {"[Krazz Works!]", "暮光高地"}
        s["spell;created=73642"] = {"雕像 - 宝石毒蛇", "CRAFTING"}
        s["npc;drop=43614"] = {"[Lockmaw]", "托维尔失落之城"}
        s["npc;drop=39803"] = {"[Air Warden]", "起源大厅"}
        s["spell;created=96253"] = {"活泼炼金石", "CRAFTING"}
        s["spell;created=76453"] = {"源质战匕", "CRAFTING"}
        s["spell;created=73640"] = {"雕像 - 恶魔豹", "CRAFTING"}
        s["quest;reward=11196"] = {"[Warlord of the Amani]", "祖阿曼"}
        s["npc;drop=42362"] = {"[Drakonid Drudge]", "黑翼血环"}
        s["spell;created=94718"] = {"源质割肠刀", "CRAFTING"}
        s["npc;drop=52271"] = {"[Hazza'rah]", "祖尔格拉布"}
        s["spell;created=81720"] = {"充能生物光学远望镜", "CRAFTING"}
        s["spell;created=78489"] = {"暮光之鳞胸甲", "CRAFTING"}
        s["spell;created=78462"] = {"风暴皮革束带", "CRAFTING"}
        s["npc;drop=45687"] = {"[Twilight-Shifter] <[The Twilight's Hammer]>", "暮光堡垒"}
        s["quest;reward=28853"] = {"杀死信使", "格瑞姆巴托"}
        s["npc;drop=39440"] = {"[Venomous Skitterer]", "起源大厅"}
        s["npc;drop=47720"] = {"[Camel]", "托维尔失落之城"}
        s["npc;drop=42789"] = {"[Stonecore Magmalord]", "巨石之核"}
        s["quest;reward=27659"] = {"[Portal Overload]", "暮光高地"}
        s["quest;reward=27748"] = {"[Fortune and Glory]", "奥丹姆"}
        s["npc;drop=45007"] = {"[Enslaved Bandit]", "托维尔失落之城"}
        s["quest;reward=26876"] = {"[The World Pillar Fragment]", "深岩之洲"}
        s["npc;drop=39855"] = {"[Azureborne Seer] <[Servant of Deathwing]>", "格瑞姆巴托"}
        s["spell;created=75257"] = {"逝亡之丝长袍", "CRAFTING"}
        s["quest;reward=26830"] = {"[Traitor's Bait]", "奥格瑞玛"}
        s["quest;reward=27106"] = {"[A Villain Unmasked]", "暴风城"}
        s["quest;reward=28133"] = {"[Fury Unbound]", "暮光高地"}
        s["quest;reward=28282"] = {"[Narkrall, The Drake-Tamer]", "暮光高地"}
        s["quest;reward=27745"] = {"[A Fiery Reunion]", "暮光高地"}
        s["quest;reward=28758"] = {"[Battle of Life and Death]", "暮光高地"}
        s["quest;reward=26971"] = {"[The Binding]", "深岩之洲"}
        s["quest;reward=27651"] = {"[Doing It Like a Dunwald]", "暮光高地"}
        s["npc;drop=52418"] = {"[Lost Offspring of Gahz'ranka]", "祖尔格拉布"}
        s["quest;reward=29186"] = {"[The Hex Lord's Fetish]", "祖阿曼"}
        s["quest;reward=28480"] = {"[Lieutenants of Darkness]", "奥丹姆"}
        s["spell;created=99439"] = {"怒拳手甲", "CRAFTING"}
        s["object;contained=188192"] = {"[Ice Chest]", "奴隶围栏"}
        s["spell;created=78476"] = {"暮光龙鳞斗篷", "CRAFTING"}
        s["quest;reward=28612"] = {"[Harrison Jones and the Temple of Uldum]", "奥丹姆"}
        s["npc;drop=52322"] = {"[Witch Doctor Qu'in] <[Medicine Woman]>", "祖尔格拉布"}
        s["npc;drop=23584"] = {"阿曼尼野熊", "祖阿曼"}
        s["quest;reward=27667"] = {"[Darkmoon Earthquake Deck]", "艾尔文森林"}
        s["quest;reward=27652"] = {"[Dark Assassins]", "暮光高地"}
        s["quest;reward=27653"] = {"[Dark Assassins]", "暮光高地"}
        s["npc;drop=52363"] = {"[Occu'thar]", "巴拉丁监狱"}
        s["spell;created=99452"] = {"无畏领主的战靴", "CRAFTING"}
        s["npc;sold=54401"] = {"[Naresir Stormfury] <[Avengers of Hyjal Quartermaster]>", "海加尔山"}
        s["npc;sold=53882"] = {"[Varlan Highbough] <[Provisions of the Grove]>", "熔火前线"}
        s["spell;created=99654"] = {"光铸源质锤", "CRAFTING"}
        s["npc;sold=53881"] = {"[Ayla Shadowstorm] <[Treasures of Elune]>", "熔火前线"}
        s["spell;created=99457"] = {"精制的皮靴", "CRAFTING"}
        s["spell;created=99446"] = {"恶魔手甲", "CRAFTING"}
        s["spell;created=99660"] = {"猎巫收割者", "CRAFTING"}
        s["spell;created=99458"] = {"虚灵之靴", "CRAFTING"}
        s["npc;sold=52822"] = {"[Zen'Vorka] <[Favors of the World Tree]>", "熔火前线"}
        s["spell;created=100687"] = {"强力打孔机", "CRAFTING"}
        s["spell;created=99460"] = {"黑焰长靴", "CRAFTING"}
        s["spell;created=99653"] = {"精工源质法刃", "CRAFTING"}
        s["npc;sold=53214"] = {"[Damek Bloombeard] <[Exceptional Equipment]>", "熔火前线"}
        s["spell;created=99459"] = {"无尽梦行之靴", "CRAFTING"}
        s["spell;created=99455"] = {"土灵鳞甲马靴", "CRAFTING"}
        s["spell;created=99449"] = {"唐塔约的地狱火手套", "CRAFTING"}
        s["spell;created=99657"] = {"铁卫", "CRAFTING"}
        s["npc;sold=54402"] = {"[Lurah Wrathvine] <[Crystallized Firestone Collector]>", "海加尔山"}
        s["npc;drop=52409"] = {"[Ragnaros]", "火焰之地"}
        s["npc;drop=52571"] = {"[Majordomo Staghelm] <[Archdruid of the Flame]>", "火焰之地"}
        s["npc;drop=53691"] = {"[Shannox]", "火焰之地"}
        s["npc;drop=52498"] = {"[Beth'tilac] <[The Red Widow]>", "火焰之地"}
        s["npc;drop=52558"] = {"[Lord Rhyolith]", "火焰之地"}
        s["npc;drop=52530"] = {"[Alysrazor]", "火焰之地"}
        s["npc;drop=53494"] = {"[Baleroc] <[The Gatekeeper]>", "火焰之地"}
        s["quest;reward=29331"] = {"[Elemental Bonds: The Vow]", "海加尔山"}
        s["npc;drop=53616"] = {"[Kar the Everburning] <[Firelord]>", "火焰之地"}
        s["npc;drop=54161"] = {"[Flame Archon]", "火焰之地"}
        s["npc;sold=52549"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
        s["quest;reward=29312"] = {"[The Stuff of Legends]", "暴风城"}
        s["npc;drop=55689"] = {"[Hagara the Stormbinder]", "巨龙之魂"}
        s["npc;drop=55308"] = {"[Warlord Zon'ozz]", "巨龙之魂"}
        s["npc;drop=55265"] = {"[Morchok]", "巨龙之魂"}
        s["npc;drop=55294"] = {"[Ultraxion]", "巨龙之魂"}
        s["npc;drop=55312"] = {"[Yor'sahj the Unsleeping]", "巨龙之魂"}
        s["npc;drop=56173"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["npc;drop=57821"] = {"[Lieutenant Shara] <[The Twilight's Hammer]>", "巨龙之魂"}
        s["spell;created=101932"] = {"守护泰坦腕甲", "CRAFTING"}
        s["npc;sold=241467"] = {"[Sylstrasza] <[Obsidian Fragment Exchange]>", "奥格瑞玛"}
        s["npc;drop=54938"] = {"[Archbishop Benedictus]", "暮光审判"}
        s["npc;drop=53879"] = {"[Deathwing] <[The Destroyer]>", "巨龙之魂"}
        s["spell;created=101925"] = {"无敌毁灭者腿铠", "CRAFTING"}
        s["spell;created=101931"] = {"毁灭之力护腕", "CRAFTING"}
        s["spell;created=101933"] = {"自然勇士护腿", "CRAFTING"}
        s["spell;created=101937"] = {"流静束腕", "CRAFTING"}
        s["npc;drop=56427"] = {"[Warmaster Blackhorn]", "巨龙之魂"}
        s["spell;created=101940"] = {"刃影护腕", "CRAFTING"}
        s["spell;created=101941"] = {"猎人杀手束腕", "CRAFTING"}
        s["spell;created=101921"] = {"熔岩地震护腿", "CRAFTING"}
        s["spell;created=101923"] = {"不羁之力束腕", "CRAFTING"}
        s["spell;created=101929"] = {"灵魂救赎腕甲", "CRAFTING"}
        s["npc;drop=55869"] = {"[Alizabal] <[Mistress of Hate]>", "巴拉丁监狱"}
        s["spell;created=101922"] = {"光芒梦境之束", "CRAFTING"}
        s["spell;created=101934"] = {"死鳞腿铠", "CRAFTING"}
        s["spell;created=101939"] = {"雷霆死鳞护腕", "CRAFTING"}
        s["npc;drop=55085"] = {"[Peroth'arn]", "永恒之井"}
        s["quest;reward=30118"] = {"[Patricide]", "巨龙之魂"}
        s["spell;created=101935"] = {"刃影护腿", "CRAFTING"}
        s["npc;sold=54658"] = {"[Sergeant Thunderhorn] <[Conquest Quartermaster]>", "奥格瑞玛"}
    end
end
