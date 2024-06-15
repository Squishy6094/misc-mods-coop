local currSong = nil
local songTimer = -10
local currDiff = 0

FUNK_ANIM_IDLE = 0
FUNK_ANIM_LEFT = 1
FUNK_ANIM_RIGHT = 2
FUNK_ANIM_UP = 3
FUNK_ANIM_DOWN = 4

local keys = {
    -- Player
    [0] = {input = L_JPAD, rotation = 0, anim = FUNK_ANIM_LEFT},
    [1] = {input = D_JPAD, rotation = 0x4000, anim = FUNK_ANIM_DOWN},
    [2] = {input = U_JPAD, rotation = -0x4000, anim = FUNK_ANIM_UP},
    [3] = {input = R_JPAD, rotation = 0x8000, anim = FUNK_ANIM_RIGHT},

    -- Opponent
    [4] = {input = 0, rotation = 0},
    [5] = {input = 0, rotation = 0x4000},
    [6] = {input = 0, rotation = -0x4000},
    [7] = {input = 0, rotation = 0x8000},
}


local animData = {
    [FUNK_ANIM_IDLE] = {anim = MARIO_ANIM_IDLE_HEAD_CENTER, timer = 0},
    [FUNK_ANIM_LEFT] = {anim = MARIO_ANIM_FIRST_PUNCH, timer = 0},
    [FUNK_ANIM_RIGHT] = {anim = MARIO_ANIM_BACKFLIP, timer = 0},
    [FUNK_ANIM_UP] = {anim = MARIO_ANIM_SINGLE_JUMP, timer = 0},
    [FUNK_ANIM_DOWN] = {anim = MARIO_ANIM_STAR_DANCE, timer = 0},
}

local volume = 1

local metadata = nil
local songName = nil

local songInst = nil
local songVocal1 = nil
local songVocal2 = nil

local prevName = nil
local prevDiff = nil
local prevRating = ""
local prevMisses = 0
local function load_song(name, difficulty)
    if name == prevName and prevDiff == difficulty then
        return
    else
        prevName = name
        prevDiff = difficulty
    end
    currSong = songInfo[name]
    songTimer = -10
    metadata = currSong.metadata
    songName = string.lower(string_space_to_dash(metadata.songName))
    currDiff = difficulty
    
    for i = 1, #currSong.notes[currDiff] do
        currSong.notes[currDiff][i].h = 0
    end
    prevRating = ""
    prevMisses = 0
    
    if songInst ~= nil or songVocal1 ~= nil or songVocal2 ~= nil then
        audio_stream_destroy(songInst)
        audio_stream_destroy(songVocal1)
        if songVocal2 ~= nil then
            audio_stream_destroy(songVocal2)
        end
    end

    local soloVocalTrack = metadata.playData.soloVocalTrack
    if not soloVocalTrack then
        songInst = audio_stream_load(songName.."-Inst.ogg")
        songVocal1 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.player..".ogg")
        songVocal2 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.opponent..".ogg")
        repeat
        until songInst.loaded and songVocal1.loaded and songVocal2.loaded
    else
        songInst = audio_stream_load(songName.."-Inst.ogg")
        songVocal1 = audio_stream_load(songName.."-Voices.ogg")
        repeat
        until songInst.loaded and soloVocalTrack and songVocal1.loaded
    end
end

local function kill_song()
    currSong = nil
    prevName = nil
    prevDiff = nil
    prevRating = ""
    prevMisses = 0
    if songInst ~= nil or songVocal1 ~= nil or songVocal2 ~= nil then
        audio_stream_destroy(songInst)
        audio_stream_destroy(songVocal1)
        if songVocal2 ~= nil then
            audio_stream_destroy(songVocal2)
        end
        stop_secondary_music(50)
    end
end

local RATING_MISS = 0
local RATING_SICK = 1
local RATING_GOOD = 2
local RATING_BAD = 3
local RATING_SHIT = 4

local keyDownTimer = {}

local TEX_ARROW = get_texture_info("arrow")

local swapSong = false
local function on_hud_render()
    if currSong == nil then return end
    local m = gMarioStates[0]
    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width()
    --[[
        if m.controller.buttonPressed & L_TRIG ~= 0 then
            swapSong = not swapSong
        end
        if not swapSong then
            load_song(1, "pico", 3)
        else
            load_song(1, "philly-nice", 3)
        end
    ]]
    djui_hud_set_color(255, 255, 255, 255)
    for i = -5, 3 do
        if i ~= -1 then
            djui_hud_set_rotation(keys[i + (i < -1 and 5 or 4)].rotation, 0.5, 0.5)
            djui_hud_render_texture(TEX_ARROW, i*30 + width*0.5 + 15, 35, 1.5, 1.5)
            djui_hud_set_rotation(0, 0, 0)
        end
    end
    prevMisses = 0
    for i = 1, #currSong.notes[currDiff] do
        -- d = lane, l = holds, t = time, h = hit
        local currNote = currSong.notes[currDiff][i]
        local scrollSpeed = currSong.scrollSpeed[currDiff]
        local prevNoteTime = (currNote.t - (songTimer - 1)/30*1000)/30*currSong.scrollSpeed[currDiff]*2*scrollSpeed
        local noteTime = (currNote.t - songTimer/30*1000)/30*currSong.scrollSpeed[currDiff]*2*scrollSpeed
        if noteTime < 240 and noteTime > -60 - currNote.l/30*currSong.scrollSpeed[currDiff]*2 then
            if currNote.h == 0 or currNote.l > 0 then
                djui_hud_set_color(255, 255, 255, 255)
            end
            if noteTime < scrollSpeed*-10 and currNote.h == 0 and currNote.l == 0 then
                djui_hud_set_color(255, 255, 255, 100)
            end
            if noteTime > 0 or currNote.h == 0 then
                djui_hud_render_rect_interpolated((currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 15, prevNoteTime + 34, 20, 20, (currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 15, noteTime + 34, 20, 20)
                if currNote.l > 0 then
                    djui_hud_render_rect_interpolated((currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 20, prevNoteTime + 34 + 20, 10, currNote.l/30*currSong.scrollSpeed[currDiff]*2, (currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 20, noteTime + 34 + 20, 10, currNote.l/30*currSong.scrollSpeed[currDiff]*2)
                end
            end
        end

        if noteTime < scrollSpeed*-10 and currNote.h == 0 and currNote.d < 4 then
            prevMisses = prevMisses + 1
        end
    end

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_set_font(FONT_MENU)
    djui_hud_print_text(prevRating, width *0.5 - djui_hud_measure_text(prevRating)*0.1, 10, 0.2)
    djui_hud_print_text("Misses: "..prevMisses, width *0.5 - djui_hud_measure_text("Misses: "..prevMisses)*0.1, 220, 0.2)
end

local function before_mario_update(m)
    if currSong == nil or m.playerIndex ~= 0 then return end
    if songInst ~= nil and songVocal1 ~= nil and (currSong.metadata.playData.soloVocalTrack and (songVocal1.loaded) or (songVocal1.loaded and songVocal2.loaded)) then
        if songTimer == 0 then
            audio_stream_play(songInst, true, volume)
            audio_stream_play(songVocal1, true, volume)
            if not currSong.metadata.playData.soloVocalTrack then
                audio_stream_play(songVocal2, true, volume)
            end
            play_secondary_music(0, 0, 0, 0)
        end
        songTimer = songTimer + 1
    end
    for i = 0, #keys do
        if m.controller.buttonDown & keys[i].input ~= 0 then
            keyDownTimer[i] = keyDownTimer[i] + 1/currSong.scrollSpeed[currDiff]
        else
            keyDownTimer[i] = -1
        end
    end
    for i = 1, #currSong.notes[currDiff] do
        -- d = lane, l = holds, t = time, h = hit
        local currNote = currSong.notes[currDiff][i]
        local scrollSpeed = currSong.scrollSpeed[currDiff]
        local noteTime = (currNote.t - songTimer/30*1000)/30*currSong.scrollSpeed[currDiff]*scrollSpeed
        if noteTime < 240 and noteTime > -60 then
            if keyDownTimer[currNote.d] ~= -1 and keyDownTimer[currNote.d] < 5 and currNote.h == 0 then
                if noteTime <= scrollSpeed*2 and noteTime >= scrollSpeed*-2 then
                    currNote.h = RATING_SICK
                    prevRating = "Sick! - "..math.floor(noteTime/30*1000).."ms"
                elseif noteTime <= scrollSpeed*5.4 and noteTime >= scrollSpeed*-5.4 then
                    currNote.h = RATING_GOOD
                    prevRating = "Good! - "..math.floor(noteTime/30*1000).."ms"
                elseif noteTime <= scrollSpeed*8 and noteTime >= scrollSpeed*-8 then
                    currNote.h = RATING_BAD
                    prevRating = "Bad - "..math.floor(noteTime/30*1000).."ms"
                elseif noteTime <= scrollSpeed*10 and noteTime >= scrollSpeed*-10 then
                    currNote.h = RATING_SHIT
                    prevRating = "Shit - "..math.floor(noteTime/30*1000).."ms"
                end
            end
        end
    end
end

local function command_set_song(msg)
    if msg == "none" then
        kill_song()
        return true
    end
    msg = string_split(msg)
    load_song(msg[1], tonumber(msg[2]))
    return true
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_chat_command("set_song", "[Name] - Sets the current week and song", command_set_song)