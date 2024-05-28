---@param texZigZag TextureInfo|nil
---@param texText TextureInfo|nil
---@param texAct TextureInfo|nil
---@return integer
--- Whatever is left as `nil` will be set to the default texture.
local function titlecard_add_textures(texZigZag, texText, texAct)
    table.insert(TitlecardTextures, {
        zigzag = texZigZag and texZigZag or TEX_LTZIGZAG,
        text = texText and texText or TEX_LTZZTEXT,
        act = texAct and texAct or TEX_LTACTBLU,
    })
    return #TitlecardTextures
end

---@param levelNum integer
---@param courseName string|nil
---@param textureNumber integer|nil
local function titlecard_set_level_info(levelNum, courseName, textureNumber)
    if not levelNum then return end
    TitlecardStages[levelNum] = {
        textureNum = textureNumber,
        name = courseName
    }
end

---@param textureNumber integer|nil
local function titlecard_set_default_texture(textureNumber)
    TitlecardTexturesRef.default = TitlecardTextures[textureNumber] and textureNumber or TitlecardTexturesRef.default
end

---@param textureNumber integer|nil
local function titlecard_set_boss_texture(textureNumber)
    TitlecardTexturesRef.boss = TitlecardTextures[textureNumber] and textureNumber or TitlecardTexturesRef.boss
end

---@param charNum integer
---@param textureNumber integer|nil
local function character_set_titlecard_textures(charNum, textureNumber)
    if _G.charSelectExists then
        CSTitlecardTextures[charNum] = textureNumber
    end
end

_G.titlecards = {
    titlecard_add_textures = titlecard_add_textures,
    titlecard_set_level_info = titlecard_set_level_info,
    titlecard_set_default_texture = titlecard_set_default_texture,
    titlecard_set_boss_texture = titlecard_set_boss_texture,
    character_set_titlecard_textures = character_set_titlecard_textures,
    textureRef = TitlecardTexturesRef
}