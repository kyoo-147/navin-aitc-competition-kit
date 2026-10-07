@echo off
setlocal
set "CODEX_HOME=C:\Users\hoang\.codex"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%CODEX_HOME%\codex-runtime-refresh.ps1" -CodexHome "%CODEX_HOME%"
set "AITC_REFRESH_RC=%ERRORLEVEL%"
if "%AITC_REFRESH_RC%"=="10" (
  call "C:\Users\hoang\AppData\Roaming\npm\codex.cmd" app-server daemon restart >nul 2>&1
) else if not "%AITC_REFRESH_RC%"=="0" (
  echo AITC runtime refresh failed with exit code %AITC_REFRESH_RC%. 1>&2
  exit /b %AITC_REFRESH_RC%
)
call "C:\Users\hoang\AppData\Roaming\npm\codex.cmd" --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust %*
set "AITC_CODEX_RC=%ERRORLEVEL%"
endlocal & exit /b %AITC_CODEX_RC%
