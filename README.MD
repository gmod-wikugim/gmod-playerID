# Example of usage:

Meta examples
```lua
local ply = LocalPlayer()
--- Return Current PlayerID: CharacterID or SteamID64 if character system don't exists
print( ply:PlayerID() ) --> 1
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
```