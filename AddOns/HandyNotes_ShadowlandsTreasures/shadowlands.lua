local myname, ns = ...

ns.hiddenConfig = {
    groupsHidden = true,
}

ns.groups["faerietales"] = "{achievement:14788:Fractured Faerie Tales}"
ns.groups["shardlabor"] = "{achievement:14339:Shard Labor}"
ns.groups["wardrobemakeover"] = "{achievement:14748:Wardrobe Makeover}"
ns.groups["sorrow"] = "{achievement:14626:Harvester of Sorrow}"
ns.groups["puzzlecache"] = "Caches of Creation"
ns.groups["lostovoid"] = "{item:190239:Lost Ovoid}"
ns.groups["soulshape"] = "Soulshapes"

ns.defaults.profile.groupsHiddenByZone[1970] = {
    puzzlecache = true,
}
