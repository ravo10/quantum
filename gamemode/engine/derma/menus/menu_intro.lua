--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

local intro = {}

local scenes = {
    ["rp_truenorth_v1a_livin"] = {
        [1] = { 
            fov = 80,
            velocity = 10,
            pos1 = Vector(6879, 4135, 72),
            pos2 = Vector(8760, 2740, 86),
            ang1 = Angle(7, 122, 0),
            ang2 = Angle(1, -104, 0) 
        },
        [2] = {
            fov = 60,
            velocity = 8,
            pos1 = Vector( 8917, 2194, 83 ),
            pos2 = Vector( 8312, 2265, 83 ),
            ang1 = Angle( 2, -123, 0 ),
            ang2 = Angle( 3, -41, 0 )
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
        f:SetTitle( "Cinematic Intro Test" )
        f.Paint = function( self ) end
        f:SetDraggable( false )
        f:MakePopup()
        function f:OnClose() 
            Quantum.Client.IsInMenu = false 
            Quantum.Client.Cam.Stop() -- stop the cinematic
        end

        Quantum.Client.Cam.Start( scenes[game.GetMap()], false ) -- start the cinematic
    end
end

return intro