--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

local intro = {}

local log = Quantum.Client.Menu.GetAPI( "dialogue" )
local theme = Quantum.Client.Menu.GetAPI( "theme" )

local scenes = { -- 5031.821777 3866.334961 120.090790;setang 0.898059 56.421352 0.000000
    ["rp_truenorth_v1a_livin"] = {
        [1] = {
            fov = 70,
            velocity = 12,
            pos1 = Vector(5062.544434, 3264.783447, 136.604355),
            pos2 = Vector(5031.821777, 3866.334961, 120.090790),
            ang1 = Angle(0.370070, 90.952415, 0.000000),
            ang2 = Angle(0.898059, 56.421352, 0.000000) 
        },
        [2] = { 
            fov = 80,
            velocity = 16,
            pos1 = Vector(6879, 4135, 72),
            pos2 = Vector(8760, 2740, 86),
            ang1 = Angle(0.686861, -43.159401, 0.000000),
            ang2 = Angle(1, -104, 0) 
        },
        [3] = {
            fov = 70,
            velocity = 12,
            pos1 = Vector( 8917, 2194, 83 ),
            pos2 = Vector( 8312, 2265, 83 ),
            ang1 = Angle( 2, -123, 0 ),
            ang2 = Angle( 3, -41, 0 )
        }, 
        [4] = {
            fov = 70,
            velocity = 12,
            pos1 = Vector( 10860.154297, 3337.662109, 141.101013 ),
            pos2 = Vector( 10881.356445, 5483.074219, 132.792114 ),
            ang1 = Angle( 0.052806, 85.319626, 0.000000 ),
            ang2 = Angle( -0.105593, 90.978638, 0.000000 )
        }
    }
}

function intro.open( dt )
    local chars = dt.cont
    local resScale = Quantum.Client.ResolutionScale
    local sw, sh = ScrW(), ScrH()
    local padding = 10 * resScale
    local padding_s = 4 * resScale

    if( !f ) then

        Quantum.Client.IsInMenu = true -- hide the hud

        local f = vgui.Create( "DFrame" )
        f:SetSize( sw, sh )
        f:SetTitle( "" )
        f:ShowCloseButton( false )
        f.Paint = function( self, w, h ) 
            surface.SetDrawColor( Color( 20, 20, 20, 255 ) )
            local height = 90 * resScale
            surface.DrawRect( 0, 0, w, 90 * resScale )
            surface.DrawRect( 0, h - height, w, height )
        end
        f:SetDraggable( false )
        f:MakePopup()
        function f:OnClose() 
            Quantum.Client.IsInMenu = false 
            Quantum.Client.Cam.Stop() -- stop the cinematic
        end
        f.w, f.h = f:GetSize()

        --- MUSIC --- 
        surface.PlaySound( "music/HL1_song10.mp3" ) -- get some better music

        local skip = vgui.Create( "DButton", f )
        skip:SetText( "Skip Intro" )
        skip:SetFont( "q_button_m" )
        skip:SetTextColor( Color( 255, 255, 255, 255 ) )
        skip:SizeToContents()
        skip.Paint = function( self ) theme.skipbutton( self, Color( 0, 0, 0, 0 ) ) end
        skip.w, skip.h = skip:GetSize()
        skip:SetPos( f.w - skip.w - padding, f.h - skip.h - padding )
        skip.DoClick = function( self ) 
            f:Close()
        end
        skip.OnCursorEntered = function() surface.PlaySound( "UI/buttonrollover.wav" ) end

        Quantum.Client.Cam.Start( scenes[game.GetMap()], false ) -- start the cinematic

        local logdata = {
            [1] = {
                title = "Welcome!",
                text = "Welcome to the server! This server is running the Quantum framework which was developed by AlmTech.\n\nDuring this awesome cinematic you will be shown what you can do on the server. Starting with the basics."
            },
            [2] = {
                title = "Classes & Professions",
                text = "Professions are the core gameplay where they can unlock certian abilities to craft, cook and gather certain resources. You can learn a profession at any teacher NPC.\n\nYou can have the maximum of 2 professions and if you are skilled enough then some players might hire you."
            },
            [3] = {
                title = "Classes & Professions",
                text = "Professions are important where they could lead you to many opportunities.\nThe items produced by certain professions could be sold or traded to NPCs and other players. But keep in mind that everyone might not be as trustworthy as you would have thought."
            },
            [4] = {
                title = "Classes & Professions",
                text = "Character classes are also one of many key element to the core gameplay. Some character classes are better at certain things but worse at other things, but your class does not define your journey and you have the freedom to choose whatever you want to do."
            }
        }

        local box = log.createinfobox( logdata, f )
    end
end

return intro