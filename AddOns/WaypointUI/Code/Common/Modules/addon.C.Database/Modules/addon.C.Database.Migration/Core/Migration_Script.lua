---@class addon
local addon = select(2, ...)
local CallbackRegistry = addon.C.CallbackRegistry.Script
local PrefabRegistry = addon.C.PrefabRegistry.Script
local TagManager = addon.C.TagManager.Script
local L = addon.C.AddonInfo.Locales
local NS = addon.C.Database.Migration; addon.C.Database.Migration = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	local MIGRATION_GLOBAL = addon.C.AddonInfo.Variables.Database.MIGRATION_GLOBAL
	local MIGRATION_LOCAL = addon.C.AddonInfo.Variables.Database.MIGRATION_LOCAL
	local MIGRATION_GLOBAL_PERSISTENT = addon.C.AddonInfo.Variables.Database.MIGRATION_GLOBAL_PERSISTENT
	local MIGRATION_LOCAL_PERSISTENT = addon.C.AddonInfo.Variables.Database.MIGRATION_LOCAL_PERSISTENT

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		local function MigrateDatabase(migrationTable, database)
			if #migrationTable > 0 then
				for _, v in ipairs(migrationTable) do
					if database.profile[v.from] then
						database.profile[v.to] = database.profile[v.from]
					end
				end
			end
		end

		function Callback:Migrate()
			MigrateDatabase(MIGRATION_GLOBAL, addon.C.Database.Variables.DB_GLOBAL)
			MigrateDatabase(MIGRATION_LOCAL, addon.C.Database.Variables.DB_LOCAL)
			MigrateDatabase(MIGRATION_GLOBAL_PERSISTENT, addon.C.Database.Variables.DB_GLOBAL_PERSISTENT)
			MigrateDatabase(MIGRATION_LOCAL_PERSISTENT, addon.C.Database.Variables.DB_LOCAL_PERSISTENT)
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:Migrate()
	end
end
