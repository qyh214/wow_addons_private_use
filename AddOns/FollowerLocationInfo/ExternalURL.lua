
local addon,lib = ...;
local Locale = GetLocale();

lib.ExternalURLValues = {
	BattleNet = "BattleNet (items only)",
	WoWHead = "WoWHead",
	WoWDB = "WoWDB (english only)",
	Thottbot = "Thottbot (english only)",
	Buffed = "Buffed (english, german, russian)"
};

lib.ExternalURL_Tooltips = {
	WoWHead = {"This site offer content in multible languages."},--"WoWHead offer a wide range of informations about quests, items, spells and other things in nearly all WoW supported languages.",
	WoWDB = {"This site offer content only in english."},
	Thottbot = {"This site offer content only in english."},
	Buffed = {"Currently Buffed doesn't support links to follower and garrision buildings. Language support is limited to english, german and russian."},
	BattleNet = {"This site contains only item informations"}
}

lib.ExternalURL_unsupportedTypes = {
	Buffed = {
		b=true, gf=true
		-- maybe coming soon... 
	},
	BattleNet = {
		m=true, gf=true, a=true, c=true, f=true,
		n=true, o=true, q=true, s=true, b=true,
	}
}

--- Usage:
-- StaticPopup_Show("FOLLOWERLOCATIONINFO_EXTERNALURL_DIALOG",nil,nil,{<Type[string]>,<Id[number|string]>});
StaticPopupDialogs["FOLLOWERLOCATIONINFO_EXTERNALURL_DIALOG"] = {
	text = BROWSER_COPY_LINK,
	button2 = CLOSE,
	timeout = 0,
	whileDead = 1, 
	hasEditBox = 1,
	hideOnEscape = 1,
	maxLetters = 1024,
	editBoxWidth = 300,
	OnShow = function(self)
		local Type,Id,Realm = unpack(self.data or {});
		local Name,Target,url = self:GetName(),FollowerLocationInfoDB.ExternalURL,false;

		--[=[ create url for battlenet ]=]
		if Target=="BattleNet" or Type=="player" then
			local lang,domains,region2domain,field = "",{
				"us.battle.net", "eu.battle.net", "kr.battle.net",
				"tw.battle.net", "www.battlenet.com.cn",
			},{
				enUS = 1, esMX = 1, ptBR = 1, jaJP = 1,
				esES = 2, enBG = 2, deDE = 2, frFR = 2,
				itIT = 2, ptPT = 2, ruRU = 2, plPL = 2,
				koKR = 3, zhTW = 4, zhCN = 5,
			},{
				--a="achievement", c="currency", f="faction", b="garrison/buildings",
				--m="garrison/mission", n="npc", o="object", q="quest", s="spell",
				--gf="followers"
				i="item",
				player="character"
			};

			if not region2domain[Locale] then
				Locale = "enUS";
			end
			if Locale~="zhCN" then
				local l1,l2 = Locale:match("(%l+)(%u+)");
				lang = "/"..l1.."-"..l2:lower();
			end
			if Type=="player" then
				if not Realm then Realm = GetRealmName(); end
				Id = gsub(Realm," ","-"):lower().."/"..Id;
			end
			if field[Type] then
				url = ("http://%s/wow%s/%s/%s/"):format(domains[region2domain[Locale]], lang, field[Type], Id);
			end

		--[=[ create url for Buffed ]=]
		elseif Target=="Buffed" then
			local lang,field = {
				deDE="buffed.de",
				ruRU="getbuffed.ru"
				-- enUS = "getbuffed.com" and all not listed languages
			},{
				a="a", c="c", f="faction",
				i="i", o="o", q="q", s="s", n="n",
				m="mission", --b="building", gf="follower"
			};
			url = ("http://wowdata.%s/?q=%s"):format(lang[Locale] or "getbuffed.com",field[Type],Id);

		--[=[ create url for WoWDB ]=]
		elseif Target=="WoWDB" then
			local field = {
				a="achievements",       c="currencies", f="factions",
				b="garrison/buildings", i="items",      m="garrison/missions",
				n="npcs",               o="objects",    q="quests",
				s="spells",             gf="garrison/followers"
			};
			url = ("http://www.wowdb.com/%s/%s"):format(field[Type],Id);

		--[=[ create url for WoWHead or Thottbot ]=]
		elseif Target=="WoWHead" or Target=="Thottbot" then
			local lang,field = { -- wowhead only
				deDE="de", esES="es", esMX="es", frFR="fr",
				itIT="it", ptPT="pt", ptBR="pt", ruRU="ru",
				koKR="ko", zhCN="cn", zhTW="cn"
				-- enUS = "www" and all not listed languages
			},{
				a="achievement", c="currency", f="faction",
				b="building",    i="item",     m="mission",
				n="npc",         o="object",   q="quest",
				s="spell",       gf="follower"
			};
			if Type=="gf" then
				Id = Id.."."..(UnitFactionGroup("player")=="Alliance" and 1 or 2);
			end
			if Target=="Thottbot" then
				url = ("http://www.thottbot.com/%s=%s"):format(field[Type],Id);
			else
				url = ("http://%s.wowhead.com/%s=%s"):format(lang[Locale] or "www",field[Type],Id);
			end
		end

		if type(url)=="string" and strlen(url)>0 then
			_G[Name.."EditBox"]:SetText(url);
			_G[Name.."EditBox"]:SetFocus();
			_G[Name.."EditBox"]:HighlightText(0);
			_G[Name.."Button2"]:ClearAllPoints();
			_G[Name.."Button2"]:SetWidth(100);
			_G[Name.."Button2"]:SetPoint("CENTER",_G[Name.."EditBox"],"CENTER",0,-30);
		else
			print("Something goes wrong. Can't create an URL.");
			self:Hide();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end
}
