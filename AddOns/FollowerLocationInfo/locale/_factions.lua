
local _,ns=...;

ns.factions = {
	[1445] = "Frostwolf Orcs",
	[1515] = "Arakkoa Outcasts",
	[1520] = "Shadowmoon Exiles",
	[1681] = "Vol'jin's Spear",
	[1682] = "Wrynn's Vanguard",
	[1708] = "Laughing Skull Orcs",
	[1710] = "Sha'tari Defense",
	[1711] = "Steamwheedle Preservation Society",
	[1731] = "Council of Exarchs",
	[1732] = "Steamwheedle Draenor Expedition",
	[1735] = "Barracks Bodyguards",
};
local f=ns.factions;

if LOCALE_deDE then
	f[1445] = "Frostwolforcs";
	f[1515] = "Ausgestoßene Arakkoa";
	f[1520] = "Exilanten des Schattenmondklans";
	f[1681] = "Vol'jins Speer";
	f[1682] = "Wrynns Vorhut";
	f[1708] = "Orcs des Lachenden Schädels";
	f[1710] = "Sha'tarverteidigung";
	f[1711] = "Werterhaltungsgesellschaft des Dampfdruckkartells";
	f[1731] = "Exarchenrat";
	f[1732] = "Draenorexpedition des Dampfdruckkartells";
	f[1735] = "Kasernenleibwachen";
end

if LOCALE_esES or LOCALE_esMX then
	f[1445] = "Orcos Lobo Gélido";
	f[1515] = "Arakkoa desterrados";
	f[1520] = "Exiliados Sombraluna";
	f[1681] = "Lanza de Vol'jin";
	f[1682] = "Vanguardia de Wrynn";
	f[1708] = "Orcos Riecráneos";
	f[1710] = "Defensa Sha'tari";
	f[1711] = "Sociedad Patrimonial Bonvapor";
	f[1731] = "Consejo de Exarcas";
	f[1732] = "Expedición Bonvapor de Draenor";
	f[1735] = "Guardaespaldas del cuartel";
end

if LOCALE_frFR then
	f[1445] = "Orcs loups-de-givre";
	f[1515] = "Parias arakkoa";
	f[1520] = "Exilés ombrelunes";
	f[1681] = "Lance de Vol’jin";
	f[1682] = "Avant-garde de Wrynn";
	f[1708] = "Orcs du Crâne-Ricanant";
	f[1710] = "Défense sha’tari";
	f[1711] = "Société de Conservation de Gentepression";
	f[1731] = "Conseil des exarques";
	f[1732] = "Expédition de Gentepression en Draenor";
	f[1735] = "Gardes du corps de caserne";
end

if LOCALE_itIT then
	f[1445] = "Orchi Lupi Bianchi";
	f[1515] = "Esiliati Arakkoa";
	f[1520] = "Esiliati Torvaluna";
	f[1681] = "Lancia di Vol'jin";
	f[1682] = "Avanguardia di Wrynn";
	f[1708] = "Orchi Teschio Ridente";
	f[1710] = "Protettori Sha'tari";
	f[1711] = "Società di Preservazione degli Spargifumo";
	f[1731] = "Concilio degli Esarchi";
	f[1732] = "Spedizione su Draenor degli Spargifumo";
	f[1735] = "Guardie del Corpo della Caserma";
end

if LOCALE_ptBR then
	f[1445] = "Orcs Lobo do Gelo";
	f[1515] = "Arakkoas Proscritos";
	f[1520] = "Exilados da Lua Negra";
	f[1681] = "Lança de Vol'jin";
	f[1682] = "Vanguarda de Wrynn";
	f[1708] = "Orcs Cargaveira";
	f[1710] = "Defesa Sha'tari";
	f[1711] = "Sociedade de Preservação de Bondebico";
	f[1731] = "Conselho de Exarcas";
	f[1732] = "Expedição a Draenor de Bondebico";
	f[1735] = "Guarda-costas do Quartel";
end

if LOCALE_ruRU then
	f[1445] = "Клан Северного Волка";
	f[1515] = "Араккоа-изгои";
	f[1520] = "Изгнанники клана Призрачной Луны";
	f[1681] = "Копье Вол'джина";
	f[1682] = "Авангард Ринна";
	f[1708] = "Клан Веселого Черепа";
	f[1710] = "Защитники Ша'тар";
	f[1711] = "Археологическое общество Хитрой Шестеренки";
	f[1731] = "Совет экзархов";
	f[1732] = "Дренорcкая Экспедиция Хитрой Шестеренки";
	f[1735] = "Телохранители из казарм";
end

if LOCALE_zhTW then
	f[1445] = "霜狼獸人";
	f[1515] = "阿拉卡流亡者";
	f[1520] = "影月流亡者";
	f[1681] = "沃金暗矛部族";
	f[1682] = "烏瑞恩先鋒軍";
	f[1708] = "獰笑骷髏獸人";
	f[1710] = "撒塔斯防禦者";
	f[1711] = "熱砂保護協會";
	f[1731] = "主教議會";
	f[1732] = "熱砂德拉諾遠征軍";
	f[1735] = "兵營保鏢";
end

if LOCALE_zhCN then
	ns.factions[1445] = "霜狼兽人";
	ns.factions[1515] = "鸦人流亡者";
	ns.factions[1520] = "影月流亡者";
	ns.factions[1681] = "沃金之矛";
	ns.factions[1682] = "乌瑞恩先锋军";
	ns.factions[1708] = "嘲颅兽人";
	ns.factions[1710] = "沙塔尔防御者";
	ns.factions[1711] = "热砂保护协会";
	ns.factions[1731] = "主教议会";
	ns.factions[1732] = "热砂港德拉诺探险队";
	ns.factions[1735] = "要塞保镖";
end

--if LOCALE_koKR then end


