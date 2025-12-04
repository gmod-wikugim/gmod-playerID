player_id.mt_CachedPlayerEntities = player_id.mt_CachedPlayerEntities or {} ---@type table<string, Player>

local PLAYER = FindMetaTable("Player") ---@class Player

local assert = assert
local tostring = tostring
local IsValid = IsValid

-- Function GetPlayerID - Get the player's ID based on installed frameworks
---@return string
function PLAYER:GetPlayerID()
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
---@param playerID string
---@return Player?
function player_id.GetPlayerFromID(playerID)
    local cachedPlayer = player_id.mt_CachedPlayerEntities[playerID]
    if IsValid(cachedPlayer) then
        return cachedPlayer
    end

    for _, ply in player.Iterator() do
        if ply:GetPlayerID() == playerID then
            return ply
        end
    end

    return nil
end


-- Cache player entities on character load and clear on disconnect
hook.Add("playerID:OnCharacterLoad", "playerID:CachePlayerEntity", function(playerID, ply)
    local playerID_string = tostring(playerID)

    player_id.mt_CachedPlayerEntities[playerID_string] = ply
end)

-- Clear cached player entity on disconnect
hook.Add("PlayerDisconnected", "playerID:ClearCachedPlayerEntity", function(ply)
    local playerID = ply:GetPlayerID()

    hook.Run("playerID:OnCharacterLeave", playerID, ply)
    player_id.mt_CachedPlayerEntities[playerID] = nil
end)

