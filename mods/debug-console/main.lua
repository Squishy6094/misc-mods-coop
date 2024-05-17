-- name: Debug Console
-- description: Utility that allows modders to easily implement Custom Fonts via Lua. Just drag \\#7777ff\\!font-handler.lua\\#dcdcdc\\ into your mod's folder!\n\nCreated by: \\#008800\\Squishy 6094

--[[
    This example showcases how the default functions
    work cleanly with the custom font without having
    to manually mess with textures tiling
]]

local DEBUG_CONSOLE_VERSION = "v1 (Beta)"

local backslash = [[\]]

local fontInfoConsole = { -- Maps textures in a spritesheet to letters
    ["!"] = {x = 0, y = 12, width = 7, height = 11},
    ['"'] = {x = 0, y = 24, width = 7, height = 11},
    ["#"] = {x = 0, y = 36, width = 7, height = 11},
    ["$"] = {x = 0, y = 48, width = 7, height = 11},
    ["%"] = {x = 0, y = 60, width = 7, height = 11},
    ["&"] = {x = 0, y = 72, width = 7, height = 11},
    ["'"] = {x = 0, y = 84, width = 7, height = 11},
    ["("] = {x = 0, y = 96, width = 7, height = 11},
    [")"] = {x = 0, y = 108, width = 7, height = 11},
    ["*"] = {x = 0, y = 120, width = 7, height = 11},
    ["+"] = {x = 0, y = 132, width = 7, height = 11},
    [","] = {x = 0, y = 144, width = 7, height = 11},
    ["-"] = {x = 0, y = 156, width = 7, height = 11},
    ["."] = {x = 0, y = 168, width = 7, height = 11},
    ["/"] = {x = 0, y = 180, width = 7, height = 11},

    ["0"] = {x = 8, y = 0, width = 7, height = 11},
    ["1"] = {x = 8, y = 12, width = 7, height = 11},
    ['2'] = {x = 8, y = 24, width = 7, height = 11},
    ["3"] = {x = 8, y = 36, width = 7, height = 11},
    ["4"] = {x = 8, y = 48, width = 7, height = 11},
    ["5"] = {x = 8, y = 60, width = 7, height = 11},
    ["6"] = {x = 8, y = 72, width = 7, height = 11},
    ["7"] = {x = 8, y = 84, width = 7, height = 11},
    ["8"] = {x = 8, y = 96, width = 7, height = 11},
    ["9"] = {x = 8, y = 108, width = 7, height = 11},
    [":"] = {x = 8, y = 120, width = 7, height = 11},
    [";"] = {x = 8, y = 132, width = 7, height = 11},
    ["<"] = {x = 8, y = 144, width = 7, height = 11},
    ["="] = {x = 8, y = 156, width = 7, height = 11},
    [">"] = {x = 8, y = 168, width = 7, height = 11},
    ["?"] = {x = 8, y = 180, width = 7, height = 11},

    ["@"] = {x = 16, y = 0, width = 7, height = 11},
    ["A"] = {x = 16, y = 12, width = 7, height = 11},
    ['B'] = {x = 16, y = 24, width = 7, height = 11},
    ["C"] = {x = 16, y = 36, width = 7, height = 11},
    ["D"] = {x = 16, y = 48, width = 7, height = 11},
    ["E"] = {x = 16, y = 60, width = 7, height = 11},
    ["F"] = {x = 16, y = 72, width = 7, height = 11},
    ["G"] = {x = 16, y = 84, width = 7, height = 11},
    ["H"] = {x = 16, y = 96, width = 7, height = 11},
    ["I"] = {x = 16, y = 108, width = 7, height = 11},
    ["J"] = {x = 16, y = 120, width = 7, height = 11},
    ["K"] = {x = 16, y = 132, width = 7, height = 11},
    ["L"] = {x = 16, y = 144, width = 7, height = 11},
    ["M"] = {x = 16, y = 156, width = 7, height = 11},
    ["N"] = {x = 16, y = 168, width = 7, height = 11},
    ["O"] = {x = 16, y = 180, width = 7, height = 11},
    
    ["P"] = {x = 24, y = 0, width = 7, height = 11},
    ["Q"] = {x = 24, y = 12, width = 7, height = 11},
    ['R'] = {x = 24, y = 24, width = 7, height = 11},
    ["S"] = {x = 24, y = 36, width = 7, height = 11},
    ["T"] = {x = 24, y = 48, width = 7, height = 11},
    ["U"] = {x = 24, y = 60, width = 7, height = 11},
    ["V"] = {x = 24, y = 72, width = 7, height = 11},
    ["W"] = {x = 24, y = 84, width = 7, height = 11},
    ["X"] = {x = 24, y = 96, width = 7, height = 11},
    ["Y"] = {x = 24, y = 108, width = 7, height = 11},
    ["Z"] = {x = 24, y = 120, width = 7, height = 11},
    ["["] = {x = 24, y = 132, width = 7, height = 11},
    [backslash] = {x = 24, y = 144, width = 7, height = 11},
    ["]"] = {x = 24, y = 156, width = 7, height = 11},
    ["^"] = {x = 24, y = 168, width = 7, height = 11},
    ["_"] = {x = 24, y = 180, width = 7, height = 11},
    
    ["`"] = {x = 32, y = 0, width = 7, height = 11},
    ["a"] = {x = 32, y = 12, width = 7, height = 11},
    ['b'] = {x = 32, y = 24, width = 7, height = 11},
    ["c"] = {x = 32, y = 36, width = 7, height = 11},
    ["d"] = {x = 32, y = 48, width = 7, height = 11},
    ["e"] = {x = 32, y = 60, width = 7, height = 11},
    ["f"] = {x = 32, y = 72, width = 7, height = 11},
    ["g"] = {x = 32, y = 84, width = 7, height = 12},
    ["h"] = {x = 32, y = 96, width = 7, height = 11},
    ["i"] = {x = 32, y = 108, width = 7, height = 11},
    ["j"] = {x = 32, y = 120, width = 7, height = 12},
    ["k"] = {x = 32, y = 132, width = 7, height = 11},
    ["l"] = {x = 32, y = 144, width = 7, height = 11},
    ["m"] = {x = 32, y = 156, width = 7, height = 11},
    ["n"] = {x = 32, y = 168, width = 7, height = 11},
    ["o"] = {x = 32, y = 180, width = 7, height = 11},

    ["p"] = {x = 40, y = 0, width = 7, height = 12},
    ["q"] = {x = 40, y = 12, width = 7, height = 12},
    ['r'] = {x = 40, y = 24, width = 7, height = 11},
    ["s"] = {x = 40, y = 36, width = 7, height = 11},
    ["t"] = {x = 40, y = 48, width = 7, height = 11},
    ["u"] = {x = 40, y = 60, width = 7, height = 11},
    ["v"] = {x = 40, y = 72, width = 7, height = 11},
    ["w"] = {x = 40, y = 84, width = 7, height = 11},
    ["x"] = {x = 40, y = 96, width = 7, height = 11},
    ["y"] = {x = 40, y = 108, width = 7, height = 12},
    ["z"] = {x = 40, y = 120, width = 7, height = 11},
    ["{"] = {x = 40, y = 132, width = 7, height = 11},
    ["|"] = {x = 40, y = 144, width = 7, height = 11},
    ["}"] = {x = 40, y = 156, width = 7, height = 11},
    ["~"] = {x = 40, y = 168, width = 7, height = 11},
}

local sActionTable = {
    [ACT_UNINITIALIZED] = "ACT_UNINITIALIZED",
    [ACT_IDLE] = "ACT_IDLE",
    [ACT_START_SLEEPING] = "ACT_START_SLEEPING",
    [ACT_SLEEPING] = "ACT_SLEEPING",
    [ACT_WAKING_UP] = "ACT_WAKING_UP",
    [ACT_PANTING] = "ACT_PANTING",
    [ACT_HOLD_PANTING_UNUSED] = "ACT_HOLD_PANTING_UNUSED",
    [ACT_HOLD_IDLE] = "ACT_HOLD_IDLE",
    [ACT_HOLD_HEAVY_IDLE] = "ACT_HOLD_HEAVY_IDLE",
    [ACT_STANDING_AGAINST_WALL] = "ACT_STANDING_AGAINST_WALL",
    [ACT_COUGHING] = "ACT_COUGHING",
    [ACT_SHIVERING] = "ACT_SHIVERING",
    [ACT_IN_QUICKSAND] = "ACT_IN_QUICKSAND",
    [ACT_UNKNOWN_0002020E] = "ACT_UNKNOWN_0002020E",
    [ACT_CROUCHING] = "ACT_CROUCHING",
    [ACT_START_CROUCHING] = "ACT_START_CROUCHING",
    [ACT_STOP_CROUCHING] = "ACT_STOP_CROUCHING",
    [ACT_START_CRAWLING] = "ACT_START_CRAWLING",
    [ACT_STOP_CRAWLING] = "ACT_STOP_CRAWLING",
    [ACT_SLIDE_KICK_SLIDE_STOP] = "ACT_SLIDE_KICK_SLIDE_STOP",
    [ACT_SHOCKWAVE_BOUNCE] = "ACT_SHOCKWAVE_BOUNCE",
    [ACT_FIRST_PERSON] = "ACT_FIRST_PERSON",
    [ACT_BACKFLIP_LAND_STOP] = "ACT_BACKFLIP_LAND_STOP",
    [ACT_JUMP_LAND_STOP] = "ACT_JUMP_LAND_STOP",
    [ACT_DOUBLE_JUMP_LAND_STOP] = "ACT_DOUBLE_JUMP_LAND_STOP",
    [ACT_FREEFALL_LAND_STOP] = "ACT_FREEFALL_LAND_STOP",
    [ACT_SIDE_FLIP_LAND_STOP] = "ACT_SIDE_FLIP_LAND_STOP",
    [ACT_HOLD_JUMP_LAND_STOP] = "ACT_HOLD_JUMP_LAND_STOP",
    [ACT_HOLD_FREEFALL_LAND_STOP] = "ACT_HOLD_FREEFALL_LAND_STOP",
    [ACT_AIR_THROW_LAND] = "ACT_AIR_THROW_LAND",
    [ACT_TWIRL_LAND] = "ACT_TWIRL_LAND",
    [ACT_LAVA_BOOST_LAND] = "ACT_LAVA_BOOST_LAND",
    [ACT_TRIPLE_JUMP_LAND_STOP] = "ACT_TRIPLE_JUMP_LAND_STOP",
    [ACT_LONG_JUMP_LAND_STOP] = "ACT_LONG_JUMP_LAND_STOP",
    [ACT_GROUND_POUND_LAND] = "ACT_GROUND_POUND_LAND",
    [ACT_BRAKING_STOP] = "ACT_BRAKING_STOP",
    [ACT_BUTT_SLIDE_STOP] = "ACT_BUTT_SLIDE_STOP",
    [ACT_HOLD_BUTT_SLIDE_STOP] = "ACT_HOLD_BUTT_SLIDE_STOP",
    [ACT_WALKING] = "ACT_WALKING",
    [ACT_HOLD_WALKING] = "ACT_HOLD_WALKING",
    [ACT_TURNING_AROUND] = "ACT_TURNING_AROUND",
    [ACT_FINISH_TURNING_AROUND] = "ACT_FINISH_TURNING_AROUND",
    [ACT_BRAKING] = "ACT_BRAKING",
    [ACT_RIDING_SHELL_GROUND] = "ACT_RIDING_SHELL_GROUND",
    [ACT_HOLD_HEAVY_WALKING] = "ACT_HOLD_HEAVY_WALKING",
    [ACT_CRAWLING] = "ACT_CRAWLING",
    [ACT_BURNING_GROUND] = "ACT_BURNING_GROUND",
    [ACT_DECELERATING] = "ACT_DECELERATING",
    [ACT_HOLD_DECELERATING] = "ACT_HOLD_DECELERATING",
    [ACT_BEGIN_SLIDING] = "ACT_BEGIN_SLIDING",
    [ACT_HOLD_BEGIN_SLIDING] = "ACT_HOLD_BEGIN_SLIDING",
    [ACT_BUTT_SLIDE] = "ACT_BUTT_SLIDE",
    [ACT_STOMACH_SLIDE] = "ACT_STOMACH_SLIDE",
    [ACT_HOLD_BUTT_SLIDE] = "ACT_HOLD_BUTT_SLIDE",
    [ACT_HOLD_STOMACH_SLIDE] = "ACT_HOLD_STOMACH_SLIDE",
    [ACT_DIVE_SLIDE] = "ACT_DIVE_SLIDE",
    [ACT_MOVE_PUNCHING] = "ACT_MOVE_PUNCHING",
    [ACT_CROUCH_SLIDE] = "ACT_CROUCH_SLIDE",
    [ACT_SLIDE_KICK_SLIDE] = "ACT_SLIDE_KICK_SLIDE",
    [ACT_HARD_BACKWARD_GROUND_KB] = "ACT_HARD_BACKWARD_GROUND_KB",
    [ACT_HARD_FORWARD_GROUND_KB] = "ACT_HARD_FORWARD_GROUND_KB",
    [ACT_BACKWARD_GROUND_KB] = "ACT_BACKWARD_GROUND_KB",
    [ACT_FORWARD_GROUND_KB] = "ACT_FORWARD_GROUND_KB",
    [ACT_SOFT_BACKWARD_GROUND_KB] = "ACT_SOFT_BACKWARD_GROUND_KB",
    [ACT_SOFT_FORWARD_GROUND_KB] = "ACT_SOFT_FORWARD_GROUND_KB",
    [ACT_GROUND_BONK] = "ACT_GROUND_BONK",
    [ACT_DEATH_EXIT_LAND] = "ACT_DEATH_EXIT_LAND",
    [ACT_JUMP_LAND] = "ACT_JUMP_LAND",
    [ACT_FREEFALL_LAND] = "ACT_FREEFALL_LAND",
    [ACT_DOUBLE_JUMP_LAND] = "ACT_DOUBLE_JUMP_LAND",
    [ACT_SIDE_FLIP_LAND] = "ACT_SIDE_FLIP_LAND",
    [ACT_HOLD_JUMP_LAND] = "ACT_HOLD_JUMP_LAND",
    [ACT_HOLD_FREEFALL_LAND] = "ACT_HOLD_FREEFALL_LAND",
    [ACT_QUICKSAND_JUMP_LAND] = "ACT_QUICKSAND_JUMP_LAND",
    [ACT_HOLD_QUICKSAND_JUMP_LAND] = "ACT_HOLD_QUICKSAND_JUMP_LAND",
    [ACT_TRIPLE_JUMP_LAND] = "ACT_TRIPLE_JUMP_LAND",
    [ACT_LONG_JUMP_LAND] = "ACT_LONG_JUMP_LAND",
    [ACT_BACKFLIP_LAND] = "ACT_BACKFLIP_LAND",
    [ACT_JUMP] = "ACT_JUMP",
    [ACT_DOUBLE_JUMP] = "ACT_DOUBLE_JUMP",
    [ACT_TRIPLE_JUMP] = "ACT_TRIPLE_JUMP",
    [ACT_BACKFLIP] = "ACT_BACKFLIP",
    [ACT_STEEP_JUMP] = "ACT_STEEP_JUMP",
    [ACT_WALL_KICK_AIR] = "ACT_WALL_KICK_AIR",
    [ACT_SIDE_FLIP] = "ACT_SIDE_FLIP",
    [ACT_LONG_JUMP] = "ACT_LONG_JUMP",
    [ACT_WATER_JUMP] = "ACT_WATER_JUMP",
    [ACT_DIVE] = "ACT_DIVE",
    [ACT_FREEFALL] = "ACT_FREEFALL",
    [ACT_TOP_OF_POLE_JUMP] = "ACT_TOP_OF_POLE_JUMP",
    [ACT_BUTT_SLIDE_AIR] = "ACT_BUTT_SLIDE_AIR",
    [ACT_FLYING_TRIPLE_JUMP] = "ACT_FLYING_TRIPLE_JUMP",
    [ACT_SHOT_FROM_CANNON] = "ACT_SHOT_FROM_CANNON",
    [ACT_FLYING] = "ACT_FLYING",
    [ACT_RIDING_SHELL_JUMP] = "ACT_RIDING_SHELL_JUMP",
    [ACT_RIDING_SHELL_FALL] = "ACT_RIDING_SHELL_FALL",
    [ACT_VERTICAL_WIND] = "ACT_VERTICAL_WIND",
    [ACT_HOLD_JUMP] = "ACT_HOLD_JUMP",
    [ACT_HOLD_FREEFALL] = "ACT_HOLD_FREEFALL",
    [ACT_HOLD_BUTT_SLIDE_AIR] = "ACT_HOLD_BUTT_SLIDE_AIR",
    [ACT_HOLD_WATER_JUMP] = "ACT_HOLD_WATER_JUMP",
    [ACT_TWIRLING] = "ACT_TWIRLING",
    [ACT_FORWARD_ROLLOUT] = "ACT_FORWARD_ROLLOUT",
    [ACT_AIR_HIT_WALL] = "ACT_AIR_HIT_WALL",
    [ACT_RIDING_HOOT] = "ACT_RIDING_HOOT",
    [ACT_GROUND_POUND] = "ACT_GROUND_POUND",
    [ACT_SLIDE_KICK] = "ACT_SLIDE_KICK",
    [ACT_AIR_THROW] = "ACT_AIR_THROW",
    [ACT_JUMP_KICK] = "ACT_JUMP_KICK",
    [ACT_BACKWARD_ROLLOUT] = "ACT_BACKWARD_ROLLOUT",
    [ACT_CRAZY_BOX_BOUNCE] = "ACT_CRAZY_BOX_BOUNCE",
    [ACT_SPECIAL_TRIPLE_JUMP] = "ACT_SPECIAL_TRIPLE_JUMP",
    [ACT_BACKWARD_AIR_KB] = "ACT_BACKWARD_AIR_KB",
    [ACT_FORWARD_AIR_KB] = "ACT_FORWARD_AIR_KB",
    [ACT_HARD_FORWARD_AIR_KB] = "ACT_HARD_FORWARD_AIR_KB",
    [ACT_HARD_BACKWARD_AIR_KB] = "ACT_HARD_BACKWARD_AIR_KB",
    [ACT_BURNING_JUMP] = "ACT_BURNING_JUMP",
    [ACT_BURNING_FALL] = "ACT_BURNING_FALL",
    [ACT_SOFT_BONK] = "ACT_SOFT_BONK",
    [ACT_LAVA_BOOST] = "ACT_LAVA_BOOST",
    [ACT_GETTING_BLOWN] = "ACT_GETTING_BLOWN",
    [ACT_THROWN_FORWARD] = "ACT_THROWN_FORWARD",
    [ACT_THROWN_BACKWARD] = "ACT_THROWN_BACKWARD",
    [ACT_WATER_IDLE] = "ACT_WATER_IDLE",
    [ACT_HOLD_WATER_IDLE] = "ACT_HOLD_WATER_IDLE",
    [ACT_WATER_ACTION_END] = "ACT_WATER_ACTION_END",
    [ACT_HOLD_WATER_ACTION_END] = "ACT_HOLD_WATER_ACTION_END",
    [ACT_DROWNING] = "ACT_DROWNING",
    [ACT_BACKWARD_WATER_KB] = "ACT_BACKWARD_WATER_KB",
    [ACT_FORWARD_WATER_KB] = "ACT_FORWARD_WATER_KB",
    [ACT_WATER_DEATH] = "ACT_WATER_DEATH",
    [ACT_WATER_SHOCKED] = "ACT_WATER_SHOCKED",
    [ACT_BREASTSTROKE] = "ACT_BREASTSTROKE",
    [ACT_SWIMMING_END] = "ACT_SWIMMING_END",
    [ACT_FLUTTER_KICK] = "ACT_FLUTTER_KICK",
    [ACT_HOLD_BREASTSTROKE] = "ACT_HOLD_BREASTSTROKE",
    [ACT_HOLD_SWIMMING_END] = "ACT_HOLD_SWIMMING_END",
    [ACT_HOLD_FLUTTER_KICK] = "ACT_HOLD_FLUTTER_KICK",
    [ACT_WATER_SHELL_SWIMMING] = "ACT_WATER_SHELL_SWIMMING",
    [ACT_WATER_THROW] = "ACT_WATER_THROW",
    [ACT_WATER_PUNCH] = "ACT_WATER_PUNCH",
    [ACT_WATER_PLUNGE] = "ACT_WATER_PLUNGE",
    [ACT_CAUGHT_IN_WHIRLPOOL] = "ACT_CAUGHT_IN_WHIRLPOOL",
    [ACT_METAL_WATER_STANDING] = "ACT_METAL_WATER_STANDING",
    [ACT_HOLD_METAL_WATER_STANDING] = "ACT_HOLD_METAL_WATER_STANDING",
    [ACT_METAL_WATER_WALKING] = "ACT_METAL_WATER_WALKING",
    [ACT_HOLD_METAL_WATER_WALKING] = "ACT_HOLD_METAL_WATER_WALKING",
    [ACT_METAL_WATER_FALLING] = "ACT_METAL_WATER_FALLING",
    [ACT_HOLD_METAL_WATER_FALLING] = "ACT_HOLD_METAL_WATER_FALLING",
    [ACT_METAL_WATER_FALL_LAND] = "ACT_METAL_WATER_FALL_LAND",
    [ACT_HOLD_METAL_WATER_FALL_LAND] = "ACT_HOLD_METAL_WATER_FALL_LAND",
    [ACT_METAL_WATER_JUMP] = "ACT_METAL_WATER_JUMP",
    [ACT_HOLD_METAL_WATER_JUMP] = "ACT_HOLD_METAL_WATER_JUMP",
    [ACT_METAL_WATER_JUMP_LAND] = "ACT_METAL_WATER_JUMP_LAND",
    [ACT_HOLD_METAL_WATER_JUMP_LAND] = "ACT_HOLD_METAL_WATER_JUMP_LAND",
    [ACT_DISAPPEARED] = "ACT_DISAPPEARED",
    [ACT_INTRO_CUTSCENE] = "ACT_INTRO_CUTSCENE",
    [ACT_STAR_DANCE_EXIT] = "ACT_STAR_DANCE_EXIT",
    [ACT_STAR_DANCE_WATER] = "ACT_STAR_DANCE_WATER",
    [ACT_FALL_AFTER_STAR_GRAB] = "ACT_FALL_AFTER_STAR_GRAB",
    [ACT_READING_AUTOMATIC_DIALOG] = "ACT_READING_AUTOMATIC_DIALOG",
    [ACT_READING_NPC_DIALOG] = "ACT_READING_NPC_DIALOG",
    [ACT_STAR_DANCE_NO_EXIT] = "ACT_STAR_DANCE_NO_EXIT",
    [ACT_READING_SIGN] = "ACT_READING_SIGN",
    [ACT_JUMBO_STAR_CUTSCENE] = "ACT_JUMBO_STAR_CUTSCENE",
    [ACT_WAITING_FOR_DIALOG] = "ACT_WAITING_FOR_DIALOG",
    [ACT_DEBUG_FREE_MOVE] = "ACT_DEBUG_FREE_MOVE",
    [ACT_STANDING_DEATH] = "ACT_STANDING_DEATH",
    [ACT_QUICKSAND_DEATH] = "ACT_QUICKSAND_DEATH",
    [ACT_ELECTROCUTION] = "ACT_ELECTROCUTION",
    [ACT_SUFFOCATION] = "ACT_SUFFOCATION",
    [ACT_DEATH_ON_STOMACH] = "ACT_DEATH_ON_STOMACH",
    [ACT_DEATH_ON_BACK] = "ACT_DEATH_ON_BACK",
    [ACT_EATEN_BY_BUBBA] = "ACT_EATEN_BY_BUBBA",
    [ACT_END_PEACH_CUTSCENE] = "ACT_END_PEACH_CUTSCENE",
    [ACT_CREDITS_CUTSCENE] = "ACT_CREDITS_CUTSCENE",
    [ACT_END_WAVING_CUTSCENE] = "ACT_END_WAVING_CUTSCENE",
    [ACT_PULLING_DOOR] = "ACT_PULLING_DOOR",
    [ACT_PUSHING_DOOR] = "ACT_PUSHING_DOOR",
    [ACT_WARP_DOOR_SPAWN] = "ACT_WARP_DOOR_SPAWN",
    [ACT_EMERGE_FROM_PIPE] = "ACT_EMERGE_FROM_PIPE",
    [ACT_SPAWN_SPIN_AIRBORNE] = "ACT_SPAWN_SPIN_AIRBORNE",
    [ACT_SPAWN_SPIN_LANDING] = "ACT_SPAWN_SPIN_LANDING",
    [ACT_EXIT_AIRBORNE] = "ACT_EXIT_AIRBORNE",
    [ACT_EXIT_LAND_SAVE_DIALOG] = "ACT_EXIT_LAND_SAVE_DIALOG",
    [ACT_DEATH_EXIT] = "ACT_DEATH_EXIT",
    [ACT_UNUSED_DEATH_EXIT] = "ACT_UNUSED_DEATH_EXIT",
    [ACT_FALLING_DEATH_EXIT] = "ACT_FALLING_DEATH_EXIT",
    [ACT_SPECIAL_EXIT_AIRBORNE] = "ACT_SPECIAL_EXIT_AIRBORNE",
    [ACT_SPECIAL_DEATH_EXIT] = "ACT_SPECIAL_DEATH_EXIT",
    [ACT_FALLING_EXIT_AIRBORNE] = "ACT_FALLING_EXIT_AIRBORNE",
    [ACT_UNLOCKING_KEY_DOOR] = "ACT_UNLOCKING_KEY_DOOR",
    [ACT_UNLOCKING_STAR_DOOR] = "ACT_UNLOCKING_STAR_DOOR",
    [ACT_ENTERING_STAR_DOOR] = "ACT_ENTERING_STAR_DOOR",
    [ACT_SPAWN_NO_SPIN_AIRBORNE] = "ACT_SPAWN_NO_SPIN_AIRBORNE",
    [ACT_SPAWN_NO_SPIN_LANDING] = "ACT_SPAWN_NO_SPIN_LANDING",
    [ACT_BBH_ENTER_JUMP] = "ACT_BBH_ENTER_JUMP",
    [ACT_BBH_ENTER_SPIN] = "ACT_BBH_ENTER_SPIN",
    [ACT_TELEPORT_FADE_OUT] = "ACT_TELEPORT_FADE_OUT",
    [ACT_TELEPORT_FADE_IN] = "ACT_TELEPORT_FADE_IN",
    [ACT_SHOCKED] = "ACT_SHOCKED",
    [ACT_SQUISHED] = "ACT_SQUISHED",
    [ACT_HEAD_STUCK_IN_GROUND] = "ACT_HEAD_STUCK_IN_GROUND",
    [ACT_BUTT_STUCK_IN_GROUND] = "ACT_BUTT_STUCK_IN_GROUND",
    [ACT_FEET_STUCK_IN_GROUND] = "ACT_FEET_STUCK_IN_GROUND",
    [ACT_PUTTING_ON_CAP] = "ACT_PUTTING_ON_CAP",
    [ACT_HOLDING_POLE] = "ACT_HOLDING_POLE",
    [ACT_GRAB_POLE_SLOW] = "ACT_GRAB_POLE_SLOW",
    [ACT_GRAB_POLE_FAST] = "ACT_GRAB_POLE_FAST",
    [ACT_CLIMBING_POLE] = "ACT_CLIMBING_POLE",
    [ACT_TOP_OF_POLE_TRANSITION] = "ACT_TOP_OF_POLE_TRANSITION",
    [ACT_TOP_OF_POLE] = "ACT_TOP_OF_POLE",
    [ACT_START_HANGING] = "ACT_START_HANGING",
    [ACT_HANGING] = "ACT_HANGING",
    [ACT_HANG_MOVING] = "ACT_HANG_MOVING",
    [ACT_LEDGE_GRAB] = "ACT_LEDGE_GRAB",
    [ACT_LEDGE_CLIMB_SLOW_1] = "ACT_LEDGE_CLIMB_SLOW_1",
    [ACT_LEDGE_CLIMB_SLOW_2] = "ACT_LEDGE_CLIMB_SLOW_2",
    [ACT_LEDGE_CLIMB_DOWN] = "ACT_LEDGE_CLIMB_DOWN",
    [ACT_LEDGE_CLIMB_FAST] = "ACT_LEDGE_CLIMB_FAST",
    [ACT_GRABBED] = "ACT_GRABBED",
    [ACT_IN_CANNON] = "ACT_IN_CANNON",
    [ACT_TORNADO_TWIRLING] = "ACT_TORNADO_TWIRLING",
    [ACT_BUBBLED] = "ACT_BUBBLED",
    [ACT_PUNCHING] = "ACT_PUNCHING",
    [ACT_PICKING_UP] = "ACT_PICKING_UP",
    [ACT_DIVE_PICKING_UP] = "ACT_DIVE_PICKING_UP",
    [ACT_STOMACH_SLIDE_STOP] = "ACT_STOMACH_SLIDE_STOP",
    [ACT_PLACING_DOWN] = "ACT_PLACING_DOWN",
    [ACT_THROWING] = "ACT_THROWING",
    [ACT_HEAVY_THROW] = "ACT_HEAVY_THROW",
    [ACT_PICKING_UP_BOWSER] = "ACT_PICKING_UP_BOWSER",
    [ACT_HOLDING_BOWSER] = "ACT_HOLDING_BOWSER",
    [ACT_RELEASING_BOWSER] = "ACT_RELEASING_BOWSER",
}

local sLevelTable = {
    [LEVEL_NONE] = "LEVEL_NONE",
    [LEVEL_UNKNOWN_1] = "LEVEL_UNKNOWN_1",
    [LEVEL_UNKNOWN_2] = "LEVEL_UNKNOWN_2",
    [LEVEL_UNKNOWN_3] = "LEVEL_UNKNOWN_3",
    [LEVEL_BBH] = "LEVEL_BBH",
    [LEVEL_CCM] = "LEVEL_CCM",
    [LEVEL_CASTLE] = "LEVEL_CASTLE",
    [LEVEL_HMC] = "LEVEL_HMC",
    [LEVEL_SSL] = "LEVEL_SSL",
    [LEVEL_BOB] = "LEVEL_BOB",
    [LEVEL_SL] = "LEVEL_SL",
    [LEVEL_WDW] = "LEVEL_WDW",
    [LEVEL_JRB] = "LEVEL_JRB",
    [LEVEL_THI] = "LEVEL_THI",
    [LEVEL_TTC] = "LEVEL_TTC",
    [LEVEL_RR] = "LEVEL_RR",
    [LEVEL_CASTLE_GROUNDS] = "LEVEL_CASTLE_GROUNDS",
    [LEVEL_BITDW] = "LEVEL_BITDW",
    [LEVEL_VCUTM] = "LEVEL_VCUTM",
    [LEVEL_BITFS] = "LEVEL_BITFS",
    [LEVEL_SA] = "LEVEL_SA",
    [LEVEL_BITS] = "LEVEL_BITS",
    [LEVEL_LLL] = "LEVEL_LLL",
    [LEVEL_DDD] = "LEVEL_DDD",
    [LEVEL_WF] = "LEVEL_WF",
    [LEVEL_ENDING] = "LEVEL_ENDING",
    [LEVEL_CASTLE_COURTYARD] = "LEVEL_CASTLE_COURTYARD",
    [LEVEL_PSS] = "LEVEL_PSS",
    [LEVEL_COTMC] = "LEVEL_COTMC",
    [LEVEL_TOTWC] = "LEVEL_TOTWC",
    [LEVEL_BOWSER_1] = "LEVEL_BOWSER_1",
    [LEVEL_WMOTR] = "LEVEL_WMOTR",
    [LEVEL_UNKNOWN_32] = "LEVEL_UNKNOWN_32",
    [LEVEL_BOWSER_2] = "LEVEL_BOWSER_2",
    [LEVEL_BOWSER_3] = "LEVEL_BOWSER_3",
    [LEVEL_UNKNOWN_35] = "LEVEL_UNKNOWN_35",
    [LEVEL_TTM] = "LEVEL_TTM",
    [LEVEL_UNKNOWN_37] = "LEVEL_UNKNOWN_37",
    [LEVEL_UNKNOWN_38] = "LEVEL_UNKNOWN_38",

}

local stringTable = {}

-- Font can use a unique variable, or an existing font to overwrite it
FONT_CONSOLE = djui_hud_add_font(get_texture_info("font-console"), fontInfoConsole, 1, 3, "_", 1)

local consoleToggle = true
local consolePage = 1

local scale = 2
local windowX = 50 
local windowY = 200
local windowWidth = 300*scale
local windowHeight = 300*scale

local mouseWindowOffsetX = 0
local mouseWindowOffsetY = 0
local prevWindowX = windowX
local prevWindowWidth = windowWidth
local windowHeld = 0

local MATH_DIVIDE_SCALE = 1/scale
local MATH_DIVIDE_FONT_WIDTH = 1/(fontInfoConsole["_"].width + 1)
local MATH_DIVIDE_FONT_HEIGHT = 1/(fontInfoConsole["_"].height + 1)

local function console_add_lines(string)
    local loopcount = 1
    if type(string) == "table" then
        loopcount = #string
    end

    for k = 1, loopcount do
        local currLine = 1
        local output = ""
        local string = string
        if type(string) == "table" then
            string = string[k]
        end
        for i = 1, #string do
            local letter = string:sub(i,i)
            output = output..letter
            if i%math.floor((windowWidth - 20)*MATH_DIVIDE_SCALE*MATH_DIVIDE_FONT_WIDTH) == 0 then
                table.insert(stringTable, output)
                currLine = currLine + 1
                output = ""
            end
        end
        if output ~= "" then
            table.insert(stringTable, output)
        end
    end
end

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    stringTable = {}
    if consoleToggle then
        console_add_lines({
            "-----------------------",
            "Debug Console "..DEBUG_CONSOLE_VERSION,
            "Made by Squishy6094",
            "",
            "Font Handler v0.5",
            "-----------------------",
            "",
        })

        if consolePage == 1 then
            console_add_lines({
                "Movement Info:",
                "Pos: x="..math.floor(m.pos.x)..", y="..math.floor(m.pos.y)..", z="..math.floor(m.pos.z),
                "Forward Vel: "..math.floor(m.forwardVel),
                "Vertical Vel: "..math.floor(m.vel.y),
                "Action: "..(sActionTable[m.action] ~= nil and sActionTable[m.action] or "???"),
                "Prev Action: "..(sActionTable[m.prevAction] ~= nil and sActionTable[m.action] or "???"),
            })
        end

        if consolePage == 2 then
            console_add_lines({
                "Area Info",
                "Level: "..sLevelTable[np.currLevelNum].." ("..np.currLevelNum..")"
            })
        end

        
        console_add_lines({
            "",
            "< Next Page | Prev Page >",
            "    D-pad L | D-pad R"
        })

        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(windowX, windowY, windowWidth, windowHeight)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_rect(windowX, windowY, windowWidth, 30)
        djui_hud_render_texture(gTextures.star, windowX + 6, windowY + 5, 1.3, 1.3)
        djui_hud_set_font(FONT_TINY)
        djui_hud_set_color(100, 100, 100, 255)
        djui_hud_print_text("Debug Console "..DEBUG_CONSOLE_VERSION, windowX + 30, windowY + 4, 1.5)
        djui_hud_set_color(255, 0, 0, 255)
        djui_hud_render_rect(windowX + windowWidth - 50, windowY, 50, 30)
        djui_hud_set_font(FONT_CONSOLE)
        djui_hud_set_color(255, 255, 255, 255)
        for i = 1, math.min(#stringTable, (windowHeight - 60)*MATH_DIVIDE_FONT_HEIGHT*MATH_DIVIDE_SCALE) do
            djui_hud_print_text(stringTable[i], windowX + 10, windowY + 30 + (12*i)*scale, scale)
        end

        if is_game_paused() then
            local mouseX = djui_hud_get_mouse_x()
            local mouseY = djui_hud_get_mouse_y()
            djui_hud_render_texture(gTextures.coin, mouseX, mouseY, 2, 2)
            if (mouseX > windowX - 20 and mouseX < windowX or mouseX > windowX + windowWidth and mouseX < windowX + windowWidth + 20) then
                djui_hud_set_rotation(0x4000, 0.5, 0.5)
                djui_hud_render_texture(gTextures.arrow_up, mouseX - 10, mouseY - 20, 2, 2)
                djui_hud_render_texture(gTextures.arrow_down, mouseX + 10, mouseY - 20, 2, 2)
                djui_hud_set_rotation(0x0, 0.5, 0.5)
            end
            if (mouseY > windowY - 20 and mouseY < windowY or mouseY > windowY + windowHeight and mouseY < windowY + windowHeight + 20) then
                djui_hud_render_texture(gTextures.arrow_up, mouseX - 10, mouseY - 20, 2, 2)
                djui_hud_render_texture(gTextures.arrow_down, mouseX + 10, mouseY - 20, 2, 2)
            end
        end
    end
end

---@param m MarioState
local function nullify_inputs(m)
    local c = m.controller
    c.buttonDown = 0
    c.buttonPressed = 0
    c.extStickX = 0
    c.extStickY = 0
    c.rawStickX = 0
    c.rawStickY = 0
    c.stickMag = 0
    c.stickX = 0
    c.stickY = 0
end

local function mouse_handler(m)
    if m.playerIndex ~= 0 then return end
    if is_game_paused() then
        local mouseX = djui_hud_get_mouse_x()
        local mouseY = djui_hud_get_mouse_y()
        djui_hud_render_texture(gTextures.coin, mouseX, mouseY, 2, 2)
        if (mouseX > windowX and mouseX < windowX + windowWidth - 50 and mouseY > windowY and mouseY < windowY + 30) or windowHeld == 1 then
            if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                windowX = mouseX - mouseWindowOffsetX
                windowY = mouseY - mouseWindowOffsetY
                windowHeld = 1
                nullify_inputs(m)
            else
                mouseWindowOffsetX = mouseX - windowX
                mouseWindowOffsetY = mouseY - windowY
                windowHeld = 0
            end
        end

        
        if (mouseX > windowX + windowWidth - 50 and mouseX < windowX + windowWidth and mouseY > windowY and mouseY < windowY + 30) or windowHeld == 1 then
            if m.controller.buttonPressed & A_BUTTON ~= 0 or m.controller.buttonPressed & B_BUTTON ~= 0 then
                consoleToggle = false
                nullify_inputs(m)
            end
        end

        if (mouseX > windowX - 20 and mouseX < windowX or mouseX > windowX + windowWidth and mouseX < windowX + windowWidth + 20) or windowHeld == 2 then
            if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                if mouseX > windowX + windowWidth*0.5 then
                    windowWidth = math.max(mouseX - windowX, 200*scale)
                else
                    --[[
                    windowX = (windowWidth >= 200*scale and mouseX or windowX)
                    windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                    ]]
                end
                windowHeld = 2
                nullify_inputs(m)
            else
                --[[
                mouseWindowOffsetX = mouseX - windowX
                mouseWindowOffsetY = mouseY - windowY
                prevWindowX = windowX
                prevWindowWidth = windowWidth]]
                windowHeld = 0
            end
        end

        if (mouseY > windowY - 20 and mouseY < windowY or mouseY > windowY + windowHeight and mouseY < windowY + windowHeight + 20) or windowHeld == 3 then
            if m.controller.buttonDown & A_BUTTON ~= 0 or m.controller.buttonDown & B_BUTTON ~= 0 then
                if mouseY > windowY + windowHeight*0.5 then
                    windowHeight = math.max(mouseY - windowY, 200*scale)
                else
                    --[[
                    windowX = (windowWidth >= 200*scale and mouseX or windowX)
                    windowWidth = math.max((windowX - prevWindowX) + prevWindowWidth, 200*scale)
                    ]]
                end
                windowHeld = 3
                nullify_inputs(m)
            else
                mouseWindowOffsetX = mouseX - windowX
                mouseWindowOffsetY = mouseY - windowY
                prevWindowX = windowX
                prevWindowWidth = windowWidth
                windowHeld = 0
            end
        end
    end
end

local function console_command()
    consoleToggle = not consoleToggle
    return true
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, mouse_handler)
hook_chat_command("debug-console", "Opens the Debugging Console", console_command)