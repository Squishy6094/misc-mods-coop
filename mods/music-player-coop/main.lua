-- name: Music Player 
-- description: A music player for SM64!

FORMAT_M64 = 0
FORMAT_STREAM = 1

local MATH_DIVIDE_30 = 1/30
local MATH_DIVIDE_60 = 1/60

songs = {
    {
        name = "It's Happy Hour!",
        composer = "Tony Grayson",
        source = "Antonblast OST",
        type = FORMAT_STREAM,
        songData = audio_stream_load("start_it_up.mp3"), 
        length = 3*60 + 41,
        lengthString = "x:xx",
    },
}

for i = 1, #songs do
    local currSong = songs[i]
    if currSong.lengthString == "x:xx" then
        currSong.lengthString = string.format("%s:%s", string.format("%02d", math.floor(currSong.length*MATH_DIVIDE_60)), string.format("%02d", math.floor(currSong.length)%60))
    end
end

themes = {
    {
        name = "Gameboy",
        texture = get_texture_info("mp-gameboy"),
        scale = 0.5,
        raise = 120,
        screenX = 10,
        screenY = 17,
        screenW = 109,
        screenH = 83,
        screenColor = {r = 144, g = 178, b = 42}
    }
}

for i = 1, #themes do
    local theme = themes[i]
    local scale = theme.scale
    theme.raise = theme.raise * scale
    theme.screenX = theme.screenX * scale
    theme.screenY = theme.screenY * scale
    theme.screenW = theme.screenW * scale
    theme.screenH = theme.screenH * scale
end

local currSongNum = 1
local prevSongNum = currSongNum
local currTheme = 1
local menu = 1
local paused = false

local songPos = 0
local prevSongPos = -1
local stallTimer = 0
local function on_hud_render()
    local currSong = songs[currSongNum]
    local currSongData = currSong.songData
    if currSongData ~= nil and currSongData.loaded then
        if songPos == 0 then
            audio_stream_play(currSongData, true, 1)
        end
        if not paused then
            songPos = audio_stream_get_position(currSongData)
        end
        --djui_chat_message_create(math.floor(prevSongPos*100)*0.01 .. "|" .. math.floor(songPos*100)*0.01 .. " - " .. stallTimer)
        if prevSongPos < songPos then
            play_secondary_music(0, 0, 100, 10)
            stallTimer = 0
        elseif not paused then
            stallTimer = stallTimer + 1
        end
        if stallTimer > 30 then -- Go to next song of song has stalled for a second (most likely stopped playing)
            songPos = 0
            currSongNum = currSongNum + 1
            if songs[currSongNum] == nil then currSongNum = 1 end
            stop_secondary_music(50)
            stallTimer = 0
        end
        prevSongPos = songPos
    end

    local m = gMarioStates[0]

    if m.controller.buttonPressed & L_TRIG ~= 0 then
        paused = not paused
        if paused then
            audio_stream_pause(currSongData)
        else
            songPos = math.max(songPos - 0.1, 0)
            audio_stream_play(currSongData, false, 1)
            audio_stream_set_position(currSongData, songPos)
        end
    end

    if m.controller.buttonPressed & R_JPAD ~= 0 then
        currSongNum = currSongNum + 1
        if songs[currSongNum] == nil then currSongNum = 1 end
        --djui_chat_message_create(currSongNum .. "|" .. prevSongNum)
        paused = false
    end

    if m.controller.buttonPressed & L_JPAD ~= 0 then
        if songPos < 3 then
            currSongNum = currSongNum - 1
            if songs[currSongNum] == nil then currSongNum = #songs end
            --djui_chat_message_create(currSongNum .. "|" .. prevSongNum)
            paused = false
        else
            songPos = 0
        end
    end
    
    if prevSongNum ~= currSongNum then
        audio_stream_stop(songs[prevSongNum].songData)
        songPos = 0
        prevSongPos = -1
        prevSongNum = currSongNum
    end

    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djui_hud_get_screen_width()
    local height = 240

    local mpTheme = themes[currTheme]
    local color = mpTheme.screenColor
    local scale = mpTheme.scale
    local x = 10
    local y = height - mpTheme.raise
    djui_hud_set_color(color.r, color.g, color.b, 255)
    djui_hud_render_rect(10 + mpTheme.screenX, height - mpTheme.raise + mpTheme.screenY, mpTheme.screenW, mpTheme.screenH)
    if menu == 1 then
        local x = x + mpTheme.screenX
        local y = y + mpTheme.screenY
        local width = mpTheme.screenW
        local height = mpTheme.screenH
        djui_hud_set_font(FONT_TINY)
        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_print_text(currSong.name, x + width*0.5 - djui_hud_measure_text(currSong.name)*0.25, y + 5, 0.5)
        local string = currSong.composer .. (currSong.source ~= "" and " - " .. currSong.source or "")
        djui_hud_print_text(string, x + width*0.5 - djui_hud_measure_text(string)*0.2, y + 12, 0.4)
        djui_hud_render_rect(x + 4, y + 19, 1, 5)
        djui_hud_render_rect(x + width - 4, y + 19, 1, 5)
        djui_hud_set_color(0, 0, 0, 50)
        local timeBar = math.min((songPos)/currSong.length*(width-9), width-9)
        djui_hud_render_rect(x + 5 + timeBar, y + 20, width - 9 - timeBar, 3)
        djui_hud_set_color(0, 0, 0, 200)
        djui_hud_render_rect(x + 5, y + 20, timeBar, 3)
        local string = string.format("%s:%s", string.format("%02d", math.floor(songPos*MATH_DIVIDE_60)), string.format("%02d", math.floor(songPos)%60)) .. " / " .. currSong.lengthString
        djui_hud_print_text(string, x + width*0.5 - djui_hud_measure_text(string)*0.15, y + 24, 0.3)
    end
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(mpTheme.texture, 10, height - mpTheme.raise, mpTheme.scale, mpTheme.scale)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render)

----------------------------
-- API / Playlist Manager --
----------------------------

local function add_song(name, composer, source, type, songData, length)
    table.insert(songs, {
        name = name,
        composer = composer,
        source = source,
        type = type,
        songData = songData, 
        length = length,
        lengthString = string.format("%s:%s", string.format("%02d", math.floor(length*MATH_DIVIDE_60)), string.format("%02d", math.floor(length)%60)),
    })
end

_G.musicPlayer = {
    add_song = add_song
}
