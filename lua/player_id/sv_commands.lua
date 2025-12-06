-- Concommand to Fetch offline player data
concommand.Add("playerid_fetch_offline_player_data", function(ply, cmd, args)
    local function message(msg)
        if IsValid(ply) then
            ply:ChatPrint("[playerID] " .. msg)
        else
            print("[playerID] " .. msg)
        end
    end

    -- Check is server console or superadmin
    if IsValid(ply) and not ply:IsSuperAdmin() then
        message("You don't have permission to use this command.")
        return
    end

    local playerID = args[1]
    if not playerID then
        message("Usage: playerid_fetch_offline_player_data <playerID>")
        return
    end

    player_id.GetOfflinePlayerDataByPlayerID(playerID, function(suc, data)
        if not suc or not data or next(data) == nil then
            message("No offline player data found for playerID: " .. playerID)
            return
        end

        message("Offline player data for playerID: " .. playerID)
        for _, info in pairs(data) do
            message("  PlayerID: " .. tostring(info.PlayerID or ""))
            message("    SteamID64: " .. tostring(info.SteamID64 or ""))
            message("    SteamID: " .. tostring(info.SteamID or ""))
            message("    Name: " .. tostring(info.name or ""))
        end
    end)
end)

-- Concommand to Search offline player data by name
concommand.Add("playerid_search_offline_player_data_by_name", function(ply, cmd, args)
    local function message(msg)
        if IsValid(ply) then
            ply:ChatPrint("[playerID] " .. msg)
        else
            print("[playerID] " .. msg)
        end
    end

    -- Check is server console or superadmin
    if IsValid(ply) and not ply:IsSuperAdmin() then
        message("You don't have permission to use this command.")
        return
    end

    local name = table.concat(args, " ")
    if name == "" then
        message("Usage: playerid_search_offline_player_data_by_name <name>")
        return
    end

    player_id.SearchOfflinePlayerDataByName(name, function(suc, characterList)
        if not suc or not characterList or next(characterList) == nil then
            message("No offline player data found for name: " .. name)
            return
        end

        message("Offline player data matching name: " .. name)
        for _, info in pairs(characterList) do
            message("  PlayerID: " .. tostring(info.PlayerID or ""))
            message("    SteamID64: " .. tostring(info.SteamID64 or ""))
            message("    SteamID: " .. tostring(info.SteamID or ""))
            message("    Name: " .. tostring(info.name or ""))
        end
    end)
end)

-- Concommand to Fetch character list by SteamID64
concommand.Add("playerid_fetch_character_list_by_steamid64", function(ply, cmd, args)
    local function message(msg)
        if IsValid(ply) then
            ply:ChatPrint("[playerID] " .. msg)
        else
            print("[playerID] " .. msg)
        end
    end

    -- Check is server console or superadmin
    if IsValid(ply) and not ply:IsSuperAdmin() then
        message("You don't have permission to use this command.")
        return
    end

    local steamID64 = args[1]
    if not steamID64 then
        message("Usage: playerid_fetch_character_list_by_steamid64 <SteamID64>")
        return
    end

    -- Convert SteamID to SteamID64 if needed
    if string.find(steamID64, "STEAM_") then
        steamID64 = util.SteamIDTo64(steamID64)
    end


    player_id.GetCharacterListBySteamID64(steamID64, function(suc, characterLists)
        if not suc or not characterLists or next(characterLists) == nil then
            message("No character list found for SteamID64: " .. steamID64)
            return
        end

        message("Character list for SteamID64: " .. steamID64)
        for _, characterList in pairs(characterLists) do
            for _, info in pairs(characterList) do
                message("  PlayerID: " .. tostring(info.PlayerID or ""))
                message("    SteamID64: " .. tostring(info.SteamID64 or ""))
                message("    SteamID: " .. tostring(info.SteamID or ""))
                message("    Name: " .. tostring(info.name or ""))
            end
        end
    end)
end)