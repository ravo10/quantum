--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

local page = {}
local scale = Quantum.Client.ResolutionScale
local padding = 10 * scale
local padding_s = 4 * scale

function page.New( parent, args )

    -- check the vars
    args.w, args.h = parent:GetSize()
    args.x, args.y = 0, 0
    
    args.closeW = args.closeW || 90 * scale
    args.closeH = args.closeH || 20 * scale
    args.closeX = args.closeX || padding
    args.closeY = args.closeY || padding
    --

    local p = vgui.Create( "DPanel", parent )
    p.w, p.h = args.w, args.h
    p.x, p.y = args.x, args.y

    p:SetSize( p.w, p.h )
    p:SetPos( p.x, p.y )
    p.Paint = args.Paint || function( self, w, h )
        -- Draw nothing, unless this function is overwritten
    end
    p.OnClose = args.OnClose || function() end

    local close = vgui.Create( "DButton", p )
    close:SetText( args.CloseButtonText || "Close" )
    close:SetTextColor( args.CloseButtonTextColor || Color( 0, 0, 0, 255 ) )
    close:SetFont( args.CloseButtonFont || "q_text" )
    --close:SetSize( args.closeW, args.closeH )
    close:SizeToContents()
    local closeW, closeH = close:GetSize()
    close:SetSize( closeW + padding*2, closeH )
    close:SetPos( args.closeX, args.closeY )
    close.DoClick = function() p:Remove() end
    close.Paint = args.CloseButtonPaint || function( self, w, h )
        surface.SetDrawColor( 50, 50, 50, 255 )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( 235, 64, 52, 255 )
        surface.DrawRect( padding_s/2, padding_s/2, w - padding_s/2, h - padding_s/2 )
    end
    return p, close
end

return page