-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2025 Thomas Floeren

local MYNAME, A = ...
local DB_ID = 'DB_018569C5_710D_4FE6_9C7F_D7389153A3AE'

--[[============================================================================
	SavedVariables and Defaults
============================================================================]]--

-- Note that we have the `LoadSavedVariablesFirst: 1` directive in the toc,
-- so no need to wait for ADDON_LOADED.

local function merge_defaults(src, dst)
	for k, v in pairs(src) do
		local src_type = type(v)
		if src_type == 'table' then
			if type(dst[k]) ~= 'table' then
				dst[k] = {}
			end
			merge_defaults(v, dst[k])
		elseif type(dst[k]) ~= src_type then
			dst[k] = v
		end
	end
end

-- DB version log here
local DB_VERSION_CURRENT = 1

local defaults = {
	frames = {
		player = {
			alpha = 0.3,
			mouse = true,
		},
		pet = {
			alpha = 0.3,
			mouse = true,
		},
		target = {
			alpha = 0.6,
			mouse = true,
		},
		focus = {
			alpha = 0.6,
			mouse = true,
		},
	},
	alpha_locked = false,
	debugmode = false,
	db_version = DB_VERSION_CURRENT,
}

if type(_G[DB_ID]) ~= 'table' then
	_G[DB_ID] = {}
elseif not _G[DB_ID].db_version or _G[DB_ID].db_version ~= DB_VERSION_CURRENT then
	-- Clean up stuff, update db structure
	-- _G[DB_ID].db_version = DB_VERSION_CURRENT
end

merge_defaults(defaults, _G[DB_ID])

local db = _G[DB_ID]
A.db = db
A.defaults = defaults
