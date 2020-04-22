-- Based on ElitismHelper
local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase
local gsub = string.gsub
local SendChatMessage = SendChatMessage
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer
local GetUnitName = GetUnitName
local GetRealmName = GetRealmName
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local AD = WDH:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0")

DB.defaults.profile.modules.AvoidableDamage = {
    enable = true,
    notification = {
        enable = true,
        compatible = true,
        outputmode = "party",
        threshold = 30,
        unit = "western",
        accuracy = 1
    },
    rank = {
        enable = true,
        worst = false,
        custom_worst = L["Need improve"]
    },
    custom = {
        enable = false,
        warningMsg = L["%name% got hit by %spell%."],
        stacksMsg = L["%name% got hit by %spell%. %stack% Stacks."],
        spellMsg = L["%name% got hit by %spell% for %damage% (%percent%)."]
    }
}

C.ModulesOrder.AvoidableDamage = 20

C.ModulesOption.AvoidableDamage = {
    name = L["Avoidable Damage"],
    type = "group",
    childGroups = "tree",
    args = {
        general = {
            order = 1,
            name = L["General"],
            type = "group",
            inline = true,
            args = {
                enable = {
                    order = 1,
                    name = L["Enable"],
                    desc = L["Enables / disables the module"],
                    type = "toggle",
                    width = "full",
                    set = function(info, value)
                        AD.db.enable = value
                        AD:ToggleModule()
                        C_Timer.After(1, function() return AD:RefreshOption() end)
                    end,
                    get = function(info) return AD.db.enable end
                },
                activeUser = {
                    order = 2,
                    type = "description",
                    width = "full",
                    hidden = function(info) return not AD.db.enable end,
                    name = function()
                        return AD.activeUser and B.ColorString(L["Active announcer"], 0, 1, 0.59) .. ": " ..
                                   AD.activeUser
                    end
                }
            }
        },
        notification = {
            order = 2,
            name = L["Notifications"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            args = {
                enable = {
                    order = 11,
                    name = L["Damage notifications"],
                    desc = L["Enables / disables damage notifications"],
                    type = "toggle",
                    set = function(info, value) AD.db.notification.enable = value end,
                    get = function(info) return AD.db.notification.enable end
                },
                threshold = {
                    order = 12,
                    name = L["Damage threshold"],
                    desc = L["If the sum of damage over threshold, WDH will notify you."],
                    type = "range",
                    disabled = function(info) return not AD.db.notification.enable end,
                    min = 1,
                    max = 100,
                    step = 1,
                    set = function(info, value)
                        AD.db.notification.threshold = value;
                        AD.hardMinPct = AD.db.notification.threshold
                    end,
                    get = function(info) return AD.db.notification.threshold end
                },
                outputmode = {
                    order = 13,
                    name = L["Messeage Output"],
                    desc = L["Define output channel"],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "select",
                    set = function(info, value) AD.db.notification.outputmode = value end,
                    get = function(info) return AD.db.notification.outputmode end,
                    values = {
                        ["self"] = L["Self(Chat Frame)"],
                        ["party"] = L["Party"],
                        ["emote"] = L["Emote"],
                        ["none"] = L["None"]
                    }
                },
                unit = {
                    order = 14,
                    name = L["Numeral System"],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "select",
                    set = function(info, value) AD.db.notification.unit = value end,
                    get = function(info) return AD.db.notification.unit end,
                    values = {["western"] = L["Western - k"], ["asia"] = L["Asia - W"]}
                },
                accuracy = {
                    order = 15,
                    name = L["Damage accuracy"],
                    type = "range",
                    disabled = function(info) return not AD.db.notification.enable end,
                    min = 0,
                    max = 5,
                    step = 1,
                    set = function(info, value) AD.db.notification.accuracy = value end,
                    get = function(info) return AD.db.notification.accuracy end
                },
                compatible = {
                    order = 16,
                    name = L["Be compatible with ElitismHelper"],
                    desc = L["Use 'ElitismHelper' as addon message prefix."],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "toggle",
                    width = "full",
                    get = function(info) return AD.db.notification.compatible end,
                    set = function(info, value)
                        AD.db.notification.compatible = value
                        AD:UnregisterEvent("CHAT_MSG_ADDON")
                        AD:SetAddonMessagePrefix()
                        AD.activeUser = nil
                        AD.allUsers = {}
                        if AD.db.enable then
                            AD:RegisterEvent("CHAT_MSG_ADDON")
                            if IsInGroup() then
                                AD:SendAddonMessage("VREQ")
                            else
                                AD.activeUser = AD.playerUser
                            end
                            C_Timer.After(2, function() return AD:RefreshOption() end)
                        end
                    end
                }
            }
        },
        rank = {
            order = 3,
            name = L["Ranking"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            args = {
                enable = {
                    order = 16,
                    name = L["Enable"],
                    desc = L["Enables / disables ranking after dungeon completed."],
                    type = "toggle",
                    set = function(info, value) AD.db.rank.enable = value end,
                    get = function(info) return AD.db.rank.enable end
                },
                worst = {
                    order = 17,
                    name = L["The worst player"],
                    desc = L["Enables / disables show the worst player in ranking."],
                    type = "toggle",
                    set = function(info, value) AD.db.rank.worst = value end,
                    get = function(info) return AD.db.rank.worst end
                },
                worst_custom = {
                    order = 18,
                    type = "input",
                    hidden = function(info) return not AD.db.rank.worst end,
                    name = L["The worst player text"],
                    get = function(info) return AD.db.rank.custom_worst end,
                    set = function(info, value) AD.db.rank.custom_worst = value end
                },
                worst_custom_default = {
                    order = 19,
                    name = L["Defaults"],
                    hidden = function(info) return not AD.db.rank.worst end,
                    type = "execute",
                    func = function()
                        AD.db.rank.custom_worst = DB.defaults.profile.modules.AvoidableDamage.rank.custom_worst
                    end
                },
                worst_example = {
                    order = 20,
                    type = "description",
                    hidden = function(info) return not AD.db.rank.worst end,
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " .. AD.db.rank.custom_worst .. ": " .. AD.playerUser
                    end
                }
            }
        },
        customization = {
            order = 4,
            name = L["Customization"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            disabled = function() return not AD.db.custom.enable end,
            args = {
                enable = {
                    order = 41,
                    name = L["Enable"],
                    type = "toggle",
                    disabled = false,
                    set = function(info, value)
                        AD.db.custom.enable = value;
                        AD:SetNotificationText()
                    end,
                    get = function(info) return AD.db.custom.enable end
                },
                default = {
                    order = 42,
                    name = L["Defaults"],
                    type = "execute",
                    func = function()
                        AD.db.custom.warningMsg = DB.defaults.profile.modules.AvoidableDamage.custom.warningMsg
                        AD.db.custom.stacksMsg = DB.defaults.profile.modules.AvoidableDamage.custom.stacksMsg
                        AD.db.custom.spellMsg = DB.defaults.profile.modules.AvoidableDamage.custom.spellMsg
                    end
                },
                warning = {
                    order = 43,
                    type = "input",
                    width = "full",
                    name = L["Warning message text"],
                    desc = function() return AD.Tips end,
                    get = function(info) return AD.db.custom.warningMsg end,
                    set = function(info, value)
                        AD.db.custom.warningMsg = value;
                        AD:SetNotificationText()
                    end
                },
                warningex = {
                    order = 44,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.warningMsg, AD.playerUser, GetSpellLink(257274))
                    end
                },
                stack = {
                    order = 45,
                    type = "input",
                    name = L["Stack message text"],
                    desc = function() return AD.Tips end,
                    width = 'full',
                    get = function(info) return AD.db.custom.stacksMsg end,
                    set = function(info, value)
                        AD.db.custom.stacksMsg = value;
                        AD:SetNotificationText()
                    end
                },
                stackgex = {
                    order = 46,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.stacksMsg, AD.playerUser, GetSpellLink(257274), 3)
                    end
                },
                spell = {
                    order = 47,
                    type = "input",
                    name = L["Spell message text"],
                    desc = function() return AD.Tips end,
                    width = 'full',
                    get = function(info) return AD.db.custom.spellMsg end,
                    set = function(info, value)
                        AD.db.custom.spellMsg = value;
                        AD:SetNotificationText()
                    end
                },
                spellex = {
                    order = 48,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.spellMsg, AD.playerUser, GetSpellLink(257274), nil,
                                                     AD:GenerateNumber(25000), "18%%")
                    end
                }
            }
        }
    }
}

local Spells = {
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
local SpellsNoTank = {
    -- Freehold

    -- Shrine of the Storm

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
local AurasNoTank = {}

local function compareDamage(a, b) return a["value"] > b["value"] end

function AD:OnInitialize()
    self.Version = B.Version
    self.db = DB.profile.modules.AvoidableDamage
    self.activeUser = nil
    self.playerUser = GetUnitName("player", true) .. "-" .. GetRealmName():gsub(" ", "")
    self.allUsers = {}
    self.Timers = {}
    self.TimerData = {}
    self.CombinedFails = {}
    self.hardMinPct = self.db.notification.threshold

    self.Tips = L["Tips"] .. ": \n" .. B.ColorString("%name%") .. " = " .. L["Player Name"] .. "\n" ..
                    B.ColorString("%spell%") .. " = " .. L["Spell Link"] .. "\n" .. B.ColorString("%stack%") .. " = " ..
                    L["Aura Stacks"] .. "\n" .. B.ColorString("%damage%") .. " = " .. L["Damage"] .. "\n" ..
                    B.ColorString("%percent%") .. " = " .. L["Percent"]

    self:SetAddonMessagePrefix()
    self:SetNotificationText()
    self:RebuildTable()
    self:ToggleModule()
end

function AD:ToggleModule()
    if self.db.enable then
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    else
        self:UnregisterEvent("CHAT_MSG_ADDON")
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("CHALLENGE_MODE_START")
        self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
    end
end

function AD:RefreshOption() LibStub("AceConfigRegistry-3.0"):NotifyChange("WindDungeonHelper") end

---------------------------------------
-- Chat function
function AD:SetAddonMessagePrefix()
    -- work with ElitismHelper
    self.prefix = self.db.notification.compatible and "ElitismHelper" or B.AddonMsgPrefix

    if self.db.notification.compatible then
        local registeredPrefixTable = C_ChatInfo.GetRegisteredAddonMessagePrefixes()

        for i, v in pairs(registeredPrefixTable) do
            -- if registered, quit
            if self.prefix == v then return end
        end

        local regStatus = C_ChatInfo.RegisterAddonMessagePrefix(self.prefix)
        -- if register failed
        if debug and not regStatus then print("prefix error") end
    end
end

function AD:SendAddonMessage(message)
    if IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and not IsInRaid() then
        if self.db.notification.outputmode == "party" or self.db.notification.outputmode == "emote" then
            C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
        end
    end
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or self.activeUser ~= self.playerUser then return end
    if self.db.notification.outputmode == "none" then return end
    if self.db.notification.outputmode == "self" then
        print(message)
    elseif self.db.notification.outputmode == "party" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(message, "PARTY")
    elseif self.db.notification.outputmode == "emote" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(": " .. message, "EMOTE")
    end
end

function AD:SetNotificationText()
    local db = self.db.custom
    self.warningMsg = db.enable and db.warningMsg or L["%name% got hit by %spell%."]
    self.stacksMsg = db.enable and db.stacksMsg or L["%name% got hit by %spell%. %stack% Stacks."]
    self.spellMsg = db.enable and db.spellMsg or L["%name% got hit by %spell% for %damage% (%percent%)."]
end

function AD:GenerateOutput(str, name, spell, stack, damage, percent)
    local new = gsub(str, "%%name%%", name)
    new = gsub(new, "%%spell%%", spell)
    if stack then new = gsub(new, "%%stack%%", stack) end
    if damage then new = gsub(new, "%%damage%%", damage) end
    if percent then new = gsub(new, "%%percent%%", percent) end
    return new
end

function AD:GenerateNumber(amount)
    if self.db.notification.unit == "western" then
        return B.Round(amount / 1000, self.db.notification.accuracy) .. L["unit_k"]
    elseif self.db.notification.unit == "asia" then
        return B.Round(amount / 10000, self.db.notification.accuracy) .. L["unit_W"]
    end
end
---------------------------------------
-- Notification
function AD:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId,
                        spellName, spellSchool, aAmount)
    if (Spells[spellId] or (SpellsNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK")) and
        UnitIsPlayer(dstName) then
        -- Initialize TimerData and CombinedFails for Timer shot
        if self.TimerData[dstName] == nil then self.TimerData[dstName] = {} end
        if self.CombinedFails[dstName] == nil then self.CombinedFails[dstName] = 0 end

        -- Add this event to TimerData / CombinedFails
        self.CombinedFails[dstName] = self.CombinedFails[dstName] + aAmount
        if self.TimerData[dstName][spellId] == nil then
            self.TimerData[dstName][spellId] = aAmount
        else
            self.TimerData[dstName][spellId] = self.TimerData[dstName][spellId] + aAmount
        end

        -- If there is no timer yet, start one with this event
        if self.Timers[dstName] == nil then
            self.Timers[dstName] = true
            C_Timer.After(4, function() return self:SpellDamageAnnouncer(dstName) end)
        end
    end
end

function AD:SpellDamageAnnouncer(user)
    local spellLink = ""
    local amount = 0
    local minPct = math.huge
    for k, v in pairs(self.TimerData[user]) do
        spellLink = spellLink .. GetSpellLink(k) .. " "
        local spellMinPct = nil
        if Spells[k] then
            spellMinPct = Spells[k]
        elseif SpellsNoTank[k] then
            spellMinPct = SpellsNoTank[k]
        end
        if spellMinPct ~= nil and spellMinPct < minPct then minPct = spellMinPct end
        amount = amount + v
    end
    self.TimerData[user] = nil
    self.Timers[user] = nil
    local userMaxHealth = UnitHealthMax(user)
    local msgAmount = self:GenerateNumber(amount)
    local pct = Round(amount / userMaxHealth * 100)

    if pct >= self.hardMinPct and pct >= minPct and self.db.notification.enable then
        self:SendChatMessage(self:GenerateOutput(self.spellMsg, user, spellLink, nil, msgAmount, pct .. "%%"))
    end
end

function AD:SwingDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, aAmount) end

function AD:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName,
                      spellSchool, auraType, auraAmount)
    if (Auras[spellId] or (AurasNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK")) and
        UnitIsPlayer(dstName) then
        if self.db.notification.enable then
            if auraAmount then
                self:SendChatMessage(self:GenerateOutput(self.stacksMsg, dstName, GetSpellLink(spellId), auraAmount))
            else
                self:SendChatMessage(self:GenerateOutput(self.warningMsg, dstName, GetSpellLink(spellId)))
            end
        end
    end
end

function AD:RebuildTable()
    self.allUsers = {}
    self.activeUser = nil

    if IsInGroup() then
        self:SendAddonMessage("VREQ")
    else
        self.activeUser = self.playerUser
    end
end

---------------------------------------
-- Event Binding
function AD:GROUP_ROSTER_UPDATE(event, ...) self:RebuildTable() end

function AD:ZONE_CHANGED_NEW_AREA(event, ...) self:RebuildTable() end

function AD:CHALLENGE_MODE_COMPLETED(event, ...)
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    if not self.db.rank.enable or not self.db.enable then return end
    local count = 0
    for _ in pairs(self.CombinedFails) do count = count + 1 end
    if count == 0 then
        self:SendChatMessage(L["No failure damage was taken this run."])
        return
    else
        self:SendChatMessage(L["Amount of failure damage:"])
    end
    local u = {}
    for k, v in pairs(self.CombinedFails) do table.insert(u, {key = k, value = v}) end
    table.sort(u, compareDamage)

    local failure_damage = -1
    local name = "someone"

    for k, v in pairs(u) do
        if failure_damage == -1 then
            failure_damage = v["value"]
            name = v["key"]
        else
            if v["value"] > failure_damage then name = v["key"] end
        end
        self:SendChatMessage(k .. ". " .. v["key"] .. " " .. self:GenerateNumber(v["value"]))
    end

    self.CombinedFails = {}

    if self.db.rank.worst then
        local worst = self.db.rank.worst and self.db.rank.custom_worst or L["Need improve"]
        self:SendChatMessage("------------------------")
        self:SendChatMessage(worst .. ": " .. name)
    end
end

function AD:CHALLENGE_MODE_START(event, ...)
    if not self.db.enable then return end
    self.CombinedFails = {}
    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function AD:CHAT_MSG_ADDON(event, ...)
    local prefix, message, channel, sender = select(1, ...)
    if prefix ~= self.prefix then return end
    if message == "VREQ" then
        self:SendAddonMessage("VANS;" .. AD.Version)
    elseif message:match("^VANS") then
        self.allUsers[sender] = message
        for k, v in pairs(self.allUsers) do
            if UnitIsGroupLeader(k) or self.activeUser == nil or k < self.activeUser then self.activeUser = k end
        end
    end
end

function AD:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local timestamp, eventType, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2 =
        CombatLogGetCurrentEventInfo(); -- Those arguments appear for all combat event variants.
    local eventPrefix, eventSuffix = eventType:match("^(.-)_?([^_]*)$");
    if (eventPrefix:match("^SPELL") or eventPrefix:match("^RANGE")) and eventSuffix == "DAMAGE" then
        local spellId, spellName, spellSchool, sAmount, aOverkill, sSchool, sResisted, sBlocked, sAbsorbed, sCritical,
              sGlancing, sCrushing, sOffhand, _ = select(12, CombatLogGetCurrentEventInfo())
        self:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId,
                         spellName, spellSchool, sAmount)
    elseif eventPrefix:match("^SWING") and eventSuffix == "DAMAGE" then
        local aAmount, aOverkill, aSchool, aResisted, aBlocked, aAbsorbed, aCritical, aGlancing, aCrushing, aOffhand, _ =
            select(12, CombatLogGetCurrentEventInfo())
        self:SwingDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, aAmount)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        local spellId, spellName, spellSchool, missType, isOffHand, mAmount = select(12, CombatLogGetCurrentEventInfo())
        if mAmount then
            self:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId,
                             spellName, spellSchool, mAmount)
        end
    elseif eventType == "SPELL_AURA_APPLIED" then
        local spellId, spellName, spellSchool, auraType = select(12, CombatLogGetCurrentEventInfo())
        self:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName,
                       spellSchool, auraType)
    elseif eventType == "SPELL_AURA_APPLIED_DOSE" then
        local spellId, spellName, spellSchool, auraType, auraAmount = select(12, CombatLogGetCurrentEventInfo())
        self:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName,
                       spellSchool, auraType, auraAmount)
    end
end
