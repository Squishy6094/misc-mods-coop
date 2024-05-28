local menu = false
local currOption = 1

local inputStallTimerButton = 0
local inputStallTimerDirectional = 0
local inputStallToDirectional = 6
local inputStallToButton = 10


optionTableRef = {
    showTitlecards = 1,
    subTitle = 2,
    texPriority = 3,
}

optionTable = {
    [optionTableRef.showTitlecards] = {
        name = "Show Titlecards",
        toggle = tonumber(mod_storage_load("showTC")),
        toggleSaveName = "showTC",
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"Off", "On", "Exclude Castle"},
    },
    [optionTableRef.subTitle] = {
        name = "Subtitles",
        toggle = tonumber(mod_storage_load("subtitle")),
        toggleSaveName = "subtitle",
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"Star/Custom", "Custom Only"},
    },
    [optionTableRef.texPriority] = {
        name = "Custom Texture Priority",
        toggle = tonumber(mod_storage_load("texPriority")),
        toggleSaveName = "texPriority",
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"Rom-Hack/Level", "Character Select"},
    },
}

---@param m MarioState
local function nullify_inputs(m)
    local c = m.controller
    c.buttonDown = 0
    c.buttonPressed = 0
    c.extStickX = 0
    c.extStickY = 0
    c.rawStickX = 0
    c.rawStickY = 0
    c.stickMag = 0
    c.stickX = 0
    c.stickY = 0
end

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
    end
end

local TEXT_OPTIONS = "Options"
local TEXT_TITLECARDS = "Titlecards"

local stallFrame = 0

local function on_hud_render()
    if stallFrame == 1 then
        failsafe_options()
    end

    if stallFrame < 2 then
        stallFrame = stallFrame + 1
    end
    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width()
    local height = 240
    if menu then
        djui_hud_set_color(0, 0, 0, 150)
        djui_hud_render_rect(0, 0, width + 5, height)
        djui_hud_set_color(255, 255, 0, 255)
        djui_hud_set_font(FONT_MENU)
        djui_hud_print_text(TEXT_OPTIONS, width*0.5 - djui_hud_measure_text(TEXT_OPTIONS)*0.25, 10, 0.5)
        djui_hud_set_font(FONT_TINY)
        djui_hud_print_text(TEXT_TITLECARDS, width*0.5 - 105, 55, 0.8)
        djui_hud_render_rect(width*0.5 - 105, 70, 210, 1)
        for i = 1, #optionTable do
            local option = optionTable[i]
            if i == currOption then
                djui_hud_set_color(255, 255, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 255)
            end
            djui_hud_print_text(option.name, width*0.5 - 100, 71 + (i - 1) * 10, 0.8)
            djui_hud_set_color(255, 255, 0, 255)
            djui_hud_print_text(option.toggleNames[option.toggle + 1], width*0.5 + 100 - djui_hud_measure_text(option.toggleNames[option.toggle + 1])*0.8, 71 + (i - 1) * 10, 0.8)
        end
    end
end

local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if inputStallTimerButton > 0 then inputStallTimerButton = inputStallTimerButton - 1 end
    if inputStallTimerDirectional > 0 then inputStallTimerDirectional = inputStallTimerDirectional - 1 end

    local cameraToObject = gMarioStates[0].marioObj.header.gfx.cameraToObject

    if menu then
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
            end
            if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
                menu = false
                inputStallTimerButton = inputStallToButton
            end
        end
        if currOption > #optionTable then currOption = 1 end
        if currOption < 1 then currOption = #optionTable end
        nullify_inputs(m)
    end
end

local function titlecards_command()
    menu = not menu
    return true
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_chat_command("titlecards", "Edit SRB2 Titlecard Settings", titlecards_command)