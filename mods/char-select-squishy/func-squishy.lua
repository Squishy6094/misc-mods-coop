
local set_mario_action = set_mario_action
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local math_floor = math.floor
local math_random = math.random
local math_sqrt = math.sqrt
local math_abs = math.abs
local collision_find_surface_on_ray = collision_find_surface_on_ray
local play_character_sound = play_character_sound
local sins = sins
local coss = coss
local camera_freeze = camera_freeze
local camera_unfreeze = camera_unfreeze
local network_player_connected_count = network_player_connected_count
local vec3f_copy = vec3f_copy
local spawn_sync_object = spawn_sync_object
local level_trigger_warp = level_trigger_warp
local mario_set_forward_vel = mario_set_forward_vel
local approach_s32 = approach_s32
local convert_s16 = convert_s16

-----------------------
-- Squishy Functions --
-----------------------

local networkIsSquishy = {}

local comboTable = {}
local comboDisplayTimerMax = 150
local comboKilled = false
local sameComboCount = 0
local comboShakeEffect = 0
local boringComboLines = {
    "Lamee...",
    "Boooorrrinnnggg...",
    "Pack it up one-trick!",
    "Mix it up a bit will ya?",
    '"Building Speed," Sure bud.',
    "Got anything else?",
    "I'm sure you're proud of that one",
    "Wake me up when you're a bit more original"
}
local boringComboLine = ""
local function combo_add(name, points, repetitive, speedFalloff)
    if comboKilled and name ~= "Tech" then return end
    if repetitive == nil then repetitive = 5 end
    if speedFalloff == nil then speedFalloff = 0.95 end
    comboShakeEffect = 0
    
    if name == "Tech" then
        comboKilled = false
        comboShakeEffect = 0
        for i = 1, #comboTable do
            comboTable[i].displayTimer = comboDisplayTimerMax
        end
    end

    if #comboTable > 0 then
        local multiplier = 0
        local falloff = 1
        for i = 1, #comboTable do
            if comboTable[i].name == name then
                multiplier = comboTable[i].multiplier + 1
                if repetitive > 0 and sameComboCount > repetitive then
                    falloff = comboTable[i].speedFalloff * speedFalloff
                end
                table.remove(comboTable, i)
                table.insert(comboTable, 1, {
                    name = name,
                    points = points,
                    displayTimer = comboDisplayTimerMax,
                    multiplier = multiplier,
                    repetitive = repetitive,
                    speedFalloff = falloff,
                })
                if i == 1 then
                    sameComboCount = sameComboCount + 1
                    if sameComboCount%math_max(repetitive*2, 1) == 0 then
                        boringComboLine = boringComboLines[math_random(1, #boringComboLines)]
                    end
                else
                    sameComboCount = 0
                    boringComboLine = boringComboLines[math_random(1, #boringComboLines)]
                end
                return falloff
            end
        end
    end

    table.insert(comboTable, 1, {
        name = name,
        points = points,
        displayTimer = comboDisplayTimerMax,
        multiplier = 1,
        repetitive = repetitive,
        speedFalloff = 1,
    })
    sameComboCount = 0
    return 1
end

local function combo_kill()
    if not comboKilled then 
        comboKilled = true
        comboShakeEffect = 10
        if #comboTable > 0 then
            for i = 1, #comboTable do
                comboTable[i].displayTimer = 20
            end
        end
    end
end

local flipRotateActs = {
    [ACT_SIDE_FLIP] = true
}
local noRotateActs = {
    [ACT_WALL_KICK_AIR] = true,
    [ACT_GRAB_POLE_FAST] = true,
    [ACT_GRAB_POLE_SLOW] = true,
    [ACT_TOP_OF_POLE] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_TOP_OF_POLE_TRANSITION] = true,
    [ACT_CLIMBING_POLE] = true,
    [ACT_HOLDING_POLE] = true,
}

gPlayerSyncTable[0].lostCoins = 0
local deathTimer = 0
local queueCamUnfreeze = false
local isDieing = false

local ledgeTimer = 0
local velStore = 0

local spamInputs = 0
local spamInputsRequired = 10

local wasButtslide = false

local function mario_update(m)
    networkIsSquishy[m.playerIndex] = (gPlayerSyncTable[m.playerIndex].squishyPlayer == NETWORK_SQUISHY)
    if not networkIsSquishy[m.playerIndex] then return end 
    -- Visual Rotation
    local action = m.action
    if action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
        if math_floor(m.floorHeight) < math_floor(m.pos.y) then
            if not noRotateActs[action] then
                m.marioObj.header.gfx.angle.y = m.intendedYaw + (not flipRotateActs[action] and 0 or 0x8000)
            end
        end
    else
        m.marioObj.header.gfx.angle.z = m.controller.stickX*0x80
    end

    -- Local Mario Update
    if m.playerIndex ~= 0 then return end
    local action = m.action
    local prevAction = m.prevAction

    -- Ledge Parkour
    if action == ACT_SOFT_BONK and prevAction == ACT_LEDGE_GRAB then
        if m.controller.buttonDown & Z_TRIG == 0 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            m.forwardVel = 6
        else
            prevAction = ACT_SOFT_BONK
        end
    end

    if (action == ACT_LEDGE_GRAB or action == ACT_LEDGE_CLIMB_FAST) then
        ledgeTimer = ledgeTimer + 1
    else
        ledgeTimer = 0
        velStore = m.forwardVel
    end

    if ledgeTimer <= 5 and velStore >= 25 then
        if action == ACT_LEDGE_CLIMB_FAST and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            set_mario_action(m, ACT_SIDE_FLIP, 0)
            m.vel.y = math_min(velStore*0.8, 40)
            if ledgeTimer == 1 then -- Firstie gives back raw speed
                m.forwardVel = velStore
                combo_add("Ledge Flip Firstie", 300)
            else
                m.forwardVel = velStore * 0.85
                combo_add("Ledge Flip", 250)
            end
        end

        if action == ACT_LEDGE_GRAB and (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
            m.vel.y = -30
            if ledgeTimer == 1 then -- Firstie gives back raw speed
                m.forwardVel = velStore
                combo_add("Ledge Slide Firstie", 300)
            else
                m.forwardVel = velStore * 0.9
                combo_add("Ledge Slide", 250)
            end
        end
    else
        if action == ACT_LEDGE_CLIMB_FAST and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            combo_add("Ledge Rollout", 50)
            m.vel.y = 10
            m.forwardVel = 20
        end

        if action == ACT_LEDGE_GRAB and (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_JUMP_KICK, 0)
            combo_add("Ledge Kick", 50)
            m.vel.y = 20
            m.forwardVel = 10
        end

        if action == ACT_LEDGE_CLIMB_SLOW_1 or action == ACT_LEDGE_CLIMB_SLOW_2 then
            set_mario_action(m, ACT_LEDGE_CLIMB_FAST, 0)
        end
    end

    -- Spam Burnout
    if action == ACT_BURNING_GROUND or action == ACT_BURNING_JUMP or action == ACT_LAVA_BOOST then
        if (m.controller.buttonPressed & Z_TRIG) ~= 0 then
            spamInputs = spamInputs + 1
            m.particleFlags = m.particleFlags | PARTICLE_DUST
            play_sound(SOUND_GENERAL_FLAME_OUT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        end
        if m.pos.y == m.floorHeight or m.wall then
            if m.floor.type ~= SURFACE_BURNING and (m.wall and m.wall.type or 0) ~= SURFACE_BURNING then
                if action == ACT_LAVA_BOOST then
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
            m.faceAngle.y = m.intendedYaw
        else
            m.marioObj.oMarioBurnTimer = 0
        end
    else
        spamInputs = 0
        spamInputsRequired = math_random(6, 8)
    end

    -- Custom Slide
    if action == ACT_BUTT_SLIDE then
        if prevAction == ACT_GROUND_POUND or prevAction == ACT_GROUND_POUND_LAND then
            m.faceAngle.y = m.floorAngle
        end
        set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
        wasButtslide = true
    end

    if action == ACT_FORWARD_ROLLOUT and prevAction == ACT_SLIDE_KICK_SLIDE and wasButtslide then
        set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        m.vel.y = math_max(m.forwardVel, 40)
        m.forwardVel = m.forwardVel*0.5
        wasButtslide = false
    end

    if (action == ACT_PUNCHING and prevAction == ACT_CROUCHING) or ((action == ACT_MOVE_PUNCHING or action == ACT_SLIDE_KICK) and prevAction == ACT_CROUCH_SLIDE) then
        set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
        m.vel.y = -30
        local speed = math_max(60, m.forwardVel*1.3)*combo_add("Quick Slide", 50, 3, 0.9)
        m.slideVelX = sins(m.faceAngle.y)*speed
        m.slideVelZ = coss(m.faceAngle.y)*speed
    end
end

local doubleJumpTable = {
    [ACT_LONG_JUMP_LAND] = true,
    [ACT_FREEFALL_LAND_STOP] = true,
}

local bonkActs = {
    [ACT_GROUND_BONK] = true,
    [ACT_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_FORWARD_GROUND_KB] = true,
    [ACT_FORWARD_GROUND_KB] = true,
    [ACT_DEATH_EXIT] = true,
    [ACT_UNUSED_DEATH_EXIT] = true,
    [ACT_FALLING_DEATH_EXIT] = true,
    [ACT_SPECIAL_DEATH_EXIT] = true,
    [ACT_DEATH_EXIT_LAND] = true,
    [ACT_FORWARD_AIR_KB] = true,
    [ACT_BACKWARD_AIR_KB] = true,
    [ACT_HARD_FORWARD_AIR_KB] = true,
    [ACT_HARD_BACKWARD_AIR_KB] = true,
  
}

local tech = true
local techTimer = 10
local activeVel = 0

local groundTimer = 0
local airVel = 0
local prevPos = {x = 0, y = 0, z = 0}
local posStillCount = 0
local prevFrameAction = 0
local prevForwardVel = 0

local prevCancelCount = -1
local cancelCount = 0
local anglemath = 0
local prevVel = {}
local prevAngle = nil
local slideTimer = 0

local actDieing = {
    [ACT_DEATH_ON_BACK] = true,
    [ACT_DEATH_ON_STOMACH] = true,
    [ACT_WATER_DEATH] = true,
    [ACT_DROWNING] = true,
    [ACT_STANDING_DEATH] = true,
    [ACT_QUICKSAND_DEATH] = true,
}

local function before_mario_update(m)
    if not networkIsSquishy[m.playerIndex] then return end 

    if m.playerIndex ~= 0 then return end
    local action = m.action
    local prevAction = m.prevAction

    -- Misc Physics Changes 
    m.peakHeight = m.pos.y
    if action == ACT_TRIPLE_JUMP_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 then
        set_mario_action(m, ACT_JUMP, 0)
    end
    if action == ACT_TRIPLE_JUMP and prevFrameAction ~= ACT_TRIPLE_JUMP then
        m.vel.y = math_max(70, airVel*0.8)
        prevFrameAction = action
    end

    if action == ACT_START_CROUCHING then
        set_mario_action(m, ACT_CROUCHING, 0)
    end
    if action == ACT_STOP_CROUCHING then
        set_mario_action(m, ACT_IDLE, 0)
    end

    if action == ACT_JUMP then
        m.vel.y = math_min(m.vel.y, 60)
    end
    if action == ACT_DOUBLE_JUMP then
        m.vel.y = math_min(m.vel.y, 80)
    end

    if action == ACT_DIVE and m.controller.buttonPressed & Z_TRIG ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
        m.vel.y = -100
        combo_add("Dive Cancel", 50)
    end

    -- Air Acceleration (Air Vel Handler)
    if action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
        if math_floor(m.floorHeight) == math_floor(m.pos.y) and action ~= ACT_SLIDE_KICK then
            groundTimer = groundTimer + 1
            if groundTimer < 5 then
                m.faceAngle.y = m.intendedYaw
            end
        else
            groundTimer = 0
            if m.controller.stickMag > 20 and math_abs(m.forwardVel) > 10 and not bonkActs[action] and m.forwardVel > 0 then
                if m.forwardVel > 0 then
                    airVel = math_max(prevForwardVel + 0.05, m.forwardVel)
                end
                prevForwardVel = math_max(m.forwardVel, prevForwardVel)
                m.forwardVel = airVel
            else
                airVel = 0
                prevForwardVel = 0
            end
        end

        --B-Hop Mode
        if (action == ACT_JUMP_LAND or action == ACT_FREEFALL_LAND_STOP) and m.controller.buttonDown & Z_TRIG ~= 0 and m.controller.buttonDown & A_BUTTON ~= 0 and m.floor.type ~= SURFACE_BURNING then
            set_mario_action(m, ACT_JUMP, 0)
            local angle = m.faceAngle.y
            local ray = collision_find_surface_on_ray(m.pos.x + sins(angle), m.pos.y + 150, m.pos.z + coss(angle), 0, -300, 0)
            local floorHeightOffset = 0
            if ray then
                floorHeightOffset = m.floorHeight - ray.hitPos.y
            end
            mario_set_forward_vel(m, airVel*0.5 + (airVel*0.5 + 3)*combo_add("B-hop", 10, 10, 0.9))
            prevForwardVel = m.forwardVel
            airVel = m.forwardVel
            m.vel.y = 40 + math_abs(m.forwardVel*0.5)*-floorHeightOffset
        end

        if action == ACT_SLIDE_KICK_SLIDE then
            m.slideVelX = m.slideVelX
            m.slideVelZ = m.slideVelZ
        end

        if doubleJumpTable[action] or (doubleJumpTable[prevAction] and prevFrameAction ~= action) and m.floor.type ~= SURFACE_BURNING then
            if m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
            end
        end
        
        if prevPos.x == m.pos.x and prevPos.y == m.pos.y and prevPos.z == m.pos.z then
            posStillCount = posStillCount + 1
        else
            posStillCount = 0
        end

        if posStillCount > 5 then
            m.forwardVel = 0
            airVel = 0
            prevForwardVel = 0
        end

        prevPos.x = m.pos.x
        prevPos.y = m.pos.y
        prevPos.z = m.pos.z

        prevFrameAction = action
    end

    -- Teching
    if m.forwardVel ~= 0 then
        activeVel = m.forwardVel
    end
    local angle = m.faceAngle.y + (activeVel > 0 and 0 or 0x8000)
    local wall = collision_find_surface_on_ray(m.pos.x, m.pos.y, m.pos.z, sins(angle)*115, 0, coss(angle)*115)
    if m.health > 255 then
        if (wall and wall.surface) or m.pos.y == m.floorHeight then
            techTimer = techTimer - 1
            if bonkActs[action] then
                combo_kill()
                if (m.controller.buttonPressed & Z_TRIG) ~= 0 and techTimer > 0 then
                    if (wall and wall.surface) and m.pos.y ~= m.floorHeight then
                        m.faceAngle.y = m.faceAngle.y + 0x8000
                        m.forwardVel = 20
                    end
                    if activeVel > 0 then
                        set_mario_action(m, ACT_FORWARD_ROLLOUT, 1)
                    else
                        set_mario_action(m, ACT_BACKWARD_ROLLOUT, 1)
                    end
                    combo_add("Tech", 50, 0)
                    play_character_sound(m, CHAR_SOUND_UH2)
                    m.vel.y = 21
                    m.particleFlags = m.particleFlags | ACTIVE_PARTICLE_SPARKLES
                    m.invincTimer = 20
                    techTimer = 10
                else
                    techTimer = 10
                end
            end
        end
    end

    -- Momentum Pound
    if (action == ACT_GROUND_POUND or action == ACT_GROUND_POUND_LAND) and m.controller.stickMag > 20 and m.vel.x == 0 then
        m.vel.x = prevVel.x
        m.vel.z = prevVel.z
    elseif m.forwardVel ~= 0 then
        prevVel.x = m.vel.x 
        prevVel.y = m.vel.y 
        prevVel.z = m.vel.z 
    end
    if action == ACT_GROUND_POUND then
        m.vel.y = -100
        m.faceAngle.y = m.intendedYaw
        if m.controller.buttonPressed & A_BUTTON ~= 0 and (cancelCount == 0 or prevAction == ACT_WALL_KICK_AIR) and m.pos.y > m.floorHeight + 50 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            combo_add("Pound Cancel", 25, 0, 1)
            m.particleFlags = PARTICLE_DUST
            local speed = math_sqrt(prevVel.x^2 + prevVel.z^2)*1
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = math_max(speed, 20)
            cancelCount = cancelCount + 1
            m.vel.y = speed*0.3
        end
    end
    --[[
    if m.wall ~= nil and action ~= ACT_TRIPLE_JUMP and (action == ACT_GROUND_POUND or (action ~= ACT_FREEFALL and prevAction == ACT_GROUND_POUND)) then
        anglemath = atan2s(m.wall.normal.z, m.wall.normal.x)
        m.faceAngle.y = anglemath
        m.forwardVel = math_min(math_sqrt(prevVel.x^2 + prevVel.z^2)*2, 100)
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
        m.vel.y = math_min(math_sqrt(prevVel.x^2 + prevVel.z^2)*2, 100)
        if prevAngle ~= anglemath then
            cancelCount = 0
            prevAngle = anglemath
        end
    end
    ]]
    if action == ACT_WALL_KICK_AIR and prevCancelCount ~= cancelCount then
        prevCancelCount = cancelCount
        m.vel.y = -(cancelCount - 7) * 10
    end
    if (cancelCount > 0 or prevAngle == anglemath) and m.pos.y == m.floorHeight then
        prevCancelCount = -1
        cancelCount = 0
        prevAngle = nil
    end

    if action == ACT_GROUND_POUND_LAND or (action == ACT_BUTT_SLIDE and prevAction == ACT_GROUND_POUND_LAND) then
        if m.controller.stickMag > 20 then
            if m.floor.type ~= SURFACE_BURNING then
                set_mario_action(m, ACT_SLIDE_KICK, 0)
                m.forwardVel = math_sqrt(prevVel.x^2 + prevVel.z^2)*1.1*combo_add("Pound Slide", 100, 3, 0.8)
                m.slideYaw = m.intendedYaw
                m.vel.y = -30
            else
                combo_add("Lava Pound", 250)
                m.forwardVel = 0
                m.hurtCounter = 8
                m.vel.y = math_sqrt(prevVel.x^2 + prevVel.z^2)*3
            end
            m.faceAngle.y = m.intendedYaw
        else
            set_mario_action(m, ACT_BACKWARD_ROLLOUT, 0)
            m.forwardVel = 0
            m.faceAngle.y = m.intendedYaw
        end
        m.flags = m.flags | INT_GROUND_POUND_OR_TWIRL
    end

    if action == ACT_BACKWARD_ROLLOUT and prevAction == ACT_GROUND_POUND_LAND and m.controller.buttonPressed & Z_TRIG ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
    end

    -- Explode on Death
    if m.health > 255 then
        deathTimer = 0
        if queueCamUnfreeze then
            queueCamUnfreeze = false
            camera_unfreeze()
        end
        if isDieing then
            isDieing = false
            if gamemode and not actDieing[m.action] then
                _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, nil, nil, nil, nil, E_MODEL_SQUISHY)
            end
        end
        if actDieing[m.action] then
            level_trigger_warp(m, WARP_OP_DEATH)
            isDieing = true
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
            if deathTimer > 30 or m.pos.y <= m.floorHeight + 10 or (action == ACT_LAVA_BOOST and m.vel.y <= 10) then
                local coinsLost = 0
                for i = 1, math_ceil(m.numCoins*0.25) do
                    if m.numCoins > 0 then
                        local velY = 30 + math_max(m.vel.y, 5)
                        local randAngle = m.faceAngle.y + math_random(-0x2000, 0x2000)
                        local randSpeed = m.forwardVel * math_random(10, 30)*0.05
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
                    _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, nil, nil, nil, nil, E_MODEL_NONE)
                end
                isDieing = true
            end
        else
            if action == ACT_BUBBLED then
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

local speedcap = 125
--[[
if gamemode then
    speedcap = 90
end
]]
local function before_phys_step(m)
    if not networkIsSquishy[m.playerIndex] then return end 
    -- Remove Ground Cap
    
    local action = m.action
    local prevAction = m.prevAction
    if action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
        if math_floor(m.floorHeight) == math_floor(m.pos.y) then
            mario_set_forward_vel(m, math_max(airVel, m.forwardVel))
            if action ~= ACT_SLIDE_KICK_SLIDE then
                airVel = airVel - 1
                prevForwardVel = m.forwardVel
            else
                m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x500, 0x500)
                airVel = airVel - 0.1
            end
        else
            if m.forwardVel > 0 then
                m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
            end
        end
    else
        if action & ACT_FLAG_SWIMMING then
            m.faceAngle.y = m.faceAngle.y - m.controller.stickX*0x10
            if m.controller.buttonDown & A_BUTTON ~= 0 and airVel > 30 then
                airVel = airVel - 0.1
                set_mario_animation(m, MARIO_ANIM_SWIM_PART2)
            else
                airVel = math_max(airVel - 3, 0)
            end
            mario_set_forward_vel(m, math_max(airVel, m.forwardVel))
        else
            m.faceAngle.y = m.faceAngle.y - m.controller.stickX*0x10
            m.faceAngle.z = m.faceAngle.z - m.controller.stickY*0x10
            airVel = airVel - 1
            mario_set_forward_vel(m, math_max(airVel, m.forwardVel))
        end
    end
    
    -- Hard Speed Cap
    m.forwardVel = math_min(m.forwardVel, speedcap)
    airVel = math_min(airVel, speedcap)
    prevForwardVel = math_min(prevForwardVel, speedcap)
end

local MATH_DIVIDE_300 = 1/300
local spamBurnoutFlash = 0

local prevAlt = 0
local squishyAltCostumes = {
    {
        name = "Squishy",
        credit = "Trashcam / Squishy",
        desc = "Squishy T. Server",
        model = E_MODEL_SQUISHY
    },
    {
        name = "Classic Squishy",
        credit = "Trashcam / Squishy",
        desc = "Pre-Estrogen",
        model = E_MODEL_SQUISHY_CLASSIC
    },
    {
        name = "Paper Squishy",
        credit = "so2007nic / Squishy",
        desc = "SBRP Moment",
        model = E_MODEL_SQUISHY_PAPER
    },
}

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

local pointCache = 0
local function on_hud_render()
    if not networkIsSquishy[0] then return end 
    -- Death Bubble Render
    if action == ACT_BUBBLED and deathTimer < 300 then
        djui_hud_set_resolution(RESOLUTION_N64)
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 230, z = m.marioObj.header.gfx.pos.z }
        djui_hud_world_pos_to_screen_pos(pos, out)
        local x = out.x - 20
        local y = out.y - 3
        local meter = deathTimer*MATH_DIVIDE_300
        local randX = math_random(-deathTimer, deathTimer)*0.01
        local randY = math_random(-deathTimer, deathTimer)*0.01
        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_render_rect_interpolated(interpPrev.bubbleExplode.x, interpPrev.bubbleExplode.y, 40, 6, x + randX, y + randY, 40, 6)
        djui_hud_set_color(255, 0, 0, 200)
        djui_hud_render_rect_interpolated(interpPrev.bubbleExplode.x + 1, interpPrev.bubbleExplode.y + 1, 38 - 38*interpPrev.bubbleExplode.meter, 4, x + randX + 1, y + randY + 1, 38 - 38*meter, 4)
        interpPrev.bubbleExplode.x = x
        interpPrev.bubbleExplode.y = y
        interpPrev.bubbleExplode.meter = meter
    end

    -- Spam Burnout
    if (action == ACT_BURNING_GROUND or action == ACT_BURNING_JUMP or action == ACT_LAVA_BOOST) and m.health > 255 then
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

    -- Alt Custom Update
    if prevAlt ~= menuTable[menuTableRef.costume].status then
        local alt = squishyAltCostumes[menuTable[menuTableRef.costume].status + 1]
        _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, alt.name, alt.desc, alt.credit, nil, alt.model)
        prevAlt = menuTable[menuTableRef.costume].status
    end

    -- Hud Combo System
    if #comboTable == 0 then
        pointCache = 0
        comboKilled = false
        return
    end
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_MENU)
    local width = djui_hud_get_screen_width()
    local points = 0
    local stringOffset = 0
    local repetitive = 0
    for i = 1, #comboTable do
        local currCombo = comboTable[i]
        if currCombo ~= nil then
            djui_hud_set_color(255, (not comboKilled and 255 or 100), (not comboKilled and 255 or 100), math.min(20, currCombo.displayTimer)*12.25)
            local string = currCombo.name..(currCombo.multiplier > 1 and " x"..currCombo.multiplier or "").." - "..currCombo.points*currCombo.multiplier
            local comboShakeX = 0
            local comboShakeY = 0
            if comboShakeEffect > 0 then
                comboShakeX = math_random(-comboShakeEffect, comboShakeEffect)*0.5
                comboShakeY = math_random(-comboShakeEffect, comboShakeEffect)*0.5
            end
            currCombo.displayTimer = currCombo.displayTimer - 1
            if currCombo.displayTimer < 0 then
                local pointCacheLocal = currCombo.points*currCombo.multiplier
                table.remove(comboTable, i)
                pointCache = pointCache + pointCacheLocal
            else
                points = points + currCombo.points * currCombo.multiplier
            end
            if i == 1 then
                stringOffset = djui_hud_measure_text(string)*0.3
                repetitive = currCombo.repetitive
            end
            djui_hud_print_text(string, width - djui_hud_measure_text(string)*0.3 - 10 + comboShakeX, 230 - (i*15) - math.max(0, currCombo.displayTimer - (comboDisplayTimerMax - 2))*2 + comboShakeY, 0.3)
        end
    end
    points = math.max(points, points + pointCache)
    comboShakeEffect = math_max(comboShakeEffect - 1, 0)
    stringOffset = stringOffset + djui_hud_measure_text(tostring(points))*0.3
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(tostring(points), width - stringOffset - 30, 215, 0.3)
    if repetitive > 0 and sameComboCount > repetitive then
        djui_hud_set_color(255, 100, 100, 255)
        djui_hud_print_text(boringComboLine, width - djui_hud_measure_text(boringComboLine)*0.2 - 10, 230 - 15, 0.2)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render)