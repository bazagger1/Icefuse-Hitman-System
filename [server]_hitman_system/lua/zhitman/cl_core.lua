--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/zhitman/cl_core.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

-- gonna localize shit i put in think/hudpaint

local LocalPlayer                   = LocalPlayer
local ScrW                          = ScrW
local ScrH                          = ScrH
local zhits                         = zhits
local Entity                        = Entity

local poses = {
      'pose_standing_01',
      'pose_standing_04',
      'pose_standing_03',
      'pose_standing_02'
}

local function randPose(ent)
      return ent:LookupSequence(poses[math.random(1, #poses)])
end

local function cfg(var)
	return (not var and zhits.cfg or zhits.cfg[var].value)
end

local function translate(var)
	return (not var and zhits.language or zhits.language[var])
end

net.Receive('zhits.notify', function()
      local msg = net.ReadString()
      chat.AddText(Color(255, 25, 25), cfg 'notifyPrefix' .. ' ', color_white, msg)
end)

local function numToBool(val)
	return (tonumber(val) > 0)
end

local bgclr = Color(0, 0, 0, 200)

local targData = { --fix this shit sometime, armor and health can stretch across screen if exceeding certain amount.
      {
            name = 'Target name',
            val = function(pl)
                  return pl:Name()
            end,
            barClr = Color(0, 0, 0, 0)
      },
      {
            name = 'Health',
            val = function(pl)
                  return pl:Health()
            end,
            barClr = Color(255, 25, 25, 100),
            perc = function(pl)
                  return pl:Health() / pl:GetMaxHealth()
            end
      },
      {
            name = 'Armor',
            val = function(pl)
                  return pl:Armor()
            end,
            barClr = Color(25, 25, 255, 100),
            perc = function(pl)
                  return pl:Armor() / 100
            end
      },
      {
            name = 'Distance',
            val = function(pl, l_pl)
                  local dist = pl:GetPos():Distance(l_pl:GetPos())

                  return (math.Clamp(math.Round(dist/50), 1, dist) .. 'm')
            end,
            barClr = Color(0, 0, 0, 0)
      },
      {
            name = 'Job',
            val = function(pl)
                  return (pl:getDarkRPVar 'job' or 'Unknown')
            end,
            barClr = Color(25, 255, 25, 50)
      }
}

local mdlW = 100
zhits.targ = zhits.targ or nil
local mdlX, mdlY, _mdlW, mdlH

net.Receive('zhits.setHitTarget', function()
      local new = net.ReadEntity()

      if new:IsWorld() then
            zhits.targ = nil
            return
      end

      zhits.targ = new
end)

hook.Add('HUDPaint', 'displayTargetHit', function()
      if cfg 'displayTarget' then
            local pl = LocalPlayer()

            if zhits.targ and IsValid(zhits.targ) and zhits.targ:IsPlayer() then
                  local w = ScrW() * .2
                  local h = 300

                  local x, y = 5, ScrH() / 2 - (h * .5)

                  local topHeight = 23
                  local barHeight = 20
                  local curY = y + topHeight + 3

                  zhits.box(x, y, w, topHeight, bgclr)
                  zhits.text(translate 'hitInfo', 20, x + 2, y + topHeight / 2, color_white, 0, 1)

                  for i = 1, #targData do
                        local data = targData[i]
                        local curW = w - mdlW

                        if i == 1 then
                              curW = w
                        end

                        zhits.box(x, curY, curW, barHeight, bgclr)
                        zhits.box(x, curY, (not data.perc and curW or (curW * data.perc(zhits.targ))), barHeight, data.barClr)

                        zhits.text(data.name .. ': ' .. data.val(zhits.targ, pl), 18, x + 2, curY + (barHeight / 2), color_white, 0, 1)

                        curY = curY + barHeight + 3
                  end

                  mdlX, mdlY, _mdlW, mdlH = x + (w - mdlW) + 3, y + barHeight + topHeight + 6, mdlW - 3, (curY - y) - topHeight - barHeight - 9

                  zhits.box(mdlX, mdlY, _mdlW, mdlH, bgclr)
            end
      end
end)

zhits.mdl = zhits.mdl or nil

hook.Add('Initialize', 'heeheshowmodelxdrawr', function()
      if zhits.mdl then zhits.mdl:Remove() end
      zhits.mdl = nil
      zhits.mdl = vgui.Create 'DModelPanel'
            zhits.mdl.isOn = false
            zhits.mdl.nextp = 0
            zhits.mdl.Think = function(self)
                  if zhits.targ and IsValid(zhits.targ) then
                        if zhits.targ:GetModel() ~= self:GetModel() and not self.isOn then
                              self:SetModel(zhits.targ:GetModel())
                              self:SetSize(_mdlW, mdlH)
                              self:SetPos(mdlX, mdlY)

                              self.isOn = true
                        end
                  end

                  if (not zhits.targ or not IsValid(zhits.targ) or not zhits.targ:IsPlayer()) and self.isOn then
                        self.isOn = false
                        self:SetSize(0, 0)
                        self:SetModel ''
                  end
            end
end)

--timer.Simple(0, function() hook.Call 'Initialize' end)

local childData = {
      ['number'] = function(parent, val)
            local newShit = parent:Add 'zhits_panel'
                  newShit:SetSize(parent:GetWide(), 75)
                  newShit.sendVal = function(self)
                        return self.numInput:GetValue()
                  end

            newShit.numInput = newShit:Add 'DTextEntry'
                  newShit.numInput:SetSize(newShit:GetWide() * .05, 25)
                  newShit.numInput:SetPos(newShit:GetWide() - newShit.numInput:GetWide() - 5, 5)
                  newShit.numInput:SetNumeric(true)

            if val and isnumber(val) then
                  newShit.numInput:SetValue(val)
            end

            return newShit
      end,
      ['string'] = function(parent, val)
            local newShit = parent:Add 'zhits_panel'
                  newShit:SetSize(parent:GetWide(), 75)
                  newShit.sendVal = function(self)
                        return self.strInput:GetValue()
                  end

            newShit.strInput = newShit:Add 'DTextEntry'
                  newShit.strInput:SetSize(newShit:GetWide() * .15, 25)
                  newShit.strInput:SetPos(newShit:GetWide() - (newShit.strInput:GetWide()) - 5, 5)
                  newShit.strInput:SetValue(val)

            return newShit
      end,
      ['bool'] = function(parent, isTicked)
            local newShit = parent:Add 'zhits_panel'
                  newShit:SetSize(parent:GetWide(), 75)
                  newShit.sendVal = function(self)
                        return (self.check:GetChecked() and 1 or 0)
                  end

            newShit.check = newShit:Add 'DCheckBox'
                  newShit.check:SetPos(newShit:GetWide() - 20, 5)
                  newShit.check:SetValue(isTicked or false)

            return newShit
      end,
      ['table'] = function(parent)
            -- nvm
      end
}

local function adminMenu()
      local w, h = ScrW(), ScrH()
	local sideSize = w * .15
	local sideButtonHeight = 45

      local bg = vgui.Create 'zhits_frame'
            bg:SetSize(w, h)
            bg:Center()
            bg:AddClose()
            bg.title = translate 'adminMenuTitle'
            bg.titleDesc = translate 'adminMenuDesc'
            bg.sideTitle = translate 'adminMenuSideTitle'

      local default = 'Search for a config variable'
      local textEntryColor = color_white

      local search = bg:Add 'DTextEntry'
            search:SetSize(w - 10, 23)
            search:SetPos(5, bg.topSize + 10)
            search:SetText(default)
            search:SetFont 'zhits_font_20'
            search.Paint = function(_, w, h)
                  zhits.box(0, 0, w, h, bgclr)
                  _:DrawTextEntryText(textEntryColor, Color(150, 150, 150, 150), textEntryColor)
            end
            search.OnGetFocus = function(self)
                  if self:GetValue() == default then
                        self:SetValue ''
                  end
            end

      local scroll = bg:Add 'DScrollPanel'
            scroll:SetSize(w - 10, h - bg.topSize - 15 - 28)
            scroll:SetPos(5, bg.topSize + 10 + 28)
            scroll:GetVBar():SetWide(0)
            scroll.display = function(self, str)
                  self:Clear()
                  toDisplay = {}

                  if str then
                        Print(str)
                        for id, d in pairs(zhits.cfg) do
                              if not d.id then continue end
                              if string.find(string.lower(d.name), string.lower(str), 1, true) ~= nil then
                                    table.insert(toDisplay, d)
                              end
                        end
                  else
                        toDisplay = zhits.cfg
                  end

                  local curY = 0
                  local trim = 100

                  for _, data in pairs(toDisplay) do
                        if childData[data.type] then
                              if data.desc:len() > trim then
                                    data.desc = data.desc:sub(1, trim - 3) .. '...'
                              end

                              local newShit = childData[data.type](scroll, data.value)
                                    newShit:SetPos(0, curY)
                                    newShit.outline = false

                                    local ex, ey

                                    if newShit.check then
                                          ex, ey = newShit.check:GetPos()
                                          ex = ex - 75
                                          ey = ey - 3
                                    end

                                    newShit.PaintOver = function(_, w, h)
                                          zhits.text('Name: ' .. data.name, 19, 3, 3, color_white)
                                          zhits.text('Description: ' .. data.desc, 19, 3, 22, color_white)
                                          zhits.text('Type: ' .. data.type, 19, 3, 40, color_white)
                                          zhits.text('Default: ' .. tostring(zhits.defaults[data.id]), 19, 3, 58, color_white)

                                          if data.type == 'bool' then
                                                zhits.text('Enabled: ', 19, ex, ey, color_white)
                                          end
                                    end

                              local saveCur = newShit:Add 'zhits_button'
                                    saveCur:SetSize(newShit:GetWide() * .1, 35)
                                    saveCur:SetPos(newShit:GetWide() - (newShit:GetWide() * .1) - 5, newShit:GetTall() - 40)
                                    saveCur.text = 'Save'
                                    saveCur.DoClick = function()
                                          if newShit:sendVal() ~= data.value then
                                                net.Start 'zhits.sendConfigValue'
                                                      net.WriteString(data.id)
                                                      net.WriteString(tostring(newShit:sendVal()))
                                                net.SendToServer()
                                          end
                                    end

                              curY = curY + newShit:GetTall() + 5
                        end
                  end
            end
            scroll.display(scroll)

            search.OnChange = function(_)
                  local str = _:GetValue()
                  scroll.display(scroll, str)
            end

      --local saveAll = bg:Add 'zhits_button'
      --      saveAll:SetSize(w - 10, 40)
      --      saveAll:SetPos(5, h - 45)
      --      saveAll.text = 'Save all'
      --      saveAll.textSize = 30
      --      saveAll.DoClick = function()
      --            net.Start 'zhits.sendWholeConfig'
      --                  net.WriteTable(zhits.cfg)
      --            net.SendToServer()
      --      end -- gonna disable for now lol
end

net.Receive('zhits.config', adminMenu)

local bg = nil

local function hitMenu()
      local w, h = ScrW() * .9, ScrH() * .9
      local sideSize = w * .2
      local curPl = nil
      local curDesc = ''

      if bg and IsValid(bg) then bg:Remove() end -- remove dat shit phag

      -- localize panels here so we dun ned 2 re organize dem shitz
      local mdl
      local offer

      bg = vgui.Create 'zhits_frame'
            bg:SetSize(w, h)
            bg:Center()
            bg:AddClose()
            bg.title = translate 'hitMenuTitle'
            bg.titleDesc = translate 'hitMenuDesc'
            bg.sideTitle = translate 'selectAPlayer'
            bg.leftTopSize = sideSize
            bg.outline = true

      local pls = {}
      local count = 0
      local noHitmen = false

      for _, pl in ipairs(player.GetAll()) do
            if pl:IsHitman() then
                  pls[count + 1] = pl
                  count = count + 1
            end
      end

      if count <= 0 then
            noHitmen = true
      end

      local active = bg:Add 'zhits_panel'
            active:SetSize(sideSize, h - bg.topSize - 15)
            active:SetPos(w - active:GetWide() - 5, bg.topSize + 10)
            active.outline = false

      local aLbl = active:Add 'DLabel'
            aLbl:SetText 'Active Hitmen:'
            aLbl:SetSize(active:GetWide(), 25)
            aLbl:SetFont 'zhits_font_25'
            aLbl:SetPos(0, 5)
            aLbl:SetContentAlignment(5)

      if noHitmen then
            local none = active:Add 'DLabel'
                  none:SetText 'No active hitmen!'
                  none:SetSize(active:GetWide(), 30)
                  none:SetPos(0, active:GetTall() / 2)
                  none:SetFont 'zhits_font_25'
                  none:SetContentAlignment(5)
      else
            local hscrl = active:Add 'DScrollPanel'
                  hscrl:SetSize(active:GetWide() - 10, active:GetTall() - 40)
                  hscrl:SetPos(5, 35)

            local curY = 0
            local ph = 45
            local clr = Color(30, 30, 30, 150)

            for _, pl in ipairs(pls) do
                  local plJob = team.GetName(pl:Team())

                  local pnl = hscrl:Add 'zhits_panel'
                        pnl:SetSize(hscrl:GetWide(), ph)
                        pnl:SetPos(0, curY)
                        pnl.outline = true
                        pnl.panelColor = clr
                        pnl.PaintOver = function(_, w, h)
                              if not IsValid(pl) then return end

                              zhits.text('Name: ' .. pl:Name(), 15, ph + 3, 3, color_white)
                              zhits.text('Job: ' .. plJob, 15, ph + 3, 14, color_white)
                              zhits.text('Group: ' .. pl:GetUserGroup(), 15, ph + 3, 25, color_white)
                        end

                  local avt = pnl:Add 'AvatarImage'
                        avt:SetSize(ph, ph)
                        avt:SetPlayer(pl)

                  curY = curY + ph + 5
            end
      end

      local plsBg = bg:Add 'zhits_panel'
            plsBg:SetSize(sideSize, h - bg.topSize - 15)
            plsBg:SetPos(5, bg.topSize + 10)
            plsBg.outline = false

      local textEntryColor = Color(180, 180, 180)

      local search = plsBg:Add 'DTextEntry'
            search:SetSize(plsBg:GetWide() - 10, 20)
            search:SetPos(5, 5)
            search:SetFont 'zhits_font_20'
            search:SetValue(translate 'searchForAPlayer')
            search.Paint = function(_, w, h)
                  zhits.box(0, 0, w, h, plsBg.panelColor)
                  _:DrawTextEntryText(textEntryColor, Color(150, 150, 150, 150), textEntryColor)
            end
            search.OnGetFocus = function(self)
                  if self:GetValue() == translate 'searchForAPlayer' then
                        self:SetValue ''
                  end
            end

      local scroll = plsBg:Add 'DScrollPanel'
            scroll:SetSize(plsBg:GetWide() - 10, plsBg:GetTall() - 15 - search:GetTall())
            scroll:SetPos(5, 10 + search:GetTall())
            scroll:GetVBar():SetWide(0)
            scroll.noPls = true
            scroll.display = function(s, pls)
                  s:Clear()

                  if not pls or #pls <= 0 then
                        s.noPls = true
                        return
                  end

                  s.noPls = false

                  local curY = 0
                  local ph = 60
                  local clr = Color(30, 30, 30, 150)

                  for _, pl in ipairs(pls) do
                        if pl == LocalPlayer() then continue end

                        local plJob = team.GetName(pl:Team())

                        /*if plTeam and team.GetColor(plTeam) then
                              local tc = team.GetColor(pl:Team())
                              clr = Color(tc.r, tc.g, tc.b, 20)
                        end*/

                        local pnl = s:Add 'zhits_panel'
                              pnl:SetSize(s:GetWide(), ph)
                              pnl:SetPos(0, curY)
                              pnl.outline = true
                              pnl.panelColor = clr
                              pnl.PaintOver = function(_, w, h)
                                    if not IsValid(pl) then return end

                                    zhits.text('Name: ' .. pl:Name(), 15, ph + 3, 3, color_white)
                                    zhits.text('Job: ' .. plJob, 15, ph + 3, 14, color_white)
                                    zhits.text('Group: ' .. pl:GetUserGroup(), 15, ph + 3, 25, color_white)
                              end

                        local avt = pnl:Add 'AvatarImage'
                              avt:SetSize(ph, ph)
                              avt:SetPlayer(pl)

                        local btn = pnl:Add 'zhits_button'
                              btn:SetSize(pnl:GetWide() - ph, 20)
                              btn:SetPos(ph, ph - 20)
                              btn.outline = false
                              btn.text = 'Select'
                              btn.DoClick = function()
                                    curPl = pl
                                    mdl.update(mdl)
                              end

                        curY = curY + ph + 10
                  end
            end

            search.OnChange = function(_)
                  local str = _:GetValue()

                  if str ~= '' then
                        local pls = {}
                        local all = player.GetAll()

                        for i = 1, #all do -- want this loop as light as possible
                              local pl = all[i]
                              if not pl then continue end

                              if string.find(string.lower(pl:Name()), string.lower(str), 1, true) ~= nil then
                                    table.insert(pls, pl)
                              end
                        end

                        scroll.display(scroll, pls)
                  end
            end

            scroll.display(scroll, player.GetAll())

      local addedY = 0

      local mid = bg:Add 'zhits_panel'
            mid:SetSize(w - sideSize - active:GetWide() - 20, h - bg.topSize - 15)
            mid:SetPos(sideSize + 10, bg.topSize + 10)
            mid.PaintOver = function(_, w, h)
                  if not curPl or not IsValid(curPl) then
                        zhits.text('Select a player!', 25, w / 2 - (w * .4 / 2), h / 2, color_white, 1, 1)
                  else
                        local curY = 3
                        zhits.text('Player information:', 20, 3, curY, color_white) curY = curY + 20
                        zhits.text('      Name: ' .. curPl:Name(), 20, 3, curY, color_white) curY = curY + 20
                        zhits.text('      Job: ' .. (team.GetName(curPl:Team()) or 'Undefinded'), 20, 3, curY, color_white) curY = curY + 20
                        zhits.text('      Money: ' .. DarkRP.formatMoney(curPl:getDarkRPVar 'money'), 20, 3, curY, color_white) curY = curY + 20
                        zhits.text('      Usergroup: ' .. curPl:GetUserGroup(), 20, 3, curY, color_white) curY = curY + 20

                        addedY = curY
                  end
            end

      local changed = false

      local hlbl = mid:Add 'DLabel'
            hlbl:SetSize(mid:GetWide() - (mid:GetWide() * .4), 25)
            hlbl.Think = function(self)
                  if curPl and IsValid(curPl) then
                        self:SetPos(3, addedY + 10)
                        self:SetText 'Hit information:'

                        if not changed then
                              changed = true
                              addedY = addedY + 55
                        end
                  else
                        self:SetText ''
                  end
            end
            hlbl:SetText 'Hit information:'
            hlbl:SetFont 'zhits_font_25'
            hlbl:SetTextColor(color_white)

      offer = mid:Add 'DNumSlider'
            offer:SetSize(350, 23)
            offer:SetMin(cfg 'minimumOffer')
            offer:SetMax((cfg 'maxOffer' ~= 0 and cfg 'maxOffer' or LocalPlayer():getDarkRPVar 'money'))
            offer:SetValue(cfg 'minimumOffer')
            offer:SetText '   Hit price:'
            offer.Label:SetTextColor(color_white)
            offer.Label:SetFont 'zhits_font_25'
            offer.TextArea:SetPaintBackground(true)
            offer.TextArea:SetFont 'zhits_font_20'
            offer.TextArea:SetWide(75)
            offer:SetDecimals(0)

      local mdlBG = mid:Add 'zhits_panel'
            mdlBG:SetSize(mid:GetWide() * .4, mid:GetTall() - 10)
            mdlBG:SetPos(mid:GetWide() - (mdlBG:GetWide()) - 5, 5)

      local desc = mid:Add 'DTextEntry'
            desc.changed = false
            desc:SetValue(translate 'enterADesc')
            desc.OnChange = function(self)
                  curDesc = self:GetValue()
            end
            desc:SetMultiline(true)
            desc:SetEnterAllowed(false)
            desc.OnGetFocus = function(self)
                  if self:GetValue() == translate 'enterADesc' then
                        self:SetValue ''
                  end
            end
            desc.oldPaint = desc.Paint
            desc.Think = function(self)
                  if not self.changed then
                        if curPl and IsValid(curPl) and addedY > 10 then
                              self:SetSize(mid:GetWide() - mdlBG:GetWide() - 15, 150)
                              self:SetPos(5, addedY + 15 + offer:GetTall() + 75)
                              self:SetVisible(true)

                              self.changed = true
                              self.Paint = self.oldPaint
                        else
                              self.Paint = function() end
                        end
                  end
            end

      local place = mid:Add 'zhits_button'
            place:SetSize(mid:GetWide() - mdlBG:GetWide() - 15, 40)
            place:SetPos(5, mid:GetTall() - place:GetTall() - 5)
            place.text = 'Place hit'
            place.textSize = 30
            place.clickable = false
            place.Think = function(self)
                  if not curPl or not IsValid(curPl) then
                        self.clickable = false
                  else
                        if not self.clickable then
                              self.clickable = true
                        end
                  end
            end
            place.DoClick = function(self)
                  if self.clickable then
                        if curPl and IsValid(curPl) then
                              net.Start 'zhits.newHit'
                                    net.WriteEntity(curPl)
                                    net.WriteInt(tonumber(offer:GetValue()), 32)
                                    net.WriteString(curDesc)
                              net.SendToServer()

                              bg:Remove()
                        end
                  end
            end

      mid.Think = function()
            if offer then
                  local self = offer

                  if curPl and IsValid(curPl) then
                        self:SetVisible(true)
                        self:SetPos(3, addedY + 25 + 10) -- height of hlbl + 10
                  else
                        self:SetVisible(false)
                  end
            end
      end

      local top = Vector(0.025778, -0.303267, 62.222530)

      mdl = mdlBG:Add 'DModelPanel'
            mdl:SetSize(mdlBG:GetWide(), mdlBG:GetTall() + 25)
            mdl:SetPos(0, -50)
            mdl.update = function(self)
                  if not curPl or not IsValid(curPl) then return end
                  self:SetModel(curPl:GetModel())

                  self:SetCamPos(top - Vector(-100, 0, 16))
                  self:SetLookAt(top)

                  local pose = randPose(self.Entity)
                  self:GetEntity():SetSequence(pose)
            end
            mdl.LayoutEntity = function(self, ent)
                  self:RunAnimation()
            end
            mdl:SetFOV(35)
end

net.Receive('zhits.openHitMenu', hitMenu)

local function hitmanMenu()
      zhits.activeHits = net.ReadTable()

      local w, h = ScrW() * .6, ScrH() * .9

      local bg = vgui.Create 'zhits_frame'
            bg:SetSize(w, h)
            bg:Center()
            bg:AddClose()
            bg.title = 'Agency Contracts:'
            bg.titleDesc = 'Targets marked for death are shown below. Kill them for contract payouts!'
            bg.leftTopSize = 0
            bg.topBar = Color(0, 0, 0, 150)
            bg.background = Color(0, 0, 0, 100)
            bg.outline = true
            bg.PaintOver = function(_, w, h)
                  if #zhits.activeHits <= 0 then
                        zhits.text('No active hits', 20, w / 2, h / 2 + (_.topSize / 2), color_white, 1, 1)
                  end
          end
---------------------------------------------------------------------------------------
--PSYCHE---------------------------------------------------------------------------------------
      local cancel = bg:Add 'zhits_button'
            cancel:SetSize(125, (bg:GetTall() / 23) - 7.5)   --(120, (bg:GetTall() / 14) - 7.5)
            cancel:SetPos(bg:GetWide() - 180, 5)            --(bg:GetWide() - 175, 5)
            cancel.text = 'Abort Mission'
            cancel.textSize = 18
            cancel.DoClick = function (pl)
              pl = LocalPlayer()
              pl:ConCommand("say !abortmission")
          end
---------------------------------------------------------------------------------------
--PSYCHE
---------------------------------------------------------------------------------------
      local sc = bg:Add 'DScrollPanel'
            sc:SetSize(bg:GetWide() - 10, bg:GetTall() - bg.topSize - 15)
            sc:SetPos(5, bg.topSize + 10)
            sc:GetVBar():SetWide(0)

      local curY = 0
      local ph = 70

      for _, hit in ipairs(zhits.activeHits) do
            if not hit.target or not IsValid(hit.target) then continue end
            if hit.hitman and IsValid(hit.hitman) then continue end

            local tlbl

            local pnl = sc:Add 'zhits_panel'
                  pnl:SetSize(sc:GetWide(), ph)
                  pnl:SetPos(0, curY)
                  pnl.Think = function(self)
                        if not hit.target or not IsValid(hit.target) then
                              self:Remove()
                        end
                  end
                  pnl.PaintOver = function(_, w, h)
                        if hit.dismissed then
                              zhits.box(0, 0, w, h, Color(0, 0, 0, 150))
                              zhits.text('Dimissed', 20, w / 2, h / 2, color_white, 1, 1)
                        end
                  end

            local mdlP = pnl:Add 'zhits_panel'
                  mdlP:SetSize(ph - 10, ph - 10)
                  mdlP:SetPos(5, 5)

            local mdl = mdlP:Add 'DModelPanel'
                  mdl:SetSize(mdlP:GetWide(), mdlP:GetTall())
                  mdl:SetModel(hit.target:GetModel())

            -- should've used a loop for all these labels but fuck it :(

            tlbl = pnl:Add 'DLabel'
                  tlbl:SetPos(5 + mdlP:GetWide() + 5, 5)
                  tlbl:SetText(translate 'target' .. ': ' .. hit.target:Name())
                  tlbl:SetFont 'zhits_font_18'
                  tlbl:SetTextColor(color_white)
                  tlbl:SetWide(pnl:GetWide() - 200)

            local rlbl = pnl:Add 'DLabel'
                  rlbl:SetPos(5 + mdlP:GetWide() + 5, 5 + 15)
                  rlbl:SetText(translate 'requester' .. ': ' .. (hit.isRandom and 'N/A (anonymous client)' or (hit.requester and IsValid(hit.requester) and hit.requester:Name() or 'Disconnected')))
                  rlbl:SetFont 'zhits_font_18'
                  rlbl:SetTextColor(color_white)
                  rlbl:SetWide(pnl:GetWide() - 200)

            local offer = pnl:Add 'DLabel'
                  offer:SetPos(5 + mdlP:GetWide() + 5, 5 + 15 + 15)
                  offer:SetText(translate 'offer' .. ': ' .. DarkRP.formatMoney(hit.offer))
                  offer:SetFont 'zhits_font_18'
                  offer:SetTextColor(color_white)
                  offer:SetWide(pnl:GetWide() - 200)

            local desc = pnl:Add 'DLabel'
                  desc:SetPos(5 + mdlP:GetWide() + 5, 5 + 15 + 15 + 15)
                  desc:SetText(translate 'description' .. ': ' .. (hit.desc or 'N/A'))
                  desc:SetFont 'zhits_font_18'
                  desc:SetTextColor(color_white)
                  desc:SetWide(pnl:GetWide() - 200)

            local accept = pnl:Add 'zhits_button'
                  accept:SetSize(150, (pnl:GetTall() / 2) - 7.5)
                  accept:SetPos(pnl:GetWide() - 155, 5)
                  accept.text = 'Accept'
                  accept.textSize = 25
                  accept.DoClick = function()
                        net.Start 'zhits.acceptHit'
                              net.WriteInt(_, 32)
                        net.SendToServer()
                  end

            local dismiss = pnl:Add 'zhits_button'
                  dismiss:SetSize(150, (pnl:GetTall() / 2) - 7.5)
                  dismiss:SetPos(pnl:GetWide() - 155, 5 + (accept:GetTall()) + 5)
                  dismiss.text = 'Dismiss'
                  dismiss.textSize = 25
                  dismiss.DoClick = function(self)
                        hit.dismissed = true

                        offer:Remove()
                        tlbl:Remove()
                        rlbl:Remove()
                        desc:Remove()
                        accept:Remove()
                        mdlP:Remove()
                        mdl:Remove()
                        self:Remove()
                  end

            curY = curY + ph + 5
      end
end

net.Receive('zhits.hitmanMenu', hitmanMenu)

local types = {
	['string'] = tostring,
	['number'] = tonumber,
	['bool'] = tobool
}

local function convert(var, tp)
	if types[tp] then
		return types[tp](var)
	end
end

net.Receive('zhits.broadcastAll', function()
      local newCfg = net.ReadTable()

      if newCfg then
            for id, data in pairs(newCfg) do
                  data.value = convert(data.value, data.type)
            end

            zhits.cfg = newCfg
            MsgC(Color(255, 25, 25), '\nZHits: ', color_white, 'CONFIG UPDATED \n')
      end
end)

net.Receive('zhits.broadcastVariable', function()
      local var = net.ReadString()
      local val = net.ReadString()

      if zhits.cfg[var] then
            val = convert(val, zhits.cfg[var].type)
            zhits.cfg[var].value = val

            MsgC(Color(255, 25, 25), '\nZHits: ', color_white, 'CONFIG UPDATED \n')
      end
end)
