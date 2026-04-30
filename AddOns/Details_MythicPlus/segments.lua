
local Details = Details
local _

---@type string, private
local tocFileName, private = ...
local addon = private.addon

---@type detailsframework
local detailsFramework = DetailsFramework

private.Segments = {
    serverTicker = nil,

    IsServerInCombat = function()
        --test 1
        local combat1 = C_DamageMeter.GetCombatSessionFromType(0, 0)
        assert(combat1, "Failed to get combat session for type 0, 0")
        local maxValue = combat1.maxValue
        if issecretvalue(maxValue) then
            return true
        end
        if (combat1.combatSources and combat1.combatSources[1] and issecretvalue(combat1.combatSources[1].totalAmount)) then
            return true
        end

        --test 2
        local combat2 = C_DamageMeter.GetCombatSessionFromType(1, 0)
        assert(combat2, "Failed to get combat session for type 1, 0")
        maxValue = combat2.maxValue
        if issecretvalue(maxValue) then
            return true
        end
        if (combat2.combatSources and combat2.combatSources[1] and issecretvalue(combat2.combatSources[1].totalAmount)) then
            return true
        end

        return false
    end,

    WaitServerDropCombat = function()
        if not private.Segments.serverTicker then
            private.Segments.serverTicker = C_Timer.NewTicker(0.1, function()
                if not private.Segments.IsServerInCombat() then
                    private.Segments.serverTicker:Cancel()
                    private.Segments.serverTicker = nil
                    private.Segments.CreateOBFS()
                end
            end)
        end
    end,

    GetAllCombatTypes = function()
        local result = {}
        for i = 0, 10 do
            local segment = C_DamageMeter.GetCombatSessionFromType(0, i)
            if segment then
                result[#result + 1] = segment
            end
        end
        return result
    end,

    ---usage: local hasRecap, events, maxHealth, link = Details222.Recap.GetRecapInfo(12345)
    ---@param id number
    ---@return boolean
    ---@return deathrecapeventinfo[]
    ---@return number
    ---@return string
    GetRecapInfo = function(id)
        local dr = C_DeathRecap
        local hasDeathRecap = dr.HasRecapEvents(id)
        if hasDeathRecap then
            local thisRecap = dr.GetRecapEvents(id)
            local maxHealth = dr.GetRecapMaxHealth(id)
            return true, thisRecap, maxHealth, dr.GetRecapLink(id)
        end
        return false
    end,

    UnpackDeathEvent = function(deathEvent)
		local evType = deathEvent[1]
		local spellId = deathEvent[2]
		local amount = deathEvent[3] --amount of damage or heal
		local eventTime = deathEvent[4] --time()
		local heathPercent = deathEvent[5]
		local sourceName = deathEvent[6]
		local absorbed = deathEvent[7]
		local spellSchool = deathEvent[8]
		local friendlyFire = deathEvent[9]
		local overkill = deathEvent[10] --amount of damage overkill, -1 if the hit did not killed the target
		local criticalHit = deathEvent[11]
		local crushing = deathEvent[12]

		return evType, spellId, amount, eventTime, heathPercent, sourceName, absorbed, spellSchool, friendlyFire, overkill, criticalHit, crushing
	end,

    UnpackDeathTable = function(deathTable)
        local deathEvents = deathTable[1]
        local deathTime = deathTable[2]
        local playerName = deathTable[3]
        local playerClass = deathTable[4]
        local playerMaxHealth = deathTable[5]
        local deathTimeString = deathTable[6]
        local lastCooldown = deathTable.last_cooldown
        local deathCombatTime = deathTable.dead_at
        local spec = deathTable.spec

        return playerName, playerClass, deathTime, deathCombatTime, deathTimeString, playerMaxHealth, deathEvents, lastCooldown, spec
    end,

	CreateDeathLogTable = function(actorName, actorClass, specIcon, deathRecap, maxHealth)
		local firstEvent = deathRecap[1] or {timestamp = time()}
		local timeOfDeath = firstEvent.timestamp
		local minutes, seconds = floor(timeOfDeath/60), floor(timeOfDeath%60)
		local deathTimeString = minutes .. "m " .. seconds .. "s"
		local deathEvents = {}

        local specInfo = detailsFramework:GetSpecInfoFromSpecIcon(specIcon)
        if not specInfo then
            if specIcon == 7455386 then
                specInfo = detailsFramework:GetSpecInfoFromSpecIcon(7455385)
            elseif specIcon == 7455385 then
                specInfo = detailsFramework:GetSpecInfoFromSpecIcon(7455386)
            end
        end

		local deathLog = {
			deathEvents, --1
			firstEvent.timestamp, --2
			actorName, --3
			actorClass, --4
			maxHealth, --5
			deathTimeString, --6
			["dead"] = true,
			["last_cooldown"] = nil,
			["dead_at"] = timeOfDeath,
			["spec"] = specInfo and specInfo.specId or nil,
		}

		for i = 1, #deathRecap do
			local deathEvent = deathRecap[i]
			deathEvents[#deathEvents+1] = {
				deathEvent.event, --evType
				deathEvent.spellId, --spellId
				deathEvent.amount, --amount
				deathEvent.timestamp, --eventTime
				deathEvent.currentHP / maxHealth, --heathPercent
				deathEvent.sourceName, --sourceName
				deathEvent.absorbed, --absorbed
				deathEvent.spellSchool, --spellSchool
				0, --deathEvent.friendlyFire, --friendlyFire
				deathEvent.overkill, --overkill
				deathEvent.critical, --criticalHit
				deathEvent.crushing --crushing
			}
		end

		return deathLog
	end,

    CreateDetailsCombat = function()
        local container = {
			tipo = 1,
			combatId = 1,
			---@type actor[]
			_ActorTable = {},
			---@type table<string, number>
			_NameIndexTable = {}, --points to the index in the _ActorTable

            ListActors = function(self)
                return ipairs(self._ActorTable)
            end,

            GetSpellList = function(self)
                return self.spells._ActorTable
            end,

            GetOrCreateActor = function(self, actorSerial, actorName, actorFlags, isPlayer, tempo) --ãctor ~actor
                local alreadyExistsActorIndex = self._NameIndexTable[actorName]
                if alreadyExistsActorIndex then
                    return self._ActorTable[alreadyExistsActorIndex]
                end

                if not actorSerial then
                    return
                end

                local actor = {
                    damage_from = {},
                    tempo = tempo,
                }

                self._ActorTable[#self._ActorTable + 1] = actor
                self._NameIndexTable[actorName] = #self._ActorTable
                actor.IsPlayer = function()
                    return true
                end
                actor.Name = function()
                    return actorName
                end
                actor.GetGUID = function()
                    return actorSerial
                end
                actor.Spec = function()
                    return actor.spec
                end
                actor.Tempo = function()
                    -- there is inline combat calcs in Details!, here it just return the combat time
                    return actor.tempo
                end
                actor.Class = function()
                    return actor.classe
                end
                actor.GetActorSpells = function()
                    return actor.spells._ActorTable
                end
                actor.spells = {
                    GetOrCreateSpell = function(spellContainer, spellId)
                        local spell = {
                            targets = {},
                        }
                        spell.id = spellId or 1
                        spellContainer._ActorTable[spellId or 1] = spell
                        return spell
                    end,
                    _ActorTable = {},
                }
                actor.spells_damage_avoidable = {
                    GetOrCreateSpell = function(spellContainer, spellId)
                        local spell = {
                            targets = {},
                        }
                        spell.id = spellId or 1
                        spellContainer._ActorTable[spellId or 1] = spell
                        return spell
                    end,
                    _ActorTable = {},
                }
                actor.interrupt_spells = {
                    GetOrCreateSpell = function(spellContainer, spellId)
                        local spell = {
                            targets = {},
                        }
                        spell.id = spellId or 1
                        spellContainer._ActorTable[spellId or 1] = spell
                        return spell
                    end,
                    _ActorTable = {},
                }
                actor.dispell_spells = {
                    GetOrCreateSpell = function(spellContainer, spellId)
                        local spell = {
                            targets = {},
                        }
                        spell.id = spellId or 1
                        spellContainer._ActorTable[spellId or 1] = spell
                        return spell
                    end,
                    _ActorTable = {},
                }

                return actor
            end
        }

        local zoneName, instanceType, _, _, _, _, _, zoneMapID = GetInstanceInfo()

        local newCombat = { --~combat
            GetContainer = function(self, i)
                return self[i]
            end,

            GetCombatTime = function(self)
                return self.combatTime
            end,

            GetCombatUID = function(self)
                return self.combatId
            end,

            --[[
            GetPlayerDeaths = function(self, unitName)
                local deaths = 0
                for i = 1, #self.last_events_tables do
                    local deathLog = self.last_events_tables[i]
                    if deathLog.name == unitName then
                        deaths = deaths + 1
                    end
                end
                return deaths
            end,
            --]]

            GetPlayerDeaths = function(self, deadPlayerName)
                local allDeaths = self:GetDeaths()
                local deaths = {}

                for i = 1, #allDeaths do
                    local thisDeath = allDeaths[i]
                    local thisPlayerName = thisDeath[3]
                    if (deadPlayerName == thisPlayerName) then
                        deaths[#deaths+1] = thisDeath
                    end
                end

                return deaths
            end,

            GetDeaths = function(self)
                return self.last_events_tables
            end,

            detailsFramework.table.copy({}, container),
            detailsFramework.table.copy({}, container),
            detailsFramework.table.copy({}, container),
            detailsFramework.table.copy({}, container),
            combat_counter = 1,

            GetDamageTakenBySpells = function(self, unitName)
                ---@type actordamage?
                local actor = self:GetContainer(1):GetOrCreateActor(nil, unitName)
                if (not actor) then
                    return {}
                end

                ---@type spell_hit_player[]
                local spellsThatHitThisPlayer = {}

                for damagerName in pairs (actor.damage_from) do
                    local damagerObject = self:GetContainer(1):GetActor(damagerName)
                    if (damagerObject) then
                        for spellId, spellTable in pairs(damagerObject:GetSpellList()) do
                            if (spellTable.targets and spellTable.targets[actor:Name()]) then
                                local amount = spellTable.targets[actor:Name()]
                                if (amount > 0) then
                                    ---@type spell_hit_player
                                    local spellThatHitThePlayer = {
                                        spellId = spellId,
                                        amount = amount,
                                        damagerName = damagerObject:Name(),
                                    }
                                    spellsThatHitThisPlayer[#spellsThatHitThisPlayer+1] = spellThatHitThePlayer
                                end
                            end
                        end
                    end
                end

                table.sort(spellsThatHitThisPlayer, function(t1, t2) return t1.amount > t2.amount end)

                return spellsThatHitThisPlayer
            end,

            --start/end time (duration)
            data_fim = 0,
            data_inicio = 0,
            tempo_start = time(),
            compressed_charts = {},
            boss_hp = 1,
            bossTimers = {},
            trinketProcs = {},
            ---@type table<actorname, string>
            playerTalents = {},
            ---@type table<actorname, table<spellname, number>>
            amountCasts = {},
            last_events_tables = {},
            player_last_events = {},
            raid_roster = {},
            frags = {},
            frags_need_refresh = false,
            alternate_power = {},
            TimeData = {},
            PhaseData = {{1, 1}, damage = {}, heal = {}, damage_section = {}, heal_section = {}}, --[1] phase number [2] phase started
            spells_cast_timeline = {},
            aura_timeline = {},
            cleu_timeline = {},
            cleu_events = {
                n = 1 --event counter
            },
            totals = {
                0, --dano
                0, --cura
                {--e_energy
                    [0] = 0, --mana
                    [1] = 0, --rage
                    [3] = 0, --energy (rogues cat)
                    [6] = 0, --runepower (dk)
                    alternatepower = 0,
                },
                {--misc
                    cc_break = 0, --armazena quantas quebras de CC
                    ress = 0, --armazena quantos pessoas ele reviveu
                    interrupt = 0, --armazena quantos interrupt a pessoa deu
                    dispell = 0, --armazena quantos dispell esta pessoa recebeu
                    dead = 0, --armazena quantas vezes essa pessia morreu
                    cooldowns_defensive = 0, --armazena quantos cooldowns a raid usou
                    buff_uptime = 0, --armazena quantos cooldowns a raid usou
                    debuff_uptime = 0 --armazena quantos cooldowns a raid usou
                },

                --avoid using this values bellow, they aren't updated by the parser, only on demand by a user interaction.
                    voidzone_damage = 0,
                    frags_total = 0,
                --end
            },
            totals_grupo = {
                0, --dano
                0, --cura
                {--e_energy
                    [0] = 0, --mana
                    [1] = 0, --rage
                    [3] = 0, --energy (rogues cat)
                    [6] = 0, --runepower (dk)
                    alternatepower = 0,
                },
                {--misc
                    cc_break = 0, --armazena quantas quebras de CC
                    ress = 0, --armazena quantos pessoas ele reviveu
                    interrupt = 0, --armazena quantos interrupt a pessoa deu
                    dispell = 0, --armazena quantos dispell esta pessoa recebeu
                    dead = 0, --armazena quantas vezes essa oessia morreu
                    cooldowns_defensive = 0, --armazena quantos cooldowns a raid usou
                    buff_uptime = 0,
                    debuff_uptime = 0
                }
            },
            zoneName = zoneName,
            mapId = zoneMapID,
            instance_type = instanceType,
            is_challenge = true,
        }

        return newCombat
    end,

    GetCombatActors = function(combat)
        return combat.combatSources
    end,

    GetActorSpells = function(damageMeterType, sourceGUID) --~spell ~spells
        local result = C_DamageMeter.GetCombatSessionSourceFromType(0, damageMeterType, sourceGUID)
        return result
    end,

    CreateOBFS = function()
        ---@type combat
        local currentCombat = private.Segments.CreateDetailsCombat()
        local segments = private.Segments.GetAllCombatTypes()
        local damageContainer, healingContainer, utilityContainer
        local tempo = segments[1].durationSeconds
        currentCombat.combatTime = tempo
        currentCombat.combatId = math.random(10000, 500000)

        do
            local damageActorList = private.Segments.GetCombatActors(segments[1])
            damageContainer = currentCombat:GetContainer(1)
            healingContainer = currentCombat:GetContainer(2)
            utilityContainer = currentCombat:GetContainer(4)

            for i = 1, #damageActorList do
                local thisActor = damageActorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    local actorName = thisActor.name
                    local actorSerial = thisActor.sourceGUID
                    local totalAmount = thisActor.totalAmount
                    local class = thisActor.classFilename
                    local icon = thisActor.specIconID

                    local actor = damageContainer:GetOrCreateActor(actorSerial, actorName, 0x512, true, tempo)
                    actor.nome = actorName
                    actor.total = totalAmount
                    actor.classe = class
                    actor.last_dps = thisActor.amountPerSecond
                    actor.specIcon = icon
                    actor.serial = actorSerial
                    actor.grupo = true
                    local specInfo = detailsFramework:GetSpecInfoFromSpecIcon(thisActor.specIconID)
                    actor.spec = specInfo and specInfo.specId or 0

                    currentCombat.totals[1] = currentCombat.totals[1] + totalAmount
                    currentCombat.totals_grupo[1] = currentCombat.totals_grupo[1] + totalAmount

                    --spells
                    local spells = private.Segments.GetActorSpells(Enum.DamageMeterType.DamageDone, thisActor.sourceGUID)
                    for j = 1, #spells.combatSpells do
                        local thisSpell = spells.combatSpells[j]
                        local spellTable = actor.spells:GetOrCreateSpell(thisSpell.spellID)
                        spellTable.total = thisSpell.totalAmount
                        spellTable.id = thisSpell.spellID
                        spellTable.counter = 1
                    end
                end
            end
        end

        do
            local actorList = segments[8].combatSources
            for i = 1, #actorList do
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    local actor = damageContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)
                    actor.nome = thisActor.name
                    actor.damage_taken = thisActor.totalAmount
                    actor.damage_taken_ps = thisActor.amountPerSecond
                    actor.classe = thisActor.classFilename
                    actor.last_dps = actor.last_dps
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true

                    --actor damage taken to fill actor.damage_from
                end
            end
        end

        do
            local actorList = segments[9].combatSources --avoidable damage taken
            for i = 1, #actorList do
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    local actor = damageContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)
                    actor.nome = thisActor.name
                    actor.damage_taken_avoidable = thisActor.totalAmount
                    actor.damage_taken_ps_avoidable = thisActor.amountPerSecond
                    actor.classe = thisActor.classFilename
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true

                    --spells
                    local spells = private.Segments.GetActorSpells(Enum.DamageMeterType.AvoidableDamageTaken, thisActor.sourceGUID)
                    for j = 1, #spells.combatSpells do
                        local thisSpell = spells.combatSpells[j]
                        local spellTable = actor.spells_damage_avoidable:GetOrCreateSpell(thisSpell.spellID)
                        spellTable.total = thisSpell.totalAmount
                        spellTable.id = thisSpell.spellID
                        spellTable.counter = 1
                    end
                end
            end
        end

        do
            local actorList = segments[3].combatSources
            for i = 1, #actorList do
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    local actor = healingContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)
                    actor.nome = thisActor.name
                    actor.total = thisActor.totalAmount
                    actor.classe = thisActor.classFilename
                    actor.last_hps = thisActor.amountPerSecond
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true

                    currentCombat.totals[2] = currentCombat.totals[2] + thisActor.totalAmount
                    currentCombat.totals_grupo[2] = currentCombat.totals_grupo[2] + thisActor.totalAmount

                    --spells
                    local spells = private.Segments.GetActorSpells(Enum.DamageMeterType.HealingDone, thisActor.sourceGUID)
                    for j = 1, #spells.combatSpells do
                        local thisSpell = spells.combatSpells[j]
                        local spellTable = actor.spells:GetOrCreateSpell(thisSpell.spellID)
                        spellTable.total = thisSpell.totalAmount
                        spellTable.id = thisSpell.spellID
                        spellTable.counter = 1
                    end
                end
            end
        end

        do
            local actorList = segments[5].combatSources
            for i = 1, #actorList do
                ---@type damagemeter_combat_source
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    ---@type actorheal
                    local actor = healingContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)

                    actor.nome = thisActor.name
                    actor.totalabsorb = thisActor.totalAmount
                    actor.totalabsorb_ps = thisActor.amountPerSecond
                    actor.classe = thisActor.classFilename
                    actor.last_hps = actor.last_hps
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true
                end
            end
        end

        do
            local actorList = segments[6].combatSources
            for i = 1, #actorList do
                ---@type damagemeter_combat_source
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    ---@type actorutility
                    local actor = utilityContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)

                    actor.interrupt_cast_overlap = 0
                    actor.interrupt_targets = {}
                    actor.interrompeu_oque = {}

                    actor.nome = thisActor.name
                    actor.interrupt = thisActor.totalAmount
                    actor.classe = thisActor.classFilename
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true

                    currentCombat.totals[4].interrupt = currentCombat.totals[4].interrupt + 1
                    currentCombat.totals_grupo[4].interrupt = currentCombat.totals_grupo[4].interrupt + 1

                    --spells
                    local spells = private.Segments.GetActorSpells(Enum.DamageMeterType.Interrupts, thisActor.sourceGUID)
                    for j = 1, #spells.combatSpells do
                        local thisSpell = spells.combatSpells[j]
                        local spellTable = actor.interrupt_spells:GetOrCreateSpell(thisSpell.spellID)
                        spellTable.total = thisSpell.totalAmount
                        spellTable.id = thisSpell.spellID
                        spellTable.counter = 1
                    end
                end
            end
        end

        do
            local actorList = segments[7].combatSources
            for i = 1, #actorList do
                ---@type damagemeter_combat_source
                local thisActor = actorList[i]
                if thisActor.sourceGUID and thisActor.specIconID then
                    ---@type actorutility
                    local actor = utilityContainer:GetOrCreateActor(thisActor.sourceGUID, thisActor.name, 0x512, true, tempo)
                    actor.dispell_targets = {}
                    actor.dispell_oque = {}

                    actor.nome = thisActor.name
                    actor.dispell = thisActor.totalAmount
                    actor.classe = thisActor.classFilename
                    actor.specIcon = thisActor.specIconID
                    actor.serial = thisActor.sourceGUID
                    actor.grupo = true

                    currentCombat.totals[4].dispell = currentCombat.totals[4].dispell + 1
                    currentCombat.totals_grupo[4].dispell = currentCombat.totals_grupo[4].dispell + 1

                    --spells
                    local spells = private.Segments.GetActorSpells(Enum.DamageMeterType.Dispels, thisActor.sourceGUID)
                    for j = 1, #spells.combatSpells do
                        local thisSpell = spells.combatSpells[j]
                        local spellTable = actor.dispell_spells:GetOrCreateSpell(thisSpell.spellID)
                        spellTable.total = thisSpell.totalAmount
                        spellTable.id = thisSpell.spellID
                        spellTable.counter = 1
                    end
                end
            end
        end

        do
            local actorList = segments[10].combatSources
            for i = 1, #actorList do
                ---@type damagemeter_combat_source
                local thisActor = actorList[i]
                local hasDeathRecap, events, maxHealth, link = private.Segments.GetRecapInfo(thisActor.deathRecapID)
                if hasDeathRecap then
                    local deathLog = private.Segments.CreateDeathLogTable(thisActor.name, thisActor.classFilename, thisActor.specIconID, events, maxHealth)
                    table.insert(currentCombat.last_events_tables, #currentCombat.last_events_tables+1, deathLog)
                end
            end
        end

        --tempo

        --currentCombat:SetDate(session.startDate, session.endDate)
        --currentCombat:SetStartTime(session.startTime)
        --currentCombat:SetEndTime(session.endTime)

        --here, need to call something to copy the segment
        addon.ApocalypseSegmentCreated(currentCombat)
    end
}



