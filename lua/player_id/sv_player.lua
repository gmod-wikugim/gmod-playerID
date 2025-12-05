
-- Function Get offline player data by playerID
---@param playerID string
---@param callback fun(suc: boolean, SteamID64:string, SteamID:string)
function player_id.GetOfflinePlayerDataByPlayerID(playerID, callback)
    -- If the current integration is SteamID64, we can directly convert
    if player_id.GetCurrentIntegration() == "SteamID64" then
        local steamID64 = playerID
        local steamID = util.SteamIDFrom64(steamID64)
        if callback then
            callback(true, steamID64, steamID)
        end
        return
    end


    local timer_name = "player_id.GetOfflinePlayerDataByPlayerID.Timeout." .. tostring(playerID)

    local bAnswerReceived = false

    local function Result(succ, steamID64, steamID)
        if bAnswerReceived then return end
        bAnswerReceived = true
        timer.Remove(timer_name)

        if callback then
            callback(succ, steamID64, steamID)
        end
    end

    hook.Run("playerID:FetchOfflinePlayerData", playerID, Result)

    timer.Create(timer_name, 5, 1, function()
        Result(false, nil, nil)
    end)
end

-- Function Get Character List By SteamID64
---@param steamID64 string
---@param callback fun(suc: boolean, characterList: string[])
function player_id.GetCharacterListBySteamID64(steamID64, callback)
    if player_id.GetCurrentIntegration() == "SteamID64" then
        -- If the current integration is SteamID64, we can directly use playerID as steamID64
        if callback then
            callback(true, {})
        end
        return
    end


    local timer_name = "player_id.GetCharacterListBySteamID64.Timeout." .. tostring(steamID64)
    local bAnswerReceived = false
    local function Result(succ, characterList)
        if bAnswerReceived then return end
        bAnswerReceived = true
        timer.Remove(timer_name)

        if callback then
            callback(succ, characterList)
        end
    end
    hook.Run("playerID:FetchCharacterListBySteamID64", steamID64, Result)
    timer.Create(timer_name, 5, 1, function()
        Result(false, nil)
    end)
end

-- Function Get SteamID by playerID
---@param playerID string
---@return string?
function player_id.GetSteamIDByPlayerID(playerID)
    local ply = player_id.GetPlayerFromID(playerID, true)
    if IsValid(ply) then
        return ply:SteamID()
    end

    return nil
end

-- Function Get SteamID64 by playerID
---@param playerID string
---@return string?
function player_id.GetSteamID64ByPlayerID(playerID)
    local ply = player_id.GetPlayerFromID(playerID, true)
    if IsValid(ply) then
        return ply:SteamID64()
    end
end

-- Cache palyer entities for SteamID, SteamID64
hook.Add("PlayerInitialSpawn", "playerID:CachePlayerEntity_SteamID", function(ply)
    player_id.mt_CachedPlayerEntities_SteamID[ply:SteamID()] = ply
    player_id.mt_CachedPlayerEntities_SteamID64[ply:SteamID64()] = ply
end)


-- Cache player entities on character load and clear on disconnect
hook.Add("playerID:OnCharacterLoad", "playerID:CachePlayerEntity", function(playerID, ply)
    local playerID_string = tostring(playerID)

    player_id.mt_CachedPlayerEntities[playerID_string] = ply
end)

-- Clear cached player entity on disconnect
hook.Add("PlayerDisconnected", "playerID:ClearCachedPlayerEntity", function(ply)
    local playerID = ply:PlayerID()

    hook.Run("playerID:OnCharacterLeave", playerID, ply)
    player_id.mt_CachedPlayerEntities[playerID] = nil
    player_id.mt_CachedPlayerEntities_SteamID[ply:SteamID()] = nil
    player_id.mt_CachedPlayerEntities_SteamID64[ply:SteamID64()] = nil
end)





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

    player_id.GetOfflinePlayerDataByPlayerID(playerID, function(suc, steamID64, steamID)
        if not suc then
            message("No offline player data found for playerID: " .. playerID)
            return
        end

        message("Offline player data for playerID: " .. playerID)
        message("  SteamID64: " .. steamID64)
        message("  SteamID: " .. steamID)
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


    player_id.GetCharacterListBySteamID64(steamID64, function(suc, characterList)
        if not suc then
            message("Failed to fetch character list for SteamID64: " .. steamID64)
            return
        end

        message("Character list for SteamID64: " .. steamID64)
        for _, characterID in ipairs(characterList) do
            message("  CharacterID: " .. characterID)
        end
    end)
end)