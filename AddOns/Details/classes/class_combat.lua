
	local Details = 		_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	local addonName, Details222 = ...

--[[global]] DETAILS_TOTALS_ONLYGROUP = true
--[[global]] DETAILS_SEGMENTID_OVERALL = -1
--[[global]] DETAILS_SEGMENTID_CURRENT = 0

--[[global]] DETAILS_COMBAT_AMOUNT_CONTAINERS = 4

--enum segments type
--[[global]] DETAILS_SEGMENTTYPE_GENERIC = 0

--[[global]] DETAILS_SEGMENTTYPE_OVERALL = 1

--[[global]] DETAILS_SEGMENTTYPE_DUNGEON_TRASH = 5
--[[global]] DETAILS_SEGMENTTYPE_DUNGEON_BOSS = 6

--[[global]] DETAILS_SEGMENTTYPE_RAID_TRASH = 7
--[[global]] DETAILS_SEGMENTTYPE_RAID_BOSS = 8

--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON = 100
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC = 10
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH = 11
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL = 12
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL = 13
--[[global]] DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS = 14

--[[global]] DETAILS_SEGMENTTYPE_PVP_ARENA = 20
--[[global]] DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND = 21

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local ipairs = ipairs -- lua local
	local pairs = pairs -- lua local
	local bitBand = bit.band -- lua local
	local date = date -- lua local
	local tremove = table.remove -- lua local
	local rawget = rawget
	local _math_max = math.max
	local floor = math.floor
	local GetTime = GetTime

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	local classCombat 	=	Details.combate
	local classActorContainer = Details.container_combatentes
	local class_type_dano 	= Details.atributos.dano
	local class_type_cura		= Details.atributos.cura
	local class_type_e_energy 	= Details.atributos.e_energy
	local class_type_misc 	= Details.atributos.misc

	local classTypeDamage = Details.atributos.dano
	local classTypeHeal = Details.atributos.cura
	local classTypeResource = Details.atributos.e_energy
	local classTypeUtility = Details.atributos.misc

	local REACTION_HOSTILE =	0x00000040
	local CONTROL_PLAYER =		0x00000100

	--local _tempo = time()
	local _tempo = GetTime()

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--api functions

	--combat (container type, actor name)
	Details.call_combate = function(self, classType, actorName)
		local container = self[classType]
		local index_mapa = container._NameIndexTable[actorName]
		local actor = container._ActorTable[index_mapa]
		return actor
	end
	classCombat.__call = Details.call_combate

	---get the unique combat identifier
	---@param self combat
	---@return number
	function classCombat:GetCombatUID()
		return self.combat_counter
	end

	--get the start date and end date
	function classCombat:GetDate()
		return self.data_inicio, self.data_fim
	end

	--set the combat date
	function classCombat:SetDate(started, ended)
		if (started and type(started) == "string") then
			self.data_inicio = started
		end
		if (ended and type(ended) == "string") then
			self.data_fim = ended
		end
	end

	---return a table representing a chart data
	---@param name string
	---@return number[]
	function classCombat:GetTimeData(name)
		if (self.TimeData) then
			return self.TimeData[name]
		end
		return {max_value = 0}
	end

	---erase a time data if exists
	---@param name string
	function classCombat:EraseTimeData(name)
		if (self.TimeData[name]) then
			self.TimeData[name] = nil
			return true
		end
		return false
	end

	function classCombat:GetContainer(attribute)
		return self [attribute]
	end

	function classCombat:GetRoster()
		return self.raid_roster
	end

	function classCombat:InstanceType()
		return rawget(self, "instance_type")
	end

	function classCombat:IsTrash()
		return rawget(self, "is_trash")
	end

	function classCombat:GetDifficulty()
		return self.is_boss and self.is_boss.diff
	end

	function classCombat:GetEncounterCleuID()
		return self.is_boss and self.is_boss.id
	end

	function classCombat:GetBossInfo()
		return self.is_boss
	end

	function classCombat:GetPhases()
		return self.PhaseData
	end

	function classCombat:GetPvPInfo()
		return self.is_pvp
	end

	function classCombat:GetMythicDungeonInfo()
		return self.is_mythic_dungeon
	end

	function classCombat:GetMythicDungeonTrashInfo()
		return self.is_mythic_dungeon_trash
	end

	---return if the combat is a mythic dungeon segment and the run id
	---@return boolean
	---@return number
	function classCombat:IsMythicDungeon()
		local bIsMythicPlusSegment = self.is_mythic_dungeon_segment
		local runId = self.is_mythic_dungeon_run_id
		return bIsMythicPlusSegment, runId
	end

	function classCombat:IsMythicDungeonOverall()
		return self.is_mythic_dungeon and self.is_mythic_dungeon.OverallSegment
	end

	function classCombat:GetArenaInfo()
		return self.is_arena
	end

	function classCombat:GetDeaths()
		return self.last_events_tables
	end

	function classCombat:GetPlayerDeaths(deadPlayerName)
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
	end

	function classCombat:GetCombatId()
		return self.combat_id
	end

	function classCombat:GetCombatNumber()
		return self.combat_counter
	end

	function classCombat:GetAlteranatePower()
		return self.alternate_power
	end

	---return the amount of casts of a spells from an actor
	---@param self combat
	---@param actorName string
	---@param spellName string
	---@return number
	function classCombat:GetSpellCastAmount(actorName, spellName)
		return self.amountCasts[actorName] and self.amountCasts[actorName][spellName] or 0
	end

	---return the cast amount table
	---@param self combat
	---@param actorName string|nil
	---@return table
	function classCombat:GetSpellCastTable(actorName)
		if (actorName) then
			return self.amountCasts[actorName] or {}
		else
			return self.amountCasts
		end
	end

	---delete an actor from the spell casts amount
	---@param self combat
	---@param actorName string
	function classCombat:RemoveActorFromSpellCastTable(actorName)
		self.amountCasts[actorName] = nil
	end

	---return the uptime of a buff from an actor
	---@param actorName string
	---@param spellId number
	---@param auraType string|nil if nil get 'buff'
	---@return number
	function classCombat:GetSpellUptime(actorName, spellId, auraType)
		---@type actorcontainer
		local utilityContainer = self:GetContainer(DETAILS_ATTRIBUTE_MISC)
		---@type actor
		local actorObject = utilityContainer:GetActor(actorName)
		if (actorObject) then
			if (auraType) then
				---@type spellcontainer
				local buffUptimeContainer = actorObject:GetSpellContainer(auraType)
				if (buffUptimeContainer) then
					---@type spelltable
					local spellTable = buffUptimeContainer:GetSpell(spellId)
					if (spellTable) then
						return spellTable.uptime or 0
					end
				end
			else
				do --if not auraType passed, attempt to get the uptime from debuffs first, if it fails, get from buffs
					---@type spellcontainer
					local debuffContainer = actorObject:GetSpellContainer("debuff")
					if (debuffContainer) then
						---@type spelltable
						local spellTable = debuffContainer:GetSpell(spellId)
						if (spellTable) then
							return spellTable.uptime or 0
						end
					end
				end
				do
					---@type spellcontainer
					local buffContainer = actorObject:GetSpellContainer("buff")
					if (buffContainer) then
						---@type spelltable
						local spellTable = buffContainer:GetSpell(spellId)
						if (spellTable) then
							return spellTable.uptime or 0
						end
					end
				end
			end
		end
		return 0
	end

	--return the name of the encounter or enemy
	function classCombat:GetCombatName(try_find)
		if (self.is_pvp) then
			return self.is_pvp.name

		elseif (self.is_boss) then
			return self.is_boss.encounter

		elseif (self.is_mythic_dungeon_trash) then
			return self.is_mythic_dungeon_trash.ZoneName .. " (" .. Loc ["STRING_SEGMENTS_LIST_TRASH"] .. ")"

		elseif (rawget(self, "is_trash")) then
			return Loc ["STRING_SEGMENT_TRASH"]

		else
			if (self.enemy) then
				return self.enemy
			end
			if (try_find) then
				return Details:FindEnemy()
			end
		end
		return Loc ["STRING_UNKNOW"]
	end

	function classCombat:GetCombatType()
		--mythic dungeon
		local isMythicDungeon = self.is_mythic_dungeon_segment
		if (isMythicDungeon) then
			local isMythicDungeonTrash = self.is_mythic_dungeon_trash
			if (isMythicDungeonTrash) then
				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
			else
				local isMythicDungeonOverall = self.is_mythic_dungeon and self.is_mythic_dungeon.OverallSegment
				local isMythicDungeonTrashOverall = self.is_mythic_dungeon and self.is_mythic_dungeon.TrashOverallSegment
				if (isMythicDungeonOverall) then
					return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
				elseif (isMythicDungeonTrashOverall) then
					return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
				end

				local bossEncounter =  self.is_boss
				if (bossEncounter) then
					return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
				end

				return DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC, DETAILS_SEGMENTTYPE_MYTHICDUNGEON
			end
		end

		--arena
		local arenaInfo = self.is_arena
		if (arenaInfo) then
			return DETAILS_SEGMENTTYPE_PVP_ARENA
		end

		--battleground
		local battlegroundInfo = self.is_pvp
		if (battlegroundInfo) then
			return DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND
		end

		--dungeon or raid
		local instanceType = self.instance_type

		if (instanceType == "party") then
			local bossEncounter =  self.is_boss
			if (bossEncounter) then
				return DETAILS_SEGMENTTYPE_DUNGEON_BOSS
			else
				return DETAILS_SEGMENTTYPE_DUNGEON_TRASH
			end

		elseif (instanceType == "raid") then
			local bossEncounter =  self.is_boss
			if (bossEncounter) then
				return DETAILS_SEGMENTTYPE_RAID_BOSS
			else
				return DETAILS_SEGMENTTYPE_RAID_TRASH
			end
		end

		--overall data
		if (self == Details.tabela_overall) then
			return DETAILS_SEGMENTTYPE_OVERALL
		end

		return DETAILS_SEGMENTTYPE_GENERIC
	end

	--return a numeric table with all actors on the specific containter
	function classCombat:GetActorList (container)
		return self [container]._ActorTable
	end

	---return an actor object for the given container and actor name
	---@param container number
	---@param name string
	---@return actor|nil
	function classCombat:GetActor(container, name)
		local index = self[container] and self[container]._NameIndexTable[name]
		if (index) then
			return self[container]._ActorTable[index]
		end
		return nil
	end

	---return the combat time in seconds
	---@return number, number
	function classCombat:GetFormatedCombatTime()
		local combatTime = self:GetCombatTime()
		local minute, second = floor(combatTime / 60), floor(combatTime % 60)
		return minute, second
	end

	---return the amount of time the combat has elapsed
	---@return number
	function classCombat:GetCombatTime()
		if (self.end_time) then
			return _math_max (self.end_time - self.start_time, 0.1)
		elseif (self.start_time and Details.in_combat and self ~= Details.tabela_overall) then
			return _math_max (GetTime() - self.start_time, 0.1)
		else
			return 0.1
		end
	end

	function classCombat:GetStartTime()
		return self.start_time
	end
	function classCombat:SetStartTime(thisTime)
		self.start_time = thisTime
	end

	function classCombat:GetEndTime()
		return self.end_time
	end
	function classCombat:SetEndTime(thisTime)
		self.end_time = thisTime
	end

	---copy deaths from combat2 into combat1
	---if bMythicPlus is true it'll check if the death has mythic plus death time and use it instead of the normal death time
	---@param combat1 combat
	---@param combat2 combat
	---@param bMythicPlus boolean
	function classCombat.CopyDeathsFrom(combat1, combat2, bMythicPlus)
		local deathsTable = combat1:GetDeaths()
		local deathsToCopy = combat2:GetDeaths()

		for i = 1, #deathsToCopy do
			local thisDeath = DetailsFramework.table.copy({}, deathsToCopy[i])

			if (bMythicPlus and thisDeath.mythic_plus) then
				thisDeath[6] = thisDeath.mythic_plus_dead_at_string
				thisDeath.dead_at = thisDeath.mythic_plus_dead_at
			end

			deathsTable[#deathsTable+1] = thisDeath
		end
	end

	--return the total of a specific attribute
	local power_table = {0, 1, 3, 6, 0, "alternatepower"}

	function classCombat:GetTotal(attribute, subAttribute, onlyGroup)
		if (attribute == 1 or attribute == 2) then
			if (onlyGroup) then
				return self.totals_grupo [attribute]
			else
				return self.totals [attribute]
			end

		elseif (attribute == 3) then
			if (subAttribute == 5) then --resources
				return self.totals.resources or 0
			end
			if (onlyGroup) then
				return self.totals_grupo [attribute] [power_table [subAttribute]]
			else
				return self.totals [attribute] [power_table [subAttribute]]
			end

		elseif (attribute == 4) then
			local subName = Details:GetInternalSubAttributeName (attribute, subAttribute)
			if (onlyGroup) then
				return self.totals_grupo [attribute] [subName]
			else
				return self.totals [attribute] [subName]
			end
		end

		return 0
	end

	---create an alternate power table for the given actor
	---@param actorName string
	---@return alternatepowertable
	function classCombat:CreateAlternatePowerTable(actorName)
		---@type alternatepowertable
		local alternatePowerTable = {last = 0, total = 0}
		self.alternate_power[actorName] = alternatePowerTable
		return alternatePowerTable
	end

	--delete an actor from the combat ~delete ~erase ~remove
	function classCombat:DeleteActor(attribute, actorName, removeDamageTaken, cannotRemap)
		local container = self[attribute]
		if (container) then

			local actorTable = container._ActorTable

			--store the index it was found
			local indexToDelete

			--get the object for the deleted actor
			local deletedActor = self(attribute, actorName)
			if (not deletedActor) then
				return
			else
				for i = 1, #actorTable do
					local actor = actorTable[i]
					if (actor.nome == actorName) then
						--print("Details: found the actor: ", actorName, actor.nome, i)
						indexToDelete = i
						break
					end
				end
			end

			for i = 1, #actorTable do
				--is this not the actor we want to remove?
				if (i ~= indexToDelete) then

					local actor = actorTable[i]
					if (not actor.isTank) then
						--get the damage dealt and remove
						local damageDoneToRemovedActor = (actor.targets[actorName]) or 0
						actor.targets[actorName] = nil
						actor.total = actor.total - damageDoneToRemovedActor
						actor.total_without_pet = actor.total_without_pet - damageDoneToRemovedActor

						--damage taken
						if (removeDamageTaken) then
							local hadDamageTaken = actor.damage_from[actorName]
							if (hadDamageTaken) then
								--query the deleted actor to know how much damage it applied to this actor
								local damageDoneToActor = (deletedActor.targets[actor.nome]) or 0
								actor.damage_taken = actor.damage_taken - damageDoneToActor
							end
						end

						--spells
						local spellsTable = actor.spells._ActorTable
						for spellId, spellTable in pairs(spellsTable) do
							local damageDoneToRemovedActor = (spellTable.targets[actorName]) or 0
							spellTable.targets[actorName] = nil
							spellTable.total = spellTable.total - damageDoneToRemovedActor
						end
					end
				end
			end

			if (indexToDelete) then
				local actorToDelete = self(attribute, actorName)
				local actorToDelete2 = container._ActorTable[indexToDelete]

				if (actorToDelete ~= actorToDelete2) then
					Details:Msg("error 0xDE8745")
				end

				local index = container._NameIndexTable[actorName]
				if (indexToDelete ~= index) then
					Details:Msg("error 0xDE8751")
				end

				--remove actor
				tremove(container._ActorTable, index)

				--remap
				if (not cannotRemap) then
					container:Remap()
				end
				return true
			end
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internals

function classCombat:CreateNewCombatTable()
	return classCombat:NovaTabela()
end

---class constructor
---@param bTimeStarted boolean if true set the start time to now with GetTime
---@param overallCombatObject combat
---@param combatId number
---@param ... unknown
---@return combat
function classCombat:NovaTabela(bTimeStarted, overallCombatObject, combatId, ...) --~init
	---@type combat
	local combatObject = {}

	combatObject[1] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_DAMAGE_CLASS,	combatObject, combatId) --Damage
	combatObject[2] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_HEAL_CLASS,	combatObject, combatId) --Healing
	combatObject[3] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_ENERGY_CLASS,	combatObject, combatId) --Energies
	combatObject[4] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_MISC_CLASS,	combatObject, combatId) --Misc
	combatObject[5] = classActorContainer:NovoContainer(Details.container_type.CONTAINER_DAMAGE_CLASS,	combatObject, combatId) --place holder for customs

	setmetatable(combatObject, classCombat)

	Details.combat_counter = Details.combat_counter + 1
	combatObject.combat_counter = Details.combat_counter

	--try discover if is a pvp combat
	local who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags = ...
	if (who_serial) then --aqui ir� identificar o boss ou o oponente
		if (alvo_name and bitBand (alvo_flags, REACTION_HOSTILE) ~= 0) then --tentando pegar o inimigo pelo alvo
			combatObject.contra = alvo_name
			if (bitBand (alvo_flags, CONTROL_PLAYER) ~= 0) then
				combatObject.pvp = true --o alvo � da fac��o oposta ou foi dado mind control
			end
		elseif (who_name and bitBand (who_flags, REACTION_HOSTILE) ~= 0) then --tentando pegar o inimigo pelo who caso o mob � quem deu o primeiro hit
			combatObject.contra = who_name
			if (bitBand (who_flags, CONTROL_PLAYER) ~= 0) then
				combatObject.pvp = true --o who � da fac��o oposta ou foi dado mind control
			end
		else
			combatObject.pvp = true --se ambos s�o friendly, seria isso um PVP entre jogadores da mesma fac��o?
		end
	end

	--start/end time (duration)
	combatObject.data_fim = 0
	combatObject.data_inicio = 0
	combatObject.tempo_start = _tempo

	combatObject.bossTimers = {}

	---store trinket procs
	combatObject.trinketProcs = {}

	---store the amount of casts of each player
	---@type table<actorname, table<spellname, number>>
	combatObject.amountCasts = {}

	--record deaths
	combatObject.last_events_tables = {}

	--last events from players
	combatObject.player_last_events = {}

	--players in the raid
	combatObject.raid_roster = {}
	combatObject.raid_roster_indexed = {}

	--frags
	combatObject.frags = {}
	combatObject.frags_need_refresh = false

	--alternate power
	combatObject.alternate_power = {}

	--time data container
	combatObject.TimeData = Details:TimeDataCreateChartTables()
	combatObject.PhaseData = {{1, 1}, damage = {}, heal = {}, damage_section = {}, heal_section = {}} --[1] phase number [2] phase started

	--for external plugin usage, these tables are guaranteed to be saved with the combat
	combatObject.spells_cast_timeline = {}
	combatObject.aura_timeline = {}
	combatObject.cleu_timeline = {}

	--cleu events
	combatObject.cleu_events = {
		n = 1 --event counter
	}

	--a tabela sem o tempo de inicio � a tabela descartavel do inicio do addon
	if (bTimeStarted) then
		--esta_tabela.start_time = _tempo
		combatObject.start_time = GetTime()
		combatObject.end_time = nil
	else
		combatObject.start_time = 0
		combatObject.end_time = nil
	end

	-- o container ir� armazenar as classes de dano -- cria um novo container de indexes de seriais de jogadores --par�metro 1 classe armazenada no container, par�metro 2 = flag da classe
	combatObject[1].need_refresh = true
	combatObject[2].need_refresh = true
	combatObject[3].need_refresh = true
	combatObject[4].need_refresh = true
	combatObject[5].need_refresh = true

	combatObject.totals = {
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
	}

	combatObject.totals_grupo = {
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
	}

	return combatObject
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	---create the table which will contain the latest events of the player while alive
	---@param self combat
	---@param playerName string
	---@return table
	function classCombat:CreateLastEventsTable(playerName)
		local lastEventsTable = {}

		for i = 1, Details.deadlog_events do
			lastEventsTable[i] = {}
		end

		lastEventsTable.n = 1
		self.player_last_events[playerName] = lastEventsTable
		return lastEventsTable
	end

	---pass through all actors and check if the activity time is unlocked, if it is, lock it
	---@param self combat
	function classCombat:LockActivityTime()
		---@cast self combat
		---@type actorcontainer
		local containerDamage = self:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		---@type actorcontainer
		local containerHeal = self:GetContainer(DETAILS_ATTRIBUTE_HEAL)

		for _, actorObject in containerDamage:ListActors() do
			if (actorObject:GetOrChangeActivityStatus()) then --check if the timer is unlocked
				Details222.TimeMachine.StopTime(actorObject)
				actorObject:GetOrChangeActivityStatus(false) --lock the actor timer
			else
				if (actorObject.start_time == 0) then
					actorObject.start_time = _tempo
				end
				if (not actorObject.end_time) then
					actorObject.end_time = _tempo
				end
			end
		end

		for _, actorObject in containerHeal:ListActors() do
			--check if the timer is unlocked
			if (actorObject:GetOrChangeActivityStatus()) then
				--lock the actor timer
				Details222.TimeMachine.StopTime(actorObject)
				--remove the actor from the time machine
				actorObject:GetOrChangeActivityStatus(false)
			else
				if (actorObject.start_time == 0) then
					actorObject.start_time = _tempo
				end
				if (not actorObject.end_time) then
					actorObject.end_time = _tempo
				end
			end
		end
	end

	function classCombat:seta_data(tipo)
		if (tipo == Details._detalhes_props.DATA_TYPE_START) then
			self.data_inicio = date("%H:%M:%S")
		elseif (tipo == Details._detalhes_props.DATA_TYPE_END) then
			self.data_fim = date("%H:%M:%S")
		end
	end

	function classCombat:seta_tempo_decorrido()
		--self.end_time = _tempo
		self.end_time = GetTime()
	end

	---set combat metatable and class lookup
	---@self any
	---@param combatObject combat
	function Details.refresh:r_combate(combatObject)
		setmetatable(combatObject, Details.combate)
		combatObject.__index = Details.combate
	end

	---clear combat object
	---@self any
	---@param combatObject combat
	function Details.clear:c_combate(combatObject)
		combatObject.__index = nil
		combatObject.__call = nil
	end

	classCombat.__sub = function(combate1, combate2)

		if (combate1 ~= Details.tabela_overall) then
			return
		end

		--sub dano
			for index, actor_T2 in ipairs(combate2[1]._ActorTable) do
				local actor_T1 = combate1[1]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [1].need_refresh = true

		--sub heal
			for index, actor_T2 in ipairs(combate2[2]._ActorTable) do
				local actor_T1 = combate1[2]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [2].need_refresh = true

		--sub energy
			for index, actor_T2 in ipairs(combate2[3]._ActorTable) do
				local actor_T1 = combate1[3]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [3].need_refresh = true

		--sub misc
			for index, actor_T2 in ipairs(combate2[4]._ActorTable) do
				local actor_T1 = combate1[4]:PegarCombatente (actor_T2.serial, actor_T2.nome, actor_T2.flag_original, true)
				actor_T1 = actor_T1 - actor_T2
				actor_T2:subtract_total (combate1)
			end
			combate1 [4].need_refresh = true

		--reduz o tempo
			combate1.start_time = combate1.start_time + combate2:GetCombatTime()

		--apaga as mortes da luta diminuida
			local amt_mortes =  #combate2.last_events_tables --quantas mortes teve nessa luta
			if (amt_mortes > 0) then
				for i = #combate1.last_events_tables, #combate1.last_events_tables-amt_mortes, -1 do
					tremove(combate1.last_events_tables, #combate1.last_events_tables)
				end
			end

		--frags
			for fragName, fragAmount in pairs(combate2.frags) do
				if (fragAmount) then
					if (combate1.frags [fragName]) then
						combate1.frags [fragName] = combate1.frags [fragName] - fragAmount
					else
						combate1.frags [fragName] = fragAmount
					end
				end
			end
			combate1.frags_need_refresh = true

		--alternate power
			local overallPowerTable = combate1.alternate_power
			for actorName, powerTable in pairs(combate2.alternate_power) do
				local power = overallPowerTable [actorName]
				if (power) then
					power.total = power.total - powerTable.total
				end
				combate2.alternate_power [actorName].last = 0
			end

		return combate1

	end

	---add combatToAdd into combatRecevingTheSum
	---@param combatRecevingTheSum combat
	---@param combatToAdd combat
	---@return combat
	classCombat.__add = function(combatRecevingTheSum, combatToAdd)
		---@type combat
		local customCombat
		if (combatRecevingTheSum ~= Details.tabela_overall) then
			customCombat = combatRecevingTheSum
		end

		local bRefreshActor = false

		for classType = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
			local actorContainer = combatToAdd[classType]
			local actorTable = actorContainer._ActorTable
			for _, actorObject in ipairs(actorTable) do
				---@cast actorObject actor
				---@type actor
				local actorCreatedInTheReceivingCombat

				if (classType == classTypeDamage) then
					actorCreatedInTheReceivingCombat = Details.atributo_damage:AddToCombat(actorObject, bRefreshActor, customCombat)

				elseif (classType == classTypeHeal) then
					actorCreatedInTheReceivingCombat = Details.atributo_heal:AddToCombat(actorObject, bRefreshActor, customCombat)

				elseif (classType == classTypeResource) then
					actorCreatedInTheReceivingCombat = Details.atributo_energy:r_connect_shadow(actorObject, true, customCombat)

				elseif (classType == classTypeUtility) then
					actorCreatedInTheReceivingCombat = Details.atributo_misc:r_connect_shadow(actorObject, true, customCombat)
				end

				actorCreatedInTheReceivingCombat.boss_fight_component = actorObject.boss_fight_component or actorCreatedInTheReceivingCombat.boss_fight_component
				actorCreatedInTheReceivingCombat.fight_component = actorObject.fight_component or actorCreatedInTheReceivingCombat.fight_component
				actorCreatedInTheReceivingCombat.grupo = actorObject.grupo or actorCreatedInTheReceivingCombat.grupo
			end
		end

		--alternate power
		local overallPowerTable = combatRecevingTheSum.alternate_power
		for actorName, powerTable in pairs(combatToAdd.alternate_power) do
			local alternatePowerTable = overallPowerTable[actorName]
			if (not alternatePowerTable) then
				alternatePowerTable = combatRecevingTheSum:CreateAlternatePowerTable(actorName)
			end
			alternatePowerTable.total = alternatePowerTable.total + powerTable.total
			combatToAdd.alternate_power[actorName].last = 0
		end

		--cast amount
		local combat1CastData = combatRecevingTheSum.amountCasts
		for actorName, castData in pairs(combatToAdd.amountCasts) do
			local playerCastTable = combat1CastData[actorName]
			if (not playerCastTable) then
				playerCastTable = {}
				combat1CastData[actorName] = playerCastTable
			end
			for spellName, amountOfCasts in pairs(castData) do
				local spellAmount = playerCastTable[spellName]
				if (not spellAmount) then
					spellAmount = 0
					playerCastTable[spellName] = spellAmount
				end
				playerCastTable[spellName] = spellAmount + amountOfCasts
			end
		end

		return combatRecevingTheSum
	end

	function Details:UpdateCombat()
		_tempo = Details._tempo
	end
