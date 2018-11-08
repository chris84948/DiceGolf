rmdir build /s /q
del /f DiceGolf.love

7z.exe a bouncing_game.zip * -r -x!*.bat
ren DiceGolf.zip DiceGolf.love

CALL "../build.bat" DiceGolf.love

del /f DiceGolf.love