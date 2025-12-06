player_id.integrations = player_id.integrations or {}

---@class (strict) player_id.integration
---@field Name string
---@field Author string
---@field Version string
---@field CanUse fun(self: player_id.integration): boolean
---@field Start fun(self: player_id.integration)
---@field Stop fun(self: player_id.integration)
---@field FetchPlayerIDFromCharacterIDs fun(self: player_id.integration, characterIDs: string[], callback: fun(succ: boolean, characterList: player_id.CharacterList?))
---@field SearchOfflinePlayerDataByName fun(self: player_id.integration, name: string, callback: fun(succ: boolean, characterList: player_id.CharacterList?))
---@field FetchCharacterListBySteamID64s fun(self: player_id.integration, steamID64s: string[], callback: fun(succ: boolean, characterList: palyer_id.CharacterListsBySteamID64s?))

-- Function to register integration
---@generic T: player_id.integration
---@param integrationName player_id.integration.`T`
function player_id.RegisterIntegration(integrationName, integrationTable)
    player_id.integrations[integrationName] = integrationTable
end

-- Function to get integration
---@generic T: player_id.integration
---@param integrationName player_id.integration.`T`
---@return T?
function player_id.GetIntegration(integrationName)
    return player_id.integrations[integrationName]
end

---@class player_id.CharacterInfo
---@field PlayerID string
---@field SteamID64 string
---@field SteamID string
---@field name string

---@alias player_id.CharacterList table<string, player_id.CharacterInfo[]>

---@alias palyer_id.CharacterListsBySteamID64s table<string, player_id.CharacterList[]>

---@return player_id.integration
function player_id.GetCurrentIntegrationTable()
    local CurrentIntegrationName = player_id.GetCurrentIntegration()
    local INTEGRATION = player_id.GetIntegration(CurrentIntegrationName)
    assert(INTEGRATION, "player_id.GetCurrentIntegrationTable: No integration found for " .. tostring(CurrentIntegrationName))

    return INTEGRATION
end


-- Function Get offline player data by playerID
---@overload fun(playerID: string|string[], callback: fun(suc: true, characterList: table<string, player_id.CharacterInfo>))
---@overload fun(playerID: string|string[], callback: fun(suc: false|nil))
function player_id.GetOfflinePlayerDataByPlayerID(playerID, callback)
    assert(playerID, "player_id.GetOfflinePlayerDataByPlayerID: playerID is required")
    assert(type(playerID) == "string" or type(playerID) == "table", "player_id.GetOfflinePlayerDataByPlayerID: playerID must be a string or a table of strings" )
    assert(type(callback) == "function", "player_id.GetOfflinePlayerDataByPlayerID: callback must be a function")

    -- Convert to table if single string
    if type(playerID) == "string" then
        playerID = {playerID}
    end


    local INTEGRATION = player_id.GetCurrentIntegrationTable()

    INTEGRATION:FetchPlayerIDFromCharacterIDs(playerID, callback)
end


-- Function Search offline player data by name
---@overload fun(name: string, callback: fun(suc: true, characterList: player_id.CharacterList))
---@overload fun(name: string, callback: fun(suc: false|nil))
function player_id.SearchOfflinePlayerDataByName(name, callback)
    if player_id.GetCurrentIntegration() == "SteamID64" then
        if callback then
            callback(false)
        end
        return
    end

    local INTEGRATION = player_id.GetCurrentIntegrationTable()

    INTEGRATION:SearchOfflinePlayerDataByName(name, callback)
end

-- Function Get Character List By SteamID64
---@param steamID64 string|string[]
---@param callback fun(suc: boolean, characterList: palyer_id.CharacterListsBySteamID64s?)
function player_id.GetCharacterListBySteamID64(steamID64, callback)
    if player_id.GetCurrentIntegration() == "SteamID64" then
        -- If the current integration is SteamID64, we can directly use playerID as steamID64
        if callback then
            callback(true, {})
        end
        return
    end

    if type(steamID64) == "string" then
        steamID64 = {steamID64}
    end

    local INTEGRATION = player_id.GetCurrentIntegrationTable()

    INTEGRATION:FetchCharacterListBySteamID64s(steamID64, callback)
end


do -- Caching

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

        if playerID then
            hook.Run("playerID:OnCharacterLeave", playerID, ply)
            player_id.mt_CachedPlayerEntities[playerID] = nil
            player_id.mt_CachedPlayerEntities_SteamID[ply:SteamID()] = nil
            player_id.mt_CachedPlayerEntities_SteamID64[ply:SteamID64()] = nil
        end
    end)

end


do -- Current Integration Detection and Management

    ---@return string, player_id.integration
    function player_id.DetectCurrentIntegration()

        for integrationName, Integration in pairs(player_id.integrations) do
            if integrationName == "DEFAULT" then continue end

            if Integration:CanUse() then
                return integrationName, Integration
            end
        end

        local DEFAULT_INTEGRATION = player_id.GetIntegration("DEFAULT")
        assert(DEFAULT_INTEGRATION, "[playerID] DetectCurrentIntegration: DEFAULT integration not found")

        return "DEFAULT", DEFAULT_INTEGRATION
    end


    function player_id.UpdateCurrentIntegration()
        if player_id.mt_CurrentIntegration != nil then
            player_id.mt_CurrentIntegration:Stop()
            player_id.mt_CurrentIntegration = nil
        end

        local CurrentIntegrationName, CurrentIntegration = player_id.DetectCurrentIntegration()
        player_id.mt_CurrentIntegrationName = CurrentIntegrationName
        player_id.mt_CurrentIntegration = CurrentIntegration

        SetGlobal2String("player_id_integration", CurrentIntegrationName)

        player_id.mt_CurrentIntegration:Start()

        print("[playerID] Using integration: " .. CurrentIntegrationName)
    end
    hook.Add("InitPostEntity", "playerID:CacheCurrentIntegration", player_id.UpdateCurrentIntegration)
    if gmod.GetGamemode() != nil then player_id.UpdateCurrentIntegration() end

end


hook.Add("InitPostEntity", "playerID:CheckLatestVersion", function()
    http.Fetch("https://raw.githubusercontent.com/gmod-wikugim/gmod-playerID/refs/heads/master/.version", function(body, len, headers, code)
        if code != 200 then return end

        local currentVersion = file.Read("player_id.version", "GAME")

        local latestVersion = string.Trim(body)
        if latestVersion == "" or #latestVersion > 16 then return end -- Invalid version

        if latestVersion != currentVersion then
            print("[playerID] A new version of playerID is available! Current version: " .. currentVersion .. ", Latest version: " .. latestVersion)
            print("[playerID] Download the latest version from https://github.com/gmod-wikugim/gmod-playerID")
        end
    end)
end)