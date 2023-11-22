local W, F, L, P = unpack(select(2, ...))

P.groupInviteGuard = {
    enabled = true,
    displayMessageAfterRejecting = true,
    allowWhisperedTarget = true,
    smartMode = false,
    muteAlreadyInGroupSound = true,
    onlyFriendsOrGuildMembers = true,
    chatFilterMode = false
}