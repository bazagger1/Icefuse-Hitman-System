--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/autorun/zhitman_init.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

zhits 			= zhits or {
	cfg			= {},
	hitmen		= {},
	activeHits 		= {},
	language 		= {},
	user			= '76561198253220777'
}

if SERVER then
	-- Add all the client/shared files
	AddCSLuaFile 'zhitman/sh_core.lua'
	AddCSLuaFile 'zhitman/sh_config.lua'
	AddCSLuaFile 'zhitman/cl_derma.lua'
	AddCSLuaFile 'zhitman/cl_core.lua'
	AddCSLuaFile 'zhitman/sh_languages.lua'

	-- Load all the server/shared files
	include 'zhitman/sh_core.lua'
	include 'zhitman/sh_config.lua'
	include 'zhitman/sh_languages.lua'
	include 'zhitman/sv_core.lua'
else
	-- Load all the client/shared files on the client
	include 'zhitman/sh_core.lua'
	include 'zhitman/sh_config.lua'
	include 'zhitman/sh_languages.lua'
	include 'zhitman/cl_derma.lua'
	include 'zhitman/cl_core.lua'
end

MsgC(Color(255,215,0), '.::::|||| Psyche ||||::::. 10/06/2017 .:::: Finished loading new Hitman System! ::::. \n')

timer.Simple(0, function()
	DarkRP.disabledDefaults['modules']['hitmenu'] = true

	if CLIENT then
		hook.Remove('KeyPress', 'openHitMenu')
		hook.Remove('HUDPaint', 'DrawHitOption')
	end

	if SERVER then
		DarkRP.defineChatCommand('requesthit', function(pl)
			zhits.notifyPlayer(pl, 'Use !placehit instead.')
			return false
		end)

		local PLAYER = FindMetaTable 'Player'

		function PLAYER:requestHit()
			return true
		end

		hook.Remove('OnPlayerChangedTeam', 'Hitman system')
		hook.Remove('playerArrested', 'Hitman system')
		hook.Remove('PlayerDisconnected', 'Hitman system')
		hook.Remove('PlayerDeath', 'DarkRP Hitman System')
	end
end)