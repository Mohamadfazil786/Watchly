@echo off
setlocal
set "PROJECT=D:\WatchMovie"
set "URL=http://127.0.0.1:8080"

for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8080" ^| findstr "LISTENING"') do set "PORT_PID=%%P"
if not defined PORT_PID (
  start "" /min python -m http.server 8080 --directory "%PROJECT%\build\web"
  timeout /t 2 /nobreak >nul
)

start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app="%URL%" --start-maximized
endlocal
