--    __           _        _______        _      __   
--   / /     /\   | |      |__   __|      | |     \ \  
--  / /     /  \  | |_ __ ___ | | ___  ___| |__    \ \ 
-- < <     / /\ \ | | '_ ` _ \| |/ _ \/ __| '_ \    > >
--  \ \   / ____ \| | | | | | | |  __/ (__| | | |  / / 
--   \_\ /_/    \_\_|_| |_| |_|_|\___|\___|_| |_| /_/  

GM.Name = "Quantum Framework"
GM.Author = "AlmTech"
GM.Email = "elias@almtech.se"
GM.Website = "N/A"

Quantum = {}
Quantum.Version = "v0.5-beta"

include( "engine/sh_debug.lua" ) -- add the debug functions and stuff

include( "settings/sh_settings.lua" )

include( "engine/vars/sh_vars.lua" ) -- include the shared constant vars