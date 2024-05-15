-- name: Custom Font Handler
-- description: Utility that allows modders to easily implement Custom Fonts via Lua. Just drag \\#7777ff\\a-font-handler.lua\\#dcdcdc\\ into your mod's folder!\n\nCreated by: \\#008800\\Squishy 6094

--[[
    This example showcases how the default functions
    work cleanly with the custom font without having
    to manually mess with textures tiling
]]


local fontInfoDs = { -- Maps textures in a spritesheet to letters
    ["A"] = {x = 0, y = 0, width = 5, height = 9},
    ["B"] = {x = 6, y = 0, width = 5, height = 9},
    ["C"] = {x = 12, y = 0, width = 5, height = 9},
    ["D"] = {x = 18, y = 0, width = 5, height = 9},
    ["E"] = {x = 24, y = 0, width = 4, height = 9},
    ["F"] = {x = 29, y = 0, width = 4, height = 9},
    ["G"] = {x = 34, y = 0, width = 5, height = 9},
    ["H"] = {x = 40, y = 0, width = 5, height = 9},
    ["I"] = {x = 46, y = 0, width = 1, height = 9},
    ["J"] = {x = 48, y = 0, width = 4, height = 9},
    ["K"] = {x = 53, y = 0, width = 5, height = 9},
    ["L"] = {x = 59, y = 0, width = 4, height = 9},
    ["M"] = {x = 64, y = 0, width = 5, height = 9},
    ["N"] = {x = 70, y = 0, width = 5, height = 9},
    ["O"] = {x = 76, y = 0, width = 5, height = 9},
    ["P"] = {x = 82, y = 0, width = 5, height = 9},
    ["Q"] = {x = 88, y = 0, width = 5, height = 10},
    ["R"] = {x = 94, y = 0, width = 5, height = 9},
    ["S"] = {x = 100, y = 0, width = 4, height = 9},
    ["T"] = {x = 105, y = 0, width = 5, height = 9},
    ["U"] = {x = 111, y = 0, width = 5, height = 9},
    ["V"] = {x = 117, y = 0, width = 5, height = 9},
    ["W"] = {x = 123, y = 0, width = 5, height = 9},
    ["X"] = {x = 129, y = 0, width = 5, height = 9},
    ["Y"] = {x = 135, y = 0, width = 5, height = 9},
    ["Z"] = {x = 141, y = 0, width = 4, height = 9},
    
    ["a"] = {x = 0, y = 11, width = 5, height = 9},
    ["b"] = {x = 6, y = 11, width = 5, height = 9},
    ["c"] = {x = 12, y = 11, width = 5, height = 9},
    ["d"] = {x = 18, y = 11, width = 5, height = 9},
    ["e"] = {x = 24, y = 11, width = 5, height = 9},
    ["f"] = {x = 30, y = 11, width = 4, height = 9},
    ["g"] = {x = 35, y = 11, width = 5, height = 10},
    ["h"] = {x = 41, y = 11, width = 5, height = 9},
    ["i"] = {x = 47, y = 11, width = 1, height = 9},
    ["j"] = {x = 49, y = 11, width = 3, height = 10},
    ["k"] = {x = 53, y = 11, width = 4, height = 9},
    ["l"] = {x = 58, y = 11, width = 2, height = 9},
    ["m"] = {x = 61, y = 11, width = 7, height = 9},
    ["n"] = {x = 69, y = 11, width = 5, height = 9},
    ["o"] = {x = 75, y = 11, width = 5, height = 9},
    ["p"] = {x = 81, y = 11, width = 5, height = 10},
    ["q"] = {x = 87, y = 11, width = 5, height = 10},
    ["r"] = {x = 93, y = 11, width = 4, height = 9},
    ["s"] = {x = 98, y = 11, width = 4, height = 9},
    ["t"] = {x = 103, y = 11, width = 4, height = 9},
    ["u"] = {x = 108, y = 11, width = 5, height = 9},
    ["v"] = {x = 114, y = 11, width = 5, height = 9},
    ["w"] = {x = 120, y = 11, width = 5, height = 9},
    ["x"] = {x = 126, y = 11, width = 5, height = 9},
    ["y"] = {x = 132, y = 11, width = 5, height = 10},
    ["z"] = {x = 138, y = 11, width = 5, height = 9},
    
    ["1"] = {x = 0, y = 22, width = 2, height = 9},
    ["2"] = {x = 3, y = 22, width = 5, height = 9},
    ["3"] = {x = 9, y = 22, width = 5, height = 9},
    ["4"] = {x = 15, y = 22, width = 6, height = 9},
    ["5"] = {x = 22, y = 22, width = 5, height = 9},
    ["6"] = {x = 28, y = 22, width = 5, height = 9},
    ["7"] = {x = 34, y = 22, width = 5, height = 9},
    ["8"] = {x = 40, y = 22, width = 5, height = 9},
    ["9"] = {x = 46, y = 22, width = 5, height = 9},
    ["0"] = {x = 52, y = 22, width = 5, height = 9},
    
    ["+"] = {x = 58, y = 22, width = 5, height = 9},
    ["-"] = {x = 64, y = 22, width = 5, height = 9},
    ["_"] = {x = 70, y = 22, width = 5, height = 9},
    ["="] = {x = 76, y = 22, width = 5, height = 9},
    ["."] = {x = 82, y = 22, width = 1, height = 9},
    [","] = {x = 84, y = 22, width = 2, height = 10},
    ["!"] = {x = 87, y = 22, width = 1, height = 9},
    ["?"] = {x = 89, y = 22, width = 4, height = 9},
    ["'"] = {x = 94, y = 22, width = 1, height = 9},
    ['"'] = {x = 94, y = 22, width = 3, height = 9},
    ["("] = {x = 98, y = 22, width = 3, height = 9},
    [")"] = {x = 102, y = 22, width = 3, height = 9},
    ["["] = {x = 106, y = 22, width = 3, height = 9},
    ["]"] = {x = 110, y = 22, width = 3, height = 9},
    ["{"] = {x = 114, y = 22, width = 4, height = 9},
    ["}"] = {x = 119, y = 22, width = 4, height = 9},
    ["@"] = {x = 0, y = 32, width = 7, height = 9},
    ["#"] = {x = 8, y = 32, width = 7, height = 9},
    ["$"] = {x = 16, y = 32, width = 7, height = 9},
    ["%"] = {x = 22, y = 32, width = 7, height = 9},
    ["^"] = {x = 30, y = 32, width = 3, height = 9},
    ["&"] = {x = 34, y = 32, width = 6, height = 9},
    ["*"] = {x = 41, y = 32, width = 7, height = 9},
    ["~"] = {x = 49, y = 32, width = 5, height = 9},
    [":"] = {x = 55, y = 32, width = 1, height = 9},
    [";"] = {x = 57, y = 32, width = 2, height = 9},
}

-- Font can use a unique variable, or an existing font to overwrite it
FONT_DSBIOS = djui_hud_add_font(get_texture_info("font-ds"), fontInfoDs, 1, 3, "x", 2)

local TEXT_SM64 = "Super Mario 64"
local TEXT_DSBIOS = "Nintendo DS Bios"

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_color(0, 0, 0, 255)
    local widthHalf = djui_hud_get_screen_width()*0.5

    djui_hud_set_font(FONT_NORMAL)
    djui_hud_print_text(TEXT_SM64, widthHalf - djui_hud_measure_text(TEXT_SM64)*0.5, 20, 1)
    djui_hud_set_font(FONT_DSBIOS)
    djui_hud_print_text(TEXT_DSBIOS, widthHalf - djui_hud_measure_text(TEXT_DSBIOS)*0.5, 60, 1)
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)