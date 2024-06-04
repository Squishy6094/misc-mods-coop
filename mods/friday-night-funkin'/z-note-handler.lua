currSong = songInfo[1]
songTimer = 0
local difficulty = difficulty.hard

local function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)
    songTimer = songTimer + 1
    for i = 1, #currSong.notes[difficulty] do
        -- d = lane, l = holds, t = time
        local currNote = currSong.notes[difficulty][i]
        local noteTime = (currNote.t/30 - songTimer)*currSong.scrollSpeed[difficulty]*2
        if noteTime < 240 and noteTime > -30 then
            if noteTime < 15 and noteTime > 5 then
                djui_hud_set_color(255, 255, 255, 255)
            else
                djui_hud_set_color(255, 255, 255, 100)
            end
            djui_hud_render_rect(currNote.d * -40 + 300, noteTime - 10, 32, 32)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)