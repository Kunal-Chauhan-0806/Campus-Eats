@echo off
REM ════════════════════════════════════════════════════════════════
REM  CampusEats — Build & Run Script for Windows
REM ════════════════════════════════════════════════════════════════
REM  Prerequisites:
REM    1. Java 17+  →  https://adoptium.net/
REM    2. MySQL 8+  →  https://dev.mysql.com/downloads/
REM    3. mysql-connector-j-*.jar placed in .\lib\
REM ════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

set JAR=
for %%F in (lib\mysql-connector-j-*.jar) do set JAR=%%F

if "%JAR%"=="" (
    echo [ERROR] MySQL JDBC driver not found in .\lib\
    echo         Download: https://dev.mysql.com/downloads/connector/j/
    pause
    exit /b 1
)

echo [INFO] Found JDBC driver: %JAR%
echo [INFO] Compiling Java sources...

if not exist out mkdir out

REM Find all .java files and compile
dir /b /s src\*.java > sources.txt
javac -cp "%JAR%" -d out @sources.txt
del sources.txt

if errorlevel 1 (
    echo [ERROR] Compilation failed.
    pause
    exit /b 1
)

echo [OK] Compilation successful!
echo [INFO] Starting CampusEats server at http://localhost:8080
echo.

java -cp "out;%JAR%" com.college.canteen.server.Main

pause
