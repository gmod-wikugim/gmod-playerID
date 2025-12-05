# Example of usage:

Concommands:
- playerid_fetch_offline_player_data playerID
- playerid_fetch_character_list_by_steamid64 characterID

Meta examples
```lua
--- Return Current PlayerID: CharacterID or SteamID64 if character system don't exists
local ply = LocalPlayer()
print( ply:PlayerID() ) --> 1
```

Search example
```lua
--- Send message to player by PlayerID
local ply = player_id.GetPlayerFromID("1")
if IsValid(ply) then
    ply:ChatPrint("Hello World!")
end
```

Hooks examples
```lua
-- Player when character is created
hook.Add("playerID:OnCharacterCreated", "playerID:LogCharacterCreated", function(characterId, ply)
    print("[playerID] Character created with ID:", characterId, "for player:", ply:Nick())
end)

-- Player when character is saved
hook.Add("playerID:OnCharacterSaved", "playerID:LogCharacterSaved", function(characterId, ply)
    print("[playerID] Character saved with ID:", characterId, "for player:", ply:Nick())
end)

-- Player when character is loaded
hook.Add("playerID:OnCharacterLoad", "playerID:LogCharacterLoad", function(characterId, ply)
    print("[playerID] Character loaded with ID:", characterId, "for player:", ply:Nick())
end)

-- Player when characted leave
hook.Add("playerID:OnCharacterLeave", "playerID:LogCharacterLeave", function(characterId, ply)
    print("[playerID] Character leave with ID:", characterId, "for player:", ply:Nick())
end)
```