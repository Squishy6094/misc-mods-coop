-- name: [CS] Squishy

------------------
-- Update Hooks --
------------------

local function mario_update(m)
    if m.playerIndex == 0 then
        local currChar = _G.charSelect.character_get_current_number()
        local currModel = _G.charSelect.character_get_current_table().model
        if currModel ~= E_MODEL_NONE then
            if charTable[currModel] ~= nil and currChar == charTable[currModel].cs then
                gPlayerSyncTable[0].squishyPlayer = charTable[currModel].network
            else
                gPlayerSyncTable[0].squishyPlayer = 0
            end
        end

        -- Coin Deduction 
        if not gPlayerSyncTable[0].lostCoins then
            gPlayerSyncTable[0].lostCoins = 0
        end
        if gPlayerSyncTable[0].lostCoins ~= 0 then
            m.numCoins = m.numCoins - gPlayerSyncTable[0].lostCoins
            gPlayerSyncTable[0].lostCoins = 0
            gPlayerSyncTable[0].numCoins = m.numCoins
            hud_set_value(HUD_DISPLAY_COINS, m.numCoins)
        end

        if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY and menuTable[menuTableRef.moveset].status ~= 0 then
            ledge_parkour(m)
            spam_burnout(m)
            trick_system(m)
        end
    end
end

local function before_mario_update(m)
    if menuTable[menuTableRef.moveset].status == 0 or m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY then
        misc_phys_changes(m)
        teching(m)
        momentum_pound(m)
        custom_slide(m)
        explode_on_death(m)
    end

    if gPlayerSyncTable[0].squishyPlayer == NETWORK_CARDBOARD then
        if not gamemode then
            disappear_update(m)
        end
    end
end

local function before_phys_step(m)
    if menuTable[menuTableRef.moveset].status == 0 or m.playerIndex ~= 0 then return end
    if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY then
        remove_ground_cap(m)
    end
end

local function hud_render()
    local m = gMarioStates[0]
    if gPlayerSyncTable[0].squishyPlayer == NETWORK_SQUISHY and menuTable[menuTableRef.moveset].status ~= 0 then
        hud_bubble_timer(m)
        hud_spam_burnout(m)
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
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)