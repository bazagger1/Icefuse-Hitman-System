--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/zhitman/sh_config.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

--
-- To add a root steamid
-- do the following after the next line:
-- zhits.cfg.rootSteamIDs['InsertSteamID/64'] = true
--

zhits.rootSteamIDs 						= {}
zhits.rootSteamIDs['STEAM_0:1:156504117']			= true
zhits.rootSteamIDs['76561198253220777']				= true

--
-- To add a root steamid
-- do the following after the next line:
-- zhits.cfg.configRanks['InsertGroup'] = true
--

zhits.configRanks						= {}
zhits.configRanks['superadmin']			= true
zhits.configRanks['c_e_o']				= true
zhits.configRanks['developer']			= true

zhits.overheadColor 						= Color(200, 50, 50) -- Color of overhead text above entities (phone, npc, etc)



























--
-- DO NOT EDIT THE FOLLOWING, YOU CAN DO IT IN-GAME!
-- YOU CAN EDIT IT HERE IF YOU WOULD LIKE, BUT IT'S EASIER IN-GAME
-- TYPE !hitconfig TO CONFIGURATE THE HIT SYSTEM
-- ENJOY <3
--

zhits.registerConfigVariable('jailHits', {
	name 			= 'Jail hits',
	desc 			= 'Be able to place hits while jailed?',
	type 			= 'bool',
	value 		= false
})

zhits.registerConfigVariable('notifyPrefix', {
	name 			= 'Notifications prefix',
	desc 			= 'Prefix of the notifications that players receive from the system',
	type 			= 'string',
	value 		= '[Icefuse Admin]'
})

zhits.registerConfigVariable('hitmanTeams', {
	name 			= 'Hitman teams',
	desc 			= 'These are the hitman teams, seperate with only a ",", for example: TEAM_HITMAN,TEAM_MOBBOSS,TEAM_ETC',
	type 			= 'string',
	value 		= 'TEAM_HITMAN,TEAM_MOBBOSS'
})

zhits.registerConfigVariable('telephoneOnly', {
	name 			= 'Telephone only hits',
	desc 			= 'Only be able to place hits through the telephone entity?',
	type 			= 'bool',
	value 		= false
})

zhits.registerConfigVariable('limitHits', {
	name 			= 'Hit limits',
	desc 			= 'Be limited to a certain amount of hits? (Set to 0 to disable)',
	type 			= 'number',
	value 		= 1
})

zhits.registerConfigVariable('minimumOffer', {
	name 			= 'Minimum hit price',
	desc 			= 'Sets the minimum hit price you can make (Set to 0 to disable)',
	type 			= 'number',
	value 		= 1000
})

zhits.registerConfigVariable('maxOffer', {
	name 			= 'Max hit price',
	desc 			= 'Sets the max hit price you can make (Set to 0 to disable)',
	type 			= 'number',
	value 		= 0
})

zhits.registerConfigVariable('noHitmanHits', {
	name 			= 'No hitman hits',
	desc 			= 'Should hitmans be able to request hits?',
	type 			= 'bool',
	value 		= false
})

zhits.registerConfigVariable('oneHitPerPerson', {
	name 			= 'One hit per player',
	desc 			= 'If there is already a hit on this player, it wont go through',
	type 			= 'bool',
	value 		= true
})

zhits.registerConfigVariable('removeHitOnTargetDeath', {
	name 			= 'Target death removing',
	desc 			= 'Should a hit be removed once the target dies?',
	type 			= 'bool',
	value 		= false
})

zhits.registerConfigVariable('removeHitOnHitmanDeath', {
	name 			= 'Hitman death removing',
	desc 			= 'Should an accepted hit be removed once the hitman dies?',
	type 			= 'bool',
	value 		= true
})

zhits.registerConfigVariable('removeHitOnHitmanArrest', {
	name 			= 'Hitman arrest removing',
	desc 			= 'Should an accepted hit be removed once the hitman is arrested?',
	type 			= 'bool',
	value 		= true
})

zhits.registerConfigVariable('randomHitsInterval', {
	name			= 'Random hits timer',
	desc			= 'How often (in seconds) a random hit occurs (set to 0 to disable)',
	type 			= 'number',
	value 		= 600
})

zhits.registerConfigVariable('randomHitsOffer', {
	name			= 'Random hits offer',
	desc			= 'How much is offered in a randomized hit?',
	type 			= 'number',
	value 		= 2500
})

zhits.registerConfigVariable('hitDescriptions', {
	name			= 'Hit descriptions',
	desc			= 'Should players be allowed to give descriptions about a hit?',
	type 			= 'bool',
	value 		= true
})

zhits.registerConfigVariable('hitAutoDelete', {
	name			= 'Hit auto-delete',
	desc			= 'Delete a hit after this amount of seconds. (Set to 0 to disable)',
	type 			= 'number',
	value 		= 520
})

zhits.registerConfigVariable('displayTarget', {
	name			= 'Display hit target',
	desc			= 'Should a hitman have a hud that displays the targets information?',
	type 			= 'bool',
	value 		= true
})

zhits.registerConfigVariable('chatNotify', {
	name			= 'Chat notifications',
	desc			= 'Enable to use chat notifications, disable to use default DarkRP notifications.',
	type 			= 'bool',
	value 		= true
})
