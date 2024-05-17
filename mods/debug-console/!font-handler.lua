--[[
    Custom Font Handler - By Squishy 6094

    This file adds custom font functionality, and does not need to be edited
    Ensure this file is loaded before anything else (make the file name start with a or !)
    Use djui_hud_add_font() to add fonts as shown in main.lua
]]

local djui_classic_hud_set_font = djui_hud_set_font
local djui_classic_hud_print_text = djui_hud_print_text
local djui_classic_hud_print_text_interpolated = djui_hud_print_text_interpolated
local djui_classic_hud_measure_text = djui_hud_measure_text

local customFont = false

local fontTable = {}

CUSTOM_FONT_COUNT = FONT_COUNT
local customFontType = FONT_NORMAL

---@param texture TextureInfo
---@param info table
---@param spacing integer
---@param offset integer
---@param backup string
---@param scale integer
---@return DjuiFontType
function djui_hud_add_font(texture, info, spacing, offset, backup, scale)
    if texture == nil then return FONT_NORMAL end
    if info == nil then return FONT_NORMAL end
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

---@param fontType DjuiFontType
---@return nil
function djui_hud_set_font(fontType)
    if fontType > FONT_COUNT then
        customFont = true
        customFontType = fontType
    else
        customFont = false
        djui_classic_hud_set_font(fontType)
    end
end

---@param message string
---@param x number
---@param y number
---@param scale number
---@return nil
function djui_hud_print_text(message, x, y, scale)
    if customFont then
        if message == nil or message == "" then return end
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

---@param message string
---@param prevX number
---@param prevY number
---@param prevScale number
---@param x number
---@param y number
---@param scale number
---@return nil
-- Custom Fonts do not currently support Interpolation due to lack of RESOLUTION_N64 support
function djui_hud_print_text_interpolated(message, prevX, prevY, prevScale, x, y, scale)
    if customFont then
        if message == nil or message == "" then return end
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
        djui_classic_hud_print_text_interpolated(message, prevX, prevY, prevScale, x, y, scale)
    end
end

---@param message string
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