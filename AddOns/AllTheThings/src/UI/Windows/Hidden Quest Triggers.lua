-- App locals
local appName, app = ...;
local L = app.L;

-- Implementation
app:CreateWindow("Hiddent Quest Triggers", {
	HideFromSettings = true,
	Commands = { "atthqt", "atthqts" },
	OnLoad = function(self, settings)
		local hqt = app.Categories.HiddenQuestTriggers;
		if hqt then
			self.data = app.CacheFields({
				text = L.HIDDEN_QUEST_TRIGGERS,
				icon = app.asset("Interface_Quest"),
				description = L.HIDDEN_QUEST_TRIGGERS_DESC,
				font = "GameFontNormalLarge",
				visible = true,
				g = hqt,
				_hqt = true,
			}, true);
			self:AssignChildren();
		end
	end,
});