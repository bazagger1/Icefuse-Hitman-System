--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/entities/zhits_phone.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

AddCSLuaFile()

ENT.Type                = 'anim'
ENT.Base                = 'base_gmodentity'

if CLIENT then
      ENT.PrintName           = 'Hit Phone'
      ENT.Category            = 'Icefuse Utilities'
end

ENT.Spawnable           = true

local function cfg(var)
	return (not var and zhits.cfg or zhits.cfg[var].value)
end

local function translate(var)
	return (not var and zhits.language or zhits.language[var])
end

if SERVER then
      function ENT:Initialize()
            self:SetModel 'models/props_trainstation/payphone001a.mdl'
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)

            local phys = self:GetPhysicsObject()

            if IsValid(phys) then
                  phys:Wake()
            end
      end

      function ENT:Use(cal)
            if IsValid(cal) then
                  if not cfg 'noHitmanHits' then
                        if cal:IsHitman() then
                              zhits.notifyPlayer(cal, translate 'noHitmanHits')
                              return
                        end
                  end

                  net.Start 'zhits.openHitMenu'
                  net.Send(cal)

                  cal.currentHitPhone = self
            end
      end
end

if CLIENT then
      local LocalPlayer = LocalPlayer
      local Vector = Vector
      local Angle = Angle
      local math = math
      local cam = cam

      local overheadColor = zhits.overheadColor

      function ENT:Draw()
            self:DrawModel()

            local pos = self:GetPos()
            local dist = LocalPlayer():GetPos():DistToSqr(pos)

            if dist < 70000 then
                  local hop = math.abs( math.cos( CurTime() * 1 ) )
                  local pos = self:GetPos() + Vector( 0, 0, 50 + hop * 15 )
                  local ang = Angle( 0, LocalPlayer():EyeAngles().y - 90, 90 )

                  cam.Start3D2D( pos, ang, 0.1 )
                        zhits.text('Hit Phone', 130, 0, 0, overheadColor, 1)
                  cam.End3D2D()
            end
      end
end