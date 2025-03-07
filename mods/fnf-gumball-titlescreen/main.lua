-- name: FNF Gumballs Titlescreen
-- description: A recreation of the Titlescreen in\n\\#f867c7\\Friday Night Funkin': \\#b7ff7b\\G\\#ffa25a\\u\\#e3f3ff\\m\\#aac2ff\\b\\#587fff\\a\\#653e0b\\l\\#f863e5\\l\\#a47fff\\s\\#dcdcdc\\\nshown off on \\#00acee\\@paigeypaper\\#dcdcdc\\'s Twitter!\n\nCreated by:\\#008800\\ Squishy6094\n\\#dcdcdc\\Original Titlescreen by: \\#c3b8c6\\Paige\n\\#dcdcdc\\Music from: \\#ff7777\\Super Mario 64 Plus\n\n\\#ffff77\\Character Select is supported to add more icons, but not required!

local math_random,math_abs,math_ceil,djui_hud_set_color,djui_hud_set_rotation,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,djui_hud_measure_text,djui_hud_render_rect,djui_hud_render_texture,audio_stream_load,audio_stream_set_looping,audio_stream_play,audio_stream_set_volume,audio_sample_load,audio_sample_play,audio_sample_destroy,set_mario_action = math.random,math.abs,math.ceil,djui_hud_set_color,djui_hud_set_rotation,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,djui_hud_measure_text,djui_hud_render_rect,djui_hud_render_texture,audio_stream_load,audio_stream_set_looping,audio_stream_play,audio_stream_set_volume,audio_sample_load,audio_sample_play,audio_sample_destroy,set_mario_action

local serverSettingInterect = gServerSettings.playerInteractions

local TEX_LOGO = get_texture_info("logo")

local TEXT_PRESS_START = "-Press Start-"

local logoScaleNormal = 0.2
local logoScale = logoScaleNormal
local iconScale = 2.5
local iconScaleTrans = 5

local iconList = {
    {texture = gTextures.mario_head},
    {texture = gTextures.luigi_head},
    {texture = gTextures.toad_head},
    {texture = gTextures.waluigi_head},
    {texture = gTextures.wario_head},
}
local iconListTrans = {}

local bpm = 130
local beatTimer = -1
local scrollTimer = 0

local iconCount = 1
local stallTimer = 0

local showTitlescreen = true
local titleTransMax = 150
local titleTrans = -titleTransMax

local bgColor = {r = 0, g = 0, b = 100}

local tilt = true

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

local audioStream
local playedMusic = false
local function update_music(volume)
    if volume == nil then volume = 2 end
    if not playedMusic then
        audioStream = audio_stream_load("plus-menu-theme.ogg")
        audio_stream_set_looping(audioStream, true)
        if audioStream.loaded then
            audio_stream_play(audioStream, true, volume)
            play_secondary_music(0, 0, 0, 0)
            beatTimer = 1
            playedMusic = true
        end
    end
    audio_stream_set_volume(audioStream, volume)
end

local MATH_BPM = 30*60/bpm

local function hud_render()
    if (not showTitlescreen and titleTrans >= titleTransMax) then return end
    local m = gMarioStates[0]
    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width()
    local height = 240
    if stallTimer < 2 then
        stallTimer = stallTimer + 1
        return
    end
    -- Loads all Icons when menu is opened 
    if iconCount == 1 and _G.charSelectExists then
        repeat
            iconCount = iconCount + 1
            if _G.charSelect.character_get_current_table(iconCount) and _G.charSelect.character_get_current_table(iconCount).lifeIcon then
                iconList[#iconList + 1] = {
                    texture = _G.charSelect.character_get_current_table(iconCount).lifeIcon,
                }
            end
        until _G.charSelect.character_get_current_table(iconCount) == nil
    else
        iconCount = 2
    end
    if #iconList%2 == 1 then -- Doubles Icons List to be an even number
        local prevIconNum = #iconList
        for i = 1, #iconList do
            iconList[prevIconNum + i] = iconList[i]
        end
    end

    if beatTimer ~= -1 then
        beatTimer = beatTimer + 1
    end
    if beatTimer > MATH_BPM then
        beatTimer = 0
        tilt = not tilt
        logoScale = logoScale * 1.05
    end

    if logoScale > logoScaleNormal then
        logoScale = logoScale - 0.001
    end

    if showTitlescreen or titleTrans < 0 then
        update_music(showTitlescreen and 2 or 0)
        set_mario_action(m, ACT_STANDING_AGAINST_WALL, 0)
        gServerSettings.playerInteractions = 0

        djui_hud_set_color(bgColor.r, bgColor.g, bgColor.b, 255)
        djui_hud_render_rect(0, 0, width + 5, height)
        djui_hud_set_color(bgColor.r * 0.5, bgColor.g * 0.5, bgColor.b * 0.5, 255)
        djui_hud_set_rotation(-0x2000, 0, 0)
        for i = 0, math_ceil(width*0.03125) + 7 do
            djui_hud_render_rect(i*32, -25, 16, 500)
        end
        djui_hud_set_color(255, 255, 255, 255)
        scrollTimer = scrollTimer + 1
        if scrollTimer >= #iconList*(iconScale * 16 + 15) then scrollTimer = 0 end
        for i = 1, #iconList do
            if iconList[i].texture then
                local icon = iconList[i]
                local rotation = 0x800
                if tilt then
                    rotation = -rotation
                end
                if i%2 == 0 then
                    rotation = -rotation
                end
                local iconWidth = iconScale / (icon.texture.width * 0.0625)
                local iconHeight = iconScale / (icon.texture.height * 0.0625)
                local iconDistance = (iconScale * 16 + 15)
                for k = -1, math_ceil(#iconList*iconDistance/width + 1) do
                    djui_hud_set_rotation(rotation, 0.5, 0.5)
                    local x = -50 + iconDistance*i - scrollTimer + #iconList*iconDistance*k
                    if x > -35 and x < width then
                        djui_hud_set_color(0, 0, 0, 255)
                        djui_hud_render_texture(icon.texture, x + iconScale, 10, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x - iconScale, 10, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x, 10 + iconScale, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x, 10 - iconScale, iconWidth, iconHeight)
                        djui_hud_set_color(255, 255, 255, 255)
                        djui_hud_render_texture(icon.texture, x, 10, iconWidth, iconHeight)
                    end

                    local x = 50 + iconDistance*i + scrollTimer - #iconList*iconDistance*k
                    if x > -35 and x < width then
                        djui_hud_set_color(0, 0, 0, 255)
                        djui_hud_render_texture(icon.texture, x + iconScale, height - iconScale*16 - 10, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x - iconScale, height - iconScale*16 - 10, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x, height - iconScale*16 - 10 + iconScale, iconWidth, iconHeight)
                        djui_hud_render_texture(icon.texture, x, height - iconScale*16 - 10 - iconScale, iconWidth, iconHeight)
                        djui_hud_set_color(255, 255, 255, 255)
                        djui_hud_render_texture(icon.texture, x, height - iconScale*16 - 10, iconWidth, iconHeight)
                    end
                end
            end
        end
        djui_hud_set_rotation(0, 0, 0)
        djui_hud_render_texture(TEX_LOGO, width*0.5 - TEX_LOGO.width*0.5*logoScale, height*0.5 - TEX_LOGO.height*0.5*logoScale, logoScale, logoScale)
        djui_hud_set_color(255, 255, 255, ((tilt or (not showTitlescreen)) and 255 or 0))
        djui_hud_set_font(FONT_NORMAL)
        djui_hud_print_text(TEXT_PRESS_START, width*0.5 - djui_hud_measure_text(TEXT_PRESS_START)*0.4, height*0.65, 0.8)
    else
        if audioStream.loaded then
            audio_stream_destroy(audioStream)
            stop_secondary_music(50)
            set_mario_action(m, ACT_JUMP_LAND, 0)
            repeat
                gServerSettings.playerInteractions = serverSettingInterect
            until gServerSettings.playerInteractions == serverSettingInterect
        end
    end
    if not showTitlescreen then
        if titleTrans == -titleTransMax then
            for i = 1, titleTransMax do
                iconListTrans[i] = {
                    texture = iconList[math_random(1, #iconList)].texture,
                    x = math_random(-32, width - 32),
                    y = math_random(-32, height - 32),
                    rotation = math_random(-0x8000, 0x8000),
                }
            end
        end
        if titleTrans < titleTransMax then 
            titleTrans = titleTrans + 3
        end
        for i = 1, titleTransMax-math_abs(titleTrans) do
            if iconListTrans[i].texture then
                local icon = iconListTrans[i]
                djui_hud_set_rotation(icon.rotation, 0.5, 0.5)
                djui_hud_set_color(0, 0, 0, 255)
                djui_hud_render_texture(icon.texture, icon.x + iconScaleTrans, icon.y, iconScaleTrans / (icon.texture.width * 0.0625), iconScaleTrans / (icon.texture.height * 0.0625))
                djui_hud_render_texture(icon.texture, icon.x - iconScaleTrans, icon.y, iconScaleTrans / (icon.texture.width * 0.0625), iconScaleTrans / (icon.texture.height * 0.0625))
                djui_hud_render_texture(icon.texture, icon.x, icon.y + iconScaleTrans, iconScaleTrans / (icon.texture.width * 0.0625), iconScaleTrans / (icon.texture.height * 0.0625))
                djui_hud_render_texture(icon.texture, icon.x, icon.y - iconScaleTrans, iconScaleTrans / (icon.texture.width * 0.0625), iconScaleTrans / (icon.texture.height * 0.0625))
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_render_texture(icon.texture, icon.x, icon.y, iconScaleTrans / (icon.texture.width * 0.0625), iconScaleTrans / (icon.texture.height * 0.0625))
            end
        end
    end
end

local pressStart
local function before_update(m)
    if m.playerIndex ~= 0 or (not showTitlescreen and titleTrans >= titleTransMax) then return end
    if showTitlescreen or titleTrans < 0 then
        if m.controller.buttonPressed & START_BUTTON ~= 0 and showTitlescreen then
            showTitlescreen = false
            pressStart = audio_sample_load("press-start.ogg")
            audio_sample_play(pressStart, m.pos, 1)
        end
        nullify_inputs(m)
    else
        if pressStart.loaded then
            audio_sample_destroy(pressStart)
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_update)
hook_event(HOOK_ON_HUD_RENDER, hud_render)