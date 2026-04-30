local AddonName, KeystoneLoot = ...;

KeystoneLoot.KeystoneMapping = {
    rules = {
        {
            keystones = { 2, 3 },
            endOfRun = { track = "champion", rank = 2 },
            greatVault = { track = "hero", rank = 1 }
        },
        {
            keystones = { 4 },
            endOfRun = { track = "champion", rank = 3 },
            greatVault = { track = "hero", rank = 2 }
        },
        {
            keystones = { 5 },
            endOfRun = { track = "champion", rank = 4 },
            greatVault = { track = "hero", rank = 2 }
        },
        {
            keystones = { 6 },
            endOfRun = { track = "hero", rank = 1 },
            greatVault = { track = "hero", rank = 3 }
        },
        {
            keystones = { 7 },
            endOfRun = { track = "hero", rank = 1 },
            greatVault = { track = "hero", rank = 4 }
        },
        {
            keystones = { 8, 9 },
            endOfRun = { track = "hero", rank = 2 },
            greatVault = { track = "hero", rank = 4 }
        },
        {
            keystones = { 10 },
            endOfRun = { track = "hero", rank = 3 },
            greatVault = { track = "greatvault", rank = 1 }
        }
    }
}
