if not _G.charSelectExists then
    return 0
end

local menu = false
local optionHover = 1
local RoomTime = "??:??:??"

menuTableRef = {
    moveset = 1,
    costume = 2,
    menuAnims = 3,
    menuBind = 4,
    menuColor = 5,
    openCSmenu = 6,
}

menuTable = {
    [menuTableRef.moveset] = {
        name = "Moveset",
        nameSave = "MoveSave",
        status = tonumber(mod_storage_load("MoveSave")),
        statusMax = 1,
        statusDefault = 1,
        --Status Toggle Names
        statusNames = {
            [-1] = "Forced Off",
            [0] = "Off",
            [1] = "On",
        }, 
        description = {
            "Toggles if Moveset changes",
            "apply while playing as",
            "Squishy via Character Select."
        },
    },
    [menuTableRef.costume] = {
        name = "Costume",
        nameSave = "costume",
        status = tonumber(mod_storage_load("costume")),
        statusMax = 2,
        statusDefault = 0,
        --Status Toggle Names
        statusNames = {
            [0] = "Default",
            [1] = "Classic",
            [2] = "Paper",
        }, 
        description = {
            "Toggles how Squishy looks",
            "during play",
        },
    },
    [menuTableRef.menuAnims] = {
        name = "Menu Animations",
        nameSave = "MenuAnims",
        status = tonumber(mod_storage_load("MenuAnims")),
        statusMax = 1,
        statusDefault = 1,
        --Status Toggle Names
        statusNames = {
            [0] = "Off",
            [1] = "On",
        }, 
        description = {
            "Toggles if Menu Animations",
            "display in this menu."
        },
    },
    [menuTableRef.menuBind] = {
        name = "Menu Bind",
        nameSave = "MenuBind",
        status = tonumber(mod_storage_load("MenuBind")),
        statusMax = 2,
        statusDefault = 1,
        --Status Toggle Names
        statusNames = {
            [0] = "Off",
            [1] = "Squishy Only",
            [2] = "Always On",
        }, 
        description = {
            "Toggles when you see the",
            "L button bind on the",
            "pause menu."
        },
    },
    [menuTableRef.menuColor] = {
        name = "Menu Color",
        nameSave = "MenuColor",
        status = tonumber(mod_storage_load("MenuColor")),
        statusMax = 2,
        statusDefault = 0,
        --Status Toggle Names
        statusNames = {
            [0] = "Default",
            [1] = "Palette Shirt",
            [2] = "Character Select",
        }, 
        description = {
            "Toggles the Menu Color",
        },
    },
    [menuTableRef.openCSmenu] = {
        name = "Open Character Select",
        status = 0,
        statusMax = 1,
        statusDefault = 0,
        --Status Toggle Names
        statusNames = {
            [0] = "",
            [1] = "",
        }, 
        description = {
            "Opens the Character Select Menu",
        },
    },
}

local function failsafe_options()
    for i = 1, #menuTable do
        if menuTable[i].status == nil or menuTable[i].status == "" then
            menuTable[i].status = menuTable[i].statusDefault
            if menuTable[i].nameSave ~= nil then
                mod_storage_save(menuTable[i].nameSave, tostring(menuTable[i].toggle))
            end
        end
        if menuTable[i].statusNames == nil then
            menuTable[i].statusNames = {"Off", "On"}
        end
    end
end

local menuDefaultColor = {r = 0, g = 136, b = 0}
local menuColor = {r = 0, g = 136, b = 0}

local menuDialog = {r = 255, g = 255, b = 255}
local squishyDialog = {r = 0, g = 136, b = 0}

local missedYou = {
    {text = "Please come back", color = menuDialog},
    {text = "I missed you", color = menuDialog},
    {text = "Was I a good menu?", color = menuDialog},
    {text = "Just a husk of what once was...", color = menuDialog},

    {text = "I'm so sorry", color = squishyDialog},
    {text = "I was too ambitious", color = squishyDialog},
    {text = "It's all my fault", color = squishyDialog},
    {text = "We all loved you", color = squishyDialog},
}

local TEX_HEADER = get_texture_info("I-missed-you")

local MATH_DIVIDE_420 = 1/420 -- Tested Widescreen

local descSlide = -100
local bobbing = 0
local bobbingInt = 0
local stallFrame = 0
local function render_menu()
    local m = gMarioStates[0]
    if stallFrame < 2 then
        stallFrame = stallFrame + 1
        if stallFrame == 1 then
            failsafe_options()
        end
        return
    end

    if menuTable[menuTableRef.menuBind].status > 0 and (menuTable[menuTableRef.menuBind].status ~= 1 or gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY) then
        if is_game_paused() and not djui_hud_is_pause_menu_created() and (gPlayerSyncTable[0].squishyPlayer ~= 0) then
            if m.action ~= ACT_EXIT_LAND_SAVE_DIALOG then
                djui_hud_set_resolution(RESOLUTION_DJUI)
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_print_text("L Button - Squishy Options", (djui_hud_get_screen_width()*0.5 - (djui_hud_measure_text("L Button - Squishy Options")*0.5)), 42, 1)
            end
        end
    end

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_resolution(RESOLUTION_N64)
    local width =  djui_hud_get_screen_width()
    local halfScreenWidth = width *0.5 - math.min(width, 320)*MATH_DIVIDE_420*50
    --[[
    djui_hud_render_rect(halfScreenWidth, 0, 1, 240)
    djui_chat_message_create(tostring(math.min(width, 320)))
    ]]

    if menu then
        if menuTable[menuTableRef.menuColor].status == 1 then
            local colorOut = {r = 0, g = 0, b = 0}
            network_player_palette_to_color(gNetworkPlayers[0], SHIRT, colorOut)
            menuColor.r = colorOut.r
            menuColor.g = colorOut.g
            menuColor.b = colorOut.b
        elseif menuTable[menuTableRef.menuColor].status == 2 then
            local csColor = _G.charSelect.get_menu_color()
            menuColor.r = csColor.r
            menuColor.g = csColor.g
            menuColor.b = csColor.b
        else
            menuColor.r = menuDefaultColor.r
            menuColor.g = menuDefaultColor.g
            menuColor.b = menuDefaultColor.b
        end

        djui_hud_set_resolution(RESOLUTION_N64)
        if menuTable[menuTableRef.menuAnims].status ~= 0 then
            bobbingInt = bobbingInt + 0.01
            bobbing = math.sin(bobbingInt)*2
            if descSlide < -1 then
                descSlide = descSlide*0.83333333333
            end
        else
            descSlide = -1
        end
        
        djui_hud_set_color(0, 0, 0, 150)
        djui_hud_render_rect(0, 0, djui_hud_get_screen_width()+5, 240)

        if true then
            djui_hud_set_color(0, 0, 0, 220)
            djui_hud_render_rect((halfScreenWidth + 91) + descSlide, ((djui_hud_get_screen_height()*0.5) - 42) - bobbing, 104, 104)
            djui_hud_render_rect((halfScreenWidth + 93) + descSlide, ((djui_hud_get_screen_height()*0.5) - 40) - bobbing, 100, 100)
            djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
            djui_hud_print_text(menuTable[optionHover].name, (halfScreenWidth + 100) + descSlide, 85 - bobbing, 0.35)
            djui_hud_set_color(255, 255, 255, 255)
            for i = 1, 9 do
                local line = menuTable[optionHover].description[i]
                if line ~= nil then
                    djui_hud_print_text(line, halfScreenWidth + 100 + descSlide, (100 + (i - 1) * 8) - bobbing, 0.3)
                end
            end
            djui_hud_print_text("Room has been Open for:", halfScreenWidth + 143 - djui_hud_measure_text("Room has been Open for:")*0.15 + descSlide, 48 - bobbing, 0.3)
            djui_hud_print_text(RoomTime, halfScreenWidth + 143 - djui_hud_measure_text(RoomTime)*0.35 + descSlide, 55 - bobbing, 0.7)
        end

        djui_hud_set_font(FONT_MENU)
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_set_color(0, 0, 0, 220)
        djui_hud_render_rect((halfScreenWidth - 88), ((djui_hud_get_screen_height()*0.5) - 93) + bobbing, 176, 205)
        djui_hud_render_rect((halfScreenWidth - 85), ((djui_hud_get_screen_height()*0.5) - 90) + bobbing, 170, 199)
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_texture(TEX_HEADER, (halfScreenWidth - TEX_HEADER.width*0.35), ((djui_hud_get_screen_height()*0.5) - 85) + bobbing, 0.7, 0.7)


        --Toggles--
        djui_hud_set_font(FONT_NORMAL)
        djui_hud_set_resolution(RESOLUTION_N64)

        djui_hud_set_color(150, 150, 150, 255)
        djui_hud_print_text("Welcome back!", (halfScreenWidth - 80), 216 + bobbing, 0.3)


        djui_hud_set_color(255, 255, 255, 200)
        djui_hud_render_rect((halfScreenWidth - 72), 80 + (optionHover * 10 - 10) + bobbing, 70, 9)
        djui_hud_set_color(255, 255, 255, 255)
        
        if optionHover < 1 then
            optionHover = #menuTable
        elseif optionHover > #menuTable then
            optionHover = 1
        end

        for i = 1, #menuTable do
            if i == optionHover then
                djui_hud_set_color(0, 0, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 255)
            end
            djui_hud_print_text(menuTable[i].name, halfScreenWidth - 70, (80 + (i - 1) * 10) + bobbing, 0.3)
        end
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(menuTable[optionHover].statusNames[menuTable[optionHover].status], halfScreenWidth, (80 + (optionHover - 1) * 10) + bobbing, 0.3)

        local hoverText = tostring(optionHover).." / "..tostring(#menuTable)
        djui_hud_set_color(128, 128, 128, 255)
        djui_hud_print_text("Option:", halfScreenWidth + 80 - djui_hud_measure_text("Option: "..hoverText)*0.25, 35 + bobbing, 0.25)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(hoverText, halfScreenWidth + 80 - djui_hud_measure_text(hoverText)*0.25, 35 + bobbing, 0.25)

        if menuTable[menuTableRef.openCSmenu].status > 0 then
            menuTable[menuTableRef.openCSmenu].status = 0
            menu = false
            _G.charSelect.set_menu_open(true)
        end
    else
        descSlide = -100
    end
end

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

local inputStallTimerButton = 0
local inputStallTimerDirectional = 0
local inputStallToDirectional = 6
local inputStallToButton = 10

local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if inputStallTimerButton > 0 then inputStallTimerButton = inputStallTimerButton - 1 end
    if inputStallTimerDirectional > 0 then inputStallTimerDirectional = inputStallTimerDirectional - 1 end

    local cameraToObject = gMarioStates[0].marioObj.header.gfx.cameraToObject

    if menu then
        if inputStallTimerDirectional == 0 then
            if (m.controller.buttonPressed & D_JPAD) ~= 0 then
                optionHover = optionHover + 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if (m.controller.buttonPressed & U_JPAD) ~= 0 then
                optionHover = optionHover - 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if m.controller.stickY < -60 then
                optionHover = optionHover + 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if m.controller.stickY > 60 then
                optionHover = optionHover - 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
        end

        if inputStallTimerButton == 0 then
            if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
                menuTable[optionHover].status = menuTable[optionHover].status + 1
                if menuTable[optionHover].status > menuTable[optionHover].statusMax then menuTable[optionHover].status = 0 end
                if menuTable[optionHover].nameSave ~= nil then
                    mod_storage_save(menuTable[optionHover].nameSave, tostring(menuTable[optionHover].status))
                end
                inputStallTimerButton = inputStallToButton
                play_sound(SOUND_MENU_CHANGE_SELECT, cameraToObject)
            end
            if (m.controller.buttonPressed & B_BUTTON) ~= 0 then
                menu = false
                inputStallTimerButton = inputStallToButton
            end
        end
        if optionHover > #menuTable then optionHover = 1 end
        if optionHover < 1 then optionHover = #menuTable end
        nullify_inputs(m)
    end

    if menuTable[menuTableRef.menuBind].status > 0 and (menuTable[menuTableRef.menuBind].status ~= 1 or gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY) then
        if is_game_paused() and not djui_hud_is_pause_menu_created() and m.action ~= ACT_EXIT_LAND_SAVE_DIALOG then
            if (m.controller.buttonPressed & L_TRIG) ~= 0 and not menu then
                m.controller.buttonPressed = START_BUTTON
                menu = true
                play_sound(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject)
            end
        end
    end
end

local function command()
    menu = not menu
    return true
end

hook_event(HOOK_ON_HUD_RENDER, render_menu)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_chat_command("squishy-settings", "Lets you edit setting for squishy", command)