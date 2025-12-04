


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