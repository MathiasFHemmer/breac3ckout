@echo off

:: Get the short Git commit hash
for /f %%i in ('git rev-parse --short HEAD') do set GIT_HASH=%%i

:: Get the current Git branch name
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set GIT_BRANCH=%%i

:: Get the current date and time
for /f "tokens=1-5 delims=/ " %%a in ('echo %date% %time%') do set BUILD_TIME=%%a %%b %%c %%d %%e

:: Create or overwrite version.h
echo module version; > ./src/version.c3
echo const String BUILD_VERSION = "%GIT_HASH%"; >> ./src/version.c3
echo const String BUILD_TIMESTAMP = "%BUILD_TIME%"; >> ./src/version.c3

c3c run --strip-unused=no