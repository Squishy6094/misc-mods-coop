
if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n".."Squishy Pack".."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

gamemode = false
for i in pairs(gActiveMods) do
    if gActiveMods[i].incompatible == "gamemode" and gActiveMods[i].name ~= "Personal Star Counter" then
        gamemode = true
        break
    end
end

menuTable = {}

---------------------------------
-- Character Select Initialize --
---------------------------------

E_MODEL_SQUISHY = smlua_model_util_get_id("squishy_classic_geo")
E_MODEL_SQUISHY_CLASSIC = smlua_model_util_get_id("squishy_classic_geo")
E_MODEL_SQUISHY_PAPER = smlua_model_util_get_id("squishy_paper_geo")

E_MODEL_SHELL = smlua_model_util_get_id("shell_geo")

E_MODEL_CARDBOARD = smlua_model_util_get_id("cardboard_geo")

local TEX_SQUISHY = get_texture_info("squishy-icon")

local VOICETABLE_NONE = {nil}

local squishyPalette = {
    [PANTS]  = "000419",
    [SHIRT]  = "0a1e00",
    [GLOVES] = "ffffff",
    [SHOES]  = "ffffff",
    [HAIR]   = "0b0300",
    [SKIN]   = "ffe6b2",
    [CAP]    = "080808",
}

NETWORK_NONE = 0
NETWORK_SQUISHY = 1
NETWORK_SHELL = 2
NETWORK_CARDBOARD = 3

local crossSupportNum = _G.charSelect.character_get_number_from_string("Squishy") and _G.charSelect.character_get_number_from_string("Squishy") or 0

charTable = {
    [E_MODEL_SQUISHY] = {cs = crossSupportNum, network = NETWORK_SQUISHY},
    [E_MODEL_SQUISHY_CLASSIC] = {cs = crossSupportNum, network = NETWORK_SQUISHY},
    [E_MODEL_SQUISHY_PAPER] = {cs = crossSupportNum, network = NETWORK_SQUISHY},
    [E_MODEL_SHELL] = {cs = 0, network = NETWORK_SHELL},
    [E_MODEL_CARDBOARD] = {cs = 0, network = NETWORK_CARDBOARD},
}

movesetFunctions = {
    [NETWORK_NONE] = {},
    [NETWORK_SQUISHY] = {},
    [NETWORK_SHELL] = {},
    [NETWORK_CARDBOARD] = {}
}

if charTable[E_MODEL_SQUISHY].cs == 0 then
    local squishyPlace = _G.charSelect.character_add("Squishy", "Squishy T. Server", "Trashcam / Squishy", "008800", E_MODEL_SQUISHY, nil, TEX_SQUISHY, 1)
    charTable[E_MODEL_SQUISHY].cs = squishyPlace
    charTable[E_MODEL_SQUISHY_CLASSIC].cs = squishyPlace
    charTable[E_MODEL_SQUISHY_PAPER].cs = squishyPlace
else
    _G.charSelect.character_edit(charTable[E_MODEL_SQUISHY].cs, "Squishy", "Squishy T. Server", "Trashcam / Squishy", {r = 0, g = 136, b = 0}, E_MODEL_SQUISHY, nil, TEX_SQUISHY, 1)
end
charTable[E_MODEL_SHELL].cs = _G.charSelect.character_add("Shell", "Silly Ladyy", "KF / Squishy", "6B5EFF", E_MODEL_SHELL, 18, TEX_SQUISHY, 1)

_G.charSelect.character_add_voice(E_MODEL_CARDBOARD, VOICETABLE_NONE)
_G.charSelect.character_add_voice(E_MODEL_NONE, VOICETABLE_NONE)

_G.charSelect.character_add_palette_preset(E_MODEL_SQUISHY, squishyPalette)
_G.charSelect.character_add_palette_preset(E_MODEL_SQUISHY_CLASSIC, squishyPalette)
_G.charSelect.character_add_palette_preset(E_MODEL_SQUISHY_PAPER, squishyPalette)

function character_voice_sound(m, sound)
    if _G.charSelect.character_get_voice(m) == VOICETABLE_NONE then return _G.charSelect.voice.sound(m, sound) end
end
function character_voice_snore(m)
    if _G.charSelect.character_get_voice(m) == VOICETABLE_NONE then return _G.charSelect.voice.snore(m) end
end

if _G.charSelectPride then
    _G.charSelect.character_add_pride_flag(charTable[E_MODEL_SQUISHY].cs, "transgender")
    --_G.charSelect.character_add_sexuality(charTable[E_MODEL_SQUISHY].cs, "asexual")

    _G.charSelect.character_add_pride_flag(charTable[E_MODEL_SHELL].cs, "transgender")
    _G.charSelect.character_add_pride_flag(charTable[E_MODEL_SHELL].cs, "lesbian")
end

-- Functions and Constants
function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end