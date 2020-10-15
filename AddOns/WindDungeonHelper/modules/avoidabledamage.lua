-- Based on ElitismHelper
local W, F, L, P = unpack(select(2, ...))
local AD = W:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0")

local format = format
local gsub = gsub
local pairs = pairs
local sort = sort
local tinsert = tinsert
local wipe = wipe

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetRealmName = GetRealmName
local GetSpellLink = GetSpellLink
local GetUnitName = GetUnitName
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealthMax = UnitHealthMax
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer

local C_ChatInfo_GetRegisteredAddonMessagePrefixes = C_ChatInfo.GetRegisteredAddonMessagePrefixes
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_Timer_After = C_Timer.After

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local Spells = {
    -- [257274] = 20, -- Debug
    -- Affixes
    [209862] = 20, -- Volcanic Plume (Environment)
    [226512] = 20, -- Sanguine Ichor (Environment)
    [288694] = 20, -- Shadow Smash (Season 2)
    [288858] = 20, -- Expel Soul (Season 2)
    -- Freehold
    [272046] = 20, --- Dive Bomb (Sharkbait)
    [257426] = 20, --- Brutal Backhand (Irontide Enforcer)
    [258352] = 20, --- Grapeshot (Captain Eudora)
    [256594] = 20, --- Barrel Smash (Captain Raoul)
    [267523] = 20, --- Cutting Surge (Captain Jolly)
    [272374] = 20, --- Whirlpool of Blades (Captain Jolly)
    [272397] = 20, --- Whirlpool of Blades (Captain Jolly)
    [256546] = 20, --- Shark Tornado
    [257310] = 20, --- Cannon Barrage
    [257757] = 20, --- Goin' Bananas (Bilge Rat Buccaneer)
    [274389] = 20, --- Rat Traps (Vermin Trapper)
    [257902] = 20, --- Shell Bounce (Ludwig Von Tortollan)
    [258199] = 20, --- Ground Shatter (Irontide Crusher)
    [276061] = 20, --- Boulder Throw (Irontide Crusher)
    [258779] = 20, --- Sea Spout (Irontide Oarsman)
    [274400] = 20, --- Duelist Dash (Cutwater Duelist)
    [257274] = 20, --- Vile Coating (Environment)
    -- Shrine of the Storm
    [264560] = 20, --- Choking Brine (Aqualing)
    [267899] = 20, --- Hindering Cleave (Brother Ironhull)
    [268280] = 20, --- Tidal Pod (Tidesage Enforcer)
    [276286] = 20, --- Slicing Hurricane (Environment)
    [276292] = 20, --- Whirlign Slam (Ironhull Apprentice)
    [267385] = 20, --- Tentacle Slam (Vol'zith the Whisperer)
    -- import from ElitismHelper
    [276268] = 20, --- Heaving Blow (Shrine Templar)
    [267973] = 20, --- Wash Away (Temple Attendant)
    [268059] = 20, --- Anchor of Binding (Tidesage Spiritualist)
    [264155] = 20, --- Surging Rush (Aqu'sirr)
    [267841] = 20, --- Blowback (Galecaller Faye)
    -- Siege of Boralus
    [256627] = 20, --- Slobber Knocker (Scrimshaw Enforcer)
    [256663] = 20, --- Burning Tar (Blacktar Bomber)
    [257431] = 20, --- Meat Hook (Chopper Redhook)
    [275775] = 20, --- Savage Tempest (Irontide Raider)
    [269029] = 20, --- Clear the Deck (Dread Captain Lockwood)
    [272874] = 20, --- Trample (Ashvane Commander)
    [272426] = 20, --- Sighted Artillery
    [272140] = 20, --- Iron Volley
    [257292] = 20, --- Heavy Slash (Irontide Cleaver)
    [273681] = 20, --- Heavy Hitter (Chopper Redhook)
    [257886] = 20, --- Brine Pool (Hadal Darkfathom)
    -- import from ElitismHelper
    [257069] = 20, --- Watertight Shell (Kul Tiran Wavetender)
    [268260] = 20, --- Broadside (Ashvane Cannoneer)
    [268443] = 20, --- Dread Volley (Dread Captain Lockwood)
    [272713] = 20, --- Crushing Slam (Bilge Rat Demolisher)
    [274941] = 20, --- Banana Rampage swirlies(Bilge Rat Buccaneer)
    [257883] = 20, --- Break Water (Hadal Darkfathom)
    [276068] = 20, --- Tidal Surge (Hadal Darkfathom)
    [261565] = 20, --- Crashing Tide (Hadal Darkfathom)
    [277535] = 20, --- Viq'Goth's Wrath (Viq'Goth)
    -- Tol Dagor
    [257785] = 20, --- Flashing Daggers
    [256976] = 20, --- Ignition (Knight Captain Valyri)
    [256955] = 20, --- Cinderflame (Knight Captain Valyri)
    [256083] = 20, --- Cross Ignition (Overseer Korgus)
    [263345] = 20, --- Massive Blast (Overseer Korgus)
    [258864] = 20, --- Suppression Fire (Ashvane Marine/Spotter)
    [258364] = 20, --- Fuselighter (Ashvane Flamecaster)
    [259711] = 20, --- Lockdown (Ashvane Warden)
    -- import from ElitismHelper
    [257119] = 20, --- Sand Trap (The Sand Queen)
    [256710] = 20, --- Burning Arsenal (Knight Captain Valyri)
    -- Waycrest Manor
    [260569] = 20, --- Wildfire (Soulbound Goliath)
    [265407] = 20, --- Dinner Bell (Banquet Steward)
    [264923] = 20, --- Tenderize (Raal the Gluttonous)
    [264150] = 20, --- Shatter (Thornguard)
    [271174] = 20, --- Retch (Pallid Gorger)
    [268387] = 20, --- Contagious Remnants (Lord Waycrest)
    [268308] = 20, --- Discordant Cadenza (Lady Waycrest
    -- import from ElitismHelper
    [264531] = 20, --- Shrapnel Trap (Maddened Survivalist)
    [264476] = 20, --- Tracking Explosive (Crazed Marksman)
    [264712] = 20, --- Rotten Expulsion (Raal the Gluttonous)
    [272669] = 20, --- Burning Fists (Soulbound Goliath)
    [278849] = 20, --- Uproot (Coven Thornshaper)
    [264040] = 20, --- Uprooted Thorns (Coven Thornshaper)
    [265757] = 20, --- Splinter Spike (Matron Bryndle)
    -- Atal'Dazar
    [253666] = 20, --- Fiery Bolt (Dazar'ai Juggernaught)
    [257692] = 20, --- Tiki Blaze (Environment)
    [255620] = 20, --- Festering Eruption (Reanimated Honor Guard)
    [256959] = 20, --- Rotting Decay (Renaimated Honor Guard)
    [250259] = 20, --- Toxic Leap
    [250022] = 20, --- Echoes of Shadra (Echoes of Shadra)
    [250585] = 20, --- Toxic Pool
    [250036] = 20, --- Shadowy Remains
    -- import from ElitismHelper
    [258723] = 20, --- Grotesque Pool (Renaimated Honor Guard)
    [255567] = 20, --- Frenzied Charge (T'lonja)
    -- King's Rest
    [265914] = 20, --- Molten Gold (The Golden Serpent)
    [266191] = 20, --- Whirling Axe (Council of Tribes)
    [270289] = 20, --- Purification Beam
    [270503] = 20, --- Hunting Leap (Honored Raptor)
    [271564] = 20, --- Embalming Fluid (Embalming Fluid)
    [270485] = 20, --- Blooded Leap (Spectral Berserker)
    [267639] = 20, --- Burn Corruption (Mchimba the Embalmer)
    [270931] = 20, --- Darkshot
    -- import from ElitismHelper
    [270003] = 20, --- Suppression Slam (Animated Guardian)
    [269932] = 20, --- Ghust Slash (Shadow-Borne Warrior)
    [265781] = 20, --- Serpentine Gust (The Golden Serpent)
    [270928] = 20, --- Bladestorm (King Timalji)
    [270891] = 20, --- Channel Lightning (King Rahu'ai)
    [270292] = 20, --- Purifying Flame (Purification Construct)
    [270514] = 20, --- Ground Crush (Spectral Brute)
    [268419] = 20, --- Gale Slash (King Dazar)
    [268796] = 20, --- Impaling Spear (King Dazar)
    -- The MOTHERLODE!!
    [257371] = 20, --- Gas Can (Mechanized Peace Keeper)
    [262287] = 20, --- Concussion Charge (Mech Jockey / Venture Co. Skyscorcher)
    [268365] = 20, --- Mining Charge (Wanton Sapper)
    [269313] = 20, --- Final Blast (Wanton Sapper)
    [275907] = 20, --- Tectonic Smash
    [259533] = 20, --- Azerite Catalyst (Rixxa Fluxflame)
    [260103] = 20, --- Propellant Blast
    [260279] = 20, --- Gattling Gun (Mogul Razdunk)
    [276234] = 20, --- Micro Missiles
    [270277] = 20, --- Big Red Rocket (Mogul Razdunk)
    [271432] = 20, --- Test Missile (Venture Co. War Machine)
    [262348] = 20, --- Mine Blast
    [257337] = 20, --- Shocking Claw
    [269092] = 20, --- Artillery Barrage (Ordnance Specialist)
    -- import from ElitismHelper
    [268417] = 20, --- Power Through (Azerite Extractor)
    [268704] = 20, --- Furious Quake (Stonefury)
    [258628] = 20, --- Resonant Quake (Earthrager)
    [271583] = 20, --- Black Powder Special (Mines near the track)
    [269831] = 20, --- Toxic Sludge (Oil Environment)
    -- Temple of Sethraliss
    [268851] = 20, --- Lightning Shield (Adderis)
    [273225] = 20, --- Volley (Sandswept Marksman)
    [264574] = 20, --- Power Shot (Sandswept Marksman)
    [273995] = 20, --- Pyrrhic Blast (Crazed Incubator)
    [264206] = 20, --- Burrow (Merektha)
    [272657] = 20, --- Noxious Breath
    [272658] = 20, --- Electrified Scales
    [272821] = 20, --- Call Lightning (Stormcaller)
    -- import from ElitismHelper
    [263425] = 20, --- Arc Dash (Adderis)
    [263573] = 20, --- Cyclone Strike (Adderis)
    [272655] = 20, --- Scouring Sand (Mature Krolusk)
    [272696] = 20, --- Lightning in a Bottle (Crazed Incubator)
    [264763] = 20, --- Spark (Static-charged Dervish)
    [279014] = 20, --- Cardiac Shock (Avatar, Environment)
    -- Underrot
    [264757] = 20, --- Sanguine Feast (Elder Leaxa)
    [265542] = 20, --- Rotten Bile (Fetid Maggot)
    [265019] = 20, --- Savage Cleave (Chosen Blood Matron)
    [261498] = 20, --- Creeping Rot (Elder Leaxa)
    [265665] = 20, --- Foul Sludge (Living Rot)
    [265511] = 20, --- Spirit Drain (Spirit Drain Totem)
    [272469] = 20, --- Abyssal Slam (Abyssal Reach)
    [272609] = 20, --- Maddening Gaze (Faceless Corruptor)
    -- import from ElitismHelper
    [260312] = 20, --- Charge (Cragmaw the Infested)
    [259720] = 20, --- Upheaval (Sporecaller Zancha)
    [270108] = 20, --- Rotting Spore (Unbound Abomination)
    [270108] = 20, --- Rotting Spore (Unbound Abomination)
    -- from ElitismHelper and https://nga.178.com/read.php?&tid=15265896&pid=396636585&to=1
    -- Mechagon Workshop
    [294128] = 20, --- Rocket Barrage (Rocket Tonk)
    [285020] = 20, --- Whirling Edge (The Platinum Pummeler)
    [294291] = 20, --- Process Waste ()
    [291930] = 20, --- Air Drop (K.U-J.0)
    [294324] = 20, --- Mega Drill (Waste Processing Unit)
    [293861] = 20, --- Anti-Personnel Squirrel (Anti-Personnel Squirrel)
    [295168] = 20, --- Capacitor Discharge (Blastatron X-80)
    [294954] = 20, --- Self-Trimming Hedge (Head Machinist Sparkflux)
    [283422] = 20, -- 车+机器人，全速前进
    [282945] = 20, -- 车+机器人，电锯
    [285344] = 20, -- 车+机器人，埋设地雷
    [291953] = 20, -- 狂犬，垃圾炸弹
    [291946] = 20, -- 狂犬，喷射烈焰
    [301299] = 20, -- 传送带，焚炉烈焰
    [294015] = 20, -- 爆破金刚，发射高爆火箭
    [293986] = 20, -- 爆破金刚，声波脉冲
    [285454] = 20, -- 机械师闪流，脉冲榴弹
    [291915] = 20, -- 国王，等离子球
    [291856] = 20, -- 国王，离子校正
    -- Mechagon Junkyard
    -- from ElitismHelper and https://nga.178.com/read.php?&tid=15265896&pid=396636585&to=1
    [300816] = 20, --- Slimewave (Slime Elemental)
    [300188] = 20, --- Scrap Cannon (Weaponized Crawler)
    [300427] = 20, --- Shockwave (Scrapbone Bully)
    [294890] = 20, --- Gryro-Scrap (Malfunctioning Scrapbot)
    [300129] = 20, --- Self-Destruct Protocol (Malfunctioning Scrapbot)
    [300561] = 20, --- Explosion (Scrapbone Trashtosser)
    [299475] = 20, --- B.O.R.K. (Scraphound)
    [299535] = 20, --- Scrap Blast (Pistonhead Blaster)
    [298940] = 20, --- Bolt Buster (Naeno Megacrash)
    [297283] = 20, --- Cave In (King Gobbamak)
    [300159] = 20, -- 重装拳机，旋翼风暴
    [297835] = 20, -- 冈克，融合
    [297985] = 20, -- 冈克，泼溅
    [297834] = 20, -- 冈克，剧毒波浪
    [299164] = 20, -- 男女，风驰电掣
    [302681] = 20, -- 男女，超能跳电
    [298849] = 20, -- 男女，电流滑步
    [298571] = 20, -- 男女，燃尽
    [301667] = 20, -- 麦卡贡骑兵，急速射击
    [295536] = 20, -- 飞机，火炮冲击
    [302384] = 20, -- 飞机，静电释放
    [296522] = 20, -- 飞机，自毁
    [296150] = 20, -- 飞机，喷涌冲击
    --- Awakened Lieutenant
    [240448] = 20, -- 震荡
    [314387] = 20, -- 秒t怪菌毯
    [314309] = 20, --- Dark Fury (Urg'roth, Breaker of Heroes)
    [314467] = 20, --- Volatile Rupture (Voidweaver Mal'thir)
    [314565] = 20 --- Defiled Ground (Blood of the Corruptor)
}

local SpellsNotTank = {
    -- Siege of Boralus
    [268230] = 20, --- Crimson Swipe (Ashvane Deckhand)
    -- Tol Dagor
    [258864] = 20, --- Suppression Fire (Ashvane Marine/Spotter)
    -- Waycrest Manor
    [263905] = 20, --- Marking Cleave (Heartsbane Runeweaver)
    [265372] = 20, ---	Shadow Cleave (Enthralled Guard)
    [271174] = 20, --- Retch (Pallid Gorger)
    -- Atal'Dazar

    -- King's Rest
    [270289] = 20, --- Purification Beam (Purification Construct)
    -- The MOTHERLODE!!
    [268846] = 20, --- Echo Blade (Weapons Tester)
    [263105] = 20, --- Blowtorch (Feckless Assistant)
    [263583] = 20, --- Broad Slash (Taskmaster Askari)
    -- Temple of Sethraliss
    [255741] = 20, --- Cleave (Scaled Krolusk Rider)
    -- Underrot
    [272457] = 20, --- Shockwave (Sporecaller Zancha)
    [260793] = 20 --- Indigestion (Cragmaw the Infested)
}

local Auras = {
    -- Freehold
    [274516] = true, -- Slippery Suds
    [274389] = true, -- Rat Traps (Vermin Trapper)
    -- Shrine of the Storm
    [268391] = true, -- Mental Assault (Abyssal Cultist)
    [276268] = true, -- Heaving Blow (Shrine Templar)
    [269104] = true, -- Explosive Void (Lord Stormsong)
    [267956] = true, -- Zap (Jellyfish)
    -- Siege of Boralus
    [257292] = true, -- Heavy Slash (Kul Tiran Vanguard)
    [272874] = true, -- Trample (Ashvane Commander)
    [257169] = true, -- Fear
    -- Tol Dagor
    [257119] = true, -- Sand Trap (The Sand Queen)
    [256474] = true, -- Heartstopper Venom (Overseer Korgus)
    -- Waycrest Manor
    [265352] = true, -- Toad Blight (Toad)
    [278468] = true, -- Freezing Trap
    -- Atal'Dazar
    [255371] = true, -- Terrifying Visage (Rezan)
    -- King's Rest
    [270003] = true, -- Suppression Slam (Animated Guardian)
    [270931] = true, -- Darkshot
    [268796] = true, -- (Kind Dazar)
    -- The MOTHERLODE!!

    -- Temple of Sethraliss
    [263914] = true, -- Blinding Sand (Merektha)
    [269970] = true, -- Blinding Sand (Merektha)
    -- Underrot
    [272609] = true, -- Maddening Gaze (Faceless Corrupter)
    -- Mechagon Workshop
    [293986] = true, --- Sonic Pulse (Blastatron X-80)
    [294863] = true, -- 机械师，烈油之泉
    [285440] = true, -- 机械师，烈焰火炮
    -- Mechaton Junkyard
    [398529] = true, -- Gooped (Gunker)
    [300659] = true, -- Consuming Slime (Toxic Monstrosity)
    [298124] = true, -- 冈克，束缚粘液
    [298259] = true -- 冈克，束缚粘液
}

local AurasNotTank = {}

local warningMessage
local stacksMessage
local spellMessage

local allUsers = {}
local timers = {}
local timerData = {}
local combinedFails = {}

local activeUser
local playerName = GetUnitName("player", true) .. "-" .. gsub(GetRealmName(), " ", "")

local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
end

function AD:SetNotificationText()
    if self.db.custom.enable then
        warningMessage = self.db.custom.warningMessage
        stacksMessage = self.db.custom.stacksMessage
        spellMessage = self.db.custom.spellMessage
    else
        warningMessage = P.avoidableDamage.custom.warningMessage
        stacksMessage = P.avoidableDamage.custom.stacksMessage
        spellMessage = P.avoidableDamage.custom.spellMessage
    end
end

function AD:GenerateOutput(text, name, spell, stack, damage, percent)
    text = gsub(text, "%%name%%", name)
    text = gsub(text, "%%spell%%", spell)

    if stack then
        text = gsub(text, "%%stack%%", stack)
    end

    if damage then
        text = gsub(text, "%%damage%%", damage)
    end

    if percent then
        percent = F.Round(percent, self.db.notification.accuracy)
        text = gsub(text, "%%percent%%", format("%s%%%%", percent))
    end
    return text
end

function AD:GenerateNumber(amount)
    if self.db.notification.unit == "ASIA" then
        if amount > 10000 then
            return F.Round(amount / 10000, self.db.notification.accuracy) .. L["[UNIT] W"]
        else
            return amount
        end
    elseif self.db.notification.unit == "WESTERN" then
        if amount > 1000 then
            return F.Round(amount / 1000, self.db.notification.accuracy) .. L["[UNIT] K"]
        else
            return amount
        end
    end
    return amount
end

function AD:SetAddonMessagePrefix()
    -- compatible mode
    self.prefix = self.db.compatible and "ElitismHelper" or W.AddonMsgPrefix

    if self.db.compatible then
        local registeredPrefixs = C_ChatInfo_GetRegisteredAddonMessagePrefixes()

        for _, registeredPrefix in pairs(registeredPrefixs) do
            if self.prefix == registeredPrefix then
                return
            end
        end

        C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)
    end
end

function AD:SendAddonMessage(message)
    if IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid() then
        C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
    end
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or activeUser ~= playerName then
        return
    end

    if self.db.notification.channel == "SELF" then
        print(message)
    elseif self.db.notification.channel == "PARTY" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(message, "PARTY")
    elseif self.db.notification.channel == "EMOTE" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(": " .. message, "EMOTE")
    end
end

function AD:SpellDamage(dstName, spellID, damageAmount)
    if not UnitIsPlayer(dstName) then
        return
    end

    local isTank = UnitGroupRolesAssigned(dstName) == "TANK"

    if Spells[spellID] or (SpellsNotTank[spellID] and not isTank) then
        -- Initialize TimerData and CombinedFails for Timer shot
        if timerData[dstName] == nil then
            timerData[dstName] = {}
        end

        if combinedFails[dstName] == nil then
            combinedFails[dstName] = 0
        end

        -- Add this event to TimerData / CombinedFails
        combinedFails[dstName] = combinedFails[dstName] + damageAmount
        if timerData[dstName][spellID] == nil then
            timerData[dstName][spellID] = damageAmount
        else
            timerData[dstName][spellID] = timerData[dstName][spellID] + damageAmount
        end

        -- If there is no timer yet, start one with this event
        if timers[dstName] == nil then
            timers[dstName] = true
            C_Timer_After(
                4,
                function()
                    self:SpellDamageAnnouncer(dstName)
                end
            )
        end
    end
end

function AD:SpellDamageAnnouncer(player)
    local spellLinks = ""
    local totalDamage = 0

    for spellID, damage in pairs(timerData[player]) do
        spellLinks = spellLinks .. GetSpellLink(spellID) .. " "
        totalDamage = totalDamage + damage
    end

    timerData[player] = nil
    timers[player] = nil

    local playerMaxHealth = UnitHealthMax(player)
    local damageText = self:GenerateNumber(totalDamage)
    local percentage = totalDamage / playerMaxHealth * 100

    if self.db.notification.enable and percentage >= self.db.notification.threshold then
        self:SendChatMessage(self:GenerateOutput(spellMessage, player, spellLinks, nil, damageText, percentage))
    end
end

function AD:AuraApply(dstName, spellID, auraAmount)
    if not UnitIsPlayer(dstName) or not self.db.notification.enable then
        return
    end

    local isTank = UnitGroupRolesAssigned(dstName) == "TANK"

    if Auras[spellID] or (AurasNotTank[spellID] and not isTank) then
        if auraAmount then
            self:SendChatMessage(self:GenerateOutput(stacksMessage, dstName, GetSpellLink(spellID), auraAmount))
        else
            self:SendChatMessage(self:GenerateOutput(warningMessage, dstName, GetSpellLink(spellID)))
        end
    end
end

function AD:ResetAuthority()
    wipe(allUsers)
    activeUser = nil

    if IsInGroup(LE_PARTY_CATEGORY_HOME) then
        self:SendAddonMessage("VREQ")
    else
        activeUser = playerName
    end
end

function AD:ResetStatistic()
    wipe(combinedFails)
    wipe(timerData)
    wipe(timers)
end

function AD:CHALLENGE_MODE_COMPLETED()
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    if self.db.rank.enable then
        return
    end

    if #combinedFails == 0 then
        self:SendChatMessage(L["No failure damage was taken this run."])
        return
    end

    self:SendChatMessage(L["Amount of failure damage:"])

    local damageTable = {}
    for name, damage in pairs(combinedFails) do
        tinsert(damageTable, {key = name, value = damage})
    end

    SortTable(damageTable)

    for index, data in pairs(damageTable) do
        self:SendChatMessage(format("%d. %s %s", index, data.key, self:GenerateNumber(data["value"])))
    end

    if self.db.rank.worst then
        self:SendChatMessage("------------------------")
        self:SendChatMessage(format("%s: %s", self.db.rank.customWorst, damageTable[1].key))
    end

    self:ResetStatistic()
end

function AD:CHALLENGE_MODE_START()
    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:ResetStatistic()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function AD:CHAT_MSG_ADDON(_, prefix, message, channel, sender)
    if prefix ~= self.prefix then
        return
    end

    if message == "VREQ" then
        self:SendAddonMessage("VANS")
    elseif message:match("^VANS") then
        allUsers[sender] = true
        for userName in pairs(allUsers) do
            if activeUser == nil then
                activeUser = userName
            end
            if userName < activeUser then
                activeUser = userName
            end
        end
    end
end

function AD:COMBAT_LOG_EVENT_UNFILTERED()
    local _, type, _, _, _, _, _, _, destName, _, _, spellId, _, _, info15, info16, info17 =
        CombatLogGetCurrentEventInfo()
    local eventPrefix, eventSuffix = type:match("^(.-)_?([^_]*)$")
    if (eventPrefix:match("^SPELL") or eventPrefix:match("^RANGE")) and eventSuffix == "DAMAGE" then
        self:SpellDamage(destName, spellId, info15)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        if info17 then
            self:SpellDamage(destName, spellId, info17)
        end
    elseif type == "SPELL_AURA_APPLIED" then
        self:AuraApply(destName, spellId)
    elseif type == "SPELL_AURA_APPLIED_DOSE" then
        self:AuraApply(destName, spellId, info16)
    end
end

function AD:OnInitialize()
    self.db = W.db.avoidableDamage

    self:SetAddonMessagePrefix()
    self:SetNotificationText()
    self:ProfileUpdate()
end

function AD:ProfileUpdate()
    self.db = W.db.avoidableDamage

    if self.db.enable then
        self:ResetAuthority()
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE", "ResetAuthority")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ResetAuthority")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        self:UnregisterEvent("CHAT_MSG_ADDON")
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("CHALLENGE_MODE_START")
        self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:ResetStatistic()
    end
end

function AD:GetActiveUser()
    return activeUser
end
