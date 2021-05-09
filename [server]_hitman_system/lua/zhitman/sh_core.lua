--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/zhitman/sh_core.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

-- FUCK WHY DID I OVERCOMPLICATE IT AND USE METATABLES GOD DAYUMIT
-- its okie tho

--
-- no clue why i decided to comment shit in this file
-- i fuckin hate commenting :(
--

--
-- zhits.registerConfigVariable(String id, table data)
--
-- Registers a config value to use in the in-game
-- config menu.
--

local saveConfig = {}

zhits.defaults = zhits.defaults or {}

function zhits.registerConfigVariable(id, data)
	if not data.type or data.value == nil then -- value can be false by default oops
		for i = 1, 10 do
			print('CORRUPT CONFIG VARIABLE FOR ZHITS SYSTEM: ' .. id)
		end

		return
	end

	zhits.cfg[id] = {
		type = data.type,
		value = data.value,
		desc = data.desc,
		name = data.name,
		id = id
	}

	zhits.defaults[id] = data.value
end

if SERVER then
	--
	-- Load config now
	--

	hook.Add('Initialize', 'loadHitsConfig', function()
		local data = file.Read('zhits_config.txt', 'DATA')

		if not data then return end
		if data == '' then return end

		data = util.JSONToTable(data)

		for id, data in ipairs(data) do
			zhits.cfg[id] = {
				name = data.name,
				desc = data.desc,
				type = data.type,
				value = data.value
			}
		end
	end)
end

local HIT = {}
	HIT.__index = HIT

--
-- cfg(String var)
--
-- just makes getting the value of a config var
-- a lot easier ;)
--

local function cfg(var)
	return (not var and zhits.cfg or zhits.cfg[var].value)
end

--
-- ENUMS for the OnHitDeleted hook
--

HIT_NO_REASON		= 0
HIT_COMPLETE 		= 1
HIT_MAN_DIED		= 2
HIT_MAN_ARRESTED		= 3
HIT_TARGET_DISCONNECTED	= 4
HIT_TARGET_DIED		= 5
HIT_REQUESTER_DISCONNECTED	= 6
HIT_TIME_RAN_OUT		= 7

local curID = 1

--
-- zhits.registerHit(Player requester)
--
-- Creates the meta table of the current hit, and
-- is used to store the information of the hit
--

function zhits.registerHit(requester)
	local data 			= {
		requesterID		= (requester and requester:SteamID64() or nil),
		requester 		= (requester or nil),
		id			= curID
	}

	setmetatable(data, HIT)
	zhits.activeHits[#zhits.activeHits + 1] = data

	curID = curID + 1

	return data
end

--
-- HIT:GetID()
--
-- Returns the current hits ID
--

function HIT:GetID()
	return self.id
end

function HIT:SetID(num)
	self.id = num
	return self
end

--
-- HIT:GetRequester(bool id)
--
-- Returns the requester of the hit (Player, nil if invalid)
-- if id is set to true, it'll return the requesters SteamID64
--

function HIT:GetRequester(id)
	return (IsValid(self.requester) and not id and self.requester or id and self.requesterID or nil)
end

--
-- HIT:GetIndex()
--
-- returns the table infex of the zhits.activeHits table
--

function HIT:GetIndex()
	local activeHits = zhits.activeHits

	for i = 1, #activeHits do
		local hit = activeHits[i]

		if hit:GetID() == self:GetID() then
			return i
		end
	end

	return nil
end

--
-- HIT:SetTarget(Player target)
--
-- Sets the target of the hit
--

function HIT:SetTarget(target)
	self.target = target

	hook.Run("OnHitPlaced", target, self:GetRequester())

	return self
end

--
-- HIT:GetTarget()
--
-- returns the target (Entity, nil if invalid)
--

function HIT:GetTarget()
	return (self.target and IsValid(self.target) and self.target or nil)
end

--
-- HIT:SetOffer(Integer offer)
--
-- Sets the offer the hitman will receive once hit is completed
-- hitman will be able to accept or deny this offer
--

function HIT:SetOffer(offer)
	self.offer = offer
	return self
end

--
-- HIT:GetOffer()
--
-- returns the current offer of the hit (interger, nil if not set)
--

function HIT:GetOffer()
	return self.offer
end

--
-- HIT:SetHitman(Player hitman)
--
-- Sets the hitman that's assigned to this current hit
-- this will do nothing if zhits.cfg['Multiple Hitmen'] is set to true
--

function HIT:SetHitman(hitman)
	self.hitman = hitman
	return self
end

--
-- HIT:GetHitman()
--
-- returns the hitman assigned to the hit, will return nil if
-- zhits.cfg['Multiple Hitmen'] is set to true
--

function HIT:GetHitman()
	return self.hitman
end

--
-- HIT:SetIsAvailable(bool isAvailable)
--
-- Sets whether or not the hit is available to be accepted
--

function HIT:SetIsAvailable(isAvailable)
	self.isAvailable = isAvailable
	return self
end

--
-- HIT:GetIsAvailable()
--
-- returns whether or not the hit is
-- available to be accepted (bool)
--

function HIT:GetIsAvailable()
	return self.isAvailable
end

--
-- HIT:SetDesc(String desc)
--
-- Sets the description of the hit
-- usually used for the memes but who cares lmao
-- If zhits.cfg['Allow Descriptions'] is set to false this wont do anything
--

function HIT:SetDesc(desc)
	if cfg 'hitDescriptions' then
		self.desc = desc
	end

	return self
end

--
-- HIT:GetDesc()
--
-- Return the description of the hit
-- Will return nil if zhits.cfg['Allow Descriptions'] is false
--

function HIT:GetDesc()
	return self.desc
end

--
-- HIT:Delete(ENUM reason)
--
-- deletes and removes the hit from the activeHits table
-- reason will be one of the following:
--
-- HIT_COMPLETE: Hit was completed successfully
-- HIT_MAN_DIED: Hitman died
-- HIT_MAN_ARRESTED: Hitman was arrested
-- HIT_TARGET_DISCONNECTED: The target of the hit has disconnected
-- HIT_TARGET_DIED: Target of hit died (Other causes)
-- HIT_REQUESTER_CANCELLED: Requester of hit cancelled
--

function HIT:Delete(reason)
	if not reason then reason = HIT_NO_REASON end

	local index = self:GetIndex()

	if SERVER then
		if self:GetHitman() then
			zhits.setHitTarget(self:GetHitman(), nil)
		end
	end

	local req, targ = self:GetRequester(), self:GetTarget()
	local hitman = self:GetHitman()

	table.remove(zhits.activeHits, index)

	if not self:GetIsRandom() then
		if SERVER and self:GetRequester() and IsValid(self:GetRequester()) then
			zhits.hitCount[self:GetRequester(true)] = (zhits.hitCount[self:GetRequester(true)] or 0) - 1

			net.Start 'zhits.deleteHit'
				net.WriteInt(index, 32)
			net.Send(player.GetAll())
		elseif not IsValid(self:GetRequester()) then
			zhits.hitCount[self:GetRequester(true)] = nil
		end
	end

	hook.Run('OnHitDeleted', req, targ, reason, (hitman or nil))
end

--
-- HIT:SetIsRandom()
--
-- Sets the hit to be a randomized hit
-- meaning there will be no requester, and the
-- offer will be decided by the server
--

function HIT:SetIsRandom()
	self.isRandom = true
	return self
end

--
-- HIT:GetIsRandom()
--
-- returns whether or not a hit is randomized
--

function HIT:GetIsRandom()
	return (self.isRandom or false)
end

--
-- HIT:SendToHitmen()
--
-- sends the hit data to the hitmen on the
-- client-side
--

function HIT:SendToHitmen()
end

--
-- HIT:SendToHitman(Player hitman)
--
-- sends the hit data to the specified hitman on the
-- client-side
--

function HIT:SendToHitman(hitman)
end

local PLAYER = FindMetaTable 'Player'

function PLAYER:IsHitman()
	local data = string.Explode(',', cfg 'hitmanTeams')

	if #data > 0 then
		for _, str in ipairs(data) do
			if not _G[str] then continue end

			if _G[str] == self:Team() then
				return true
			end
		end
	end

	return (self:isHitman() or false)
end

function PLAYER:HasHit()
	for _, data in ipairs(zhits.activeHits) do
		if data:GetTarget() == self then
			return true
		end
	end

	return false
end

function zhits.getHitmen()
	local pls = player.GetAll()
	local hitmen = {}

	for i = 1, #pls do
		local pl = pls[i]

		if pl:IsHitman() then
			table.insert(hitmen, pl)
		end
	end

	return hitmen
end

// BLogs support

hook.Add("bLogs_FullyLoaded", "saport4hitsxd", function()
	if bLogs and SERVER then
		local MODULE = bLogs:Module()

		MODULE.Category = "General"
		MODULE.Name = "zHits"
		MODULE.Colour   = Color(255, 25, 25)

		MODULE:Hook("OnHitPlaced", "HitPlaced", function(pTarget, pRequester)
			MODULE:Log("A hit has been placed on " .. bLogs:FormatPlayer(pTarget) .. " by " .. (pRequester and IsValid(pRequester) and bLogs:FormatPlayer(pRequester) or "AUTOMATED"))
		end)

		MODULE:Hook("OnHitDeleted", "HitDeleted", function(pRequester, pTarget, REASON, pHitman)
			if REASON == HIT_COMPLETE then
				MODULE:Log("A hit on " .. bLogs:FormatPlayer(pTarget) .. " has just been completed" .. (pHitman and IsValid(pHitman) and " by " .. bLogs:FormatPlayer(pHitman) or ""))
			end
		end)

		bLogs:AddModule(MODULE)
	end
end)
--
--// PLogs support
--
--hook.Add("pLogs_FullyLoaded", "saport4hitsxd", function()
--	if pLogs and SERVER then
--		local MODULE = pLogs:Module()
--
--		MODULE.Category = "General"
--		MODULE.Name = "zHits"
--		MODULE.Colour   = Color(255, 25, 25)
--
--		MODULE:Hook("OnHitPlaced", "HitPlaced", function(pTarget, pRequester)
--			MODULE:Log("A hit has been placed on " .. pLogs:FormatPlayer(pTarget) .. " by " .. (pRequester and IsValid(pRequester) and pLogs:FormatPlayer(pRequester) --or "AUTOMATED"))
--		end)
--
--		MODULE:Hook("OnHitDeleted", "HitDeleted", function(pRequester, pTarget, REASON, pHitman)
--			if REASON == HIT_COMPLETE then
--				MODULE:Log("A hit on " .. pLogs:FormatPlayer(pTarget) .. " has just been completed" .. (pHitman and IsValid(pHitman) and " by " .. --pLogs:FormatPlayer(pHitman) or ""))
--			end
--		end)
--
--		pLogs:AddModule(MODULE)
--	end
--end)
--