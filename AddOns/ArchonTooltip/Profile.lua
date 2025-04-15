---@class Private
local Private = select(2, ...)

---@class Profile
---@field difficulty number
---@field progress ProfileProgress
---@field average number|nil
---@field averageDifficulty number|nil The difficulty corresponding to the average parse.
---@field specs ProfileSpec[]
---@field totalKillCount number
---@field isSubscriber boolean
---@field size number
---@field zoneId number
---@field mainCharacter Profile|nil

---@class ProfileProgress
---@field count number
---@field total number

---@class ProfileSpec
---@field type string
---@field difficulty number
---@field progress ProfileProgress
---@field average number|nil
---@field asp number
---@field rank number
---@field encounters EncounterProfile[]
---@field size number

---@class EncounterProfile
---@field id number
---@field kills number
---@field best number|nil

---@param providerSpec ProviderProfileSpec
---@return ProfileSpec
local function convertSpec(providerSpec)
	---@type ProfileSpec
	local spec = {
		type = providerSpec.spec,
		difficulty = providerSpec.difficulty,
		progress = {
			count = providerSpec.progress,
			total = providerSpec.total,
		},
		average = providerSpec.average,
		asp = providerSpec.asp,
		rank = providerSpec.rank,
		encounters = {},
		size = providerSpec.size,
	}

	if providerSpec.encounters ~= nil then
		local firstEncounterId = next(providerSpec.encounters)
		local zone = Private.GetZoneForEncounterId(firstEncounterId)

		if zone ~= nil then
			-- We want to ensure that encounters match the order of the zone
			-- and that we include encounters the player has no data for
			for _, zoneEncounter in ipairs(zone.encounters) do
				local encounterId = zoneEncounter.id
				local encounter = {
					id = encounterId,
					kills = 0,
					best = nil,
				}

				local specEncounter = providerSpec.encounters[encounterId]
				if specEncounter ~= nil then
					encounter.kills = specEncounter.kills
					encounter.best = specEncounter.best
				end

				table.insert(spec.encounters, encounter)
			end
		end
	end

	return spec
end

---@param name string
---@param maybeRealm string
---@param isMainCharacterQuery ?boolean
---@return Profile|nil
function Private.GetProfile(name, maybeRealm, isMainCharacterQuery)
	local realm = Private.GetRealmOrDefault(maybeRealm)

	if realm == nil then
		return
	end

	Private.Print("loading profile for " .. name .. "-" .. realm .. " " .. (isMainCharacterQuery and "(main)" or ""))
	local providerProfile = Private.GetProviderProfile(name, realm)

	if providerProfile == nil then
		return nil
	end

	---@type number|nil
	local zoneId = nil

	if providerProfile.encounters ~= nil then
		local firstEncounterId = next(providerProfile.encounters)

		if firstEncounterId then
			local zone = Private.GetZoneForEncounterId(firstEncounterId)

			if zone then
				zoneId = zone.id
			end
		end

		-- workaround for incorrect data
		if zoneId == nil then
			return nil
		end
	end

	local specs = {}
	for _, providerSpec in ipairs(providerProfile.perSpec) do
		local spec = convertSpec(providerSpec)

		table.insert(specs, spec)

		if zoneId == nil and spec.encounters ~= nil then
			for _, encounterData in ipairs(spec.encounters) do
				local zone = Private.GetZoneForEncounterId(encounterData.id)

				if zone then
					zoneId = zone.id
				end

				break
			end
		end
	end

	table.sort(specs, function(a, b)
		if a.progress.count == b.progress.count then
			return (a.average or 0) > (b.average or 0)
		end

		return a.progress.count > b.progress.count
	end)

	local includeAverage = providerProfile.anySpec ~= nil

	local profile = {
		difficulty = providerProfile.difficulty,
		progress = {
			count = providerProfile.progress,
			total = providerProfile.total,
		},
		average = includeAverage and providerProfile.anySpec.average or nil,
		averageDifficulty = includeAverage and providerProfile.anySpec.difficulty or nil,
		specs = specs,
		isSubscriber = providerProfile.subscriber,
		size = providerProfile.size,
		zoneId = zoneId,
		totalKillCount = providerProfile.totalKillCount,
		mainCharacter = nil,
	}

	Private.Debug({
		profile = profile,
		name = name,
		realm = realm,
	})

	if providerProfile.mainCharacter then
		if providerProfile.mainCharacter.name then
			if not providerProfile.mainCharacter.server then
				providerProfile.mainCharacter.server = realm
			end
			profile.mainCharacter = Private.GetProfile(providerProfile.mainCharacter.name, providerProfile.mainCharacter.server, true)
		else
			profile.mainCharacter = providerProfile.mainCharacter
		end
	end

	return profile
end
