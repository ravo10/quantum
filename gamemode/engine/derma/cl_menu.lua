--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

Quantum.Client.Menu = {}
local libs = {
    ["net"] = GM.FolderName .. "/gamemode/engine/derma/lib/cl_network.lua",
    ["page"] = GM.FolderName .. "/gamemode/engine/derma/lib/cl_menu_pages.lua",
    ["theme"] = GM.FolderName .. "/gamemode/engine/derma/lib/cl_menu_theme.lua"
}
Quantum.Client.Menu.GetAPI = function( lib ) return include( libs[lib] ) end

net.Receive( "quantum_menu_net", function( len, pl ) 
    local dt = net.ReadTable() -- TO DO: merge datatable with cached ( if same id/type )

    if( Quantum.Client.EnableDebug ) then -- debug
        Quantum.Debug( "Datatable size: " .. len/8 .. " bytes" )
        Quantum.Debug( "--Datatable contents--")
        PrintTable( dt ) 
        Quantum.Debug( "--End of datatable contens--" )
    end

    local menu = include( GAMEMODE.FolderName .. "/gamemode/engine/derma/menus/menu_" .. dt.id .. ".lua" )
    menu.open( dt )
end)