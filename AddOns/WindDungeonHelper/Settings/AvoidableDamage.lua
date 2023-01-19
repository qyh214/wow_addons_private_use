local W, F, L, P = unpack(select(2, ...))

P.avoidableDamage = {
    enable = true,
    alwaysOutputToChat = false,
    notification = {
        enable = true,
        channel = "PARTY",
        threshold = 40,
        unit = "ASIA",
        accuracy = 1
    },
    rank = {
        enable = true,
        addonInfo = true,
        worst = false,
        onlyRanking = false,
        customWorst = L["Need improve"]
    },
    custom = {
        enable = false,
        warningMessage = L["%name% got hit by %spell%."],
        stacksMessage = L["%name% got hit by %spell%. %stack% Stacks."],
        spellMessage = L["%name% got hit by %spell% for %damage% (%percent%)."]
    }
}