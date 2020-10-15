local W, F, L, P = unpack(select(2, ...))

P.avoidableDamage = {
    enable = true,
    compatible = true,
    notification = {
        enable = true,
        channel = "PARTY",
        threshold = 30,
        unit = "ASIA",
        accuracy = 1
    },
    rank = {
        enable = true,
        worst = false,
        customWorst = L["Need improve"]
    },
    custom = {
        enable = false,
        warningMessage = L["%name% got hit by %spell%."],
        stacksMessage = L["%name% got hit by %spell%. %stack% Stacks."],
        spellMessage = L["%name% got hit by %spell% for %damage% (%percent%)."]
    }
}