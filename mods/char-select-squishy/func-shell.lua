
local breakdanceTimer = 0
local prevAction = 0
local function misc_phys_changes(m)

    m.vel.y = m.vel.y + 1

    if m.action == ACT_SLIDE_KICK and prevAction ~= ACT_SLIDE_KICK then
        m.vel.y = 10
        mario_set_forward_vel(m, 70)
        set_mario_animation(m, MARIO_ANIM_BREAKDANCE)
        --djui_chat_message_create("pretty lady is functioning")
    end

    if m.action == ACT_SLIDE_KICK_SLIDE then
        --set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
    end

    if m.action == ACT_CROUCHING and m.prevAction == ACT_PUNCHING and m.controller.buttonDown & Z_TRIG ~= 0 then
        breakdanceTimer = breakdanceTimer + 1
        if breakdanceTimer > 1 then
            set_mario_action(m, ACT_PUNCHING, 9)
            breakdanceTimer = 0
        end
    end
    prevAction = m.action
end

local twirlBoost = true
local function air_jumps(m)
    if m.action == ACT_JUMP_LAND or m.action == ACT_FREEFALL_LAND then
        set_mario_action(m, ACT_FREEFALL_LAND_STOP, 0)
    end

    if m.action == ACT_JUMP or m.action == ACT_SIDE_FLIP then
        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
            mario_set_forward_vel(m, math.abs(m.forwardVel*1.1)) 
            m.faceAngle.y = m.intendedYaw
            m.vel.y = 50
        end
    end

    if prevAction == ACT_DOUBLE_JUMP or prevAction == ACT_WALL_KICK_AIR or prevAction == ACT_DIVE then
        if m.vel.y > 0 then
            m.particleFlags = PARTICLE_DUST
        end
        if m.controller.buttonPressed & A_BUTTON ~= 0 then
            set_mario_action(m, ACT_TWIRLING, 0)
            m.vel.y = 40
        end
    end


    if prevAction == ACT_TWIRLING then
        m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
        if m.vel.y > -10 then
            if twirlBoost then
                m.vel.y = m.vel.y + 1
            else
                m.vel.y = m.vel.y - 3
            end
            if m.vel.y < 0 then
                set_mario_action(m, ACT_FREEFALL, 0)
                twirlBoost = false
            end
        else
            m.vel.y = -75
        end
    end 
    if m.pos.y <= m.floorHeight then
        twirlBoost = true
    end
    
    if m.action == ACT_GROUND_POUND then
        set_mario_action(m, ACT_TWIRLING, 0)
        m.vel.y = -75
    end

    if m.action == ACT_TWIRL_LAND then
        set_mario_action(m, ACT_GROUND_POUND_LAND, 0)
    end
end

movesetFunctions[NETWORK_SHELL] = {
    mario_update_local = function (m)
        --ledge_parkour(m)
        --spam_burnout(m)
    end,
    mario_update = function (m)
        --visual_rotation(m)
    end,
    before_mario_update = function (m)
        misc_phys_changes(m)
        air_jumps(m)
        --teching(m)
        --momentum_pound(m)
        --custom_slide(m)
        --explode_on_death(m)
    end,
    before_phys_step = function (m)
        --remove_ground_cap(m)
    end,
    hud_render = function (m)
        --hud_bubble_timer(m)
        --hud_spam_burnout(m)
        --hud_combo_system()
        --alt_custom_update()
    end
}