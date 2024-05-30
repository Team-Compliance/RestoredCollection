@echo off
cd ../../data/restored collection
if exist save*.dat (
del save*.dat
echo Cleared all mod's save files
) else (
echo No save files were found
)

pause