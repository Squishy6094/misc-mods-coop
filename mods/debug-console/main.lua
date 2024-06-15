-- name: Debug Console
-- description: Debugging Console themed around Window's \\#888888\\cmd.exe\\#dcdcdc\\!

--[[
    This example showcases how the default functions
    work cleanly with the custom font without having
    to manually mess with textures tiling
]]

---@param x number
---@return integer
--- Returns the nearsest integral value to `x`
function math.round(x)
    return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

--- @param string string
--- Splits a string into a table by spaces
function string_split(string)
    local result = {}
    for match in string:gmatch(string.format("[^%s]+", " ")) do
        table.insert(result, match)
    end
    return result
end

local DEBUG_CONSOLE_VERSION = "v1 (In-Dev)"

--Tables from a-tables.lua
local fontInfoConsole, infoActionTable, infoLevelTable, infoVoicesTable = fontInfoConsole, infoActionTable, infoLevelTable, infoVoicesTable

-- Settings Options
local currOption = 1
local optionTableRef = {
    winScale = 1,
    unpauseDpad = 2,
    unpauseMouse = 3,
    bootupWin = 4,
    transWin = 5,
}

local optionTable = {
    [optionTableRef.winScale] = {
        name = "Window Scale",
        toggle = tonumber(mod_storage_load("winScale")),
        toggleSaveName = "winScale",
        toggleDefault = 1,
        toggleMax = 3,
        toggleNames = {"#---", "##--", "###-", "####"},
    },
    [optionTableRef.unpauseDpad] = {
        name = "Unpaused D-pad",
        toggle = tonumber(mod_storage_load("unpauseDpad")),
        toggleSaveName = "unpauseDpad",
        toggleDefault = 1,
        toggleMax = 1,
    },
    [optionTableRef.unpauseMouse] = {
        name = "Unpaused Mouse",
        toggle = tonumber(mod_storage_load("unpauseMouse")),
        toggleSaveName = "unpauseMouse",
        toggleDefault = 0,
        toggleMax = 1,
    },
    [optionTableRef.bootupWin] = {
        name = "Bootup Window",
        toggle = tonumber(mod_storage_load("bootupWin")),
        toggleSaveName = "bootupWin",
        toggleDefault = 1,
        toggleMax = 1,
    },
    [optionTableRef.transWin] = {
        name = "Translucent Window",
        toggle = tonumber(mod_storage_load("transWin")),
        toggleSaveName = "transWin",
        toggleDefault = 0,
        toggleMax = 1,
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
            optionTable[i].toggleNames = {"X", "O"}
        end
    end
end

local defaultX = 50
local defaultY = 200
local defaultWidth = 300
local defaultHeight = 300

local modStorageVars = {
    windowX = (mod_storage_load("windowX") ~= "" and tonumber(mod_storage_load("windowX")) or defaultX),
    windowY = (mod_storage_load("windowY") ~= "" and tonumber(mod_storage_load("windowY")) or defaultY),
    windowWidth = (mod_storage_load("windowW") ~= "" and tonumber(mod_storage_load("windowW")) or defaultWidth),
    windowHeight = (mod_storage_load("windowH") ~= "" and tonumber(mod_storage_load("windowH")) or defaultHeight),
    windowPage = (mod_storage_load("windowP") ~= "" and tonumber(mod_storage_load("windowP")) or 1),
}
local function mod_storage_update_window(x, y, width, height, page)
    if modStorageVars.windowX ~= x then
        mod_storage_save("windowX", tostring(x))
        modStorageVars.windowX = x
    end
    if modStorageVars.windowY ~= y then
        mod_storage_save("windowY", tostring(y))
        modStorageVars.windowY = y
    end
    if modStorageVars.windowWidth ~= width then
        mod_storage_save("windowW", tostring(width))
        modStorageVars.windowWidth = width
    end
    if modStorageVars.windowHeight ~= height then
        mod_storage_save("windowH", tostring(height))
        modStorageVars.windowHeight = height
    end
    if modStorageVars.windowPage ~= page then
        mod_storage_save("windowP", tostring(page))
        modStorageVars.windowPage = page
    end
end

failsafe_options()

local stringTable = {}

-- Font can use a unique variable, or an existing font to overwrite it
FONT_CONSOLE = djui_hud_add_font(get_texture_info("font-console"), fontInfoConsole, 1, 3, "_", 1)

local consoleToggle = true
local consoleWindows = {}
local defaultScale = 1.5
local windowHeld = 0
local windowLastHeld = 1

local function console_create()
    table.insert(consoleWindows, {
        consolePage = modStorageVars.windowPage --[[(#consoleWindows == 0 and 1 or 3)]],

        scale = defaultScale,
        windowX = (consoleWindows[windowLastHeld] ~= nil and consoleWindows[windowLastHeld].windowX + 40 or modStorageVars.windowX),
        windowY = (consoleWindows[windowLastHeld] ~= nil and consoleWindows[windowLastHeld].windowY + 40 or modStorageVars.windowY),
        windowWidth = modStorageVars.windowWidth,
        windowHeight = modStorageVars.windowHeight,
        windowWidthMin = 204,
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

if optionTable[optionTableRef.bootupWin].toggle == 1 then
    console_create()
end

local fontWidth = fontInfoConsole["_"].width
local fontHeight = fontInfoConsole["_"].height
local MATH_DIVIDE_FONT_WIDTH = 1/(fontWidth + 1)
local MATH_DIVIDE_FONT_HEIGHT = 1/(fontHeight + 1)
local MATH_DIVIDE_ANGLE = 65536/360

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
            if i%math.floor((console.windowWidth * console.scale - 10 - fontWidth)/console.scale*MATH_DIVIDE_FONT_WIDTH) == 0 then
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
    settings = 2,
    player = 3,
    area = 4,
    custom = 5,
}

local lastCharacterSound = 0
local function get_current_sound(m, voice)
    if m.playerIndex ~= 0 then return end
    lastCharacterSound = voice
end

local customPageTextDefault = {"Commands:", " /debug-console text [text]", "   Add line", " /debug-console text clear", "   Clears all lines"}
local customPageText = customPageTextDefault
local consolePageData = {
    [consolePageList.welcome] = {
        name = "Welcome!",
        textFunc = function (m, console)
            console_add_lines(console, { 
                "------------------------",
                "Debug Console "..DEBUG_CONSOLE_VERSION,
                "Made by Squishy6094",
                "",
                "Font Handler v0.5",
                "------------------------",
                " ",
                "Welcome to Debugging Console!",
                "This mod has Debugging Windows",
                "Which can be moved around while",
                "paused like any other window can!",
                " ",
                "You can use D-pad Left or Right",
                "To change 'Pages' which tell you",
                "different info based on different",
                "categories."
            })
        end
    },
    [consolePageList.settings] = {
        name = "Settings",
        textFunc = function (m, console)
            local displayTable = {}
            for i = 1, #optionTable do
                displayTable[i] = (i == currOption and "> " or "  ")..optionTable[i].name.." ("..optionTable[i].toggleNames[optionTable[i].toggle + 1]..")"
            end
            displayTable[#displayTable + 1] = " "
            displayTable[#displayTable + 1] = "Inputs Disabled"
            displayTable[#displayTable + 1] = "Up/Down to Navigate"
            displayTable[#displayTable + 1] = "A button to Toggle"
            displayTable[#displayTable + 1] = "B button to Go to Next Page"
            console_add_lines(console, displayTable)
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
                "Angle: "..(math.round(m.faceAngle.y/MATH_DIVIDE_ANGLE)+180).." ("..m.faceAngle.y..")",
                "Action: "..(infoActionTable[m.action] ~= nil and infoActionTable[m.action] or "???"),
                "  Arg: "..m.actionArg.." Timer: "..m.actionTimer,
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
                "Pos: "..math.floor(m.pos.x)..", "..math.floor(m.pos.y)..", "..math.floor(m.pos.z),
                "Level: "..infoLevelTable[np.currLevelNum].." ("..np.currLevelNum..")",
                "Act: ("..np.currActNum..")",
                "Area: ("..np.currAreaIndex..")",
            })
        end
    },
    [consolePageList.custom] = {
        name = "Custom Page",
        textFunc = function (m, console)
            console_add_lines(console, customPageText)
        end
    },
}

if _G.charSelectExists then
    local forceCharTable = {
        [CT_MARIO] = "CT_MARIO",
        [CT_LUIGI] = "CT_LUIGI",
        [CT_TOAD] = "CT_TOAD",
        [CT_WALUIGI] = "CT_WALUIGI",
        [CT_WARIO] = "CT_WARIO",
    }

    consolePageList.charSelect = #consolePageData + 1
    consolePageData[consolePageList.charSelect] = {
        name = "Character Select",
        textFunc = function (m, console)
            local currTable = _G.charSelect.character_get_current_table()
            console_add_lines(console, {
                "Name: "..currTable.name,
                "Save Name: "..currTable.saveName,
                "Credit: "..currTable.credit,
                "Description: ",
            })
            console_add_lines(console, currTable.description)
            console_add_lines(console, {
                "Color: "..currTable.color.r..", "..currTable.color.g..", "..currTable.color.b..", ",
                "Forced: "..forceCharTable[currTable.forceChar].." ("..currTable.forceChar..")",
                "Table Pos: ".._G.charSelect.character_get_current_number(),
                "Camera Scale: "..currTable.camScale,
            })
        end
    }
end

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local m = gMarioStates[0]

    if defaultScale ~= (optionTable[optionTableRef.winScale].toggle + 1)*0.5 then
        defaultScale = (optionTable[optionTableRef.winScale].toggle + 1)*0.5
        if #consoleWindows > 0 then 
            for i = 1, #consoleWindows do
                consoleWindows[i].scale = defaultScale
            end
        end
        
    end

    if consoleToggle then
        local mouseX = djui_hud_get_mouse_x()
        local mouseY = djui_hud_get_mouse_y()

        if #consoleWindows < 1 then return end
        for i = 1, #consoleWindows do
            local console = consoleWindows[i]
            local scale = console.scale
            stringTable = {}

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
                    "< Next Page | Prev Page >",
                    "Use mouse to adjust Window"
                })
            elseif optionTable[optionTableRef.unpauseDpad].toggle == 1 then
                console_add_lines(console, {
                    " ",
                    "< Next Page | Prev Page >",
                })
            end

            djui_hud_set_color(0, 0, 0, (optionTable[optionTableRef.transWin].toggle == 0 and 255 or 150))
            djui_hud_render_rect(console.windowX, console.windowY, console.windowWidth * scale, console.windowHeight * scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_rect(console.windowX, console.windowY, console.windowWidth * scale, 30)
            djui_hud_render_texture(gTextures.star, console.windowX + 6, console.windowY + 5, 1.3, 1.3)
            djui_hud_set_font(FONT_TINY)
            if windowLastHeld == i then
                djui_hud_set_color(100, 100, 100, 255)
            else
                djui_hud_set_color(200, 200, 200, 255)
            end
            djui_hud_print_text("Debug Console "..DEBUG_CONSOLE_VERSION, console.windowX + 30, console.windowY + 4, 1.5)
            djui_hud_set_color(255, 0, 0, console.exitAnimTimer)
            djui_hud_render_rect(console.windowX + console.windowWidth * scale - 50, console.windowY, 50, 30)
            djui_hud_set_color(console.exitAnimTimer, console.exitAnimTimer, console.exitAnimTimer, 255)
            djui_hud_set_rotation(0x2000, 0.5, 0.5)
            djui_hud_render_rect(console.windowX + console.windowWidth * scale - 31, console.windowY + 14, 15, 1)
            djui_hud_render_rect(console.windowX + console.windowWidth * scale - 23, console.windowY + 7, 1, 15)
            djui_hud_set_rotation(0, 0, 0)
            djui_hud_set_font(FONT_CONSOLE)
            djui_hud_set_color(255, 255, 255, 255)
            for l = 1, math.min(#stringTable, (console.windowHeight - 15 - fontHeight)*MATH_DIVIDE_FONT_HEIGHT) do
                djui_hud_print_text(stringTable[l], console.windowX + 10, console.windowY + 30 + (12*(l - 1))*console.scale, console.scale)
            end
        end

        
        if (optionTable[optionTableRef.unpauseMouse].toggle == 1 or is_game_paused()) then
            djui_hud_render_texture(gTextures.coin, mouseX, mouseY, 2, 2)

            if #consoleWindows < 1 then return end
            for i = #consoleWindows, 1, -1 do
                local console = consoleWindows[i]
                local scale = console.scale
                if (mouseX > console.windowX - 20 and mouseX < console.windowX or mouseX > console.windowX + console.windowWidth * scale and mouseX < console.windowX + console.windowWidth * scale + 20) and (mouseY > console.windowY and mouseY < console.windowY + console.windowHeight * scale) then
                    djui_hud_set_rotation(0x4000, 0.5, 0.5)
                    djui_hud_render_texture(gTextures.arrow_up, mouseX - 10, mouseY - 20, 2, 2)
                    djui_hud_render_texture(gTextures.arrow_down, mouseX + 10, mouseY - 20, 2, 2)
                    djui_hud_set_rotation(0x0, 0.5, 0.5)
                end
                if (mouseY > console.windowY - 20 and mouseY < console.windowY or mouseY > console.windowY + console.windowHeight * scale and mouseY < console.windowY + console.windowHeight * scale + 20) and (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth * scale) then
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

local inputStallTimerButton = 0
local inputStallTimerDirectional = 0
local inputStallToDirectional = 10
local inputStallToButton = 7
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    -- Mouse Handler
    if (optionTable[optionTableRef.unpauseMouse].toggle == 1 or is_game_paused()) then
        local mouseX = djui_hud_get_mouse_x()
        local mouseY = djui_hud_get_mouse_y()
        if consoleWindows[windowLastHeld] == nil then
            if #consoleWindows > 0 then
                repeat
                    windowLastHeld = windowLastHeld - 1
                until consoleWindows[windowLastHeld] ~= nil or windowLastHeld < 1
            else
                windowLastHeld = 1
            end
        end
        windowHeld = 0
        if #consoleWindows < 1 then windowLastHeld = 0 return end
        for i = #consoleWindows, 1, -1 do
            local console = consoleWindows[i]
            local scale = console.scale

            -- Window Focus
            if (mouseX > console.windowX -20 and mouseX < console.windowX + console.windowWidth * scale + 20 and mouseY > console.windowY - 20 and mouseY < console.windowY + console.windowHeight * scale + 20) then
                if m.controller.buttonPressed & A_BUTTON ~= 0 or m.controller.buttonPressed & B_BUTTON ~= 0 then
                    if windowHeld == 0 then
                        if i ~= #consoleWindows then
                            consoleWindows[#consoleWindows + 1] = consoleWindows[i]
                            table.remove(consoleWindows, i)
                        end
                        windowHeld = #consoleWindows
                    end
                end
            end

            -- Window Closing
            if (mouseX > console.windowX + console.windowWidth * scale - 50 and mouseX < console.windowX + console.windowWidth * scale and mouseY > console.windowY and mouseY < console.windowY + 30) then
                if m.controller.buttonPressed & A_BUTTON ~= 0 or m.controller.buttonPressed & B_BUTTON ~= 0 then
                    table.remove(consoleWindows, #consoleWindows)
                    windowLastHeld = 0
                    nullify_inputs(m)
                end
                console.exitAnimTimer = math.min(console.exitAnimTimer + 40, 255)
            else
                console.exitAnimTimer = math.max(console.exitAnimTimer - 40, 0)
            end

            if windowHeld == 0 or windowHeld == i then
                -- Window Movement
                if (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth * scale - 50 and mouseY > console.windowY and mouseY < console.windowY + 30) or console.windowHoldPoint == 1 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        console.windowX = mouseX - console.mouseWindowOffsetX
                        console.windowY = mouseY - console.mouseWindowOffsetY
                        console.windowHoldPoint = 1
                        windowHeld = #consoleWindows
                        nullify_inputs(m)
                    else
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        console.windowHoldPoint = 0
                    end
                end

                -- Window Horizontal Scaling
                if (mouseX > console.windowX - 20 and mouseX < console.windowX or mouseX > console.windowX + console.windowWidth * scale and mouseX < console.windowX + console.windowWidth * scale + 20) and (mouseY > console.windowY and mouseY < console.windowY + console.windowHeight * scale) or console.windowHoldPoint == 2 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        if mouseX > console.windowX + console.windowWidth * scale*0.5 then
                            console.windowWidth = math.max((mouseX - console.windowX)/scale, console.windowWidthMin)
                        else
                            --[[
                            console.windowX = (windowWidth >= 200*scale and mouseX or console.windowX)
                            console.windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                            ]]
                        end
                        console.windowHoldPoint = 2
                        windowHeld = #consoleWindows
                        nullify_inputs(m)
                    else
                        --[[
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        prevWindowX = console.windowX
                        prevWindowWidth = console.windowWidth]]
                        console.windowHoldPoint = 0
                    end
                end

                -- Window Vertical Scaling
                if (mouseY > console.windowY - 20 and mouseY < console.windowY or mouseY > console.windowY + console.windowHeight * scale and mouseY < console.windowY + console.windowHeight * scale + 20) and (mouseX > console.windowX and mouseX < console.windowX + console.windowWidth * scale) or console.windowHoldPoint == 3 then
                    if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                        if mouseY > console.windowY + console.windowHeight * scale*0.5 then
                            console.windowHeight = math.max((mouseY - console.windowY)/scale, console.windowHeightMin)
                        else
                            --[[
                            console.windowX = (windowWidth >= 200*scale and mouseX or console.windowX)
                            console.windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                            ]]
                        end
                        console.windowHoldPoint = 3
                        windowHeld = #consoleWindows
                        nullify_inputs(m)
                    else
                        console.mouseWindowOffsetX = mouseX - console.windowX
                        console.mouseWindowOffsetY = mouseY - console.windowY
                        console.prevWindowX = console.windowX
                        console.prevWindowWidth = console.windowWidth
                        console.windowHoldPoint = 0
                    end
                end
                if windowLastHeld == i then
                    mod_storage_update_window(console.windowX, console.windowY, console.windowWidth, console.windowHeight, console.consolePage)
                end
            end
            if windowHeld ~= 0 then windowLastHeld = windowHeld end
        end
    end

    if windowLastHeld ~= 0 and consoleWindows[windowLastHeld] ~= nil and (optionTable[optionTableRef.unpauseDpad].toggle == 1 or is_game_paused()) then
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

    -- Settings Handler
    if #consoleWindows > 0 and consoleWindows[windowLastHeld] ~= nil and consoleWindows[windowLastHeld].consolePage == consolePageList.settings then
        if inputStallTimerButton > 0 then inputStallTimerButton = inputStallTimerButton - 1 end
        if inputStallTimerDirectional > 0 then inputStallTimerDirectional = inputStallTimerDirectional - 1 end
        local cameraToObject = gMarioStates[0].marioObj.header.gfx.cameraToObject
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
                consoleWindows[windowLastHeld].consolePage = optionTableRef.unpauseDpad + 1
                inputStallTimerButton = inputStallToButton
            end
        end
        if currOption > #optionTable then currOption = 1 end
        if currOption < 1 then currOption = #optionTable end
        nullify_inputs(m)
    end
end

local function console_command(msg)
    msg = string_split(msg)
    local command = (msg[1] ~= nil and string.lower(msg[1]) or "")
    if command == "" or command == " " or command == "open" then
        if #consoleWindows < 3 then
            console_create()
        else
            djui_chat_message_create("Failed to open Console: Too many console windows open")
        end
        return true
    end
    if command == "clear" then
        if #consoleWindows > 0 then
            for i = 1, #consoleWindows do
                table.remove(consoleWindows, 1)
            end
            return true
        else
            djui_chat_message_create("Failed to clear Consoles: No windows found!")
            return true
        end
    end
    if command == "text" then
        if string.lower(msg[2]) == "clear" then
            for i = 1, #customPageText do
                table.remove(customPageText, 1)
            end
            djui_chat_message_create("Cleared Page "..consolePageList.custom)
        else
            local output = ""
            for i = 2, #msg do
                output = output..msg[i]..(i ~= #msg and " " or "")
            end
            djui_chat_message_create(output)
            table.insert(customPageText, output)
            djui_chat_message_create("Added Line on Page "..consolePageList.custom)
        end
        return true
    end
end

hook_event(HOOK_CHARACTER_SOUND, get_current_sound)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_chat_command("debug-console", "Opens the Debugging Console", console_command)