---@class player_id.integration.ACC2: player_id.integration
local INTEGRATION = {}
INTEGRATION.Name = "ACC2"
INTEGRATION.Author = "Wikugim (https://about.srdev.pw/wikugim)"
INTEGRATION.Version = "1.0.0"

-- Check if ACC2 is installed
---@return boolean
function INTEGRATION:CanUse()
    return ACC2 ~= nil
end

function INTEGRATION:Start()
    if not ACC2 then
        error("[playerID][ACC2] ACC2 integration started but ACC2 is not installed!")
        return
    end

    hook.Add("ACC2:Character:Created", "ACC2:Compatibilities:PlayerID:CharacterCreated", function(ply, characterId)
        hook.Run("playerID:OnCharacterCreated", characterId, ply)
    end)

    hook.Add("ACC2:Character:Save", "ACC2:Compatibilities:PlayerID:CharacterSaved", function(ply, characterId)
        hook.Run("playerID:OnCharacterSaved", characterId, ply)
    end)

    hook.Add("ACC2:Load:Character", "ACC2:Compatibilities:PlayerID:CharacterLoad", function(ply, characterId, old_characterId)
        if old_characterId != nil then
            hook.Run("playerID:OnCharacterLeave", old_characterId, ply)
        end

        hook.Run("playerID:OnCharacterLoad", characterId, ply)
    end)
end

function INTEGRATION:Stop()
    hook.Remove("ACC2:Character:Created", "ACC2:Compatibilities:PlayerID:CharacterCreated")
    hook.Remove("ACC2:Character:Save", "ACC2:Compatibilities:PlayerID:CharacterSaved")
    hook.Remove("ACC2:Load:Character", "ACC2:Compatibilities:PlayerID:CharacterLoad")
end


/*

CREATE TABLE acc2_characters_compatibilities(
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    characterId INT NOT NULL,
    compatibilityName VARCHAR(64),
    typeValue VARCHAR(64),
    keyName VARCHAR(64),
    value LONGTEXT,
    ownerId64 VARCHAR(32),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(characterId) REFERENCES acc2_characters(id) ON DELETE CASCADE
);

keyName list: globalName

ACC2.Query(query, callback)
*/

---@param characterIDs string[]
---@param callback fun(succ: boolean, characterList: player_id.CharacterList?)
function INTEGRATION:FetchPlayerIDFromCharacterIDs(characterIDs, callback)
    assert(type(characterIDs) == "table" and next(characterIDs) != nil, "[playerID][ACC2] FetchPlayerIDFromCharacterIDs: characterIDs must be a non-empty table")
    assert(type(callback) == "function", "[playerID][ACC2] FetchPlayerIDFromCharacterIDs: callback must be a function")

    -- Select ownerId64 from acc2_characters, then return globalName from acc2_characters_compatibilities
    local qeury = Format("SELECT ac.id, ac.ownerId64, acc.value FROM acc2_characters AS ac LEFT JOIN acc2_characters_compatibilities AS acc ON ac.id = acc.characterId AND acc.keyName = 'globalName' WHERE ac.id IN (%s) AND ac.deletedAt IS NULL;", table.concat(characterIDs, ", "))
    ACC2.Query(qeury, function(result)
        if !result or next(result) == nil then
            callback(false)
            return
        end

        local CharacterList = {}
        for _, row in pairs(result) do
            local charID_str = tostring(row.id)
            CharacterList[charID_str] = {
                PlayerID = charID_str,
                SteamID64 = row.ownerId64,
                SteamID = util.SteamIDFrom64(row.ownerId64),
                name = row.value or "Unknown",
            }
        end

        callback(true, CharacterList)
    end)
end

---@param name string
---@param callback fun(succ: boolean, characterList: player_id.CharacterList?)
function INTEGRATION:SearchOfflinePlayerDataByName(name, callback)
    assert(type(name) == "string" and name != "", "[playerID][ACC2] SearchOfflinePlayerDataByName: name must be a non-empty string")
    assert(type(callback) == "function", "[playerID][ACC2] SearchOfflinePlayerDataByName: callback must be a function")

    -- playerID:SearchOfflinePlayerDataByName for ACC2, should check for equal name, and also LIKE name
    local query = Format("SELECT ac.id, ac.ownerId64, acc.value FROM acc2_characters AS ac LEFT JOIN acc2_characters_compatibilities AS acc ON ac.id = acc.characterId AND acc.keyName = 'globalName' WHERE (acc.value = %s OR acc.value LIKE %s) AND ac.deletedAt IS NULL;", SQLStr(name), SQLStr("%" .. name .. "%"))
    ACC2.Query(query, function(result)
        if !result or next(result) == nil then
            callback(false)
            return
        end

        local CharacterList = {}
        for _, row in pairs(result) do
            local charID_str = tostring(row.id)
            CharacterList[charID_str] = {
                PlayerID = charID_str,
                SteamID64 = row.ownerId64,
                SteamID = util.SteamIDFrom64(row.ownerId64),
                name = row.value or "Unknown",
            }
        end

        callback(true, CharacterList)
    end)
end

---@param steamID64s string[]
---@param callback fun(succ: boolean, characterList: palyer_id.CharacterListsBySteamID64s?)
function INTEGRATION:FetchCharacterListBySteamID64s(steamID64s, callback)
    assert(type(steamID64s) == "table" and next(steamID64s) != nil, "[playerID][ACC2] FetchCharacterListBySteamID64s: steamID64s must be a non-empty table")
    assert(type(callback) == "function", "[playerID][ACC2] FetchCharacterListBySteamID64s: callback must be a function")

    -- Select characterId from acc2_characters, globalName from acc2_characters_compatibilities, where ownerId64 IN steamID64s
    local query = Format("SELECT ac.id, ac.ownerId64, acc.value FROM acc2_characters AS ac LEFT JOIN acc2_characters_compatibilities AS acc ON ac.id = acc.characterId AND acc.keyName = 'globalName' WHERE ac.ownerId64 IN (%s) AND ac.deletedAt IS NULL;", table.concat(steamID64s, ", "))
    ACC2.Query(query, function(result)
        if !result or next(result) == nil then
            callback(false)
            return
        end

        local CharacterList = {}
        for _, row in pairs(result) do
            local steamID64 = row.ownerId64
            CharacterList[steamID64] = CharacterList[steamID64] or {}

            local charID_str = tostring(row.id)
            CharacterList[steamID64][charID_str] = {
                PlayerID = charID_str,
                SteamID64 = steamID64,
                SteamID = util.SteamIDFrom64(steamID64),
                name = row.value or "Unknown",
            }
        end

        callback(true, CharacterList)
    end)
end



player_id.RegisterIntegration("ACC2", INTEGRATION)