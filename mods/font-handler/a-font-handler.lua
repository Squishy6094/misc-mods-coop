--[[
    This file adds custom font functionality
    This file does not need to be edited
    Ensure this file is loaded before anything else (make the file name start with a or !)
    Use djui_hud_add_font() to add fonts as shown in main.lua
    Please Credit Squishy 6094 if you are using this for your own mod >v<
]]

local djui_classic_hud_set_font = djui_hud_set_font
local djui_classic_hud_print_text = djui_hud_print_text
local djui_classic_hud_measure_text = djui_hud_measure_text

local customFont = false

local fontTable = {}

CUSTOM_FONT_COUNT = FONT_COUNT
local customFontType = 0

---@param texture TextureInfo
---@param info table
---@param spacing integer|nil
---@param backup string|nil
---@param scale integer|nil
---@return integer
function djui_hud_add_font(texture, info, spacing, offset, backup, scale)
    if texture == nil then return 0 end
    if info == nil then return 0 end
    if spacing == nil then spacing = 1 end
    if offset == nil then offset = 0 end
    if backup == nil then backup = "x" end
    if scale == nil then scale = 1 end
    CUSTOM_FONT_COUNT = CUSTOM_FONT_COUNT + 1
    fontTable[CUSTOM_FONT_COUNT] = {
        spritesheet = texture,
        spacing = spacing,
        offset = offset,
        info = info,
        backup = backup,
        scale = scale,
    }
    return CUSTOM_FONT_COUNT
end

function djui_hud_set_font(fontType)
    if fontType > FONT_COUNT then
        customFont = true
        customFontType = fontType
    else
        customFont = false
        djui_classic_hud_set_font(fontType)
    end
end

function djui_hud_print_text(message, x, y, scale)
    if customFont then
        if message == nil or message == "" then return 0 end
        local currFont = fontTable[customFontType]
        y = y + currFont.offset
        scale = scale*currFont.scale
        for i = 1, #message do
            local letter = message:sub(i,i)
            if letter and letter ~= " " then
                if currFont.info[letter] == nil then
                    letter = currFont.backup
                end
                local scaleWidth = scale*(currFont.info[letter].height/currFont.info[letter].width)
                djui_hud_render_texture_tile(currFont.spritesheet, x, y, scaleWidth, scale, currFont.info[letter].x, currFont.info[letter].y, currFont.info[letter].width, currFont.info[letter].height)
            else
                letter = currFont.backup
            end
            x = x + (currFont.info[letter].width + currFont.spacing)*scale
        end
    else
        djui_classic_hud_print_text(message, x, y, scale)
    end
end

---@param message string|nil
---@return number
function djui_hud_measure_text(message)
    if customFont then
        if message == nil or message == "" then return 0 end
        local currFont = fontTable[customFontType]
        local output = 0
        for i = 1, #message do
            local letter = message:sub(i,i)
            if currFont.info[letter] == nil or letter == " " then
                letter = currFont.backup
            end
            output = output + (currFont.info[letter].width + (i ~= #message and currFont.spacing or 0))*currFont.scale
        end
        return output
    else
        return djui_classic_hud_measure_text(message)
    end
end

local fontInfoDs = {
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
}

FONT_NORMAL = djui_hud_add_font(get_texture_info("font-ds"), fontInfoDs, 1, 3, "x", 2)