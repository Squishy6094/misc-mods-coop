-------------------------
-- Cardboard Functions --
-------------------------

local cloakTimer = 0
local prevHealth = gMarioStates[0].health
function disappear_update(m)
    if prevHealth > m.health then
        cloakTimer = 300
        _G.charSelect.character_edit(charTable[E_MODEL_CARDBOARD].cs, nil, nil, nil, nil, E_MODEL_NONE)
        spawn_sync_object(id_bhvVertStarParticleSpawner, 0, m.pos.x, m.pos.y, m.pos.z, nil)
    end

    if cloakTimer > 0 then
        cloakTimer = cloakTimer - 1
        spawn_non_sync_object(id_bhvSparkleSpawn, 0, m.pos.x, m.pos.y, m.pos.z, nil)
    elseif cloakTimer == 0 then
        cloakTimer = -1
        _G.charSelect.character_edit(charTable[E_MODEL_CARDBOARD].cs, nil, nil, nil, nil, E_MODEL_CARDBOARD)
    end

    prevHealth = m.health
end