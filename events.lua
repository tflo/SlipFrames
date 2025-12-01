-- SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
-- Copyright (c) 2025-2026 Thomas Floeren

local MYNAME, A = ...


--[[============================================================================
	Events
============================================================================]]--

local function PLAYER_LOGIN()
	A.frames_set_alpha()
	A.frames_set_mouse()
end

local function PLAYER_REGEN_DISABLED()
	A.frames_set_alpha(A.ALPHA_COMBAT)
end

local function PLAYER_REGEN_ENABLED()
	A.frames_set_alpha()
end

local function PLAYER_LOGOUT()
	A.save_frames_mouse()
end


--[[----------------------------------------------------------------------------
	Event frame, handlers, and registration
----------------------------------------------------------------------------]]--

local ef = CreateFrame('Frame', MYNAME .. '_eventframe')

local event_handlers = {
	['PLAYER_LOGIN'] = PLAYER_LOGIN,
	['PLAYER_REGEN_DISABLED'] = PLAYER_REGEN_DISABLED,
	['PLAYER_REGEN_ENABLED'] = PLAYER_REGEN_ENABLED,
	['PLAYER_LOGOUT'] = PLAYER_LOGOUT,
}

for event in pairs(event_handlers) do
	ef:RegisterEvent(event)
end

ef:SetScript('OnEvent', function(_, event, ...)
	event_handlers[event]()
end)
