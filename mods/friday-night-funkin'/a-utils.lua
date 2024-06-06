songInfo = {}

difficulty = {
    easy = 1,
    normal = 2,
    hard = 3,
}

WEEK_1 = 1

songs = {}

--- @param string string
--- Splits a string into a table by spaces
function string_split(string)
    local result = {}
    for match in string:gmatch(string.format("[^%s]+", " ")) do
        table.insert(result, match)
    end
    return result
end

function string_space_to_dash(string)
    if string == nil then return "" end
    return string:gsub(" ", "-")
end