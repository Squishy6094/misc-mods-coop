local currSong = nil
local songTimer = -100
local currDiff = 0

local keys = {
    -- Player
    [0] = L_JPAD,
    [1] = D_JPAD,
    [2] = U_JPAD,
    [3] = R_JPAD,

    -- Opponent
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0
}

local volume = 1

local metadata = nil
local songName = nil

local songInst = nil
local songVocal1 = nil
local songVocal2 = nil

local prevWeek = nil
local prevName = nil
local prevDiff = nil
local prevRating = ""
local function load_song(week, name, difficulty)
    if week == prevWeek and name == prevName and prevDiff == difficulty then
        return
    else
        prevWeek = week
        prevName = name
        prevDiff = difficulty
    end
    currSong = songInfo[songs[week][name]]
    songTimer = -100
    metadata = currSong.metadata
    songName = string.lower(string_space_to_dash(metadata.songName))
    currDiff = difficulty
    
    for i = 1, #currSong.notes[currDiff] do
        currSong.notes[currDiff][i].h = 0
    end
    prevRating = ""
    
    if songInst ~= nil or songVocal1 ~= nil or songVocal2 ~= nil then
        audio_stream_destroy(songInst)
        audio_stream_destroy(songVocal1)
        audio_stream_destroy(songVocal2)
    end

    songInst = audio_stream_load(songName.."-Inst.ogg")
    songVocal1 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.player..".ogg")
    songVocal2 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.opponent..".ogg")
    repeat
        
    until songInst.loaded and songVocal1.loaded and songVocal2.loaded
end

local function kill_song()
    if songInst ~= nil or songVocal1 ~= nil or songVocal2 ~= nil then
        audio_stream_destroy(songInst)
        audio_stream_destroy(songVocal1)
        audio_stream_destroy(songVocal2)
    end
end

local RATING_MISS = 0
local RATING_SICK = 1
local RATING_GOOD = 2
local RATING_BAD = 3
local RATING_SHIT = 4

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
    if songInst ~= nil and songInst.loaded and songVocal1.loaded and songVocal2.loaded then
        if songTimer == 0 then
            audio_stream_play(songInst, true, volume)
            audio_stream_play(songVocal1, true, volume)
            audio_stream_play(songVocal2, true, volume)
        end
        songTimer = songTimer + 1
    end
    djui_hud_set_color(255, 255, 255, 100)
    for i = -5, 3 do
        if i ~= -1 then
            djui_hud_render_rect(i*30 + width*0.5 + 15, 35, 20, 20)
        end
    end
    for i = 1, #currSong.notes[currDiff] do
        -- d = lane, l = holds, t = time, h = hit
        local currNote = currSong.notes[currDiff][i]
        local scrollSpeed = currSong.scrollSpeed[currDiff]
        local prevNoteTime = (currNote.t - (songTimer - 1)/30*1000)/30*currSong.scrollSpeed[currDiff]*2*scrollSpeed
        local noteTime = (currNote.t - songTimer/30*1000)/30*currSong.scrollSpeed[currDiff]*2*scrollSpeed
        if noteTime < 240 and noteTime > -30 then
            if currNote.h == 0 then
                djui_hud_set_color(255, 255, 255, 255)
            end
            if noteTime <= scrollSpeed*5 and noteTime >= scrollSpeed*-5 then
                if m.controller.buttonPressed & keys[currNote.d] ~= 0 and currNote.h == 0 then
                    if noteTime <= scrollSpeed*1 and noteTime >= scrollSpeed*-1 then
                        currNote.h = RATING_SICK
                        prevRating = "Sick! - "..math.floor(noteTime/30*1000).."ms"
                    elseif noteTime <= scrollSpeed*2.7 and noteTime >= scrollSpeed*-2.7 then
                        currNote.h = RATING_GOOD
                        prevRating = "Good! - "..math.floor(noteTime/30*1000).."ms"
                    elseif noteTime <= scrollSpeed*4 and noteTime >= scrollSpeed*-4 then
                        currNote.h = RATING_BAD
                        prevRating = "Bad - "..math.floor(noteTime/30*1000).."ms"
                    elseif noteTime <= scrollSpeed*5 and noteTime >= scrollSpeed*-5 then
                        currNote.h = RATING_SHIT
                        prevRating = "Shit - "..math.floor(noteTime/30*1000).."ms"
                    end
                end
                if currNote.h > 0 then
                    djui_hud_set_color(255, 255, 0, 0)
                end
            elseif noteTime < scrollSpeed*-5 then
                if currNote.h > 0 then
                    djui_hud_set_color(0, 255, 0, 0)
                else
                    djui_hud_set_color(255, 255, 255, 100)
                end
            end
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_set_font(FONT_MENU)
            djui_hud_print_text(prevRating, width *0.5 - djui_hud_measure_text(prevRating)*0.1, 10, 0.2)
            djui_hud_render_rect_interpolated((currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 15, prevNoteTime + 35, 20, 20, (currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 15, noteTime + 35, 20, 20)
            if currNote.l > 0 then
                djui_hud_render_rect_interpolated((currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 20, prevNoteTime + 35 + 20, 10, currNote.l/30*currSong.scrollSpeed[currDiff]*2, (currNote.d < 4 and currNote.d or currNote.d - 9)*30 + width*0.5 + 20, noteTime + 35 + 20, 10, currNote.l/30*currSong.scrollSpeed[currDiff]*2)
            end
        end
    end
end

local function command_set_song(msg)
    msg = string_split(msg)
    load_song(tonumber(msg[1]), msg[2], tonumber(msg[3]))
    return true
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_chat_command("set_song", "[Song][Name] - Sets the current week and song", command_set_song)