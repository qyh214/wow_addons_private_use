---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.API; addon.C.API = NS

--------------------------------
-- VARIABLES
--------------------------------

NS.Util = {}

do -- MAIN

end

do -- CONSTANTS

end

--------------------------------
-- STRING
--------------------------------

do
	do -- STRING
		do -- MEASUREMENT
			local MeasurementFrame = CreateFrame("Frame", "MeasurementFrame", nil)
			MeasurementFrame:SetScale(addon.C.AddonInfo.Variables.General.UI_SCALE)
			MeasurementFrame:SetAllPoints(UIParent)

			local MeasurementText = MeasurementFrame:CreateFontString("MeasurementText", "OVERLAY")
			MeasurementText:SetPoint("CENTER", MeasurementFrame)
			MeasurementText:Hide()

			-- Gets the width & height of the given string.
			---@param frame fontstring
			---@param maxWidth? number
			---@param maxHeight? number
			---@return width number
			---@return height number
			function NS.Util:GetStringSize(frame, maxWidth, maxHeight)
				local text = NS.Util:GetUnformattedText(frame:GetText())
				local font, size, flags = frame:GetFont()
				local justifyH, justifyV = frame:GetJustifyH(), frame:GetJustifyV()

				--------------------------------

				MeasurementText:SetFont(font or GameFontNormal:GetFont(), size > 0 and size or 12, flags or "")
				MeasurementText:SetText(text)
				MeasurementText:SetScale(frame:GetEffectiveScale())

				if justifyH then
					MeasurementText:SetJustifyH(justifyH)
				end

				if justifyV then
					MeasurementText:SetJustifyV(justifyV)
				end

				MeasurementText:SetWidth(maxWidth or frame:GetWidth())
				MeasurementText:SetHeight(maxHeight or 1000)

				--------------------------------

				local width, height = MeasurementText:GetWrappedWidth(), MeasurementText:GetStringHeight()
				return width, height
			end

			--- Gets the actual height of the text in the given font string without any color codes.
			---@param text FontString
			---@return number
			function NS.Util:GetActualStringHeight(text)
				local cleanedText = NS.Util:StripColorCodes(text:GetText())

				--------------------------------

				local textFrame = CreateFrame("Frame"):CreateFontString(nil, "BACKGROUND", text:GetFont())
				textFrame:SetWidth(text:GetWidth())
				textFrame:SetText(cleanedText)

				--------------------------------

				local height = textFrame:GetHeight()
				return height
			end
		end

		do -- SEARCH
			-- Returns if the given string is found in the string.
			---@param string string
			---@param stringToSearch string
			---@return success boolean
			function NS.Util:FindString(string, stringToSearch)
				if string and stringToSearch then
					if string.match(string, stringToSearch) then
						return true
					else
						return false
					end
				else
					return false
				end
			end

			--- Returns the starting index of the character at the given index in the given UTF-8 encoded string.
			---@param str string
			---@param index number
			---@return number|nil
			function NS.Util:GetCharacterStartIndex(str, index)
				local i = 1
				local charCount = 0

				while i <= #str do
					local byte = str:byte(i)

					if byte >= 0 and byte <= 127 then
						charCount = charCount + 1
						if charCount == index then
							return i
						end
						i = i + 1
					elseif byte >= 192 and byte <= 223 then
						charCount = charCount + 1
						if charCount == index then
							return i
						end
						i = i + 2
					elseif byte >= 224 and byte <= 239 then
						charCount = charCount + 1
						if charCount == index then
							return i
						end
						i = i + 3
					elseif byte >= 240 and byte <= 247 then
						charCount = charCount + 1
						if charCount == index then
							return i
						end
						i = i + 4
					else
						i = i + 1
					end
				end

				return nil
			end

			--- Returns the index of the last byte of the character at the given index in the given UTF-8 encoded string.
			---@param str string
			---@param index number
			---@return number|nil
			function NS.Util:GetCharacterEndIndex(str, index)
				local start = NS.Util:GetCharacterStartIndex(str, index)
				if start then
					local byte = str:byte(start)
					if byte >= 0 and byte <= 127 then
						return start
					elseif byte >= 192 and byte <= 223 then
						return start + 1
					elseif byte >= 224 and byte <= 239 then
						return start + 2
					elseif byte >= 240 and byte <= 247 then
						return start + 3
					end
				end
				return nil
			end

			--- Returns a substring of the given string from the starting index to the ending index.
			---@param str string
			---@param A number
			---@param B number
			---@return string
			function NS.Util:GetSubstring(str, A, B)
				local startIndex = NS.Util:GetCharacterStartIndex(str, A)
				local endIndex = NS.Util:GetCharacterEndIndex(str, B)

				--------------------------------

				if startIndex and endIndex then
					return str:sub(startIndex, endIndex)
				else
					return ""
				end
			end
		end

		do -- UTILITIES
			-- Removes atlas markup from the given string.
			---@param str string
			---@param removeSpace boolean
			---@return string
			function NS.Util:RemoveAtlasMarkup(str, removeSpace)
				if removeSpace then
					str = string.gsub(str, "(|A.-|a )", "")
					str = string.gsub(str, "(|H.-|h )", "")
				else
					str = string.gsub(str, "(|A.-|a)", "")
					str = string.gsub(str, "(|H.-|h)", "")
				end

				return str
			end
		end
	end

	do -- FORMATTING
		-- Removes color codes from the given string.
		---@param text string
		---@return string
		function NS.Util:StripColorCodes(text)
			if text ~= nil then
				local new = string.gsub(text, "|cff%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
				new = string.gsub(new, "|cn.-:", "")

				return new
			else
				return ""
			end
		end

		-- Converts RGB values to a hex color string.
		---@param r number
		---@param g number
		---@param b number
		---@return string: The given color as a hex string (#RRGGBB).
		function NS.Util:GetHexColor(r, g, b)
			r = math.floor(r * 255)
			g = math.floor(g * 255)
			b = math.floor(b * 255)
			return string.format("%02x%02x%02x", r, g, b)
		end

		-- Changes the brightness of a given hex color string.
		---@param hexColor string
		---@param factor number
		---@return string
		function NS.Util:SetHexColorFromModifier(hexColor, factor)
			local color = hexColor:match("([0-9A-Fa-f]+)")

			if not color then
				return hexColor
			end

			local r = tonumber(color:sub(1, 2), 16)
			local g = tonumber(color:sub(3, 4), 16)
			local b = tonumber(color:sub(5, 6), 16)

			r = math.max(0, math.floor(r * (factor)))
			g = math.max(0, math.floor(g * (factor)))
			b = math.max(0, math.floor(b * (factor)))

			local newColor = string.format("%02x%02x%02x", r, g, b)

			return newColor
		end

		--- Modifies the brightness of a given hex color string, with a base color tint.
		---@param hexColor string
		---@param factor number
		---@param baseColor string
		---@return string
		function NS.Util:SetHexColorFromModifierWithBase(hexColor, factor, baseColor)
			local color = hexColor:match("([0-9A-Fa-f]+)")

			if not color then
				return hexColor
			end

			local r = tonumber(color:sub(1, 2), 16) or 0
			local g = tonumber(color:sub(3, 4), 16) or 0
			local b = tonumber(color:sub(5, 6), 16) or 0

			-- Parse the base color
			local baseR = tonumber(baseColor:sub(1, 2), 16) or 0
			local baseG = tonumber(baseColor:sub(3, 4), 16) or 0
			local baseB = tonumber(baseColor:sub(5, 6), 16) or 0

			-- Apply the brightness factor
			r = math.min(255, math.floor(r * factor + baseR * (1 - factor)))
			g = math.min(255, math.floor(g * factor + baseG * (1 - factor)))
			b = math.min(255, math.floor(b * factor + baseB * (1 - factor)))

			-- Ensure values are at least zero
			r = math.max(0, r)
			g = math.max(0, g)
			b = math.max(0, b)

			local newColor = string.format("%02x%02x%02x", r, g, b)

			return newColor
		end

		-- Converts a hex color to an RGB color from 0-1
		---@param hexColor string
		function NS.Util:GetRGBFromHexColor(hexColor)
			local r = tonumber(hexColor:sub(1, 2), 16) or 0
			local g = tonumber(hexColor:sub(3, 4), 16) or 0
			local b = tonumber(hexColor:sub(5, 6), 16) or 0

			return { r = r / 255, g = g / 255, b = b / 255 }
		end

		--- Sets the font of a FontString
		--- @param fontString FontString
		--- @param font string
		--- @param size number
		function NS.Util:SetFont(fontString, font, size)
			if not fontString then
				return
			end

			--------------------------------

			fontString:SetFont(font, size, "")
		end

		-- Sets the font size of a FontString
		---@param fontString FontString
		function NS.Util:SetFontSize(fontString, size)
			local FontName, FontHeight, FontFlags = fontString:GetFont()
			fontString:SetFont(FontName, size, FontFlags or "")
		end

		-- Removes inline formatting from the given text.
		---@param text string
		function NS.Util:GetUnformattedText(text)
			local Result = text

			--------------------------------

			if text ~= "" and text ~= nil then
				Result = Result:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
				Result = Result:gsub("\124cn.-:", "")
				Result = Result:gsub("|H(.-)|h(.-)|h", "%2")

				return Result
			else
				return ""
			end
		end

		-- Removes non-colored formmating from a given text.
		---@param text string
		function NS.Util:GetImportantFormattedText(text)
			local Result = text

			--------------------------------

			if text ~= "" and text ~= nil then
				Result = Result:gsub("|cff000000", "")
				Result = Result:gsub("|cffFFFFFF", "")

				return Result
			else
				return ""
			end
		end

		-- Remove inline formatting from the given FontString.
		---@param fontString FontString
		function NS.Util:SetUnformattedText(fontString)
			if fontString.IsObjectType and fontString:IsObjectType("FontString") then
				fontString:SetText(NS.Util:GetUnformattedText(fontString:GetText()))
			end
		end
	end

	do -- UTILITIES
		-- Extracts a number from a string.
		---@param str string
		---@return number number
		---@return sign string
		function NS.Util:ParseNumberFromString(str)
			-- Remove color codes from the string
			str = str:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")

			--------------------------------

			-- Extract the number from the unformatted string
			local NumberString = str:match("%-?%d[%d,]*")
			local NumberSign = "+"

			--------------------------------

			if NumberString then
				if str:find("%-") then
					NumberSign = "-"
				end

				--------------------------------

				NumberString = NumberString:gsub("[,+%-]", "")

				--------------------------------

				local Number = tonumber(NumberString)

				--------------------------------

				return Number, NumberSign
			else
				return nil, nil
			end
		end
	end
end

--------------------------------
-- UTILITIES
--------------------------------

do
	do -- FORMATTING
		-- Formats x to be comma seperated.
		---@param x number
		function NS.Util:FormatNumber(x)
			return BreakUpLargeNumbers(x)
		end

		-- Returns x amount coverted to gold, silver and copper.
		---@param x number
		---@return gold number
		---@return silver number
		---@return copper number
		function NS.Util:FormatMoney(x)
			local gold = math.floor(x / 10000)
			local silver = math.floor((x % 10000) / 100)
			local copperAmount = x % 100

			--------------------------------

			return gold, silver, copperAmount
		end

		-- Returns hr, min, sec from seconds.
		---@param seconds number
		---@return number rawHr
		---@return number rawMin
		---@return number rawSec
		---@return string strHr
		---@return string strMin
		---@return string strSec
		function NS.Util:FormatTime(seconds)
			local rawHr = math.floor(seconds / 3600)
			local rawMin = math.floor((seconds % 3600) / 60)
			local rawSec = seconds % 60
			local strHr = rawHr > 0 and rawHr .. "h " or ""
			local strMin = rawMin > 0 and rawMin .. "m " or ""
			local strSec = rawSec > 0 and rawSec .. "s" or ""

			--------------------------------

			return rawHr, rawMin, rawSec, strHr, strMin, strSec
		end
	end

	do -- TOOLTIP
		-- Adds a tooltip to the specified frame.
		--- @param frame any
		--- @param text string
		--- @param location string
		--- @param locationX? number
		--- @param locationY? number
		--- @param wrapText? boolean
		function NS.Util:AddTooltip(frame, text, location, locationX, locationY, bypassMouseResponder, wrapText)
			frame.showTooltip = true
			frame.tooltipText = text
			frame.tooltipActive = false

			--------------------------------

			if not frame.hookedFunc then
				frame.hookedFunc = true

				--------------------------------

				frame.API_ShowTooltip = function()
					frame.tooltipActive = true

					--------------------------------

					addon.CS:GetCommonFrame().GameTooltip:SetOwner(frame, location, locationX, locationY)
					addon.CS:GetCommonFrame().GameTooltip:SetText(frame.tooltipText, 1, 1, 1, 1, (wrapText == nil and true or wrapText))

					addon.CS:GetCommonFrame().GameTooltip:Show()
				end

				frame.API_HideTooltip = function()
					frame.tooltipActive = false

					--------------------------------

					addon.CS:GetCommonFrame().GameTooltip:Clear()
				end

				--------------------------------

				local function Enter()
					if frame.showTooltip then
						frame.API_ShowTooltip()
					else
						frame.API_HideTooltip()
					end
				end

				local function Leave()
					frame.API_HideTooltip()
				end

				if bypassMouseResponder then
					frame:HookScript("OnEnter", Enter)
					frame:HookScript("OnLeave", Leave)
				else
					addon.C.FrameTemplates:CreateMouseResponder(frame, { enterCallback = Enter, leaveCallback = Leave })
				end
			end
		end

		-- Disables the tooltip for the specified frame.
		---@param frame any
		function NS.Util:RemoveTooltip(frame)
			frame.showTooltip = false
			frame.tooltipText = ""
			if frame.tooltipActive then
				frame.tooltipActive = false

				--------------------------------

				frame.API_HideTooltip()
			end
		end

		-- Extracts item stats from a tooltip.
		---@param tooltip frame
		---@param raw? boolean: Default = false - Whether to ignore the "If you replace this item" line
		---@return table with the following keys:
		---    - intNum: number of intellect
		---    - intSign: sign of intellect
		---    - strNum: number of strength
		---    - strSign: sign of strength
		---    - aglNum: number of agility
		---    - aglSign: sign of agility
		---    - masteryNum: number of mastery
		---    - masterySign: sign of mastery
		---    - hasteNum: number of haste
		---    - hasteSign: sign of haste
		---    - versNum: number of versatility
		---    - versSign: sign of versatility
		---    - critNum: number of critical strike
		---    - critSign: sign of critical strike
		function NS.Util:GetItemStatsFromTooltip(tooltip, raw)
			local stats = {}

			--------------------------------

			local valid = false

			for i = 1, tooltip:NumLines() do
				local Line = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()

				--------------------------------

				if string.match(Line, "If you replace this item") or raw then
					valid = true
				end

				--------------------------------

				if valid then
					local function MatchLine(line, stringToFind)
						if string.match(line, stringToFind) then
							return line
						else
							return nil
						end
					end

					-- Search for specific keywords to identify stats
					local intellect = MatchLine(Line, "Intellect")
					local strength = MatchLine(Line, "Strength")
					local agility = MatchLine(Line, "Agility")
					local mastery = MatchLine(Line, "Mastery")
					local haste = MatchLine(Line, "Haste")
					local versatility = MatchLine(Line, "Versatility")
					local crit = MatchLine(Line, "Critical Strike")

					local intNum, intSign = NS.Util:ParseNumberFromString(tostring(intellect))
					local strNum, strSign = NS.Util:ParseNumberFromString(tostring(strength))
					local aglNum, aglSign = NS.Util:ParseNumberFromString(tostring(agility))
					local masteryNum, masterySign = NS.Util:ParseNumberFromString(tostring(mastery))
					local hasteNum, hasteSign = NS.Util:ParseNumberFromString(tostring(haste))
					local versatilityNum, versatilitySign = NS.Util:ParseNumberFromString(tostring(versatility))
					local critNum, critSign = NS.Util:ParseNumberFromString(tostring(crit))

					-- If any stat is found, add it to the table
					if intNum then
						stats.intNum = intNum
						stats.intSign = intSign
					elseif strNum then
						stats.strNum = strNum
						stats.strSign = strSign
					elseif aglNum then
						stats.aglNum = aglNum
						stats.aglSign = aglSign
					elseif masteryNum then
						stats.masteryNum = masteryNum
						stats.masterySign = masterySign
					elseif hasteNum then
						stats.hasteNum = hasteNum
						stats.hasteSign = hasteSign
					elseif versatilityNum then
						stats.versNum = versatilityNum
						stats.versSign = versatilitySign
					elseif critNum then
						stats.critNum = critNum
						stats.critSign = critSign
					end
				end
			end

			--------------------------------

			return stats
		end

		-- Extracts the total item stats from a tooltip.
		---@param tooltip frame
		---@param raw? boolean: Default = false - Whether to ignore the "If you replace this item" line
		---@return table table with the following keys:
		---    - intNum: total number of intellect
		---    - strNum: total number of strength
		---    - aglNum: total number of agility
		---    - masteryNum: total number of mastery
		---    - hasteNum: total number of haste
		---    - versNum: total number of versatility
		---    - critNum: total number of critical strike
		function NS.Util:GetTotalItemStatsFromTooltip(tooltip, raw)
			local stats = {
				intNum = 0,
				strNum = 0,
				aglNum = 0,
				masteryNum = 0,
				hasteNum = 0,
				versNum = 0,
				critNum = 0,
			}

			--------------------------------

			local valid = false

			for i = 1, tooltip:NumLines() do
				local Line = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()

				--------------------------------

				if string.match(Line, "If you replace this item") or raw then
					valid = true
				end

				--------------------------------

				if valid then
					local finishSearch = false

					--------------------------------

					local function MatchLine(line, stringToFind)
						local isEquip = NS.Util:FindString(line, "Equip")
						local isZoneOfFocus = NS.Util:FindString(line, "Zone of Focus")
						local isSet = NS.Util:FindString(line, "Set")

						--------------------------------

						if (not isEquip or isZoneOfFocus) and not isSet and string.match(line, stringToFind) and not finishSearch then
							finishSearch = true

							--------------------------------

							return line
						else
							return nil
						end
					end

					-- Search for specific keywords to identify stats
					local intellect = MatchLine(Line, "Intellect")
					local strength = MatchLine(Line, "Strength")
					local agility = MatchLine(Line, "Agility")
					local mastery = MatchLine(Line, "Mastery")
					local haste = MatchLine(Line, "Haste")
					local versatility = MatchLine(Line, "Versatility")
					local crit = MatchLine(Line, "Critical Strike")

					-- Parse and accumulate values for each stat
					local function AccumulateStat(statName, statValue)
						if statValue then
							local function CalculateStat(string)
								local num, sign = NS.Util:ParseNumberFromString(string)
								local statName

								--------------------------------

								if NS.Util:FindString(string, "Intellect") then statName = "intNum" end
								if NS.Util:FindString(string, "Strength") then statName = "strNum" end
								if NS.Util:FindString(string, "Agility") then statName = "aglNum" end
								if NS.Util:FindString(string, "Mastery") then statName = "masteryNum" end
								if NS.Util:FindString(string, "Haste") then statName = "hasteNum" end
								if NS.Util:FindString(string, "Versatility") then statName = "versNum" end
								if NS.Util:FindString(string, "Critical Strike") then statName = "critNum" end

								--------------------------------

								if num and statName then
									stats[statName] = stats[statName] + num
								end
							end

							if NS.Util:FindString(statValue, "and") then
								local string1, string2 = statValue:match("^(.-)%s+and%s+(.*)$")

								CalculateStat(string1)
								CalculateStat(string2)
							elseif NS.Util:FindString(statValue, "Zone of Focus") then
								local string1, string2 = statValue:match("^(.-)%%(.*)$")

								CalculateStat(string2)
							else
								CalculateStat(statValue)
							end
						end
					end

					AccumulateStat("intNum", intellect)
					AccumulateStat("strNum", strength)
					AccumulateStat("aglNum", agility)
					AccumulateStat("masteryNum", mastery)
					AccumulateStat("hasteNum", haste)
					AccumulateStat("versNum", versatility)
					AccumulateStat("critNum", crit)
				end
			end

			--------------------------------

			return stats
		end

		-- Returns the item level from a tooltip.
		---@param tooltip frame
		---@return ItemLevel number
		function NS.Util:GetItemLevelFromTooltip(tooltip)
			local itemLevel

			--------------------------------

			for i = 1, tooltip:NumLines() do
				local line = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()

				--------------------------------

				local function MatchLine(line, stringToFind)
					if string.match(line, stringToFind) then
						return line
					else
						return nil
					end
				end

				--------------------------------

				local itemLevelLine = MatchLine(line, "Item Level")

				--------------------------------

				if itemLevelLine then
					itemLevel = NS.Util:ParseNumberFromString(tostring(itemLevelLine))
				end
			end

			--------------------------------

			return itemLevel
		end
	end

	do -- SEARCH
		-- Returns if the an item name is found in the player's bag.
		---@param itemName string
		---@return itemID any
		---@return itemLink any
		function NS.Util:FindItemInInventory(itemName)
			if not itemName then
				return nil, nil
			end

			--------------------------------

			for bag = 0, 4 do
				for slot = 1, C_Container.GetContainerNumSlots(bag) do
					local itemID = C_Container.GetContainerItemID(bag, slot) or nil
					local itemLink = C_Container.GetContainerItemLink(bag, slot) or nil

					if itemLink then
						local itemNameInBag = C_Item.GetItemInfo(itemLink)
						if itemNameInBag and itemNameInBag:lower() == itemName:lower() then
							return itemID, itemLink
						end
					end
				end
			end

			--------------------------------

			return nil
		end

		-- Finds the position of a specified key in a table.
		--- @param table table
		--- @param indexValue any
		--- @return index any
		function NS.Util:FindKeyPositionInTable(table, indexValue)
			local currentIndex = 0

			--------------------------------

			for k, v in pairs(table) do
				currentIndex = currentIndex + 1

				--------------------------------

				if k == indexValue then
					return currentIndex
				end
			end

			--------------------------------

			return nil
		end

		-- Finds the position of a specified value in a table.
		--- @param table table
		--- @param indexValue any
		--- @return index any
		function NS.Util:FindValuePositionInTable(table, indexValue)
			local currentIndex = 0

			--------------------------------

			for k, v in pairs(table) do
				currentIndex = currentIndex + 1

				--------------------------------

				if v == indexValue then
					return currentIndex
				end
			end

			--------------------------------

			return nil
		end

		-- Finds the position of a variable value in a table.
		--- @param table table
		--- @param indexValue any
		--- @param searchVariable string
		function NS.Util:FindVariableValuePositionInTable(table, subVariableList, value)
			for i = 1, #table do
				local currentEntry = table[i]

				--------------------------------

				local subVariable = NS.Util:GetSubVariableFromList(currentEntry, subVariableList)
				if subVariable == value then
					return i
				end
			end

			--------------------------------

			return nil
		end

		-- Returns a sub variable from a list.
		---@param list table
		---@param subVariableList table
		---@return any
		function NS.Util:GetSubVariableFromList(list, subVariableList)
			local currentKey = list

			--------------------------------

			for i = 1, #subVariableList do
				currentKey = currentKey[subVariableList[i]]
			end

			--------------------------------

			return currentKey
		end

		-- Sorts a list by numbers.
		---@param list table
		---@param subVariableList table
		---@param ascending? boolean: use ascending order
		---@return table
		function NS.Util:SortListByNumber(list, subVariableList, ascending)
			table.sort(list, function(a, b)
				if ascending then
					local subVariableA = NS.Util:GetSubVariableFromList(a, subVariableList)
					local subVariableB = NS.Util:GetSubVariableFromList(b, subVariableList)

					return subVariableA > subVariableB
				else
					local subVariableA = NS.Util:GetSubVariableFromList(a, subVariableList)
					local subVariableB = NS.Util:GetSubVariableFromList(b, subVariableList)

					return subVariableA < subVariableB
				end
			end)

			--------------------------------

			return list
		end

		-- Sorts a list by alphabetical order.
		---@param list table
		---@param subVariableList table,
		---@param descending? boolean: use descending order (Z-A)
		---@return table
		function NS.Util:SortListByAlphabeticalOrder(list, subVariableList, descending)
			table.sort(list, function(a, b)
				if descending then
					local subVariableA = NS.Util:GetSubVariableFromList(a, subVariableList)
					local subVariableB = NS.Util:GetSubVariableFromList(b, subVariableList)

					return subVariableA:lower() > subVariableB:lower()
				else
					local subVariableA = NS.Util:GetSubVariableFromList(a, subVariableList)
					local subVariableB = NS.Util:GetSubVariableFromList(b, subVariableList)

					return subVariableA:lower() < subVariableB:lower()
				end
			end)

			--------------------------------

			return list
		end

		-- Filters a list by a variable.
		---@param list table
		---@param subVariableList table,
		---@param value any: value to filter
		---@param roughMatch? boolean: use rough matching
		---@param caseSensitive? boolean: use case-sensitive matching
		---@param customCheck? function
		---@return table
		function NS.Util:FilterListByVariable(list, subVariableList, value, roughMatch, caseSensitive, customCheck)
			local filteredList = {}

			--------------------------------

			for k, v in ipairs(list) do
				if customCheck then
					if customCheck(v) then
						table.insert(filteredList, v)
					end
				elseif roughMatch then
					if caseSensitive or caseSensitive == nil then
						local subVariableValue = NS.Util:GetSubVariableFromList(v, subVariableList)

						if NS.Util:FindString(tostring(subVariableValue), tostring(value)) then
							table.insert(filteredList, v)
						end
					else
						local subVariableValue = NS.Util:GetSubVariableFromList(v, subVariableList)

						if NS.Util:FindString(string.lower(tostring(subVariableValue)), string.lower(tostring(value))) then
							table.insert(filteredList, v)
						end
					end
				else
					if caseSensitive or caseSensitive == nil then
						local subVariableValue = NS.Util:GetSubVariableFromList(v, subVariableList)

						if subVariableValue == value then
							table.insert(filteredList, v)
						end
					else
						local subVariableValue = NS.Util:GetSubVariableFromList(v, subVariableList)

						if string.lower(tostring(subVariableValue)) == string.lower(tostring(value)) then
							table.insert(filteredList, v)
						end
					end
				end
			end

			--------------------------------

			return filteredList
		end
	end

	do -- FRAME TEMPLATES

	end

	do -- FUNCTIONS
		ChangeUpdateCallbacks = {}

		-- Function to trigger the callbacks when a variable changes.
		---@param variableName string
		---@param newValue any
		local function TriggerCallbacks(variableName, newValue)
			for _, entry in ipairs(ChangeUpdateCallbacks) do
				if entry.variableName == variableName then
					entry.callback(newValue)
				end
			end
		end

		-- Function to watch a variable and trigger a callback on change.
		---@param variableTable any
		---@param variableName string
		---@param callback function
		function NS.Util:WatchLocalVariable(variableTable, variableName, callback)
			if not variableTable[variableName] then
				variableTable[variableName] = nil -- Initialize if not set
			end

			-- Metatable for variable watching
			local mt = {
				__newindex = function(t, key, value)
					rawset(t, key, value)  -- Set the value
					TriggerCallbacks(variableName, value) -- Trigger the callbacks
				end,
				__index = function(t, key)
					return rawget(t, key) -- Return the value
				end
			}

			-- Set the metatable for the variable in the table
			setmetatable(variableTable, mt)

			-- Register the callback
			ChangeUpdateCallbacks[#ChangeUpdateCallbacks + 1] = {
				variableName = variableName,
				callback = callback
			}
		end
	end

	do -- MISCELLANEOUS
		-- Gets if the player is in shapeshift form by spell name.
		---@return IsInShapeshiftForm boolean
		function NS.Util:IsPlayerInShapeshiftForm()
			local auras = {
				"Cat Form", -- Druid Cat Form
				"Bear Form", -- Druid Bear Form
				"Travel Form", -- Druid Travel Form
				"Moonkin Form", -- Druid Moonkin Form
				"Aquatic Form", -- Druid Aquatic Form
				"Treant Form", -- Druid Treant Form
				"Mount Form", -- Druid Mount Form
			}

			--------------------------------

			for key, value in ipairs(auras) do
				if AuraUtil.FindAuraByName(value, "Player") then
					return true
				end
			end

			--------------------------------

			return false
		end
	end

	do -- METHOD
		-- Creates a method chain. Input a list of variables names to keep track and set. The variables can be called at anytime within the declaration method.
		--
		-- DECLARATION
		-- 		local chain = AddMethodChain({ "onFinish" })
		-- 		return { onFinish = chain.onFinish.set } -- in return statement
		--
		-- CALL
		--		chain.onFinish.variable()
		--
		-- USAGE
		-- 		func().onFinish(function()
		-- 			print("Hello, World!")
		-- 		end)
		---@param variableNames table
		---@return table
		function NS.Util:AddMethodChain(variableNames)
			local chain = {}

			--------------------------------

			for i = 1, #variableNames do
				local entry = {}
				entry = {
					["variable"] = nil,
					["set"] = function(...)
						entry.variable = ...
					end
				}

				chain[variableNames[i]] = entry
			end

			--------------------------------

			return chain
		end
	end

	do -- STANDARD FUNCTIONS
		-- Returns the length of a table.
		---@param table table
		---@return length number
		function NS.Util:tnum(table)
			local length = 0

			for _ in pairs(table) do
				length = length + 1
			end

			return length
		end

		-- Reverses a table.
		---@param table table
		---@return table table
		function NS.Util:rt(table)
			local reversed = {}
			local len = #table

			--------------------------------

			for i = len, 1, -1 do
				reversed[len - i + 1] = table[i]
			end

			--------------------------------

			return reversed
		end

		-- Generates a random hash
		---@return string hash
		function NS.Util:gen_hash()
			local hash = ""
			local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

			--------------------------------

			for i = 1, 16 do
				local rand = math.random(1, #chars)
				hash = hash .. chars:sub(rand, rand)
			end

			--------------------------------

			return hash
		end
	end
end

--------------------------------
-- DISPLAY
--------------------------------

do
	-- Return WorldFrame width, unaffected by UI Scale.
	---@return width number
	function NS.Util:GetScreenWidth()
		return WorldFrame:GetWidth()
	end

	-- Return WorldFrame height, unaffected by UI Scale.
	---@return height number
	function NS.Util:GetScreenHeight()
		return WorldFrame:GetHeight()
	end
end

--------------------------------
-- ACHIEVEMENTS
--------------------------------

do
	-- Returns the statistic ID for the specified statistic name. Can be used for GetStatistic(id) or GetComparisonStatistic(id).
	function NS.Util:GetStatisticID(name)
		for _, CategoryId in pairs(GetStatisticsCategoryList()) do
			for i = 1, GetCategoryNumAchievements(CategoryId) do
				local IDNumber, Name = GetAchievementInfo(CategoryId, i)

				if tostring(Name) == tostring(name) then
					return IDNumber, Name
				end
			end
		end
		return -1
	end

	-- Gets the value for the specified statistic ID.
	---@param unit UnitToken
	---@param id number
	function NS.Util:GetStatistic(unit, id)
		if unit ~= "player" then
			return GetComparisonStatistic(id)
		else
			return GetStatistic(id)
		end
	end
end

--------------------------------
-- PVP
--------------------------------

do
	function NS.Util:GetRatedPVPTierFromRating(rating)
		local rank = {
			["name"] = nil,
			["pvpTierInfo"] = nil
		}

		local tier = {
			["Elite"] = C_PvP.GetPvpTierInfo(6),
			["Duelist"] = C_PvP.GetPvpTierInfo(5),
			["Rival2"] = C_PvP.GetPvpTierInfo(208),
			["Rival1"] = C_PvP.GetPvpTierInfo(4),
			["Challenger2"] = C_PvP.GetPvpTierInfo(207),
			["Challenger1"] = C_PvP.GetPvpTierInfo(3),
			["Combatant2"] = C_PvP.GetPvpTierInfo(206),
			["Combatant1"] = C_PvP.GetPvpTierInfo(2),
			["Unranked"] = C_PvP.GetPvpTierInfo(1)
		}

		--------------------------------

		if not rating or rating <= 0 then
			rank.name = "Unranked"
			rank.pvpTierInfo = tier["Unranked"]
		else
			if rating >= tier["Duelist"].ascendRating then
				rank.name = "Elite"
				rank.pvpTierInfo = tier["Elite"]
			elseif rating >= tier["Rival2"].ascendRating then
				rank.name = "Duelist"
				rank.pvpTierInfo = tier["Duelist"]
			elseif rating >= tier["Rival1"].ascendRating then
				rank.name = "Rival II"
				rank.pvpTierInfo = tier["Rival2"]
			elseif rating >= tier["Challenger2"].ascendRating then
				rank.name = "Rival I"
				rank.pvpTierInfo = tier["Rival1"]
			elseif rating >= tier["Challenger1"].ascendRating then
				rank.name = "Challenger II"
				rank.pvpTierInfo = tier["Challenger2"]
			elseif rating >= tier["Combatant2"].ascendRating then
				rank.name = "Challenger I"
				rank.pvpTierInfo = tier["Challenger1"]
			elseif rating >= tier["Combatant1"].ascendRating then
				rank.name = "Combatant II"
				rank.pvpTierInfo = tier["Combatant2"]
			elseif rating >= tier["Unranked"].ascendRating then
				rank.name = "Combatant I"
				rank.pvpTierInfo = tier["Combatant1"]
			else
				rank.name = "Unranked"
				rank.pvpTierInfo = tier["Unranked"]
			end
		end

		--------------------------------

		return rank
	end
end

--------------------------------
-- BLIZZARD
--------------------------------

do
	-- Blizzard FrameXML — https://wowpedia.fandom.com/wiki/Using_the_ColorPickerFrame

	-- Shows Blizzard's Color Picker frame.
	---@param initialColor table
	---@param callback function
	---@param opacityCallback function
	---@param confirmCallback function
	---@param cancelCallback function
	function NS.Util:Blizzard_ShowColorPicker(initialColor, callback, opacityCallback, confirmCallback, cancelCallback)
		local info = { r = initialColor.r, g = initialColor.g, b = initialColor.b, }
		ColorPickerFrame:SetupColorPickerAndShow(info)
		ColorPickerFrame.opacity = initialColor.a

		ColorPickerFrame.func = callback
		ColorPickerFrame.opacityFunc = opacityCallback
		ColorPickerFrame.swatchFunc = confirmCallback
		ColorPickerFrame.cancelFunc = cancelCallback

		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
	end

	-- Hides Blizzard's Color Picker frame.
	----
	function NS.Util:Blizzard_HideColorPicker()
		ColorPickerFrame:Hide()
	end

	function NS.Util:Blizzard_AddConfirmPopup(id, text, button1Text, button2Text, acceptCallback, cancelCallback, hideOnEscape)
		StaticPopupDialogs[id] = {
			text = text,
			button1 = button1Text,
			button2 = button2Text,
			OnAccept = acceptCallback,
			OnCancel = cancelCallback,
			hideOnEscape = hideOnEscape,
			timeout = 0,
			preferredIndex = 3,
		}
	end

	function NS.Util:Blizzard_ShowPopup(id, ...)
		StaticPopup_Show(id, ...)
	end

	function NS.Util:Blizzard_HidePopup(id)
		StaticPopup_Hide(id)
	end
end

--------------------------------
-- NPC
--------------------------------

do
	local INTERACT_GOSSIP = Enum.PlayerInteractionType and Enum.PlayerInteractionType.Gossip or 3;
	local INTERACT_QUEST = Enum.PlayerInteractionType and Enum.PlayerInteractionType.QuestGiver or 4;

	function NS.Util:IsNPCGossip()
		return C_PlayerInteractionManager.IsInteractingWithNpcOfType(INTERACT_GOSSIP)
	end

	function NS.Util:IsNPCQuest()
		return C_PlayerInteractionManager.IsInteractingWithNpcOfType(INTERACT_QUEST)
	end

	function NS.Util:IsNPCQuestOrGossip()
		return (NS.Util:IsNPCGossip() or NS.Util:IsNPCQuest())
	end

	function NS.Util:IsAutoAccept()
		if not addon.C.Variables.IS_WOW_VERSION_CLASSIC_ALL then
			return QuestGetAutoAccept() and QuestFrameAcceptButton:IsVisible()
		else
			return false
		end
	end
end

--------------------------------
-- CONVERSION
--------------------------------

do
	function NS.Util:ConvertYardsToMetric(yds)
		local km = 0
		local m = 0

		local meters = yds * 0.9144
		km = meters / 1000
		m = meters % 1000

		return km, m
	end
end

--------------------------------
-- MISCELLANEOUS
--------------------------------

do
	do -- INLINE ICONS
		-- Creates an inline icon.
		---@param path string
		---@param height number
		---@param width number
		---@param horizontalOffset number
		---@param verticalOffset number
		---@param type? string: "Atlas" or "Texture"
		---@return string string
		function NS.Util:InlineIcon(path, height, width, horizontalOffset, verticalOffset, type)
			if type == "Atlas" then
				return CreateAtlasMarkup(path, width, height, horizontalOffset, verticalOffset)
			else
				return "|T" .. path .. ":" .. height .. ":" .. width .. ":" .. horizontalOffset .. ":" .. verticalOffset .. "|t"
			end
		end

		-- Offsets an inline icon.
		---@param iconString string
		---@param newXOffset number
		---@param newYOffset number
		---@return new string
		function NS.Util:IconOffset(iconString, newXOffset, newYOffset)
			return iconString:gsub(":(%d+):(%d+)|a", ":" .. newXOffset .. ":" .. newYOffset .. "|a")
		end
	end
end
