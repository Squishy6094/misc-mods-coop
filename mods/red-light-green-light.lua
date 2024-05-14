-- name: \\#ff7777\\Red Light\\#dcdcdc\\/\\#77ff77\\Green Light\\#dcdcdc\\
-- description: \\#ff7777\\Red Light\\#dcdcdc\\/\\#77ff77\\Green Light\n\\#ffff77\\( Gamemode/Add-on )\n\n\\#dcdcdc\\The classic game played between childhood friends addapted to\nwork in Super Mario 64, featuring a\nmultitute of Host and User options toggleable via \\#ffff33\\/rlgl\\#dcdcdc\\\n\n\Remake by: \\#008800\\Squishy 6094\n\\#dcdcdc\\Original Mod by: \\#880000\\GroovyBeardLover
local warning = false
gGlobalSyncTable.timer = math.random(1, 30) * 30
gGlobalSyncTable.light = true
gGlobalSyncTable.redlightgreenlight = 1
local localredlightgreenlight = 1
gGlobalSyncTable.redlightmode = 2
gGlobalSyncTable.triggermode = 0
gGlobalSyncTable.mhLights = 0

local menu = false
local currOption = 1

local optionTableRef = {
    gamemode = 1,
    redlightmode = 2,
    triggermode = 3,
    lighttext = 4,
    colorblind = 5,
    vignette = 6,
    mhLights = nil
}

local optionTable = {
    [optionTableRef.gamemode] = {
        name = "Gamemode",
        hostOnly = true,
        toggleDefault = 1,
        toggleMax = 1,
        toggleDesc = {"Red Light/Green Light is Inactive", "Red Light/Green Light is Active"}
    },
    [optionTableRef.redlightmode] = {
        name = "Red Light Mode",
        toggle = tonumber(mod_storage_load("redlightmode")),
        toggleSaveName = "redlightmode",
        hostOnly = true,
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"Instakill", "Poison", "Lockout"},
        toggleDesc = {"Kills you if you move", "Drains Health if you move", "Locks your inputs if it's Red Light"}
    },
    [optionTableRef.triggermode] = {
        name = "Trigger Mode",
        hostOnly = true,
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"Auto", "Host"},
        toggleDesc = {"Light is Automated", "Light is switched by Host (L Button)"}
    },
    [optionTableRef.lighttext] = {
        name = "Light Text",
        toggle = tonumber(mod_storage_load("lighttext")),
        toggleSaveName = "lighttext",
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"Status", "Mode", "Lockout"},
        toggleDesc = {"Shows the Light Status", "Shows the current Red Light Mode",}
    },
    [optionTableRef.colorblind] = {
        name = "Colorblind Mode",
        toggle = tonumber(mod_storage_load("colorblind")),
        toggleSaveName = "colorblind",
        toggleDefault = 0,
        toggleMax = 1,
        toggleDesc = {"Colors display normally", "Greens are brighter, Reds are Darker",}
    },
    [optionTableRef.vignette] = {
        name = "Vignette",
        toggle = tonumber(mod_storage_load("vignette")),
        toggleSaveName = "vignette",
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"Off", "Faint", "Strong"},
        toggleDesc = {"No color shows on sides", "Current Light shows faintly on sides", "Current Light shows strongly on sides"}
    },
}

local function failsafe_options()
    for i = 1, #optionTable do
        if optionTable[i].toggle == nil or optionTable[i].toggle == "" then
            optionTable[i].toggle = optionTable[i].toggleDefault
            if optionTable[i].toggleSaveName ~= nil then
                mod_storage_save(optionTable[i].toggleSaveName, tostring(optionTable[i].toggle))
            end
        end
        if optionTable[i].toggleNames == nil then
            optionTable[i].toggleNames = {"Off", "On"}
        end
        if optionTable[i].hostOnly then
            if i == optionTableRef.redlightmode then
                gGlobalSyncTable.redlightmode = optionTable[i].toggle
            end
        end
    end
end

failsafe_options()

local timer = -1
local timerEnd = -2
local timerWarning = 31
local cooldownTimer = 0
local cooldownTimerStart = 150

-- Network Timer
local connectedIndex = 0
function server_update()
    if gGlobalSyncTable.redlightgreenlight ~= 1 then return end
    if network_is_server() then
        if timer == nil or timer < timerEnd then
            timer = math.random(3, 30) * 30
            timerEnd = math.random(3, 7) * -30
            local data = {
                timerStart = timer,
            }
            network_send(true, data)
        end
    end
    if gGlobalSyncTable.triggermode ~= 1 then
        if timer ~= nil then
            timer = timer - 1
        end
    else
        if timer > -1 and timer < timerWarning then
            timer = timer - 1
        end
        timerEnd = -2
    end

    if connectedIndex ~= 0 and gPlayerSyncTable[connectedIndex].isUpdating then
        connectedIndex = 0
        local data = {
            timerStart = timer,
        }
        network_send(true, data)
    end
end

local function on_packet_receive(data)
    timer = data.timerStart
end

local function on_connect(m)
    connectedIndex = m.playerIndex
end

local SafeActs = {
    [ACT_WARP_DOOR_SPAWN] = true,
    [ACT_PULLING_DOOR] = true,
    [ACT_PUSHING_DOOR] = true,
    [ACT_ENTERING_STAR_DOOR] = true,
    [ACT_UNLOCKING_KEY_DOOR] = true,
    [ACT_UNLOCKING_STAR_DOOR] = true,
    [ACT_DEATH_EXIT] = true,
    [ACT_DEATH_EXIT_LAND] = true,
    [ACT_FALLING_DEATH_EXIT] = true,
    [ACT_SPECIAL_DEATH_EXIT] = true,
    [ACT_UNUSED_DEATH_EXIT] = true,
    [ACT_SPAWN_NO_SPIN_AIRBORNE] = true,
    [ACT_SPAWN_NO_SPIN_LANDING] = true,
    [ACT_SPAWN_SPIN_AIRBORNE] = true,
    [ACT_SPAWN_SPIN_LANDING] = true,
    [ACT_WARP_DOOR_SPAWN] = true,
    [ACT_READING_AUTOMATIC_DIALOG] = true,
    [ACT_READING_NPC_DIALOG] = true,
    [ACT_STAR_DANCE_EXIT] = true,
    [ACT_STAR_DANCE_NO_EXIT] = true,
    [ACT_STAR_DANCE_WATER] = true,
    [ACT_IDLE] = true,
    [ACT_FIRST_PERSON] = true,
    [ACT_CROUCHING] = true,
    [ACT_CROUCH_SLIDE] = true,
    [ACT_CRAWLING] = true,

    -- Never safe
    [ACT_HOLDING_BOWSER] = false,
    [ACT_CLIMBING_POLE] = false,
}

local actNoFreeze = {
    [ACT_HOLD_IDLE] = true,
    [ACT_HOLD_WALKING] = true,
    [ACT_HOLD_FREEFALL] = true,
    [ACT_HOLD_BUTT_SLIDE] = true,
    [ACT_HOLD_BEGIN_SLIDING] = true,
    [ACT_HOLD_BUTT_SLIDE] = true,
    [ACT_HOLD_HEAVY_IDLE] = true,
    [ACT_HOLD_HEAVY_WALKING] = true,
    [ACT_GRABBED] = true,
    [ACT_LEDGE_GRAB] = true,
    [ACT_GROUND_BONK] = true,
    [ACT_GROUND_POUND_LAND] = true,
    [ACT_FORWARD_GROUND_KB] = true,
    [ACT_HARD_FORWARD_GROUND_KB] = true,
    [ACT_SOFT_FORWARD_GROUND_KB] = true,
    [ACT_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_BACKWARD_GROUND_KB] = true,
    [ACT_SOFT_BACKWARD_GROUND_KB] = true,
    [ACT_SQUISHED] = true,
    [ACT_PICKING_UP_BOWSER] = true,
    [ACT_HOLDING_BOWSER] = true,
    [ACT_RELEASING_BOWSER] = true,
    [ACT_BURNING_FALL] = true,
    [ACT_BURNING_GROUND] = true,
    [ACT_BURNING_JUMP] = true,
}

local function nullify_inputs(m, nullCam)
    local c = m.controller
    local camInputs = {
        buttonDown = {},
        buttonPressed = {}
    }
    if not nullCam then
        camInputs.buttonDown.L_CBUTTONS = c.buttonDown & L_CBUTTONS
        camInputs.buttonDown.R_CBUTTONS = c.buttonDown & R_CBUTTONS
        camInputs.buttonDown.U_CBUTTONS = c.buttonDown & U_CBUTTONS
        camInputs.buttonDown.D_CBUTTONS = c.buttonDown & D_CBUTTONS
        camInputs.buttonDown.R_TRIG = c.buttonDown & R_TRIG
        camInputs.buttonDown.L_TRIG = c.buttonDown & L_TRIG
        camInputs.buttonDown.START_BUTTON = c.buttonDown & START_BUTTON
        
        camInputs.buttonPressed.L_CBUTTONS = c.buttonPressed & L_CBUTTONS
        camInputs.buttonPressed.R_CBUTTONS = c.buttonPressed & R_CBUTTONS
        camInputs.buttonPressed.U_CBUTTONS = c.buttonPressed & U_CBUTTONS
        camInputs.buttonPressed.D_CBUTTONS = c.buttonPressed & D_CBUTTONS
        camInputs.buttonPressed.R_TRIG = c.buttonPressed & R_TRIG
        camInputs.buttonPressed.L_TRIG = c.buttonPressed & L_TRIG
        camInputs.buttonPressed.START_BUTTON = c.buttonPressed & START_BUTTON
    end
    c.buttonDown = 0
    c.buttonPressed = 0
    c.extStickX = 0
    c.extStickY = 0
    c.rawStickX = 0
    c.rawStickY = 0
    c.stickMag = 0
    c.stickX = 0
    c.stickY = 0
    if not nullCam then
        if camInputs.buttonDown.L_CBUTTONS ~= 0 then
            c.buttonDown = L_CBUTTONS
        end
        if camInputs.buttonDown.R_CBUTTONS ~= 0 then
            c.buttonDown = R_CBUTTONS
        end
        if camInputs.buttonDown.U_CBUTTONS ~= 0 then
            c.buttonDown = U_CBUTTONS
        end
        if camInputs.buttonDown.D_CBUTTONS ~= 0 then
            c.buttonDown = D_CBUTTONS
        end
        if camInputs.buttonDown.R_TRIG ~= 0 then
            c.buttonDown = R_TRIG
        end
        if camInputs.buttonDown.L_TRIG ~= 0 then
            c.buttonDown = L_TRIG
        end
        if camInputs.buttonDown.START_BUTTON ~= 0 then
            c.buttonDown = START_BUTTON
        end
        
        if camInputs.buttonPressed.L_CBUTTONS ~= 0 then
            c.buttonPressed = L_CBUTTONS
        end
        if camInputs.buttonPressed.R_CBUTTONS ~= 0 then
            c.buttonPressed = R_CBUTTONS
        end
        if camInputs.buttonPressed.U_CBUTTONS ~= 0 then
            c.buttonPressed = U_CBUTTONS
        end
        if camInputs.buttonPressed.D_CBUTTONS ~= 0 then
            c.buttonPressed = D_CBUTTONS
        end
        if camInputs.buttonPressed.R_TRIG ~= 0 then
            c.buttonPressed = R_TRIG
        end
        if camInputs.buttonPressed.L_TRIG ~= 0 then
            c.buttonPressed = L_TRIG
        end
        if camInputs.buttonPressed.START_BUTTON ~= 0 then
            c.buttonPressed = START_BUTTON
        end
    end
end

local inputStallTimerButton = 0
local inputStallTimerDirectional = 0
local inputStallToDirectional = 12
local inputStallToButton = 10

local lightGreen = true
local deathTimer = 0
local deathTimerMax = 15

local function menu_update(m)
    if menu then
        local cameraToObject = gMarioStates[0].marioObj.header.gfx.cameraToObject

        if inputStallTimerButton > 0 then inputStallTimerButton = inputStallTimerButton - 1 end
        if inputStallTimerDirectional > 0 then inputStallTimerDirectional = inputStallTimerDirectional - 1 end

        if inputStallTimerDirectional == 0 then
            if (m.controller.buttonPressed & D_JPAD) ~= 0 then
                currOption = currOption + 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if (m.controller.buttonPressed & U_JPAD) ~= 0 then
                currOption = currOption - 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if m.controller.stickY < -60 then
                currOption = currOption + 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if m.controller.stickY > 60 then
                currOption = currOption - 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
        end

        if inputStallTimerButton == 0 then
            if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
                optionTable[currOption].toggle = optionTable[currOption].toggle + 1
                if optionTable[currOption].toggle > optionTable[currOption].toggleMax then optionTable[currOption].toggle = 0 end
                if optionTable[currOption].toggleSaveName ~= nil then
                    mod_storage_save(optionTable[currOption].toggleSaveName, tostring(optionTable[currOption].toggle))
                end
                inputStallTimerButton = inputStallToButton
                play_sound(SOUND_MENU_CHANGE_SELECT, cameraToObject)

                if optionTable[currOption].hostOnly then
                    if currOption == optionTableRef.gamemode then
                        gGlobalSyncTable.redlightgreenlight = optionTable[currOption].toggle
                    end
                    if currOption == optionTableRef.redlightmode then
                        gGlobalSyncTable.redlightmode = optionTable[currOption].toggle
                    end
                    if currOption == optionTableRef.triggermode then
                        gGlobalSyncTable.triggermode = optionTable[currOption].toggle
                    end
                    if currOption == optionTableRef.mhLights then
                        gGlobalSyncTable.mhLights = optionTable[currOption].toggle
                    end
                    local table = optionTable[currOption]
                    djui_popup_create_global("Red Light/Green Light\n"..table.name.." was set to "..table.toggleNames[table.toggle + 1]..(table.toggleDesc and "\n"..table.toggleDesc[table.toggle + 1] or ""), (table.toggleDesc and 3 or 2))
                end
            end
            if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
                menu = false
                inputStallTimerButton = inputStallToButton
            end
        end
        if currOption > #optionTable then currOption = 1 end
        if currOption < 1 then currOption = #optionTable end
        if optionTable[currOption].hostOnly and not network_is_server() then
            repeat
                currOption = currOption + 1
            until not optionTable[currOption].hostOnly
        end
        nullify_inputs(m, true)
    end
end

function before_mario_update(m)
    if gPlayerSyncTable[m.playerIndex].isUpdating and not gNetworkPlayers[m.playerIndex].connected then
        gPlayerSyncTable[m.playerIndex].isUpdating = false
    end
    if m.playerIndex ~= 0 then return end

    if not gPlayerSyncTable[0].isUpdating then
        gPlayerSyncTable[0].isUpdating = true
    end

    -- Prevent script errors while waiting for packet
    if timer ~= nil then
        lightGreen = (timer > 0)
    else
        timer = 0
    end
    menu_update(m)

    if not warning and lightGreen and timer < timerWarning then
        warning = true
        play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
    end
    if warning and timer > timerWarning then
        play_sound(SOUND_MENU_REVERSE_PAUSE, m.marioObj.header.gfx.cameraToObject)
        warning = false
    end

    if gGlobalSyncTable.mhLights == 1 and _G.mhApi.getTeam(0) == 1 then
        localredlightgreenlight = 0
    elseif gGlobalSyncTable.mhLights == 2 and _G.mhApi.getTeam(0) == 0 then
        localredlightgreenlight = 0
    else
        localredlightgreenlight = 1
    end

    if localredlightgreenlight ~= 1 then return end
    if gGlobalSyncTable.redlightgreenlight == 1 then
        if not lightGreen then
            if gGlobalSyncTable.redlightmode ~= 2 then
                local stick = math.sqrt(m.controller.stickX^2 + m.controller.stickY^2)
                local speed = math.sqrt(m.vel.x^2 + math.max(m.vel.y, 0)^2 + m.vel.z^2)

                if (speed > 10 or speed > 0 and stick > 20 and not SafeActs[m.action]) or SafeActs[m.action] == false or deathTimer >= deathTimerMax then
                    if not SafeActs[m.action] and not is_game_paused() and m.health > 255 then
                        if gGlobalSyncTable.redlightmode == 0 then
                            deathTimer = deathTimer + 1
                            if deathTimer >= deathTimerMax then
                                m.health = 255
                                deathTimer = 0
                            end
                        else
                            deathTimer = 0
                        end
                        if gGlobalSyncTable.redlightmode == 1 then
                            m.health = m.health - 20
                        end
                        if m.health <= 255 then
                            local color = {r = 0, g = 0, b = 0}
                            djui_chat_message_create(color.r..color.g..color.b)
                            djui_popup_create_global("Red Light/Green Light\n\\#"..color.r..color.g..color.b.."\\"..gNetworkPlayers[0].name.."\\#dcdcdc\\ was Caught Moving!", 2)
                            set_mario_action(m, ACT_HARD_BACKWARD_GROUND_KB, 0)
                            m.forwardVel = -5
                        end
                    else
                        if m.action == ACT_CRAWLING or m.action == ACT_START_CRAWLING or m.action == ACT_STOP_CRAWLING then
                            if math.random(0, 100) == 64 then
                                m.health = 255
                                deathTimer = 0

                                djui_popup_create_global("Red Light/Green Light\n"..gNetworkPlayers[0].name.."\\#dcdcdc\\ was Caught Crawling!", 2)
                            end
                        end
                    end
                end
            elseif not is_game_paused() and m.health > 255 and not actNoFreeze[m.action] then
                if m.pos.y == m.floorHeight then
                    set_mario_action(m, ACT_STANDING_AGAINST_WALL, 0)
                    set_mario_animation(m, MARIO_ANIM_STAND_AGAINST_WALL)
                    m.vel.x = 0
                    m.vel.z = 0
                end
                nullify_inputs(m, false)
            end
        else
            if gGlobalSyncTable.redlightmode == 0 then
                deathTimer = 0
            end
            if gGlobalSyncTable.redlightmode == 2 then
                if m.action == ACT_STANDING_AGAINST_WALL then
                    set_mario_action(m, ACT_IDLE, 0)
                end
            end
        end
    end

    -- Host Trigger
    if gGlobalSyncTable.triggermode == 1 and network_is_server() then
        if m.controller.buttonPressed & L_TRIG ~= 0 and cooldownTimer == 0 then
            timer = (timer > timerWarning) and timerWarning - 1 or timerWarning + 1
            cooldownTimer = (timer > timerWarning) and cooldownTimerStart or 0
            local data = {
                timerStart = timer,
            }
            network_send(true, data)
        end
        if cooldownTimer > 0 then
            cooldownTimer = cooldownTimer - 1
        end
    end
end

local modList = {
    mariohunt = false,
    ommcoop = false,
}
for i in pairs(gActiveMods) do
    if (gActiveMods[i].relativePath == "MarioHunt") then
        modList.mariohunt = true
        optionTableRef.mhLights = #optionTable + 1
        optionTable[optionTableRef.mhLights] = {
            name = "Affect Team",
            hostOnly = true,
            toggleDefault = 0,
            toggleMax = 2,
            toggleNames = {"Everyone", "Hunters", "Runners"},
            toggleDesc = {"(MH) Light Affects Everyone", "(MH) Light Affects Hunters Only", "(MH) Light Affects Runners Only"}
        }
        failsafe_options()
    end
    if (gActiveMods[i].relativePath == "omm-coop") then
        modList.ommcoop = true
    end
end

-- Hud Stuff
local menuSlideMax = 0
local menuSlide = 1
local r = 0
local g = 0
local screenWidth = 0
local y = -100
function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)

    if menu then
        if menuSlide < menuSlideMax then
            menuSlide = menuSlide*1.2
        elseif menuSlideMax ~= 0 then
            menuSlide = menuSlideMax
        end
    else
        if menuSlide > 1 then
            menuSlide = menuSlide*0.9
        else
            menuSlide = 1
        end
    end

    local text = ""
    local subtext = ""

    if lightGreen then
        text = "Green Light"
        g = (optionTable[optionTableRef.colorblind].toggle == 0) and 200 or 255
        if timer ~= nil and timer < timerWarning then
            r = 150
            if optionTable[optionTableRef.colorblind].toggle ~= 0 then
                g = 150
            end
        else
            r = 0
        end
    else
        text = "Red Light"
        r = (optionTable[optionTableRef.colorblind].toggle == 0) and 200 or 75
        g = 0
    end
    if optionTable[optionTableRef.lighttext].toggle == 1 then
        text = optionTable[optionTableRef.redlightmode].toggleNames[gGlobalSyncTable.redlightmode + 1]
    end
    subtext = optionTable[optionTableRef.redlightmode].toggleNames[gGlobalSyncTable.redlightmode + 1].." | "..optionTable[optionTableRef.triggermode].toggleNames[gGlobalSyncTable.triggermode + 1]..(gGlobalSyncTable.mhLights ~= 0 and " | "..optionTable[optionTableRef.mhLights].toggleNames[gGlobalSyncTable.mhLights + 1] or "")
    if localredlightgreenlight == 0 then
        text = "Unaffected"
    end

    local scale = 0.50

    -- get width of screen and text
    screenWidth = djui_hud_get_screen_width()*0.5
    local offsetY = 0
    local offsetScaleY = 0
    if gGlobalSyncTable.redlightgreenlight ~= 1 then
        offsetScaleY = -18
    end
    if modList.mariohunt then
        offsetY = offsetY + 15
        if _G.mhApi.getState() == 0 or _G.mhApi.getState() == 5 then
            offsetY = offsetY + 12
        end
    end

    djui_hud_set_color(0, 0, 0, 150)
    if menuSlide > 1 or offsetScaleY ~= -18 then
        djui_hud_render_rect(screenWidth - 42, 2 + offsetY, 84, 25 + menuSlide + offsetScaleY)
    end
    
    if menu or menuSlide > 1 then
        local menuSlideCount = 0
        for i = 1, #optionTable do
            if not optionTable[i].hostOnly or network_is_server() then
                if optionTable[i].hostOnly then
                    djui_hud_set_color(255, 255, 0, 255)
                else
                    djui_hud_set_color(255, 255, 255, 255)
                end
                y = y + 10
                if y >= 2 + offsetY then
                    local toggleName = optionTable[i].name
                    if i == currOption then
                        toggleName = "> "..toggleName
                    else
                        toggleName = "  "..toggleName
                    end
                    djui_hud_set_font(FONT_NORMAL)
                    djui_hud_print_text(toggleName, screenWidth - 40, y, 0.3)
                    local toggleOption = optionTable[i].toggleNames[optionTable[i].toggle + 1]
                    djui_hud_print_text(toggleOption, screenWidth + 40 - djui_hud_measure_text(toggleOption)*0.3, y, 0.3)
                    djui_hud_set_font(FONT_TINY)
                    if i == currOption and optionTable[i].toggleDesc then
                        y = y + 3
                        local toggleDesc = optionTable[i].toggleDesc[optionTable[i].toggle + 1]
                        djui_hud_print_text(toggleDesc, screenWidth - djui_hud_measure_text(toggleDesc)*0.2, y + 5, 0.4)
                    end
                end
                menuSlideCount = menuSlideCount + 1
            end
        end
        menuSlideMax = menuSlideCount*10 + 3 + 5
        y = menuSlide - 10*(menuSlideCount - 1) - 3 + offsetY + offsetScaleY
    end

    
    if gGlobalSyncTable.redlightgreenlight == 1 then
        djui_hud_set_font(FONT_NORMAL)
        if localredlightgreenlight == 1 then
            djui_hud_set_color(r, g, 0, 255)
        else
            djui_hud_set_color(r*0.5, g*0.5, 0, 255)
        end
        djui_hud_render_rect(screenWidth - 40, 4 + offsetY, 80, 16)
        if gGlobalSyncTable.redlightmode == 0 then
            djui_hud_set_color(255, 100, 100, 255)
            djui_hud_render_rect(screenWidth - 40, 18 + offsetY, 80*(math.min(deathTimer, deathTimerMax)/deathTimerMax), 2)
        end
        if gGlobalSyncTable.triggermode == 1 then
            djui_hud_set_color(200, 255, 200, 255)
            djui_hud_render_rect(screenWidth - 40, 18 + offsetY, 80*(cooldownTimer/cooldownTimerStart), 2)
        end

        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_print_text(text, screenWidth - djui_hud_measure_text(text)*scale*0.5, 4 + offsetY, scale)
        djui_hud_set_font(FONT_TINY)
        djui_hud_set_color(255, 255, 0, 200)
        djui_hud_print_text(subtext, screenWidth - djui_hud_measure_text(subtext)*scale*0.5, 19 + offsetY + menuSlide, scale)
    end
end

function on_hud_render_behind()
    djui_hud_set_resolution(RESOLUTION_N64)
    if gGlobalSyncTable.redlightgreenlight == 1 and optionTable[optionTableRef.vignette].toggle ~= 0 and localredlightgreenlight == 1 then
        local multiply = optionTable[optionTableRef.vignette].toggle * optionTable[optionTableRef.vignette].toggle
        for i = 1, 10 do
            djui_hud_set_color(r, g, 0, 5 * multiply)
            djui_hud_render_rect(0, 0, 10 * i, 240);
            djui_hud_render_rect(screenWidth*2 + -10 * i + 2, 0, 10 * i, 240);
        end
        djui_hud_set_color(r, g, 0, 5 * multiply)
        djui_hud_render_rect(0, 0, screenWidth*2 + 2, 240);
    end
end

function toggle_menu(msg)
    menu = not menu
    return true
end

hook_event(HOOK_UPDATE, server_update)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_connect)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render_behind)
hook_chat_command("rlgl", "Opens the Red Light/Green Light Settings", toggle_menu)