local addonName, addon = ...
local FilterProcessor, L, AceGUI, private

local MSG_COUNT_IDX = 1
local PERIOD_COUNT_IDX = 2
local CHAN_NUM_IDX = 3
local DEVIATION_AVG_IDX = 4
local LAST_PERIOD_IDX = 5

if(addonName ~= nil) then
	FilterProcessor = addon:NewModule("FilterProcessor", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
	L = LibStub("AceLocale-3.0"):GetLocale(addonName)
	AceGUI = LibStub("AceGUI-3.0")
	private = {
		plist = {},
	}
else
	addon = {}

	bit = bit32

	function addon:log(...) end
	FilterProcessor = {}

	addon = {
		db = {
			global =
			{
				-- analysis run params
				analysis = {
					interval = 10,
				},
				-- score setting, user's score greater than this score will be rejected
				filtering_level = 0.5,
				-- hourly messages count threshold, greater than this count, users's behavior will be learned and pass to spam check process
				hourly_learning_threshold = 20,
				-- daily learning threshold
				daily_learning_threshold = 50,
				-- penalty threshold, if player's message count lower than this in penalty window, the user will be removed from leanring process
				penalty_threshold = 5,
				-- time deviation threshold of period 
				deviation_threshold = 0.1,
				-- players under watch but not yet meet conditions to be learned
				prelearning = 
				{
					["player-8888-9999"] = {
						-- hour# since os.time() start (00:00:00 UTC, January 1, 1970). hourwindow = os.time()//3600 (math.floor(os.time()//3600)
						hourwindow = 441719,
						-- message count during the hour time window, reset after next window
						hourlycount = 71,
						-- day# since os.time() start (00:00:00 UTC, January 1, 1970). daywindow = os.time()//86400 (math.floor(os.time()//86400)
						daywindow = 11000,
						-- message count during the day time window, reset after next window
						dailycount = 238,
						-- penalty window# since 1970. os.time//(penalty period seconds, 5 days=432000)
						penaltywindow = 3681,
						-- msgs in penalty window
						penaltycount = 3,
						-- if the user under leanring
						learning = true,
					},
				},
				-- players addon is under learning
				plist = 
				{
					["player-1111-2222"] =
					{
						-- name
						name = "demo player",
						-- spam score
						score = 38,
						-- query level using limited api, should performed at low freq
						level = 1,
						-- obtained by getuserinfobyguid
						class = "warlock",
						-- bot or human, 0=human, 1=bot
						bot = 0.9,
						-- last accept time, if message was discard due to same player limitation
						-- the field will not updated.
						last_accept_time = 21311331,
						-- messages sent by the player
						msgs = {
							-- message hash
							["9876543210"] =
							{
								-- msg length
								len = 8,
								-- msg, shoule be remove in release version
								message = "i am spammer",
								-- all non-meaningful chars or contain sick chars
								spamlike = true,
								-- icons
								hasicon = true,
								-- links
								haslink = true,
								-- first receive time
								first_time = 11111111,
								-- last sent time, first read should ignored after addon reload
								last_time = 21111111,
								-- last accept time, if message was discard due to same player limitation
								-- the field will not updated.
								last_accept_time = 21311331,
								--             消息数         周期特征消息数      频道号         偏差总平均         上次的周期                  
								-- samplings. {msg_count (1), period_count (2), chan_num(3),  deviation_avg(4), last_period (5),}
								samplings = {
									all_time = { 8, 6, 2, -0.2, 11,},
									-- last hour sampling, 30x2min
									last_hour = {
										["0"] = { 8, 6, 2, 3, 11,},
										["1"] = { 8, 7, 2, -2.6, 12,},
									},
									last_week = {
										["0"] = { 61, 38, 2, -1.8, 11,},
										["1"] = { 70, 60, 2, 2.1, 10,},
									},
								},
							},
						},
					},
				},
			},
		},
	}
end

------------------------------------------------------------------------------

----- utilities functions
local function StringHash(text)
	local counter = 1
	local len = string.len(text)
	for i = 1, len, 3 do 
		counter = math.fmod(counter*8161, 4294967279) +  -- 2^32 - 17: Prime!
		  (string.byte(text,i)*16776193) +
		  ((string.byte(text,i+1) or (len-i+256))*8372226) +
		  ((string.byte(text,i+2) or (len-i+256))*3932164)
	end
	return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

-- utf8 (WoW default encoding) to unicode table, end with 0
local function utf8to32(utf8str)
	assert(type(utf8str) == "string")
	local res, seq, val = {}, 0, nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			table.insert(res, val)
			seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
			      c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
				  error("invalid UTF-8 character sequence")
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	table.insert(res, val)
	table.insert(res, 0)
	return res
end

local sickchars ={
	--{b=0x0000, e=0x007F}, --Basic Latin
	--{b=0x0000, e=0x002F}, --Basic Latin - Special Characters
	--{b=0x0030, e=0x0039}, --Basic Latin - Digits
	--{b=0x003A, e=0x0040}, --Basic Latin - Special Characters
	--{b=0x0041, e=0x005A}, --Basic Latin - Upper Case Letters
	--{b=0x005B, e=0x0060}, --Basic Latin - Special Characters
	--{b=0x0061, e=0x007A}, --Basic Latin - Lower Case Letters
	--{b=0x007B, e=0x007F}, --Basic Latin - Special Characters
	{b=0x0080, e=0x00FF}, --C1 Controls and Latin-1 Supplement
	{b=0x0100, e=0x017F}, --Latin Extended-A
	{b=0x0180, e=0x024F}, --Latin Extended-B
	{b=0x0250, e=0x02AF}, --IPA Extensions
	{b=0x02B0, e=0x02FF}, --Spacing Modifier Letters
	{b=0x0300, e=0x036F}, --Combining Diacritical Marks
	{b=0x0370, e=0x03FF}, --Greek/Coptic
	{b=0x0400, e=0x04FF}, --Cyrillic
	{b=0x0500, e=0x052F}, --Cyrillic Supplement
	--{b=0x0530, e=0x058F}, --Armenian
	--{b=0x0590, e=0x05FF}, --Hebrew
	--{b=0x0600, e=0x06FF}, --Arabic
	--{b=0x0700, e=0x074F}, --Syriac
	{b=0x0750, e=0x077F}, --Undefined
	--{b=0x0780, e=0x07BF}, --Thaana
	{b=0x07C0, e=0x08FF}, --Undefined
	--{b=0x0900, e=0x097F}, --Devanagari
	--{b=0x0980, e=0x09FF}, --Bengali/Assamese
	--{b=0x0A00, e=0x0A7F}, --Gurmukhi
	--{b=0x0A80, e=0x0AFF}, --Gujarati
	--{b=0x0B00, e=0x0B7F}, --Oriya
	--{b=0x0B80, e=0x0BFF}, --Tamil
	--{b=0x0C00, e=0x0C7F}, --Telugu
	--{b=0x0C80, e=0x0CFF}, --Kannada
	--{b=0x0D00, e=0x0DFF}, --Malayalam
	--{b=0x0D80, e=0x0DFF}, --Sinhala
	--{b=0x0E00, e=0x0E7F}, --Thai
	--{b=0x0E80, e=0x0EFF}, --Lao
	--{b=0x0F00, e=0x0FFF}, --Tibetan
	--{b=0x1000, e=0x109F}, --Myanmar
	--{b=0x10A0, e=0x10FF}, --Georgian
	--{b=0x1100, e=0x11FF}, --Hangul Jamo
	--{b=0x1200, e=0x137F}, --Ethiopic
	{b=0x1380, e=0x139F}, --Undefined
	--{b=0x13A0, e=0x13FF}, --Cherokee
	--{b=0x1400, e=0x167F}, --Unified Canadian Aboriginal Syllabics
	--{b=0x1680, e=0x169F}, --Ogham
	--{b=0x16A0, e=0x16FF}, --Runic
	--{b=0x1700, e=0x171F}, --Tagalog
	--{b=0x1720, e=0x173F}, --Hanunoo
	--{b=0x1740, e=0x175F}, --Buhid
	--{b=0x1760, e=0x177F}, --Tagbanwa
	--{b=0x1780, e=0x17FF}, --Khmer
	--{b=0x1800, e=0x18AF}, --Mongolian
	{b=0x18B0, e=0x18FF}, --Undefined
	--{b=0x1900, e=0x194F}, --Limbu
	--{b=0x1950, e=0x197F}, --Tai Le
	{b=0x1980, e=0x19DF}, --Undefined
	--{b=0x19E0, e=0x19FF}, --Khmer Symbols
	{b=0x1A00, e=0x1CFF}, --Undefined
	{b=0x1D00, e=0x1D7F}, --Phonetic Extensions
	{b=0x1D80, e=0x1DFF}, --Undefined
	{b=0x1E00, e=0x1EFF}, --Latin Extended Additional
	{b=0x1F00, e=0x1FFF}, --Greek Extended
	{b=0x2000, e=0x206F}, --General Punctuation
	{b=0x2070, e=0x209F}, --Superscripts and Subscripts
	{b=0x20A0, e=0x20CF}, --Currency Symbols
	{b=0x20D0, e=0x20FF}, --Combining Diacritical Marks for Symbols
	{b=0x2100, e=0x214F}, --Letterlike Symbols
	{b=0x2150, e=0x218F}, --Number Forms
	{b=0x2190, e=0x21FF}, --Arrows
	{b=0x2200, e=0x22FF}, --Mathematical Operators
	{b=0x2300, e=0x23FF}, --Miscellaneous Technical
	{b=0x2400, e=0x243F}, --Control Pictures
	{b=0x2440, e=0x245F}, --Optical Character Recognition
	{b=0x2460, e=0x24FF}, --Enclosed Alphanumerics
	{b=0x2500, e=0x257F}, --Box Drawing
	{b=0x2580, e=0x259F}, --Block Elements
	{b=0x25A0, e=0x25FF}, --Geometric Shapes
	{b=0x2600, e=0x26FF}, --Miscellaneous Symbols
	{b=0x2700, e=0x27BF}, --Dingbats
	{b=0x27C0, e=0x27EF}, --Miscellaneous Mathematical Symbols-A
	{b=0x27F0, e=0x27FF}, --Supplemental Arrows-A
	{b=0x2800, e=0x28FF}, --Braille Patterns
	{b=0x2900, e=0x297F}, --Supplemental Arrows-B
	{b=0x2980, e=0x29FF}, --Miscellaneous Mathematical Symbols-B
	{b=0x2A00, e=0x2AFF}, --Supplemental Mathematical Operators
	{b=0x2B00, e=0x2BFF}, --Miscellaneous Symbols and Arrows
	{b=0x2C00, e=0x2E7F}, --Undefined
	--{b=0x2E80, e=0x2EFF}, --CJK Radicals Supplement
	--{b=0x2F00, e=0x2FDF}, --Kangxi Radicals
	{b=0x2FE0, e=0x2EEF}, --Undefined
	{b=0x2FF0, e=0x2FFF}, --Ideographic Description Characters
	--{b=0x3000, e=0x303F}, --CJK Symbols and Punctuation
	--{b=0x3040, e=0x309F}, --Hiragana
	--{b=0x30A0, e=0x30FF}, --Katakana
	--{b=0x3100, e=0x312F}, --Bopomofo
	{b=0x3130, e=0x318F}, --Hangul Compatibility Jamo
	--{b=0x3190, e=0x319F}, --Kanbun (Kunten)
	--{b=0x31A0, e=0x31BF}, --Bopomofo Extended
	{b=0x31C0, e=0x31EF}, --Undefined
	--{b=0x31F0, e=0x31FF}, --Katakana Phonetic Extensions
	{b=0x3200, e=0x32FF}, --Enclosed CJK Letters and Months
	{b=0x3300, e=0x33FF}, --CJK Compatibility
	{b=0x3400, e=0x4DBF}, --CJK Unified Ideographs Extension A
	{b=0x4DC0, e=0x4DFF}, --Yijing Hexagram Symbols
	--{b=0x4E00, e=0x9FAF}, --CJK Unified Ideographs
	{b=0x9FB0, e=0x9FFF}, --Undefined
	{b=0xA000, e=0xA48F}, --Yi Syllables
	{b=0xA490, e=0xA4CF}, --Yi Radicals
	{b=0xA4D0, e=0xABFF}, --Undefined
	--{b=0xAC00, e=0xD7AF}, --Hangul Syllables
	{b=0xD7B0, e=0xD7FF}, --Undefined
	{b=0xD800, e=0xDBFF}, --High Surrogate Area
	{b=0xDC00, e=0xDFFF}, --Low Surrogate Area
	{b=0xE000, e=0xF8FF}, --Private Use Area
	{b=0xF900, e=0xFAFF}, --CJK Compatibility Ideographs
	{b=0xFB00, e=0xFB4F}, --Alphabetic Presentation Forms
	--{b=0xFB50, e=0xFDFF}, --Arabic Presentation Forms-A
	{b=0xFE00, e=0xFE0F}, --Variation Selectors
	{b=0xFE10, e=0xFE1F}, --Undefined
	{b=0xFE20, e=0xFE2F}, --Combining Half Marks
	{b=0xFE30, e=0xFE4F}, --CJK Compatibility Forms
	--{b=0xFE50, e=0xFE6F}, --Small Form Variants
	--{b=0xFE70, e=0xFEFF}, --Arabic Presentation Forms-B
	--{b=0xFF00, e=0xFFEF}, --Halfwidth and Fullwidth Forms
	{b=0xFFF0, e=0xFFFF}, --Specials
	{b=0x10000, e=0x1007F}, --Linear B Syllabary
	{b=0x10080, e=0x100FF}, --Linear B Ideograms
	{b=0x10100, e=0x1013F}, --Aegean Numbers
	{b=0x10140, e=0x102FF}, --Undefined
	{b=0x10300, e=0x1032F}, --Old Italic
	{b=0x10330, e=0x1034F}, --Gothic
	{b=0x10380, e=0x1039F}, --Ugaritic
	{b=0x10400, e=0x1044F}, --Deseret
	--{b=0x10450, e=0x1047F}, --Shavian
	--{b=0x10480, e=0x104AF}, --Osmanya
	{b=0x104B0, e=0x107FF}, --Undefined
	{b=0x10800, e=0x1083F}, --Cypriot Syllabary
	{b=0x10840, e=0x1CFFF}, --Undefined
	{b=0x1D000, e=0x1D0FF}, --Byzantine Musical Symbols
	{b=0x1D100, e=0x1D1FF}, --Musical Symbols
	{b=0x1D200, e=0x1D2FF}, --Undefined
	{b=0x1D300, e=0x1D35F}, --Tai Xuan Jing Symbols
	{b=0x1D360, e=0x1D3FF}, --Undefined
	{b=0x1D400, e=0x1D7FF}, --Mathematical Alphanumeric Symbols
	{b=0x1D800, e=0x1FFFF}, --Undefined
	{b=0x20000, e=0x2A6DF}, --CJK Unified Ideographs Extension B
	{b=0x2A6E0, e=0x2F7FF}, --Undefined
	{b=0x2F800, e=0x2FA1F}, --CJK Compatibility Ideographs Supplement
	{b=0x2FAB0, e=0xDFFFF}, --Unused
	{b=0xE0000, e=0xE007F}, --Tags
	{b=0xE0080, e=0xE00FF}, --Unused
	{b=0xE0100, e=0xE01EF}, --Variation Selectors Supplement
	{b=0xE01F0, e=0xEFFFF}, --Unused
	{b=0xF0000, e=0xFFFFD}, --Supplementary Private Use Area-A
	{b=0xFFFFE, e=0xFFFFF}, --Unused
	{b=0x100000, e=0x10FFFD}, --Supplementary Private Use Area-B
}

local non_meaningful_text_chars ={
	--{b=0x0000, e=0x007F}, --Basic Latin
	{b=0x0000, e=0x002F}, --Basic Latin - Special Characters
	--{b=0x0030, e=0x0039}, --Basic Latin - Digits
	{b=0x003A, e=0x0040}, --Basic Latin - Special Characters
	--{b=0x0041, e=0x005A}, --Basic Latin - Upper Case Letters
	{b=0x005B, e=0x0060}, --Basic Latin - Special Characters
	--{b=0x0061, e=0x007A}, --Basic Latin - Lower Case Letters
	{b=0x007B, e=0x007F}, --Basic Latin - Special Characters
	{b=0x0080, e=0x00FF}, --C1 Controls and Latin-1 Supplement
	{b=0x0100, e=0x017F}, --Latin Extended-A
	{b=0x0180, e=0x024F}, --Latin Extended-B
	{b=0x0250, e=0x02AF}, --IPA Extensions
	{b=0x02B0, e=0x02FF}, --Spacing Modifier Letters
	{b=0x0300, e=0x036F}, --Combining Diacritical Marks
	{b=0x0370, e=0x03FF}, --Greek/Coptic
	{b=0x0400, e=0x04FF}, --Cyrillic
	{b=0x0500, e=0x052F}, --Cyrillic Supplement
	--{b=0x0530, e=0x058F}, --Armenian
	--{b=0x0590, e=0x05FF}, --Hebrew
	--{b=0x0600, e=0x06FF}, --Arabic
	--{b=0x0700, e=0x074F}, --Syriac
	{b=0x0750, e=0x077F}, --Undefined
	--{b=0x0780, e=0x07BF}, --Thaana
	{b=0x07C0, e=0x08FF}, --Undefined
	--{b=0x0900, e=0x097F}, --Devanagari
	--{b=0x0980, e=0x09FF}, --Bengali/Assamese
	--{b=0x0A00, e=0x0A7F}, --Gurmukhi
	--{b=0x0A80, e=0x0AFF}, --Gujarati
	--{b=0x0B00, e=0x0B7F}, --Oriya
	--{b=0x0B80, e=0x0BFF}, --Tamil
	--{b=0x0C00, e=0x0C7F}, --Telugu
	--{b=0x0C80, e=0x0CFF}, --Kannada
	--{b=0x0D00, e=0x0DFF}, --Malayalam
	--{b=0x0D80, e=0x0DFF}, --Sinhala
	--{b=0x0E00, e=0x0E7F}, --Thai
	--{b=0x0E80, e=0x0EFF}, --Lao
	--{b=0x0F00, e=0x0FFF}, --Tibetan
	--{b=0x1000, e=0x109F}, --Myanmar
	--{b=0x10A0, e=0x10FF}, --Georgian
	--{b=0x1100, e=0x11FF}, --Hangul Jamo
	--{b=0x1200, e=0x137F}, --Ethiopic
	{b=0x1380, e=0x139F}, --Undefined
	--{b=0x13A0, e=0x13FF}, --Cherokee
	--{b=0x1400, e=0x167F}, --Unified Canadian Aboriginal Syllabics
	--{b=0x1680, e=0x169F}, --Ogham
	--{b=0x16A0, e=0x16FF}, --Runic
	--{b=0x1700, e=0x171F}, --Tagalog
	--{b=0x1720, e=0x173F}, --Hanunoo
	--{b=0x1740, e=0x175F}, --Buhid
	--{b=0x1760, e=0x177F}, --Tagbanwa
	--{b=0x1780, e=0x17FF}, --Khmer
	--{b=0x1800, e=0x18AF}, --Mongolian
	{b=0x18B0, e=0x18FF}, --Undefined
	--{b=0x1900, e=0x194F}, --Limbu
	--{b=0x1950, e=0x197F}, --Tai Le
	{b=0x1980, e=0x19DF}, --Undefined
	--{b=0x19E0, e=0x19FF}, --Khmer Symbols
	{b=0x1A00, e=0x1CFF}, --Undefined
	{b=0x1D00, e=0x1D7F}, --Phonetic Extensions
	{b=0x1D80, e=0x1DFF}, --Undefined
	{b=0x1E00, e=0x1EFF}, --Latin Extended Additional
	{b=0x1F00, e=0x1FFF}, --Greek Extended
	{b=0x2000, e=0x206F}, --General Punctuation
	{b=0x2070, e=0x209F}, --Superscripts and Subscripts
	{b=0x20A0, e=0x20CF}, --Currency Symbols
	{b=0x20D0, e=0x20FF}, --Combining Diacritical Marks for Symbols
	{b=0x2100, e=0x214F}, --Letterlike Symbols
	{b=0x2150, e=0x218F}, --Number Forms
	{b=0x2190, e=0x21FF}, --Arrows
	{b=0x2200, e=0x22FF}, --Mathematical Operators
	{b=0x2300, e=0x23FF}, --Miscellaneous Technical
	{b=0x2400, e=0x243F}, --Control Pictures
	{b=0x2440, e=0x245F}, --Optical Character Recognition
	{b=0x2460, e=0x24FF}, --Enclosed Alphanumerics
	{b=0x2500, e=0x257F}, --Box Drawing
	{b=0x2580, e=0x259F}, --Block Elements
	{b=0x25A0, e=0x25FF}, --Geometric Shapes
	{b=0x2600, e=0x26FF}, --Miscellaneous Symbols
	{b=0x2700, e=0x27BF}, --Dingbats
	{b=0x27C0, e=0x27EF}, --Miscellaneous Mathematical Symbols-A
	{b=0x27F0, e=0x27FF}, --Supplemental Arrows-A
	{b=0x2800, e=0x28FF}, --Braille Patterns
	{b=0x2900, e=0x297F}, --Supplemental Arrows-B
	{b=0x2980, e=0x29FF}, --Miscellaneous Mathematical Symbols-B
	{b=0x2A00, e=0x2AFF}, --Supplemental Mathematical Operators
	{b=0x2B00, e=0x2BFF}, --Miscellaneous Symbols and Arrows
	{b=0x2C00, e=0x2E7F}, --Undefined
	--{b=0x2E80, e=0x2EFF}, --CJK Radicals Supplement
	--{b=0x2F00, e=0x2FDF}, --Kangxi Radicals
	{b=0x2FE0, e=0x2EEF}, --Undefined
	{b=0x2FF0, e=0x2FFF}, --Ideographic Description Characters
	{b=0x3000, e=0x303F}, --CJK Symbols and Punctuation
	--{b=0x3040, e=0x309F}, --Hiragana
	--{b=0x30A0, e=0x30FF}, --Katakana
	--{b=0x3100, e=0x312F}, --Bopomofo
	{b=0x3130, e=0x318F}, --Hangul Compatibility Jamo
	--{b=0x3190, e=0x319F}, --Kanbun (Kunten)
	--{b=0x31A0, e=0x31BF}, --Bopomofo Extended
	{b=0x31C0, e=0x31EF}, --Undefined
	--{b=0x31F0, e=0x31FF}, --Katakana Phonetic Extensions
	{b=0x3200, e=0x32FF}, --Enclosed CJK Letters and Months
	{b=0x3300, e=0x33FF}, --CJK Compatibility
	{b=0x3400, e=0x4DBF}, --CJK Unified Ideographs Extension A
	{b=0x4DC0, e=0x4DFF}, --Yijing Hexagram Symbols
	--{b=0x4E00, e=0x9FAF}, --CJK Unified Ideographs
	{b=0x9FB0, e=0x9FFF}, --Undefined
	{b=0xA000, e=0xA48F}, --Yi Syllables
	{b=0xA490, e=0xA4CF}, --Yi Radicals
	{b=0xA4D0, e=0xABFF}, --Undefined
	--{b=0xAC00, e=0xD7AF}, --Hangul Syllables
	{b=0xD7B0, e=0xD7FF}, --Undefined
	{b=0xD800, e=0xDBFF}, --High Surrogate Area
	{b=0xDC00, e=0xDFFF}, --Low Surrogate Area
	{b=0xE000, e=0xF8FF}, --Private Use Area
	{b=0xF900, e=0xFAFF}, --CJK Compatibility Ideographs
	{b=0xFB00, e=0xFB4F}, --Alphabetic Presentation Forms
	--{b=0xFB50, e=0xFDFF}, --Arabic Presentation Forms-A
	{b=0xFE00, e=0xFE0F}, --Variation Selectors
	{b=0xFE10, e=0xFE1F}, --Undefined
	{b=0xFE20, e=0xFE2F}, --Combining Half Marks
	{b=0xFE30, e=0xFE4F}, --CJK Compatibility Forms
	--{b=0xFE50, e=0xFE6F}, --Small Form Variants
	--{b=0xFE70, e=0xFEFF}, --Arabic Presentation Forms-B
	{b=0xFF00, e=0xFFEF}, --Halfwidth and Fullwidth Forms
	{b=0xFFF0, e=0xFFFF}, --Specials
	{b=0x10000, e=0x1007F}, --Linear B Syllabary
	{b=0x10080, e=0x100FF}, --Linear B Ideograms
	{b=0x10100, e=0x1013F}, --Aegean Numbers
	{b=0x10140, e=0x102FF}, --Undefined
	{b=0x10300, e=0x1032F}, --Old Italic
	{b=0x10330, e=0x1034F}, --Gothic
	{b=0x10380, e=0x1039F}, --Ugaritic
	{b=0x10400, e=0x1044F}, --Deseret
	--{b=0x10450, e=0x1047F}, --Shavian
	--{b=0x10480, e=0x104AF}, --Osmanya
	{b=0x104B0, e=0x107FF}, --Undefined
	{b=0x10800, e=0x1083F}, --Cypriot Syllabary
	{b=0x10840, e=0x1CFFF}, --Undefined
	{b=0x1D000, e=0x1D0FF}, --Byzantine Musical Symbols
	{b=0x1D100, e=0x1D1FF}, --Musical Symbols
	{b=0x1D200, e=0x1D2FF}, --Undefined
	{b=0x1D300, e=0x1D35F}, --Tai Xuan Jing Symbols
	{b=0x1D360, e=0x1D3FF}, --Undefined
	{b=0x1D400, e=0x1D7FF}, --Mathematical Alphanumeric Symbols
	{b=0x1D800, e=0x1FFFF}, --Undefined
	{b=0x20000, e=0x2A6DF}, --CJK Unified Ideographs Extension B
	{b=0x2A6E0, e=0x2F7FF}, --Undefined
	{b=0x2F800, e=0x2FA1F}, --CJK Compatibility Ideographs Supplement
	{b=0x2FAB0, e=0xDFFFF}, --Unused
	{b=0xE0000, e=0xE007F}, --Tags
	{b=0xE0080, e=0xE00FF}, --Unused
	{b=0xE0100, e=0xE01EF}, --Variation Selectors Supplement
	{b=0xE01F0, e=0xEFFFF}, --Unused
	{b=0xF0000, e=0xFFFFD}, --Supplementary Private Use Area-A
	{b=0xFFFFE, e=0xFFFFF}, --Unused
	{b=0x100000, e=0x10FFFD}, --Supplementary Private Use Area-B
}

-- check if unicode table cotains sick chars (garbage chars)
-- return: len, garbage
-- len: length of string (in utf8 encoding)
-- garbage: true/false, true if contains garbage chars
local function contains_sickchars(utfstr)
	if(utfstr == nil or utfstr == "") then
		return 0, false
	end
	
	local unicode_table = utf8to32(utfstr)
	local len = #unicode_table

	len = len -1 

	for key, uchar in pairs(unicode_table) do
		if(uchar~=0) then 
			for _, garbage_block in pairs(sickchars) do
				if(uchar>=garbage_block.b and uchar<=garbage_block.e) then
					--print("key=", key)
					return len, true
				end
			end
		end
	end

	return len, false
end

-- check if a utf string don't contains any meaningful char
-- return: len, non_meaningful
-- len: length of string (in utf8 encoding)
-- non_meaningful: true/false, true if string has no meanful char
local function all_non_meaningful(utfstr)
	if(utfstr == nil or utfstr == "") then
		return 0, true
	end
	
	local unicode_table = utf8to32(utfstr)
	local len = #unicode_table

	len = len -1 

	for key, uchar in pairs(unicode_table) do
		if(uchar~=0) then 
			meaningful = true
			for _, nontext_block in pairs(non_meaningful_text_chars) do
				if(uchar>=nontext_block.b and uchar<=nontext_block.e) then
					meaningful = false
					break
				end
			end
			if(meaningful) then
				return len, false
			end
		end
	end

	return len, true
end

-- if message contains rt# icon
function find_icon(str)
	local pos = string.find(str, "{rt%d}")
	if pos ~= nil then
		return true
	end
	return false
end

function find_link(str)
	local pos = string.find(str, "|Hitem:%d+:.-|h.-|h")
	if pos ~= nil then
		return true
	end
	return false
end

-----------------------------------------------------
----- Filter functions

-- load db
function FilterProcessor:loaddb()
	
	-- players in learning
	-- addon.db.global.plist = addon.db.global.plist or {}

	-- prelearning data 
	-- addon.db.global.prelearning = addon.db.global.prelearning or {}

	-- features table, calculated features db from plist
	-- addon.db.global.pfeatures = addon.db.global.pfeatures or {}

	self:UpdateFilterScore(addon.db.global.filtering_level)
end

function FilterProcessor:UpdateFilterScore(key)
	-- if not found, default to "4" - spammer
	self.filter_score = addon.db.global.level_score_map[addon.db.global.filtering_level] or "4"
	addon:log(L["At current level, block spam score set to: "] .. self.filter_score)
end

-- when module initialing
function FilterProcessor:OnInitialize()
	-- addon:log("Filter db loaded.")

	-- set analysis timestamp flag
	self.analysis_last_run = time()

	-- set compact db timestamp flag
	self.compactdb_last_run = time()

	FilterProcessor:loaddb()
end

-- when new message arrived
-- return result, score:
-- result: false: let go, true:block the message
-- score: the spam score
function FilterProcessor:OnNewMessage(...)
	local msgdata = ...

	--addon:log("OnNewMessage: " .. msgdata.from)

	if msgdata.guid == nil or msgdata.guid == "" then
		-- addon:log("Empty guid, skipped")
		return false, 0
	end

	self:PreLearning(msgdata)
	-- if the user is not talkative, skip learning the user
	prelearning_user = addon.db.global.prelearning[msgdata.guid]
	if( not addon.db.global.prelearning[msgdata.guid].learning ) then
		-- addon:log("skip non-talkative user " .. msgdata.from .. ", msg=" .. msgdata.message)
		return false, 0
	end

	-- reset limitation triggers
	self.player_limitation_trigger = false
	self.content_limitation_trigger = false

	-- learning the talkative user
	self:LearnMessage(msgdata)

	-- setup a analysis timer
	self:Analysis()

	-- setup a compact db timer
	-- not using timer, compact db after analysis
	-- self:CompactDB()

	-- only filter messages when switch set to on
	if addon.db.global.message_filter_switch then 
		local pfeature = addon.db.global.pfeatures[msgdata.guid]
		if addon.db.global.pfeatures[msgdata.guid] ~= nil then
			if ( pfeature.score >= self.filter_score ) then
				--addon:log("[Block] " .. pfeature.name .. ", score=" .. pfeature.score )
				return true, pfeature.score 
			else
				--addon:log("[Not block] " .. pfeature.name .. ", score=" .. pfeature.score )
			end
		end

	end

	-- if limitation triggered
	if self.player_limitation_trigger or self.content_limitation_trigger then
		--addon:log("player:" .. tostring(self.player_limitation_trigger) .. ", content:" .. tostring(self.content_limitation_trigger))
		--addon:log("[Block]: " .. msgdata.from .. " [" .. msgdata.message .. "]")
		return true, 0		
	end

end

-- API: IsBlock(guid)
-- guid: the player guid returned from GetPlayerInfoByGUID
function FilterProcessor:IsBlock(guid)
	local pfeature = addon.db.global.pfeatures[guid]
	if addon.db.global.pfeatures[guid] ~= nil then
		if ( pfeature.score >= self.filter_score ) then
			-- addon:log("isblock " .. guid .. ", score=" .. pfeature.score)
			return true, pfeature.score 
		end
	end
	return false, 0
end

-- get player's spam score
function FilterProcessor:SpamScore(guid)
	local pfeature = addon.db.global.pfeatures[guid]
	if addon.db.global.pfeatures[guid] ~= nil then
		return pfeature.score 
	end
	return 0
end

-- analysis the data and calculate spam scores
function FilterProcessor:Analysis()
	local timelapsed = time()-self.analysis_last_run
	if timelapsed<addon.db.global.analysis.interval then
		return
	end

	-- update analysis timestamp flag
	self.analysis_last_run = time()

	-- compute spam scores using threaded process to avoid blocking current thread
	self:SetupAnalysisTimer()

end

-- compact db if timer reached
function FilterProcessor:CompactDB()
		local timelapsed = time()-self.compactdb_last_run
	if timelapsed<addon.db.global.compactdb.interval then
		return
	end

	-- update analysis timestamp flag
	self.compactdb_last_run = time()

	-- setup compact db timer
	self:SetupCompactDBTimer()

end
-- before message pass to leaning engine, user must meet the conditions which indicate the user is likely a spammer
-- it's a measure to improve performance and save db space
function FilterProcessor:PreLearning(msgdata)

	-- get #hour since os.time() start since 1970
	hournumber = math.floor(msgdata.receive_time / 3600)
	-- get #day since os.time() start since 1970
	daynumber = math.floor(msgdata.receive_time / 86400)
	-- get 5-days window number since 1970
	penaltynumber = math.floor(msgdata.receive_time / 432000)
	
	local pdata = addon.db.global.prelearning[msgdata.guid]

	-- If new sender
	if(pdata == nil) then
		pdata = {}
		pdata = {
			name = msgdata.from,  -- for debug purpose, removed in release version to save db space or leave for easy debug
			hourwindow = hournumber,
			hourlycount = 1,
			daywindow = daynumber,
			dailycount = 1,
			penaltywindow = penaltynumber,
			penaltycount = 0,
			learning = false,
		}
		addon.db.global.prelearning[msgdata.guid] = pdata
	-- if existing sender
	else
		-- if user under learning, unlearned if user's message count lower than threshold in penaltywindow
		if(pdata.learning) then
			-- same penaltywindow
			if(pdata.penaltywindow == penaltynumber) then
				pdata.penaltycount = pdata.penaltycount + 1
			-- new penaltywindow
			else
				-- if messages count sent by the user lower than threshold in previous penalty window
				if pdata.penaltycount<addon.db.global.penalty_threshold then
					-- reset penalty window and counter
					pdata.penaltywindow = penaltynumber
					pdata.penaltycount = 0
					-- mark the user should be removed from learning process
					pdata.learning = false
					if not addon.db.global.do_not_disturb then
						addon:log(msgdata.from .. L["'s behavior return normal and removed from the learning process."])
					end
				else
					pdata.penaltywindow = penaltynumber
					pdata.penaltycount = 1
				end
			end
		else
			-- hour window, hour is the same with saved hour number, increase counter
			if pdata.hourwindow == hournumber then
				pdata.hourlycount = pdata.hourlycount + 1
				--addon:log(msgdata.from .. " pdata.hourlycount increase by 1: " .. tostring(pdata.hourlycount))
			-- new hour number, reset counter
			else
				pdata.hourwindow = hournumber
				pdata.hourlycount = 1
			end

			-- day window
			if pdata.daywindow == daynumber then
				pdata.dailycount = pdata.dailycount + 1
			else
				pdata.daywindow = daywindow
				pdata.dailycount = 1
			end

			-- check hourly count beyond threshold, mark the user should be learned
			if pdata.hourlycount>addon.db.global.hourly_learning_threshold then
				pdata.learning = true
				if not addon.db.global.do_not_disturb then
					addon:log(msgdata.from .. L[" was talkative in last hour and added to learning process."])
				end
			else
				-- if daily count exceed threshold
				if pdata.dailycount>addon.db.global.daily_learning_threshold then
					pdata.learning = true
					if not addon.db.global.do_not_disturb then
						addon:log(msgdata.from .. L[" was talkative in last day and added to learning process."])
					end
				end
			end
		end
	end

	-- set update time
	pdata.updatetime = time()

end

-- learn the message and store metrics data into db
function FilterProcessor:LearnMessage(msgdata)
	--addon:log("leaning [" .. msgdata.from .. "] channal=[" .. msgdata.chan_id_name .. "] msg=" .. msgdata.message)
	--local md5str = md5.sumhexa(msgdata.message)

	-- using channel number + hash of message as message key
	hashstr =  msgdata.chan_num .. ":" .. StringHash(msgdata.message)
	msgdata.hash = hashstr

	-- set limitation trigger flag from DB
	--self:SetLimitationTriggerWithDB()

	-- set limitation trigger flag in memory, support all players include those not under learning
	self:CalcLimitationTriggerInMem()

	self:BehaviorNewMessage(msgdata)

	-- update limitation trigger with db
	-- self:UpdateLimitationTriggerWithDB()

	-- update limitation trigger in memory
	self:UpdateLimitationTriggerInMem()
end

-- set player or messge limitation trigger
function FilterProcessor:CalcLimitationTriggerInMem()
	-- set discard flag if interval limitation of same player triggered
	-- if interval set and player exists
	if addon.db.global.min_interval_same_player>0 and private.plist[msgdata.guid] then
		--addon:log( "[INT PLAYER] " .. msgdata.from .. " exists, limit=" .. addon.db.global.min_interval_same_player )
		-- if last accept time exists
		if private.plist[msgdata.guid].last_accept_time ~= nil then
			local diff = msgdata.receive_time - private.plist[msgdata.guid].last_accept_time
			--addon:log( "[INT PLAYER] " .. msgdata.from .. " has last_accept_time, diff=" .. diff )
			-- if within the limited period
			if diff <= addon.db.global.min_interval_same_player then
				--addon:log( "[INT PLAYER Block] " .. msgdata.from .. " " .. diff .. "<=" .. addon.db.global.min_interval_same_player)
				-- set trigger flag
				self.player_limitation_trigger = true
			-- if not triggered
			end
		end
	end

	-- set discard flag if interval limitation of same content triggered
	-- if interval set and player exists
	if addon.db.global.min_interval_same_message>0 and private.plist[msgdata.guid] then
		--addon:log( "[INT MSG] " .. msgdata.from .. " exists, limit=" .. addon.db.global.min_interval_same_message )
		-- content exists
		if private.plist[msgdata.guid].msgs[msgdata.hash] then
			--addon:log( "[INT MSG] " .. msgdata.from .. " same message exists" )
			-- if last accept time exists
			if private.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time ~= nil then
				local diff = msgdata.receive_time - private.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time
				--addon:log( "[INT MSG] " .. msgdata.from .. " same message has last_accept_time, diff=" .. diff .. " vs " .. addon.db.global.min_interval_same_message )
				-- if within the limited period
				if diff <= addon.db.global.min_interval_same_message then
					--addon:log( "[INT MSG Block] " .. msgdata.from .. " " .. diff .. "<=" .. addon.db.global.min_interval_same_message)
					-- set trigger flag
					self.content_limitation_trigger = true
				-- if not triggered
				end
			end
		end
	end

	-- get or set plist data 
	if private.plist[msgdata.guid] == nil then
		private.plist[msgdata.guid] = {
			msgs = {},
			last_accept_time = msgdata.receive_time,
		}
	end

	-- get or set messages node
	if private.plist[msgdata.guid].msgs[msgdata.hash] == nil then
		private.plist[msgdata.guid].msgs[msgdata.hash] = { last_accept_time = msgdata.receive_time }
	end
end

-- Update accept time with db
function FilterProcessor:UpdateLimitationTriggerInMem()

	-- if same player limitation not triggered
	if not self.player_limitation_trigger then
		-- update player's last_accept_time
		private.plist[msgdata.guid].last_accept_time = msgdata.receive_time
	end

	-- if same content limitation not triggered
	if not self.content_limitation_trigger then
		-- update content's last_accept_time
		private.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time = msgdata.receive_time
	end
end

-- set player or messge limitation trigger
function FilterProcessor:CalcLimitationTriggerWithDB()
	-- set discard flag if interval limitation of same player triggered
	-- if interval set and player exists
	if addon.db.global.min_interval_same_player>0 and addon.db.global.plist[msgdata.guid] then
		--addon:log( "[INT PLAYER] " .. msgdata.from .. " exists, limit=" .. addon.db.global.min_interval_same_player )
		-- if last accept time exists
		if addon.db.global.plist[msgdata.guid].last_accept_time ~= nil then
			--addon:log( "[INT PLAYER] " .. msgdata.from .. " has last_accept_time, diff=" .. (msgdata.receive_time - addon.db.global.plist[msgdata.guid].last_accept_time) )
			-- if within the limited period
			if msgdata.receive_time - addon.db.global.plist[msgdata.guid].last_accept_time <= addon.db.global.min_interval_same_player then
				--addon:log( "[INT PLAYER Block] " .. msgdata.from .. " " .. (msgdata.receive_time - addon.db.global.plist[msgdata.guid].last_accept_time) .. "<=" .. addon.db.global.min_interval_same_player)
				-- set trigger flag
				self.player_limitation_trigger = true
			-- if not triggered
			end
		end
	end

	-- set discard flag if interval limitation of same content triggered
	-- if interval set and player exists
	if addon.db.global.min_interval_same_message>0 and addon.db.global.plist[msgdata.guid] then
		--addon:log( "[INT MSG] " .. msgdata.from .. " exists, limit=" .. addon.db.global.min_interval_same_message )
		-- content exists
		if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash] then
			--addon:log( "[INT MSG] " .. msgdata.from .. " same message exists" )
			-- if last accept time exists
			if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time ~= nil then
				--addon:log( "[INT MSG] " .. msgdata.from .. " same message has last_accept_time, diff=" .. (msgdata.receive_time - addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time) )
				-- if within the limited period
				if msgdata.receive_time - addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time <= addon.db.global.min_interval_same_message then
					--addon:log( "[INT MSG Block] " .. msgdata.from .. " " .. (msgdata.receive_time - addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time) .. "<=" .. addon.db.global.min_interval_same_message)
					-- set trigger flag
					self.content_limitation_trigger = true
				-- if not triggered
				end
			end
		end
	end
end

-- Update accept time with db
function FilterProcessor:UpdateLimitationTriggerWithDB()

	-- if same player limitation not triggered
	if not self.player_limitation_trigger then
		-- update player's last_accept_time
		addon.db.global.plist[msgdata.guid].last_accept_time = msgdata.receive_time
	end

	-- if same content limitation not triggered
	if not self.content_limitation_trigger then
		-- update content's last_accept_time
		addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_accept_time = msgdata.receive_time
	end
end

-- learn user messaging behavior
function FilterProcessor:BehaviorNewMessage(msgdata)
	local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(msgdata.guid)
	local len, hassick, notmeaningful, hasicon, haslink = self:GetMsgSpec(msgdata.message)

	--[[
	if(hassick or notmeaningful) then 
		addon:log("spamlike msg=" .. msgdata.message)
	end
	]]

	-- get or set plist data 
	addon.db.global.plist[msgdata.guid] = addon.db.global.plist[msgdata.guid] or {
			name = msgdata.from,
			class = string.lower(engClass),
			msgs = {},
			last_accept_time = msgdata.receive_time,
		}

	-- get or set messages node
	addon.db.global.plist[msgdata.guid].msgs[msgdata.hash] = addon.db.global.plist[msgdata.guid].msgs[msgdata.hash] or {
			len = len,
			--msg = msgdata.message, -- save message, for debug purpose, must be removed in release version
			spamlike = hassick or notmeaningful,
			hasicon = hasicon,
			haslink = haslink,
			-- event = msgdata.event, -- for debug purpose
			first_time = msgdata.receive_time,
			last_time = msgdata.receive_time,
			last_accept_time = msgdata.receive_time,
			lastperiod = 0,
			samplings = {
				all_time = {0, 0, msgdata.chan_num, 0, nil},
				last_hour = {},
				last_week = {},
			},
		}
	-- for debug purpose
	--[[
	if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].msg == nil then
		addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].msg = msgdata.message
	end
	]]

	-- to compatible upgrade from existing db
	if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.all_time == nil then
		addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.all_time = {0, 0, msgdata.chan_num, 0, nil}
	end
	if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_hour == nil then
		addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_hour = {}
	end
	if addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_week == nil then
		addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_week = {}
	end

	-- perform all samplings
	self:PerformAllSampling(msgdata, addon.db.global.plist[msgdata.guid].msgs[msgdata.hash])

	-- update last_time to message receival time
	addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].last_time = msgdata.receive_time

end

-- perform all sampling
function FilterProcessor:PerformAllSampling(msgdata, msgnode)
	-- addon:log("Sampling message: " .. msgdata.message)
	-- full time sampling
	self:Sampling(msgdata, msgnode, msgnode.samplings.all_time, true)

	-- do sampling of time frame to get more metrics data
	-- set key as (minute number / 2) results in 30 keys in 60mins
	local key = tostring(math.floor(date("%M", msgdata.receive_time)/2))
	msgnode.samplings.last_hour[key] = msgnode.samplings.last_hour[key] or {0, 0, msgdata.chan_num, 0, nil}
	self:Sampling(msgdata, msgnode, msgnode.samplings.last_hour[key])

	-- set key as weekday number 1-7 = mon-sun
	key = tostring(math.floor(date("%w", msgdata.receive_time)))
	msgnode.samplings.last_week[key] = msgnode.samplings.last_week[key] or {0, 0, msgdata.chan_num, 0, nil}
	self:Sampling(msgdata, msgnode, msgnode.samplings.last_week[key])
end

-- Sampling last hour to store period and message count data into db
-- samplingnode array: {msg_count (1), period_count (2), last_chan_num(3), last_period (4)}
--local MSG_COUNT_IDX = 1
--local PERIOD_COUNT_IDX = 2
--local CHAN_NUM_IDX = 3
--local DEVIATION_AVG_IDX = 4
--local LAST_PERIOD_IDX = 5
function FilterProcessor:Sampling(msgdata, msgnode, samplingnode, alltime)
	local diff_between_msgs = msgdata.receive_time - msgnode.last_time

	if samplingnode[LAST_PERIOD_IDX] ~= nil then
		local deviation = diff_between_msgs - samplingnode[LAST_PERIOD_IDX]
		local deviation_per = deviation/diff_between_msgs
		
		-- find periodcal message
		if( (msgdata.chan_num == samplingnode[CHAN_NUM_IDX]) and (math.abs(deviation_per) < addon.db.global.deviation_threshold) ) then
			--[[
			if(alltime) then
				addon:log("[Sampling] dup and spam, deviation=" .. deviation .. "s/" .. math.floor(deviation_per*1000, 2)/10 .. "% " .. ' [' ..
					diff_between_msgs .. "] seconds: [" .. msgdata.chan_num .. 
					"][" .. msgdata.from .. "] " .. msgdata.message )
			end
			]]
			-- increase the periodcally spam counter by 1
			samplingnode[PERIOD_COUNT_IDX] = samplingnode[PERIOD_COUNT_IDX] + 1
		end

		-- if deviation less than 1, sum the deviation
		if( (msgdata.chan_num == samplingnode[CHAN_NUM_IDX]) and (math.abs(deviation_per) < 1) ) then
			-- sum the deviation
			samplingnode[DEVIATION_AVG_IDX] = samplingnode[DEVIATION_AVG_IDX] + deviation
		end
	end

	-- set lastperiod to latest time diff
	samplingnode[LAST_PERIOD_IDX] = diff_between_msgs
	-- set channel number
	samplingnode[CHAN_NUM_IDX] = msgdata.chan_num
	-- inrease msg counter by 1
	samplingnode[MSG_COUNT_IDX] = samplingnode[MSG_COUNT_IDX] + 1
end

-- return: len, garbage
-- len: length of string (in utf8 encoding)
-- garbage: true/false, true if spam like (contain sick chars or has non meanful char)
function FilterProcessor:GetMsgSpec(message)
	if(message == nil or message == "") then
		return 0, false
	end

	len, hassick = contains_sickchars(message)
	_, notmeaningful = all_non_meaningful(message)
	hasicon = find_icon(message)
	haslink = find_link(message)

	return len, hassick, notmeaningful, hasicon, haslink
end

------------ analysis 
--[[
	local MSG_COUNT_IDX = 1
	local PERIOD_COUNT_IDX = 2
	local CHAN_NUM_IDX = 3
	local DEVIATION_AVG_IDX = 4
	local LAST_PERIOD_IDX = 5
]]

local analysis_perf = {
	-- min threshold of hourly rate of all messages
	inc_min_hourly_allmsgs_thres = 30,
	-- min threshold of hourly rate of per unique message to be included into spam score calculation
	inc_min_hourly_thres = 15,
	-- min reconds to trigger calc of spam score
	min_all_time_thres = 100,
	-- extra score if periodcal/total exceed this:  threshold, multiplex
	hourly_extra_score_period = {
		{0.9, 10,},
		{0.8, 6,},
		{0.7, 4,},
		{0.6, 3,},
		{0.5, 2,},
		{0.4, 1,},
		{0, 1,},
	},
	-- extra score if rate exceed this: threshold, multiplex
	hourly_extra_score_rate = {
		{1000, 10,},
		{720, 8,},
		{360, 4,},
		{180, 3,},
		{90, 2,},
		{45, 1,},
		{0, 1,},
	},
	-- period message percentage vs spam score for hourly
	spam_perc_score_hour = {
		{0.9, 1,},
		{0.8, 0.9,},
		{0.7, 0.6,},
		{0.6, 0.5,},
		{0.5, 0.2,},
		{0.4, 0.15,},
		{0.3, 0.07,},
		{0.2, 0.02,},
		{0.1, 0.01,},
		{0, 0,},
	},
	-- period message percentage vs spam score for weekly
	spam_perc_score_week = {
		{0.9, 1,},
		{0.8, 0.9,},
		{0.7, 0.6,},
		{0.6, 0.5,},
		{0.5, 0.2,},
		{0.4, 0.15,},
		{0.3, 0.07,},
		{0.2, 0.02,},
		{0.1, 0.01,},
		{0, 0,},
	},
	-- period message percentage vs spam score for all time
	spam_perc_score_all_time = {
		{0.9, 3,},
		{0.8, 2,},
		{0.7, 1.6,},
		{0.6, 1.3,},
		{0.5, 1.1,},
		{0.4, 0.4,},
		{0.3, 0.2,},
		{0.2, 0.1,},
		{0.1, 0.05,},
		{0, 0,},
	},
	-- bot to spam score mapping
	bot_to_spam_score = {
		{500, 50,},
		{200, 40,},
		{100, 30,},
		{70, 20,},
		{50, 10,},
		{30, 8,},
		{20, 6,},
		{10, 5,},
		{7, 4,},
		{5, 3,},
		{3, 2,},
		{2, 1.5,},
		{1, 1,},
		{0.8, 0.6,},
		{0.5, 0.3,},
		{0.3, 0.2,},
		{0.2, 0.1,},
		{0.1, 0.05,},
		{0.05, 0.01,},
		{0, 0,},
	},
	-- hourly rate to score mapping
	hourly_to_score = {
		{1000, 10,},
		{500, 5,},
		{300, 3,},
		{250, 2.5,},
		{200, 2,},
		{150, 1.5,},
		{100, 1.2,},
		{80, 1,},
		{70, 0.8,},
		{60, 0.5,},
		{50, 0.3,},
		{40, 0.2,},
		{30, 0.1,},
		{20, 0.05,},
		{15, 0.01,},
		{10, 0,},
		{0, 0,},
	},
	-- links to score mapping
	links_to_score = {
		{1000, 5,},
		{500, 4,},
		{300, 2,},
		{200, 1,},
		{100, 0.6,},
		{50, 0.5,},
		{30, 0.2},
		{20, 0.1,},
		{10, 0.05,},
		{0, 0,},
	},
	-- icons to score mapping
	icons_to_score = {
		{1000, 5,},
		{500, 4,},
		{300, 2,},
		{200, 1,},
		{100, 0.6,},
		{50, 0.5,},
		{30, 0.2},
		{20, 0.1,},
		{10, 0.05,},
		{0, 0,},
	},
	-- icons to score mapping
	spamlikes_to_score = {
		{1000, 5,},
		{500, 4,},
		{300, 2,},
		{200, 1,},
		{100, 0.6,},
		{50, 0.5,},
		{30, 0.2},
		{20, 0.1,},
		{10, 0.05,},
		{0, 0,},
	},
	-- when update features, score of previous feature should be keeped for centain time if new score is lower, score to time mapping
	feature_score_keep_time = {
		{50, 315576000,}, -- 10 years
		{40, 157788000,}, -- 5 years
		{30, 17280000,}, -- 200 days
		{20, 8640000,}, -- 100 days
		{10, 5184000,}, -- 60 days
		{8, 2592000,}, -- 30 days
		{6, 432000,}, -- 10 days
		{5, 172800,}, -- 2 days
		{4, 172800,}, -- 2 days
		{3, 86400,}, -- 1 day
		{2, 86400,}, -- 1 day
		{1.5, 86400,}, -- 1 day
		{1, 86400,}, -- 1 day
		{0.6, 43200,}, -- 12 hours
		{0.3, 21600,}, -- 6 hours
		{0.2, 10800,}, -- 3 hours
		{0.1, 7200,}, -- 2 hours
		{0.05, 3600,}, -- 1 hour
		{0.01, 1800,}, -- 30 minutes
		{0, 0,},
	},
}

function timer_analysis_func()
	-- skip if reseting db in progress
	if addon.resetting_flag ~= nil then
		if addon.resetting_flag then
			return
		end
	end

	if (not addon.db.global.do_not_disturb) then
		addon:log(L["Performing analysis on user behavior ..."])
	end

	-- debug
	--[[
	local adata = copy_table(addon.db.global.analysis)
	addon:log("adata:" .. table_to_string(adata))
	adata.testdata_copytable = 1
	local bdata = addon.db.global.analysis
	addon:log("bdata:" .. table_to_string(bdata))
	]]

	local new_spammer_counter = 0

	for kp, vp in pairs(addon.db.global.plist) do
		local pfeature = {
			name = vp.name,
			score = 0, -- total score
			bot = 0, -- bot score
			-- 2-mins in an hour
			short = {
				score = 0, -- 15/30, should greater than 1 if has more than 15 periodcal message records over 30 total records
			},
			-- daily in a week
			medium = {
				score = 0, -- 3/7
			},
			-- all time
			long = {
				score = 0, -- see spam_perc_score_all_time
			},
			-- count of messages with icon
			icons = 0,
			-- count of messages with link
			links = 0,
			-- count of messages spam like
			spamlikes = 0,
			-- max messages per hour of single unique message
			maxhourrate = 0,
			-- total messages per hour of all messages
			hourratetotal = 0,
		}
		for km, vm in pairs(vp.msgs) do
			local compscore
			local rate
			local total_period_records
			local total_records

			-- short term requency spam computation
			compscore = 0
			rate = 0
			total_period_records = 0
			total_records = 0
			-- addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_hour
			for kh, vh in pairs(vm.samplings.last_hour) do
				total_records = total_records + 1
				rate = rate + vh[MSG_COUNT_IDX]
				-- if seems contains periodcal messages
				if vh[MSG_COUNT_IDX]>=5 and vh[PERIOD_COUNT_IDX]>=4 then
					-- increase counter
					total_period_records = total_period_records + 1
					-- percentage of periodcal/total
					local period_div_total = vh[PERIOD_COUNT_IDX]/vh[MSG_COUNT_IDX]
					-- lookup table to get score based on percentage
					for i=1, #analysis_perf.spam_perc_score_hour do
						if period_div_total>=analysis_perf.spam_perc_score_hour[i][1] then
							compscore = compscore + analysis_perf.spam_perc_score_hour[i][2]
							break
						end
					end					
				end
			end

			-- extra score multiplex for (total period records / total records)
			for i=1, #analysis_perf.hourly_extra_score_period do
				if total_period_records/total_records >= analysis_perf.hourly_extra_score_period[i][1] then
					compscore = compscore * analysis_perf.hourly_extra_score_period[i][2]
					break
				end
			end

			-- calc max hourly rate
			if rate > pfeature.maxhourrate then
				pfeature.maxhourrate = rate
			end

			pfeature.hourratetotal = pfeature.hourratetotal + rate

			-- extra score multiplex for message rate for repeated unique message
			for i=1, #analysis_perf.hourly_extra_score_rate do
				if total_period_records/total_records >= analysis_perf.hourly_extra_score_rate[i][1] then
					compscore = compscore * analysis_perf.hourly_extra_score_rate[i][2]
					break
				end
			end

			pfeature.short.score = pfeature.short.score + compscore

			-- medium term spam computation
			compscore = 0
			-- addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.last_week
			for kh, vh in pairs(vm.samplings.last_week) do
				if vh[MSG_COUNT_IDX]>=5 and vh[PERIOD_COUNT_IDX]>=4 then
					-- percentage of periodcal/total
					local period_div_total = vh[PERIOD_COUNT_IDX]/vh[MSG_COUNT_IDX]
					-- lookup table to get score based on percentage
					for i=1, #analysis_perf.spam_perc_score_week do
						if period_div_total>=analysis_perf.spam_perc_score_week[i][1] then
							compscore = compscore + analysis_perf.spam_perc_score_week[i][2]
							break
						end
					end					
				end
			end
			pfeature.medium.score = pfeature.medium.score  + compscore

			-- long term spam computation
			if vm.samplings.all_time[PERIOD_COUNT_IDX] >= analysis_perf.min_all_time_thres then
				compscore = 0
				-- addon.db.global.plist[msgdata.guid].msgs[msgdata.hash].samplings.all_time
				local period_div_total = vm.samplings.all_time[PERIOD_COUNT_IDX]/vm.samplings.all_time[MSG_COUNT_IDX]
				for i=1, #analysis_perf.spam_perc_score_all_time do
					if period_div_total>=analysis_perf.spam_perc_score_all_time[i][1] then
						compscore = analysis_perf.spam_perc_score_all_time[i][2]
						break
					end
				end
				pfeature.long.score = pfeature.long.score + compscore

			end

			pfeature.bot = pfeature.short.score + pfeature.medium.score + pfeature.long.score

			-- increase icon/link/spamlike counter
			-- frequent messages with links are annoying, count every single message
			if vm.haslink then pfeature.links = pfeature.links + rate end
			if vm.hasicon then pfeature.icons = pfeature.icons + rate end
			if vm.spamlike then pfeature.spamlikes = pfeature.spamlikes + rate end
		end

		-- calculation of spam score
		if 	(pfeature.maxhourrate > analysis_perf.inc_min_hourly_thres) -- min hourly threshold for unique message with max rate
			or (pfeature.hourratetotal > analysis_perf.inc_min_hourly_allmsgs_thres) -- min hourly threshold for all messages rate
		then
			local score = 0
			-- convert bot score to spam score
			for i=1, #analysis_perf.bot_to_spam_score do
				if pfeature.bot >=analysis_perf.bot_to_spam_score[i][1] then
					score = score + analysis_perf.bot_to_spam_score[i][2]
					break
				end
			end

			-- convert max hourly rate score to spam score
			for i=1, #analysis_perf.hourly_to_score do
				if pfeature.maxhourrate >=analysis_perf.hourly_to_score[i][1] then
					score = score + analysis_perf.hourly_to_score[i][2]
					break
				end
			end

			-- convert total hourly rate of all messsage score to spam score
			for i=1, #analysis_perf.hourly_to_score do
				if pfeature.hourratetotal >=analysis_perf.hourly_to_score[i][1] then
					score = score + analysis_perf.hourly_to_score[i][2]
					break
				end
			end

			-- if too many links messages, possibly a seller
			if pfeature.links > 0 then
				--addon:log(pfeature.name .. " links=" ..pfeature.links )
				for i=1, #analysis_perf.links_to_score do
					if pfeature.links >=analysis_perf.links_to_score[i][1] then
						--addon:log("scores=" .. analysis_perf.links_to_score[i][2] )
						score = score + analysis_perf.links_to_score[i][2]
						break
					end
				end
			end

			-- icon messages
			if pfeature.icons > 0 then
				for i=1, #analysis_perf.icons_to_score do
					if pfeature.links >=analysis_perf.icons_to_score[i][1] then
						score = score + analysis_perf.icons_to_score[i][2]
						break
					end
				end
			end

			-- spamlikes messages 
			if pfeature.spamlikes > 0 then
				for i=1, #analysis_perf.spamlikes_to_score do
					if pfeature.spamlikes >=analysis_perf.spamlikes_to_score[i][1] then
						score = score + analysis_perf.spamlikes_to_score[i][2]
						break
					end
				end
			end

			pfeature.score = score
		end

		--if pfeature.bot>0.1 or pfeature.icons>0 or pfeature.links>0 or pfeature.spamlikes>0 then
		-- update pfeature
		if pfeature.score > 0 then
			local toupdate = false
			-- set update time of current analysis
			pfeature.updatetime = time()

			local last_feature = addon.db.global.pfeatures[kp] or nil

			-- if new, to update
			if last_feature == nil then
				new_spammer_counter = new_spammer_counter + 1
				if not addon.db.global.do_not_disturb then
					addon:log(L["Found new possible spammer: "] .. pfeature.name)
				end
				toupdate = true
			else
				-- diff precision set to hundredth
				local diff = math.floor((pfeature.score - last_feature.score) * 100) / 100

				-- if current score greater than last score, to update
				if diff>0 then
					--addon:log(pfeature.name .. L["'s spam score increased."])
					--addon:log("update pfeature: score increase: " .. pfeature.name .. " " .. pfeature.score .. "/" .. last_feature.score .. " diff=" .. diff)
					toupdate = true
				-- if current score is lower, to update only when diff from last update satisfy the mapping table
				elseif diff<0 then
					for i=1, #analysis_perf.feature_score_keep_time do
						if last_feature.score >=analysis_perf.feature_score_keep_time[i][1] then
							if (last_feature.updatetime == nil) then
								toupdate = true
							else
								if (pfeature.updatetime - last_feature.updatetime >= analysis_perf.feature_score_keep_time[i][2]) then
									--addon:log("update pfeature: score decline and update time reached: " .. pfeature.name .. " " .. pfeature.score .. "/" .. last_feature.score .. " diff=" .. diff)
									toupdate = true
								else
									--addon:log("update pfeature: score decline and time needed: " .. pfeature.name .. " " .. pfeature.score .. "/" .. last_feature.score .. " diff=" .. diff .. " time=" .. (pfeature.updatetime - last_feature.updatetime) .. "/" .. analysis_perf.feature_score_keep_time[i][2] )
								end
							end
							break
						end
					end
				else
					--addon:log("update pfeature: score not changed: " .. pfeature.name .. " " .. pfeature.score .. "/" .. last_feature.score .. " diff=" .. diff)
				end
			end

			if toupdate then
				--addon:log("Doing update pfeature")
				--addon.db.global.pfeatures[kp] = {score = pfeature.score, name=pfeature.name, updatetime=pfeature.updatetime} -- release version
				addon.db.global.pfeatures[kp] = pfeature -- for debug or release purpose
			end
		end

		--[[
		if addon.db.global.pfeatures[kp] == nil and pfeature.score >= 0.5 then
			addon:log(table2string({note="New annoying player found.", name=pfeature.name, score=pfeature.score}))
		end
		]]

	end
	
	-- notify after debug info written
	--PlaySound(SOUNDKIT.READY_CHECK)
	--PlaySound(123)

	-- play discover sound if there are new spammers
	if new_spammer_counter > 0 then
		PlaySound(1519)
	end

	-- compact db after analysis
	timer_compactdb_func()
end

-- set a timer to launch analysis process
function FilterProcessor:SetupAnalysisTimer()
    FilterProcessor.analysisTimer = C_Timer.NewTimer(2, timer_analysis_func)
end

--------------- compact db

local compact_pref = {
	-- purge messages less than purge_hour_count in an hour, normally equals to hourly_learning_threshold
	purge_hour_count = 10,
}

-- compact db to reduce db size
function timer_compactdb_func()
	-- skip if reseting db in progress
	if addon.resetting_flag ~= nil then
		if addon.resetting_flag then
			return
		end
	end

	if (not addon.db.global.do_not_disturb) then
		addon:log(L["Performing optimization on learning DB ..."])
	end

	local aweek_ago = time() - 604800
	local ahour_ago = time() - 3600

	-- compact plist
    for kp,vp in pairs(addon.db.global.plist) do
    	local msgcounter = 0
    	for km, vm in pairs(vp.msgs) do
    		msgcounter = msgcounter + 1
	    	-- purge messages older than a week
    		if vm.last_time < aweek_ago then
    			vp.msgs[km] = nil
    		end

    		-- remove message field, should comment out in release version if message not saved at all
			--vp.msgs[km].msg = nil    		

    		--[[
    		-- purge messages sent less than purge_hour_count in all time
    		if (vm.last_time < ahour_ago) and (vm.samplings.all_time[MSG_COUNT_IDX]<compact_pref.purge_hour_count) then
    			vp.msgs[km] = nil
    		end
			]]

    		if (vm.last_time < ahour_ago) then
	    		-- purge messages sent less than purge_hour_count in last hour
	    		local hourmsgcount = 0
	    		for kh, vh in pairs(vm.samplings.last_hour) do
	    			hourmsgcount = hourmsgcount + vh[MSG_COUNT_IDX]
	    		end
	    		if hourmsgcount < compact_pref.purge_hour_count then
	    			vp.msgs[km] = nil
	    		end
    		end

    	end
    	-- remove player node without messages
    	if msgcounter == 0 then
    		addon.db.global.plist[kp] = nil
    	end
    end

    -- compact prelearning
    for kp,vp in pairs(addon.db.global.prelearning) do 
    	if vp.updatetime == nil then
    		vp.updatetime = time()
    	else
    		-- remove not in learning and updatetime older than 1 hour
    		if (vp.learning == false) and (time() - vp.updatetime > 3600) then
    			addon.db.global.prelearning[kp] = nil
    		end
    	end
    end

	--PlaySound(18019)
end

-- set a timer to launch compact db process
function FilterProcessor:SetupCompactDBTimer()
    FilterProcessor.compactdbTimer = C_Timer.NewTimer(2, timer_compactdb_func)
end


------------------------------------------------------------------------
-- unicode table to utf8
local function unicode_tbl_to_utf8(tbl)

    local rets=""
    for i = 1, #tbl, 1 do
        local unicode = tbl[i]

        if unicode <= 0x007f then
            rets=rets..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            rets=rets..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            rets=rets..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    --rets=rets..'\0'
    return rets
end

-- utf8 to unicode table
function utf8_to_tbl(utf8str)
	assert(type(utf8str) == "string")
	local res, seq, val = {}, 0, nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			table.insert(res, val)
			seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
			      c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
				  error("invalid UTF-8 character sequence")
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	table.insert(res, val)
	return res
end

-- get factors
-- exclude 1, self, 2, self/2
function defactor_atleast_2(n)
	local sqrt = math.floor(math.sqrt(n))
  	local factors = {}
  	for i=2, sqrt do
    	div = n / i
    	if div == math.floor(div) then
      		factors[i] = true
      		factors[div] = true
    	end
  	end

  	return factors
end

function tbl_subrange(t, first, last)
	local sub = {}
	for i=first,last do
		sub[#sub + 1] = t[i]
	end
	return sub
end

local function tohex(num)
    local charset = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
    local tmp = {}
    repeat
        table.insert(tmp,1,charset[num%16+1])
        num = math.floor(num/16)
    until num==0
    return table.concat(tmp)
end

function comparetables(t1, t2)
 	if #t1 ~= #t2 then return false end
 	for i=1,#t1 do
    	if t1[i] ~= t2[i] then return false end
 	end
 	return true
end

-- remove all repeat chars
function remove_char_repeats_fast(str) 
	local t = utf8_to_tbl(str)
	local rt = {}
	local rk = {}

	for i=1, #t, 1 do
		if not rk[ t[i] ] then
			rk[ t[i] ] = true
			table.insert(rt, t[i])
		end
	end

	return unicode_tbl_to_utf8(rt)
end

-- remove all repeat chars
function longest_substring_fast(str) 
	local t = utf8_to_tbl(str)
	local rt = {}
	local r1 = {}

	for i=1, #t do
		r1[i] = t[i]
		for j=1, i do
			r1[j] = t[j]
		end
		print(unicode_tbl_to_utf8(r1))
	end

	return unicode_tbl_to_utf8(rt)
end

-- remove all repeat chars
function remove_char_repeats_preserve_numbers_fast(str) 
	local t = utf8_to_tbl(str)
	return remove_char_repeats_preserve_numbers_table(t)
end

function remove_char_repeats_preserve_numbers_table(t) 
	local rt = {}
	local rk = {}
	local len = #t
	local waitseq = {}

	for i=1, #t, 1 do

		-- new found unicode char
		if (not rk[ t[i] ]) then
			--print(unicode_tbl_to_utf8(rt) .. "| |" .. unicode_tbl_to_utf8(waitseq))
			-- if waiting sequence not empty, insert elements of waitseq into result and wipe waitseq
			if(#waitseq>0) then
				--packseq = remove_char_repeats_preserve_numbers_table(waitseq)
				packseq = waitseq
				for j=1, #packseq, 1 do
					table.insert(rt, packseq[j])
				end
				waitseq = {}
			end

			rk[ t[i] ] = true
			table.insert(rt, t[i])
			--print(unicode_tbl_to_utf8(rt) .. "| |" .. unicode_tbl_to_utf8(waitseq) .. "\n")
		-- if char exists
		else
			--[[
			-- unicode number range 0x30-0x39
			if (t[i]>=0x30 and t[i]<=0x39) then
				-- if adjacent with numbers
				--if ( i>1 and t[i-1]>=0x30 and t[i-1]<=0x39 ) or (i<len and t[i+1]>=0x30 and t[i+1]<=0x39) then
				--	table.insert(waitseq, t[i])
				--end

				-- insert into waiting seq
				table.insert(waitseq, t[i])
			end
			]]

			if (t[i]>=0x30 and t[i]<=0x39) or (t[i]>=0x41 and t[i]<=0x5a) then
			-- save existing chars into waiting sequence
				table.insert(waitseq, t[i])
			end
		end

	end

	return unicode_tbl_to_utf8(rt)
end

-- get only repeat string if a string contains only the repeat pattern
function find_repeat_pattern_fast(str) 
	local t = utf8_to_tbl(str)

	local len = #t
	fs = defactor_atleast_2(len)
	
	-- sort factors from low to high
	local tkeys = {}
	for k in pairs(fs) do table.insert(tkeys, k) end
	table.sort(tkeys)

	local prev = nil

	-- loop keys
	for _, k in ipairs(tkeys) do
		if(k>=2) then
			-- print(v)
			prev = nil
			local identical = true
			local parts = math.floor(len/k)
			for i=0, parts-1, 1 do
				--print("len=", v, ", parts=", parts)
				--subt = tbl_subrange(t, (i-1)*sublen+1, sublen)
				subt = tbl_subrange(t, i*k+1, (i+1)*k)
				--print(unicode_tbl_to_utf8(subt))
				if(prev ~=nil) then
					if not comparetables(prev, subt) then
						-- found diff
						identical = false
						break
					end
				end
				prev = subt
			end
			-- if found shortest length, convert the unicode table to utf8
			if(identical) then
				return unicode_tbl_to_utf8(prev)
			end
		end
	end
	return nil
end

------------- remove dups, slow, need to optimize
function trim_compare_tables(t1, t2)
    local ct1 = {}
    local ct2 = {}

    local c
    c = 1
    for i=1, #t1 do
        if t1[i] ~= 0x20 and t1[i] ~= 0xa0 and t1[i] ~= 0x3000 then
            ct1[c] = t1[i]
            c = c + 1
        end
    end

    c = 1
    for i=1, #t2 do
        if t2[i] ~= 0x20 and t2[i] ~= 0xa0 and t2[i] ~= 0x3000 then
            ct2[c] = t2[i]
            c = c + 1
        end
    end

    if #ct1 ~= #ct2 then return false end
    for i=1,#t1 do
        if ct1[i] ~= ct2[i] then return false end
    end
    return true
end

-- fast compare table without copy table
-- t: table
-- p1: position 1
-- p2: position 2
-- size: size of elements to compare
function compare_tables_part(t, p1, p2, size)
 	for i=1,size do
    	if t[p1+i] ~= t[p2+i] then return false end
 	end
 	return true
end

-- fast remove dups without copy table
function remove_dups(str, fast) 
	-- utf8 to unicode table
	local t = utf8_to_tbl(str)

	local N = #t
	-- compare offset max set to half length of string
	local maxoff = math.floor(N/2)

	-- increase offset from 0 to max offset
	for off = 0, maxoff do
		local g

		-- calculate max window size (target repeated substring to find)
		if (N-off)%2 == 0 then
			g = math.floor((N-off)/2)
		else
			g = math.floor(((N-off)-1)/2)
		end

		-- target repeated substring set to at least 3 chars
		for ws = 3, g do
			local dup = 0

			-- compare each window to first window begin with off
			for n = 1, N/ws do
				--print(n .. " ct2=" .. unicode_tbl_to_utf8(ct2))
				-- if found repeat pattern
				if compare_tables_part(t, off, n*ws+off, ws) then
					-- increast repeat counter
					dup = dup + 1
				else
					break
				end
			end

			-- if found repeated pattern
			if dup>0 then
				local rest = N-(dup+1)*ws
				--print("Found " .. dup .. " dups, rest chars=" .. N-(dup+1)*ws)
				rt = {}

				-- first part: from 0 to end of first window
				for k=1, off+ws do
					table.insert(rt, t[k])
				end
				-- if there are chars after repeated strings
				if rest > 0 then
					for k=(dup+1)*ws+1, N do
						table.insert(rt, t[k+off])
					end
				end
				--print("rt=" .. unicode_tbl_to_utf8(rt))
				return unicode_tbl_to_utf8(rt)
			end

		end

		-- If fast set, only from first byte (offset 0)
		if fast == true then
			break
		end
	end

	return nil
end

-- utf8 to unicode table
function utf8_to_tbl_fast(utf8str, start, stop)
    assert(type(utf8str) == "string")

    if start == nil then
        start = 1
    end    

    if stop == nil then
        stop = #utf8str
    end

    local res, seq, val = {}, 0, nil
    for i = start, stop do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                  error("invalid UTF-8 character sequence")
            val = bit.band(c, 2^(8-seq) - 1)
        else
            val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    table.insert(res, val)
    return res
end

-- unicode table to utf8
function unicode_tbl_to_utf8_fast(tbl, start, stop)
	if tbl == nil then
		return nil
	end

    if start == nil then
        start = 1
    end    

    if stop == nil then
        stop = #tbl
    end

    local rets=""
    for i = start, stop do
        local unicode = tbl[i]

        if unicode <= 0x007f then
            rets=rets..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            rets=rets..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            rets=rets..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    --rets=rets..'\0'
    return rets
end

-- if t[p1+i]==0xa0 or t[p1+i]==0x20 or t[p1+i]==0x3000
function compare_tables_part_nospace_fast(t, p1, p2, size)
	local ncounter = 0
	local p1pos = 1
	local p2pos = 1

	local result = false

	while(p1pos<=size) do
		-- p1 not space
		local c1 = t[p1+p1pos]
		if c1~=0xa0 and c1~=0x20 and c1~=0x3000 then
			local c2 = nil
			local i

			while(p2pos<=size) do
				c2 = t[p2+p2pos]
				if c2~=0xa0 and c2~=0x20 and c2~=0x3000 then
					p2pos = p2pos + 1
					break
				end
				p2pos = p2pos + 1
			end

			--print(c1, c2)

			if c1 ~= c2 then 
            	return false 
            end

        	 -- number
	        if c1 >= 0x30 and c1 <= 0x39 then
	        	ncounter = ncounter + 1
	        end
		end
	    p1pos = p1pos + 1
	end

    -- ignore all number repeats
    if ncounter == size then
    	return false
    end

	for i=p2pos, size do
		local extrac2 = t[p2+i]
		--p2 has non-space chars
		if extrac2~=0xa0 and extrac2~=0x20 and extrac2~=0x3000 then
			return false
		end
	end

	--print (size, p1pos, p2pos)
	if p1pos  == size+1 then
		result = true
	end

    return result
end

function estimate_dup_probability(tbl)
	local prob = 0.0
	if tbl == nil then
		return prob
	end

	local uc = {}
	for k, v in pairs(tbl) do
		if uc[v] ~= nil then
			uc[v] = uc[v] + 1
		else
			uc[v] = 1
		end
	end

	local counter = 0
	for k, v in pairs(uc) do
		counter = counter + 1
		-- print( unicode_tbl_to_utf8_fast({k}), "=", v)
	end

	--print(counter, #tbl, 1-counter/#tbl)
	return math.floor((1-counter/#tbl)*100)/100
end

function remove_dups_fast(str, deep) 
    local t = utf8_to_tbl_fast(str)
    --print(table2string(t))
    local prob = estimate_dup_probability(t)
    --print("size=" .. #t .. ", prob=" .. prob)

    local skip = false
    if prob<0.33 then
    	skip = true
	elseif (#t>256 and prob<0.4) then
		skip = true
	elseif (#t>128 and prob<0.45) then
		skip = true
	elseif (#t>64 and prob<0.47) then
		skip = true
	elseif (#t>32 and prob<0.5) then
		skip = true
	end

	-- skip very low probability of duplicates
	if(skip) then
		--print("Skip low probability")
		return nil
	end

    local dflag = false
    if deep ~= nil then 
    	dflag = deep
    else
    	--print("deep not set, estimating...")
		if (#t>256 and prob>0.7) then
			dflag = true
		elseif (#t>128 and prob>0.6) then
			dflag = true
		elseif (#t>64 and prob>0.55) then
			dflag = true
		elseif (#t>32 and prob>0.5) then
			dflag = true
		end
    end
    --print("size=" .. #t .. ", prob=" .. prob .. ", deepflag=" .. tostring(dflag))


    local rt = remove_dups_tbl_fast(t, dflag)
 	return unicode_tbl_to_utf8_fast(rt)
end

function remove_dups_tbl_fast(t, deep)
	local i, k
    -- offset, window_size
    local off, w
    -- length
    local n = #t
    -- half of length
    local h = math.floor(n/2)

    -- offset from 0 to n
    for off=0, n do
        local maxwin = h

        -- calc max window size
        if h>(n-off) then
        	maxwin = n-off
        end

        -- window size from large to small
        for w=maxwin, 3, -1 do
	        local dups = 0
            -- fist element index = 0
            for k = 1, (n-off)/w-1 do
	            --if compare_tables_part(t, dups*w+off, (dups+1)*w+off, w) then
	            --print(unicode_tbl_to_utf8_fast(t, off+1, off+w) .. " vs " .. unicode_tbl_to_utf8_fast(t, k*w+off+1, k*w+off+w) )
	            --if compare_tables_part_fast(t, off, k*w+off, w) then
	            if compare_tables_part_nospace_fast(t, off, k*w+off, w) then
	                dups = dups + 1
	                --print("dups=", dups, "w=", w)
	            else
	            	break
	            end
            end

            if(dups>0) then
            	local rt = {}
            	for i = 1, off+w do
            		table.insert(rt, t[i])
            	end

				--print(unicode_tbl_to_utf8_fast(rt))

            	for i = (dups+1)*w+off+1, n do
            		table.insert(rt, t[i])
            	end
				--print(unicode_tbl_to_utf8_fast(rt))

            	--ft = nil
            	-- find dups again
            	if deep then
	            	ft = remove_dups_tbl_fast(rt, deep)
	            	if ft ~= nil then
	            		return ft
	            	else
	            		return rt
	            	end
            	else
            		return rt
            	end
            end
        end
    end
end

------------------------------------------------------------------------

---------------------------
-- test functions
if addonName == nil then


	local function serialize_local(obj)
	    local lua = ""  
	    local t = type(obj)  
	    if t == "number" then  
	        lua = lua .. obj  
	    elseif t == "boolean" then  
	        lua = lua .. tostring(obj)  
	    elseif t == "string" then  
	        lua = lua .. string.format("%q", obj)  
	    elseif t == "table" then  
	        lua = lua .. "{"  
	        for k, v in pairs(obj) do  
	            lua = lua .. "[" .. serialize_local(k) .. "]=" .. serialize_local(v) .. ", "  
	        end  
	        local metatable = getmetatable(obj)  
	        if metatable ~= nil and type(metatable.__index) == "table" then  
	            for k, v in pairs(metatable.__index) do  
	                lua = lua .. "[" .. serialize_local(k) .. "]=" .. serialize_local(v) .. ", "  
	            end  
	        end  
	        lua = lua .. "}"  
	    elseif t == "nil" then  
	        return nil  
	    else  
	        error("can not serialize a " .. t .. " type.")  
	    end  
	    return lua  
	end

	function table2string_local(tablevalue)
	    local stringtable = serialize_local(tablevalue)
	    return stringtable
	end

	function test1()
		a='收G G G G G G G G G G…'
		a="*(&*&(*&&𓈠��"
		print(a)
		len, found = contains_sickchars(a)
		print(len, " sick:", found)
		len, found = all_non_meaningful(a)
		print(len, " non-meaningful:", found)
	end

	function test2()
		t = os.time()
		print(os.date("%c", t))
		print(t/3600)
		print(math.floor(t/3600))
		print(math.floor(t/432000))
		print(math.fmod(t, 3600))
	end

	function test3()
		--print(table2string_local(addon.db.global.prelearning))
		print(find_link("|cff0070dd|Hitem:13396::::::::60:::::::|h[斯库尔的苍白之触]|h|r"))
	end

	function test4()
		a = os.time()-0
		print(math.floor(os.date("%M", a)/2))
		print(math.floor(0.31*100, 2)/10)
		print(math.floor(os.date("%w", os.time())))
	end

	function test5()
		for i=1, #analysis_perf.spam_perc_score_all_time do
			print(analysis_perf.spam_perc_score_all_time[i][1])
		end
	end

	function test6()
		a = (1>30)
		print(a)
	end


	function test7()
		last_feature = {score=2, updatetime=50}
		pfeature = {score=1, updatetime=100+86400}

		if pfeature.score > 0 then
		end

		local toupdate = false

		-- if new, to update
		if last_feature == nil then
			toupdate = true
		else
			-- if current score greater than last score, to update
			if pfeature.score > last_feature.score then
				toupdate = true
			-- if current score is lower, to update only when diff from last update satisfy the mapping table
			else
				for i=1, #analysis_perf.feature_score_keep_time do
					if last_feature.score >=analysis_perf.feature_score_keep_time[i][1] then
						if (last_feature.updatetime == nil) then
							toupdate = true
						else
							if (pfeature.updatetime - last_feature.updatetime >= analysis_perf.feature_score_keep_time[i][2]) then
								toupdate = true
							end
						end
						break
					end
				end
			end
		end

		print(tostring(toupdate))
	end

	function test8()
		a = 1/3
		print(math.floor(a*1000)/1000)
		print(os.time()-1590630091)
	end

	function test9()
		package.path = "/Users/acamar/Downloads/tmp/Acamar.lua"
		v= require "Acamar"
		
		local bannedlist = {}

		for k, v in pairs(AcamarDB.global.pfeatures) do
			if ( v.score >= 0 ) then
				bannedlist[k] = v
			end
	    end

		local sort_field = "score"
		function tcompare(a, b)
			return a[sort_field]>b[sort_field]
		end

		local function sortedByValue(tbl, sortFunction)
		    local keys = {}
		    for key in pairs(tbl) do
		        table.insert(keys, key)
		    end

		    table.sort(keys, function(a, b)
		        return sortFunction(tbl[a], tbl[b])
		    end)

		    return keys
		end

		local sortedKeys = sortedByValue(bannedlist, tcompare)

		local counter = 0
		for _, key in ipairs(sortedKeys) do
			counter = counter + 1
			print( tostring(counter) .. ", " .. bannedlist[key].name .. " :[" .. bannedlist[key].score .. "]")
			pnode = AcamarDB.global.plist[key]
			if pnode ~= nil then
				if pnode.msgs ~= nil then
					for mk, mv in pairs(pnode.msgs) do
						print("", mv.msg)
					end
				end
			end
			print("")
	    end
   	end

   	function test10()
   		a5="JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板"
		s = find_repeat_pattern_fast(a5)
		print(s)

		s = remove_char_repeats(a5)
		print(s)
   	end

	local function remsg(ori)
	    local modifymsg = nil
	    local len = string.len(ori)
	    if((len>=4) and (len%2==0)) then
	        modifymsg = find_repeat_pattern_fast(ori)
	    end

	    if(modifymsg == nil) then
	        modifymsg = remove_char_repeats(ori)
	    end

	    return modifymsg
	end

   	function test11()
   		a5 = "JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板JJC兽人老高已出 来需求的老板"
   		a6 = "MLD10分钟一门　160+怪　接30－52　MLD10分钟一门　160+怪　接30－52　MLD10分钟一门　160+怪　接30－52　MLD10分钟一门　160+怪　接30－52　MLD10分钟一门　160+怪　接30－52　MLD10分钟一门　160+怪　接30－52 A"
   		a7 = "#[正义之手]#11815##[正义之手]#11815##[正义之手]#11815#来 老板 。。。。"

		--s1 = remove_char_repeats_preserve_numbers_fast(a6)
		--s2 = remove_char_repeats_fast(a6)
		--s3 = find_repeat_pattern_fast(a6)

		s1 = longest_substring_fast(a5)

		print(s1)
   	end

	test11()
end
-- EOF