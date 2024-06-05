currSong = songInfo[1]
songTimer = -100
local difficulty = difficulty.hard

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

for i = 1, #currSong.notes[difficulty] do
    currSong.notes[difficulty][i].h = 0
end

local volume = 1

local metadata = currSong.metadata
local songName = string.lower(metadata.songName)

local songInst = nil
local songVocal1 = nil
local songVocal2 = nil

local function on_hud_render()
    local m = gMarioStates[0]
    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width()
    if songInst == nil then
        songInst = audio_stream_load(songName.."-Inst.ogg")
        songVocal1 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.player..".ogg")
        songVocal2 = audio_stream_load(songName.."-Voices-"..metadata.playData.characters.opponent..".ogg")
        repeat
            
        until songInst.loaded and songVocal1.loaded and songVocal2.loaded
    end
    if songInst.loaded and songVocal1.loaded and songVocal2.loaded then
        if songTimer == -10 then
            audio_stream_play(songInst, true, volume)
            audio_stream_play(songVocal1, true, volume)
            audio_stream_play(songVocal2, true, volume)
        end
        songTimer = songTimer + 1
    end
    djui_hud_set_color(255, 255, 255, 100)
    for i = -4, 3 do
        djui_hud_render_rect(i*30 + width*0.5, 35, 20, 20)
    end
    for i = 1, #currSong.notes[difficulty] do
        -- d = lane, l = holds, t = time, h = hit
        local currNote = currSong.notes[difficulty][i]
        local scrollSpeed = currSong.scrollSpeed[difficulty]
        local noteTime = (currNote.t - songTimer/30*1000)/30*currSong.scrollSpeed[difficulty]*2
        if noteTime < 240 and noteTime > -30 then
            if currNote.h == 0 then
                djui_hud_set_color(255, 255, 255, 255)
            end
            if noteTime < 50 and noteTime > 30 then
                if m.controller.buttonPressed & keys[currNote.d] ~= 0 and currNote.h == 0 then
                    currNote.h = 1
                end
                djui_hud_set_color(255, 255, 0, 255)
            elseif noteTime < 30 then
                if currNote.h > 0 then
                    djui_hud_set_color(0, 255, 0, 100)
                else
                    djui_hud_set_color(255, 0, 0, 100)
                end
            end
            djui_hud_render_rect((currNote.d < 4 and currNote.d or currNote.d - 8)*30 + width*0.5, noteTime - 10, 20, 20)
            if currNote.l > 0 then
                djui_hud_render_rect((currNote.d < 4 and currNote.d or currNote.d - 8)*30 + width*0.5 + 5, noteTime - 10, 10, currNote.l/30*currSong.scrollSpeed[difficulty]*2)
            end
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)