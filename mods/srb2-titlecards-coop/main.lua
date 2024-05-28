-- name: SRB2 Titlecards

local prevLevel = 0
local animTimer = 0
local animSwipe = 0

local TEX_LTACTBLU = get_texture_info("LTACTBLU")
local TEX_LTACTRED = get_texture_info("LTACTRED")
local TEX_LTZIGRED = get_texture_info("LTZIGRED")
local TEX_LTZIGZAG = get_texture_info("LTZIGZAG")
local TEX_LTZZTEXT = get_texture_info("LTZZTEXT")
local TEX_LTZZWARN = get_texture_info("LTZZWARN")

local TEXT_ACT = "Act"

local math_max = math.max


TitlecardTexturesRef = {
    default = 1,
    boss = 2,
}

TitlecardTextures = {
    [TitlecardTexturesRef.default] = {
        act = TEX_LTACTBLU,
        zigzag = TEX_LTZIGZAG,
        text = TEX_LTZZTEXT,
    },
    [TitlecardTexturesRef.boss] = {
        act = TEX_LTACTRED,
        zigzag = TEX_LTZIGRED,
        text = TEX_LTZZWARN,
    },
}

CSTitlecardTextures = {}

TitlecardStages = {
    [LEVEL_BOWSER_1] = {
        textureNum = TitlecardTexturesRef.boss,
        name = "Bowser Fight 1",
    },
    [LEVEL_BOWSER_2] = {
        textureNum = TitlecardTexturesRef.boss,
        name = "Bowser Fight 2"
    },
    [LEVEL_BOWSER_3] = {
        textureNum = TitlecardTexturesRef.boss,
        name = "Bowser Fight 3"
    },
    [LEVEL_BITDW] = {
        textureNum = TitlecardTexturesRef.boss,
    },
    [LEVEL_BITFS] = {
        textureNum = TitlecardTexturesRef.boss,
    },
    [LEVEL_BITS] = {
        textureNum = TitlecardTexturesRef.boss,
    },
}

local interpPos = {
    zigzag = {x = 0, y = 0},
    text = {x = 0, y = 0},
    act = {x = 0, y = 0},
    levelName = {x = 0, y = 0},
    actText = {x = 0, y = 0},
    actNum = {x = 0, y = 0},
    subTitle = {x = 0, y = 0},
}

local currTitlecard = 1
local levelName = ""
local subTitle = ""

local MATH_DIVIDE_420 = 1/420 -- Tested Widescreen

local castleLevels = {
    [LEVEL_CASTLE] = true,
    [LEVEL_CASTLE_COURTYARD] = true,
    [LEVEL_CASTLE_GROUNDS] = true,
}

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_color(255, 255, 255, 255)
    local width = djui_hud_get_screen_width()
    local widthScale = math_max(width, 320)*MATH_DIVIDE_420
    local height = 240
    local m = gMarioStates[0]
    local levelNum = gNetworkPlayers[0].currLevelNum
    if prevLevel ~= levelNum and obj_get_first_with_behavior_id(id_bhvActSelector) == nil and gNetworkPlayers[0].currActNum ~= 99 then
        prevLevel = levelNum
        animTimer = 1
        animSwipe = -width*0.5
        local cardInfo = TitlecardStages[levelNum]
        currTitlecard = (cardInfo and cardInfo.textureNum) and cardInfo.textureNum or 1
        levelName = (cardInfo and cardInfo.name) and cardInfo.name or get_level_name(gNetworkPlayers[0].currCourseNum, gNetworkPlayers[0].currLevelNum, gNetworkPlayers[0].currAreaIndex)
        subTitle = (cardInfo and cardInfo.subTitle) and cardInfo.subTitle or optionTable[optionTableRef.subTitle].toggle == 0 and get_star_name(gNetworkPlayers[0].currCourseNum, gNetworkPlayers[0].currActNum) or ""

        -- Show Check
        local showTitlecards = optionTable[optionTableRef.showTitlecards].toggle
        if showTitlecards == 0 or (showTitlecards == 2 and castleLevels[levelNum]) then
            animTimer = 0
            return
        end
    end
    if animTimer > 0 and animTimer < 150 then
        animTimer = animTimer + 1
        if animTimer < 100 then
            animSwipe = animSwipe * 0.85
        else
            if animSwipe < 0 then animSwipe = 0.1 end
            animSwipe = animSwipe * 1.4
        end
        local animSwipeAbs = -math.abs(animSwipe*0.5)
        local nameOffset = math_max(0, djui_hud_measure_text(levelName) - 190)*widthScale
        local textures = TitlecardTextures[currTitlecard]
        if _G.charSelectExists then
            local currChar = _G.charSelect.character_get_current_number()
            if ((currTitlecard == TitlecardTexturesRef.default and TitlecardTexturesRef.default == 1) or optionTable[optionTableRef.texPriority].toggle == 1) and TitlecardTextures[CSTitlecardTextures[currChar]] then
                textures = TitlecardTextures[CSTitlecardTextures[currChar]]
            end
        end

        local x = animSwipeAbs
        local y = -animTimer
        djui_hud_render_texture_interpolated(textures.zigzag, interpPos.zigzag.x, interpPos.zigzag.y, widthScale, widthScale, x, y, widthScale, widthScale)
        djui_hud_render_texture_interpolated(textures.zigzag, interpPos.zigzag.x, interpPos.zigzag.y + textures.zigzag.height*widthScale, widthScale, widthScale, x, y + textures.zigzag.height*widthScale, widthScale, widthScale)
        interpPos.zigzag.x = x
        interpPos.zigzag.y = y
        
        x = animSwipeAbs
        y = animTimer
        djui_hud_render_texture_interpolated(textures.text, interpPos.text.x, interpPos.text.y, widthScale, widthScale, x, y, widthScale, widthScale)
        djui_hud_render_texture_interpolated(textures.text, interpPos.text.x, interpPos.text.y - 320*widthScale, widthScale, widthScale, x, y - 320*widthScale, widthScale, widthScale)
        interpPos.text.x = x
        interpPos.text.y = y

        x = width*0.5 + (100 - textures.act.width*0.5)*widthScale - animSwipe + nameOffset 
        y = height*0.5 + (28 - textures.act.height*0.5)*widthScale
        djui_hud_render_texture_interpolated(textures.act, interpPos.act.x, interpPos.act.y, widthScale, widthScale, x, y, widthScale, widthScale)
        interpPos.act.x = x
        interpPos.act.y = y

        djui_hud_set_font(FONT_MENU)
        x = width*0.5 - djui_hud_measure_text(levelName)*0.5*widthScale + 80*widthScale + nameOffset + animSwipe
        y = height*0.5 - 10*widthScale
        djui_hud_print_text_interpolated(levelName, interpPos.levelName.x, interpPos.levelName.y, 0.5*widthScale, x, y, 0.5*widthScale)
        interpPos.levelName.x = x
        interpPos.levelName.y = y

        
        if gNetworkPlayers[0].currActNum ~= 0 then
            x = width*0.5 - djui_hud_measure_text(TEXT_ACT)*0.5*widthScale + 80*widthScale + nameOffset - animSwipe
            y = height*0.5 + 10*widthScale
            djui_hud_print_text_interpolated(TEXT_ACT, interpPos.actText.x, interpPos.actText.y, 0.5*widthScale, x, y, 0.5*widthScale)
            interpPos.actText.x = x
            interpPos.actText.y = y

            djui_hud_set_color(255, 255, 0, 255)
            local actNum = tostring(gNetworkPlayers[0].currActNum)
            x = width*0.5 + 85*widthScale - animSwipe + nameOffset
            y = height*0.5 + 5*widthScale
            djui_hud_print_text_interpolated(actNum, interpPos.actNum.x, interpPos.actNum.y, 0.7*widthScale, x, y, 0.7*widthScale)
            interpPos.actNum.x = x
            interpPos.actNum.y = y
        end

        if (TitlecardStages[levelNum] and TitlecardStages[levelNum].subTitle) or gNetworkPlayers[0].currActNum ~= 0 then
            djui_hud_set_font(FONT_TINY)
            x = width*0.5 - djui_hud_measure_text(subTitle)*0.5*widthScale + animSwipe
            y = height*0.5 + 40*widthScale
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_print_text_interpolated(subTitle, interpPos.subTitle.x + widthScale, interpPos.subTitle.y, widthScale, x + widthScale, y, widthScale)
            djui_hud_print_text_interpolated(subTitle, interpPos.subTitle.x - widthScale, interpPos.subTitle.y, widthScale, x - widthScale, y, widthScale)
            djui_hud_print_text_interpolated(subTitle, interpPos.subTitle.x, interpPos.subTitle.y + widthScale, widthScale, x, y + widthScale, widthScale)
            djui_hud_print_text_interpolated(subTitle, interpPos.subTitle.x, interpPos.subTitle.y - widthScale, widthScale, x, y - widthScale, widthScale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_interpolated(subTitle, interpPos.subTitle.x, interpPos.subTitle.y, widthScale, x, y, widthScale)
            interpPos.subTitle.x = x
            interpPos.subTitle.y = y
        end

        -- hide edges in 4:3
        djui_hud_set_rotation(0, 0, 0)
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(-100, 0, 100, height)
        djui_hud_render_rect(width, 0, 100, height)
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)