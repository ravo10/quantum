--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

local menu = {}

local snm = Quantum.Client.Menu.GetAPI( "net" )
local theme = Quantum.Client.Menu.GetAPI( "theme" )
local iteminfo = Quantum.Client.Menu.GetAPI( "iteminfo" )

local resScale = Quantum.Client.ResolutionScale
local sw, sh = ScrW(), ScrH()
local padding = 10 * resScale
local padding_s = 4 * resScale
local errorMdl = "models/player.mdl"

local function createItemAmountLabel( icon, item )
	icon.amountpanel = vgui.Create( "DLabel", icon )
	icon.amountpanel:SetText( tostring( item.amount ) )
	icon.amountpanel:SetTextColor( Color( 205, 205, 205, 255 ) )
	icon.amountpanel:SetFont( "q_item_amount" )
	icon.amountpanel:SizeToContents()
	icon.amountpanel.w, icon.amountpanel.h = icon.amountpanel:GetSize()
	icon.amountpanel:SetPos( ( icon.w - icon.amountpanel.w ) - padding_s, icon.h - icon.amountpanel.h )
	return icon.amountpanel
end

function menu.open( dt )
	local items = Quantum.Client.Inventory 

	if( Quantum.Client.Character == nil ) then 
		chat.AddText( Color( 255, 25, 25 ), "[Quantum] - [ERROR] Check console for details.\n" )
		Quantum.Error( "\nCharacter could not be found. Can not open inventory!\nGive this message to someone important: Quantum.Client.Character=nil\nTry rejoining the server and this should be fixed." ) 
		return 
	end

	if( !f ) then
		Quantum.Client.IsInMenu = true

		local f = vgui.Create( "DFrame" )
		f:SetSize( sw, sh )
		f.w, f.h = f:GetSize()
		f:SetTitle( "" )
		f:SetDraggable( false )
		f:ShowCloseButton( false )
		f:MakePopup()
		f.Paint = function( self, w, h ) 
			surface.SetDrawColor( 0, 0, 0, 40 )
			surface.DrawRect( 0, 0, w, h )
			theme.renderblur( self, 10, 10 )
		end
		function f:OnClose()
			Quantum.Client.IsInMenu = false -- show the hud when closed
			Quantum.Client.Cam.Stop()
		end

		local keycodesClose = {
			[KEY_ESCAPE] = true,
			[KEY_F2] = true,
			[KEY_TAB] = true
		}

		function f:OnKeyCodeReleased( keyCode )
			if( keycodesClose[keyCode] ) then
				self:Close()	
			end
		end

		Quantum.Client.CurMenu = f

		-- Default is the inventory page --

		local bar = vgui.Create( "DPanel", f )
		bar:SetSize( f.w, padding*5 )
		bar.w, bar.h = bar:GetSize()
		bar:SetPos( 0, 0 )
		bar.Paint = function( self ) theme.blurpanel( self ) end
		bar.DoClick = function( self ) f:Close() end

		-- Inventory button --
		title = vgui.Create( "DLabel", bar )
		title:SetText( "Inventory" )
		title:SetFont( "q_header_s" )
		title:SetTextColor( Color( 255, 255, 255, 255 ) )
		title.Paint = function( self )
			theme.pagetext( self )
		end

		title:SizeToContents()
		title.w, title.h = title:GetSize()
		title:SetPos( bar.w/2 - title.w/2, bar.h/2 - title.h/2 )

		---- Character view ----
		local char = vgui.Create( "DModelPanel", f )
		char:SetSize( 550 * resScale, f.h - bar.h )
		char.w, char.h = char:GetSize()
		char:SetPos( 0, bar.h )
		char.x, char.y = char:GetPos()
		char:SetFOV( 25 )
		char:SetModel( Quantum.Client.Character.model || errorMdl )
		char:SetDirectionalLight( BOX_FRONT, Color( 116, 205, 255 ) )

		local ent = char.Entity
		local eyepos = ent:GetBonePosition( ent:LookupBone( "ValveBiped.Bip01_Head1" ) )
		eyepos:Add( Vector( 40, 0, -15 ) )
		char:SetCamPos( eyepos + Vector( 40, -5, 2 ) )
		char:SetLookAt( eyepos )
		ent:SetEyeTarget( eyepos + Vector( 40, -5, 2 ) )
		function char:LayoutEntity( Entity ) return end

		---- Inventory panel ----

		local inv = vgui.Create( "DPanel", f ) -- section for all of the item panels
		inv:SetSize( f.w - char.w, f.h - bar.h )
		inv.w, inv.h = inv:GetSize()
		inv:SetPos( char.w, bar.h )
		inv.Paint = function( self, w, h ) 
			surface.SetDrawColor( 0, 0, 0, 0 )
			surface.DrawRect( 0, 0, w, h )
		end

		local itemWidth, itemHeight = 65 * resScale, 65 * resScale
		local maxW, maxH = Quantum.Inventory.Width, Quantum.Inventory.Height

		local itempanels = {}
				
		local count = 0
		local xbasepos, ybasepos = 0, 0
		local xintervall, yintervall = itemWidth + padding/2, itemHeight + padding/2
		local xpos, ypos = 0, 0
		local rows = 0

		local itemframe = vgui.Create( "DPanel", inv ) -- container for all of the item panels
		itemframe:SetSize( inv:GetSize() )
		itemframe:SetPos( 0, 0 )
		itemframe.Paint = function( self, w, h ) end

		for ii=1, maxW * maxH, 1 do -- create all of the item panels
			if( ii != 1 ) then count = count + 1 end

			itempanels[ii] = vgui.Create( "DPanel", itemframe )

			itempanels[ii].index = ii -- set the vars
			if( items[ii] ) then 
				itempanels[ii].item = Quantum.Item.Get( items[ii][1] ) -- get the items info through its id 
				itempanels[ii].item.amount = items[ii][2] || 1 -- get the amount
			end 

			itempanels[ii]:SetSize( itemWidth, itemHeight )
			if( count >= maxW ) then
				ypos = ypos + yintervall
				xpos = xbasepos
				count = 0
				rows = rows + 1
			else
				if( count != 0 ) then
					xpos = xpos + xintervall
				else
					xpos = 0
				end
			end
			itempanels[ii]:SetPos( xpos, ypos )
			itempanels[ii].x, itempanels[ii].y = itempanels[ii]:GetPos()

			if( itempanels[ii].item == nil ) then -- get the items rarity color
				itempanels[ii].itemcolor = Quantum.Rarity.None.color 
			else 
				itempanels[ii].itemcolor = itempanels[ii].item.rarity.color
			end

			itempanels[ii].Paint = function( self ) 
				theme.itempanel( self, self.itemcolor )
			end

			itempanels[ii].RemoveItem = function()
				itempanels[ii].itemcolor = nil
				if( itempanels[ii].icon:IsValid() ) then itempanels[ii].icon:SetVisible( false ) end
			end

			itempanels[ii].SetItemAmount = function( amount )
				if( amount < 1 ) then itempanels[ii].RemoveItem() return end
				itempanels[ii].item.amount = amount

				if( itempanels[ii].icon != nil ) then
					if( IsValid( itempanels[ii].icon.amountpanel ) ) then
						itempanels[ii].icon.amountpanel:Remove()
					end
					if( itempanels[ii].item.amount > 1 ) then
						itempanels[ii].icon.amountpanel = createItemAmountLabel( itempanels[ii].icon, itempanels[ii].item )
					end

					---- Create new options panel for it ----
					if( IsValid( itempanels[ii].icon.options ) ) then
						itempanels[ii].icon.options:Remove()
						itempanels[ii].icon.options = iteminfo.giveoptions( itempanels[ii].icon, f, itempanels[ii].item.amount )
					end
				end
			end

			---- Create the model icon for the item panel ----
			if( itempanels[ii].item != nil && itempanels[ii].item.model != nil ) then
				itempanels[ii].icon = vgui.Create( "DModelPanel", itempanels[ii] )
				itempanels[ii].icon:SetSize( itempanels[ii]:GetSize() )
				itempanels[ii].icon.w, itempanels[ii].icon.h = itempanels[ii].icon:GetSize()
				itempanels[ii].icon:SetPos( 0, 0 )
				itempanels[ii].icon:SetModel( itempanels[ii].item.model )
				itempanels[ii].icon:SetFOV( 45 )

				-- get the dimensions of the models entity
				local mn, mx = itempanels[ii].icon.Entity:GetRenderBounds()
				local size = 0

				-- calculate the vector axises so that the view doesn't go outside of the models renderbounds --
				size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
				size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
				size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

				-- Apply the new "data" --
				itempanels[ii].icon:SetCamPos( Vector( size/2, size, size ) )
				itempanels[ii].icon:SetLookAt( ( mn + mx )/2 )

				---- Amount Text ----
				if( itempanels[ii].item.amount > 1 ) then
					itempanels[ii].icon.amountpanel = createItemAmountLabel( itempanels[ii].icon, itempanels[ii].item )
				end

				---- Tooltip ----
				itempanels[ii].icon.tooltip = iteminfo.givetooltip( itempanels[ii].icon, f ) -- give the item a tooltip
				itempanels[ii].icon.tooltip:CreateInfo() -- create the labels for the tooltip & such
				----

				---- Click Options ---- 
				itempanels[ii].icon.options = iteminfo.giveoptions( itempanels[ii].icon, f, itempanels[ii].item.amount )

				itempanels[ii].icon.DoClick = function( self )
					surface.PlaySound( "UI/buttonclick.wav" )
					self.options.Open()	
				end

			end

			
		end
		
		-- get the width and height of all of the items
		local iwidth, iheight = (itempanels[maxW].x - xbasepos) + itemWidth, (itempanels[#itempanels].y - ybasepos) + itemHeight 
		itemframe:SetSize( iwidth, iheight ) -- set the frames dimensions to all of the items dimensions combined.
		itemframe.w, itemframe.h = itemframe:GetSize()
		itemframe:SetPos( inv.w/2 - itemframe.w/2, inv.h/2 - itemframe.h/2 + padding*8 ) -- center the item panels
		itemframe.x, itemframe.y = itemframe:GetPos()

		----CHAR INFO----

		--Money text
		local money = vgui.Create( "DLabel", inv )
		money:SetText( Quantum.Format.Money( Quantum.Client.Character.money ) )
		money:SetFont( "q_money" )
		money:SetTextColor( Color( 90, 218, 132, 255 ) )
		money:SizeToContents()
		money.w, money.h = money:GetSize()
		money:SetPos( itemframe.x, itemframe.y - money.h - padding )
		money.x, money.y = money:GetPos()
		money.Paint = function( self, w, h ) 
			draw.RoundedBox( 5, 0, 0, w, h, Color( 0, 0, 0, 90 ) )
		end

		--Name text
		local name = vgui.Create( "DLabel", inv )
		name:SetText( Quantum.Client.Character.name || "ERROR: NAME=nil" )
		name:SetFont( "q_name" )
		name:SizeToContents()
		name.w, name.h = name:GetSize()
		name:SetPos( itemframe.x, money.y - name.h - padding )
		name.Paint = function( self, w, h ) 
			draw.RoundedBox( 5, 0, 0, w, h, Color( 0, 0, 0, 90 ) )
			theme.pagetext( self ) 
		end

	end
end

hook.Add("ScoreboardShow", "Quantum_Menu_CharInfo_Open", function() 
	-- if( InventoryStartTime == nil ) then
	-- 	InventoryStartTime = CurTime()
	-- end

	-- if( InventoryStartTime + 1 <= CurTime() ) then 
	-- 	menu.open() 
	-- 	InventoryStartTime = nil
	-- end -- open the menu

	-- menu.open() 
	
	return false
end)

local startTime

hook.Add( "Think", "Quantum_Menu_CharInfo_Think", function()
	if( !Quantum.Client.IsInMenu ) then
		if( input.IsButtonDown( Quantum.Bind.OpenInventory ) ) then
			startTime = startTime || CurTime()

			if( CurTime() - startTime >= Quantum.InventoryOpenDelay ) then
				startTime = nil
				menu.open()
			end
		else
			startTime = nil
		end
	end
end)


return menu