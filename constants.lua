local Constants = {}

Constants.course_green = 1
Constants.course_fairway = 2
Constants.course_rough = 3
Constants.course_bunker = 4
Constants.course_water = 5

Constants.field_title = 1
Constants.field_shot = 2
Constants.field_distance = 3
Constants.field_rollButton = 4
Constants.field_rolls = 5
Constants.field_rollResult = 6

Constants.field_hole = 7
Constants.field_courseName = 8

Constants.courseNames = {
    "Fore Your Dice Only",
    "Dice Hard With A Sandtrap",
    "To Roll A MockingBirdie",
    "I Only Have Dice Fore You",
    "Dice Dice Birdie",
    "Harry Potter And The Prisoner Of DiceKaban",
    "To Die Fore",
    "Driving Miss Dice-y",
    "Die-monds are Fore-ever"
}

Constants.shotComplete = 0
Constants.shotComplete_OutOfBounds = 1
Constants.shotComplete_Water = 2
Constants.shotComplete_Messages = {
    "OUT OF BOUNDS",
    "WATER HAZARD"
}

return Constants