


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

/*
CREATE TABLE acc2_characters(
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    ownerId64 VARCHAR(32),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedAt TIMESTAMP NULL
);

ACC2.Query(query, callback)
*/
hook.Add("playerID:FetchOfflinePlayerData", "ACC2:Compatibilities:PlayerID:FetchOfflinePlayerData", function(playerID, callback)
    if !ACC2 then return end

    local query = Format("SELECT id, ownerId64 FROM acc2_characters WHERE id = %s AND deletedAt IS NULL LIMIT 1;", SQLStr(playerID))
    ACC2.Query(query, function(result)
        if !result or #result == 0 then
            callback(false, nil, nil)
            return
        end

        local steamID64 = result[1].ownerId64
        local steamID = util.SteamIDFrom64(steamID64)

        callback(true, steamID64, steamID)
    end)
end)

hook.Add("playerID:FetchCharacterListBySteamID64", "ACC2:Compatibilities:PlayerID:FetchCharacterListBySteamID64", function(steamID64, callback)
    if !ACC2 then return end

    local query = Format("SELECT id FROM acc2_characters WHERE ownerId64 = %s AND deletedAt IS NULL;", SQLStr(steamID64))
    ACC2.Query(query, function(result)
        if !result then
            callback(false, nil)
            return
        end

        local characterList = {}
        for _, row in ipairs(result) do
            table.insert(characterList, row.id)
        end

        callback(true, characterList)
    end)
end)