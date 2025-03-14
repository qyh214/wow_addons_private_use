local W, F, L = unpack(select(2, ...))
local format = format

W.Media = {
	Icons = {},
	Textures = {},
}

local MediaPath = "Interface/Addons/WindDungeonHelper/Media/"

do
	local cuttedIconTemplate = "|T%s:%d:%d:0:0:64:64:5:59:5:59|t"
	local cuttedIconAspectRatioTemplate = "|T%s:%d:%d:0:0:64:64:%d:%d:%d:%d|t"
	local textureTemplate = "|T%s:%d:%d|t"
	local aspectRatioTemplate = "|T%s:0:aspectRatio|t"
	local textureWithTexCoordTemplate = "|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"
	local s = 14

	function F.GetIconString(icon, height, width, aspectRatio)
		if aspectRatio and height and height > 0 and width and width > 0 then
			local proportionality = height / width
			local offset = ceil((54 - 54 * proportionality) / 2)
			if proportionality > 1 then
				return format(cuttedIconAspectRatioTemplate, icon, height, width, 5 + offset, 59 - offset, 5, 59)
			elseif proportionality < 1 then
				return format(cuttedIconAspectRatioTemplate, icon, height, width, 5, 59, 5 + offset, 59 - offset)
			end
		end

		width = width or height
		return format(cuttedIconTemplate, icon, height or s, width or s)
	end

	function F.GetTextureString(texture, height, width, aspectRatio)
		if aspectRatio then
			return format(aspectRatioTemplate, texture)
		else
			width = width or height
			return format(textureTemplate, texture, height or s, width or s)
		end
	end

	function F.GetTextureStringFromTexCoord(texture, width, size, texCoord)
		width = width or size

		return format(
			textureWithTexCoordTemplate,
			texture,
			ceil(width * (texCoord[4] - texCoord[3]) / (texCoord[2] - texCoord[1])),
			width,
			0,
			0,
			size.x,
			size.y,
			texCoord[1] * size.x,
			texCoord[2] * size.x,
			texCoord[3] * size.y,
			texCoord[4] * size.y
		)
	end
end

do
	local raceAtlasMap = {
		["Human"] = {
			["Male"] = "raceicon128-human-male",
			["Female"] = "raceicon128-human-female",
		},
		["Orc"] = {
			["Male"] = "raceicon128-orc-male",
			["Female"] = "raceicon128-orc-female",
		},
		["Dwarf"] = {
			["Male"] = "raceicon128-dwarf-male",
			["Female"] = "raceicon128-dwarf-female",
		},
		["NightElf"] = {
			["Male"] = "raceicon128-nightelf-male",
			["Female"] = "raceicon128-nightelf-female",
		},
		["Scourge"] = {
			["Male"] = "raceicon128-undead-male",
			["Female"] = "raceicon128-undead-female",
		},
		["Tauren"] = {
			["Male"] = "raceicon128-tauren-male",
			["Female"] = "raceicon128-tauren-female",
		},
		["Gnome"] = {
			["Male"] = "raceicon128-gnome-male",
			["Female"] = "raceicon128-gnome-female",
		},
		["Troll"] = {
			["Male"] = "raceicon128-troll-male",
			["Female"] = "raceicon128-troll-female",
		},
		["Goblin"] = {
			["Male"] = "raceicon128-goblin-male",
			["Female"] = "raceicon128-goblin-female",
		},
		["BloodElf"] = {
			["Male"] = "raceicon128-bloodelf-male",
			["Female"] = "raceicon128-bloodelf-female",
		},
		["Draenei"] = {
			["Male"] = "raceicon128-draenei-male",
			["Female"] = "raceicon128-draenei-female",
		},
		["Worgen"] = {
			["Male"] = "raceicon128-worgen-male",
			["Female"] = "raceicon128-worgen-female",
		},
		["Pandaren"] = {
			["Male"] = "raceicon128-pandaren-male",
			["Female"] = "raceicon128-pandaren-female",
		},
		["Nightborne"] = {
			["Male"] = "raceicon128-nightborne-male",
			["Female"] = "raceicon128-nightborne-female",
		},
		["HighmountainTauren"] = {
			["Male"] = "raceicon128-highmountain-male",
			["Female"] = "raceicon128-highmountain-female",
		},
		["VoidElf"] = {
			["Male"] = "raceicon128-voidelf-male",
			["Female"] = "raceicon128-voidelf-female",
		},
		["LightforgedDraenei"] = {
			["Male"] = "raceicon128-lightforged-male",
			["Female"] = "raceicon128-lightforged-female",
		},
		["ZandalariTroll"] = {
			["Male"] = "raceicon128-zandalari-male",
			["Female"] = "raceicon128-zandalari-female",
		},
		["KulTiran"] = {
			["Male"] = "raceicon128-kultiran-male",
			["Female"] = "raceicon128-kultiran-female",
		},
		["DarkIronDwarf"] = {
			["Male"] = "raceicon128-darkirondwarf-male",
			["Female"] = "raceicon128-darkirondwarf-female",
		},
		["Vulpera"] = {
			["Male"] = "raceicon128-vulpera-male",
			["Female"] = "raceicon128-vulpera-female",
		},
		["MagharOrc"] = {
			["Male"] = "raceicon128-magharorc-male",
			["Female"] = "raceicon128-magharorc-female",
		},
		["Mechagnome"] = {
			["Male"] = "raceicon128-mechagnome-male",
			["Female"] = "raceicon128-mechagnome-female",
		},
		["Dracthyr"] = {
			["Male"] = "raceicon128-dracthyr-male",
			["Female"] = "raceicon128-dracthyr-female",
		},
		["EarthenDwarf"] = {
			["Male"] = "raceicon128-earthen-male",
			["Female"] = "raceicon128-earthen-female",
		},
	}

	function F.GetRaceAtlasString(englishRace, gender, height, width)
		local englishGender = gender == 2 and "Male" or gender == 3 and "Female"
		if not englishGender or not englishRace or not raceAtlasMap[englishRace] then
			return
		end
		return format("|A:%s:%d:%d|a", raceAtlasMap[englishRace][englishGender], height or 16, width or 16)
	end
end

local function AddMedia(name, file, type)
	W.Media[type][name] = MediaPath .. type .. "/" .. file
end

do
	AddMedia("title", "WindDungeonHelperTitle.tga", "Textures")

	local texTable = {
		texHeight = 512,
		texWidth = 1024,
		languages = {
			-- {offsetY, width, height}
			enUS = { 0, 655, 122 },
			zhCN = { 150, 375, 108 },
			zhTW = { 300, 311, 108 },
		},
	}

	function F.GetTitleSize(scale)
		local data = texTable.languages[W.Locale] or texTable.languages["enUS"]
		if not data then
			return
		end

		return {
			width = function()
				return scale * data[2]
			end,
			height = function()
				return scale * data[3]
			end,
		}
	end

	function F.GetTitleTexCoord()
		local data = texTable.languages[W.Locale] or texTable.languages["enUS"]
		if not data then
			return
		end

		return { 0, data[2] / texTable.texWidth, data[1] / texTable.texHeight, (data[1] + data[3]) / texTable.texHeight }
	end
end

function F.GetClassIconStyleList()
	return { "flat", "flatborder", "flatborder2", "round", "square", "warcraftflat" }
end

function F.GetClassIconWithStyle(class, style)
	if not class or not F.In(strupper(class), _G.CLASS_SORT_ORDER) then
		return
	end

	if not style or not F.In(style, F.GetClassIconStyleList()) then
		return
	end

	return MediaPath .. "Icons/ClassIcon/" .. strlower(class) .. "_" .. style .. ".tga"
end

function F.GetClassIconStringWithStyle(class, style, width, height)
	local path = F.GetClassIconWithStyle(class, style)
	if not path then
		return
	end

	if not width and not height then
		return format("|T%s:0|t", path)
	end

	if not height then
		height = width
	end

	return format("|T%s:%d:%d:0:0:64:64:0:64:0:64|t", path, height, width)
end

AddMedia("sunUITank", "SunUI/Tank.tga", "Icons")
AddMedia("sunUIHealer", "SunUI/Healer.tga", "Icons")
AddMedia("sunUIDPS", "SunUI/DPS.tga", "Icons")

AddMedia("discord", "Discord.tga", "Icons")
AddMedia("github", "Github.tga", "Icons")
AddMedia("nga", "NGA.tga", "Icons")
AddMedia("qq", "QQ.tga", "Icons")
AddMedia("kook", "KOOK.tga", "Icons")

AddMedia("donateKofi", "Ko-fi.tga", "Icons")
AddMedia("donateAiFaDian", "AiFaDian.tga", "Icons")
