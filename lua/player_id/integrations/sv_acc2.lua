


hook.Add("ACC2:Character:Created", "ACC2:Compatibilities:PlayerID:CharacterCreated", function(ply, characterId)
    hook.Run("playerID:OnCharacterCreated", characterId, ply)
end)

hook.Add("ACC2:Character:Save", "ACC2:Compatibilities:PlayerID:CharacterSaved", function(ply, characterId)
    hook.Run("playerID:OnCharacterSaved", characterId, ply)
end)

hook.Add("ACC2:Load:Character", "ACC2:Compatibilities:PlayerID:CharacterLoad", function(ply, characterId)
    hook.Run("playerID:OnCharacterLoad", characterId, ply)
end)


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