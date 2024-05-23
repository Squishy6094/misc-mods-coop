-- name: [CS] Squishy

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n".."Squishy Pack".."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local gamemode = false
for i in pairs(gActiveMods) do
    if gActiveMods[i].incompatible == "gamemode" and gActiveMods[i].name ~= "Personal Star Counter" then
        gamemode = true
        break
    end
end

---------------------------------
-- Character Select Initialize --
---------------------------------

local E_MODEL_SQUISHY = smlua_model_util_get_id("squishy_geo")
local E_MODEL_CARDBOARD = smlua_model_util_get_id("cardboard_geo")

local TEX_SQUISHY = get_texture_info("squishy-icon")

local VOICETABLE_NONE = {nil}

local squishyPalette = {
    [PANTS]  = "000419",
    [SHIRT]  = "0a1e00",
    [GLOVES] = "ffffff",
    [SHOES]  = "ffffff",
    [HAIR]   = "0b0300",
    [SKIN]   = "ffe6b2",
    [CAP]    = "080808",
}

NETWORK_SQUISHY = 1
NETWORK_CARDBOARD = 2

charTable = {
    [E_MODEL_SQUISHY] = {cs = _G.charSelect.character_get_number_from_string("Squishy") and _G.charSelect.character_get_number_from_string("Squishy") or 0, network = NETWORK_SQUISHY},
    [E_MODEL_CARDBOARD] = {cs = 0, network = NETWORK_CARDBOARD},
}

if charTable[E_MODEL_SQUISHY].cs == 0 then
    charTable[E_MODEL_SQUISHY].cs = _G.charSelect.character_add("Squishy", "Squishy T. Server", "Trashcam / Squishy", "008800", E_MODEL_SQUISHY, nil, TEX_SQUISHY, 1)
else
    _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, "Squishy", "Squishy T. Server", "Trashcam / Squishy", {r = 0, g = 136, b = 0}, E_MODEL_SQUISHY, nil, TEX_SQUISHY, 1)
end

_G.charSelect.character_add_voice(E_MODEL_CARDBOARD, VOICETABLE_NONE)
_G.charSelect.character_add_voice(E_MODEL_NONE, VOICETABLE_NONE)
hook_event(HOOK_CHARACTER_SOUND, function (m, sound)
    if _G.charSelect.character_get_voice(m) == VOICETABLE_NONE then return _G.charSelect.voice.sound(m, sound) end
end)
hook_event(HOOK_MARIO_UPDATE, function (m)
    if _G.charSelect.character_get_voice(m) == VOICETABLE_NONE then return _G.charSelect.voice.snore(m) end
end)

_G.charSelect.character_add_palette_preset(E_MODEL_SQUISHY, squishyPalette)


-----------------------
-- Squishy Functions --
-----------------------

local ledgeTimer = 0
local velStore = 0
local function ledge_parkour(m)
    if m.action == ACT_SOFT_BONK and m.prevAction == ACT_LEDGE_GRAB then
        if m.controller.buttonDown & Z_TRIG == 0 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            m.forwardVel = 6
        else
            m.prevAction = ACT_SOFT_BONK
        end
    end

    if (m.action == ACT_LEDGE_GRAB or m.action == ACT_LEDGE_CLIMB_FAST) then
        ledgeTimer = ledgeTimer + 1
    else
        ledgeTimer = 0
        velStore = m.forwardVel
    end

    if ledgeTimer <= 5 and velStore >= 25 then
        if m.action == ACT_LEDGE_CLIMB_FAST and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            set_mario_action(m, ACT_SIDE_FLIP, 0)
            m.vel.y = math.min(velStore*0.8, 40)
            if ledgeTimer == 1 then -- Firstie gives back raw speed
                m.forwardVel = velStore
            else
                m.forwardVel = velStore * 0.85
            end
        end

        if m.action == ACT_LEDGE_GRAB and (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_SLIDE_KICK, 0)
            m.vel.y = math.min(velStore*0.2, 20)
            if ledgeTimer == 1 then -- Firstie gives back raw speed
                m.forwardVel = velStore
            else
                m.forwardVel = velStore * 0.9
            end
        end
    else
        if m.action == ACT_LEDGE_CLIMB_FAST and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            m.vel.y = 10
            m.forwardVel = 20
        end

        if m.action == ACT_LEDGE_GRAB and (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_JUMP_KICK, 0)
            m.vel.y = 20
            m.forwardVel = 10
        end

        if m.action == ACT_LEDGE_CLIMB_SLOW_1 or m.action == ACT_LEDGE_CLIMB_SLOW_2 then
            set_mario_action(m, ACT_LEDGE_CLIMB_FAST, 0)
        end
    end
end

local TECH_KB = {
    [ACT_GROUND_BONK] = true,
    [ACT_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_FORWARD_GROUND_KB] = true,
    [ACT_FORWARD_GROUND_KB] = true,
    [ACT_DEATH_EXIT_LAND] = true,
    [ACT_FORWARD_AIR_KB] = true,
    [ACT_BACKWARD_AIR_KB] = true,
    [ACT_HARD_FORWARD_AIR_KB] = true,
    [ACT_HARD_BACKWARD_AIR_KB] = true,
  
}
local tech = true
local techTimer = 10
local activeVel = 0
local function teching(m)
    if m.forwardVel ~= 0 then
        activeVel = m.forwardVel
    end
    local angle = m.faceAngle.y + (activeVel > 0 and 0 or 0x8000)
    local wall = collision_find_surface_on_ray(m.pos.x, m.pos.y, m.pos.z, sins(angle)*115, 0, coss(angle)*115)
    if m.health > 255 then
        if (wall and wall.surface) or m.pos.y == m.floorHeight then
            techTimer = techTimer - 1
            if TECH_KB[m.action] and (m.controller.buttonPressed & Z_TRIG) ~= 0 and techTimer > 0 then
                if (wall and wall.surface) and m.pos.y ~= m.floorHeight then
                    m.faceAngle.y = m.faceAngle.y + 0x8000
                    m.forwardVel = 20
                end
                if activeVel > 0 then
                    set_mario_action(m, ACT_FORWARD_ROLLOUT, 1)
                else
                    set_mario_action(m, ACT_BACKWARD_ROLLOUT, 1)
                end
                play_character_sound(m, CHAR_SOUND_UH2)
                m.vel.y = 21
                m.particleFlags = m.particleFlags | ACTIVE_PARTICLE_SPARKLES
                m.invincTimer = 20
                techTimer = 10
            else
                techTimer= 10
            end
        end
    end
end

local prevCancelCount = -1
local cancelCount = 0
local anglemath = 0
local prevVel = {}
local prevAngle = nil
local function momentum_pound(m)
    if (m.action == ACT_GROUND_POUND or m.action == ACT_GROUND_POUND_LAND) and m.controller.stickMag > 20 and m.vel.x == 0 then
        m.vel.x = prevVel.x * 2
        m.vel.z = prevVel.z * 2
    elseif m.forwardVel ~= 0 then
        prevVel.x = m.vel.x 
        prevVel.y = m.vel.y 
        prevVel.z = m.vel.z 
    end
    if m.action == ACT_GROUND_POUND then
        m.vel.y = -100
        m.peakHeight = m.pos.y
        if m.controller.buttonPressed & A_BUTTON ~= 0 and (cancelCount == 0 or m.prevAction == ACT_WALL_KICK_AIR) and m.pos.y > m.floorHeight + 50 then
            set_mario_action(m, ACT_LONG_JUMP, 0)
            local speed = math.sqrt(prevVel.x^2 + prevVel.z^2)*1.2
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = math.max(speed, 20)
            cancelCount = cancelCount + 1
            m.vel.y = speed*0.3
        end
    end
    
    if m.wall ~= nil and m.action ~= ACT_TRIPLE_JUMP and (m.action == ACT_GROUND_POUND or (m.action ~= ACT_FREEFALL and m.prevAction == ACT_GROUND_POUND)) then
        anglemath = atan2s(m.wall.normal.z, m.wall.normal.x)
        m.faceAngle.y = anglemath
        m.forwardVel = math.min(math.sqrt(prevVel.x^2 + prevVel.z^2)*2, 100)
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = math.min(math.sqrt(prevVel.x^2 + prevVel.z^2)*2, 100)
        if prevAngle ~= anglemath then
            cancelCount = 0
            prevAngle = anglemath
        end
    end
    if m.action == ACT_WALL_KICK_AIR and prevCancelCount ~= cancelCount then
        prevCancelCount = cancelCount
        m.vel.y = -(cancelCount - 7) * 10
    end
    if (cancelCount > 0 or prevAngle == anglemath) and m.pos.y == m.floorHeight then
        prevCancelCount = -1
        cancelCount = 0
        prevAngle = nil
    end

    if m.action == ACT_GROUND_POUND_LAND or (m.action == ACT_BUTT_SLIDE and m.prevAction == ACT_GROUND_POUND_LAND) then
        if m.controller.stickMag > 20 then
            if m.floor.type ~= SURFACE_BURNING then
                set_mario_action(m, ACT_SLIDE_KICK, 0)
            else
                set_mario_action(m, ACT_LAVA_BOOST, 0)
                m.hurtCounter = 12
                m.vel.y = 90
            end
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = math.sqrt(prevVel.x^2 + prevVel.z^2)*1.3
        else
            set_mario_action(m, ACT_BACKWARD_ROLLOUT, 0)
            m.forwardVel = 0
            m.faceAngle.y = m.intendedYaw
        end
        m.flags = m.flags | INT_GROUND_POUND_OR_TWIRL
    end

    if m.action == ACT_BACKWARD_ROLLOUT and m.prevAction == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & Z_TRIG ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
    end
end

local wasButtslide = false
local function custom_slide(m)
    if m.action == ACT_BUTT_SLIDE then
        if m.prevAction == ACT_GROUND_POUND or m.prevAction == ACT_GROUND_POUND_LAND then
            m.faceAngle.y = m.floorAngle
        end
        set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
        wasButtslide = true
    end

    if m.action == ACT_FORWARD_ROLLOUT and m.prevAction == ACT_SLIDE_KICK_SLIDE and wasButtslide then
        set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        m.vel.y = math.max(m.forwardVel, 40)
        m.forwardVel = m.forwardVel*0.8
        wasButtslide = false
    elseif m.action ~= ACT_SLIDE_KICK_SLIDE then
        wasButtslide = false
    end
end

gPlayerSyncTable[0].lostCoins = 0
local deathTimer = 0
local queueCamUnfreeze = false
local isDieing = false
local function explode_on_death(m)
    if m.health > 255 then
        deathTimer = 0
        if queueCamUnfreeze then
            queueCamUnfreeze = false
            camera_unfreeze()
        end
        if isDieing then
            isDieing = false
            if gamemode then
                _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, nil, nil, nil, nil, E_MODEL_SQUISHY)
            end
        end
        return
    end
    if not isDieing then
        deathTimer = deathTimer + 1
        if gServerSettings.bubbleDeath == 0 or network_player_connected_count() == 1 then
            queueCamUnfreeze = true
            camera_freeze()
            local focusPos = {
                x = m.pos.x,
                y = m.pos.y + 120,
                z = m.pos.z,
            }
            vec3f_copy(gLakituState.focus, focusPos)
            if deathTimer > 30 or m.pos.y <= m.floorHeight + 10 or (m.action == ACT_LAVA_BOOST and m.vel.y <= 10) then
                local coinsLost = 0
                for i = 1, 5 do
                    if m.numCoins > 0 then
                        local velY = 30 + math.max(m.vel.y, 5)
                        local randAngle = m.faceAngle.y + math.random(-0x2000, 0x2000)
                        local randSpeed = m.forwardVel * math.random(10, 30)*0.05
                        spawn_sync_object(id_bhvMovingYellowCoin, E_MODEL_YELLOW_COIN, m.pos.x, m.pos.y, m.pos.z, function (o) o.oVelY = velY; o.oMoveAngleYaw = randAngle; o.oForwardVel = randSpeed end)
                    end
                end
                for i = 0, MAX_PLAYERS - 1 do
                    if gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum and gNetworkPlayers[i].currActNum == gNetworkPlayers[0].currActNum then
                        gPlayerSyncTable[i].lostCoins = gPlayerSyncTable[i].lostCoins + coinsLost
                    end
                end
                spawn_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, m.pos.x, m.pos.y, m.pos.z, function (o) o.oOpacity = 255 end)
                if not gamemode then
                    set_mario_action(m, ACT_DISAPPEARED, 0)
                    level_trigger_warp(m, WARP_OP_DEATH)
                else
                    level_trigger_warp(m, ACT_DEATH_ON_BACK)
                    _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, nil, nil, nil, nil, E_MODEL_NONE)
                end
                isDieing = true
            end
        else
            if m.action == ACT_BUBBLED then
                if deathTimer > 300 then
                    set_mario_action(m, ACT_DISAPPEARED, 0)
                    spawn_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, m.pos.x, m.pos.y, m.pos.z, function (o) o.oOpacity = 255 end)
                    level_trigger_warp(m, WARP_OP_DEATH)
                    isDieing = true
                end
            else
                deathTimer = 0
            end
        end
    end
end

local doubleJumpTable = {
    [ACT_LONG_JUMP_LAND] = true
}

local function more_double_jumps(m)
    if doubleJumpTable[m.action] then
        if m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        end
    end
end

local interpPrev = {
    bubbleExplode = {
        x = 0,
        y = 0,
        meter = 0
    },
    spamBurnout = {
        x = 0,
        y = 0,
    }
}

local MATH_DIVIDE_300 = 1/300

local function hud_bubble_timer(m)
    if m.action == ACT_BUBBLED and deathTimer < 300 then
        djui_hud_set_resolution(RESOLUTION_N64)
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 230, z = m.marioObj.header.gfx.pos.z }
        djui_hud_world_pos_to_screen_pos(pos, out)
        local x = out.x - 20
        local y = out.y - 3
        local meter = deathTimer*MATH_DIVIDE_300
        local randX = math.random(-deathTimer, deathTimer)*0.01
        local randY = math.random(-deathTimer, deathTimer)*0.01
        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_render_rect_interpolated(interpPrev.bubbleExplode.x, interpPrev.bubbleExplode.y, 40, 6, x + randX, y + randY, 40, 6)
        djui_hud_set_color(255, 0, 0, 200)
        djui_hud_render_rect_interpolated(interpPrev.bubbleExplode.x + 1, interpPrev.bubbleExplode.y + 1, 38 - 38*interpPrev.bubbleExplode.meter, 4, x + randX + 1, y + randY + 1, 38 - 38*meter, 4)
        interpPrev.bubbleExplode.x = x
        interpPrev.bubbleExplode.y = y
        interpPrev.bubbleExplode.meter = meter
    end
end

local spamInputs = 0
local spamInputsRequired = 10
local function spam_burnout(m)
    if m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP or m.action == ACT_LAVA_BOOST then
        if (m.controller.buttonPressed & Z_TRIG) ~= 0 then
            spamInputs = spamInputs + 1
            m.particleFlags = m.particleFlags | PARTICLE_DUST
            play_sound(SOUND_GENERAL_FLAME_OUT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        end
        if m.pos.y == m.floorHeight or m.wall then
            if m.floor.type ~= SURFACE_BURNING and (m.wall and m.wall.type or 0) ~= SURFACE_BURNING then
                if m.action == ACT_LAVA_BOOST then
                    set_mario_action(m, ACT_BURNING_GROUND, 0)
                end
                m.health = m.health + 2
            else
                spamInputs = 0
            end
        end
        if spamInputs >= spamInputsRequired then
            m.marioObj.oMarioBurnTimer = 200
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        else
            m.marioObj.oMarioBurnTimer = 0
        end
    else
        spamInputs = 0
        spamInputsRequired = math.random(6, 8)
    end
end

local spamBurnoutFlash = 0

local function hud_spam_burnout(m)
    if (m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP or m.action == ACT_LAVA_BOOST) and m.health > 255 then
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_set_font(FONT_MENU)
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 230, z = m.marioObj.header.gfx.pos.z }
        djui_hud_world_pos_to_screen_pos(pos, out)
        local x = out.x + 20
        local y = out.y - 10
        spamBurnoutFlash = spamBurnoutFlash + 1
        if spamBurnoutFlash > 6 then
            spamBurnoutFlash = 0
        end
        if spamBurnoutFlash > 3 then
            djui_hud_set_color(255, 255, 255, 255)
        else
            djui_hud_set_color(100, 100, 100, 255)
        end
        djui_hud_print_text_interpolated("Z", interpPrev.spamBurnout.x, interpPrev.spamBurnout.y, 0.3, x, y, 0.3)
        interpPrev.spamBurnout.x = x
        interpPrev.spamBurnout.y = y
    end
end

-------------------------
-- Cardboard Functions --
-------------------------

local cloakTimer = 0
local prevHealth = gMarioStates[0].health
local function disappear_update(m)
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

------------------
-- Update Hooks --
------------------

local function mario_update(m)
    if m.playerIndex == 0 then
        local currChar = _G.charSelect.character_get_current_number()
        local currModel = _G.charSelect.character_get_current_table().model
        if currModel ~= E_MODEL_NONE then
            if charTable[currModel] ~= nil and currChar == charTable[currModel].cs then
                gPlayerSyncTable[0].squishyPlayer = charTable[currModel].network
            else
                gPlayerSyncTable[0].squishyPlayer = 0
            end
        end

        -- Coin Deduction 
        if not gPlayerSyncTable[0].lostCoins then
            gPlayerSyncTable[0].lostCoins = 0
        end
        if gPlayerSyncTable[0].lostCoins ~= 0 then
            m.numCoins = m.numCoins - gPlayerSyncTable[0].lostCoins
            gPlayerSyncTable[0].lostCoins = 0
            gPlayerSyncTable[0].numCoins = m.numCoins
            hud_set_value(HUD_DISPLAY_COINS, m.numCoins)
        end

        if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY and menuTable[menuTableRef.moveset].status ~= 0 then
            ledge_parkour(m)
            spam_burnout(m)
        end
    end
end

local function before_mario_update(m)
    if menuTable[menuTableRef.moveset].status == 0 or m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY then
        teching(m)
        momentum_pound(m)
        custom_slide(m)
        more_double_jumps(m)
        explode_on_death(m)
    end

    if gPlayerSyncTable[0].squishyPlayer == NETWORK_CARDBOARD then
        if not gamemode then
            disappear_update(m)
        end
    end
end

local function hud_render()
    local m = gMarioStates[0]
    if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY and menuTable[menuTableRef.moveset].status ~= 0 then
        hud_bubble_timer(m)
        hud_spam_burnout(m)
    end
end

local function on_player_connected(m)
    -- only run on server
    if not network_is_server() then
        return
	end
	for i = 0, (MAX_PLAYERS - 1) do
		if gPlayerSyncTable[i].lostCoins == nil then
			gPlayerSyncTable[i].lostCoins = 0
		end
    end
end

-- Unlock Cardboard Cutout
function on_chat_message(m, msg)
    if m.playerIndex == 0 and string.lower(msg) == "cardboard" and charTable[E_MODEL_CARDBOARD].cs == 0 then
        charTable[E_MODEL_CARDBOARD].cs = _G.charSelect.character_add("Cardboard Cutout", "The Horrors of the Inner Plexus", "Genasaido / SBRP Team", "ff9ef4", E_MODEL_CARDBOARD, nil, nil, 1)
        djui_popup_create('Character Select:\nNew Character Unlocked!\n\\#ff9ef4\\"' .. _G.charSelect.character_get_current_table(charTable[E_MODEL_CARDBOARD].cs).name .. '"', 3)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)