-- name: Debug Console
-- description: Debugging Console themed around Window's \\#888888\\cmd.exe\\#dcdcdc\\!

--[[
    This example showcases how the default functions
    work cleanly with the custom font without having
    to manually mess with textures tiling
]]

local DEBUG_CONSOLE_VERSION = "v1 (In-Dev)"

--Tables from a-tables.lua
local fontInfoConsole, infoActionTable, infoLevelTable, infoVoicesTable = fontInfoConsole, infoActionTable, infoLevelTable, infoVoicesTable

local stringTable = {}

-- Font can use a unique variable, or an existing font to overwrite it
FONT_CONSOLE = djui_hud_add_font(get_texture_info("font-console"), fontInfoConsole, 1, 3, "_", 1)

local consoleToggle = true
local consoleWindows = {}
local defaultScale = 1.5
local windowHeld = 0
local windowLastHeld = 1
local firstWindowOpen = true

local function console_create()
    table.insert(consoleWindows, {
        consolePage = (#consoleWindows == 0 and 1 or 2),

        scale = defaultScale,
        windowX = (consoleWindows[windowLastHeld] ~= nil and consoleWindows[windowLastHeld].windowX + 40 or 50),
        windowY = (consoleWindows[windowLastHeld] ~= nil and consoleWindows[windowLastHeld].windowY + 40 or 200),
        windowWidth = 300*defaultScale,
        windowHeight = 300*defaultScale,
        windowWidthMin = 202,
        windowHeightMin = 150,
        
        exitAnimTimer = 0,

        mouseWindowOffsetX = 0,
        mouseWindowOffsetY = 0,
        prevWindowX = 50,
        prevWindowWidth = 200,
        windowHoldPoint = 0,
    })
    windowLastHeld = #consoleWindows
end

console_create()

local function console_delete(consoleNum)
    table.remove(consoleWindows, consoleNum)
    if consoleNum == 1 then
        firstWindowOpen = false
    end
end

local fontWidth = fontInfoConsole["_"].width
local fontHeight = fontInfoConsole["_"].height
local MATH_DIVIDE_FONT_WIDTH = 1/(fontWidth + 1)
local MATH_DIVIDE_FONT_HEIGHT = 1/(fontHeight + 1)

local function console_add_lines(console, string)
    local loopcount = 1
    if type(string) == "table" then
        loopcount = #string
    end

    for k = 1, loopcount do
        local output = ""
        local string = string
        if type(string) == "table" then
            string = string[k]
        end
        for i = 1, #string do
            local letter = string:sub(i,i)
            output = output..letter
            if i%math.floor((console.windowWidth - 10 - fontWidth)/console.scale*MATH_DIVIDE_FONT_WIDTH) == 0 then
                table.insert(stringTable, output)
                output = ""
            end
        end
        if output ~= "" then
            table.insert(stringTable, output)
        end
    end
end

local consolePageList = {
    welcome = 1,
    player = 2,
    area = 3,
}

local lastCharacterSound = 0
local function get_current_sound(m, voice)
    if m.playerIndex ~= 0 then return end
    lastCharacterSound = voice
end

local consolePageData = {
    [consolePageList.welcome] = {
        name = "Welcome",
        textFunc = function (m, console)
            console_add_lines(console, { 
                "Welcome to Debugging Console!",
                "This mod has Debugging Windows",
                "Which can be moved around while",
                "paused like any other window can!",
                " ",
                "You can use D-pad Left or Right",
                "To change 'Pages' which tell you",
                "different info based on different",
                "types of things."
            })
        end
    },
    [consolePageList.player] = {
        name = "Player",
        textFunc = function (m, console)
            console_add_lines(console, {
                "Player Index: ".. (m.playerIndex) .. " | " .. network_global_index_from_local(m.playerIndex),
                "Pos: "..math.floor(m.pos.x)..", "..math.floor(m.pos.y)..", "..math.floor(m.pos.z),
                "Vel: "..math.floor(m.vel.x)..", "..math.floor(m.vel.y)..", "..math.floor(m.vel.z),
                "Forward Vel: "..math.floor(m.forwardVel),
                "Action: "..(infoActionTable[m.action] ~= nil and infoActionTable[m.action] or "???"),
                "Prev Action: "..(infoActionTable[m.prevAction] ~= nil and infoActionTable[m.prevAction] or "???"),
                "Last Sound: "..(infoVoicesTable[lastCharacterSound] ~= nil and infoVoicesTable[lastCharacterSound] or "???"),
            })
        end
    },
    [consolePageList.area] = {
        name = "Stage/Location",
        textFunc = function (m, console)
            local np = gNetworkPlayers[m.playerIndex]
            console_add_lines(console, {
                "Level: "..infoLevelTable[np.currLevelNum].." ("..np.currLevelNum..")",
                "Act: ("..np.currActNum..")",
                "Area: ("..np.currAreaIndex..")",
            })
        end
    },
}

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local m = gMarioStates[0]
    if consoleToggle then
        local mouseX = djui_hud_get_mouse_x()
        local mouseY = djui_hud_get_mouse_y()

        if #consoleWindows < 1 then return end
        for i = 1, #consoleWindows do
            local console = consoleWindows[i]
            stringTable = {}
            if i == 1 and firstWindowOpen then
            console_add_lines(console, {
                    "-----------------------",
                    "Debug Console "..DEBUG_CONSOLE_VERSION,
                    "Made by Squishy6094",
                    "",
                    "Font Handler v0.5",
                    "-----------------------",
                })
            end

            if consolePageData[console.consolePage] ~= nil then
                console_add_lines(console, {
                    " ",
                    "Page "..console.consolePage..": "..consolePageData[console.consolePage].name,
                    " ",
                })
                consolePageData[console.consolePage].textFunc(m, console)
            end

            if is_game_paused() then
                console_add_lines(console, {
                    " ",
                    "< Next | Prev >",
                    "Use mouse to adjust Window"
                })
            end

            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_render_rect(console.windowX, console.windowY, console.windowWidth, console.windowHeight)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_rect(console.windowX, console.windowY, console.windowWidth, 30)
            djui_hud_render_texture(gTextures.star, console.windowX + 6, console.windowY + 5, 1.3, 1.3)
            djui_hud_set_font(FONT_TINY)
            if windowLastHeld == i then
                djui_hud_set_color(100, 100, 100, 255)
            else
                djui_hud_set_color(200, 200, 200, 255)
            end
            djui_hud_print_text("Debug Console "..DEBUG_CONSOLE_VERSION, console.windowX + 30, console.windowY + 4, 1.5)
            djui_hud_set_color(255, 0, 0, console.exitAnimTimer)
            djui_hud_render_rect(console.windowX + console.windowWidth - 50, console.windowY, 50, 30)
            djui_hud_set_color(console.exitAnimTimer, console.exitAnimTimer, console.exitAnimTimer, 255)
            djui_hud_set_rotation(0x2000, 0.5, 0.5)
            djui_hud_render_rect(console.windowX + console.windowWidth - 31, console.windowY + 14, 15, 1)
            djui_hud_render_rect(console.windowX + console.windowWidth - 23, console.windowY + 7, 1, 15)
            djui_hud_set_rotation(0, 0, 0)
            djui_hud_set_font(FONT_CONSOLE)
            djui_hud_set_color(255, 255, 255, 255)
            for i = 1, math.min(#stringTable, (console.windowHeight/console.scale - 15 - fontHeight)*MATH_DIVIDE_FONT_HEIGHT) do
                djui_hud_print_text(stringTable[i], console.windowX + 10, console.windowY + 30 + (12*(i - 1))*console.scale, console.scale)
            end
        end

        
        if is_game_paused() then
            djui_hud_render_texture(gTextures.coin, mouseX, mouseY, 2, 2)

            if #consoleWindows < 1 then return end
            for i = 1, #consoleWindows do
                console = consoleWindows[i]
                if (mouseX > console.windowX - 20 and mouseX < console.windowX or mouseX > console.windowX + console.windowWidth and mouseX < console.windowX + console.windowWidth + 20) and (mouseY > console.windowY and mouseY < console.windowY + console.windowHeight) then
                    djui_hud_set_rotation(0x4000, 0.5, 0.5)
                    djui_hud_render_texture(gTextures.arrow_up, mouseX - 10, mouseY - 20, 2, 2)
                    djui_hud_render_texture(gTextures.arrow_down, mouseX + 10, mouseY - 20, 2, 2)
                    djui_hud_set_rotation(0x0, 0.5, 0.5)
                end
                if (mouseY > console.windowY - 20 and mouseY < console.windowY or mouseY > console.windowY + console.windowHeight and mouseY < console.windowY + console.windowHeight + 20) and (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth) then
                    djui_hud_render_texture(gTextures.arrow_up, mouseX, mouseY - 15, 2, 2)
                    djui_hud_render_texture(gTextures.arrow_down, mouseX, mouseY + 5, 2, 2)
                end
            end
        end
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

local pageScrollCooldown = 0
local function mouse_handler(m)
    if m.playerIndex ~= 0 then return end
    if is_game_paused() then
        local mouseX = djui_hud_get_mouse_x()
        local mouseY = djui_hud_get_mouse_y()
        if consoleWindows[windowLastHeld] == nil then
            if #consoleWindows > 0 then
                repeat
                    windowLastHeld = windowLastHeld - 1
                until consoleWindows[windowLastHeld] ~= nil
            else
                windowLastHeld = 1
            end
        end
        if #consoleWindows < 1 then windowLastHeld = 0 return end
        for i = #consoleWindows, 1, -1 do
            if windowHeld == 0 or windowHeld == i then
                if windowHeld ~= 0 then windowLastHeld = windowHeld end
                local console = consoleWindows[i]
                -- Window Movement
                if (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth - 50 and mouseY > console.windowY and mouseY < console.windowY + 30) or console.windowHoldPoint == 1 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        console.windowX = mouseX - console.mouseWindowOffsetX
                        console.windowY = mouseY - console.mouseWindowOffsetY
                        console.windowHoldPoint = 1
                        windowHeld = i
                        nullify_inputs(m)
                    else
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        console.windowHoldPoint = 0
                        windowHeld = 0
                    end
                end

                -- Window Closing
                if (mouseX > console.windowX + console.windowWidth - 50 and mouseX < console.windowX + console.windowWidth and mouseY > console.windowY and mouseY < console.windowY + 30) then
                    if m.controller.buttonPressed & A_BUTTON ~= 0 or m.controller.buttonPressed & B_BUTTON ~= 0 then
                        console_delete(i)
                        windowHeld = i
                        nullify_inputs(m)
                    else
                        windowHeld = 0
                    end
                    console.exitAnimTimer = math.min(console.exitAnimTimer + 40, 255)
                else
                    console.exitAnimTimer = math.max(console.exitAnimTimer - 40, 0)
                end

                -- Window Horizontal Scaling
                if (mouseX > console.windowX - 20 and mouseX < console.windowX or mouseX > console.windowX + console.windowWidth and mouseX < console.windowX + console.windowWidth + 20) and (mouseY > console.windowY and mouseY < console.windowY + console.windowHeight) or console.windowHoldPoint == 2 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        if mouseX > console.windowX + console.windowWidth*0.5 then
                            console.windowWidth = math.max(mouseX - console.windowX, console.windowWidthMin*console.scale)
                        else
                            --[[
                            console.windowX = (windowWidth >= 200*scale and mouseX or console.windowX)
                            console.windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                            ]]
                        end
                        console.windowHoldPoint = 2
                        windowHeld = i
                        nullify_inputs(m)
                    else
                        --[[
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        prevWindowX = console.windowX
                        prevWindowWidth = console.windowWidth]]
                        console.windowHoldPoint = 0
                        windowHeld = 0
                    end
                end

                -- Window Vertical Scaling
                if (mouseY > console.windowY - 20 and mouseY < console.windowY or mouseY > console.windowY + console.windowHeight and mouseY < console.windowY + console.windowHeight + 20) and (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth) or console.windowHoldPoint == 3 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        if mouseY > console.windowY + console.windowHeight*0.5 then
                            console.windowHeight = math.max(mouseY - console.windowY, console.windowHeightMin*console.scale)
                        else
                            --[[
                            console.windowX = (windowWidth >= 200*scale and mouseX or console.windowX)
                            console.windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                            ]]
                        end
                        console.windowHoldPoint = 3
                        windowHeld = i
                        nullify_inputs(m)
                    else
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        console.prevWindowX = console.windowX
                        console.prevWindowWidth = console.windowWidth
                        console.windowHoldPoint = 0
                        windowHeld = 0
                    end
                end
            end
        end
    end

    if windowLastHeld ~= 0 and consoleWindows[windowLastHeld] ~= nil then
        if pageScrollCooldown <= 0 then
            local console = consoleWindows[windowLastHeld]
            if m.controller.buttonDown & L_JPAD ~= 0 then
                console.consolePage = console.consolePage - 1
                pageScrollCooldown = 5
            end
            if m.controller.buttonDown & R_JPAD ~= 0 then
                console.consolePage = console.consolePage + 1
                pageScrollCooldown = 5
            end
            if console.consolePage < 1 then console.consolePage = #consolePageData end
            if console.consolePage > #consolePageData then console.consolePage = 1 end
        else
            pageScrollCooldown = pageScrollCooldown - 1
        end
    end
end

local function console_command()
    if #consoleWindows < 3 then
        console_create()
    else
        djui_chat_message_create("Failed to open Console: Too many console instances open")
    end
    return true
end

hook_event(HOOK_CHARACTER_SOUND, get_current_sound)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, mouse_handler)
hook_chat_command("debug-console", "Opens the Debugging Console", console_command)