player_id.mt_CachedPlayerEntities = player_id.mt_CachedPlayerEntities or {} ---@type table<string, Player>
player_id.mt_CachedPlayerEntities_SteamID = player_id.mt_CachedPlayerEntities_SteamID or {} ---@type table<string, Player>
player_id.mt_CachedPlayerEntities_SteamID64 = player_id.mt_CachedPlayerEntities_SteamID64 or {} ---@type table<string, Player>


local PLAYER = FindMetaTable("Player") ---@class Player

local assert = assert
local tostring = tostring
local IsValid = IsValid

-- Function GetPlayerID - Get the player's ID based on installed frameworks
---@return string
function PLAYER:PlayerID()
    if ACC2 then -- Advanced Character Creator - Create infinite characters
        local playerID = ACC2.GetNWVariables("characterId", self)
        assert(playerID, "ACC2 is installed but no character ID found for player " .. self:Nick())

        local playerID_string = tostring(playerID)
        assert(playerID_string, "Character ID found but could not convert to string for player " .. self:Nick())

        return playerID_string
    elseif ix then -- Helix framework
        local character = self:GetCharacter()
        assert(character, "Helix is installed but no character found for player " .. self:Nick())
        local playerID = character:GetID()
        assert(playerID, "Helix character found but no ID for player " .. self:Nick())

        local playerID_string = tostring(playerID)
        assert(playerID_string, "Character ID found but could not convert to string for player " .. self:Nick())

        return playerID_string
    else
        local playerID = self:SteamID64()
        assert(playerID, "No SteamID64 found for player " .. self:Nick())

        local playerID_string = tostring(playerID)
        assert(playerID_string, "SteamID64 found but could not convert to string for player " .. self:Nick())

        return playerID_string
    end
end

-- Function to get Player entity from PlayerID, don't use in performance critical code (like Paint, Think, etc)
-- Also accept SteamID and SteamID64 for convenience
---@param playerID string
---@param bOnlyCached boolean|nil If true, only return cached player entities
---@return Player?
function player_id.GetPlayerFromID(playerID, bOnlyCached)
    local cachedPlayer = player_id.mt_CachedPlayerEntities[playerID]
    if IsValid(cachedPlayer) then
        return cachedPlayer
    end

    if bOnlyCached then return nil end

    for _, ply in player.Iterator() do
        if ply:GetPlayerID() == playerID then
            return ply
        end
    end

    return nil
end

-- Function to check current integration
---@return "ACC2"|"Helix"|"SteamID64"
function player_id.GetCurrentIntegration()
    if ACC2 then
        return "ACC2"
    elseif ix then
        return "Helix"
    else
        return "SteamID64"
    end
end