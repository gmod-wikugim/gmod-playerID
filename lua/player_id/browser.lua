local function includeCl(path) AddCSLuaFile(path) if CLIENT then include(path) end end
local function includeSv(path) if SERVER then include(path) end end
local function includeSh(path) AddCSLuaFile(path) include(path) end

player_id = player_id or {} ---@class player_id

includeSh("sh_player.lua")

includeSv("integrations/sv_acc2.lua")