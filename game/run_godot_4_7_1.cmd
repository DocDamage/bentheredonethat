@echo off
set "GODOT_EXE=%~dp0..\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64.exe"
"%GODOT_EXE%" --editor --path "%~dp0"
