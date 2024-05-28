
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

-----------------------
-- Squishy Functions --
-----------------------

local ledgeTimer = 0
local velStore = 0
function ledge_parkour(m)
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
            m.vel.y = math_min(velStore*0.8, 40)
            if ledgeTimer == 1 then -- Firstie gives back raw speed
                m.forwardVel = velStore
            else
                m.forwardVel = velStore * 0.85
            end
        end

        if m.action == ACT_LEDGE_GRAB and (m.controller.buttonPressed & B_BUTTON) ~= 0 then
            set_mario_action(m, ACT_SLIDE_KICK, 0)
            m.vel.y = math_min(velStore*0.2, 20)
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

local techActs = {
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
function teching(m)
    if m.forwardVel ~= 0 then
        activeVel = m.forwardVel
    end
    local angle = m.faceAngle.y + (activeVel > 0 and 0 or 0x8000)
    local wall = collision_find_surface_on_ray(m.pos.x, m.pos.y, m.pos.z, sins(angle)*115, 0, coss(angle)*115)
    if m.health > 255 then
        if (wall and wall.surface) or m.pos.y == m.floorHeight then
            techTimer = techTimer - 1
            if techActs[m.action] and (m.controller.buttonPressed & Z_TRIG) ~= 0 and techTimer > 0 then
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
local slideTimer = 0
function momentum_pound(m)
    if (m.action == ACT_GROUND_POUND or m.action == ACT_GROUND_POUND_LAND) and m.controller.stickMag > 20 and m.vel.x == 0 then
        m.vel.x = prevVel.x
        m.vel.z = prevVel.z
    elseif m.forwardVel ~= 0 then
        prevVel.x = m.vel.x 
        prevVel.y = m.vel.y 
        prevVel.z = m.vel.z 
    end
    if m.action == ACT_GROUND_POUND then
        m.vel.y = -100
        m.peakHeight = m.pos.y
        if m.controller.buttonPressed & A_BUTTON ~= 0 and (cancelCount == 0 or m.prevAction == ACT_WALL_KICK_AIR) and m.pos.y > m.floorHeight + 50 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
            m.particleFlags = PARTICLE_DUST
            local speed = math_sqrt(prevVel.x^2 + prevVel.z^2)*1
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = math_max(speed, 20)
            cancelCount = cancelCount + 1
            m.vel.y = speed*0.3
        end
    end
    --[[
    if m.wall ~= nil and m.action ~= ACT_TRIPLE_JUMP and (m.action == ACT_GROUND_POUND or (m.action ~= ACT_FREEFALL and m.prevAction == ACT_GROUND_POUND)) then
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
                if m.action == ACT_BUTT_SLIDE then
                    m.slideVelX = prevVel.x
                    m.slideVelZ = prevVel.z
                    set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
                else
                    set_mario_action(m, ACT_SLIDE_KICK, 0)
                end
            else
                set_mario_action(m, ACT_LAVA_BOOST, 0)
                m.hurtCounter = 12
                m.vel.y = 90
            end
            m.faceAngle.y = m.intendedYaw
            m.forwardVel = math_sqrt(prevVel.x^2 + prevVel.z^2)*1.1
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

    if m.action == ACT_SLIDE_KICK and m.pos.y < m.floorHeight + 5 then
        if slideTimer > 0 then
            set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        end
        slideTimer = slideTimer + 1
    else
        slideTimer = 0
    end
end

local wasButtslide = false
function custom_slide(m)
    if m.action == ACT_BUTT_SLIDE then
        if m.prevAction == ACT_GROUND_POUND or m.prevAction == ACT_GROUND_POUND_LAND then
            m.faceAngle.y = m.floorAngle
        end
        set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
        wasButtslide = true
    end

    if m.action == ACT_FORWARD_ROLLOUT and m.prevAction == ACT_SLIDE_KICK_SLIDE and wasButtslide then
        set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        m.vel.y = math_max(m.forwardVel, 40)
        m.forwardVel = m.forwardVel*0.8
        wasButtslide = false
    elseif m.action ~= ACT_SLIDE_KICK_SLIDE then
        wasButtslide = false
    end

    if (m.action == ACT_PUNCHING and m.prevAction == ACT_CROUCHING) or ((m.action == ACT_MOVE_PUNCHING or m.action == ACT_SLIDE_KICK) and m.prevAction == ACT_CROUCH_SLIDE) then
        set_mario_action(m, ACT_SLIDE_KICK_SLIDE, 0)
        m.vel.y = -30
        local speed = math_max(50, m.forwardVel)
        m.slideVelX = sins(m.faceAngle.y)*speed
        m.slideVelZ = coss(m.faceAngle.y)*speed
    end
end

gPlayerSyncTable[0].lostCoins = 0
local deathTimer = 0
local queueCamUnfreeze = false
local isDieing = false
function explode_on_death(m)
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
    [ACT_LONG_JUMP_LAND] = true,
    [ACT_FREEFALL_LAND_STOP] = true,
}

local prevAction = 0
local prevForwardVel = 0
local groundTimer = 0
local airVel = 0
function misc_phys_changes(m)
    if m.action == ACT_TRIPLE_JUMP_LAND and m.controller.buttonPressed & A_BUTTON ~= 0 then
        set_mario_action(m, ACT_JUMP, 0)
    end

    if m.action == ACT_JUMP then
        m.vel.y = math_min(m.vel.y, 60)
    end
    if m.action == ACT_DOUBLE_JUMP then
        m.vel.y = math_min(m.vel.y, 80)
    end

    --B-Hop Mode
    if (m.action == ACT_JUMP_LAND or m.action == ACT_FREEFALL_LAND_STOP) and m.controller.buttonDown & Z_TRIG ~= 0 and m.controller.buttonDown & A_BUTTON ~= 0 and m.floor.type ~= SURFACE_BURNING then
        set_mario_action(m, ACT_JUMP, 0)
        m.vel.y = 40
        m.forwardVel = m.forwardVel + 10
        groundTimer = groundTimer + 2
    end

    -- Air Acceleration
    if math_floor(m.floorHeight) == math_floor(m.pos.y) and m.action ~= ACT_SLIDE_KICK then
        groundTimer = groundTimer + 1
        if groundTimer < 15 then
            m.faceAngle.y = m.intendedYaw
        end
    else
        groundTimer = 0
        if m.controller.stickMag > 20 and math_abs(m.forwardVel) > 10 and not techActs[m.action] then
            airVel = math_max(prevForwardVel + 0.05, m.forwardVel)
            prevForwardVel = math_max(m.forwardVel, prevForwardVel)
            m.forwardVel = airVel
        else
            airVel = 0
            prevForwardVel = 0
        end
    end

    if m.action == ACT_SLIDE_KICK_SLIDE then
        m.slideVelX = m.slideVelX - 1
        m.slideVelZ = m.slideVelZ - 1
    end

    if doubleJumpTable[m.action] or (doubleJumpTable[m.prevAction] and prevAction ~= m.action) then
        if m.controller.buttonPressed & A_BUTTON ~= 0 and m.controller.buttonDown & Z_TRIG == 0 then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
        end
    end
    prevAction = m.action

end

function remove_ground_cap(m)
    if math_floor(m.floorHeight) == math_floor(m.pos.y) then
        mario_set_forward_vel(m, math_max(airVel, m.forwardVel))
        if m.action ~= ACT_SLIDE_KICK_SLIDE then
            airVel = airVel - 1
            prevForwardVel = m.forwardVel
        else
            m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x500, 0x500)
            airVel = airVel - 0.1
        end
    end
    
    -- Hard Speed Cap
    m.forwardVel = math_min(m.forwardVel, 150)
    airVel = math_min(airVel, 150)
    prevForwardVel = math_min(prevForwardVel, 150)
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
function trick_system(m)
    if math_floor(m.floorHeight) < math_floor(m.pos.y) then
        if not noRotateActs[m.action] then
            m.marioObj.header.gfx.angle.y = m.intendedYaw + (not flipRotateActs[m.action] and 0 or 0x8000)
        end
        m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
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

function hud_bubble_timer(m)
    if m.action == ACT_BUBBLED and deathTimer < 300 then
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
end

local spamInputs = 0
local spamInputsRequired = 10
function spam_burnout(m)
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
        spamInputsRequired = math_random(6, 8)
    end
end

local spamBurnoutFlash = 0

function hud_spam_burnout(m)
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