--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

local enabledHUDs = {
	["CHudChat"] = true,
	["CHudGMod"] = true,
	["CHudWeaponSelection"] = false
}

hook.Add( "HUDShouldDraw", "Quantum_RemoveDefualtHUD", function( hudid ) 
	return enabledHUDs[hudid] == true
end)

local scale = Quantum.Client.ResolutionScale
local barW, barH = 400 * scale, 25 * scale
local radius = 1.05 * scale
local padding = 5 * scale
local padding_s = padding/2
local sw, sh = ScrW(), ScrH()

local function SetAlpha( color, alpha )
	return Color( color.r, color.g, color.b, alpha )
end

local function renderStatHUD()
	local hp = LocalPlayer():Health()
	local lasthp = hp
	local maxhp = LocalPlayer():GetMaxHealth()

	local armor = LocalPlayer():Armor()
	local maxarmor = 200

	-- Health border
	surface.SetDrawColor( 20, 20, 20, 200 )
	surface.DrawRect( sw/2 - barW/2, sh*0.9, barW, barH )

	-- Armor bar
	surface.SetDrawColor( 52, 180, 255, 200, 200 ) 

	local armorWidth = math.Clamp( (barW - padding_s) * armor/maxarmor, 0, barW - padding_s )
	surface.DrawRect( ( sw/2 - armorWidth/2 ), (sh*0.9) + padding_s/2, armorWidth, barH - padding_s )

	-- Health bar
	surface.SetDrawColor( 168, 62, 50, 255 ) 

	local healthWidth = math.Clamp( (barW - padding) * hp/maxhp, 0, barW - padding )
	surface.DrawRect( ( sw/2 - healthWidth/2 ), (sh*0.9) + padding/2, healthWidth, barH - padding )

	-- Health Text
	surface.SetFont( "q_HUD" )
	surface.SetTextColor( 255, 255, 255, 255 )
	local hptxt = tostring( hp )
	local txtW, txtH = surface.GetTextSize( hptxt )
	surface.SetTextPos( ( ( sw/2 - txtW/2 ) + padding/2 ), ( ( sh*0.9 - txtH/3 ) ) )
	surface.DrawText( hptxt )
end

local function renderItemInfoHUD()
	local trace = LocalPlayer():GetEyeTraceNoCursor() 
	local entsNear = ents.FindInSphere( LocalPlayer():GetPos(), Quantum.ItemInfoDisplayMaxDistance )
	local txtPadding = 24 * scale

	for i, ent in pairs( entsNear ) do
		if( ent:GetClass() == "q_item" ) then
			local distance = LocalPlayer():GetPos():Distance( ent:GetPos() )
			local distFrac = Lerp( distance/Quantum.ItemInfoDisplayMaxDistance, 1, 0 )
	
			if( distance <= Quantum.ItemInfoDisplayMaxDistance ) then
				local item = Quantum.Item.Get( ent:GetNWString( "q_item_id" ) ) || { name = "", rarity = { txt = "", color = Color( 0, 0, 0, 0 ) } }
				local amount = ent:GetNWInt( "q_item_amount" ) || 1
	
				local pos = ent:GetPos()
				pos.z = pos.z + 20
	
				local screenPos = pos:ToScreen()
	
				local itemAmountTxt = ""
				if( amount > 1 ) then itemAmountTxt = amount .. "x " end
	
				local alphaFrac = distFrac
	
	
				draw.SimpleText( itemAmountTxt .. item.name, "q_item_hud_title", screenPos.x, screenPos.y, SetAlpha( item.rarity.color, 255 * alphaFrac ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( item.rarity.txt, "q_item_hud_rarity", screenPos.x, screenPos.y + txtPadding, SetAlpha( item.rarity.color, 255 *alphaFrac ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				if( item.soulbound ) then
					draw.SimpleText( "Soulbound", "q_item_hud_soulbound", screenPos.x, screenPos.y + txtPadding*2, Color( 235, 64, 52, 255 * alphaFrac ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
		end
	end
end


local pStart
local pFrac

local pW, pH = 250 * scale, 15 * scale
local pBasePosX, pBasePosY = sw/2 - pW/2, (sh / 2)*1.25

local function createCraftPanel()

	local craft = vgui.Create( "DLabel" )
	craft:SetText( "Crafting..." )
	craft:SetFont( "q_craft_hud_text" )
	craft:SetTextColor( Color( 255, 255, 255, 200 ) )
	craft:SizeToContents()
	craft.w, craft.h = craft:GetSize()
	craft:SetPos( sw/2 - craft.w/2, sh*0.65 - craft.h/2 )

	craft.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 180 ) )
		surface.DrawRect( 0, 0, w, h )

		surface.SetDrawColor( Color( 255, 255, 255, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end

	craft.frac = 0
	craft.fadein = true
	craft.startTime = CurTime()
	local intervall = 1.25
	local midIntervall = 0.2

	craft.Think = function( self )
		if( craft.fadein ) then
			if( self.startTime == nil ) then self.startTime = CurTime() end
			self.frac = Lerp( (CurTime() - self.startTime ) / intervall, 0, 1 )
			self:SetAlpha( math.Clamp( 255 * self.frac, 5, 255 ) )
			if( self.frac >= 1 ) then 
				self.fadein = false 
				self.startTime = nil
				self.frac = 1
			end
		else
			if( self.startTime == nil ) then self.startTime = CurTime() end
			self.frac = Lerp( (CurTime() - self.startTime ) / intervall, 1, 0 )
			self:SetAlpha( math.Clamp( 255 * self.frac, 5, 255 ) )
			if( self.frac <= 0 ) then 
				self.fadein = true
				self.startTime = nil
				self.frac = 1
			end
		end
	end

	return craft
end

local craftPanel

local function renderActionDelayHUD()
	if( LocalPlayer():GetNWBool( "Quantum_Craft_IsCrafting" ) ) then
		if( !IsValid( craftPanel ) ) then
			craftPanel = createCraftPanel()
		end
	else
		if( IsValid( craftPanel ) ) then craftPanel:Remove() end
	end
end

local function renderCharNamesHUD3D2D()
	local entsNear = ents.FindInSphere( LocalPlayer():GetPos(), Quantum.CharInfoDisplayDistance )
	local txtPadding = 38 * scale

	for i, ent in pairs( entsNear ) do
		if( ent:IsPlayer() && ent != LocalPlayer() ) then
			local distance = LocalPlayer():GetPos():Distance( ent:GetPos() )
			local distFrac = Lerp( distance/Quantum.CharInfoDisplayDistance, 1, 0 )
			
			if( distance <= Quantum.CharInfoDisplayDistance && ent:Alive() ) then
				local name = ent:GetNWString( "q_char_name" )
				local pos = ent:GetPos()
				pos.z = pos.z + 75

				local ang = ent:GetAngles()
				ang:RotateAroundAxis( ang:Forward(), 90 )

				ang.y = LocalPlayer():EyeAngles().y - 90

				local isServerMasterOnDuty = ent:GetNWBool( "q_servermaster_onduty" )
				if( isServerMasterOnDuty ) then pos.z = pos.z + 4 end

				surface.SetFont( "q_char_hud_name" )
				local txtW, txtH = surface.GetTextSize( name )
				local W, H = txtW + padding*5, txtH - padding/2
				
				cam.Start3D2D( pos, ang, 0.125 )

					--surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
					--surface.DrawRect( -txtW/2, -txtH/2, txtW, txtH )
					-- draw.RoundedBox( padding*2.5, -W/2, -H/2, W, H, Color( 0, 0, 0, 200 * distFrac )  )

					draw.SimpleText( name, "q_char_hud_name", 0, 0, Color( 245, 245, 245, 255 * distFrac ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
					if( isServerMasterOnDuty ) then
						draw.SimpleText( "<Server Master>", "q_char_hud_name", 0, txtPadding, Color( 100, 150, 245, 255 * distFrac ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
				cam.End3D2D()
			end
		end
	end
end

hook.Add( "PostDrawOpaqueRenderables", "Quantum_HUD_PlayerNames", function() 
	renderCharNamesHUD3D2D()
end)

local function createTalkingPanel()
	local mat = "materials/quantum/mic_icon48.png"

	local icon = vgui.Create( "Material" )
	icon:SetSize( 48 * scale, 48 * scale )
	icon.w, icon.h = icon:GetSize()
	icon:SetPos( ( sw - icon.w ) - padding*25, sh*0.65 - icon.h/2 )
	icon:SetMaterial( mat )

	icon.frac = 0
	icon.fadein = true
	icon.startTime = CurTime()
	local intervall = 1.25
	local midIntervall = 0.2

	icon.Think = function( self )
		if( icon.fadein ) then
			if( self.startTime == nil ) then self.startTime = CurTime() end
			self.frac = Lerp( (CurTime() - self.startTime ) / intervall, 0, 1 )
			self:SetAlpha( math.Clamp( 255 * self.frac, 5, 255 ) )
			if( self.frac >= 1 ) then 
				self.fadein = false 
				self.startTime = nil
				self.frac = 1
			end
		else
			if( self.startTime == nil ) then self.startTime = CurTime() end
			self.frac = Lerp( (CurTime() - self.startTime ) / intervall, 1, 0 )
			self:SetAlpha( math.Clamp( 255 * self.frac, 5, 255 ) )
			if( self.frac <= 0 ) then 
				self.fadein = true
				self.startTime = nil
				self.frac = 1
			end
		end
	end

	return icon
end

function GM:PlayerStartVoice( cl ) -- replace the ugly voice panel
	if( cl == LocalPlayer() ) then
		cl.talkicon = createTalkingPanel()
	end
	return 
end 

function GM:PlayerEndVoice( cl )
	if( cl == LocalPlayer() ) then
		if( IsValid( cl.talkicon ) ) then
			cl.talkicon:Remove()
		end
	end
end

local showRarities = {
	[Quantum.Rarity.Rare] = true,
	[Quantum.Rarity.Epic] = true,
	[Quantum.Rarity.Legendary] = true
}

local function renderHaloAroundItems()
	for i, item in pairs( ents.FindByClass( "q_item" ) ) do
		local itemid = item:GetNWString( "q_item_id" )
		local itemTbl = Quantum.Item.Get(itemid) || { rarity = Quantum.Rarity.Rare }

		if( itemTbl != nil ) then
			if( showRarities[itemTbl.rarity] ) then
				halo.Add( { item }, SetAlpha( itemTbl.rarity.color, 255 ), 0, 0, 2, true, false )
			end
		end
	end
end

hook.Add( "PreDrawHalos", "Quantum_Item_Halos", function() 
	renderHaloAroundItems()
end)

function GM:HUDPaint()
	if( LocalPlayer():IsValid() ) then
		if( !Quantum.Client.IsInMenu ) then
			if( !LocalPlayer():Alive() ) then 
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawRect( 0, 0, sw, sh )
			end
			
			if( Quantum.Client.Config.EnableHUD ) then
				if( LocalPlayer():Alive() ) then
					-- renderStatHUD()
					renderItemInfoHUD()
					renderActionDelayHUD()
				end
			end
		end
	end
end

function GM:Think()
	if( Quantum.Client.IsInMenu ) then
		if( gui.IsGameUIVisible() ) then gui.HideGameUI() end -- hides the main menu for the player

		if( !LocalPlayer():Alive() ) then
			if( IsValid( Quantum.Client.CurMenu ) ) then 
				Quantum.Client.CurMenu:Close() -- closes the current open menu on death
			end
		end
	end
end

hook.Add( "RenderScreenspaceEffects", "Quantum_HUD_RenderLowHealth", function() 
	if( !Quantum.Client.IsInMenu || Quantum.Client.IsInInventory ) then
		DrawMotionBlur( Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0.4, 0 ), Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0.8, 0 ), Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0.1, 0 ) ) 
		DrawColorModify( {
			[ "$pp_colour_addr" ] = 0,
			[ "$pp_colour_addg" ] = 0,
			[ "$pp_colour_addb" ] = 0,
			[ "$pp_colour_brightness" ] = Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), -0.25, 0 ),
			[ "$pp_colour_contrast" ] = Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0.2, 1 ),
			[ "$pp_colour_colour" ] = Lerp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0.8, 1 ),
			[ "$pp_colour_mulr" ] = 0,
			[ "$pp_colour_mulg" ] = 0,
			[ "$pp_colour_mulb" ] = 0
		} )
	end
end)
