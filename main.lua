-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright (c) 2025 Thomas Floeren

local MYNAME, A = ...
local MYPRETTYNAME = C_AddOns.GetAddOnMetadata(MYNAME, 'Title') or '<UNKNOWN ADDON NAME>'
local MYVERSION = C_AddOns.GetAddOnMetadata(MYNAME, 'Version') or '<UNKNOWN ADDON VERSION>'
local MYSHORTNAME = 'SF'
local db = A.db

-- local C_Timer_After = C_Timer.After
local WTC = WrapTextInColorCode
local tonumber = tonumber
-- local type = type
local format = format
local InCombatLockdown = InCombatLockdown


--[[============================================================================
	Constants and Utils
============================================================================]]--

--[[----------------------------------------------------------------------------
	Color, Sound
----------------------------------------------------------------------------]]--

local colors = { -- When changing, change also the literals in the securehandlerbody!
	ADDON = '1E90FF', -- dodgerblue
	TXT = 'FFF8DC', -- cornsilk
	DEBUG = 'FF00FF', -- magenta
-- 	HEAD = 'F4A460', -- sandybrown
	HEAD = '66CDAA', -- mediumaquamarine
-- 	HEAD = 'DA70D6', -- orchid
-- 	HEAD = 'FFE4B5', -- moccasin
	WARN = 'FF4500', -- orangered
	BAD = 'DC143C', -- crimson
	ON = '32CD32', -- limegreen
	OFF = 'C0C0C0', -- silver
	CMD = 'FFA500', -- orange
	KEY = 'FFD700', -- gold
	LOCKED = 'FA8072', -- salmon
	UNLOCKED = '90EE90', -- lightgreen
}

local CLR = setmetatable({}, {
	__index = function(_, k)
		local color = colors[k]
		assert(color, format('Color %q not defined.', k))
		color = 'FF' .. color
		return function(text) return text and WTC(text, color) or '\124c' .. color end
	end,
})

local BLOCKSEP = CLR.ADDON(strrep('+', 42))

local function addonprint(msg)
	print(format('%s%s: %s', CLR.ADDON(), MYPRETTYNAME, CLR.TXT(msg)))
end

-- local function debugprint(...)
-- 	print(format('%s%s > DEBUG > %s', CLR.DEBUG(), MYSHORTNAME, CLR.TXT()), ...)
-- end

local enable_sound = true

local SND = {
	LOCK = 567523, -- alpha & click
	UNLOCK = 567462,  -- alpha & click
	ALPHA_SET = 567455,
	ALPHA_CANNOT = 2024957,
}

local function playsound(sound)
	if enable_sound then PlaySoundFile(sound) end
end


--[[----------------------------------------------------------------------------
	Frames
----------------------------------------------------------------------------]]--

A.ALPHA_COMBAT = 1

local FRAMES = {
	player = {
		global = PlayerFrame,
		group = 1,
		alpha_min = 0,
		},
	pet = {
		global = PetFrame,
		group = 1,
		alpha_min = 0,
		},
	target = {
		global = TargetFrame,
		group = 2,
		alpha_min = 0.1,
		},
	focus = {
		global = FocusFrame,
		group = 2,
		alpha_min = 0.1,
		},
}

-- Lookup by global
local frameglobals = setmetatable({}, {
	__index = function(_, key)
		for k, v in pairs(FRAMES) do
			if v.global:GetName() == key:GetName() then return k end
		end
	end,
})


--[[============================================================================
	Main
============================================================================]]--

--[[---------------------------------------------------------------------------
	Alpha
---------------------------------------------------------------------------]]--

-- @ PLAYER_LOGIN, @ PLAYER_REGEN_DISABLED, @ PLAYER_REGEN_ENABLED
function A.frames_set_alpha(value)
	value = tonumber(value)
	for k, v in pairs(FRAMES) do
		if v.global then v.global:SetAlpha(value or A.db.frames[k].alpha) end
	end
end

local function alpha_new(frame, delta)
	local alpha = A.db.frames[frame].alpha
	-- This changes between 0-10-30-50-70-90-100 and 0-20-40-60-80-100
-- 	alpha = min(10, alpha * 10 + delta * (alpha == 0 and 1 or 2))
	-- This is 0-10-20-30-40-50-60-70-80-90-100
	alpha = min(10, alpha * 10 + delta) -- Simple way
	-- This is 0-20-40-60-80-100
-- 	alpha = min(10, alpha * 10 + delta * 2)
	return floor(alpha + 0.5) / 10
end

local msg_timestamp = 0

local function frame_scroll(self, delta)
	if InCombatLockdown() then return end
	if IsModifiedClick() then -- Alpha
		if A.db.frames.alpha_locked then
			-- For the fast scrollers, throttle the msg a bit
			local now = GetTime()
			if now - msg_timestamp > 1 then
				addonprint(
					format(
						'Alpha is %s; %s frame to unlock.',
						CLR.LOCKED('locked'),
						CLR.KEY('double-click')
					)
				)
				msg_timestamp = now
				playsound(SND.ALPHA_CANNOT)
			end
		else
			local frame = frameglobals[self]
			local alpha = max(FRAMES[frame].alpha_min, alpha_new(frame, delta))
			for _, v in pairs(FRAMES) do
				if v.group == FRAMES[frame].group then v.global:SetAlpha(alpha) end
			end
			if alpha ~= A.db.frames[frame].alpha then
				addonprint(format('Alpha: %s%%', CLR.KEY(alpha * 100)))
				playsound(SND.ALPHA_SET)
				A.db.frames[frame].alpha = alpha
			end
		end
	else -- Click-through; analogous to the combat version
		local state = self:IsMouseEnabled()
		self:EnableMouse(delta == 1)
		if self:IsMouseEnabled() ~= state then
			addonprint(
				format(
					'Slip Frames: %s: %s',
					self:GetName(),
					state and CLR.LOCKED('Click-through') or CLR.UNLOCKED('Mouse enabled')
				)
			)
		playsound(state and SND.LOCK or SND.UNLOCK)
		end
	end
end

-- Alpha-lock is always set for all frames
local function frame_alpha_lock()
	if not InCombatLockdown() then
		A.db.frames.alpha_locked = not A.db.frames.alpha_locked
		addonprint(format('Alpha values %s.', A.db.frames.alpha_locked and CLR.LOCKED('locked') or CLR.UNLOCKED('unlocked')))
		playsound(A.db.frames.alpha_locked and SND.LOCK or SND.UNLOCK)
	end
end

-- Set the alpha to 1 when hovering over, reset to set value when mouse leaves
-- Do not test against the 2nd parameter `motion`, otherwise alpha stays at 1 when mouse leaves
local function frame_alpha_mouse_enter(self)
	if not InCombatLockdown() then
		local frame = frameglobals[self]
		for _, v in pairs(FRAMES) do
			if v.group == FRAMES[frame].group then v.global:SetAlpha(1) end
		end
	end
end

local function frame_alpha_mouse_leave(self)
	if not InCombatLockdown() then
		local frame = frameglobals[self]
		for _, v in pairs(FRAMES) do
			if v.group == FRAMES[frame].group then v.global:SetAlpha(A.db.frames[frame].alpha) end
		end
	end
end


--[[---------------------------------------------------------------------------
	Mouse enable/disable
---------------------------------------------------------------------------]]--

function A.frames_set_mouse() -- @ PLAYER_LOGIN
	for k, v in pairs(FRAMES) do
		if v.global then v.global:EnableMouse(A.db.frames[k].mouse) end
	end
end

-- We must be able to unlock the frame in combat
-- 1 for backward (down), -1 for forward
local securehandlerbody = [=[
	if PlayerInCombat() and not IsModifiedClick() then
		local state = self:IsMouseEnabled()
		self:EnableMouse(offset == 1)
		if self:IsMouseEnabled() ~= state then
			print('\124cff1E90FFSlip Frames:\124cffFFF8DC '
				.. self:GetName() .. ': '
				.. (state and '\124cffFA8072Click-through' or '\124cff90EE90Mouse enabled')
			)
		end
	end
]=]

-- We cannot access our db in combat, so we write later
function A.save_frames_mouse() -- @ PLAYER_LOGOUT
	for k, v in pairs(FRAMES) do
		A.db.frames[k].mouse = v.global:IsMouseEnabled()
	end
end

-- Put everything in place
for _, v in pairs(FRAMES) do
	if v.global then
		v.global:HookScript('OnMouseWheel', frame_scroll)
		v.global:HookScript('OnDoubleClick', frame_alpha_lock)
		v.global:HookScript('OnEnter', frame_alpha_mouse_enter)
		v.global:HookScript('OnLeave', frame_alpha_mouse_leave)
		SecureHandlerWrapScript(v.global, 'OnMouseWheel', v.global, securehandlerbody)
	end
end


--[[============================================================================
	UI
============================================================================]]--

local CMD1, CMD2, CMD3 = '/slipframes', '/sfr', nil

local help = {
	format(
		'%s%s Mouse Wheel Help:',
		CLR.HEAD(),
		CLR.ADDON(MYPRETTYNAME)
	),
	format('%sRoll %s on unit frame:', CLR.HEAD(), CLR.CMD('mouse weel')),
	format('%s%s : Lock frame (mouse click-through)..', CLR.TXT(), CLR.CMD('Up (forward)')),
	format('%s%s : Unlock frame (receives mouse clicks).', CLR.TXT(), CLR.CMD('Down (backward)')),
	format('%s%s : Frame transparency.', CLR.TXT(), CLR.CMD('Up/down with modifier key')),
	format(
		'%s%s is per group: %s vs %s frames. %s is per frame.',
		CLR.TXT(),
		CLR.KEY('Transparency'),
		CLR.KEY('Player & Pet'),
		CLR.KEY('Target & Focus'),
		CLR.KEY('Click-through')
	),
	format(
		'%s%s any frame to %s values.',
		CLR.TXT(),
		CLR.CMD('Double-click'),
		CLR.KEY('lock all transparency')
	),
	format(
		'%s%s Slash Command Help:',
		CLR.HEAD(),
		CLR.ADDON(MYPRETTYNAME)
	),
	format(
		'%s%s or %s understands these arguments:',
		CLR.HEAD(),
		CLR.CMD(CMD1),
		CLR.CMD(CMD2)
	),
	format('%s%s : Print addon version.', CLR.TXT(), CLR.CMD('version')),
	format('%s%s or %s : Print this help text.', CLR.TXT(), CLR.CMD('help'), CLR.CMD('h')),
}

local function multiprint(lines)
	for _, v in ipairs(lines) do
		print(v)
	end
end


--[[----------------------------------------------------------------------------
	Slash function
----------------------------------------------------------------------------]]--

SLASH_SlipFrames1 = CMD1
SLASH_SlipFrames2 = CMD2
SlashCmdList.SlipFrames = function(msg)
	local args = {}
	for arg in msg:gmatch('[^ ]+') do
		tinsert(args, arg)
	end
	if args[1] == 'version' or args[1] == 'ver' then
		addonprint(format('Version %s', CLR.KEY(MYVERSION)))
	elseif args[1] == 'dm' then
		db.debugmode = not db.debugmode
		addonprint(
			format(
				"Debug mode %s. Currently, there aren't any debug prints.",
				db.debugmode and CLR.ON('enabled') or CLR.OFF('disabled')
			)
		)
	elseif args[1] == nil or args[1] == 'help' or args[1] == 'h' then
		print(BLOCKSEP)
		multiprint(help)
		print(BLOCKSEP)
	end
end
