--[[
Server Name: ▌ Icefuse.net ▌ DarkRP 100k Start ▌ Bitminers-Slots-Unbox ▌
Server IP:   208.103.169.42:27015
File Path:   addons/[server]_hitman_system/lua/zhitman/cl_derma.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

local rgb = Color

-- EDIT THIS TABLE TO EDIT THE THEME

zhits.cfg.theme = {
	hasBlur 			= true,
	doOutline 			= false,
	sideThingSize		= 5,
	colors 			= {
		topBar 		= rgb(0, 0, 0, 220),
		leftTop 		= rgb(100, 100, 100, 120),
		sidePanel 		= rgb(0, 0, 0, 220),
		dataPanelsBG	= rgb(0, 0, 0, 120),
		dataPanels 		= rgb(150, 155, 160, 15),
		background 		= rgb(0, 0, 0, 0),
		foreground 		= rgb(15, 15, 15, 0),
		closeButton 	= rgb(0, 0, 0, 0),
		buttons 		= rgb(100, 115, 220, 100),
		buttonHover 	= rgb(255, 150, 10, 200), -- also the side of some panels
		textColor 		= rgb(255, 255, 255, 220),
		buttonTextColor 	= rgb(255, 255, 255, 255),
		titleTextColor 	= rgb(255, 255, 255, 100),
		miniPanelsBG	= rgb(0, 0, 0, 200) -- bg of the panels the display submit information n shit
	}
}

-- DONT TOUCH ANYTHING PAST HERE

local color_blue 		= Color(40, 40, 255, 255)
local color_black 	= Color(0, 0, 0, 255)
local surface		= surface
local cfg 			= zhits.cfg

local curPl 		= nil
local IsValid 		= IsValid

local draw_SimpleText	= draw.SimpleText
local blur 		= Material 'pp/blurscreen'

function zhits.blurPanel(pnl)
	local x, y = pnl:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 6 do
		blur:SetFloat('$blur', (i / 3) * 6)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
	end
end

local function createFont(size, weight)
	surface.CreateFont('zhits_font_' .. size, {
		font = 'Arial',
		size = size,
		weight = (weight or 500)
	})
end

createFont(19, 750)
createFont(20, 750)
createFont(22, 750)
createFont(25, 750)
createFont(45, 1000)
createFont(24, 300)
createFont(130)
createFont(18, 750)
createFont(15, 700)
createFont(30, 1000)

function zhits.box(x, y, w, h, clr)
	surface.SetDrawColor((clr or clrs.background))
	surface.DrawRect(x, y, w, h)
end

function zhits.text(txt, size, x, y, clr, alignX, alignY)
	draw_SimpleText(txt, 'zhits_font_' .. size, x, y, (clr or clrs.textColor), alignX, alignY)
end

local theme = zhits.cfg.theme
local clrs = theme.colors

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle ''
	self:SetDraggable(false)

	self.title = ''
	self.titleDesc = ''
	self.sideTitle = ''
	self.topSize = 50
	self.leftTopSize = 150
end

function PANEL:AddClose()
	local w = self:GetWide()

	self.close = self:Add 'DButton'
		self.close:SetSize(50, 50)
		self.close:SetPos(w - 55, 5)
		self.close:SetText ''

	function self.close:DoClick()
		self:GetParent():SizeTo(0, 0, .3, nil, nil, function()
			self:GetParent():Remove()
		end)
	end

	function self.close:Paint(w, h)
		zhits.text('X', 30, w / 2, h / 2, color_white, 1, 1)
	end
end

function PANEL:PerformLayout()
	if not self.noPopup then
		self:MakePopup()
	end
end

function PANEL:Paint(w, h)
	if theme.hasBlur then
		zhits.blurPanel(self)
	end

	zhits.box(0, 0, w, h, (self.background or clrs.background))
	zhits.box(5, 5, self.leftTopSize, self.topSize, clrs.leftTop)
	zhits.box((self.leftTopSize ~= 0 and 5 or 0) + self.leftTopSize + 5, 5, (self.leftTopSize == 0 and (w - 10) or (w - self.leftTopSize - 15)), self.topSize, (self.topBar or clrs.topBar))

	zhits.text(self.sideTitle, 30, 5 + self.leftTopSize / 2, 5 + (self.topSize / 2), clrs.titleTextColor, 1, 1)
	zhits.text(self.title, 30, 5 + self.leftTopSize + 10, 5 + (self.topSize / 2) - 10, clrs.titleTextColor, 0, 1)
	zhits.text(self.titleDesc, 24, 5 + self.leftTopSize + 10, 5 + (self.topSize / 2) + 10, clrs.titleTextColor, 0, 1)

	if self.outline then
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

vgui.Register('zhits_frame', PANEL, 'DFrame')

PANEL = {}

function PANEL:Init()
	self.panelColor = clrs.dataPanelsBG
	self.outline = true
end

function PANEL:Paint(w, h)
	zhits.box(0, 0, w, h, self.panelColor)

	if theme.doOutline and self.outline then
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

vgui.Register('zhits_panel', PANEL, 'DPanel')

PANEL = {}

function PANEL:Init()
	self:SetText ''

	self.text = ''
	self.btnColor = clrs.buttons
	self.lerpHover = 0
	self.isSelected = false
	self.textSize = 20
	self.clickable = true
end

function PANEL:Paint(w, h)
	zhits.box(0, 0, w, h, self.btnColor)

	if theme.doOutline then
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	if (self:IsHovered() or self.isSelected) and self.clickable then
		self.lerpHover = Lerp(.075, self.lerpHover, w - 1)
	else
		self.lerpHover = Lerp(.075, self.lerpHover, theme.sideThingSize)
	end

	zhits.box(1, 1, self.lerpHover, h - 2, clrs.buttonHover)
	zhits.text(self.text, self.textSize, w / 2, h / 2, clrs.buttonTextColor, 1, 1)
end

vgui.Register('zhits_button', PANEL, 'DButton')