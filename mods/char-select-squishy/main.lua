-- name: [CS] Squishy

------------------
-- Update Hooks --
------------------

local charTable = charTable

local currChar = 0
local currModel = E_MODEL_NONE

local character_get_current_number = _G.charSelect.character_get_current_number
local character_get_current_table = _G.charSelect.character_get_current_table
local hud_set_value = hud_set_value
local character_voice_sound = character_voice_sound
local character_voice_snore = character_voice_snore

local function mario_update(m)
    local p = gPlayerSyncTable[m.playerIndex]
    character_voice_snore(m)
    if m.playerIndex ~= 0 then return end
    currChar = character_get_current_number()
    currModel = character_get_current_table().model
    -- Network Character Update
    if currModel ~= E_MODEL_NONE then
        if charTable[currModel] ~= nil and currChar == charTable[currModel].cs then
            p.squishyPlayer = charTable[currModel].network
        else
            p.squishyPlayer = 0
        end
    end

    -- Coin Deduction 
    if not p.lostCoins then
        p.lostCoins = 0
    end
    if p.lostCoins ~= 0 then
        m.numCoins = m.numCoins - p.lostCoins
        p.lostCoins = 0
        p.numCoins = m.numCoins
        hud_set_value(HUD_DISPLAY_COINS, m.numCoins)
    end
end

local function on_player_connected(m)
    -- only run on server
    if not network_is_server() then
        return
	end
	for i = 0, (MAX_PLAYERS - 1) do
		if gPlayerSyncTable[i].lostCoins == nil then
			gPlayerSyncTable[i].lostCoins = 0
		end
    end
end

-- Unlock Cardboard Cutout
function on_chat_message(m, msg)
    if m.playerIndex == 0 and string.lower(msg) == "cardboard" and charTable[E_MODEL_CARDBOARD].cs == 0 then
        charTable[E_MODEL_CARDBOARD].cs = _G.charSelect.character_add("Cardboard Cutout", "The Horrors of the Inner Plexus", "Genasaido / SBRP Team", "ff9ef4", E_MODEL_CARDBOARD, nil, nil, 1)
        djui_popup_create('Character Select:\nNew Character Unlocked!\n\\#ff9ef4\\"' .. _G.charSelect.character_get_current_table(charTable[E_MODEL_CARDBOARD].cs).name .. '"', 3)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_CHARACTER_SOUND, character_voice_sound)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)