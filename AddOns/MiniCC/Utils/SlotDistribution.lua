---@type string, Addon
local _, addon = ...

---@class SlotDistribution
local M = {}

addon.Utils.SlotDistribution = M

---Calculate slot distribution across CC, Defensive, and Important categories.
---Guarantees each active category at least 1 slot (when enough total slots exist),
---then distributes remaining slots by priority: CC -> Defensive -> Important.
---@param containerCount number Total number of available slots
---@param ccCount number Number of CC auras
---@param defensiveCount number Number of Defensive auras
---@param importantCount number Number of Important auras
---@return number ccSlots Number of slots allocated to CC
---@return number defensiveSlots Number of slots allocated to Defensive
---@return number importantSlots Number of slots allocated to Important
function M.Calculate(containerCount, ccCount, defensiveCount, importantCount)
	local ccSlots, defensiveSlots, importantSlots = 0, 0, 0

	local activeCategories = 0
	if ccCount > 0 then
		activeCategories = activeCategories + 1
	end
	if defensiveCount > 0 then
		activeCategories = activeCategories + 1
	end
	if importantCount > 0 then
		activeCategories = activeCategories + 1
	end

	if activeCategories == 0 then
		return 0, 0, 0
	end

	if containerCount >= activeCategories then
		-- Guarantee each active category at least 1 slot
		if ccCount > 0 then
			ccSlots = 1
		end
		if defensiveCount > 0 then
			defensiveSlots = 1
		end
		if importantCount > 0 then
			importantSlots = 1
		end

		-- Distribute remaining slots by priority: CC -> Defensive -> Important
		local remaining = containerCount - activeCategories

		while remaining > 0 do
			local allocated = false

			if ccCount > ccSlots then
				ccSlots = ccSlots + 1
				remaining = remaining - 1
				allocated = true
			end
			if defensiveCount > defensiveSlots and remaining > 0 then
				defensiveSlots = defensiveSlots + 1
				remaining = remaining - 1
				allocated = true
			end
			if importantCount > importantSlots and remaining > 0 then
				importantSlots = importantSlots + 1
				remaining = remaining - 1
				allocated = true
			end

			if not allocated then
				break
			end
		end
	else
		-- Not enough slots for all categories; round-robin by priority: CC -> Defensive -> Important
		local remaining = containerCount

		while remaining > 0 do
			local allocated = false

			if ccCount > ccSlots then
				ccSlots = ccSlots + 1
				remaining = remaining - 1
				allocated = true
			end
			if defensiveCount > defensiveSlots and remaining > 0 then
				defensiveSlots = defensiveSlots + 1
				remaining = remaining - 1
				allocated = true
			end
			if importantCount > importantSlots and remaining > 0 then
				importantSlots = importantSlots + 1
				remaining = remaining - 1
				allocated = true
			end

			if not allocated then
				break
			end
		end
	end

	return ccSlots, defensiveSlots, importantSlots
end
