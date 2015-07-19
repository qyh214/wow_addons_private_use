 GladiatorlosSA = LibStub("AceAddon-3.0"):NewAddon("GladiatorlosSA", "AceEvent-3.0","AceConsole-3.0","AceTimer-3.0")

 local AceConfigDialog = LibStub("AceConfigDialog-3.0")
 local AceConfig = LibStub("AceConfig-3.0")
 local L = LibStub("AceLocale-3.0"):GetLocale("GladiatorlosSA")
 local LSM = LibStub("LibSharedMedia-3.0")
 local self, GSA, PlaySoundFile = GladiatorlosSA, GladiatorlosSA, PlaySoundFile
 local GSA_TEXT = "GladiatorlosSA"
 local GSA_VERSION = " v2.1"
 local gsadb
 local soundz,sourcetype,sourceuid,desttype,destuid = {},{},{},{},{}

 local LSM_GSA_SOUNDFILES = {
	["GSA-Demo"] = "Interface\\AddOns\\GladiatorlosSA\\Voice_Custom\\Will-Demo.ogg",
 }

 local GSA_LOCALEPATH = {
	enUS = "GladiatorlosSA\\Voice_enUS",
 }
 self.GSA_LOCALEPATH = GSA_LOCALEPATH

 local GSA_LANGUAGE = {
	["GladiatorlosSA\\Voice_enUS"] = L["English(female)"],
 }
 self.GSA_LANGUAGE = GSA_LANGUAGE

 local GSA_EVENT = {
	SPELL_CAST_SUCCESS = L["Spell cast success"],
	SPELL_CAST_START = L["Spell cast start"],
	SPELL_AURA_APPLIED = L["Spell aura applied"],
	SPELL_AURA_REMOVED = L["Spell aura removed"],
	SPELL_INTERRUPT = L["Spell interrupt"],
	SPELL_SUMMON = L["Spell summon"]
	--UNIT_AURA = "Unit aura changed",
 }
 self.GSA_EVENT = GSA_EVENT

 local GSA_UNIT = {
	any = L["Any"],
	player = L["Player"],
	target = L["Target"],
	focus = L["Focus"],
	mouseover = L["Mouseover"],
	--party = L["Party"],
	--raid = L["Raid"],
	--arena = L["Arena"],
	--boss = L["Boss"],
	custom = L["Custom"], 
 }
 self.GSA_UNIT = GSA_UNIT

 local GSA_TYPE = {
	[COMBATLOG_FILTER_EVERYTHING] = L["Any"],
	[COMBATLOG_FILTER_FRIENDLY_UNITS] = L["Friendly"],
	[COMBATLOG_FILTER_HOSTILE_PLAYERS] = L["Hostile player"],
	[COMBATLOG_FILTER_HOSTILE_UNITS] = L["Hostile unit"],
	[COMBATLOG_FILTER_NEUTRAL_UNITS] = L["Neutral"],
	[COMBATLOG_FILTER_ME] = L["Myself"],
	[COMBATLOG_FILTER_MINE] = L["Mine"],
	[COMBATLOG_FILTER_MY_PET] = L["My pet"],
	[COMBATLOG_FILTER_UNKNOWN_UNITS] = "Unknow unit",
 }
 self.GSA_TYPE = GSA_TYPE

--local sourcetype,sourceuid,desttype,destuid = {},{},{},{}
--local gsadb
--local PlaySoundFile = PlaySoundFile
 local dbDefaults = {
	profile = {
		all = false,
		arena = true,
		battleground = true,
		field = true,
		path = GSA_LOCALEPATH[GetLocale()] or "GladiatorlosSA\\Voice_enUS",
		path_male = GSA_LOCALEPATH[GetLocale()] or "GladiatorlosSA\\Voice_enUS", -- added to 2.3
		path_neutral = GSA_LOCALEPATH[GetLocale()] or "GladiatorlosSA\\Voice_enUS", -- added to 2.3
		path_menu = GSA_LOCALEPATH[GetLocale()] or "GladiatorlosSA\\Voice_enUS", -- added to 2.3
		throttle = 0,
		smartDisable = false,
		outputUnlock = false,
		output_menu = "MASTER",
		
		aruaApplied = false,
		aruaRemoved = false,
		castStart = false,
		castSuccess = false,
		interrupt = false,

		aonlyTF = false,
		conlyTF= false,
		sonlyTF = false,
		ronlyTF = false,
		drinking = true,
		class = false,

		archangel = false,
		freezingTrap = false,
		battlestance = false,
		defensestance = false,
		chakraChastise = false,
		chakraSanctuary = false,
		chakraSerenity = false,
		entanglingRoots = false,
		massDispell = false,
		waterShield = false,
		lichborneDown = false,
		iceboundFortitudeDown = false,
		mockingBanner = false,
		totemicProjection = false,
		wildCharge = false,
		rushingJadeWind = false,
		manaTea = false,
		purge = false, -- Added to 2.2.2
		tranquilizingShot = false, -- Added to 2.2.2
		powerWordShield = false, -- Added to 2.2.2
		genderVoice = false, -- added to 2.3
		custom = {},
		--shieldBarrier = false,
		shieldBarrierDown = false,
	}	
 }

 GSA.log = function(msg) DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF22GladiatorlosSA|r: "..msg) end

 -- LSM BEGIN / inspired from MSBTMedia.lua
 local function RegisterSound(soundName, soundPath)
	if (type(soundName) ~= "string" or type(soundPath) ~= "string") then return end
	if (soundName == "" or soundPath == "") then return end

	soundz[soundName] = soundPath
	LSM:Register("sound", soundName, soundPath)
 end

 for soundName, soundPath in pairs(LSM_GSA_SOUNDFILES) do RegisterSound(soundName, soundPath) end
 for index, soundName in pairs(LSM:List("sound")) do soundz[soundName] = LSM:Fetch("sound", soundName) end

 local function LSMRegistered(event, mediaType, name)
	if (mediaType == "sound") then
		soundz[name] = LSM:Fetch(mediaType, name)
	end
 end
 -- LSM END

 function GladiatorlosSA:OnInitialize()
	if not self.spellList then
		self.spellList = self:GetSpellList()
	end
	for _,v in pairs(self.spellList) do
		for _,spell in pairs(v) do
			if dbDefaults.profile[spell] == nil then dbDefaults.profile[spell] = true end
		end
	end
	
	self.db1 = LibStub("AceDB-3.0"):New("GladiatorlosSADB",dbDefaults, "Default");
	--DEFAULT_CHAT_FRAME:AddMessage(GSA_TEXT .. GSA_VERSION .. GSA_AUTHOR .."  - /gsa ");
	self:RegisterChatCommand("GladiatorlosSA", "ShowConfig")
	self:RegisterChatCommand("gsa", "ShowConfig")
	self:RegisterChatCommand("gsaz", "ShowConfig2") -- ***** @
	self.db1.RegisterCallback(self, "OnProfileChanged", "ChangeProfile")
	self.db1.RegisterCallback(self, "OnProfileCopied", "ChangeProfile")
	self.db1.RegisterCallback(self, "OnProfileReset", "ChangeProfile")
	gsadb = self.db1.profile
	local options = {
		name = "GladiatorlosSA",
		desc = L["PVP Voice Alert"],
		type = 'group',
		args = {},
	}
	local bliz_options = CopyTable(options)
	bliz_options.args.load = {
		name = L["Load Configuration"],
		desc = L["Load Configuration Options"],
		type = 'execute',
		func = function() 
		self:OnOptionCreate() 
			bliz_options.args.load.disabled = true 
			GameTooltip:Hide() 
			--fix for in 5.3 BLZOptionsFrame can't refresh on load
			InterfaceOptionsFrame:Hide() 
			InterfaceOptionsFrame:Show() 
		end,
		handler = GladiatorlosSA,
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GladiatorlosSA_bliz", bliz_options)
	AceConfigDialog:AddToBlizOptions("GladiatorlosSA_bliz", "GladiatorlosSA")
	LSM.RegisterCallback(LSM_GSA_SOUNDFILES, "LibSharedMedia_Registered", LSMRegistered)
 end

 function GladiatorlosSA:OnEnable()
	GladiatorlosSA:RegisterEvent("PLAYER_ENTERING_WORLD")
	GladiatorlosSA:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	GladiatorlosSA:RegisterEvent("UNIT_AURA")
	if not GSA_LANGUAGE[gsadb.path] then gsadb.path = GSA_LOCALEPATH[GetLocale()] end
	self.throttled = {}
	self.smarter = 0
 end

 function GladiatorlosSA:OnDisable()

 end

--local GSA_GENDER = {"gsadb.path_neutral","gsadb.path_male","gsadb.path"}

 function GSA:GetGenderPath(genderZ)
	if genderZ == 1 then return gsadb.path_neutral
	elseif genderZ == 2 then return gsadb.path_male
	else return gsadb.path
	end
 end

-- play sound by file name
 function GSA:PlaySound(fileName, extend, genderZ)
	local gender_path = self:GetGenderPath(genderZ)
	PlaySoundFile("Interface\\Addons\\" ..gender_path.. "\\"..fileName .. "." .. (extend or "ogg"), gsadb.output_menu)
 end

 function GladiatorlosSA:ArenaClass(id)
	for i = 1 , 5 do
		if id == UnitGUID("arena"..i) then
			return select(2, UnitClass ("arena"..i))
		end
	end
 end

 function GladiatorlosSA:PLAYER_ENTERING_WORLD()
	--CombatLogClearEntries()
 end

-- play sound by spell id and spell type AND gender
 function GladiatorlosSA:PlaySpell(listName, spellID, sourceGUID, destGUID, ...)
	local list = self.spellList[listName]
	if not list[spellID] then return end
	if not gsadb[list[spellID]] then return	end
	if gsadb.throttle ~= 0 and self:Throttle("playspell",gsadb.throttle) then return end
	if gsadb.smartDisable then
		if (GetNumGroupMembers() or 0) > 20 then return end
		if self:Throttle("smarter",20) then
			self.smarter = self.smarter + 1
			if self.smarter > 30 then return end
		else 
			self.smarter = 0
		end
	end
	
	local genderZ
	if gsadb.genderVoice then
		if (sourceGUID ~= nil or destGUID ~= nil) then
			if (sourceGUID == ('') or sourceGUID == nil ) then
				local _, _, _, _, sex, _, _ = GetPlayerInfoByGUID(destGUID)
				genderZ = sex
			else
				local _, _, _, _, sex, _, _ = GetPlayerInfoByGUID(sourceGUID)
				genderZ = sex
			end
		else
			GSA.log ("sourceGUID or destGUID error")
			print("--",sourceGUID,destGUID,listName,spellID)
		end
	end

		self:PlaySound(list[spellID],extend,genderZ)

 end

 function GladiatorlosSA:COMBAT_LOG_EVENT_UNFILTERED(event , ...)
	local _,currentZoneType = IsInInstance()
	if (not ((currentZoneType == "none" and gsadb.field) or (currentZoneType == "pvp" and gsadb.battleground) or (currentZoneType == "arena" and gsadb.arena) or gsadb.all)) then
		return
	end
	local timestamp,event,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,destGUID,destName,destFlags,destFlags2,spellID,spellName= select ( 1 , ... );
	if not GSA_EVENT[event] then return end

		--print(sourceName,sourceGUID,destName,destGUID,destFlags,"|cffFF7D0A" .. event.. "|r",spellName,"|cffFF7D0A" .. spellID.. "|r")
		--print("|cffff0000timestamp|r",timestamp,"|cffff0000event|r",event,"|cffff0000hideCaster|r",hideCaster,"|cffff0000sourceGUID|r",sourceGUID,"|cffff0000sourceName|r",sourceName,"|cffff0000sourceFlags|r",sourceFlags,"|cffff0000sourceFlags2|r",sourceFlags2,"|cffff0000destGUID|r",destGUID,"|cffff0000destName|r",destName,"|cffff0000destFlags|r",destFlags,"|cffff0000destFlags2|r",destFlags2,"|cffff0000spellID|r",spellID,"|cffff0000spellName|r",spellName)
		
		
	if (destFlags) then
		for k in pairs(GSA_TYPE) do
			desttype[k] = CombatLog_Object_IsA(destFlags,k)
			--log("desttype:"..k.."="..(desttype[k] or "nil"))
		end
	else
		for k in pairs(GSA_TYPE) do
			desttype[k] = nil
		end
	end
	if (destGUID) then
		for k in pairs(GSA_UNIT) do
			destuid[k] = (UnitGUID(k) == destGUID)
			--log("destuid:"..k.."="..(destuid[k] and "true" or "false"))
		end
	else
		for k in pairs(GSA_UNIT) do
			destuid[k] = nil
			--log("destuid:"..k.."="..(destuid[k] and "true" or "false"))
		end
	end
	destuid.any = true
	if (sourceFlags) then
		for k in pairs(GSA_TYPE) do
			sourcetype[k] = CombatLog_Object_IsA(sourceFlags,k)
			--log("sourcetype:"..k.."="..(sourcetype[k] or "nil"))
		end
	else
		for k in pairs(GSA_TYPE) do
			sourcetype[k] = nil
			--log("sourcetype:"..k.."="..(sourcetype[k] or "nil"))
		end
	end
	if (sourceGUID) then
		for k in pairs(GSA_UNIT) do
			sourceuid[k] = (UnitGUID(k) == sourceGUID)
			--log("sourceuid:"..k.."="..(sourceuid[k] and "true" or "false"))
		end
	else
		for k in pairs(GSA_UNIT) do
			sourceuid[k] = nil
			--log("sourceuid:"..k.."="..(sourceuid[k] and "true" or "false"))
		end
	end
	sourceuid.any = true


	if (event == "SPELL_AURA_APPLIED" and desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not gsadb.aonlyTF or destuid.target or destuid.focus) and not gsadb.aruaApplied) then
		self:PlaySpell("auraApplied", spellID, sourceGUID, destGUID);
	elseif (event == "SPELL_AURA_REMOVED" and desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not gsadb.ronlyTF or destuid.target or destuid.focus) and not gsadb.auraRemoved) then
		self:PlaySpell("auraRemoved", spellID, sourceGUID, destGUID)
	elseif (event == "SPELL_CAST_START" and sourcetype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not gsadb.conlyTF or sourceuid.target or sourceuid.focus) and not gsadb.castStart) then
		self:PlaySpell("castStart", spellID, sourceGUID, destGUID)
	elseif ((event == "SPELL_CAST_SUCCESS" or event == "SPELL_SUMMON") and sourcetype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and (not gsadb.sonlyTF or sourceuid.target or sourceuid.focus) and not gsadb.castSuccess) then
		if self:Throttle(tostring(spellID).."default", 0.05) then return end
		if (spellID == 42292 or spellID == 59752) and gsadb.class and currentZoneType == "arena" then
			local c = self:ArenaClass(sourceGUID)
			if c then 
				self:PlaySound(c);
			end
		else	
			self:PlaySpell("castSuccess", spellID, sourceGUID, destGUID)
		end
	elseif (event == "SPELL_INTERRUPT" and desttype[COMBATLOG_FILTER_HOSTILE_PLAYERS] and not gsadb.interrupt) then 
		self:PlaySpell ("friendlyInterrupt", spellID, sourceGUID, destGUID)
	end

	--[[ Test lines ]]
	-- if (event == "SPELL_AURA_APPLIED" and desttype[COMBATLOG_FILTER_EVERYTHING] and (not gsadb.aonlyTF or destuid.target or destuid.focus) and not gsadb.aruaApplied) then
		-- self:PlaySpell("auraApplied", spellID, sourceGUID, destGUID);
	-- elseif (event == "SPELL_AURA_REMOVED" and desttype[COMBATLOG_FILTER_EVERYTHING] and (not gsadb.ronlyTF or destuid.target or destuid.focus) and not gsadb.auraRemoved) then
		-- self:PlaySpell("auraRemoved", spellID, sourceGUID, destGUID)
	-- elseif (event == "SPELL_CAST_START" and sourcetype[COMBATLOG_FILTER_EVERYTHING] and (not gsadb.conlyTF or sourceuid.target or sourceuid.focus) and not gsadb.castStart) then
		-- self:PlaySpell("castStart", spellID, sourceGUID, destGUID)
	-- elseif ((event == "SPELL_CAST_SUCCESS" or event == "SPELL_SUMMON") and sourcetype[COMBATLOG_FILTER_EVERYTHING] and (not gsadb.sonlyTF or sourceuid.target or sourceuid.focus) and not gsadb.castSuccess) then
		-- if self:Throttle(tostring(spellID).."default", 0.05) then return end
		-- if (spellID == 42292 or spellID == 59752) and gsadb.class then
			-- local _,c,_ = UnitClass("player"); -- localizedClass, englishClass, classIndex = 
			-- if c then 
				-- self:PlaySound(c);
			-- end
		-- else	
			-- self:PlaySpell("castSuccess", spellID, sourceGUID, destGUID)
		-- end
	-- elseif (event == "SPELL_INTERRUPT" and desttype[COMBATLOG_FILTER_EVERYTHING] and not gsadb.interrupt) then 
		-- self:PlaySpell ("friendlyInterrupt", spellID, sourceGUID, destGUID)
	-- end


	-- play custom spells
	for k, css in pairs (gsadb.custom) do
		if css.destuidfilter == "custom" and destName == css.destcustomname then 
			destuid.custom = true  
		else 
			destuid.custom = false
		end
		if css.sourceuidfilter == "custom" and sourceName == css.sourcecustomname then
			sourceuid.custom = true  
		else
			sourceuid.custom = false 
		end

		if css.eventtype[event] and destuid[css.destuidfilter] and desttype[css.desttypefilter] and sourceuid[css.sourceuidfilter] and sourcetype[css.sourcetypefilter] and spellID == tonumber(css.spellid) then
			if self:Throttle(tostring(spellID)..css.name, 0.1) then return end
			--PlaySoundFile(css.soundfilepath, "Master")

			if css.existingsound then -- Added to 2.3.3
				if (css.existinglist ~= nil and css.existinglist ~= ('')) then
					local soundz = LSM:Fetch('sound', css.existinglist)
					PlaySoundFile(soundz, gsadb.output_menu)
				else
					GSA.log (L["No sound selected for the Custom alert : |cffC41F4B"] .. css.name .. "|r.") -- missing... added to 2.3.4
				end
			else
				PlaySoundFile(css.soundfilepath, gsadb.output_menu)
			end
		end
	end
 end

-- play drinking in arena
 local DRINK_SPELL, REFRESHMENT_SPELL, FOOD_SPELL = GetSpellInfo(104270), GetSpellInfo(167152), GetSpellInfo(5006)
 function GladiatorlosSA:UNIT_AURA(event,uid)

	if uid:find("arena") and gsadb.drinking then
	-- if gsadb.drinking then
		if UnitAura(uid,DRINK_SPELL) or UnitAura(uid,REFRESHMENT_SPELL) or UnitAura(uid,FOOD_SPELL) then

			local genderZ
			if gsadb.genderVoice then
				genderZ = UnitSex(uid)
			end

			if self:Throttle(tostring(104270) .. uid, 3) then return end
			self:PlaySound("drinking",extend,genderZ)
		end
	end
 end

 function GladiatorlosSA:Throttle(key,throttle)
	if (not self.throttled) then
		self.throttled = {}
	end
	-- Throttling of Playing
	if (not self.throttled[key]) then
		self.throttled[key] = GetTime()+throttle
		return false
	elseif (self.throttled[key] < GetTime()) then
		self.throttled[key] = GetTime()+throttle
		return false
	else
		return true
	end
 end 