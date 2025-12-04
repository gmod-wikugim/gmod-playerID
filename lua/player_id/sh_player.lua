--

local PLAYER = FindMetaTable("Player") ---@class Player

local assert = assert
local tostring = tostring

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