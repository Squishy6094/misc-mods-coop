for i in pairs(songInfo) do
    if songInfo[i].song ~= nil then -- Typical Psych .json Format
        local input = songInfo[i]
        local output = {
            metadata = {},
            events = {},
            notes = {},
        }

        output.notes[difficulty.hard] = {}
        for s = 1, #input.song.notes do
            for n = 1, #input.song.notes[s].sectionNotes do
                local currNote = input.song.notes[s].sectionNotes[n]
                table.insert(output.notes[difficulty.hard], {
                    -- d = lane, l = holds, t = time, h = hit
                    d = (currNote[2] + (input.song.notes[s].mustHitSection and 0 or 4))%8,
                    l = currNote[3],
                    t = currNote[1],
                })
            end
        end

        output.metadata = {
            timeFormat = "ms",
            artist = "???",
            playData = {
                album = "???",
                stage = input.song.stage,
                characters = { player = input.song.player1, girlfriend = input.song.gfVersion, opponent = input.song.player2 },
                soloVocalTrack = true,
                songVariations = nil,
                difficulties = {"hard"},
                noteStyle = "funkin"
            },
            songName = "Your Copy",
            timeChanges = { d = 4, n = 4, t = -1, bt = {4, 4, 4, 4}, bpm = input.song.bpm },
            generatedBy = "Psych Engine",
            looped = false,
            version = "2.2.1"
        }
        output.scrollSpeed = {[difficulty.hard] = input.song.speed}

        songInfo[i] = output
    end
end