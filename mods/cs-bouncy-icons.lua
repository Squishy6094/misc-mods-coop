-- name: [CS] \\#dcdcdc\\Bouncy Icons (Add-on)
-- description: A silly mod for the Character Select Menu, This mod gets every icon available\nin the Character List and bounces it around the menu!! >w<\n\n\C-Left/Right to move icons around\n\\#ffff33\\/char-select-bouncy-icons\\#dcdcdc\\ to toggle\nthe add-on\n\nCreated by:\\#008800\\ Squishy6094\\#dcdcdc\\\n\n\\#ff7777\\This Mod requires Character Select\nto use as a Library!

if not _G.charSelectExists then
    return 0 
end

local math_random = math.random
local math_min = math.min
local math_max = math.max

local iconList = {
    {texture = gTextures.mario_head},
    {texture = gTextures.luigi_head},
    {texture = gTextures.toad_head},
    {texture = gTextures.waluigi_head},
    {texture = gTextures.wario_head},
}

local iconCount = 1

local showIcons = true

local function hud_render()
    local width = djui_hud_get_screen_width() - 15
    local height = 225
    -- Loads all Icons when menu is opened 
    if iconCount == 1 then
        repeat
            iconCount = iconCount + 1
            if _G.charSelect.character_get_current_table(iconCount) and _G.charSelect.character_get_current_table(iconCount).lifeIcon then
                iconList[#iconList + 1] = {
                    texture = _G.charSelect.character_get_current_table(iconCount).lifeIcon,
                }
            end
        until _G.charSelect.character_get_current_table(iconCount) == nil
    end

    djui_hud_set_color(255, 255, 255, 255)
    if not showIcons then return end
    for i = 1, #iconList do
        if iconList[i].texture then
            local icon = iconList[i]
            -- Initialize Physics
            if icon.posX == nil then
                icon.posX = math_random(0, width)
                icon.posY = math_random(0, height)
                icon.velX = math_random(-20, 20)*0.1
                icon.velY = 0
            end
            
            djui_hud_render_texture_interpolated(icon.texture, icon.posX, icon.posY, 1 / (icon.texture.width * 0.0625), 1 / (icon.texture.height * 0.0625), icon.posX + icon.velX, icon.posY + icon.velY, 1 / (icon.texture.width * 0.0625), 1 / (icon.texture.height * 0.0625))

            -- Update Physics
            if (_G.charSelect.controller.buttonDown & L_CBUTTONS) ~= 0 then
                icon.velX = math_max(icon.velX - 0.1, -5)
            end
            if (_G.charSelect.controller.buttonDown & R_CBUTTONS) ~= 0 then
                icon.velX = math_min(icon.velX + 0.1, 5)
            end

            icon.posX = icon.posX + icon.velX
            if icon.posX < 0 or icon.posX > width then
                icon.posX = math_max(math_min(icon.posX, width), 0)
                icon.velX = -math_min(icon.velX*0.9, 5)
            end

            icon.posY = icon.posY + icon.velY
            icon.velY = icon.velY + 0.1
            if icon.posY > height then
                icon.velY = math_random(-60, -10)*0.1
                icon.velX = math_min(icon.velX*1.1, 5)
            end
        end
    end
end

local function toggle()
    showIcons = not showIcons
    return true
end

_G.charSelect.hook_render_in_menu(hud_render)
hook_chat_command("char-select-bouncy-icons", "Toggles the Bouncy Icons Add-on for Character Select", toggle)
