rmdir build /s /q
del /f DiceGolf.love

7z.exe a DiceGolf.zip * -r -x!*.bat -x!*.piskel -x!*.svg
ren DiceGolf.zip DiceGolf.love

CALL "../build.bat" DiceGolf.love

del /f DiceGolf.love