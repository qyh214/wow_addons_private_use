function SlashRL_OnLoad()
	SlashCmdList["SLASHRLCOMMAND"] = SlashRL_SlashHandler;
	SLASH_SLASHRLCOMMAND1 = "/rl";
	SLASH_SLASHRLCOMMAND2 = "/reload";
	SLASH_SLASHRLCOMMAND3 = "/reloadui";
end

function SlashRL_SlashHandler()
	ReloadUI();
end