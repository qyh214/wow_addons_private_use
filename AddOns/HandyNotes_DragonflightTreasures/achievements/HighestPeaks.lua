local myname, ns = ...

local HIGHEST = {
	achievement=15890,
	achievementNotFound=true,
	minimap=false, -- there's a flag once they're unlocked
	texture=ns.atlas_texture("racing", {r=0, g=1, b=0}),
	requires=ns.DRAGONRIDING,
	hide_before={
		ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 6),
		ns.conditions.GarrisonTalent(2164),
	},
}

ns.RegisterPoints(ns.WAKINGSHORES, {
	[28714773] = {quest=70826, vignette=5395,},
	[43976295] = {quest=70825, vignette=5394,},
	[54807412] = {quest=71204, vignette=5410,},
	[56024541] = {quest=70823, vignette=5392,},
	[73363885] = {quest=70824, vignette=5393,},
}, HIGHEST)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
	[28327764] = {quest=71200, vignette=5409,},
	[30393646] = {quest=71207, vignette=5411,},
	[57753081] = {quest=70827, vignette=5396,},
	[86313928] = {quest=71208, vignette=5412,},
}, HIGHEST)

ns.RegisterPoints(ns.AZURESPAN, {
	[31912703] = {quest=71215}, -- no vignette?
	[37476621] = {quest=71216, vignette=5418,},
	[46142499] = {quest=71218, vignette=5420,},
	[63084866] = {quest=71220, vignette=5421,},
	[74854324] = {quest=71221, vignette=5422,},
	[77441838] = {quest=71217, vignette=5419,},
}, HIGHEST)

ns.RegisterPoints(ns.THALDRASZUS, {
	[34048484] = {quest=71222, vignette=5423,},
	[46117398] = {quest=70024, vignette=5390,},
	[50168163] = {quest=70039, vignette=5391,},
	[65727498] = {quest=71223, vignette=5424,},
	[64645672] = {quest=71224, vignette=5425,},
}, HIGHEST)

ns.RegisterPoints(ns.FORBIDDENREACH, {
    [54593464] = {quest=73699, vignette=5535,},
    [36933792] = {quest=73700, vignette=5536,},
    -- These were also added in 10.0.7 per the vignette data, but I haven't found them:
    -- [] = {quest=73696, vignette=5533,},
    -- [] = {quest=73702, vignette=5537,},
}, HIGHEST)
