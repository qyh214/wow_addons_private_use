local myname, ns = ...

ns.hiddenConfig = {
    groupsHidden = true,
}

ns.groups["puzzlecache"] = "Caches of Creation"
ns.groups["lostovoid"] = "{item:190239:Lost Ovoid}"
ns.groups["soulshape"] = "Soulshapes"
ns.groups["coreless"] = "Coreless Automa"

ns.defaults.profile.groupsHiddenByZone[1970] = {
    puzzlecache = true,
    coreless = true,
}
ns.defaults.profile.achievementsHidden[15229] = true
