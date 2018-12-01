rmdir build /s /q
del /f DiceGolf.love
del /f "I Dice Big Putts.zip"

7z.exe a DiceGolf.zip * -r -x!*.bat -x!*.piskel -x!*.svg -x!*.gif
ren DiceGolf.zip DiceGolf.love

CALL "../build.bat" DiceGolf.love

del /f DiceGolf.love

ren Build "I Dice Big Putts"
7z.exe a "I Dice Big Putts.zip" "I Dice Big Putts\*" -r

rmdir "I Dice Big Putts" /s /q