---@class player_id.integration.DEFAULT: player_id.integration
local INTEGRATION = {}
INTEGRATION.Name = "DEFAULT"
INTEGRATION.Author = "Wikugim (https://about.srdev.pw/wikugim)"
INTEGRATION.Version = "1.0.0"

-- Check if DEFAULT is installed
---@return boolean
function INTEGRATION:CanUse()
    return true -- DEFAULT is always available
end

function INTEGRATION:Start()
    hook.Add("PlayerInitialSpawn", "DEFAULT:Compatibilities:PlayerID:CharacterCreated", function(ply)
        local characterId = ply:SteamID64() -- Use SteamID64 as characterId for DEFAULT
        hook.Run("playerID:OnCharacterLoad", characterId, ply)
    end)
end

function INTEGRATION:Stop()
    hook.Remove("PlayerInitialSpawn", "DEFAULT:Compatibilities:PlayerID:CharacterCreated")
end

---@param characterIDs string[]
---@param callback fun(succ: boolean, characterList: player_id.CharacterList?)
function INTEGRATION:FetchPlayerIDFromCharacterIDs(characterIDs, callback)
    assert(type(characterIDs) == "table" and next(characterIDs) != nil, "[playerID][DEFAULT] FetchPlayerIDFromCharacterIDs: characterIDs must be a non-empty table")
    assert(type(callback) == "function", "[playerID][DEFAULT] FetchPlayerIDFromCharacterIDs: callback must be a function")

    local CharacterList = {}
    for _, characterID in pairs(characterIDs) do

        local name = "Unknown" -- Name is unknown in DEFAULT integration
        local ply = player.GetBySteamID64(characterID)
        if IsValid(ply) then
            name = ply:Nick()
        end

        CharacterList[characterID] = {
            PlayerID = characterID,
            SteamID64 = characterID,
            SteamID = util.SteamIDFrom64(characterID),
            name = name,
        }
    end

    callback(true, CharacterList)
end

---@param name string
---@param callback fun(succ: boolean, characterList: player_id.CharacterList?)
function INTEGRATION:SearchOfflinePlayerDataByName(name, callback)
    assert(type(name) == "string" and name != "", "[playerID][DEFAULT] SearchOfflinePlayerDataByName: name must be a non-empty string")
    assert(type(callback) == "function", "[playerID][DEFAULT] SearchOfflinePlayerDataByName: callback must be a function")

    callback(false)
end

---@param steamID64s string[]
---@param callback fun(succ: boolean, characterList: palyer_id.CharacterListsBySteamID64s?)
function INTEGRATION:FetchCharacterListBySteamID64s(steamID64s, callback)
    assert(type(steamID64s) == "table" and next(steamID64s) != "nil", "[playerID][DEFAULT] FetchCharacterListBySteamID64s: steamID64s must be a non-empty table")
    assert(type(callback) == "function", "[playerID][DEFAULT] FetchCharacterListBySteamID64s: callback must be a function")

    local CharacterList = {}
    for _, steamID64 in pairs(steamID64s) do
        local name = "Unknown" -- Name is unknown in DEFAULT integration
        local ply = player.GetBySteamID64(steamID64)
        if IsValid(ply) then
            name = ply:Nick()
        end

        CharacterList[steamID64] = CharacterList[steamID64] or {}

        CharacterList[steamID64][steamID64] = {
            PlayerID = steamID64,
            SteamID64 = steamID64,
            SteamID = util.SteamIDFrom64(steamID64),
            name = name,
        }
    end

    callback(true, CharacterList)
end



player_id.RegisterIntegration("DEFAULT", INTEGRATION)